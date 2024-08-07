import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'scan_result_screen.dart'; // Import the result screen
import 'medicine_details_page.dart'; // Import the medicine details page if needed

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({Key? key}) : super(key: key);

  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  String _barcode = "";
  String _scanResult = "";
  String _expiryDate = "";
  bool? _isFake;

  Future<void> _scanBarcode() async {
    try {
      final result = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );
      if (result != '-1') {
        setState(() {
          _barcode = result;
        });

        await FirebaseFirestore.instance.collection('barcodes').add({
          'barcode': _barcode,
          'scannedAt': Timestamp.now(),
        });

        await _checkMedicine(_barcode);
      }
    } catch (e) {
      setState(() {
        _scanResult = 'Error: $e';
      });
    }
  }

  Future<void> _checkMedicine(String barcode) async {
    try {
      final url =
          'https://your-api-endpoint.com/check-medicine'; // Replace with your API endpoint
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({'barcode': barcode}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _isFake = data['isFake'];
          _expiryDate = "Expiry Date: ${data['expiryDate']}";
          _scanResult =
              _isFake! ? "This medicine is fake." : "This medicine is genuine.";
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanResultScreen(
              barcode: _barcode,
              scanResult: _scanResult,
              expiryDate: _expiryDate,
              isFake: _isFake!,
            ),
          ),
        );
      } else {
        setState(() {
          _scanResult = "Failed to check medicine. Please try again.";
        });
      }
    } catch (e) {
      setState(() {
        _scanResult = 'Error connecting to API: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barcode Scanner'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _barcode.isEmpty ? 'Scan a barcode' : 'Scanned: $_barcode',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _scanBarcode,
              child: Text('Start Barcode Scan'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              _scanResult.isEmpty ? '' : 'Result: $_scanResult',
              style: TextStyle(
                  fontSize: 16,
                  color: _isFake == true ? Colors.red : Colors.green),
            ),
            SizedBox(height: 20),
            Text(
              _expiryDate,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
