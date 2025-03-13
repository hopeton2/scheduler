import 'package:flutter/material.dart';
import 'package:scheduler/services/scheduler_service.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerDropdown extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorChanged;

  const ColorPickerDropdown({
    super.key,
    required this.selectedColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final editorSettings = SchedulerService().scheduler.appointmentEditorSettings;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return ListTile(
      title: Text(editorSettings.colorLabel),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: selectedColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[400]!),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
      onTap: () => _showColorPicker(context, isMobile),
    );
  }

  void _showColorPicker(BuildContext context, bool isMobile) {
    final editorSettings = SchedulerService().scheduler.appointmentEditorSettings;

    if (isMobile) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) => _ColorPickerContent(
          selectedColor: selectedColor,
          onColorChanged: onColorChanged,
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(editorSettings.colorLabel),
          content: _ColorPickerContent(
            selectedColor: selectedColor,
            onColorChanged: onColorChanged,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(editorSettings.cancelButtonLabel),
            ),
          ],
        ),
      );
    }
  }
}

class _ColorPickerContent extends StatefulWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorChanged;

  const _ColorPickerContent({
    required this.selectedColor,
    required this.onColorChanged,
  });

  @override
  _ColorPickerContentState createState() => _ColorPickerContentState();
}

class _ColorPickerContentState extends State<_ColorPickerContent> {
  late Color _currentColor;
  bool _showCustomPicker = false;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.selectedColor;
  }

  @override
  Widget build(BuildContext context) {
    final editorSettings = SchedulerService().scheduler.appointmentEditorSettings;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isMobile) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    editorSettings.colorLabel,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (!_showCustomPicker) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...editorSettings.predefinedColors.map((color) => _ColorOption(
                        color: color,
                        isSelected: _currentColor == color,
                        onTap: () {
                          setState(() => _currentColor = color);
                          widget.onColorChanged(color);
                          if (isMobile) {
                            Navigator.of(context).pop();
                          }
                        },
                      )),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.color_lens),
                label: Text(editorSettings.customColorLabel),
                onPressed: () => setState(() => _showCustomPicker = true),
              ),
            ] else ...[
              ColorPicker(
                pickerColor: _currentColor,
                onColorChanged: (color) {
                  setState(() => _currentColor = color);
                  widget.onColorChanged(color);
                },
                enableAlpha: false,
                labelTypes: const [],
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.palette),
                label: const Text('Back to Presets'),
                onPressed: () => setState(() => _showCustomPicker = false),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorOption({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.grey[400]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? const Icon(
                Icons.check,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
}