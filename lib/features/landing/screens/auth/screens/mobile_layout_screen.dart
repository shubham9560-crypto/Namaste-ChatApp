import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatapp_clone/colors.dart';
import 'package:whatapp_clone/common/utils/utils.dart';
import 'package:whatapp_clone/contact_list.dart';
import 'package:whatapp_clone/features/landing/screens/auth/controller/auth_controller.dart';
import 'package:whatapp_clone/features/landing/screens/auth/screens/select_contacts_screen.dart';
import 'package:whatapp_clone/features/meeting/screens/meeting_screen.dart';
import 'package:whatapp_clone/features/status/screens/confirm_status.dart';
import 'package:whatapp_clone/features/status/screens/status_screen.dart';

class MobileLayoutScreen extends ConsumerStatefulWidget {
  const MobileLayoutScreen({super.key});

  @override
  ConsumerState<MobileLayoutScreen> createState() => _MobileLayoutScreenState();
}

class _MobileLayoutScreenState extends ConsumerState<MobileLayoutScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        ref.read(authControllerProvider.notifier).setUserState(true);
        break;

      case AppLifecycleState.inactive:
        ref.read(authControllerProvider.notifier).setUserState(false);
        break;

      case AppLifecycleState.detached:
        ref.read(authControllerProvider.notifier).setUserState(false);
        break;

      case AppLifecycleState.paused:
        ref.read(authControllerProvider.notifier).setUserState(false);
        break;

      case AppLifecycleState.hidden:
        ref.read(authControllerProvider.notifier).setUserState(false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: appBarColor,
          centerTitle: false,
          title: const Text(
            "Namaste",
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.grey),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onPressed: () {},
            ),
          ],

          bottom: TabBar(
            controller: tabController,
            indicatorColor: tabColor,
            indicatorWeight: 4,
            labelColor: tabColor,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: "CHATS"),
              Tab(text: "STATUS"),
              Tab(text: "CALLS"),
            ],
          ),
        ),

        body: TabBarView(
          controller: tabController,
          children: [ContactsList(), StatusScreen(), MeetingScreen()],
        ),

        floatingActionButton: AnimatedBuilder(
          animation: tabController,
          builder: (context, _) {
            return FloatingActionButton(
              onPressed: () async {
                if (tabController.index == 0) {
                  Navigator.pushNamed(context, SelectContactsScreen.routeName);
                } else if (tabController.index == 1) {
                  XFile? pickedImage = await pickImageFromGallery(context);

                  if (pickedImage != null) {
                    Navigator.pushNamed(
                      context,
                      ConfirmStatus.routeName,
                      arguments: pickedImage,
                    );
                  }
                }
              },
              backgroundColor: tabColor,

              child: Icon(
                tabController.index == 0 ? Icons.comment : Icons.add,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }
}
