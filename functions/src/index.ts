/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import {SecretManagerServiceClient} from '@google-cloud/secret-manager';
import * as functions from 'firebase-functions';
import { sendNotificationToUserDevices } from "./notification";

// Initialize Firebase Admin
admin.initializeApp();

// Initialize Secret Manager client
const secretManager = new SecretManagerServiceClient();

// Cache structure
interface SecretCache {
  value: string;
  timestamp: number;
}

// In-memory cache
const secretCache: Record<string, SecretCache> = {};
const CACHE_DURATION = 60 * 60 * 1000; // 1 hour in milliseconds

// Get project ID from either environment variable or functions config
const getProjectId = (): string => {
  const projectId = process.env.GOOGLE_CLOUD_PROJECT || process.env.GCLOUD_PROJECT;
  if (!projectId) {
    throw new Error('Unable to determine project ID. Make sure you are running in a Firebase/GCP environment or set GOOGLE_CLOUD_PROJECT env variable.');
  }
  return projectId;
};

/**
 * Fetches a secret from Google Cloud Secret Manager with caching
 * @param secretName - Name of the secret to fetch
 * @returns The secret value
 */
async function getSecret(secretName: string): Promise<string> {
  try {
    // Check cache first
    const now = Date.now();
    const cached = secretCache[secretName];
    if (cached && (now - cached.timestamp) < CACHE_DURATION) {
      logger.debug(`Using cached secret for ${secretName}`);
      return cached.value;
    }

    // If not in cache or expired, fetch from Secret Manager
    const projectId = admin.app().options.projectId;
    if (!projectId) {
      throw new Error('Project ID not found');
    }

    const name = `projects/${projectId}/secrets/${secretName}/versions/latest`;
    
    const [version] = await secretManager.accessSecretVersion({
      name: name,
    });

    const payload = version.payload?.data?.toString();
    if (!payload) {
      throw new Error(`Secret ${secretName} not found or empty`);
    }

    // Update cache
    secretCache[secretName] = {
      value: payload,
      timestamp: now,
    };

    return payload;
  } catch (error) {
    logger.error(`Error fetching secret ${secretName}:`, error);
    throw error;
  }
}

// send notification if device id is added to firestore
exports.sendSampleNotification = functions.firestore.onDocumentCreated('users/{userId}/devices/{deviceId}', async (event) => {
  const { userId, deviceId } = event.params;

  const device = await admin.firestore().collection('users').doc(userId).collection('devices').doc(deviceId).get();

  const deviceData = device.data();

  const fcmToken = deviceData?.fcmToken;
  
  if (!fcmToken) {
    logger.error(`No FCM token found for user ${userId} and device ${deviceId}`);
    return;
  }

  await sendNotificationToUserDevices(userId, 'Sample Notification', 'This is a sample notification');
});
