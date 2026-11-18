// Sends a push notification to every app user when a new story is published.
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

exports.notifyNewStory = onDocumentCreated(
  { document: "news/{id}", region: "asia-south1" },
  async (event) => {
    const n = event.data?.data();
    if (!n || !n.published || n.notify === false) return;

    const message = {
      notification: {
        title: n.title,
        body: (n.body || "").slice(0, 120),
        ...(n.imageUrl ? { imageUrl: n.imageUrl } : {}),
      },
      android: { notification: { color: "#5B1F8F" } },
      data: { newsId: event.params.id },
    };

    await getMessaging().send({ ...message, topic: "news" });
  }
);
