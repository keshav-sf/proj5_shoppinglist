import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:proj5_shoppinglist/categories_screen.dart';
import 'package:proj5_shoppinglist/dummy_data.dart';
import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formkey = GlobalKey<FormState>();
  var enteredName = "";
  var enteredQuantity = 1;
  var _categorySelected = categories[Categories.vegetables]!;
  var _issending = false;

  void _saveItem() async {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
      setState(() {
        _issending = true;
      });
      final url = Uri.https('proj5-shoppinglist-default-rtdb.firebaseio.com',
          'shopping-list.json');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'name': enteredName,
            'quantity': enteredQuantity,
            'category': _categorySelected.title
          },
        ),
      );
      final Map<String, dynamic> resData = json.decode(response.body);
      // print(response.body);
      // print(response.statusCode);

      Navigator.of(context).pop(GroceryItem(
          id: resData['name'],
          name: enteredName,
          quantity: enteredQuantity,
          category: _categorySelected));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
            key: _formkey,
            child: Column(
              children: [
                TextFormField(
                  maxLength: 50,
                  decoration: const InputDecoration(
                    label: Text('Name'),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length <= 1 ||
                        value.trim().length > 50) {
                      return 'Must be between 1 and 50 characters.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    enteredName = value!;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          label: Text('Quantity'),
                        ),
                        initialValue: '1',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0) {
                            return 'Must be a valid positive Number.';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          enteredQuantity = int.parse(newValue!);
                        },
                      ),
                    ),
                    Expanded(
                      child: DropdownButtonFormField(
                        value: _categorySelected,
                        items: [
                          for (final i in categories.entries)
                            DropdownMenuItem(
                                value: i.value,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      color: i.value.color,
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    Text(i.value.title),
                                  ],
                                ))
                        ],
                        onChanged: (value) {
                          setState(() {
                            _categorySelected = value!;
                          });
                        },
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () {
                          _issending ? null : _formkey.currentState!.reset();
                        },
                        child: const Text("Reset")),
                    ElevatedButton(
                        onPressed: _issending ? null : _saveItem,
                        child: _issending
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator())
                            : const Text("Add Item"))
                  ],
                )
              ],
            )),
      ),
    );
  }
}
