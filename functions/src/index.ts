import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

export const deleteUser = functions.https.onRequest(async (request, response) => {
    // TODO: Make sure body (it may be null!), userEmail and
    // collection have values. Return HTTP 400 if not.
    const userEmail = request.body.data.email;
    const collection = request.body.data.coll;
    
    // IMPORTANT TODO: Make sure the calling user/admin is properly
    // authorized to delete this account. Return HTTP 403 if not.

    deleteUserByEmail(userEmail, collection)
        .then((uid) => {
            // consider the RESTful empty HTTP 204 response
            // response.status(200).send('deleted');
            response.json({result: 'User with ID: $uid successfully deleted.'});
        })
        .catch((err) => {
            if (err && err.code === "auth/user-not-found") {
                // an already deleted user should be considered a success?
                response.json({result: 'User might have been deleted already.'});
                return;
            }

            // IMPORTANT: Don't forget to log the error for debugging later
            console.error("Failed to delete user by email. Error Code: " + (err.code || "unknown"), err);
            response.json({result: 'Failed to delete User with error: $err.'});
        }); 
})

async function deleteUserByEmail(userEmail: string, collection: string) {
    // grabs services first to make sure they are initialized
    const auth = admin.auth();
    const db = admin.firestore();
    
    // gets a user by their email, throws an error if not found
    const { uid } = await auth.getUserByEmail(userEmail);
    
    // These can be done in parallel using Promise.all()
    await auth.deleteUser(uid);
    await db.collection(collection)
        .doc(uid)
        .delete();

    return uid;
}

export const sendByFCMAdmin = functions.https.onRequest(async (request, response) => {
    const token = request.body.data.token;
    const title = request.body.data.title;

    const body = request.body.data.body;
    const otherData = request.body.data.other;

    //const firestore = admin.firestore();
    
    // Get the owners details
    //const owner = firestore.collection("users").doc(ownerId).get();
  
    // Get the users details
    //const user = firestore.collection("users").doc(userId).get();

    const message = {
        notification: {
            title: title,
            body: body
        },
        data: {
          data: otherData
        },
        token: token
    };
  
    await admin.messaging().send(message).then((res) => {
        // Response is a message ID string.
        console.log('Successfully sent message:', res);
        response.json({result: 'Notification $res successfully sent.'});
      })
      .catch((error) => {
        console.log('Error sending message:', error);
        response.json({result: 'Failed to send notification with error: $error.'});
      });
})
