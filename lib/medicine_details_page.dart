import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MedicineDetailsPage extends StatelessWidget {
  final String medicineName;

  MedicineDetailsPage({required this.medicineName});

  Future<Map<String, dynamic>> fetchMedicineDetails() async {
    // Using the DailyMed API as an example
    final response = await http.get(
      Uri.parse(
          'https://dailymed.nlm.nih.gov/dailymed/services/v2/drugname/$medicineName'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to load medicine details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicine Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchMedicineDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data found for $medicineName'));
          }

          final medicineData = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${medicineData['title']}',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text(
                    'Primary Use: ${medicineData['indications_and_usage'] ?? 'N/A'}'),
                // Add more details as required
              ],
            ),
          );
        },
      ),
    );
  }
}
