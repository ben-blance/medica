import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';

class MedicineEntry {
  String form;
  String name;
  String beforeAfterBreakfast;
  String beforeAfterLunch;
  String beforeAfterDinner;
  DateTime? startDate;
  DateTime? endDate;
  TextEditingController nameController;

  MedicineEntry({
    this.form = "Tablets",
    this.name = "",
    this.beforeAfterBreakfast = "No",
    this.beforeAfterLunch = "No",
    this.beforeAfterDinner = "No",
    this.startDate,
    this.endDate,
  }) : nameController = TextEditingController(text: name);

  // Add this factory constructor to create MedicineEntry from Supabase data
  factory MedicineEntry.fromJson(Map<String, dynamic> json) {
    return MedicineEntry(
      form: json['type'] ?? "Tablets",
      name: json['name'] ?? "",
      beforeAfterBreakfast: json['breakfast'] ?? "No",
      beforeAfterLunch: json['launch'] ?? "No",
      beforeAfterDinner: json['dinner'] ?? "No",
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
    );
  }

  void dispose() {
    nameController.dispose();
  }
}


class PatientDetailScreen extends StatefulWidget {
  final String id;

  const PatientDetailScreen({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  _PatientDetailScreenState createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  final _supabase = Supabase.instance.client;
  Map<String, dynamic>? _patientData;
  bool _isLoading = true;
  String? _error;
  bool _isPasswordVisible = false;

  List<MedicineEntry> _medicines = [MedicineEntry()];

  List<String> _medicineForms = [
    "Liquids",
    "Tablets",
    "Capsules",
    "Drops",
    "Creams",
    "Gels",
    "Ointments",
    "Inhalers",
    "Patches",
    "Injections",
  ];

  @override
  void initState() {
    super.initState();
    _fetchPatientData();
  }

  @override
  void dispose() {
    for (var medicine in _medicines) {
      medicine.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchPatientData() async {
    try {
      // Fetch patient details
      final patientResponse = await _supabase
          .from('patients')
          .select()
          .eq('id', widget.id)
          .single();

      // Fetch medicines for this patient
      final medicinesResponse = await _supabase
          .from('medicine')
          .select()
          .eq('id', widget.id);

      setState(() {
        _patientData = patientResponse;

        // Clear existing medicines
        for (var medicine in _medicines) {
          medicine.dispose();
        }

        // Convert response to MedicineEntry objects
        if (medicinesResponse.length > 0) {
          _medicines = List<MedicineEntry>.from(
              medicinesResponse.map((med) => MedicineEntry.fromJson(med))
          );
        } else {
          _medicines = [MedicineEntry()]; // Default empty medicine entry
        }

        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Error fetching data: $error';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateExistingMedicine(Map<String, dynamic> medicineData) async {
    await _supabase
        .from('medicine')
        .update(medicineData)
        .match({
      'id': _patientData?['id'],
      'name': medicineData['name'],
    });
  }



  Future<void> _saveMedicines() async {
    try {
      // Validate required fields
      for (var medicine in _medicines) {
        if (medicine.nameController.text.isEmpty) {
          throw 'Medicine name is required';
        }
        if (medicine.startDate == null || medicine.endDate == null) {
          throw 'Medicine period is required';
        }
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );


      // Get the patient ID from patientData
      final patientId = _patientData?['id'];
      if (patientId == null) {
        throw 'Patient ID not found';
      }

      // Fetch existing medicines to compare
      final existingMedicines = await _supabase
          .from('medicine')
          .select('name')
          .eq('id', patientId);

      final existingMedicineNames = existingMedicines
          .map((m) => m['name'] as String)
          .toSet();



      for (var medicine in _medicines) {
        final medicineData = {
          'id': patientId,
          'type': medicine.form,
          'name': medicine.nameController.text,
          'breakfast': medicine.beforeAfterBreakfast,
          'launch': medicine.beforeAfterLunch,
          'dinner': medicine.beforeAfterDinner,
          'start_date': medicine.startDate?.toIso8601String(),
          'end_date': medicine.endDate?.toIso8601String(),
        };

        if (existingMedicineNames.contains(medicine.nameController.text)) {
          // Update existing medicine
          await _updateExistingMedicine(medicineData);
        } else {
          // Insert new medicine
          await _supabase
              .from('medicine')
              .insert(medicineData);
        }
      }


      // Remove loading indicator
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medicines saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      // Remove loading indicator
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Not available';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  Future<void> _selectDateRange(BuildContext context, int index) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _medicines[index].startDate = picked.start;
        _medicines[index].endDate = picked.end;
      });
    }
  }

  void _addNewMedicine() {
    setState(() {
      _medicines.add(MedicineEntry());
    });
  }

  void _removeMedicine(int index) {
    if (_medicines.length > 1) {
      _medicines[index].dispose();
      setState(() {
        _medicines.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(_error!)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_patientData?['name'] ?? 'Patient Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Patient Details',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildPatientInfo(),
              const SizedBox(height: 16),
              ..._medicines.asMap().entries.map((entry) {
                final index = entry.key;
                return Column(
                  children: [
                    _buildMedicineEntry(index),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
              TextButton.icon(
                onPressed: _addNewMedicine,
                icon: const Icon(Icons.add),
                label: const Text('Add a new Medicine'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveMedicines,
                child: const Text("Save"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientInfo() {
    return Card(
      elevation: 2,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${_patientData?['name'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Age: ${_patientData?['age']?.toString() ?? 'N/A'}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Gender: ${_patientData?['gender'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Date of Birth: ${_formatDate(_patientData?['dob'])}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Current Date: ${_formatDate(_patientData?['currentdate'])}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Password: ${_isPasswordVisible ? (_patientData?['password'] ?? 'N/A') : '••••••••••'}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: _patientData?['password'] != null
                          ? () => _copyToClipboard(_patientData!['password'])
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Text(
              'ID: ${_patientData?['id'] ?? 'N/A'}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineEntry(int index) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Medicine ${index + 1}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (_medicines.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeMedicine(index),
                    color: Colors.red,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _medicines[index].form,
              decoration: const InputDecoration(
                labelText: "Form",
                border: OutlineInputBorder(),
              ),
              items: _medicineForms.map((String form) {
                return DropdownMenuItem<String>(
                  value: form,
                  child: Text(form),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _medicines[index].form = newValue!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _medicines[index].nameController,
              decoration: const InputDecoration(
                labelText: "Name of Medicine",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _medicines[index].name = value;
              },
            ),
            const SizedBox(height: 16),
            _buildRadioGroup(
              "Breakfast",
              _medicines[index].beforeAfterBreakfast,
                  (value) {
                setState(() {
                  _medicines[index].beforeAfterBreakfast = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildRadioGroup(
              "Lunch",
              _medicines[index].beforeAfterLunch,
                  (value) {
                setState(() {
                  _medicines[index].beforeAfterLunch = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildRadioGroup(
              "Dinner",
              _medicines[index].beforeAfterDinner,
                  (value) {
                setState(() {
                  _medicines[index].beforeAfterDinner = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _selectDateRange(context, index),
                  child: const Text("Select Period"),
                ),
                const SizedBox(width: 16),
                if (_medicines[index].startDate != null && _medicines[index].endDate != null)
                  Expanded(
                    child: Text(
                      "From ${DateFormat('dd/MM/yyyy').format(_medicines[index].startDate!)} to ${DateFormat('dd/MM/yyyy').format(_medicines[index].endDate!)}",
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioGroup(String label, String selectedValue, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        Row(
          children: [
            Radio<String>(
              value: "No",
              groupValue: selectedValue,
              onChanged: onChanged,
            ),
            const Text("No"),
            const SizedBox(width: 16),
            Radio<String>(
              value: "Before",
              groupValue: selectedValue,
              onChanged: onChanged,
            ),
            const Text("Before"),
            const SizedBox(width: 16),
            Radio<String>(
              value: "After",
              groupValue: selectedValue,
              onChanged: onChanged,
            ),
            const Text("After"),
          ],
        ),
      ],
    );
  }
}