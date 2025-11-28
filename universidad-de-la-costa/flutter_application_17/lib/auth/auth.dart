// Universidad de la Costa - Computación Móvil - Flutter Application 17:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_17/pages/home_page.dart';
import 'package:flutter_application_17/pages/profile_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Authenticated user -> ensure the router shows /profile-page
          if (snapshot.hasData) {
            final String? currentRoute = ModalRoute.of(context)?.settings.name;
            if (currentRoute != '/profile-page') {
              // Defer navigation until after build to avoid route exceptions.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacementNamed(context, '/profile-page');
              });
            }
            return const ProfilePage();
          }
          // Not authenticated -> show HomePage
          else {
            return const HomePage();
          }
        },
      ),
    );
  }
}