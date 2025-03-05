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
    final currentTimeOfDay = TimeOfDay.fromDateTime(now);
    
    // If current time is past 10 PM, only allow future dates
    if (currentTimeOfDay.hour >= 22) {
      if (!selectedDate!.isAfter(now.add(Duration(days: 1)).subtract(Duration(days: 1)))) {
        return false;
      }
    }
    
    // If selected date is today
    if (isSameDay(selectedDate!, now)) {
      // Convert both times to minutes for comparison
      final selectedMinutes = time.hour * 60 + time.minute;
      final currentMinutes = currentTimeOfDay.hour * 60 + currentTimeOfDay.minute;

      // Check if time is within operating hours and at least 30 minutes from now
      return time.hour >= 8 && 
             time.hour < 22 && 
             selectedMinutes >= (currentMinutes + 30);
    }
    
    // For future dates, just check operating hours
    return time.hour >= 8 && time.hour < 22;
  }

  @override
  void initState() {
    super.initState();
    // Initialize Malaysia current time
    malaysiaCurrentTime = DateTime.now().toUtc().add(malaysiaTimeZoneOffset);

    // Check if current time is past 10 PM
    final currentTimeOfDay = TimeOfDay.fromDateTime(malaysiaCurrentTime);
    if (currentTimeOfDay.hour >= 22) {
      // Set selected date to tomorrow
      selectedDate = malaysiaCurrentTime.add(Duration(days: 1));
      _selectedDay = selectedDate;
      _focusedDay = selectedDate!;
      
      // Set selected time to 8 AM
      selectedTime = TimeOfDay(hour: 8, minute: 0);
      _timeManuallySelected = true;
    } else {
      // Initialize with current time if within operating hours
      selectedTime = TimeOfDay.fromDateTime(malaysiaCurrentTime);
      if (selectedTime!.hour < 8) {
        // If before 8 AM, set to 8 AM
        selectedTime = TimeOfDay(hour: 8, minute: 0);
        _timeManuallySelected = true;
      }
    }

    // Start timer for updates
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          malaysiaCurrentTime = DateTime.now().toUtc().add(malaysiaTimeZoneOffset);
          // Only update selectedTime if it hasn't been manually changed by user
          if (!_timeManuallySelected) {
            TimeOfDay currentTime = TimeOfDay.fromDateTime(malaysiaCurrentTime);
            if (currentTime.hour >= 22) {
              // If past 10 PM, set next day 8 AM
              selectedDate = malaysiaCurrentTime.add(Duration(days: 1));
              _selectedDay = selectedDate;
              _focusedDay = selectedDate!;
              selectedTime = TimeOfDay(hour: 8, minute: 0);
              _timeManuallySelected = true;
            } else if (currentTime.hour < 8) {
              // If before 8 AM, set to 8 AM
              selectedTime = TimeOfDay(hour: 8, minute: 0);
              _timeManuallySelected = true;
            } else {
              selectedTime = currentTime;
            }
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
          firstDay: DateTime.now().subtract(Duration(days: 365)),
          lastDay: DateTime.now().add(Duration(days: 365)),
          focusedDay: _focusedDay ?? DateTime.now(),
          calendarFormat: _calendarFormat,
          enabledDayPredicate: _enabledDayPredicate(),
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            final now = DateTime.now().toUtc().add(malaysiaTimeZoneOffset);
            final currentTimeOfDay = TimeOfDay.fromDateTime(now);

            // If current time is past 10 PM and trying to select today or earlier
            if (currentTimeOfDay.hour >= 22 && 
                !selectedDay.isAfter(now.add(Duration(days: 1)).subtract(Duration(days: 1)))) {
              // Show error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please select a date from tomorrow onwards'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            setState(() {
              _selectedDay = selectedDay;
              selectedDate = selectedDay;
              _focusedDay = focusedDay;
              
              // Reset time to 8 AM if selecting a future date
              if (!isSameDay(selectedDay, now)) {
                selectedTime = TimeOfDay(hour: 8, minute: 0);
                _timeManuallySelected = true;
              }
            });
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

  // Update the calendar's enabled day predicate
  bool Function(DateTime) _enabledDayPredicate() {
    return (day) {
      final now = DateTime.now().toUtc().add(malaysiaTimeZoneOffset);
      final currentTimeOfDay = TimeOfDay.fromDateTime(now);
      
      // If current time is past 10 PM
      if (currentTimeOfDay.hour >= 22) {
        // Only allow dates from tomorrow onwards
        return day.isAfter(now.add(Duration(days: 1)).subtract(Duration(days: 1)));
      }
      
      // Otherwise, only allow today and future dates
      return !day.isBefore(now.subtract(Duration(days: 1)));
    };
  }

  // Time Picker Widget
  Widget _buildTimePicker() {
    final now = DateTime.now().toUtc().add(malaysiaTimeZoneOffset);
    final currentTimeOfDay = TimeOfDay.fromDateTime(now);
    
    // Determine initial time based on current time
    TimeOfDay initialTime;
    if (currentTimeOfDay.hour >= 21) {
      // After 9 PM, set to 8:30 AM
      initialTime = TimeOfDay(hour: 8, minute: 30);
    } else if (currentTimeOfDay.hour < 8 || 
              (currentTimeOfDay.hour == 8 && currentTimeOfDay.minute < 30)) {
      // Before 8:30 AM, set to 8:30 AM
      initialTime = TimeOfDay(hour: 8, minute: 30);
    } else {
      // During operating hours, use current time
      initialTime = currentTimeOfDay;
    }

    // Use initialTime if selectedTime is not set
    final displayTime = selectedTime ?? initialTime;

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
                'Select Time (8:30 AM - 9:00 PM)',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimeWheel(
                  value: displayTime.hour,
                  maxValue: 23,
                  onChanged: (value) {
                    _timeManuallySelected = true;
                    final newTime = TimeOfDay(
                      hour: value,
                      minute: value == 8 ? 30 : // Force 30 minutes for 8 AM
                             value == 21 ? 0 :  // Force 0 minutes for 9 PM
                             displayTime.minute,
                    );
                    if (isTimeValid(newTime)) {
                      setState(() {
                        selectedTime = newTime;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please select a valid time between 8:30 AM and 9:00 PM'),
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
                  value: displayTime.minute,
                  maxValue: 59,
                  onChanged: (value) {
                    _timeManuallySelected = true;
                    final newTime = TimeOfDay(
                      hour: displayTime.hour,
                      minute: displayTime.hour == 8 ? (value < 30 ? 30 : value) : // Minimum 30 for 8 AM
                             displayTime.hour == 21 ? 0 :              // Always 0 for 9 PM
                             value,
                    );
                    if (isTimeValid(newTime)) {
                      setState(() {
                        selectedTime = newTime;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please select a valid time between 8:30 AM and 9:00 PM'),
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
            final actualHour = index + 8; // Convert index to actual hour (8-21)
            if (actualHour > 21) {  // Prevent selecting hours after 9 PM
              return;
            }
            
            if (actualHour == 8 && (selectedTime?.minute ?? 0) < 30) {
              // If selecting 8 AM, ensure minutes are at least 30
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  selectedTime = TimeOfDay(hour: 8, minute: 30);
                });
              });
            } else if (actualHour == 21 && (selectedTime?.minute ?? 0) > 0) {
              // If selecting 9 PM, ensure minutes are 0
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  selectedTime = TimeOfDay(hour: 21, minute: 0);
                });
              });
            } else {
              onChanged(actualHour);
            }
          }
          // For minutes wheel
          else {
            final newTime = TimeOfDay(
              hour: selectedTime?.hour ?? currentTime.hour,
              minute: index,
            );
            
            // Only restrict minutes for boundary hours (8 AM and 9 PM)
            if (newTime.hour == 8 && index < 30) {
              // If 8 AM, minimum minutes is 30
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  selectedTime = TimeOfDay(hour: 8, minute: 30);
                });
              });
              return;
            } else if (newTime.hour == 21 && index > 0) {
              // If 9 PM, only allow 00 minutes
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  selectedTime = TimeOfDay(hour: 21, minute: 0);
                });
              });
              return;
            }
            
            // For all other hours, allow any minute
            if (isTimeValid(newTime)) {
              onChanged(index);
            }
          }
        },
        controller: FixedExtentScrollController(
          initialItem: maxValue == 23 ? (value - 8) : value
        ),
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: maxValue == 23 ? 14 : 60, // 14 hours (8-21) or 60 minutes
          builder: (context, index) {
            bool isPastTime = false;
            bool isInvalidTime = false;
            final actualHour = maxValue == 23 ? index + 8 : selectedTime?.hour ?? 8;

            // Check if time is invalid only for boundary hours
            if (maxValue == 23) {
              isInvalidTime = actualHour > 21;  // Gray out hours after 9 PM
            } else {
              isInvalidTime = (selectedTime?.hour == 8 && index < 30) || // Only gray out minutes before 30 for 8 AM
                             (selectedTime?.hour == 21 && index > 0);    // Only gray out minutes after 00 for 9 PM
            }

            // Check if this is a past time
            if (selectedDate != null &&
                isSameDay(selectedDate!, malaysiaCurrentTime)) {
              final currentMinutes = currentTime.hour * 60 + currentTime.minute;
              final selectedMinutes = (selectedTime?.hour ?? actualHour) * 60 + 
                                    (maxValue == 23 ? 0 : index);
              
              isPastTime = selectedMinutes < currentMinutes;
            }

            return Container(
              decoration: BoxDecoration(
                color: (maxValue == 23 ? index + 8 : index) == value 
                    ? Color(0xFFF5F5F5) 
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  maxValue == 23 
                      ? (index + 8).toString().padLeft(2, '0')
                      : index.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: (maxValue == 23 ? index + 8 : index) == value 
                        ? FontWeight.bold 
                        : FontWeight.normal,
                    color: isInvalidTime || isPastTime
                        ? Colors.grey[300]
                        : (maxValue == 23 ? index + 8 : index) == value
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
                content: Text('Reservation created. Please come to your appointment')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(result['message'] ?? 'Failed to create reservation')),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Color(0xffe6be8a),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Color(0xffe6be8a),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 3),
                blurRadius: 6,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
        title: Text(
          'Book Reservation',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(3, 3),
                      blurRadius: 6,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
                child: _buildCalendar(),
              ),
              
              SizedBox(height: 20),
              
              Container(
                padding: EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(3, 3),
                      blurRadius: 6,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildTimePicker(),
                  ],
                ),
              ),
              
              SizedBox(height: 20),
              
              Container(
                width: double.infinity,
                constraints: BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(3, 3),
                            blurRadius: 6,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Area',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none, // Remove border line
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'The Hornbill Restaurant (Chinese)',
                            child: Text('The Hornbill Restaurant (Chinese)'),
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
                    SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(3, 3),
                            blurRadius: 6,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Pax',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none, // Remove border line
                          ),
                          hintText: 'Enter number of people',
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            final number = int.tryParse(value);
                            if (number != null && number > 0) {
                              setState(() {
                                pax = number;
                              });
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 20),

              Container(
                width: double.infinity,
                constraints: BoxConstraints(maxWidth: 600),
                child: ElevatedButton(
                  onPressed: _bookNow,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xffe6be8a),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Book Now',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      'Want to book an event?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    Text(
                      'Call 0123456789',
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              
            ],
          ),
        ),
      ),
    );
  }
}