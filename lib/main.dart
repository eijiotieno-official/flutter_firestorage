import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_firestorage/upload_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //this function will help us pick a file from the device storage
  Future<File?> pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: false);

    return result!.paths.map((e) => File(e!)).toList().first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Firestorage File Upload"),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await pickFile().then(
              (file) {
                if (file != null) {
                  //navigate to 'UploadPage' while passing 'file'
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return UploadPage(file: file);
                      },
                    ),
                  );
                }
              },
            );
          },
          child: const Text("Pick a file"),
        ),
      ),
    );
  }
}
