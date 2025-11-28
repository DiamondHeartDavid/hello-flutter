// Universidad de la Costa - Computación Móvil - Flutter Application 17:
import 'package:flutter/material.dart';
import 'package:flutter_application_17/components/my_back_button.dart';
import 'package:flutter_application_17/database/firestore_database.dart';

class AddTasksPage extends StatefulWidget {
  const AddTasksPage({super.key});

  @override
  State<AddTasksPage> createState() => _AddTasksPageState();
}

class _AddTasksPageState extends State<AddTasksPage> {
  final FirestoreDatabase _database = FirestoreDatabase();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Text field controllers
  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController taskDescriptionController = TextEditingController();

  String? selectedParcelaId;
  String? selectedTaskType;
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;

  // Predefined task types
  final List<String> taskTypes = [
    'Irrigation',
    'Planting',
    'Harvest',
    'Fertilization',
    'Pest control',
    'Pruning',
    'Cleaning',
    'Maintenance',
    'Other',
  ];

  @override
  void dispose() {
    taskNameController.dispose();
    taskDescriptionController.dispose();
    super.dispose();
  }

  Future<void> createTask() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedParcelaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a plot')),
      );
      return;
    }

    if (selectedTaskType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a task type')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await _database.createTask(
        title: taskNameController.text.trim(),
        description: taskDescriptionController.text.trim(),
        type: selectedTaskType!,
        parcelaId: selectedParcelaId!,
        date: selectedDate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task created successfully')),
          );
        clearForm();
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

  void clearForm() {
    taskNameController.clear();
    taskDescriptionController.clear();
    selectedParcelaId = null;
    selectedTaskType = null;
    selectedDate = DateTime.now();
    setState(() {});
  }

  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> deleteTask(String taskId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm delete'),
        content: const Text('Are you sure you want to delete this task?'),
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
        await _database.deleteTask(taskId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task deleted')),
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

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
                  Expanded(
                    child: Text(
                        'Plan Tasks',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Formulario
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                    'New Task',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Task name
                                TextFormField(
                                  controller: taskNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Task name',
                                      hintText: 'e.g., Water tomatoes',
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

                                // Descripción
                                TextFormField(
                                  controller: taskDescriptionController,
                                  maxLines: 3,
                                  decoration: const InputDecoration(
                                    labelText: 'Description',
                                    hintText: 'Describe the task...',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a description';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 12),

                                // Task type
                                DropdownButtonFormField<String>(
                                  value: selectedTaskType,
                                  decoration: const InputDecoration(
                                    labelText: 'Task type',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: taskTypes.map((type) {
                                    return DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() => selectedTaskType = value);
                                  },
                                ),

                                const SizedBox(height: 12),

                                // Date selector
                                InkWell(
                                  onTap: selectDate,
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'Date',
                                      border: OutlineInputBorder(),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(formatDate(selectedDate)),
                                        const Icon(Icons.calendar_today),
                                      ],
                                    ),
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
                                          'No plots available. Create one first.',
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
                                          child: Text(
                                            '${parcela['name']} - ${parcela['cropType']}',
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() => selectedParcelaId = value);
                                      },
                                    );
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Botones
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: clearForm,
                                      child: const Text('Clear'),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: isLoading ? null : createTask,
                                      child: isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text('Create Task'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Tasks list
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Planned Tasks',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              StreamBuilder<List<Map<String, dynamic>>>(
                                stream: _database.getAllTasks(),
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

                                  final tasks = snapshot.data ?? [];

                                  if (tasks.isEmpty) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Text('No planned tasks'),
                                      ),
                                    );
                                  }

                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: tasks.length,
                                    itemBuilder: (context, index) {
                                      final task = tasks[index];
                                      final date = task['date'] != null
                                          ? (task['date'] as dynamic).toDate()
                                          : DateTime.now();

                                      return Card(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        child: ListTile(
                                          title: Text(
                                            task['title'] ?? '',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(task['description'] ?? ''),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Type: ${task['type']} | Date: ${formatDate(date)}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                          trailing: IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () =>
                                                deleteTask(task['id']),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}