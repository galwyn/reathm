/*
 * This script fetches and displays accomplishments for a specific user on a given day.
 *
 * Usage:
 * - To view accomplishments for a specific user today:
 *   node scripts/view_accomplishments.js <userId>
 *
 * - To view accomplishments for a specific user on a specific date:
 *   node scripts/view_accomplishments.js <userId> YYYY-MM-DD
 *
 * Example:
 *   node scripts/view_accomplishments.js nXT0qdPYkbYBPyaVUByzKo7MCRt2 2025-09-13
 */

const admin = require('firebase-admin');
const serviceAccount = require('../serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function viewAccomplishments(userId, dateStr) {
  if (!userId) {
    console.error('Error: User ID is a required argument.');
    console.log('Usage: node scripts/view_accomplishments.js <userId> [YYYY-MM-DD]');
    return;
  }

  let targetDay;
  if (dateStr) {
    targetDay = new Date(dateStr);
    if (isNaN(targetDay.getTime())) {
      console.error(`Error: Invalid date format "${dateStr}". Please use YYYY-MM-DD.`);
      return;
    }
  } else {
    targetDay = new Date();
  }

  const startOfDay = new Date(targetDay.getFullYear(), targetDay.getMonth(), targetDay.getDate());
  const endOfDay = new Date(startOfDay.getTime() + 24 * 60 * 60 * 1000);

  console.log(`Fetching accomplishments for user "${userId}" on ${startOfDay.toDateString()}...`);

  const snapshot = await db
    .collection('users')
    .doc(userId)
    .collection('accomplishments')
    .where('timestamp', '>=', startOfDay)
    .where('timestamp', '<', endOfDay)
    .orderBy('timestamp')
    .get();

  if (snapshot.empty) {
    console.log('No accomplishments found for this day.');
    return;
  }

  console.log('\n--- Accomplishments ---');
  snapshot.docs.forEach((doc) => {
    const data = doc.data();
    const timestamp = data.timestamp.toDate();
    console.log(`- ${data.activity} (at ${timestamp.toLocaleTimeString()})`);
  });
  console.log('-----------------------\n');
}

const [,, userId, dateStr] = process.argv;
viewAccomplishments(userId, dateStr).catch(console.error);
