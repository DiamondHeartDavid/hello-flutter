// Universidad de la Costa - Computación Móvil - Flutter Application 17:
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_17/database/firestore_database.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Text field controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  final FirestoreDatabase _database = FirestoreDatabase();

  // Login method
  Future<void> login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      showErrorDialog('Please fill in all fields');
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (mounted) {
        // After successful login, navigate to the app root (AuthPage) so the
        // auth state can decide whether to show ProfilePage or HomePage.
        Navigator.pushReplacementNamed(context, '/');
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Login error';
      if (e.code == 'user-not-found') {
        message = 'No account found with this email';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password';
      }
      showErrorDialog(message);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _createAdminAccount(String email, String password, String firstName, String lastName) async {
    if (email.isEmpty || password.isEmpty) {
      showErrorDialog('Email and password are required');
      return;
    }
    setState(() => isLoading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      // Create user document and set role to administrator
      await _database.createUserDocument(
        uid: userCredential.user!.uid,
        firstName: firstName.isEmpty ? 'Admin' : firstName,
        lastName: lastName.isEmpty ? 'User' : lastName,
        email: email,
        phone: '',
        zone: '',
        availableDays: [],
        role: 'administrator',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Admin account created and signed in')));
        Navigator.pushReplacementNamed(context, '/');
      }
    } on FirebaseAuthException catch (e) {
      showErrorDialog('Error creating admin: ${e.message}');
    } catch (e) {
      showErrorDialog('Unexpected error: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  

  /// Quick login flow that signs in as `admin@example.com` / `admin`. If the
  /// account does not exist, it will be created and promoted to administrator.
  Future<void> _quickAdminLogin() async {
    const quickEmail = 'admin@example.com';
    const quickPassword = 'admin';

    setState(() => isLoading = true);
    try {
      // Determine sign-in methods available for the email to provide helpful flows
      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(quickEmail);
      if (methods.isEmpty) {
        // No account -> create it using email/password
        await _createAdminAccount(quickEmail, quickPassword, 'Admin', 'User');
        return;
      }

      // If the account supports password sign-in, try signing in with the quick creds
      if (methods.contains('password')) {
        try {
          final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: quickEmail, password: quickPassword);
          final uid = credential.user?.uid;
          if (uid != null) {
            await _database.setUserRole(uid: uid, role: 'administrator');
          }
          if (mounted) Navigator.pushReplacementNamed(context, '/');
          return;
        } on FirebaseAuthException catch (signInErr) {
          if (signInErr.code == 'wrong-password') {
            showErrorDialog('Quick sign-in failed: the account exists but the password is different. Please use the correct password or re-create the account.');
            return;
          }
          if (signInErr.code == 'user-disabled') {
            showErrorDialog('Quick sign-in failed: this account has been disabled.');
            return;
          }
          // Other errors: allow falling through to message below
          showErrorDialog('Quick sign-in failed: ${signInErr.message}');
          return;
        }
      }

      // The account exists but doesn't support password sign-in (e.g., Google provider)
      showErrorDialog('Quick sign-in failed: an account with this email exists but cannot be used with email/password (provider: ${methods.join(', ')}).');
    } on FirebaseAuthException catch (e) {
      showErrorDialog('Quick sign-in failed: ${e.message}');
    } catch (e) {
      showErrorDialog('Unexpected error: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Logo
              Icon(Icons.person, size: 80),

              const SizedBox(height: 25),

              // App name
              Text('App name here'),

              const SizedBox(height: 25),

              // Email textfield
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'Type your email...',
                ),
                obscureText: false,
              ),

              const SizedBox(height: 10),

              // Password textfield
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'Type your password...',
                ),
                obscureText: true,
              ),

              const SizedBox(height: 25),

              // Sign in button
              ElevatedButton(onPressed: login, child: const Text('Login')),

              const SizedBox(height: 25),

              // Quick Admin Login button (visible in normal mode for convenience)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _quickAdminLogin,
                    child: const Text('Quick Admin Login'),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Don't have an account?"),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/register-page');
                    },
                    child: Text(
                      ' Register here',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
