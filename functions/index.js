// functions/index.js
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

admin.initializeApp();

exports.deleteUserAccount = onCall(async (context) => {
  if (!context.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated.");
  }

  const uid = context.auth.uid;
  const db = admin.firestore();
  const bucket = admin.storage().bucket();

  const report = {
    usersDocDeleted: false,
    postsDeleted: 0,
    commentsDeleted: 0,
    likesDeleted: 0,
    postImagesDeleted: 0,
    profileImagesDeleted: 0,
    authDeleted: false,
    warnings: [],
  };

  try {
    console.log(`[deleteUserAccount] start uid=${uid}`);

    // 1) users/{uid}
    try {
      await db.collection("users").doc(uid).delete();
      report.usersDocDeleted = true;
    } catch (err) {
      report.warnings.push(`users doc delete failed: ${err.message}`);
      console.warn("users doc delete failed:", err);
    }

    // 2) posts(authorId == uid) + Storage(posts/{uid}/...) 전부
    try {
      const postsSnap = await db.collection("posts").where("authorId", "==", uid).get();
      report.postsDeleted = postsSnap.size;
      await Promise.all(postsSnap.docs.map((d) => d.ref.delete()));

      // 게시글 이미지 경로: posts/{uid}/ (postId 하위 폴더 없음)
      try {
        const [files] = await bucket.getFiles({ prefix: `posts/${uid}/` });
        if (files && files.length) {
          await Promise.all(files.map((f) => f.delete({ ignoreNotFound: true })));
          report.postImagesDeleted = files.length;
        }
      } catch (e) {
        report.warnings.push(`post images delete failed: ${e.message}`);
        console.warn("post images delete failed:", e);
      }
    } catch (err) {
      report.warnings.push(`posts delete block failed: ${err.message}`);
      console.warn("posts block failed:", err);
    }

    // 3) comments(userId == uid)
    try {
      const commentsSnap = await db.collection("comments").where("userId", "==", uid).get();
      report.commentsDeleted = commentsSnap.size;
      await Promise.all(commentsSnap.docs.map((d) => d.ref.delete()));
    } catch (err) {
      report.warnings.push(`comments delete failed: ${err.message}`);
      console.warn("comments delete failed:", err);
    }

    // 4) likes(userId == uid)
    try {
      const likesSnap = await db.collection("likes").where("userId", "==", uid).get();
      report.likesDeleted = likesSnap.size;
      await Promise.all(likesSnap.docs.map((d) => d.ref.delete()));
    } catch (err) {
      report.warnings.push(`likes delete failed: ${err.message}`);
      console.warn("likes delete failed:", err);
    }

    // 5) 프로필 이미지(user_profiles/{uid} 전체)
    try {
      const [files] = await bucket.getFiles({ prefix: `user_profiles/${uid}` });
      if (files && files.length) {
        await Promise.all(files.map((f) => f.delete({ ignoreNotFound: true })));
        report.profileImagesDeleted = files.length;
      }
    } catch (err) {
      report.warnings.push(`profile images delete failed: ${err.message}`);
      console.warn("profile images delete failed:", err);
    }

    // 6) Firebase Auth 계정 삭제 (항상 마지막)
    try {
      await admin.auth().deleteUser(uid);
      report.authDeleted = true;
    } catch (err) {
      console.error("auth delete failed:", err);
      throw new HttpsError(
        "internal",
        "회원 탈퇴 실패(계정 삭제 단계)",
        { step: "authDelete", message: err.message, report },
      );
    }

    console.log("[deleteUserAccount] done", report);
    return { success: true, message: "회원 탈퇴가 완료되었습니다.", report };
  } catch (err) {
    console.error("[deleteUserAccount] failed:", err);
    throw new HttpsError(
      "internal",
      "회원 탈퇴 실패",
      { message: err?.message ?? String(err), report },
    );
  }
});
