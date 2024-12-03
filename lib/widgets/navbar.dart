import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      color: Colors.green,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('FoodApp', style: TextStyle(color: Colors.white, fontSize: 20)),
          Row(
            children: [
              TextButton(
                  onPressed: () {},
                  child: const Text('Home',
                      style: TextStyle(color: Colors.white))),
              SizedBox(width: 20),
              TextButton(
                  onPressed: () {},
                  child: const Text('Cart',
                      style: TextStyle(color: Colors.white))),
            ],
          ),
        ],
      ),
    );
  }
}
