import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';
import 'package:whats_app_clone/common/widgtes/loader.dart';
import 'package:whats_app_clone/models/status_model.dart';

class StatusScreen extends StatefulWidget {
  static const String routeName = "/status-screen-story";
  final StatusModel status;
  const StatusScreen({super.key, required this.status});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  StoryController storyController = StoryController();

  List<StoryItem> storyItems = [];

  @override
  void initState() {
    super.initState();
    initStoryPage();
  }

  void initStoryPage() {
    for (int i = 0; i < widget.status.photoUrl.length; i++) {
      storyItems.add(StoryItem.pageImage(
          url: widget.status.photoUrl[i], controller: storyController));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: storyItems.isEmpty
          ? const LoadingPage()
          : StoryView(
              storyItems: storyItems,
              controller: storyController,
              onVerticalSwipeComplete: (direction) {
                if (direction == Direction.down) {
                  Navigator.pop(context);
                }
              },
            ),
    );
  }
}
