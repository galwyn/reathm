const {onCall} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {GoogleGenerativeAI} = require("@google/generative-ai");

admin.initializeApp();

/**
 * Generates an affirmation based on a theme/persona.
 * First checks Firestore for a cached affirmation of the same theme
 * that hasn't been used recently (implied simple cache).
 * If none, calls Gemini.
 */
exports.generateAffirmation = onCall(async (request) => {
  logger.info("generateAffirmation request received", {structuredData: true});

  const theme = request.data.theme || "general";
  const collectionRef = admin.firestore().collection("affirmations_cache");

  try {
    // 1. Check cache: Get a random affirmation for this theme
    // For simplicity, we get one where 'usedCount' is low or just random.
    // Real production might need better randomization logic.
    const snapshot = await collectionRef
        .where("theme", "==", theme)
        .limit(10)
        .get();

    if (!snapshot.empty) {
      // Pick a random one from the batch
      const docs = snapshot.docs;
      const randomDoc = docs[Math.floor(Math.random() * docs.length)];
      logger.info("Serving affirmation from cache", {structuredData: true});
      return {affirmation: randomDoc.data().text};
    }

    // 2. If Cache Miss, Call Gemini
    const genAI = new GoogleGenerativeAI(process.env.GEMINI_KEY);
    const model = genAI.getGenerativeModel({model: "gemini-2.5-flash"});

    let prompt = "";
    switch (theme) {
      case "stoic":
        prompt = "Generate a short, powerful Stoic affirmation about " +
          "resilience, control, or virtue. Max 15 words.";
        break;
      case "tough_love":
        prompt = "Generate a short, direct 'tough love' affirmation " +
          "challenging the user to take action and stop making excuses. " +
          "Max 15 words.";
        break;
      case "gentle":
        prompt = "Generate a soft, comforting affirmation about " +
          "self-compassion and patience. Max 15 words.";
        break;
      case "spiritual":
        prompt = "Generate a deep, spiritual affirmation about " +
          "connection to the universe or inner peace. Max 15 words.";
        break;
      default:
        prompt = "Generate a positive, inspiring affirmation. Max 15 words.";
    }

    const result = await model.generateContent(prompt);
    const affirmationText = result.response.text().trim();

    // 3. Store in Cache for future use
    await collectionRef.add({
      text: affirmationText,
      theme: theme,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    logger.info("Affirmation generated via AI and cached",
        {structuredData: true});
    return {affirmation: affirmationText};
  } catch (error) {
    logger.error("Error generating affirmation:", error);
    // Fallback if AI fails
    return {affirmation: "You are stronger than you know."};
  }
});

exports.generateEncouragement = onCall(async (request) => {
  logger.info("generateEncouragement request received",
      {structuredData: true});

  const genAI = new GoogleGenerativeAI(process.env.GEMINI_KEY);
  const completedActivity = request.data.completedActivity;

  if (!completedActivity) {
    logger.error("No completedActivity provided");
    throw new functions.https.HttpsError(
        "invalid-argument",
        "No completedActivity provided",
    );
  }

  try {
    const model = genAI.getGenerativeModel({model: "gemini-2.5-flash"});
    const prompt = "Generate a single, short, encouraging sentence for " +
      `someone who completed this activity: ${completedActivity}.`;
    const result = await model.generateContent(prompt);
    const encouragement = result.response.text();
    logger.info("Encouragement generated successfully",
        {structuredData: true});
    return {encouragement: encouragement};
  } catch (error) {
    logger.error("Error generating encouragement:", error);
    throw new functions.https.HttpsError(
        "internal",
        "Error generating encouragement",
    );
  }
});

exports.generateNewAffirmation = onCall(async (request) => {
  // Same logic as generateAffirmation but forces a new generation
  // (ignoring cache) because the user specifically disliked the previous one.
  logger.info("generateNewAffirmation request received",
      {structuredData: true});

  const genAI = new GoogleGenerativeAI(process.env.GEMINI_KEY);
  const dislikedAffirmation = request.data.dislikedAffirmation;
  const theme = request.data.theme || "general";

  if (!dislikedAffirmation) {
    logger.error("No dislikedAffirmation provided");
    throw new functions.https.HttpsError(
        "invalid-argument",
        "No dislikedAffirmation provided",
    );
  }

  try {
    const model = genAI.getGenerativeModel({model: "gemini-2.5-flash"});
    const prompt = `Generate a new, different affirmation (Theme: ${theme}), ` +
      "between 8 and 14 words long. " +
      `The user disliked this one: "${dislikedAffirmation}".`;
    const result = await model.generateContent(prompt);
    const affirmationText = result.response.text().trim();

    // Cache this new one too
    await admin.firestore().collection("affirmations_cache").add({
      text: affirmationText,
      theme: theme,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    logger.info("New affirmation generated successfully",
        {structuredData: true});
    return {affirmation: affirmationText};
  } catch (error) {
    logger.error("Error generating new affirmation:", error);
    throw new functions.https.HttpsError(
        "internal",
        "Error generating new affirmation",
    );
  }
});

exports.deleteUserAccount = onCall(async (request) => {
  const uid = request.auth.uid;
  if (!uid) {
    throw new functions.https.HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
    );
  }
  try {
    // Delete user data from Firestore
    await admin.firestore().collection("users").doc(uid).delete();
    // Delete user from Firebase Authentication
    await admin.auth().deleteUser(uid);
    logger.info(`Successfully deleted user ${uid}`);
    return {success: true};
  } catch (error) {
    logger.error(`Error deleting user ${uid}:`, error);
    throw new functions.HttpsError(
        "internal",
        "Error deleting user account.",
    );
  }
});
