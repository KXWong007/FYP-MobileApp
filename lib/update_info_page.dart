import 'package:flutter/material.dart';

class UpdateInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: 600), // Width constraint for a more compact layout
            child: Stack(
              children: [
                // Header and Back Button
                Column(
                  children: [
                    Stack(
                      children: [
                        // Curved Header
                        Container(
                          height: 250,
                          decoration: BoxDecoration(
                            color: Color(0xffe6be8a),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(50),
                              bottomRight: Radius.circular(50),
                            ),
                          ),
                        ),
                        // Back Button Positioned at the top left
                        Positioned(
                          top: 20,
                          left: 20,
                          child: IconButton(
                            icon: Icon(Icons.arrow_back,
                                size: 30, color: Colors.white),
                            onPressed: () {
                              Navigator.pop(
                                  context); // Go back to the previous screen
                            },
                          ),
                        ),
                        // Customer Label Positioned below the header
                        Positioned(
                          top: 50,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Text(
                              'Ordinary Customer',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        // Profile Picture Positioned at the center below the title
                        Positioned(
                          top: 110,
                          left: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 80,
                            child: Image.asset("../img/images_profile.jpg"),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    // Form Fields for Updating Info
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildProfileField('E-mail', 'ordinary@gmail.com'),
                          buildProfileField('Phone Number', '123-456-7890'),
                          buildProfileField(
                              'Address', '123 Main St, City, Country'),
                          buildProfileField('Password', 'Enter new password',
                              obscureText: true),
                          buildProfileField(
                              'Confirm Password', 'Re-enter new password',
                              obscureText: true),
                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
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
            onPressed: () {
              // After updating successfully, show a message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Updated Successfully'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Color(0xffe6be8a),
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            child: Text(
              'Update Info',
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

  Widget buildProfileField(String label, String hint,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
