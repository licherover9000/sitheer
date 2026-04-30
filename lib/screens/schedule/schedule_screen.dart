import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sitheer/providers/schedule_providers.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:sitheer/screens/schedule/add_event_schedule.dart';
// Make sure this matches your file name!

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  // 1. We added your missing function back!
  void _showAddEventSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddEventSheet(initialDate: _selectedDay),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      if (!mounted) return;
      context.read<ScheduleProviders>().startListening(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 2. Added the 's' to ScheduleProviders
    final events = context.watch<ScheduleProviders>().eventsForDay(
      _selectedDay,
    );

    // 3. Removed the rogue 'const' from Scaffold
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventSheet(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // 4. Fixed the twisted TableCalendar syntax
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            calendarFormat: CalendarFormat.week,
            eventLoader: (day) =>
                context.read<ScheduleProviders>().eventsForDay(day),
          ),

          const Divider(height: 1),

          Expanded(
            child: events.isEmpty
                ? const Center(child: Text('No events for this day.'))
                : ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (ctx, i) {
                      return ListTile(
                        title: Text(events[i].title),
                        subtitle: Text(
                          '${events[i].startTime.format(context)} - ${events[i].endTime.format(context)}',
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
