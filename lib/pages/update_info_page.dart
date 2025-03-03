import 'package:flutter/material.dart';

class UpdateInfoPage extends StatelessWidget {
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
                      'Update Info',
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
              // Form Content
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
                            CircleAvatar(
                              radius: 80,
                              child: Image.asset("../img/images_profile.jpg"),
                            ),
                            SizedBox(height: 20),
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
            height: constraints.maxWidth > 500 ? 80 : 60,
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
