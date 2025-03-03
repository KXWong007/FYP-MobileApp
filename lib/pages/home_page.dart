import 'package:flutter/material.dart';
import '../services/api_service.dart';
import './menu_page.dart';
import './orders_page.dart';
import './profile_page.dart';
import './table_reserv_page.dart';
import './reserv_list_page.dart';
import '../main.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Constrain max width for better mobile experience
          final maxWidth =
              constraints.maxWidth > 500 ? 500.0 : constraints.maxWidth;

          return Column(
            children: [
              // Top Banner
              Container(
                height: 50,
                color: Color(0xffe6be8a),
                width: double.infinity,
              ),
              // Title
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
              // Button Grid
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: Container(
                      width: maxWidth,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: GridView.count(
                          crossAxisCount: 2, // Two buttons per row
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          shrinkWrap:
                              true, // Avoid expanding the grid unnecessarily
                          physics:
                              NeverScrollableScrollPhysics(), // Let parent handle scrolling
                          children: [
                            HomeButton(
                              icon: Icons.restaurant,
                              label: 'Food Ordering',
                              onPressed: () async {
                                String? selectedTable =
                                    await _showTableNumberDialog(context);
                                if (selectedTable != null) {
                                  final customerId =
                                      await ApiService.getSignedInCustomerId();
                                  if (customerId != null) {
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
                                    _showSnackBar(context,
                                        'Unable to retrieve customer ID');
                                  }
                                }
                              },
                            ),
                            HomeButton(
                              icon: Icons.receipt_long,
                              label: 'Orders List',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => OrderPage()),
                                );
                              },
                            ),
                            HomeButton(
                              icon: Icons.event_seat,
                              label: 'Table Reservation',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          TableReservationPage()),
                                );
                              },
                            ),
                            HomeButton(
                              icon: Icons.list_alt,
                              label: 'Reservation List',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ReservationListPage()),
                                );
                              },
                            ),
                            HomeButton(
                              icon: Icons.person,
                              label: 'Profile',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProfilePage()),
                                );
                              },
                            ),
                            HomeButton(
                              icon: Icons.logout,
                              label: 'Logout',
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Bottom Banner (fixed to bottom)
              Container(
                height: 50,
                color: Color(0xffe6be8a),
                width: double.infinity,
              ),
            ],
          );
        },
      ),
    );
  }

  Future<String?> _showTableNumberDialog(BuildContext context) async {
    String inputTableNum = '';
    final TextEditingController tableNumController = TextEditingController();

    return await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Table Number'),
          content: TextField(
            controller: tableNumController,
            autofocus: true, // Automatically focus on the input field
            onChanged: (value) {
              inputTableNum = value;
            },
            onSubmitted: (value) async {
              // Trigger OK button action on Enter key press
              final tableNum = value.trim();
              bool isValid = await ApiService.validateTableNumber(tableNum);

              if (isValid) {
                Navigator.of(context).pop(tableNum);
              } else {
                _showSnackBar(context, 'Invalid table number');
              }
            },
            decoration: const InputDecoration(
              labelText: 'Table Number',
              hintText: 'e.g., M1, R2, H3',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final tableNum = inputTableNum.trim();
                bool isValid = await ApiService.validateTableNumber(tableNum);

                if (isValid) {
                  Navigator.of(context).pop(tableNum);
                } else {
                  _showSnackBar(context, 'Invalid table number');
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class HomeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const HomeButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dynamic button sizing based on screen size
    final buttonSize = MediaQuery.of(context).size.width / 4.5;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: buttonSize,
        height: buttonSize,
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
              size: buttonSize / 2, // Icon size is proportional to the button
            ),
            SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: Colors.brown,
                fontSize: 14, // Slightly reduced font size
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
