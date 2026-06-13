import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatapp_clone/colors.dart';
import 'package:whatapp_clone/common/widgets/error.dart';
import 'package:whatapp_clone/common/widgets/loader.dart';
import 'package:whatapp_clone/features/landing/screens/auth/controller/auth_controller.dart';
import 'package:whatapp_clone/features/landing/screens/auth/screens/mobile_layout_screen.dart';
import 'package:whatapp_clone/features/landing/screens/landingpage.dart';
import 'package:whatapp_clone/firebase_options.dart';
import 'package:whatapp_clone/router.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAppCheck.instance.activate(
    providerAndroid: const AndroidPlayIntegrityProvider(),
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor,

        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: appBarColor,
        ),
      ),
      onGenerateRoute: (settings) => generateRoute(settings),
      home: ref
          .watch(userDataAuthProvider)
          .when(
            data: (user) {
              if (user == null) return const Landingpage();
              debugPrint(user.name);
              return const MobileLayoutScreen();
            },
            error: (err, trace) {
              // return Scaffold();
              debugPrint("USER PROVIDER ERROR: $err");
              debugPrint(trace.toString());

              return ErrorScreen(error: err.toString());
            },
            loading: () {
              return const Loader();
            },
          ),
    );
  }
}
