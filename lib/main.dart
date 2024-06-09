// lib/main.dart
import 'package:dish_list/Pages/ChangeEmail.dart';
import 'package:dish_list/Pages/Changepassword.dart';
import 'package:dish_list/Pages/ForgotPassword.dart';
import 'package:dish_list/Pages/Sign_in.dart';
import 'package:dish_list/Service/AuthProvider.dart';
import 'package:dish_list/Service/DishProvider.dart';
import 'package:dish_list/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dish_list/pages/homepage.dart';
import 'package:provider/provider.dart';

import 'Pages/List_Dishes.dart';
import 'Pages/ModifyProfile.dart';
import 'Pages/ProfilePage.dart';
import 'Pages/Register.dart';
import 'Service/F_Service.dart';
import 'firebase_options.dart'; // Adjust the import path as necessary

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options:  DefaultFirebaseOptions.currentPlatform); // Initialize Firebase
  runApp(MyApp()
  );}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Existing providers
        ChangeNotifierProvider(create: (context) => DishProvider()),
        ChangeNotifierProvider(create: (context) => UserProfileProvider()),
        // New provider for FournisseurService
        ChangeNotifierProvider(create: (context) => FournisseurService()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SignInScreen(), // Set HomePage as the home screen
        routes: {
          '/home': (context) => HomePage(),
          '/sign-in': (context) => SignInScreen(),
          '/register': (context) => RegisterPage(),
          '/dish-list': (context) => ListDishesPage(),
          '/profile': (context) => ProfilePage(),
          '/modify-profile': (context) => ModifyProfilePage(),
          '/change-password': (context) => ChangePasswordPage(),
          '/change-email': (context) => ChangeEmailPage(),
          '/forgot-password': (context) => ForgotPasswordPage(),
          // other routes...
        },
      ),
    );
  }
}


