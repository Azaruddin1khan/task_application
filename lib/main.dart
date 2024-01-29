import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<List<String>> excelData = [];

  // Future<void> readExcel(String filePath) async {
  //   var bytes = File(filePath).readAsBytesSync();
  //   var excel = Excel.decodeBytes(bytes);

  //   for (var table in excel.tables.keys) {
  //     for (var row in excel.tables[table]!.rows) {
  //       setState(() {
  //         excelData.add(row.map((cell) => cell.toString()).toList());
  //       });
  //     }
  //   }
  // }

  Future<void> pickFile() async {
    try {
      // Open the file picker
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'xlsx',
          'xls',
          'csv',
        ], // Add more if needed
      );

      if (result != null) {
        // Check if the picked file is a Google Sheets file
        final pickedFile = result.files.single;
        if (pickedFile.extension == 'xlsx' ||
            pickedFile.extension == 'xls' ||
            pickedFile.extension == 'csv') {
          // Proceed with the file processing
          final filePath = pickedFile.path;

          print('Picked file path: ${pickedFile.path}');
          print('Picked file name: ${pickedFile.name}');
          print('Picked file bytes: ${pickedFile.bytes}');
          print('Picked file size: ${pickedFile.size}');

          // You can now handle the selected Google Sheets file as needed
        } else {
          // Invalid file type selected
          print(
              'Invalid file type selected. Please pick a Google Sheets file. ');
        }
      } else {
        // User canceled the picker
        print('User canceled the picker');
      }
    } catch (e) {
      // Handle any errors that occur during file picking
      print('Error picking file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF & Excel Example'),
      ),
      body: excelData.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => generatePDF(),
                    child: Text('Generate PDF'),
                  ),
                  ElevatedButton(
                    onPressed: pickFile,
                    child: Text('Pick Excel or Google sheet'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: excelData.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(excelData[index].join(', ')),
                );
              },
            ),
    );
  }

  Future<void> generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              pw.Text(
                '''Your text with different styles''',
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                '''You Can write anything what do you want''',
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
            ]),
      ),
    );

    final output = await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );

    // Save the PDF to the device
    // You can use a file picker package or save it to a specific location
    // Here, I'm saving it to the app's documents directory
    final file = File('example.pdf');
    await file.writeAsBytes(await pdf.save());

    print('PDF saved to: ${file.path}');
  }
}
