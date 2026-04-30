import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sitheer/model/event.dart';
import 'package:sitheer/providers/schedule_providers.dart';

class AddEventSheet extends StatefulWidget {
  final DateTime initialDate;

  const AddEventSheet({super.key, required this.initialDate});

  @override
  State<AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends State<AddEventSheet> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  // The 5 color chips recommended by the manual
  final List<Color> _colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
  ];
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _selectedColor = _colors[0]; // Default to blue
    final now = TimeOfDay.now();
    _startTime = now;
    _endTime = now.replacing(hour: (now.hour + 1) % 24);
  }

  Future<void> _submit() async {
    if (_titleController.text.isEmpty) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final newEvent = AppEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      date: _selectedDate,
      startTime: _startTime,
      endTime: _endTime,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      color: _selectedColor,
    );

    final schedule = context.read<ScheduleProviders>();
    await schedule.addEvent(newEvent, uid);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        // Added scroll view so it doesn't overflow on small screens
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Event Title'),
              autofocus: true,
            ),
            const SizedBox(height: 16),

            // Date & Time Pickers
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Date: ${_selectedDate.toString().split(' ')[0]}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2030),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
            ),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Start: ${_startTime.format(context)}'),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _startTime,
                      );
                      if (time != null) setState(() => _startTime = time);
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('End: ${_endTime.format(context)}'),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _endTime,
                      );
                      if (time != null) setState(() => _endTime = time);
                    },
                  ),
                ),
              ],
            ),

            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Notes (Optional)'),
            ),
            const SizedBox(height: 16),

            // Color Chips
            const Text(
              'Event Color',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _colors.map((color) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: CircleAvatar(
                    backgroundColor: color,
                    child: _selectedColor == color
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Save Event'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
