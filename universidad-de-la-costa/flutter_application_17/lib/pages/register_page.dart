// Universidad de la Costa - Computación Móvil - Flutter Application 17:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_17/database/firestore_database.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Text field controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController zoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  List<String> selectedDays = [];
  final List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  bool isLoading = false;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    zoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Sign-Up method
  Future<void> signUp() async {
    if (firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        zoneController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        confirmPasswordController.text.trim().isEmpty) {
      showErrorDialog('Please fill in all fields');
      return;
    }

    if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      showErrorDialog('Passwords do not match');
      return;
    }

    if (selectedDays.isEmpty) {
      showErrorDialog('Please select at least one available day');
      return;
    }

    setState(() => isLoading = true);

    try {
      // Create user in Firebase Auth
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Create document in Firestore
      FirestoreDatabase database = FirestoreDatabase();
      await database.createUserDocument(
        uid: userCredential.user!.uid,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        zone: zoneController.text.trim(),
        availableDays: selectedDays,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful!'),
            backgroundColor: Colors.green,
          ),
        );
        // Redirect to app root (AuthPage) - AuthPage will render ProfilePage
        // for the authenticated user.
        Navigator.pushReplacementNamed(context, '/');
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Error creating account';
      if (e.code == 'email-already-in-use') {
        message = 'An account with this email already exists';
      } else if (e.code == 'weak-password') {
        message = 'Password must be at least 6 characters';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is invalid';
      }
      showErrorDialog(message);
    } catch (e) {
      showErrorDialog('Unexpected error: $e');
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

  // Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Logo
                  const Icon(Icons.person_add, size: 80, color: Colors.green),

                  const SizedBox(height: 25),

                  // App name
                  const Text(
                    'User Registration',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // First name textfield
                  TextFormField(
                    controller: firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),

                  // Last name textfield
                  TextFormField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),

                  // Email textfield
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),

                  // Phone textfield
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.phone),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),

                  // Zone textfield
                  TextFormField(
                    controller: zoneController,
                    decoration: InputDecoration(
                      labelText: 'Neighborhood',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.location_on),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your neighborhood';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),

                  // Available days
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Available days:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: daysOfWeek.map((day) {
                            final isSelected = selectedDays.contains(day);
                            return FilterChip(
                              label: Text(day),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    selectedDays.add(day);
                                  } else {
                                    selectedDays.remove(day);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        if (selectedDays.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              'Please select at least one day',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Password textfield
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Minimum 6 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),

                  // Repeat password textfield
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 25),

                  // Sign Up button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : signUp,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Sign up',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text("Already have an account?"),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/login-page');
                        },
                        child: const Text(
                          ' Log in',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}