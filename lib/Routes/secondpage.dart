import 'package:flutter/material.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:simple_app/Routes/displaywidgets.dart';

class SecondRoute extends StatefulWidget {
  const SecondRoute({super.key});

  @override
  State<SecondRoute> createState() => _SecondRouteState();
}

class _SecondRouteState extends State<SecondRoute> {
  final List<String> _selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Route'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MultiSelectContainer(
                prefix: MultiSelectPrefix(
                  selectedPrefix: const Padding(
                    padding: EdgeInsets.only(right: 5),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
                items: [
                  MultiSelectCard(value: 'TextField', label: 'TextField'),
                  MultiSelectCard(value: 'Image', label: 'Image'),
                  MultiSelectCard(value: 'SaveButton', label: 'SaveButton'),
                ],
                onChange: (allSelectedItems, selectedItem) {
                  setState(() {
                    _selectedItems.clear();
                    _selectedItems.addAll(allSelectedItems);
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_selectedItems.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DisplayWidgetsPage(selectedItems: _selectedItems),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  elevation: 12.0,
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                ),
                child: const Text('Import Widgets'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}