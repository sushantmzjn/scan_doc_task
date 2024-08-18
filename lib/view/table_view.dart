import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TableView extends StatelessWidget {
  final RecognizedText recognizedText;

  const TableView({Key? key, required this.recognizedText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanned Marksheet')),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical, // Enable vertical scrolling
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, // Enable horizontal scrolling
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

    // Debug: Print the recognized text
    debugPrint("Recognized Text:\n$text");

    // Split the text into lines
    List<String> lines = text.split('\n');
    int maxColumns = 0;

    for (String line in lines) {
      // Adjust this logic as needed. Example using single spaces as a delimiter.
      List<String> columns = line.split(RegExp(r'\s+'));

      // Debug: Print each line and its columns
      debugPrint("Line: $line\nColumns: $columns");

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
}
