import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:proj5_shoppinglist/dummy_data.dart';
import 'package:proj5_shoppinglist/new_item.dart';
import 'package:http/http.dart' as http;

const categories = {
  Categories.vegetables: Category(
    'Vegetables',
    Color.fromARGB(255, 0, 255, 128),
  ),
  Categories.fruit: Category(
    'Fruit',
    Color.fromARGB(255, 145, 255, 0),
  ),
  Categories.meat: Category(
    'Meat',
    Color.fromARGB(255, 255, 102, 0),
  ),
  Categories.dairy: Category(
    'Dairy',
    Color.fromARGB(255, 0, 208, 255),
  ),
  Categories.carbs: Category(
    'Carbs',
    Color.fromARGB(255, 0, 60, 255),
  ),
  Categories.sweets: Category(
    'Sweets',
    Color.fromARGB(255, 255, 149, 0),
  ),
  Categories.spices: Category(
    'Spices',
    Color.fromARGB(255, 255, 187, 0),
  ),
  Categories.convenience: Category(
    'Convenience',
    Color.fromARGB(255, 191, 0, 255),
  ),
  Categories.hygiene: Category(
    'Hygiene',
    Color.fromARGB(255, 149, 0, 255),
  ),
  Categories.other: Category(
    'Other',
    Color.fromARGB(255, 0, 225, 255),
  ),
};

enum Categories {
  vegetables,
  fruit,
  meat,
  dairy,
  carbs,
  sweets,
  spices,
  convenience,
  hygiene,
  other,
}

class Category {
  const Category(this.title, this.color);
  final String title;
  final Color color;
}

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  var _isloading = true;
  String? errormsg;

  List<GroceryItem> _groceryItems = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  // Load Item in List
  void _loadItems() async {
    final url = Uri.https(
        'proj5-shoppinglist-default-rtdb.firebaseio.com', 'shopping-list.json');
    try {
      final response = await http.get(url);

      if (response.statusCode >= 400) {
        setState(() {
          errormsg = "Failed to fetch data. Please try again!";
        });
      }
      if (response.body == 'null') {
        setState(() {
          _isloading = false;
        });
        return;
      }

      final Map<String, dynamic> listdata = json.decode(response.body);
      final List<GroceryItem> loadedItems = [];

      for (final item in listdata.entries) {
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.title == item.value['category'])
            .value;
        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }
      setState(() {
        _groceryItems = loadedItems;
        _isloading = false;
      });
    } catch (error) {
      setState(() {
        errormsg = "Failed to fetch data. Please try again!";
      });
    }
  }

  // Add Item in List
  void _addItem() async {
    final newItem =
        await Navigator.of(context).push<GroceryItem>(MaterialPageRoute(
      builder: (ctx) => const NewItem(),
    ));
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  // Delete Item in List
  void removeItem(GroceryItem item) {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Alert"),
          content: const Text("Do you really want to delete this item!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _groceryItems.insert(index, item);
                });
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () async {
                final url = Uri.https(
                    'proj5-shoppinglist-default-rtdb.firebaseio.com',
                    'shopping-list/${item.id}.json');
                final response = await http.delete(url);
                Navigator.pop(context);
                if (response.statusCode >= 400) {
                  setState(() {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Note"),
                          content: const Text(
                              "Do to some technical issue you cannot delete this item!"),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Ok"))
                          ],
                        );
                      },
                    );
                    _groceryItems.insert(index, item);
                  });
                }
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Grocery"),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: errormsg != null
          ? Center(
              child: Text(
                errormsg!,
              ),
            )
          : _isloading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _groceryItems.isEmpty
                  ? const Center(
                      child: Text(
                        "No items added yet.",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _groceryItems.length,
                      itemBuilder: (ctx, index) => Dismissible(
                        onDismissed: (direction) {
                          removeItem(_groceryItems[index]);
                        },
                        key: ValueKey(_groceryItems[index].id),
                        child: ListTile(
                          title: Text(
                            _groceryItems[index].name,
                          ),
                          leading: Container(
                            width: 24,
                            height: 24,
                            color: _groceryItems[index].category.color,
                          ),
                          trailing: Text(
                            _groceryItems[index].quantity.toString(),
                          ),
                        ),
                      ),
                    ),
    );
  }
}
