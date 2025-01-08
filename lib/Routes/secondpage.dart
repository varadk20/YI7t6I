import 'package:flutter/material.dart';

class SecondRoute extends StatefulWidget {
  const SecondRoute({super.key});

  @override
  State<SecondRoute> createState() => _SecondRouteState();
}

class _SecondRouteState extends State<SecondRoute> {
  final List<String> _selectedItems = [];
  bool _isTextFieldSelected = false;
  bool _isImageSelected = false;
  bool _isSaveButtonSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Widgets'),
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
                _buildCheckboxItem('SaveButton', _isSaveButtonSelected, (value) {
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
                    child: value
                        ? null
                        : const SizedBox(),
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
