import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DisplayWidgetsPage extends StatefulWidget {
  final List<String> selectedItems;

  const DisplayWidgetsPage({super.key, required this.selectedItems});

  @override
  _DisplayWidgetsPageState createState() => _DisplayWidgetsPageState();
}

class _DisplayWidgetsPageState extends State<DisplayWidgetsPage> {
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final TextEditingController _textController = TextEditingController();
  XFile? _selectedImage;

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
    bool hasContentToSave = widget.selectedItems.contains('Image') ||
        widget.selectedItems.contains('TextField') ||
        _selectedImage != null;

    // If no widget is selected and only the Save Button is pressed, show snackbar
    if (!hasContentToSave) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least a widget to save')),
      );
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

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data saved successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nothing to save!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save data: $e')),
      );
    }
  }
  

  @override
  Widget build(BuildContext context) {
    bool hasContentToSave = widget.selectedItems.contains('Image') ||
        widget.selectedItems.contains('TextField') ||
        _selectedImage != null;

    return Scaffold(
      appBar: AppBar(title: Text('Selected Widgets')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.selectedItems.map((item) {
              if (item == 'TextField') {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                        labelText: 'Enter Text',
                        border: OutlineInputBorder()),
                  ),
                );
              } else if (item == 'Image') {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                          onPressed: _pickImage,
                          child: const Text('Pick an Image')),
                      const SizedBox(height: 16),
                      _selectedImage != null
                          ? Image.file(File(_selectedImage!.path),
                              width: 200, height: 200, fit: BoxFit.cover)
                          : const Text('No image selected'),
                    ],
                  ),
                );
              } else if (item == 'SaveButton') {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 12.0,
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green),
                    onPressed: _saveData, // Always enabled
                    child: const Text('Save'),
                  ),
                );
              }
              return const SizedBox.shrink();
            }).toList(),
          ),
        ),
      ),
    );
  }
}
