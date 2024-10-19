const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendNotification2 = functions.https.onRequest(async (req, res) => {
  const registrationToken = req.body.token; // รับ Token จากคำขอ
  const message = {
    notification: {
      title: req.body.title,
      body: req.body.body,
    },
    token: registrationToken, // Add trailing comma here
  };

  try {
    const response = await admin.messaging().send(message);
    res.status(200).send(`Notification sent successfully: ${response}`);
  } catch (error) {
    console.error("Error sending notification:", error);
    res.status(500).send("Error sending notification");
  }
});
