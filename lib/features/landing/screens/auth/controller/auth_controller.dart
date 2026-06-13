import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';
import 'package:whatapp_clone/common/widgets/snackbar.dart';
import 'package:whatapp_clone/features/landing/screens/auth/repositories/auth_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatapp_clone/features/landing/screens/auth/screens/otp_screen.dart';
import 'package:whatapp_clone/features/landing/screens/auth/screens/user_info_screen.dart';
import 'package:whatapp_clone/models/user_model.dart';

final authControllerProvider = StateNotifierProvider<AuthController, bool>((
  ref,
) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepository, ref: ref);
});

final userDataAuthProvider = FutureProvider((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserData();
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository authRepository;
  final Ref ref;
  AuthController({required this.authRepository, required this.ref})
    : super(false);

  Future<UserModel?> getUserData() async {
    return await authRepository.getCurrentUserData();
  }

  Future<void> singInWithPhone(BuildContext context, String phoneNumber) async {
    state = true;
    return await authRepository.signInWithPhone(
      context,
      phoneNumber,
      onCodeSent: (verificationId) {
        state = false;
        Navigator.pushNamed(
          context,
          OtpScreen.routeName,
          arguments: verificationId,
        );
      },
      onVerificationCompleted: () {
        state = false;
      },
      onError: (error) {
        state = false;
        showSnackBar(context: context, content: error.toString());
      },
    );
  }

  Future<void> verifyOTP(
    BuildContext context,
    String verificationId,
    String userOTP,
  ) async {
    state = true;

    final success = await authRepository.verifyOTP(
      verificationId: verificationId,
      userOTP: userOTP,
      onError: (error) {
        showSnackBar(context: context, content: error);
      },
    );

    state = false;

    if (!context.mounted) return;
    if (success) {
      Navigator.pushNamed(context, UserInfoScreen.routeName);
    } else {
      showSnackBar(context: context, content: "Invalid OTP");
    }
  }

  Future<void> saveUserDataToFirebase(
    BuildContext context,
    String name,
    XFile? profilePic,
  ) async {
    state = true;
    await authRepository.saveUserDataToFirebase(
      name: name,
      profilePic: profilePic,
      ref: ref,
      context: context,
    );

    state = false;
  }

  Stream<UserModel> getUserById(String uid) {
    return authRepository.UserData(uid);
  }

  Future<void> setUserState(bool isOnline) {
    final done = authRepository.setUserState(isOnline);
    return done;
  }
}
