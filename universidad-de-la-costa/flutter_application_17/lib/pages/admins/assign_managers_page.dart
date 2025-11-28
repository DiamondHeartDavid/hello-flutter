// Universidad de la Costa - Computación Móvil - Flutter Application 17:
import 'package:flutter/material.dart';
import 'package:flutter_application_17/components/my_back_button.dart';
import 'package:flutter_application_17/database/firestore_database.dart';

class AssignManagersPage extends StatefulWidget {
  const AssignManagersPage({super.key});

  @override
  State<AssignManagersPage> createState() => _AssignManagersPageState();
}

class _AssignManagersPageState extends State<AssignManagersPage> {
  final FirestoreDatabase _database = FirestoreDatabase();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? selectedUserId;
  String? selectedParcelaId;
  Map<String, dynamic>? selectedParcelaData;
  bool isLoading = false;

  Future<void> assignManager() async {
    if (selectedUserId == null || selectedParcelaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a user and a plot')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Update the plot with the assigned user
      await _database.updateParcela(
        parcelaId: selectedParcelaId!,
        name: selectedParcelaData!['name'],
        size: selectedParcelaData!['size'],
        cropType: selectedParcelaData!['cropType'],
        status: selectedParcelaData!['status'],
        assignedTo: selectedUserId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Manager assigned successfully')),
        );
        clearSelection();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void clearSelection() {
    setState(() {
      selectedUserId = null;
      selectedParcelaId = null;
      selectedParcelaData = null;
    });
  }

  Future<void> loadParcelaDetails(String parcelaId) async {
    try {
      final parcela = await _database.getParcelaById(parcelaId);
      setState(() {
        selectedParcelaData = parcela;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading plot: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              // Back button
              Row(
                children: [
                  const MyBackButton(),
                  const SizedBox(width: 10),
                  Text(
                    'Assign Managers',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Formulario
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Select user',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Users selector
                                StreamBuilder<List<Map<String, dynamic>>>(
                                  stream: _database.getAllUsers(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }

                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    }

                                    final users = snapshot.data ?? [];

                                    if (users.isEmpty) {
                                      return const Text(
                                        'No users available',
                                      );
                                    }

                                    return DropdownButtonFormField<String>(
                                      value: selectedUserId,
                                      decoration: const InputDecoration(
                                        labelText: 'Assigned user',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: users.map((user) {
                                        return DropdownMenuItem<String>(
                                          value: user['id'],
                                          child: Text(
                                            '${user['firstName']} ${user['lastName']}',
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() => selectedUserId = value);
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Select plot',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Plot selector
                                StreamBuilder<List<Map<String, dynamic>>>(
                                  stream: _database.getAllParcelas(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }

                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    }

                                    final parcelas = snapshot.data ?? [];

                                    if (parcelas.isEmpty) {
                                      return const Text(
                                        'No plots available',
                                      );
                                    }

                                    return DropdownButtonFormField<String>(
                                      value: selectedParcelaId,
                                      decoration: const InputDecoration(
                                        labelText: 'Plot',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: parcelas.map((parcela) {
                                        return DropdownMenuItem<String>(
                                          value: parcela['id'],
                                          child: Text(parcela['name'] ?? ''),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedParcelaId = value;
                                          if (value != null) {
                                            loadParcelaDetails(value);
                                          }
                                        });
                                      },
                                    );
                                  },
                                ),

                                // Show selected plot details
                                if (selectedParcelaData != null) ...[
                                  const SizedBox(height: 16),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Plot details:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildDetailRow(
                                    'Status:',
                                    selectedParcelaData!['status'] ?? 'N/A',
                                  ),
                                  _buildDetailRow(
                                    'Crop type:',
                                    selectedParcelaData!['cropType'] ?? 'N/A',
                                  ),
                                  _buildDetailRow(
                                    'Size:',
                                    selectedParcelaData!['size'] ?? 'N/A',
                                  ),
                                  if (selectedParcelaData!['assignedTo'] != null)
                                    _buildDetailRow(
                                      'Current manager:',
                                      'Assigned',
                                      isWarning: true,
                                    ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Assign button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : assignManager,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                  'Assign Manager',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isWarning ? Colors.orange : null,
                fontWeight: isWarning ? FontWeight.bold : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}