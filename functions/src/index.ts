/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// import {SecretManagerServiceClient} from '@google-cloud/secret-manager';
import { onDocumentCreated, onDocumentWritten } from 'firebase-functions/v2/firestore';
import { setGlobalOptions } from "firebase-functions/v2";
import { initializeApp } from 'firebase-admin/app';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';

// Initialize Firebase Admin
initializeApp();

const db = getFirestore();
const messaging = getMessaging();

// Set global options
setGlobalOptions({
  region: 'asia-southeast1',  // Set this to match your trigger region
  maxInstances: 10
});

// // Initialize Secret Manager client
// const secretManager = new SecretManagerServiceClient();

// // Cache structure
// interface SecretCache {
//   value: string;
//   timestamp: number;
// }

// // In-memory cache
// const secretCache: Record<string, SecretCache> = {};
// const CACHE_DURATION = 60 * 60 * 1000; // 1 hour in milliseconds

// // Get project ID from either environment variable or functions config
// const getProjectId = (): string => {
//   const projectId = process.env.GOOGLE_CLOUD_PROJECT || process.env.GCLOUD_PROJECT;
//   if (!projectId) {
//     throw new Error('Unable to determine project ID. Make sure you are running in a Firebase/GCP environment or set GOOGLE_CLOUD_PROJECT env variable.');
//   }
//   return projectId;
// };

// /**
//  * Fetches a secret from Google Cloud Secret Manager with caching
//  * @param secretName - Name of the secret to fetch
//  * @returns The secret value
//  */
// async function getSecret(secretName: string): Promise<string> {
//   try {
//     // Check cache first
//     const now = Date.now();
//     const cached = secretCache[secretName];
//     if (cached && (now - cached.timestamp) < CACHE_DURATION) {
//       logger.debug(`Using cached secret for ${secretName}`);
//       return cached.value;
//     }

//     // If not in cache or expired, fetch from Secret Manager
//     const projectId = admin.app().options.projectId;
//     if (!projectId) {
//       throw new Error('Project ID not found');
//     }

//     const name = `projects/${projectId}/secrets/${secretName}/versions/latest`;
    
//     const [version] = await secretManager.accessSecretVersion({
//       name: name,
//     });

//     const payload = version.payload?.data?.toString();
//     if (!payload) {
//       throw new Error(`Secret ${secretName} not found or empty`);
//     }

//     // Update cache
//     secretCache[secretName] = {
//       value: payload,
//       timestamp: now,
//     };

//     return payload;
//   } catch (error) {
//     logger.error(`Error fetching secret ${secretName}:`, error);
//     throw error;
//   }
// }

interface DeviceInfo {
  deviceId: string;
  deviceInfo: {
    androidVersion: string;
    fcmToken: string;
    brand: string;
    manufacturer: string;
    model: string;
  };
}

// Helper function to send notification to a specific device
async function sendNotification(token: string, title: string, body: string) {
  try {
    console.log(`Attempting to send notification to token: ${token.substring(0, 6)}...`);
    console.log(`Notification content - Title: ${title}, Body: ${body}`);
    
    await messaging.send({
      token,
      notification: {
        title,
        body,
      },
      android: {
        priority: 'high',
      },
    });
    
    console.log(`Successfully sent notification to token: ${token.substring(0, 6)}...`);
    return true;
  } catch (error) {
    console.error(`Error sending notification to token: ${token.substring(0, 6)}...`, error);
    return false;
  }
}

// Helper function to get all device tokens for a user
async function getUserDeviceTokens(userId: string): Promise<string[]> {
  console.log(`Fetching device tokens for user: ${userId}`);
  
  const userDoc = await db
    .collection('users')
    .doc(userId)
    .get();

  const userData = userDoc.data();
  if (!userData) {
    console.log(`No user data found for ID: ${userId}`);
    return [];
  }
  
  if (!userData.devices) {
    console.log(`No devices found for user: ${userId}`);
    return [];
  }

  const devices = userData.devices as DeviceInfo[];
  const tokens = devices
    .map(device => device.deviceInfo.fcmToken)
    .filter(token => token !== undefined && token !== null);
    
  console.log(`Found ${tokens.length} valid tokens for user: ${userId}`);
  return tokens;
}

