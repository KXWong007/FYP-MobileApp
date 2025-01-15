import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './services/api_service.dart';
import './services/menu_service.dart';
import './services/order_service.dart';
import './services/cart_service.dart';
import './pages/menu_page.dart';
import './pages/orders_page.dart';
import 'profile_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartService()),
        ChangeNotifierProvider(create: (_) => MenuService()),
        ChangeNotifierProvider(create: (_) => OrderService()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scoot Meals',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: LoginPage(),
    );
  }
}

class MyAppState extends ChangeNotifier {}

class LoginPage extends StatelessWidget {
  final TextEditingController _memberIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                      child: Image.asset("../img/Logo1.jpeg"),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Welcome back you\'ve been missed',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16,
                          
                        ),
                      ),
                    ),
                    Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Container(
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
                            controller: _memberIdController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide.none, // Remove border line
                              ),
                              labelText: 'Member ID',
                              prefixIcon: Icon(
                                Icons.person_outline_rounded,
                              ),
                            ),
                          ),
                        )),
                    Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Container(
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
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide.none, // Remove border line
                              ),
                              labelText: 'Password',
                              prefixIcon: Icon(
                                Icons.lock_outline_rounded,
                              ),
                            ),
                          ),
                        )),

                    Container(
                        height: 80,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              backgroundColor: Color(0xff262626)),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () => _signIn(context),
                        )),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Forget Your Password?',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ))),
    );
  }

  Future<void> _signIn(BuildContext context) async {
    try {
      print('Attempting to sign in...');
      print('CustomerId: ${_memberIdController.text}');

      // Define base URL based on platform
      final String baseUrl = 'http://127.0.0.1:8000';

      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: jsonEncode({
          'customerId': _memberIdController.text,
          'password': _passwordController.text,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Decoded data: $data');

        if (data['success'] == true) {
          // Store the customer ID after successful login
          ApiService.setSignedInCustomerId(_memberIdController.text);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainMenuPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Invalid credentials')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Your Member ID or Password is incorrect')),
        );
      }
    } catch (e) {
      print('Error details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your Member ID or Password is incorrect')),
      );
    }
  }
}

class MainMenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xffe6be8a),
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 3),  // Shadow goes downward
                  blurRadius: 6,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Pick Your Option',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            // Ensures the grid takes up remaining space
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 30,
                mainAxisSpacing: 30,
                shrinkWrap: true,
                children: [
                  MainMenuButton(
                    icon: Icons.restaurant,
                    label: 'Food Ordering',
                    onPressed: () async {
                      // Show the table number input dialog
                      String? selectedTable = await showDialog<String>(
                        context: context,
                        builder: (BuildContext context) {
                          String inputTableNum = '';
                          return AlertDialog(
                            title: const Text('Enter Table Number'),
                            content: TextField(
                              onChanged: (value) {
                                inputTableNum = value;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Table Number',
                                hintText: 'e.g., M1, R2, H3',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(null),
                                child: Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  // Validate the table number
                                  final tableNum = inputTableNum.trim();
                                  bool isValid =
                                      await ApiService.validateTableNumber(
                                          tableNum);

                                  if (isValid) {
                                    // Proceed with the order process
                                    Navigator.of(context).pop(tableNum);
                                  } else {
                                    // Show an error message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('Invalid table number')),
                                    );
                                  }
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );

                      if (selectedTable != null) {
                        // Fetch the signed-in customer's ID asynchronously
                        final customerId =
                            await ApiService.getSignedInCustomerId();

                        if (customerId != null) {
                          // Navigate to MenuPage with tableNum and customerId
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MenuPage(
                                tableNum: selectedTable,
                                customerId: customerId,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Unable to retrieve customer ID')),
                          );
                        }
                      }
                    },
                  ),
                  MainMenuButton(
                    icon: Icons.receipt_long,
                    label: 'Orders List',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OrderPage()),
                      );
                    },
                  ),
                  MainMenuButton(
                    icon: Icons.event_seat,
                    label: 'Table Reservation',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TableReservationPage()),
                      );
                    },
                  ),
                  MainMenuButton(
                    icon: Icons.list_alt,
                    label: 'Reservation List',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ReservationListPage()),
                      );
                    },
                  ),
                  MainMenuButton(
                    icon: Icons.person,
                    label: 'Profile',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      );
                    },
                  ),
                  MainMenuButton(
                    icon: Icons.logout,
                    label: 'Logout',
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xffe6be8a),
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, -3),  // Shadow goes upward
                  blurRadius: 6,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MainMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const MainMenuButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.black,
              size: 80,
            ),
            SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: Colors.brown,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center, // Center the label
            ),
          ],
        ),
      ),
    );
  }
}

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

