import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatapp_clone/colors.dart';
import 'package:whatapp_clone/common/widgets/custom_button.dart';
import 'package:country_picker/country_picker.dart';
import 'package:whatapp_clone/common/widgets/loader.dart';
import 'package:whatapp_clone/features/landing/screens/auth/controller/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = '/login_screen';

  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final phoneController = TextEditingController();

  Country? selectedCountry;

  @override
  void dispose() {
    super.dispose();
    phoneController.dispose();
  }

  void countryPicker() {
    showCountryPicker(
      context: context,

      onSelect: (Country country) {
        setState(() {
          selectedCountry = country;
        });
      },
    );
  }

  Future<void> sendPhoneNumber() async {
    String phoneNumber =
        '+${selectedCountry!.phoneCode}${phoneController.text.trim()}';

    debugPrint(phoneNumber);

    if (selectedCountry != null && phoneNumber.isNotEmpty) {
      ref
          .watch(authControllerProvider.notifier)
          .singInWithPhone(context, phoneNumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        title: const Text("Enter Your Phone Number"),
      ),

      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("What'sApp will need to verify your phone number"),
            const SizedBox(height: 10),
            TextButton(
              onPressed: countryPicker,
              child: const Text("Pick country"),
            ),

            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                selectedCountry != null
                    ? Text(
                        '+${selectedCountry!.phoneCode}',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      )
                    : Text("---"),

                const SizedBox(width: 10),
                SizedBox(
                  width: size.width * 0.6,
                  child: TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(hintText: "Phone Number"),
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.1),

            isLoading
                ? const Loader()
                : SizedBox(
                    width: 100,
                    child: CustomButton(
                      text: "Next",
                      onPressed: sendPhoneNumber,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
