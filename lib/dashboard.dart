import 'package:flutter/material.dart';
import 'package:medika/addPatient.dart';
import 'package:medika/patientDetail.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, String>> patients = [];

  // Method to add a new patient
  void _addPatient(String name) {
    setState(() {
      patients.add({
        "name": name,
        "id": "ID: ${patients.length + 12345}",
        "gender": "Unknown", // Default or placeholder gender
        "dob": "Unknown",    // Default or placeholder DOB
        "age": "Unknown"     // Default or placeholder age
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dr. Mali'),
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
          IconButton(icon: Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      drawer: Drawer(),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.black,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  radius: 40,
                  child: Icon(Icons.person, size: 40),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. Mali',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      _buildStatBar("", 50, 50, Colors.red),
                      _buildStatBar("", 300, 300, Colors.orange),
                      _buildStatBar("", 42, 42, Colors.blue),
                    ],
                  ),
                ),

              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: patients.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {
                      // Navigate to the PatientDetailScreen with patient data
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PatientDetailScreen(
                            name: patients[index]['name']!,
                            id: patients[index]['id']!,
                            gender: patients[index]['gender'], // Add other patient info
                            dob: patients[index]['dob'],
                            age: patients[index]['age'],
                          ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patients[index]['name']!,
                                style: TextStyle(fontSize: 18, color: Colors.white),
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(height: 4),
                              Text(
                                patients[index]['id']!,
                                style: TextStyle(fontSize: 14, color: Colors.white70),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to the AddPatientScreen when the FAB is pressed
          final newPatientName = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPatientScreen()),
          );

          // If a new patient name is returned, add it to the list
          if (newPatientName != null) {
            _addPatient(newPatientName);
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            label: 'Habits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Dailies',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box),
            label: 'To Do\'s',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Rewards',
          ),
        ],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
      ),
    );
  }

  Widget _buildStatBar(String label, int current, int max, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey)),
        SizedBox(height: 4),
        LinearProgressIndicator(
          value: current / max,
          backgroundColor: Colors.grey,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
