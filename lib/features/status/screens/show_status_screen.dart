// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';

import 'package:whatapp_clone/common/widgets/loader.dart';
import 'package:whatapp_clone/models/status_model.dart';

// ignore: use_key_in_widget_constructors
class ShowStatusScreen extends StatefulWidget {
  static const String routeName = '/show-status-screen';
  final StatusModel statusModel;
  const ShowStatusScreen({super.key, required this.statusModel});
  @override
  State<ShowStatusScreen> createState() => _ShowStatusScreenState();
}

class _ShowStatusScreenState extends State<ShowStatusScreen> {
  final StoryController _storyController = StoryController();
  List<StoryItem> storyItems = [];

  @override
  void initState() {
    super.initState();
    initStoryPageItems();
  }

  void initStoryPageItems() {
    for (int i = 0; i < widget.statusModel.photoUrl.length; i++) {
      storyItems.add(
        StoryItem.pageImage(
          url: widget.statusModel.photoUrl[i],
          controller: _storyController,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: storyItems.isEmpty
          ? const Loader()
          : StoryView(
              storyItems: storyItems,
              controller: _storyController,
              onStoryShow: (storyItem, index) {},
              onComplete: () {
                Navigator.pop(context);
              },
              onVerticalSwipeComplete: (direction) {
                if (direction == Direction.down) {
                  Navigator.pop(context);
                }
              },
            ),
    );
  }
}
