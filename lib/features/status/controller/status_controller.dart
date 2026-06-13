import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatapp_clone/features/landing/screens/auth/controller/auth_controller.dart';
import 'package:whatapp_clone/features/status/respository/status_repository.dart';
import 'package:whatapp_clone/models/status_model.dart';

final statusControllerProvider = Provider((ref) {
  final statusRepository = ref.read(statusRepositoryProvider);

  return StatusController(statusRepository: statusRepository, ref: ref);
});

class StatusController {
  final StatusRepository statusRepository;
  final Ref ref;

  StatusController({required this.statusRepository, required this.ref});

  Future<void> addStatus(BuildContext context, XFile file) async {
    final user = await ref.read(userDataAuthProvider.future);
    await statusRepository.uploadStatus(
      context: context,
      userName: user!.name,
      profilePic: user.profilePic,
      phoneNumber: user.phoneNumber,
      statusImage: file,
    );
  }

  Future<List<StatusModel>> getStatus(BuildContext context) async {
    List<StatusModel> statuses = await statusRepository.getStatus(context);
    return statuses;
  }
}
