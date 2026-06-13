import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatapp_clone/colors.dart';
import 'package:whatapp_clone/common/widgets/loader.dart';
import 'package:whatapp_clone/common/widgets/snackbar.dart';
import 'package:whatapp_clone/features/status/controller/status_controller.dart';

class ConfirmStatus extends ConsumerStatefulWidget {
  static const String routeName = '/confirm-status-screen';
  final XFile file;

  const ConfirmStatus({super.key, required this.file});

  @override
  ConsumerState<ConfirmStatus> createState() => _ConfirmStatusState();
}

class _ConfirmStatusState extends ConsumerState<ConfirmStatus> {
  bool _isUploading = false;

  Future<void> addStatus() async {
    showSnackBar(context: context, content: "Uploading");

    setState(() => _isUploading = true);

    await ref.read(statusControllerProvider).addStatus(context, widget.file);

    if (!mounted) return;

    setState(() => _isUploading = false);

    showSnackBar(context: context, content: "Uploaded");
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: Stack(
            children: [
              Center(child: Image.file(File(widget.file.path))),
              if (_isUploading) const Center(child: Loader()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addStatus,
        backgroundColor: tabColor,
        child: const Icon(Icons.done, color: Colors.white),
      ),
    );
  }
}
