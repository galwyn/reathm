/*
 * This script cleans up the Firestore database by migrating the schema for daily activities.
 * It removes the old 'completed' field and adds the 'isActive' field to each activity.
 *
 * To run this script:
 * 1. Make sure you have authenticated with Firebase: `firebase login`
 * 2. Set up your project: `firebase use <your-project-id>`
 * 3. Run the script from the `functions` directory: `node scripts/cleanup_database.js`
 */

const admin = require('firebase-admin');
const serviceAccount = require('../serviceAccountKey.json'); // You need to download this from your Firebase project settings

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function deleteCollection(db, collectionPath, batchSize) {
  const collectionRef = db.collection(collectionPath);
  const query = collectionRef.orderBy('__name__').limit(batchSize);

  return new Promise((resolve, reject) => {
    deleteQueryBatch(db, query, resolve).catch(reject);
  });
}

async function deleteQueryBatch(db, query, resolve) {
  const snapshot = await query.get();

  const batchSize = snapshot.size;
  if (batchSize === 0) {
    // When there are no documents left, we are done
    resolve();
    return;
  }

  // Delete documents in a batch
  const batch = db.batch();
  snapshot.docs.forEach((doc) => {
    batch.delete(doc.ref);
  });
  await batch.commit();

  // Recurse on the next process tick, to avoid
  // exploding the stack.
  process.nextTick(() => {
    deleteQueryBatch(db, query, resolve);
  });
}

async function cleanupDatabase() {
  console.log('Starting database cleanup...');

  const usersSnapshot = await db.collection('users').get();

  for (const userDoc of usersSnapshot.docs) {
    const userData = userDoc.data();
    const dailyActivities = userData.daily_activities;

    if (dailyActivities) {
      const updatedActivities = {};
      let needsUpdate = false;

      for (const activityId in dailyActivities) {
        const activity = dailyActivities[activityId];
        updatedActivities[activityId] = {
          id: activity.id,
          name: activity.name,
          emoji: activity.emoji,
          isActive: true, // Set isActive to true by default
        };
        if (activity.hasOwnProperty('completed')) {
          needsUpdate = true;
        }
      }

      if (needsUpdate) {
        console.log(`Updating activities for user ${userDoc.id}`);
        await userDoc.ref.update({ daily_activities: updatedActivities });
      }
    }

    console.log(`Deleting old 'activities' subcollection for user ${userDoc.id}`);
    await deleteCollection(db, `users/${userDoc.id}/activities`, 50);
  }

  console.log('Deleting user_activities collection...');
  await deleteCollection(db, 'user_activities', 50);
  console.log('user_activities collection deleted.');

  console.log('Database cleanup complete.');
}

cleanupDatabase().catch(console.error);
