import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'product_detail_page.dart';
import '../services/menu_service.dart';
import 'cart_page.dart';

class MenuPage extends StatefulWidget {
  final String tableNum;
  final String customerId;

  const MenuPage({required this.tableNum, required this.customerId});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String selectedArea = 'All';
  String selectedCategory = 'All';
  String selectedSubcategory = 'All';
  String selectedCuisine = 'All';
  String searchQuery = '';
  bool isListView = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<MenuService>(context, listen: false)
        .fetchMenuItemsAndOptions());
  }

  // Refactored dropdown widget to avoid repetitive code
  Widget buildDropdown({
    required String value,
    required Function(String?) onChanged,
    required List<String> items,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Consumer<MenuService>(
            builder: (context, menuService, child) {
              if (menuService.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // Filter the menu items
              final filteredMenuItems = menuService
                  .getMenuItemsByArea(selectedArea)
                  .where((menuItem) {
                bool matchesSearch = menuItem.dishName
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase());
                bool matchesCategory = selectedCategory == 'All' ||
                    menuItem.category == selectedCategory;
                bool matchesSubcategory = selectedSubcategory == 'All' ||
                    menuItem.subcategory == selectedSubcategory;
                bool matchesCuisine = selectedCuisine == 'All' ||
                    menuItem.cuisine == selectedCuisine;

                return matchesSearch &&
                    matchesCategory &&
                    matchesSubcategory &&
                    matchesCuisine;
              }).toList();

              // Sort items by availability
              filteredMenuItems.sort((a, b) {
                if (a.availability && !b.availability) {
                  return -1;
                } else if (!a.availability && b.availability) {
                  return 1;
                }
                return 0;
              });

              return Column(
                children: [
                  // Top Banner with Title and Back Button
                  Stack(
                    children: [
                      Container(
                        height: 60,
                        color: Color(0xffe6be8a),
                      ),
                      Positioned(
                        left: 10,
                        top: 10,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.pop(
                                context); // Navigate back to Main Menu
                          },
                        ),
                      ),
                    ],
                  ),

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      onChanged: (value) => setState(() => searchQuery = value),
                      decoration: const InputDecoration(
                        labelText: 'Search',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),

                  // Dropdown Filters: Area, Category, Subcategory, Cuisine
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Wrap(
                      spacing: 16.0, // Horizontal space between filters
                      runSpacing:
                          16.0, // Vertical space between rows if filters wrap
                      children: [
                        buildDropdown(
                          label: "Areas:",
                          value: selectedArea,
                          onChanged: (newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedArea = newValue;
                              });
                            }
                          },
                          items: [
                            'All',
                            'Main Hall',
                            'Badger Bar',
                            'Hornbill Restaurant',
                            'Rajah Room'
                          ],
                        ),
                        buildDropdown(
                          label: "Categories:",
                          value: selectedCategory,
                          onChanged: (newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedCategory = newValue;
                              });
                            }
                          },
                          items: ['All'] + menuService.categories,
                        ),
                        buildDropdown(
                          label: "Subcategories:",
                          value: selectedSubcategory,
                          onChanged: (newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedSubcategory = newValue;
                              });
                            }
                          },
                          items: ['All'] + menuService.subcategories,
                        ),
                        buildDropdown(
                          label: "Cuisines:",
                          value: selectedCuisine,
                          onChanged: (newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedCuisine = newValue;
                              });
                            }
                          },
                          items: ['All'] + menuService.cuisines,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Toggle View Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Menu Items",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: Icon(isListView ? Icons.grid_view : Icons.list),
                          onPressed: () =>
                              setState(() => isListView = !isListView),
                        ),
                      ],
                    ),
                  ),

                  // Menu Items
                  Expanded(
                    child: filteredMenuItems.isEmpty
                        ? const Center(
                            child: Text('No menu items available'),
                          )
                        : (isListView
                            ? ListView.builder(
                                itemCount: filteredMenuItems.length,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                itemBuilder: (context, index) {
                                  final menu = filteredMenuItems[index];
                                  return buildListTile(menu);
                                },
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.all(16),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 3 / 4,
                                ),
                                itemCount: filteredMenuItems.length,
                                itemBuilder: (context, index) {
                                  final menu = filteredMenuItems[index];
                                  return buildGridTile(menu);
                                },
                              )),
                  ),
                ],
              );
            },
          ),
        ),

        // Check Cart Button
        bottomNavigationBar: Container(
          height: 60,
          color: const Color(0xffe6be8a),
          child: Center(
              child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartPage(
                    tableNum: widget.tableNum,
                    customerId: widget.customerId,
                  ),
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
            child: const Text(
              'Check Cart',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xffe6be8a),
              ),
            ),
          )),
        ));
  }

  // Utility for building ListTile
  Widget buildListTile(menu) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: menu.availability ? Colors.white : Colors.grey[300],
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProductDetailPage(menu: menu)),
        ),
        child: Row(
          children: [
            buildImageContainer(menu.image),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(menu.dishName,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(menu.description ?? '',
                        style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('RM${menu.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Utility for building GridTile
  Widget buildGridTile(menu) {
    return Card(
      color: menu.availability ? Colors.white : Colors.grey[300],
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProductDetailPage(menu: menu)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: buildImageContainer(menu.image)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(menu.dishName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(menu.description ?? '',
                      style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('RM${menu.price.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// Utility for image container
  Widget buildImageContainer(String? imageUrl) {
    // Modify the image URL to replace 'menu-images/' with 'img/menu-images/'
    final modifiedImageUrl = imageUrl != null && imageUrl.isNotEmpty
        ? imageUrl.replaceFirst('menu-images/', '../img/menu-images/')
        : null;

    return Container(
      width: 100, // Set the width of the container
      height:
          100, // Set the height of the container to the same value as width for square
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: modifiedImageUrl != null
          ? Image.network(
              modifiedImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error_outline), // Error icon if image fails
            )
          : const Icon(
              Icons.fastfood, // Default icon if no image URL is provided
              size: 50, // Adjust icon size
            ),
    );
  }
}
