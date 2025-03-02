import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";


/**
 * Send notification to a specific user
 * @param userId - Firebase Auth UID
 * @param title - Notification title
 * @param body - Notification body
 */
async function sendNotificationToUser(
  userId: string, 
  title: string, 
  body: string
): Promise<void> {
  try {
    // Get user's FCM token from Firestore
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(userId)
      .get();

    const fcmToken = userDoc.data()?.fcmToken;
    
    if (!fcmToken) {
      throw new Error(`No FCM token found for user ${userId}`);
    }

    // Send the notification
    await admin.messaging().send({
      token: fcmToken,
      notification: {
        title,
        body,
      },
      android: {
        priority: 'high',
        notification: {
          title,
            body,
        },
      },
    });

    logger.info(`Notification sent to user ${userId}`);
  } catch (error) {
    logger.error(`Error sending notification to user ${userId}:`, error);
    throw error;
  }
}

export async function sendNotificationToUserDevices(userId: string, title: string, body: string) {
  const userDevices = await admin.firestore()
    .collection('users')
    .doc(userId)
    .collection('devices')
    .get();

  const tokens = userDevices.docs.map(doc => doc.data().fcmToken);

  if (tokens.length === 0) {
    throw new Error(`No devices found for user ${userId}`);
  }

  // Send to multiple tokens
  await admin.messaging().sendEachForMulticast({
    tokens,
    notification: {
      title,
      body,
    },
  });
}

// Example HTTP function to trigger notification
export const sendNotification = onRequest(async (req, res) => {
  try {
    const { userId, title, body } = req.body;

    await sendNotificationToUser(userId, title, body);
    
    res.status(200).send('Notification sent successfully');
  } catch (error) {
    logger.error('Error:', error);
    res.status(500).send('Error sending notification');
  }
});