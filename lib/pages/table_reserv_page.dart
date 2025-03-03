import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:async';
import '../services/api_service.dart';

class TableReservationPage extends StatefulWidget {
  @override
  _TableReservationPageState createState() => _TableReservationPageState();
}

class _TableReservationPageState extends State<TableReservationPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? selectedArea;
  int? pax;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _timeManuallySelected = false;

  final Duration malaysiaTimeZoneOffset = const Duration(hours: 8); // UTC+8
  late DateTime malaysiaCurrentTime;
  Timer? _timer; // Add timer variable

  bool isTimeValid(TimeOfDay time) {
    if (selectedDate == null) return true;

    final now = DateTime.now().toUtc().add(malaysiaTimeZoneOffset);
    if (isSameDay(selectedDate!, now)) {
      final currentTime = TimeOfDay.fromDateTime(now);
      // Convert both times to minutes for easier comparison
      final selectedMinutes = time.hour * 60 + time.minute;
      final currentMinutes = currentTime.hour * 60 + currentTime.minute;

      // Add buffer time (e.g., 30 minutes from now)
      return selectedMinutes >= (currentMinutes + 30);
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    // Initialize Malaysia current time
    malaysiaCurrentTime = DateTime.now().toUtc().add(malaysiaTimeZoneOffset);

    // Initialize with exact current Malaysia time
    selectedTime = TimeOfDay.fromDateTime(malaysiaCurrentTime);

    // Start a timer to update the current time every minute
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          malaysiaCurrentTime =
              DateTime.now().toUtc().add(malaysiaTimeZoneOffset);
          // Only update selectedTime if it hasn't been manually changed by user
          if (!_timeManuallySelected) {
            selectedTime = TimeOfDay.fromDateTime(malaysiaCurrentTime);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer
    super.dispose();
  }

  // Calendar Widget
  Widget _buildCalendar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: TableCalendar(
          firstDay: DateTime.now(),
          lastDay: DateTime.now().add(Duration(days: 365)),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                selectedDate = selectedDay; // Update the selectedDate
                print('Selected date: $selectedDate'); // Debug print
              });
            }
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          calendarStyle: CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black54),
            rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black54),
          ),
        ),
      ),
    );
  }

  // Time Picker Widget
  Widget _buildTimePicker() {
    final currentTime = TimeOfDay.fromDateTime(malaysiaCurrentTime);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Select Time',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimeWheel(
                  value: selectedTime?.hour ?? currentTime.hour,
                  maxValue: 23,
                  onChanged: (value) {
                    _timeManuallySelected = true;
                    final newTime = TimeOfDay(
                      hour: value,
                      minute: selectedTime?.minute ?? currentTime.minute,
                    );
                    if (isTimeValid(newTime)) {
                      setState(() {
                        selectedTime = newTime;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Please select a time at least 30 minutes from now'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    ':',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ),
                _buildTimeWheel(
                  value: selectedTime?.minute ?? currentTime.minute,
                  maxValue: 59,
                  onChanged: (value) {
                    _timeManuallySelected = true;
                    final newTime = TimeOfDay(
                      hour: selectedTime?.hour ?? currentTime.hour,
                      minute: value,
                    );
                    if (isTimeValid(newTime)) {
                      setState(() {
                        selectedTime = newTime;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Please select a time at least 30 minutes from now'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeWheel({
    required int value,
    required int maxValue,
    required Function(int) onChanged,
  }) {
    final currentTime = TimeOfDay.fromDateTime(malaysiaCurrentTime);
    final currentTotalMinutes = currentTime.hour * 60 + currentTime.minute;

    return Container(
      height: 150,
      width: 80,
      child: ListWheelScrollView.useDelegate(
        itemExtent: 50,
        perspective: 0.005,
        diameterRatio: 1.2,
        physics: FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) {
          // For hours wheel
          if (maxValue == 23) {
            final newTotalMinutes = index * 60 + (selectedTime?.minute ?? 0);
            if (selectedDate == null ||
                !isSameDay(selectedDate!, malaysiaCurrentTime) ||
                newTotalMinutes >= currentTotalMinutes) {
              onChanged(index);
            } else {
              // Bounce back to current hour if trying to select past time
              WidgetsBinding.instance.addPostFrameCallback((_) {
                (context as Element).markNeedsBuild();
                setState(() {
                  selectedTime = TimeOfDay(
                    hour: currentTime.hour,
                    minute: selectedTime?.minute ?? currentTime.minute,
                  );
                });
              });
            }
          }
          // For minutes wheel
          else {
            if (selectedDate == null ||
                !isSameDay(selectedDate!, malaysiaCurrentTime)) {
              onChanged(index);
            } else if (selectedTime?.hour == currentTime.hour) {
              if (index >= currentTime.minute) {
                onChanged(index);
              } else {
                // Bounce back to current minute if trying to select past time
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  (context as Element).markNeedsBuild();
                  setState(() {
                    selectedTime = TimeOfDay(
                      hour: selectedTime?.hour ?? currentTime.hour,
                      minute: currentTime.minute,
                    );
                  });
                });
              }
            } else {
              onChanged(index);
            }
          }
        },
        controller: FixedExtentScrollController(initialItem: value),
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: maxValue + 1,
          builder: (context, index) {
            bool isPastTime = false;

            // Check if this is a past time
            if (selectedDate != null &&
                isSameDay(selectedDate!, malaysiaCurrentTime)) {
              if (maxValue == 23) {
                // Hours wheel
                isPastTime = index < currentTime.hour;
              } else {
                // Minutes wheel
                if (selectedTime?.hour == currentTime.hour) {
                  isPastTime = index < currentTime.minute;
                }
              }
            }

            return Container(
              decoration: BoxDecoration(
                color: value == index ? Color(0xFFF5F5F5) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight:
                        value == index ? FontWeight.bold : FontWeight.normal,
                    color: isPastTime
                        ? Colors.grey[300] // Gray out past times
                        : value == index
                            ? Colors.brown
                            : Colors.grey[400],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Function to handle "Book Now" button press
  void _bookNow() async {
    if (selectedDate != null &&
        selectedTime != null &&
        selectedArea != null &&
        pax != null) {
      try {
        final result = await ApiService.createReservation(
          date: selectedDate!,
          time: selectedTime!,
          area: selectedArea!,
          pax: pax!,
        );

        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Reservation created successful, kindly go your email and confirm the reservation')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(result['message'] ?? 'Failed to create reservation')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth =
              constraints.maxWidth > 500 ? 500.0 : constraints.maxWidth;

          return Column(
            children: [
              // Top Banner
              Stack(
                children: [
                  Container(
                    height: constraints.maxWidth > 500 ? 80 : 60,
                    color: Color(0xffe6be8a),
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text(
                      'Table Reservation',
                      style: TextStyle(
                        fontSize: constraints.maxWidth > 500 ? 30 : 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Reservation Form Content
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: Container(
                      width: maxWidth,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildCalendar(),
                            _buildTimePicker(),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Area',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: 'The Hornbill Restaurant (Chinese)',
                                    child: Text(
                                        'The Hornbill Restaurant (Chinese)'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'The Rajah Room (Western)',
                                    child: Text('The Rajah Room (Western)'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedArea = value;
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Pax',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    pax = int.tryParse(value);
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text('Want to book for an event?'),
                                  Text('Call: 012-3456789'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      // Bottom Banner
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            height: constraints.maxWidth > 500 ? 80 : 60, // Use LayoutBuilder for responsive height
            color: Color(0xffe6be8a),
            child: Center(
              child: ElevatedButton(
                onPressed: _bookNow,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color(0xffe6be8a),
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Text(
                  'Book Now',
                  style: TextStyle(
                    fontSize: constraints.maxWidth > 500 ? 22 : 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xffe6be8a),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
