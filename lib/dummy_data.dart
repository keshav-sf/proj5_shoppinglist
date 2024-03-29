import 'package:proj5_shoppinglist/categories_screen.dart';

// final groceryItems = [
//   GroceryItem(
//       id: 'a',
//       name: 'Milk',
//       quantity: 1,
//       category: categories[Categories.dairy]!),
//   GroceryItem(
//       id: 'b',
//       name: 'Bananas',
//       quantity: 5,
//       category: categories[Categories.fruit]!),
//   GroceryItem(
//       id: 'c',
//       name: 'Beef Steak',
//       quantity: 1,
//       category: categories[Categories.meat]!),
// ];

class GroceryItem {
  const GroceryItem(
      {required this.id,
      required this.name,
      required this.quantity,
      required this.category});
  final String id;
  final String name;
  final int quantity;
  final Category category;
}