// Send notification when announcement is created
exports.sendAnnouncementNotification = onDocumentCreated('announcements/{announcementId}', async (event) => {
  try {
    const announcement = event.data?.data();
    if (!announcement) {
      console.log('No announcement data found');
      return;
    }

    // Get the course details
    const courseDoc = await db
      .collection('courses')
      .doc(announcement.courseId)
      .get();
    
    const courseData = courseDoc.data();
    if (!courseData) {
      console.log('No course data found for:', announcement.courseId);
      return;
    }

    // Get all students from class_students collection
    const classStudentsSnapshot = await db
      .collection('class_students')
      .where('courseId', '==', announcement.courseId)
      .where('semesterId', '==', announcement.semesterId)
      .get();

    // Get all student IDs
    const studentIds = classStudentsSnapshot.docs.map(doc => doc.data().studentId);

    if (studentIds.length === 0) {
      console.log('No students found for course:', announcement.courseId);
      return;
    }

    // Prepare notification content
    const title = `New Announcement: ${courseData.code}`;
    const body = announcement.title;

    // Process students in batches of 500 to avoid memory issues
    const batchSize = 500;
    for (let i = 0; i < studentIds.length; i += batchSize) {
      const batch = studentIds.slice(i, i + batchSize);
      
      // Get all device tokens for each student in the batch and send notifications
      const batchPromises = batch.map(async (studentId) => {
        try {
          const tokens = await getUserDeviceTokens(studentId);
          return tokens.map(token => sendNotification(token, title, body));
        } catch (error) {
          console.error(`Error getting devices for student ${studentId}:`, error);
          return [];
        }
      });

      // Wait for all notifications in this batch to complete
      await Promise.all((await Promise.all(batchPromises)).flat());
      console.log(`Processed batch of ${batch.length} students`);
    }
    
    console.log(`Successfully sent notifications for announcement ${event.params.announcementId} to ${studentIds.length} students`);

  } catch (error) {
    console.error('Error sending announcement notification:', error);
  }
});

// Send notification when exam schedule is created
exports.sendExamScheduleNotification = onDocumentCreated('exam_schedules/{examId}', async (event) => {
  try {
    const examSchedule = event.data?.data();
    if (!examSchedule) {
      console.log('No exam schedule data found');
      return;
    }

    // Get the course details
    const courseDoc = await db
      .collection('courses')
      .doc(examSchedule.courseId)
      .get();
    
    const courseData = courseDoc.data();
    if (!courseData) {
      console.log('No course data found for:', examSchedule.courseId);
      return;
    }

    // Get all students from class_students collection
    const classStudentsSnapshot = await db
      .collection('class_students')
      .where('courseId', '==', examSchedule.courseId)
      .where('semesterId', '==', examSchedule.semesterId)
      .get();

    // Get all student IDs
    const studentIds = classStudentsSnapshot.docs.map(doc => doc.data().studentId);

    if (studentIds.length === 0) {
      console.log('No students found for course:', examSchedule.courseId);
      return;
    }

    // Format date and time for notification
    const examDate = examSchedule.date.toDate();
    const formattedDate = examDate.toLocaleDateString('en-US', {
      weekday: 'short',
      month: 'short',
      day: 'numeric',
    });

    const formatTime = (time: { hour: number; minute: number }) => {
      const hour = time.hour % 12 || 12;
      const minute = time.minute.toString().padStart(2, '0');
      const period = time.hour < 12 ? 'AM' : 'PM';
      return `${hour}:${minute} ${period}`;
    };

    // Prepare notification content
    const title = `New Exam Schedule: ${courseData.code}`;
    const body = `${examSchedule.title} on ${formattedDate} at ${formatTime(examSchedule.startTime)} in ${examSchedule.room}`;

    // Process students in batches of 500 to avoid memory issues
    const batchSize = 500;
    for (let i = 0; i < studentIds.length; i += batchSize) {
      const batch = studentIds.slice(i, i + batchSize);
      
      // Get all device tokens for each student in the batch and send notifications
      const batchPromises = batch.map(async (studentId) => {
        try {
          const tokens = await getUserDeviceTokens(studentId);
          return tokens.map(token => sendNotification(token, title, body));
        } catch (error) {
          console.error(`Error getting devices for student ${studentId}:`, error);
          return [];
        }
      });

      // Wait for all notifications in this batch to complete
      await Promise.all((await Promise.all(batchPromises)).flat());
      console.log(`Processed batch of ${batch.length} students`);
    }
    
    console.log(`Successfully sent notifications for exam schedule ${event.params.examId} to ${studentIds.length} students`);

  } catch (error) {
    console.error('Error sending exam schedule notification:', error);
  }
});

