#!/usr/bin/env node

/**
 * seed-admin.js
 * Node script for creating or updating an admin user in Firebase Auth and Firestore
 * Usage:
 *   Required: service account key (set GOOGLE_APPLICATION_CREDENTIALS to path of JSON)
 *
 * Examples:
 *   PowerShell:
 *     $env:GOOGLE_APPLICATION_CREDENTIALS = "C:\path\to\serviceAccountKey.json"; npm run seed-admin -- --email admin@example.com --password admin --first Admin --last User --username admin
 *
 *   macOS / Linux:
 *     export GOOGLE_APPLICATION_CREDENTIALS=/path/to/serviceAccountKey.json
 *     npm run seed-admin -- --email admin@example.com --password admin --first Admin --last User --username admin
 */

const admin = require('firebase-admin');

function parseArgs() {
  const args = {};
  const argv = process.argv.slice(2);
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a.startsWith('--')) {
      const key = a.slice(2);
      const val = argv[i + 1] && !argv[i + 1].startsWith('--') ? argv[++i] : true;
      args[key] = val;
    }
  }
  return args;
}

(async function main() {
  try {
    const args = parseArgs();
    const email = args.email || 'admin@example.com';
    const password = args.password || 'admin';
    const first = args.first || 'Admin';
    const last = args.last || 'User';
    const username = args.username || args.user || null;
    const role = args.role || 'administrator';

    if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
      console.warn('\nWarning: GOOGLE_APPLICATION_CREDENTIALS is not set.\nSet it to the path of your service account key JSON file before running this script.');
    }

    // Initialize the Firebase Admin SDK using application default credentials (GOOGLE_APPLICATION_CREDENTIALS)
    if (!admin.apps.length) {
      admin.initializeApp();
    }

    const auth = admin.auth();
    const db = admin.firestore();

    console.log(`Seeding admin user: ${email}`);

    let userRecord;
    try {
      // Try to find existing user by email
      userRecord = await auth.getUserByEmail(email);
      console.log(`User already exists with uid=${userRecord.uid}, updating password...`);
      // Update password (if provided)
      await auth.updateUser(userRecord.uid, { password });
    } catch (err) {
      // If user not found, create; otherwise rethrow
      if (err.code === 'auth/user-not-found') {
        console.log('User not found, creating...');
        userRecord = await auth.createUser({ email, password, displayName: `${first} ${last}` });
        console.log(`Created user uid=${userRecord.uid}`);
      } else {
        console.error('Error getting user by email:', err);
        throw err;
      }
    }

    // Set custom claim admin: true for server-side checks (optional but useful)
    try {
      await auth.setCustomUserClaims(userRecord.uid, { admin: true });
      console.log('Custom claims set { admin: true }');
    } catch (e) {
      console.warn('Warning: Could not set custom claims:', e.message || e);
    }

    // Ensure Firestore users/<uid> document exists and has role and profile
    const userDocRef = db.collection('users').doc(userRecord.uid);
    const docData = {
      firstName: first,
      lastName: last,
      email: email,
      role: role,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    if (username) docData.username = username;

    await userDocRef.set(docData, { merge: true });

    console.log(`Firestore entry created/updated for user with role: ${role}`);
    console.log('Admin user seeding complete.');
  } catch (err) {
    console.error('Failed to seed admin user:', err);
    process.exitCode = 1;
  }
})();
