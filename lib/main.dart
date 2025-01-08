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
  String _message = 'No widget added.';

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
    bool hasContentToSave = _selectedWidgets.contains('Image') ||
        _selectedWidgets.contains('TextField') ||
        _selectedImage != null;

    if (!hasContentToSave) {
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

      if (data['text'] != null || data['image'] != null) {
        await _database.ref('saved_data').push().set(data);

        setState(() {
          _message = 'Data saved successfully!';
        });

        // Show a green Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data saved successfully!'),
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

      // Show an error Snackbar
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 350,
              height: 600,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.lightGreen[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  if (_selectedWidgets.contains('TextField'))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          labelText: 'Enter Text',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  if (_selectedWidgets.contains('Image'))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: _pickImage,
                            child: const Text('Pick an Image'),
                          ),
                          const SizedBox(height: 16),
                          _selectedImage != null
                              ? Image.file(File(_selectedImage!.path),
                                  width: 200, height: 200, fit: BoxFit.cover)
                              : const Text('No image selected'),
                        ],
                      ),
                    ),
                  if (_selectedWidgets.contains('SaveButton'))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(200, 60),
                          side: const BorderSide(color: Colors.black, width: 1),
                          backgroundColor: Colors.green,
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
                  // The message will be shown here inside the existing container
                  if (_message.isNotEmpty)
                    Text(
                      _message,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Black text inside the green box
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
                      _message = ''; // Clear the message when a widget is added
                    }
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
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

class WidgetSelectionPage extends StatefulWidget {
  const WidgetSelectionPage({super.key});

  @override
  State<WidgetSelectionPage> createState() => _WidgetSelectionPageState();
}

class _WidgetSelectionPageState extends State<WidgetSelectionPage> {
  final List<String> _selectedItems = [];
  bool _isTextFieldSelected = false;
  bool _isImageSelected = false;
  bool _isSaveButtonSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Widgets'),
        backgroundColor: Colors.lightGreen[100],
      ),
      body: Container(
        color: Colors.lightGreen[100],
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCheckboxItem('TextField', _isTextFieldSelected, (value) {
                  setState(() {
                    _isTextFieldSelected = value!;
                    _updateSelectedItems('TextField', value);
                  });
                }),
                _buildCheckboxItem('Image', _isImageSelected, (value) {
                  setState(() {
                    _isImageSelected = value!;
                    _updateSelectedItems('Image', value);
                  });
                }),
                _buildCheckboxItem('SaveButton', _isSaveButtonSelected,
                    (value) {
                  setState(() {
                    _isSaveButtonSelected = value!;
                    _updateSelectedItems('SaveButton', value);
                  });
                }),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedItems.isNotEmpty) {
                      Navigator.pop(context, _selectedItems);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(200, 60),
                    side: const BorderSide(color: Colors.black, width: 1),
                  ),
                  child: const Text(
                    'Import Widgets',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxItem(
      String label, bool value, ValueChanged<bool?> onChanged) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
          color: Colors.grey[400], borderRadius: BorderRadius.circular(8)),
      child: GestureDetector(
        onTap: () {
          onChanged(!value);
        },
        child: ListTile(
          contentPadding: const EdgeInsets.only(left: 24.0),
          title: Row(
            children: [
              Container(
                color: Colors.white,
                height: 30,
                width: 30,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 24,
                    width: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: value ? Colors.green : Colors.grey,
                      border: Border.all(color: Colors.green),
                    ),
                    child: value ? null : const SizedBox(),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }

  void _updateSelectedItems(String item, bool isSelected) {
    if (isSelected) {
      _selectedItems.add(item);
    } else {
      _selectedItems.remove(item);
    }
  }
}
