// Universidad de la Costa - Computación Móvil - Flutter Application 17:
import 'package:flutter/material.dart';
import 'package:flutter_application_17/components/my_back_button.dart';
import 'package:flutter_application_17/database/firestore_database.dart';

class ParcelasPage extends StatefulWidget {
  const ParcelasPage({super.key});

  @override
  State<ParcelasPage> createState() => _ParcelasPageState();
}

class _ParcelasPageState extends State<ParcelasPage> {
  final FirestoreDatabase _database = FirestoreDatabase();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Text field controllers
  final TextEditingController parcelaNameController = TextEditingController();
  final TextEditingController parcelaSizeController = TextEditingController();
  final TextEditingController parcelaTypeController = TextEditingController();
  final TextEditingController parcelaStatusController = TextEditingController();

  bool isLoading = false;
  String? editingParcelaId;

  // Predefined status list
  final List<String> statusOptions = ['Active', 'Preparing', 'Inactive', 'Harvest'];
  String selectedStatus = 'Active';

  @override
  void dispose() {
    parcelaNameController.dispose();
    parcelaSizeController.dispose();
    parcelaTypeController.dispose();
    parcelaStatusController.dispose();
    super.dispose();
  }

  Future<void> saveParcela() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      if (editingParcelaId == null) {
        // Create new plot
        await _database.createParcela(
          name: parcelaNameController.text.trim(),
          size: parcelaSizeController.text.trim(),
          cropType: parcelaTypeController.text.trim(),
          status: selectedStatus,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Plot created successfully')),
          );
        }
      } else {
        // Update existing plot
          // Update existing plot
        await _database.updateParcela(
          parcelaId: editingParcelaId!,
          name: parcelaNameController.text.trim(),
          size: parcelaSizeController.text.trim(),
          cropType: parcelaTypeController.text.trim(),
          status: selectedStatus,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Plot updated successfully')),
          );
        }
      }

      clearForm();
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

  void clearForm() {
    parcelaNameController.clear();
    parcelaSizeController.clear();
    parcelaTypeController.clear();
    selectedStatus = 'Active';
    editingParcelaId = null;
    setState(() {});
  }

  void editParcela(Map<String, dynamic> parcela) {
    editingParcelaId = parcela['id'];
    parcelaNameController.text = parcela['name'] ?? '';
    parcelaSizeController.text = parcela['size'] ?? '';
    parcelaTypeController.text = parcela['cropType'] ?? '';
    selectedStatus = parcela['status'] ?? 'Active';
    setState(() {});
  }

  Future<void> deleteParcela(String parcelaId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm delete'),
        content: const Text('Are you sure you want to delete this plot?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _database.deleteParcela(parcelaId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Plot deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting: $e')),
          );
        }
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
                    'Plot Management',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Form
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          editingParcelaId == null ? 'Create new plot' : 'Edit plot',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Plot name
                        TextFormField(
                          controller: parcelaNameController,
                          decoration: const InputDecoration(
                            labelText: 'Plot name',
                            hintText: 'e.g., Plot A',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // Size
                        TextFormField(
                          controller: parcelaSizeController,
                          decoration: const InputDecoration(
                            labelText: 'Size',
                            hintText: 'e.g., 100 m²',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the size';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // Crop type
                        TextFormField(
                          controller: parcelaTypeController,
                          decoration: const InputDecoration(
                            labelText: 'Crop type',
                            hintText: 'e.g., Tomatoes, Lettuce',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the crop type';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // Status
                        DropdownButtonFormField<String>(
                          value: selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                          ),
                          items: statusOptions.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => selectedStatus = value);
                            }
                          },
                        ),

                        const SizedBox(height: 16),

                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (editingParcelaId != null)
                              TextButton(
                                onPressed: clearForm,
                                child: const Text('Cancel'),
                              ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: isLoading ? null : saveParcela,
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(editingParcelaId == null ? 'Create' : 'Update'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Plots list
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _database.getAllParcelas(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    final parcelas = snapshot.data ?? [];

                    if (parcelas.isEmpty) {
                      return const Center(
                        child: Text('No plots registered'),
                      );
                    }

                    return ListView.builder(
                      itemCount: parcelas.length,
                      itemBuilder: (context, index) {
                        final parcela = parcelas[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(
                              parcela['name'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Size: ${parcela['size']}'),
                                Text('Crop: ${parcela['cropType']}'),
                                Text('Status: ${parcela['status']}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => editParcela(parcela),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => deleteParcela(parcela['id']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}