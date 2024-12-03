import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/menu.dart';

class MenuService extends ChangeNotifier {
  List<Menu> _menuItems = [];
  List<Menu> get menuItems => _menuItems;
  bool isLoading = false;

  // Search query variable
  String searchQuery = '';

  // Dropdown lists for Areas, Categories, Subcategories, and Cuisines
  List<String> availableAreas = [];
  List<String> categories = [];
  List<String> subcategories = [];
  List<String> cuisines = [];

  List<String> get uniqueAreas {
    Set<String> areas = {'All'}; // Default option "All"
    for (var menu in _menuItems) {
      areas.addAll(menu
          .availableAreas); // Assuming availableAreas is a list in the Menu model
    }
    return areas.toList()..sort();
  }

  // Filter menu items by selected area
  List<Menu> getMenuItemsByArea(String selectedArea) {
    List<Menu> filteredMenuItems;

    // Filter by area if not 'All'
    if (selectedArea == 'All') {
      filteredMenuItems = _menuItems;
    } else {
      filteredMenuItems = _menuItems
          .where((menu) => menu.availableAreas.contains(selectedArea))
          .toList();
    }

    return filteredMenuItems;
  }

  // Fetch Menu items and dropdown options
  Future<void> fetchMenuItemsAndOptions() async {
    isLoading = true;
    notifyListeners();

    try {
      // Fetch Menu items
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/customer/menu'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('Menu Response status: ${response.statusCode}');
      print('Menu Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _menuItems = List<Menu>.from(data.map((json) => Menu.fromJson(json)));

        // Fetch additional dropdown data for areas, categories, subcategories, and cuisines
        final optionsResponse = await http.get(
          Uri.parse('http://127.0.0.1:8000/api/customer/menu-options'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        );

        print('Options Response status: ${optionsResponse.statusCode}');
        print('Options Response body: ${optionsResponse.body}');

        if (optionsResponse.statusCode == 200) {
          final optionsData = json.decode(optionsResponse.body);

          availableAreas =
              List<String>.from(optionsData['availableAreas'] ?? []);
          categories = List<String>.from(optionsData['categories'] ?? []);
          subcategories = List<String>.from(optionsData['subcategories'] ?? []);
          cuisines = List<String>.from(optionsData['cuisines'] ?? []);
        } else {
          print(
              'Failed to load options. Status code: ${optionsResponse.statusCode}');
        }

        notifyListeners();
      } else {
        print('Failed to load menu items. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching menu items: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
