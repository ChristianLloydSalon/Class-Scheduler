/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import * as admin from "firebase-admin";
// import {SecretManagerServiceClient} from '@google-cloud/secret-manager';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { setGlobalOptions } from "firebase-functions/v2";
import { sendNotificationToUserDevices } from "./notification";

// Initialize Firebase Admin
admin.initializeApp();

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
  fcmToken: string;
  deviceInfo: {
    androidVersion: string;
    brand: string;
    manufacturer: string;
    model: string;
  };
}

// Helper function to send notification to a specific device
async function sendNotification(token: string, title: string, body: string) {
  try {
    await admin.messaging().send({
      token,
      notification: {
        title,
        body,
      },
      android: {
        priority: 'high',
      },
    });
  } catch (error) {
    console.error('Error sending notification to token:', error);
  }
}

// Helper function to get all device tokens for a user
async function getUserDeviceTokens(userId: string): Promise<string[]> {
  const userDoc = await admin.firestore()
    .collection('users')
    .doc(userId)
    .get();

  const userData = userDoc.data();
  if (!userData || !userData.devices) return [];

  const devices = userData.devices as DeviceInfo[];
  return devices
    .map(device => device.fcmToken)
    .filter(token => token !== undefined && token !== null);
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
    const courseDoc = await admin.firestore()
      .collection('courses')
      .doc(announcement.courseId)
      .get();
    
    const courseData = courseDoc.data();
    if (!courseData) {
      console.log('No course data found for:', announcement.courseId);
      return;
    }

    // Get all students from class_students collection
    const classStudentsSnapshot = await admin.firestore()
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
    const courseDoc = await admin.firestore()
      .collection('courses')
      .doc(examSchedule.courseId)
      .get();
    
    const courseData = courseDoc.data();
    if (!courseData) {
      console.log('No course data found for:', examSchedule.courseId);
      return;
    }

    // Get all students from class_students collection
    const classStudentsSnapshot = await admin.firestore()
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
