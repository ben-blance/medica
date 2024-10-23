import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PatientDetailScreen extends StatefulWidget {
  final String name;
  final String id;
  final String? gender;
  final String? dob;
  final String? age;

  const PatientDetailScreen({
    Key? key,
    required this.name,
    required this.id,
    this.gender,
    this.dob,
    this.age,
  }) : super(key: key);

  @override
  _PatientDetailScreenState createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  // Variables for form and table fields
  String _selectedForm = "Tablets";
  String _medicineName = "";
  String _beforeAfterBreakfast = "Before";
  String _beforeAfterLunch = "Before";
  String _beforeAfterDinner = "Before";

  // Variables for date pickers
  DateTime? _startDate;
  DateTime? _endDate;

  // List of medicine forms
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

  // Method to select date range
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patient Details',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Name: ${widget.name}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('ID: ${widget.id}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            // Editable table starts here
            _buildEditableTable(),
            SizedBox(height: 16),
            // Save Button
            ElevatedButton(
              onPressed: () {
                // Handle form submission
                print("Saved");
              },
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableTable() {
    return Column(
      children: [
        // Form (Dropdown)
        DropdownButtonFormField<String>(
          value: _selectedForm,
          decoration: InputDecoration(labelText: "Form"),
          items: _medicineForms.map((String form) {
            return DropdownMenuItem<String>(
              value: form,
              child: Text(form),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedForm = newValue!;
            });
          },
        ),
        SizedBox(height: 16),
        // Name of Medicine (Text Field)
        TextField(
          decoration: InputDecoration(labelText: "Name of Medicine"),
          onChanged: (value) {
            setState(() {
              _medicineName = value;
            });
          },
        ),
        SizedBox(height: 16),
        // Before/After Meal Radio Buttons (Now stacked vertically)
        _buildRadioGroup("Breakfast", _beforeAfterBreakfast, (value) {
          setState(() {
            _beforeAfterBreakfast = value!;
          });
        }),
        SizedBox(height: 16),
        _buildRadioGroup("Lunch", _beforeAfterLunch, (value) {
          setState(() {
            _beforeAfterLunch = value!;
          });
        }),
        SizedBox(height: 16),
        _buildRadioGroup("Dinner", _beforeAfterDinner, (value) {
          setState(() {
            _beforeAfterDinner = value!;
          });
        }),
        SizedBox(height: 16),
        // Period (Date Range Picker)
        Row(
          children: [
            ElevatedButton(
              onPressed: () => _selectDateRange(context),
              child: Text("Select Period"),
            ),
            SizedBox(width: 16),
            if (_startDate != null && _endDate != null)
              Text(
                "From ${DateFormat('dd/MM/yyyy').format(_startDate!)} to ${DateFormat('dd/MM/yyyy').format(_endDate!)}",
              ),
          ],
        ),
      ],
    );
  }


  Widget _buildRadioGroup(String label, String selectedValue, Function(String?) onChanged) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 14)),
        Row(
          children: [
            Radio<String>(
              value: "Before",
              groupValue: selectedValue,
              onChanged: onChanged,
            ),
            Text("Before"),
            Radio<String>(
              value: "After",
              groupValue: selectedValue,
              onChanged: onChanged,
            ),
            Text("After"),
          ],
        ),
      ],
    );
  }
}
