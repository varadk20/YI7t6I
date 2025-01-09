import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_app/Routes/secondpage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Assignment App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _selectedWidgets = [];
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final TextEditingController _textController = TextEditingController();
  XFile? _selectedImage;
  String _message = 'No widget is added';

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) setState(() => _selectedImage = pickedFile);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  Future<void> _saveData() async {
    // Check if any widget has been added
    if (_selectedWidgets.isEmpty ||
        (!_selectedWidgets.contains('Image') &&
            !_selectedWidgets.contains('TextField') &&
            _selectedImage == null)) {
      setState(() {
        _message = 'Add at least a widget to save.';
      });
      return;
    }

    try {
      String? imageBase64;
      if (_selectedImage != null) {
        final imageFile = File(_selectedImage!.path);
        final imageBytes = await imageFile.readAsBytes();
        imageBase64 = base64Encode(imageBytes);
      }

      final text = _textController.text.trim();
      final data = {
        'text': text.isNotEmpty ? text : null,
        'image': imageBase64,
      };

      // Check if there's anything to save
      if (data['text'] != null || data['image'] != null) {
        await _database.ref('saved_data').push().set(data);

        // setState(() {
        //   _message = 'Data saved successfully!';
        // });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully Saved',
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _message = 'Nothing to save!';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Failed to save data: $e';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 350,
              height: 600,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 50, top: 30),
              decoration: BoxDecoration(
                color: Colors.lightGreen[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      if (_selectedWidgets.contains('TextField'))
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 50,
                              ), // Top margin for TextField
                              SizedBox(
                                width:
                                    300, // Match the width of the Upload Image button
                                child: TextField(
                                  controller: _textController,
                                  decoration: const InputDecoration(
                                    labelText: 'Enter Text',
                                    border: OutlineInputBorder(),
                                    
                                  ),
                                  
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_selectedWidgets.contains('Image'))
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              ElevatedButton(
                                onPressed: _pickImage,
                                style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(300, 50),
                                    backgroundColor: Colors.grey.shade300,
                                    shape: RoundedRectangleBorder()),
                                child: const Text(
                                  'Upload Image',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _selectedImage != null
                                  ? Image.file(
                                      File(_selectedImage!.path),
                                      width: 200,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    )
                                  : const Text('No image selected'),
                            ],
                          ),
                        ),
                    ],
                  ),
                  // Center the message
                  if (_message.isNotEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          _message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 30,
                            // fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  // Save Button at the bottom
                  if (_selectedWidgets.contains('SaveButton'))
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 80),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(80, 50),
                          side: const BorderSide(color: Colors.black, width: 1),
                          backgroundColor: Colors.green.shade200,
                          shape: RoundedRectangleBorder(),
                        ),
                        onPressed: _saveData,
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final selectedItems = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WidgetSelectionPage()),
                );
                if (selectedItems != null) {
                  setState(() {
                    _selectedWidgets = List<String>.from(selectedItems);
                    if (_selectedWidgets.isEmpty) {
                      _message = 'Add at least a widget to save.';
                    } else {
                      _message = '';
                    }
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade200,
                minimumSize: const Size(200, 60),
                side: const BorderSide(color: Colors.black, width: 1),
              ),
              child: const Text(
                'Add Widgets',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