// This function triggers when a new schedule is created
export const checkScheduleNotifications = onDocumentCreated(
    'schedules/{scheduleId}',
    async (event) => {
        const data = event.data?.data();
        if (!data) return;

        const startTime = data.startTime;
        const notifyBefore = data.notifyBefore || 15; // minutes

        // Calculate next notification time
        const nextNotificationTime = new Date();
        nextNotificationTime.setHours(startTime.hour);
        nextNotificationTime.setMinutes(startTime.minute - notifyBefore);

        // Store notification schedule
        await db.collection('schedule_notifications').add({
            scheduleId: event.data?.id,
            nextNotification: Timestamp.fromDate(nextNotificationTime),
            courseId: data.courseId,
            semesterId: data.semesterId,
            subjectData: data.subjectData,
            roomData: data.roomData,
            day: data.day,
            startTime: data.startTime
        });
    }
);

// This function processes pending notifications
export const processScheduleNotifications = onDocumentWritten(
    'schedule_notifications/{notificationId}',
    async (event) => {
        console.log(`Processing notification document: ${event.params.notificationId}`);
        
        const data = event.data?.after?.data();
        if (!data) {
            console.log('No data found in notification document');
            return;
        }

        const now = Timestamp.now();
        console.log(`Current time: ${now.toDate()}`);
        console.log(`Next notification time: ${data.nextNotification.toDate()}`);

        // Check if it's time to send notification
        if (data.nextNotification.toDate() <= now.toDate()) {
            try {
                console.log(`Starting notification process for course: ${data.courseId}`);
                
                // Get students in this class
                const students = await db
                    .collection('class_students')
                    .where('courseId', '==', data.courseId)
                    .where('semesterId', '==', data.semesterId)
                    .get();

                // Get all student IDs
                const studentIds = students.docs.map(doc => doc.data().studentId);
                console.log(`Found ${studentIds.length} students in the class`);

                if (studentIds.length === 0) {
                    console.log('No students found for course:', data.courseId);
                    return;
                }

                // Format time for display
                const timeString = `${data.startTime.hour.toString().padStart(2, '0')}:${data.startTime.minute.toString().padStart(2, '0')}`;
                console.log(`Formatted time string: ${timeString}`);

                let successfulNotifications = 0;
                let failedNotifications = 0;

                // Process students in batches
                const batchSize = 500;
                for (let i = 0; i < studentIds.length; i += batchSize) {
                    const batch = studentIds.slice(i, i + batchSize);
                    console.log(`Processing batch ${Math.floor(i/batchSize) + 1} with ${batch.length} students`);
                    
                    const batchPromises = batch.map(async (studentId) => {
                        try {
                            const tokens = await getUserDeviceTokens(studentId);
                            const results = await Promise.all(
                                tokens.map(token => 
                                    sendNotification(
                                        token,
                                        `Upcoming Class: ${data.subjectData.title}`,
                                        `Your class starts at ${timeString} in Room ${data.roomData.name}`
                                    )
                                )
                            );
                            
                            const successful = results.filter(result => result).length;
                            const failed = results.length - successful;
                            
                            successfulNotifications += successful;
                            failedNotifications += failed;
                            
                            return results;
                        } catch (error) {
                            console.error(`Error processing student ${studentId}:`, error);
                            failedNotifications += 1;
                            return [];
                        }
                    });

                    await Promise.all(batchPromises);
                    console.log(`Completed batch ${Math.floor(i/batchSize) + 1}`);
                }

                // Calculate next notification time (for next week)
                const nextWeek = new Date(data.nextNotification.toDate());
                nextWeek.setDate(nextWeek.getDate() + 7);
                console.log(`Setting next notification time to: ${nextWeek}`);

                // Update next notification time
                await event.data?.after?.ref.update({
                    nextNotification: Timestamp.fromDate(nextWeek)
                });

                console.log(`Notification summary:
                - Total students: ${studentIds.length}
                - Successful notifications: ${successfulNotifications}
                - Failed notifications: ${failedNotifications}
                - Next notification scheduled for: ${nextWeek}`);

            } catch (error) {
                console.error('Error processing notification:', error);
                throw error;
            }
        } else {
            console.log('Not yet time to send notification');
        }
    }
);
