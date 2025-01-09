import 'package:flutter/material.dart';

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
                _buildCheckboxItem('Text Widget', _isTextFieldSelected, (value) {
                  setState(() {
                    _isTextFieldSelected = value!;
                    _updateSelectedItems('TextField', value);
                  });
                }),
                _buildCheckboxItem('Image Widget', _isImageSelected, (value) {
                  setState(() {
                    _isImageSelected = value!;
                    _updateSelectedItems('Image', value);
                  });
                }),
                _buildCheckboxItem('Button Widget', _isSaveButtonSelected,
                    (value) {
                  setState(() {
                    _isSaveButtonSelected = value!;
                    _updateSelectedItems('SaveButton', value);
                  });
                }),
                const SizedBox(height: 100),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedItems.isNotEmpty) {
                      Navigator.pop(context, _selectedItems);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade200,
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
      margin: const EdgeInsets.symmetric(vertical: 30.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: GestureDetector(
        onTap: () {
          onChanged(!value);
        },
        child: SizedBox(
          width: 300,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              color: Colors.white,
              width: 50,
              height: double.infinity, // Matches ListTile height
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: value ? Colors.green : Colors.grey.shade300,
                    // border: Border.all(color: Colors.green),
                  ),
                ),
              ),
            ),
            title: Text(label),
            horizontalTitleGap: 20.0, // Gap between leading and title
          ),
        ),
      ),
    );
  }

  void _updateSelectedItems(String label, bool isSelected) {
    if (isSelected) {
      _selectedItems.add(label);
    } else {
      _selectedItems.remove(label);
    }
  }
}
