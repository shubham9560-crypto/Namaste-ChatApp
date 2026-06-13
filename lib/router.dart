import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatapp_clone/common/widgets/error.dart';
import 'package:whatapp_clone/features/landing/screens/auth/screens/login_screen.dart';
import 'package:whatapp_clone/features/landing/screens/auth/screens/otp_screen.dart';
import 'package:whatapp_clone/features/landing/screens/auth/screens/select_contacts_screen.dart';
import 'package:whatapp_clone/features/landing/screens/auth/screens/user_info_screen.dart';
import 'package:whatapp_clone/features/chat/screens/mobile_chat_screen.dart';
import 'package:whatapp_clone/features/status/screens/confirm_status.dart';
import 'package:whatapp_clone/features/status/screens/show_status_screen.dart';
import 'package:whatapp_clone/models/status_model.dart';

MaterialPageRoute<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case LoginScreen.routeName:
      return MaterialPageRoute(builder: (context) => LoginScreen());

    case OtpScreen.routeName:
      final verificationId = settings.arguments as String;
      return MaterialPageRoute(
        builder: (context) => OtpScreen(verificationId: verificationId),
      );

    case UserInfoScreen.routeName:
      return MaterialPageRoute(builder: (context) => UserInfoScreen());
    case SelectContactsScreen.routeName:
      return MaterialPageRoute(builder: (context) => SelectContactsScreen());

    case MobileChatScreen.routeName:
      final arguments = settings.arguments as Map<String, dynamic>;
      final name = arguments['name'];
      final uid = arguments['uid'];

      return MaterialPageRoute(
        builder: (context) => MobileChatScreen(name: name, uid: uid),
      );

    case ShowStatusScreen.routeName:
      final status = settings.arguments as StatusModel;
      return MaterialPageRoute(
        builder: (context) => ShowStatusScreen(statusModel: status),
      );

    case ConfirmStatus.routeName:
      final file = settings.arguments as XFile;

      return MaterialPageRoute(builder: (context) => ConfirmStatus(file: file));

    default:
      return MaterialPageRoute(
        builder: (context) => ErrorScreen(error: 'This page doesn\'t exist'),
      );
  }
}
