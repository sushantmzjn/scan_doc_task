import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

class TableView extends StatelessWidget {
  final RecognizedText recognizedText;

  const TableView({Key? key, required this.recognizedText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanned Marksheet'),
        actions: [
          IconButton(
            onPressed: () => _downloadCSV(context),
            icon: const Icon(Icons.download),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recognized Text:',
                  style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10.h),
                Table(
                  border: TableBorder.all(),
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  children: _buildTableRows(recognizedText.text),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<TableRow> _buildTableRows(String text) {
    List<TableRow> rows = [];
    List<List<String>> tableData = [];

    // Split the text into lines
    List<String> lines = text.split('\n');
    int maxColumns = 0;

    for (String line in lines) {
      // Adjust this logic as needed. Example using single spaces as a delimiter.
      List<String> columns = line.split(RegExp(r'\s+'));

      // Trim any excess whitespace from the columns
      columns = columns.map((col) => col.trim()).toList();

      // Add the parsed columns to tableData
      tableData.add(columns);

      // Update maxColumns to ensure all rows have the same number of columns
      if (columns.length > maxColumns) {
        maxColumns = columns.length;
      }
    }

    // Build table rows, padding with empty strings if necessary
    for (List<String> columns in tableData) {
      rows.add(
        TableRow(
          children: List.generate(
            maxColumns,
            (index) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(index < columns.length ? columns[index] : ''),
            ),
          ),
        ),
      );
    }

    return rows;
  }

  Future<void> _downloadCSV(BuildContext context) async {
    List<List<String>> tableData = [];

    List<String> lines = recognizedText.text.split('\n');

    for (String line in lines) {
      List<String> columns = line.split(RegExp(r'\s+'));

      columns = columns.map((col) => col.trim()).toList();

      tableData.add(columns);
    }

    String csvData = const ListToCsvConverter().convert(tableData);

    String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    String fileName = 'scanned_text_$timestamp.csv';

    Directory? downloadsDirectory;
    if (Platform.isAndroid) {
      downloadsDirectory = Directory('/storage/emulated/0/Download');
    } else if (Platform.isIOS) {
      downloadsDirectory = await getApplicationDocumentsDirectory();
    } else {
      downloadsDirectory = await getTemporaryDirectory();
    }

    if (downloadsDirectory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not get Downloads directory')),
      );
      return;
    }

    String filePath = '${downloadsDirectory.path}/$fileName';

    // Write CSV to file
    File file = File(filePath);
    await file.writeAsString(csvData);

    // sacffold message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data saved to $filePath')),
    );
    print('File saved to $filePath');
  }
}
