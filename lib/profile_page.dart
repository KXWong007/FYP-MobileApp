import 'package:flutter/material.dart';
import 'update_info_page.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Curved Header
          Stack(
            children: [
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Color(0xffe6be8a),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
              ),
              // Back Button
              Positioned(
                top: 30,
                left: 10,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, size: 30, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context); // Go back to the previous screen
                  },
                ),
              ),
              // Profile Picture and Username
              Positioned(
                top: 40,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Ordinary Customer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    CircleAvatar(
                      radius: 80,
                      backgroundImage: AssetImage("../img/images_profile.jpg"),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Ordinary',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Spacer
          SizedBox(height: 40),

          // Profile Information Section
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    buildProfileField('E-mail', 'ordinary@gmail.com'),
                    buildProfileField('Phone Number', '123-456-7890'),
                    buildProfileField('Address', '123 Main St, City, Country'),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to update info page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateInfoPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Color(0xffe6be8a), // Match button color to theme
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // Bottom Footer
      bottomNavigationBar: Container(
        height: 50,
        color: Color(0xffe6be8a), // Bottom bar with matching color
        width: double.infinity,
      ),
    );
  }

  Widget buildProfileField(String label, String value) {
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
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
