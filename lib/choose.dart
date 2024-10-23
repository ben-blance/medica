import 'package:flutter/material.dart';
import 'package:medika/dashboard.dart';
import 'package:medika/patientDashboard.dart';

class Choose extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Role'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Action for Doctor button
                print('Doctor button pressed');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardScreen()),
                );
              },
              child: Text('Doctor'),
            ),
            SizedBox(height: 20), // Add some space between buttons
            ElevatedButton(
              onPressed: () {
                // Action for Patient button
                print('Patient button pressed');

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PatientDashboardScreen()),
                );
              },
              child: Text('Patient'),
            ),
          ],
        ),
      ),
    );
  }
}
