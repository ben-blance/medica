import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PatientDashboardScreen extends StatefulWidget {
  final int userId;

  const PatientDashboardScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _PatientDashboardScreenState createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> medicines = [];
  Map<String, dynamic>? patientDetails;
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Fetch patient details
      final patientResponse = await supabase
          .from('patients')
          .select('name, age, gender, dob')
          .eq('id', widget.userId)
          .single();

      // Fetch medicines
      final medicinesResponse = await supabase
          .from('medicine')
          .select()
          .eq('id', widget.userId);

      setState(() {
        patientDetails = patientResponse;
        medicines = List<Map<String, dynamic>>.from(medicinesResponse);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to fetch data';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Dashboard'),
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
          IconButton(icon: Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      drawer: Drawer(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error.isNotEmpty
          ? Center(child: Text(error, style: TextStyle(color: Colors.red)))
          : Column(
        children: [
          _buildPatientDetailsCard(),
          Expanded(child: _buildMedicinesList()),
        ],
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
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildPatientDetailsCard() {
    if (patientDetails == null) return SizedBox.shrink();

    return Card(
      margin: EdgeInsets.all(16),
      color: Colors.grey[800],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patient Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Name', patientDetails!['name']),
                      SizedBox(height: 8),
                      _buildDetailRow('Age', '${patientDetails!['age']} years'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Gender', patientDetails!['gender']),
                      SizedBox(height: 8),
                      _buildDetailRow('DOB', _formatDate(patientDetails!['dob'])),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicinesList() {
    if (medicines.isEmpty) {
      return Center(child: Text('No medicines found'));
    }

    return ListView.builder(
      itemCount: medicines.length,
      itemBuilder: (context, index) {
        final medicine = medicines[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Card(
            color: Colors.grey[800],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Medicine: ${medicine['name']}',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          Text(
                            'Type: ${medicine['type']}',
                            style: TextStyle(fontSize: 14, color: Colors.white70),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Start: ${_formatDate(medicine['start_date'])}',
                            style: TextStyle(fontSize: 14, color: Colors.white70),
                          ),
                          Text(
                            'End: ${_formatDate(medicine['end_date'])}',
                            style: TextStyle(fontSize: 14, color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildMedicineScheduleTable(medicine),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid Date';
    }
  }

  Widget _buildMedicineScheduleTable(Map<String, dynamic> medicine) {
    return Table(
      border: TableBorder.all(color: Colors.white),
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.blueGrey),
          children: [
            _buildTableHeader('Time'),
            _buildTableHeader('Dosage'),
          ],
        ),
        if (medicine['breakfast'] != null)
          _buildTableRow('Breakfast', medicine['breakfast']),
        if (medicine['launch'] != null)
          _buildTableRow('Lunch', medicine['launch']),
        if (medicine['dinner'] != null)
          _buildTableRow('Dinner', medicine['dinner']),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  TableRow _buildTableRow(String time, String dosage) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(time, style: TextStyle(color: Colors.white)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(dosage, style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}