// Universidad de la Costa - Computación Móvil - Flutter Application 17:
import 'package:flutter/material.dart';
import 'package:flutter_application_17/components/my_back_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_17/database/firestore_database.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirestoreDatabase _database = FirestoreDatabase();

  // Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: StreamBuilder<Map<String, dynamic>?>(
              stream: _database.currentUserStream(),
              builder: (context, snapshot) {
                // Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                final userData = snapshot.data;

                // If there is no user data, show a placeholder or redirect to login
                if (userData == null) {
                  // If there is no user data, attempt to redirect to login page.
                  final String? currentRoute = ModalRoute.of(context)?.settings.name;
                  if (currentRoute != '/login-page') {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.pushReplacementNamed(context, '/login-page');
                    });
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text('Redirecting...'),
                    ],
                  );
                }

                final firstName = (userData['firstName'] ?? '').toString();
                final lastName = (userData['lastName'] ?? '').toString();
                final roleFromDB = (userData['role'] ?? 'volunteer').toString();

                // Normalize role values to 'Administrator' or 'User'
                final normalizedRole = _mapRoleToLabel(roleFromDB);

                // Greeting
                final username = '$firstName $lastName'.trim();

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Back and sign out buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        MyBackButton(),
                        IconButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushReplacementNamed(context, '/');
                          },
                          icon: const Icon(Icons.logout),
                        ),
                      ],
                    ),

                    // Icon
                    Icon(Icons.person, size: 80),

                    const SizedBox(height: 25),

                    // Greeting
                    Text('Welcome!',
                        style: TextStyle(fontWeight: FontWeight.w500)),

                    // Username
                    Text(username.isNotEmpty ? username : 'Guest'),

                    // User role
                    Text(normalizedRole),

                    const SizedBox(height: 25),

                    if (kDebugMode)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              final uid = FirebaseAuth.instance.currentUser?.uid;
                              if (uid != null) {
                                await _database.setUserRole(uid: uid, role: 'administrator');
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User role set to Administrator')));
                                setState(() {});
                              }
                            },
                            child: const Text('Make me admin (Dev)'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              final uid = FirebaseAuth.instance.currentUser?.uid;
                              if (uid != null) {
                                await _database.setUserRole(uid: uid, role: 'volunteer');
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User role reset to User')));
                                setState(() {});
                              }
                            },
                            child: const Text('Reset to User (Dev)'),
                          ),
                        ],
                      ),

                    // Admin cards
                    if (normalizedRole == 'Administrator')
                      Expanded(
                        child: ListView(
                          children: <Widget>[
                            // 01. Organize plots or crop zones
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(25.0),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      'Organize plots or crop zones',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Esse ullamco dolore consectetur et amet fugiat consectetur anim non aliquip.'
                                      ' Esse ullamco dolore consectetur et amet fugiat consectetur anim non aliquip.',
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/parcelas-page',
                                        );
                                      },
                                      child: const Text('Click here'),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // 02. Assign managers
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(25.0),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      'Assign managers',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Esse ullamco dolore consectetur et amet fugiat consectetur anim non aliquip.'
                                      ' Esse ullamco dolore consectetur et amet fugiat consectetur anim non aliquip.',
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/assign-managers-page',
                                        );
                                      },
                                      child: const Text('Click here'),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // 03. Plan weekly or monthly tasks
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(25.0),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      'Plan weekly or monthly tasks',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Esse ullamco dolore consectetur et amet fugiat consectetur anim non aliquip.'
                                      ' Esse ullamco dolore consectetur et amet fugiat consectetur anim non aliquip.',
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/add-tasks-page',
                                        );
                                      },
                                      child: const Text('Click here'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // User cards
                    if (normalizedRole == 'User')
                      Expanded(
                        child: ListView(
                          children: <Widget>[
                            // 01. Sign up as a volunteer
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(25.0),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      'Sign up as a volunteer',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Esse ullamco dolore consectetur et amet fugiat consectetur anim non aliquip.'
                                      ' Esse ullamco dolore consectetur et amet fugiat consectetur anim non aliquip.',
                                    ),
                                    ElevatedButton(
                                      onPressed: () {},
                                      child: const Text('Click here'),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // 02. Apply for specific tasks
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(25.0),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      'Apply for specific tasks',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Esse ullamco dolore consectetur et amet fugiat consectetur anim non aliquip.'
                                      ' Esse ullamco dolore consectetur et amet fugiat consectetur anim non aliquip.',
                                    ),
                                    ElevatedButton(
                                      onPressed: () {},
                                      child: const Text('Click here'),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // 03. Register your contribution to the garden
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(25.0),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      'Register your contribution to the garden',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Esse ullamco dolore consectetur et amet fugiat consectetur anim non aliquip.'
                                      ' Esse ullamco dolore consectetur et amet fugiat consectetur anim non aliquip.',
                                    ),
                                    ElevatedButton(
                                      onPressed: () {},
                                      child: const Text('Click here'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Helper: normalize stored role value to one of Administrator or User strings used in UI
  String _mapRoleToLabel(String role) {
    final r = role.toLowerCase();
    if (r == 'admin' || r.contains('admin') || r == 'administrator') {
      return 'Administrator';
    }
    // default to User for volunteer and unknown values
    return 'User';
  }
}
