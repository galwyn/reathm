const {onCall} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const functions = require("firebase-functions");
const {GoogleGenerativeAI} = require("@google/generative-ai");


exports.generateAffirmation = onCall(async (request) => {
  logger.info("generateAffirmation request received",
      {structuredData: true});

  // Get the Gemini API key from the environment variables
  const genAI = new GoogleGenerativeAI(process.env.GEMINI_KEY);

  const prompt = request.data.prompt;

  if (!prompt) {
    logger.error("No prompt provided");
    throw new functions.https.HttpsError(
        "invalid-argument",
        "No prompt provided",
    );
  }

  try {
    const model = genAI.getGenerativeModel({model: "gemini-1.5-flash"});
    const result = await model.generateContent(prompt);
    const affirmation = result.response.text();
    logger.info("Affirmation generated successfully",
        {structuredData: true});
    return {affirmation: affirmation};
  } catch (error) {
    logger.error("Error generating affirmation:", error);
    throw new functions.https.HttpsError(
        "internal",
        "Error generating affirmation",
    );
  }
});

exports.generateEncouragement = onCall(async (request) => {
  logger.info("generateEncouragement request received",
      {structuredData: true});

  // Get the Gemini API key from the environment variables
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
    const model = genAI.getGenerativeModel({model: "gemini-1.5-flash"});
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
  logger.info("generateNewAffirmation request received",
      {structuredData: true});

  // Get the Gemini API key from the environment variables
  const genAI = new GoogleGenerativeAI(process.env.GEMINI_KEY);

  const dislikedAffirmation = request.data.dislikedAffirmation;

  if (!dislikedAffirmation) {
    logger.error("No dislikedAffirmation provided");
    throw new functions.https.HttpsError(
        "invalid-argument",
        "No dislikedAffirmation provided",
    );
  }

  try {
    const model = genAI.getGenerativeModel({model: "gemini-1.5-flash"});
    const prompt = "Generate a new, different affirmation, " +
      "between 8 and 14 words long. " +
      `The user disliked this one: "${dislikedAffirmation}".`;
    const result = await model.generateContent(prompt);
    const affirmation = result.response.text();
    logger.info("New affirmation generated successfully",
        {structuredData: true});
    return {affirmation: affirmation};
  } catch (error) {
    logger.error("Error generating new affirmation:", error);
    throw new functions.https.HttpsError(
        "internal",
        "Error generating new affirmation",
    );
  }
});
