import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";

export async function sendNotificationToUserDevices(userId: string, title: string, body: string) {
  const userDevices = await admin.firestore()
    .collection('users')
    .doc(userId)
    .collection('devices')
    .get();

  // Filter out any null or undefined tokens
  const tokens = userDevices.docs
    .map(doc => doc.data().fcmToken)
    .filter((token): token is string => !!token); // Filter out null/undefined tokens

  if (tokens.length === 0) {
    logger.error(`No valid FCM tokens found for user ${userId}`);
    return;
  }

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

  logger.info(`Notification sent to ${tokens.length} devices for user ${userId}`);
}