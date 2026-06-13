import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:whatapp_clone/common/widgets/snackbar.dart';

Future<XFile?> pickImageFromGallery(BuildContext context) async {
  XFile? image;

  try {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      image = pickedImage;

      return image;
    }
  } catch (e) {
    showSnackBar(context: context, content: e.toString());
  }
  return null;
}

Future<XFile?> pickVideoFromGallery(BuildContext context) async {
  XFile? video;

  try {
    final pickedVideo = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
    );
    if (pickedVideo != null) {
      video = pickedVideo;

      return video;
    }
  } catch (e) {
    showSnackBar(context: context, content: e.toString());
  }
  return null;
}

void showAllNumbers() async {
  List<Contact> contacts = [];
  if (await FlutterContacts.permissions.request(PermissionType.read) ==
      PermissionStatus.granted) {
    contacts = await FlutterContacts.getAll();
  }

  for (var contact in contacts) {
    if (contact.phones.isNotEmpty) {
      final normalizedPhone = PhoneNumber.parse(
        contact.phones[0].number,
        destinationCountry: IsoCode.IN,
      );
      debugPrint(
        "Before ${contact.phones[0].number} After ${normalizedPhone.international.toString()}",
      );
    }
  }
}

//lUwWHzNaaKA8WJAj2iEGXPaD2EjmXaIq
// Future<GiphyGif?> pickGIF(BuildContext context) async {
//   try {
//     final gif = await Giphy.getGif(
//       context: context,
//       apiKey: 'lUwWHzNaaKA8WJAj2iEGXPaD2EjmXaIq',
//       showAttribution: false,
//       showPreview: false,
//     );
//     return gif; // can be null if user cancels
//   } catch (e) {
//     if (context.mounted) {
//       showSnackBar(context: context, content: 'Failed to pick GIF');
//     }
//     return null;
//   }
// }

// void formatDate
String formateDate(DateTime time) {
  return DateFormat('h:mm a').format(time);
}