class ReservationListPage extends StatefulWidget {
  @override
  _ReservationListPageState createState() => _ReservationListPageState();
}

class _ReservationListPageState extends State<ReservationListPage> {
  List<Map<String, dynamic>> reservations = [];
  bool isLoading = true;
  String? error;
  String currentFilter = 'upcoming';
  Timer? _refreshTimer;
  final Duration malaysiaTimeZoneOffset = const Duration(hours: 8);

  @override
  void initState() {
    super.initState();
    fetchReservations();
    // Set up periodic refresh
    _refreshTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (mounted) {  // Check if widget is still mounted
        fetchReservations();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();  // Cancel timer when disposing
    super.dispose();
  }

  Future<void> fetchReservations() async {
    if (!mounted) return;  // Add this check at the start of the method
    
    try {
      // Don't show loading indicator for automatic refreshes
      if (isLoading) {
        setState(() {
          error = null;
        });
      }

      final customerId = ApiService.getSignedInCustomerId();
      if (customerId == null) throw Exception('No signed in user');

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/reservations/user/$customerId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (!mounted) return;  // Add this check before setState

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            reservations = List<Map<String, dynamic>>.from(data['data']);
            isLoading = false;
          });
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch reservations');
        }
      } else {
        throw Exception('Server error! Contact admin for assistance');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  // Add pull-to-refresh functionality
  Future<void> _onRefresh() async {
    await fetchReservations();
  }

  List<Map<String, dynamic>> getFilteredReservations() {
    final now = DateTime.now();

    List<Map<String, dynamic>> filtered = reservations.where((reservation) {
      final date = DateTime.parse(reservation['reservationDate']);
      final status = reservation['rstatus'].toString().toLowerCase();

      switch (currentFilter) {
        case 'upcoming':
          return date.isAfter(now) &&
              ['confirm'].contains(status);
        case 'completed':
          return date.isBefore(now) && status == 'completed';
        case 'cancelled':
          return status == 'cancel';
        default:
          return true;
      }
    }).toList();

    // Sort the filtered list
    if (currentFilter == 'upcoming') {
      filtered.sort((a, b) {
        // First sort by status (confirmed first)
        final statusA = a['rstatus'].toString().toLowerCase();
        final statusB = b['rstatus'].toString().toLowerCase();

        // If status is 'confirm', it should come first
        if (statusA == 'confirm' && statusB != 'confirm') return -1;
        if (statusA != 'confirm' && statusB == 'confirm') return 1;

        // If both have same status, sort by date
        final dateA = DateTime.parse(a['reservationDate']);
        final dateB = DateTime.parse(b['reservationDate']);
        return dateA.compareTo(dateB);
      });
    }

    return filtered;
  }

  Future<void> cancelReservation(String reservationId) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/reservations/$reservationId/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      // Hide loading dialog
      Navigator.pop(context);

      print('Cancel response: ${response.body}'); // Debug print

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reservation cancelled successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh the reservations list
          await fetchReservations();
        } else {
          throw Exception(data['message'] ?? 'Failed to cancel reservation');
        }
      } else {
        throw Exception('Server error! Contact admin for assistance');
      }
    } catch (e) {
      // Hide loading dialog if error occurs
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      print('Error cancelling reservation: $e'); // Debug print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel reservation: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              // Top Banner with Title and Back Button
              Stack(
                children: [
                  Container(
                    height: 60,
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
                    alignment: Alignment.center,
                    child: Text(
                      'Reservation List',
                      style: TextStyle(
                        fontSize: 24,
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

              SizedBox(height: 20), // Space between widgets

              // Navigation Buttons
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavigationButton(
                        context, 'Upcoming', Color(0xffe6be8a), 'upcoming'),
                    _buildNavigationButton(
                        context, 'Completed', Color(0xffe6be8a), 'completed'),
                    _buildNavigationButton(
                        context, 'Cancelled', Color(0xffe6be8a), 'cancelled'),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Wrap the Expanded widget with RefreshIndicator
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : error != null
                          ? Center(child: Text(error!))
                          : getFilteredReservations().isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 64,
                                        color: Color(0xffe6be8a),
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        currentFilter == 'upcoming' 
                                            ? 'No Upcoming Reservations'
                                            : currentFilter == 'completed'
                                                ? 'No Completed Reservations'
                                                : 'No Cancelled Reservations',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Color(0xffe6be8a),
                                          // fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  physics:
                                      AlwaysScrollableScrollPhysics(), // Enable scrolling
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  itemCount: getFilteredReservations().length,
                                  itemBuilder: (context, index) {
                                    final reservation =
                                        getFilteredReservations()[index];
                                    final date = DateTime.parse(
                                        reservation['reservationDate']);

                                    return _buildReservationCard(
                                      status:
                                          _getStatusText(reservation['rstatus']),
                                      reservationId: reservation['reservationId'],
                                      pax: reservation['pax'].toString(),
                                      area: _getAreaText(reservation['rarea']),
                                      date: DateFormat('yyyy-MM-dd').format(date),
                                      time: DateFormat('HH:mm').format(date),
                                      buttonColor: _getActionButtonColor(
                                          reservation['rstatus']),
                                      buttonText: _getActionButtonText(
                                          reservation['rstatus']),
                                      buttonAction:
                                          reservation['rstatus'] == 'confirm'
                                              ? () => cancelReservation(
                                                  reservation['reservationId'])
                                              : null,
                                    );
                                  },
                                ),
                ),
              ),

              // Bottom Banner
              Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xffe6be8a),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, -3),
                      blurRadius: 6,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods for the UI
  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'confirm':
        return 'Upcoming';
      case 'cancel':
        return 'Cancelled';
      case 'completed':
        return 'Completed';
      default:
        return 'Unknown Status';
    }
  }

  String _getAreaText(String area) {
    switch (area.toUpperCase()) {
      case 'W':
        return 'The Rajah Room (Western)';
      case 'C':
        return 'The Hornbill Restaurant (Chinese)';
      default:
        return 'Unknown Area';
    }
  }

  Color _getActionButtonColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirm':
        return Color(0xffe6be8a); // Cancel button
      default:
        return Colors.grey;
    }
  }

  String _getActionButtonText(String status) {
    switch (status.toLowerCase()) {
      case 'confirm':
        return 'Cancel';
      case 'cancel':
        return 'Cancelled';
      case 'completed':
        return 'Completed';
      default:
        return '';
    }
  }

  // Update the navigation button to include filter functionality
  Widget _buildNavigationButton(
    BuildContext context,
    String label,
    Color color,
    String filter,
  ) {
    final bool isSelected = currentFilter == filter;
    
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                offset: Offset(3, 3),
                blurRadius: 6,
                color: Colors.grey.shade400,
              ),
            ],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected ? color : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0, // Remove default button elevation
            ),
            onPressed: () {
              setState(() {
                currentFilter = filter;
              });
            },
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Builds a reservation card
  Widget _buildReservationCard({
    required String status,
    required String reservationId,
    required String pax,
    required String area,
    required String date,
    required String time,
    required Color buttonColor,
    required String buttonText,
    VoidCallback? buttonAction,
  }) {
    // Check if reservation is today and before 9 PM
    final reservationDateTime = DateTime.parse('$date $time');
    final now = DateTime.now().toUtc().add(malaysiaTimeZoneOffset);
    final isToday = isSameDay(reservationDateTime, now);
    final reservationTimeOfDay = TimeOfDay.fromDateTime(reservationDateTime);
    final isBefore9PM = reservationTimeOfDay.hour < 21 || 
                       (reservationTimeOfDay.hour == 21 && reservationTimeOfDay.minute == 0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              offset: Offset(3, 3),
              blurRadius: 6,
              color: Colors.grey.shade400,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xffe6be8a),
                      ),
                    ),
                    if (status == 'Upcoming' && isToday && isBefore9PM) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xffe6be8a),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          'Today',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  'Reservation ID: $reservationId',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Booking Details
            Row(
              children: [
                Icon(Icons.people, color: Color(0xffe6be8a)),
                SizedBox(width: 5),
                Text('Pax: $pax', style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.location_on, color: Color(0xffe6be8a)),
                SizedBox(width: 5),
                Text('Area: $area', style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Color(0xffe6be8a)),
                SizedBox(width: 5),
                Text('Date: $date', style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.access_time, color: Color(0xffe6be8a)),
                SizedBox(width: 5),
                Text('Time: $time', style: TextStyle(fontSize: 16)),
              ],
            ),

            SizedBox(height: 15),

            // Corrected button styling
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: buttonAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to get color based on status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Upcoming':
        return Color(0xffe6be8a);
      case 'In Waiting List':
        return Color(0xffe6be8a);
      case 'Completed':
        return Color(0xffe6be8a);
      case 'Cancelled':
        return Color(0xffe6be8a);
      default:
        return Colors.black;
    }
  }
}
