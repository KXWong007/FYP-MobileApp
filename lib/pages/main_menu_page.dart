import 'package:flutter/material.dart';
import '../services/api_service.dart';
import './menu_page.dart';
import './orders_page.dart';
import './profile_page.dart';
import './table_reserv_page.dart';
import './reserv_list_page.dart';
import '../main.dart';

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