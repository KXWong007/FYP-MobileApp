import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth =
              constraints.maxWidth > 500 ? 500.0 : constraints.maxWidth;

          return Column(
            children: [
              // Top Banner with Title and Back Button
              Stack(
                children: [
                  Container(
                    height: constraints.maxWidth > 500 ? 80 : 60,
                    color: Color(0xffe6be8a),
                    alignment: Alignment.center,
                    child: Text(
                      'Reservation List',
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
                child: Center(
                  child: Container(
                    width: maxWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Flexible(
                          child: _buildNavigationButton(
                              context, 'Upcoming', Colors.blue, 'upcoming'),
                        ),
                        SizedBox(width: 10), // Space between buttons
                        Flexible(
                          child: _buildNavigationButton(
                              context, 'Completed', Colors.green, 'completed'),
                        ),
                        SizedBox(width: 10), // Space between buttons
                        Flexible(
                          child: _buildNavigationButton(
                              context, 'Cancelled', Colors.red, 'cancelled'),
                        ),
                      ],
                    ),
                  ),
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
                          : Center(
                              child: Container(
                                width: maxWidth,
                                child: ListView.builder(
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
                                      status: _getStatusText(
                                          reservation['rstatus']),
                                      reservationId:
                                          reservation['reservationId'],
                                      pax: reservation['pax'].toString(),
                                      area: _getAreaText(reservation['rarea']),
                                      date:
                                          DateFormat('yyyy-MM-dd').format(date),
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
                ),
              ),

              // Bottom Banner
              Container(
                height: constraints.maxWidth > 500 ? 80 : 60,
                color: Color(0xffe6be8a),
              ),
            ],
          );
        },
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
      BuildContext context, String label, Color color, String filter) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          currentFilter = filter;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            currentFilter == filter ? color : color.withOpacity(0.6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.white),
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
            // First row: Status and Reservation ID
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(status),
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    'Reservation ID: $reservationId',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Second row: Icon and Pax
            Row(
              children: [
                Icon(Icons.people, color: Colors.grey),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Pax: $pax',
                    style: TextStyle(fontSize: 16),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),

            // Third row: Icon and Area
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Area: $area',
                    style: TextStyle(fontSize: 16),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),

            // Fourth row: Icon and Date
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Date: $date',
                    style: TextStyle(fontSize: 16),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),

            // Fifth row: Icon and Time
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Time: $time',
                    style: TextStyle(fontSize: 16),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),

            // Sixth row: Reminder text and Button
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Kindly check your email for reservation confirmation.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: buttonColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
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
