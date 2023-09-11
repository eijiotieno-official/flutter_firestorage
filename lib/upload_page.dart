import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UploadPage extends StatefulWidget {
  final File file;
  const UploadPage({super.key, required this.file});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  UploadTask? uploadTask;
  TaskState? taskState;
  double uploadProgress = 0.0;

  Future uploadFile() async {
    //get file name
    String fileName = path.basenameWithoutExtension(widget.file.path);

    Reference storageReference = FirebaseStorage.instance.ref();

    //store the uploaded file into 'files' folder
    Reference fileReference = storageReference.child("file/$fileName");

    setState(() {
      uploadTask = fileReference.putFile(widget.file);
    });

    //listen to upload task events
    uploadTask!.snapshotEvents.listen(
      (TaskSnapshot taskSnapshot) async {
        setState(() {
          taskState = taskSnapshot.state;
        });

        switch (taskSnapshot.state) {
          case TaskState.running:
            //update uploadProgress variable
            setState(() {
              uploadProgress =
                  (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
            });
            break;
          case TaskState.canceled:
            setState(() {
              uploadProgress = 0.0;
              uploadTask = null;
            });
            break;
          case TaskState.error:
            setState(() {
              uploadProgress = 0.0;
              uploadTask = null;
            });
            break;
          case TaskState.success:
            //we can retrieve the file's download url
            String url = await taskSnapshot.ref.getDownloadURL();
            print(url);
          default:
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          taskState == null
              ? "Upload Page"
              : taskState == TaskState.running
                  ? "Uploading file ..."
                  : taskState == TaskState.paused
                      ? "Paused"
                      : taskState == TaskState.error
                          ? "Error encountered"
                          : taskState == TaskState.success
                              ? "Successfully uploaded"
                              : "Cancelled upload",
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //display file name
          Text("File : ${path.basename(widget.file.path)}"),
          //visualize upload progress using LiquidCircularProgressIndicator widget
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: SizedBox(
              height: MediaQuery.of(context).size.width * 0.8,
              width: MediaQuery.of(context).size.width * 0.8,
              child: LiquidCircularProgressIndicator(
                value: uploadProgress,
                backgroundColor: Theme.of(context).hoverColor,
                center: Text("${(uploadProgress * 100).toInt()}"),
              ),
            ),
          ),
          //display this widget only when there is an uploadTask event
          if (uploadTask != null)
            Wrap(
              children: [
                if (taskState == TaskState.running)
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: () {
                        uploadTask!.pause();
                      },
                      child: const Text("Pause"),
                    ),
                  ),
                if (taskState == TaskState.running)
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: () {
                        uploadTask!.cancel();
                      },
                      child: const Text("Cancel"),
                    ),
                  ),
                if (taskState == TaskState.paused)
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: () {
                        uploadTask!.pause();
                      },
                      child: const Text("Resume"),
                    ),
                  ),
              ],
            ),
          if (uploadTask == null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () {
                    //call uploadFile function
                    uploadFile();
                  },
                  child: const Text("Upload File"),
                ),
              ),
            )
        ],
      ),
    );
  }
}
