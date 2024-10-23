import 'package:flutter/material.dart';

class PatientDashboardScreen extends StatefulWidget {
  @override
  _PatientDashboardScreenState createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  List<Map<String, dynamic>> patients = [
    {
      "name": "John Doe",
      "id": "ID: 12345",
      "gender": "Male",
      "dob": "01/01/1990",
      "age": "34",
      "startDate": "01/01/2024",
      "endDate": "01/30/2024",
      "prescriptions": [
        {
          "medName": "Aspirin",
          "medType": "Tablet",
          "frequency": "Before Breakfast",
        },
        {
          "medName": "Metformin",
          "medType": "Tablet",
          "frequency": "After Lunch",
        },
      ],
    },
    {
      "name": "Jane Smith",
      "id": "ID: 12346",
      "gender": "Female",
      "dob": "02/15/1985",
      "age": "39",
      "startDate": "02/01/2024",
      "endDate": "02/28/2024",
      "prescriptions": [
        {
          "medName": "Ibuprofen",
          "medType": "Tablet",
          "frequency": "After Dinner",
        },
      ],
    },
  ];

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
      body: ListView.builder(
        itemCount: patients.length,
        itemBuilder: (context, index) {
          var patient = patients[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Card(
              color: Colors.grey[800],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display patient name and ID with prescription dates
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patient['name']!,
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                            Text(
                              patient['id']!,
                              style: TextStyle(fontSize: 14, color: Colors.white70),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Start: ${patient['startDate']}',
                              style: TextStyle(fontSize: 14, color: Colors.white70),
                            ),
                            Text(
                              'End: ${patient['endDate']}',
                              style: TextStyle(fontSize: 14, color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Prescriptions:',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    _buildPrescriptionTable(patient['prescriptions']),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action for adding a new patient could be implemented here
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
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
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

  // Method to build the prescription table
  Widget _buildPrescriptionTable(List<dynamic> prescriptions) {
    if (prescriptions.isEmpty) {
      return Text("No prescriptions available", style: TextStyle(color: Colors.white70));
    }

    return Table(
      border: TableBorder.all(color: Colors.white),
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.blueGrey),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Medicine Name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Type', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Frequency', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        ...prescriptions.map((prescription) {
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(prescription['medName'], style: TextStyle(color: Colors.white)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(prescription['medType'], style: TextStyle(color: Colors.white)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(prescription['frequency'], style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }
}
