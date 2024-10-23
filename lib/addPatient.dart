import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates
import 'package:supabase_flutter/supabase_flutter.dart';

class AddPatientScreen extends StatefulWidget {
  @override
  _AddPatientScreenState createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  DateTime? _dob; // Date of Birth
  String? _age; // Age calculated from DOB
  String? _gender;

  // Gender options
  final List<String> _genders = ['Male', 'Female', 'Other'];

  final SupabaseClient supabase = Supabase.instance.client; // Supabase client instance

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Patient'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                onSaved: (value) {
                  _name = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the patient name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // Date of Birth Picker
              ListTile(
                title: Text(
                  _dob == null
                      ? 'Select Date of Birth'
                      : 'DOB: ${DateFormat('yyyy-MM-dd').format(_dob!)}',
                ),
                subtitle: _dob != null ? Text('Age: $_age years') : null,
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              SizedBox(height: 16),
              // Gender Dropdown
              DropdownButtonFormField(
                value: _gender,
                items: _genders.map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _gender = value as String?;
                  });
                },
                decoration: InputDecoration(labelText: 'Gender'),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a gender';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _addPatient(); // Call the function to add patient
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to pick a date of birth
  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Current date for initial display
      firstDate: DateTime(1900), // Limit past dates
      lastDate: DateTime.now(), // Cannot pick a future date
    );
    if (pickedDate != null && pickedDate != _dob) {
      setState(() {
        _dob = pickedDate;
        _age = _calculateAge(pickedDate).toString(); // Calculate age
      });
    }
  }

  // Function to calculate age based on date of birth
  int _calculateAge(DateTime dob) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - dob.year;
    if (currentDate.month < dob.month ||
        (currentDate.month == dob.month && currentDate.day < dob.day)) {
      age--;
    }
    return age;
  }

  // Function to add patient to Supabase table
  Future<void> _addPatient() async {
    if (_name != null && _dob != null && _gender != null && _age != null) {
      try {
        final response = await supabase.from('patient').insert({
          'name': _name,
          'age': int.parse(_age!), // Convert age to int
          'gender': _gender,
          'dob': _dob!.toIso8601String(), // Convert to ISO format for Supabase
          'currentdate': DateTime.now().toUtc().toIso8601String(), // UTC timestamp
        }).select(); // Fetch back the inserted row

        if (response == null || response.isEmpty) {
          print('Error adding patient');
        } else {
          print('Patient added: $response');
          Navigator.pop(context, _name); // Return the name to the previous screen
        }
      } catch (error) {
        print('Error adding patient: $error');
      }
    }
  }
}
