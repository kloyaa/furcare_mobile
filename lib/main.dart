import 'package:flutter/material.dart';
import 'package:furcare_app/providers/authentication.dart';
import 'package:furcare_app/providers/fees.dart';
import 'package:furcare_app/providers/user.dart';
import 'package:furcare_app/screens/auth/registration/customer_registration.dart';
import 'package:furcare_app/screens/branch/branch.dart';
import 'package:furcare_app/screens/customer/create_profile/create_pet_profile.dart';
import 'package:furcare_app/screens/customer/create_profile/create_profile_1.dart';
import 'package:furcare_app/screens/customer/create_profile/create_profile_2.dart';
import 'package:furcare_app/screens/customer/customer_main.dart';
import 'package:furcare_app/screens/customer/edit/edit_owner_profile.dart';
import 'package:furcare_app/screens/customer/edit/edit_profile_step_1.dart';
import 'package:provider/provider.dart';
import 'package:furcare_app/screens/auth/customer_login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    precacheImage(const AssetImage('assets/success.gif'), context);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthTokenProvider()),
        ChangeNotifierProvider(create: (_) => RegistrationProvider()),
        ChangeNotifierProvider(create: (_) => FeesProvider()),
        ChangeNotifierProvider(create: (_) => ClientProvider()),
      ],
      child: MaterialApp(
        title: 'Furcare',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          // '/': (context) => ProfileSetupAnimation(redirectPath: '/'),
          // '/': (context) => SuccessScreen(redirectPath: '/'),
          '/': (context) => const CustomerLogin(),
          // '/': (context) => const StaffLogin(),
          '/branches': (context) => const BranchesList(),
          '/c/main': (context) => const CustomerMain(),
          '/c/register': (context) => const CustomerRegister(),
          '/c/edit/profile/1': (context) => const EditProfileStep1(),
          '/c/create/profile/1': (context) => const CreateProfileStep1(),
          '/c/create/profile/2': (context) => const CreateProfileStep2(),
          '/c/edit/profile/owner': (context) => const EditOwner(),
          '/c/create/profile/pet': (context) => const CreatePet(),
        },
      ),
    );
  }
}
