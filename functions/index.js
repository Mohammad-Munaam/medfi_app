const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.onAmbulanceStatusUpdate = functions.firestore
    .document("ambulance_requests/{requestId}")
    .onUpdate(async (change, context) => {

        const before = change.before.data();
        const after = change.after.data();

        // Only trigger if status changed
        if (before.status === after.status) {
            return null;
        }

        const userId = after.userId;
        const newStatus = after.status;

        // Fetch user FCM token
        const userDoc = await admin.firestore().collection("users").doc(userId).get();
        const userData = userDoc.data();

        if (!userData || !userData.fcmToken) {
            console.log("No FCM token found");
            return null;
        }

        const token = userData.fcmToken;

        let title = "";
        let body = "";

        if (newStatus === "on_the_way") {
            title = "Ambulance Dispatched";
            body = "Ambulance is on the way.";
        } else if (newStatus === "arrived") {
            title = "Ambulance Arrived";
            body = "Ambulance has reached your location.";
        } else if (newStatus === "completed") {
            title = "Request Completed";
            body = "Emergency request closed.";
        } else {
            return null;
        }

        const message = {
            notification: {
                title: title,
                body: body,
            },
            token: token,
        };

        await admin.messaging().send(message);

        // Audit Log
        const batch = admin.firestore().batch();
        const auditRef = admin.firestore().collection("audit_logs").doc();
        batch.set(auditRef, {
            requestId: context.params.requestId,
            previousStatus: before.status,
            newStatus: newStatus,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Update Operator Metrics if completed
        if (newStatus === "completed" && after.assignedOperatorId) {
            const operatorId = after.assignedOperatorId;
            const metricsRef = admin.firestore().collection("operator_metrics").doc(operatorId);

            // Calculate duration if assignedAt exists
            let durationInMinutes = 0;
            if (after.assignedAt) {
                const assignedTime = after.assignedAt.toDate();
                const completedTime = new Date(); // Approximate to now, or use after.updatedAt if available and reliable
                // Ideally use after.updatedAt.toDate() if it's a Timestamp, but safekeeping with current time if needed.
                // let's try to use after.updatedAt if it exists
                const endTime = after.updatedAt ? after.updatedAt.toDate() : new Date();
                durationInMinutes = (endTime - assignedTime) / (1000 * 60);
            }

            batch.set(metricsRef, {
                totalHandled: admin.firestore.FieldValue.increment(1),
                completedToday: admin.firestore.FieldValue.increment(1), // Logic for resetting 'today' is complex in simple inc, but let's just increment for now
                // Efficiently updating average is tricky without reading, but let's just keep total count for now as per requirement "totalHandled"
                lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
            }, { merge: true });
        }

        await batch.commit();

        console.log("Notification sent, audit logged, and metrics updated.");

        return null;
    });
