const functions = require("firebase-functions");
const admin = require('firebase-admin');
admin.initializeApp();


exports.followEvent =  functions.firestore.document('followers/{followedId}/usersFollowers/{followingId}').onCreate(async (snapshot,context) => {
    const followedId = context.params.followedId;
    const followingId = context.params.followingId;


    const postssnapshot = await admin.firestore().collection("posts").doc(followedId).collection("usersPosts").get();
    postssnapshot.forEach((doc)=> {
        const postId = doc.id;
        const postData = doc.data();
        
        admin.firestore().collection("flows").doc(followingId).collection("userFlowPosts").doc(postId).set(postData);
    });

});


exports.unfollowEvent =  functions.firestore.document('followers/{followedId}/usersFollowers/{followingId}').onDelete(async (snapshot,context) => {
    const followedId = context.params.followedId;
    const followingId = context.params.followingId;


    const postssnapshot = await admin.firestore().collection("flows").doc(followingId).collection("usersFlowPosts").where("publisherId","==",followedId).get();
    postssnapshot.forEach((doc)=> {
        doc.ref.delete();
    });

});

exports.newPostEvent =  functions.firestore.document('posts/{followedId}/usersPosts/{postId}').onCreate(async(snapshot,context) => {
    const followedId = context.params.followedId;
    const postId = context.params.postId;
    const newPostData = snapshot.data();

    const followersSnapshot = await admin.firestore().collection("followers").doc(followedId).collection("usersFollowers").get();
    followersSnapshot.forEach((doc)=> {
        const followerId = doc.id;
        admin.firestore().collection("flows").doc(followerId).collection("usersFlowsPosts").doc(postId).set(newPostData);
    });

});


exports.updatePostEvent =  functions.firestore.document('posts/{followedId}/usersPosts/{postId}').onUpdate(async(snapshot,context) => {
    const followedId = context.params.followedId;
    const postId = context.params.postId;
    const updatedPostData = snapshot.after.data();

    const followersSnapshot = await admin.firestore().collection("followers").doc(followedId).collection("usersFollowers").get();
    followersSnapshot.forEach((doc)=> {
        const followerId = doc.id;
        admin.firestore().collection("flows").doc(followerId).collection("usersFlowsPosts").doc(postId).update(updatedPostData);
    });

});


exports.deletePostEvent =  functions.firestore.document('posts/{followedId}/usersPosts/{postId}').onDelete(async(snapshot,context) => {
    const followedId = context.params.followedId;
    const postId = context.params.postId;
  

    const followersSnapshot = await admin.firestore().collection("followers").doc(followedId).collection("usersFollowers").get();
    followersSnapshot.forEach((doc)=> {
        const followerId = doc.id;
        admin.firestore().collection("flows").doc(followerId).collection("usersFlowsPosts").doc(postId).delete();
    });

});
/*

exports.recordDeleted =  functions.firestore.document('deneme/{docId}').onDelete((snapshot,context) => {
    admin.firestore().collection("gunluk").add({
        "aciklama":"Deneme koleksiyonundan kayıt silindi"
    })
});

exports.recordUpdate =  functions.firestore.document('deneme/{docId}').onUpdate((change,context) => {
    admin.firestore().collection("gunluk").add({
        "aciklama":"Deneme koleksiyonuna kayıt güncellendi"
    })
});

exports.recordWritten =  functions.firestore.document('deneme/{docId}').onWrite((change,context) => {
    admin.firestore().collection("gunluk").add({
        "aciklama":"Deneme koleksiyonuna veri ekleme,silme,güncelleme işlemlerinden biri yapıldı"
    })
});
*/
