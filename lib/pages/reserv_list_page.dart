import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
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
              ['confirm', 'waitinglist'].contains(status);
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
        // First sort by status (confirmed first, then waiting list)
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
                                      buttonAction: (reservation['rstatus'] == 'confirm' || 
                                                    reservation['rstatus'] == 'waitinglist')  // Updated to match database
                                                  ? () => cancelReservation(reservation['reservationId'])
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
      case 'waitinglist':  // Updated to match database
        return 'In Waiting List';
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
      case 'waitinglist':  // Updated to match database
        return Color(0xffe6be8a);
      default:
        return Colors.grey;
    }
  }

  String _getActionButtonText(String status) {
    switch (status.toLowerCase()) {
      case 'confirm':
      case 'waitinglist':  // Updated to match database
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