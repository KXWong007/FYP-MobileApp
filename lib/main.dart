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
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        'Welcome',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'Sign in to your account',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: TextField(
                          controller: _memberIdController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            labelText: 'Member ID',
                          ),
                        )),
                    Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: TextField(
                          controller: _passwordController,
                          onTap: () {},
                          cursorColor: Color(0xff262626),
                          obscureText: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            labelText: 'Password',
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
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection error: $e')),
      );
    }
  }
}

class MainMenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 50,
            color: Color(0xffe6be8a),
            width: double.infinity,
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
            color: Color(0xffe6be8a),
            width: double.infinity,
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
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top Banner
                Stack(
                  children: [
                    Container(
                      height: 60,
                      color: Color(0xffe6be8a),
                      alignment: Alignment.center,
                      child: Text(
                        'Table Reservation',
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
                SizedBox(height: 20),
                _buildCalendar(),
                _buildTimePicker(),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                SizedBox(height: 20), // Added spacing
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 60,
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xffe6be8a),
              ),
            ),
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
  Timer? _refreshTimer; // Add timer variable

  @override
  void initState() {
    super.initState();
    fetchReservations();
    // Set up periodic refresh every 30 seconds
    _refreshTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (mounted) {
        fetchReservations();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel(); // Cancel timer when disposing
    super.dispose();
  }

  Future<void> fetchReservations() async {
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
        throw Exception('Server error: ${response.statusCode}');
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
              ['confirm', 'firstc', 'secondc', 'thirdc'].contains(status);
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
        throw Exception('Server error: ${response.statusCode}');
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
                    color: Color(0xffe6be8a),
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
                        Navigator.pop(context); // Navigate back to Main Menu
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
                        context, 'Upcoming', Colors.blue, 'upcoming'),
                    _buildNavigationButton(
                        context, 'Completed', Colors.green, 'completed'),
                    _buildNavigationButton(
                        context, 'Cancelled', Colors.red, 'cancelled'),
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
                color: Color(0xffe6be8a),
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
        return 'Booking Confirmed';
      case 'firstc':
      case 'secondc':
      case 'thirdc':
        return 'Pending Confirmation';
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
        return Colors.red; // Cancel button
      case 'firstc':
      case 'secondc':
      case 'thirdc':
        return Colors.grey; // Pending
      default:
        return Colors.grey;
    }
  }

  String _getActionButtonText(String status) {
    switch (status.toLowerCase()) {
      case 'confirm':
        return 'Cancel';
      case 'firstc':
      case 'secondc':
      case 'thirdc':
        return 'Waiting for confirmation...';
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
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                currentFilter == filter ? color : color.withOpacity(0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            setState(() {
              currentFilter = filter;
            });
          },
          child: Text(
            label,
            style: TextStyle(color: Colors.white),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Text
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(status),
                  ),
                ),
                // Add Reservation ID
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
                Icon(Icons.people, color: Colors.grey),
                SizedBox(width: 5),
                Text('Pax: $pax', style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey),
                SizedBox(width: 5),
                Text('Area: $area', style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey),
                SizedBox(width: 5),
                Text('Date: $date', style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey),
                SizedBox(width: 5),
                Text('Time: $time', style: TextStyle(fontSize: 16)),
              ],
            ),

            SizedBox(height: 15),

            // Conditional rendering based on status
            if (status == 'Pending Confirmation')
              // Row with reminder text and button for pending confirmation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Kindly check your email for reservation confirmation',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  ElevatedButton(
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
                ],
              )
            else
              // Only button aligned to the right for other statuses
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
      case 'Booking Confirmed':
        return Colors.blue;
      case 'Pending Confirmation':
        return Colors.orange;
      case 'In Waiting List':
        return Colors.grey;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}
