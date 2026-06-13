import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatapp_clone/common/repository/common_firebase_storage_repository.dart';
import 'package:whatapp_clone/common/widgets/snackbar.dart';
import 'package:whatapp_clone/features/landing/screens/auth/screens/mobile_layout_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod/riverpod.dart';
import 'package:whatapp_clone/models/user_model.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  ),
);

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRepository({required this.auth, required this.firestore});

  Future<void> setUserState(bool isOnline) async {
    // debugPrint("going online$isOnline");
    if (auth.currentUser == null) return;
    await firestore.collection("users").doc(auth.currentUser!.uid).update({
      'isOnline': isOnline,
    });
  }

  Future<UserModel?> getCurrentUserData() async {
    if (auth.currentUser == null) {
      return null;
    }
    UserModel? user;

    var userData = await firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
        .get();

    if (userData.data() != null) {
      user = UserModel.fromMap(userData.data()!);
    }
    return user;
  }

  Future<void> signInWithPhone(
    BuildContext context,
    String phoneNumber, {
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
    required VoidCallback onVerificationCompleted,
  }) async {
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: ((PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential);
        onVerificationCompleted();
      }),
      verificationFailed: (FirebaseAuthException err) {
        onError(err.message ?? 'Verfication failed');
      },
      codeSent: ((String verificationId, int? token) async {
        onCodeSent(verificationId);
      }),
      codeAutoRetrievalTimeout: (String verifcationId) {},
    );
  }

  Future<bool> verifyOTP({
    required String verificationId,
    required String userOTP,

    required void Function(String error) onError,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: userOTP,
      );

      await auth.signInWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      onError(e.toString());
      return false;
    }
  }

  Future<void> saveUserDataToFirebase({
    required String name,
    required XFile? profilePic,
    required Ref ref,
    required BuildContext context,
  }) async {
    try {
      String uid = auth.currentUser!.uid;
      String photoUrl = 'https://cdn-icons-png.flaticon.com/512/219/219988.png';

      if (profilePic != null) {
        photoUrl = await ref
            .read(commonFirebaseStorageRepository)
            .storeFileToFirebase('profilePic/$uid', profilePic);

        print(profilePic);
      }

      var user = UserModel(
        name: name,
        profilePic: photoUrl,
        uid: uid,
        isOnline: true,
        phoneNumber: auth.currentUser!.phoneNumber.toString(),
        groupId: [],
      );

      await firestore.collection('users').doc(uid).set(user.toMap());
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MobileLayoutScreen()),
        (route) => false,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Stream<UserModel> UserData(String uid) {
    return firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((event) => UserModel.fromMap(event.data()!));
  }
}
