import 'package:flutter/material.dart';

// The model: a name and a bought status
class Item {
  Item(this.name);

  final String name;
  bool bought = false;
}

void main() {
  runApp(const ShoppingApp());
}

class ShoppingApp extends StatelessWidget {
  const ShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.green),
      home: const HomeScreen(title: 'Shopping List'),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // The data: a list of Item objects
  final items = [Item('Milk'), Item('Bread'), Item('Rice')];

  // What is typed in the field
  final controller = TextEditingController();

  // The rules for adding items
  void addItem() {
    final text = controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Type an item first')),
      );
      return;
    }
    setState(() {
      items.add(Item(text));
    });
    controller.clear();
  }

  // Clean-up when the screen closes
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Count how many items are left (not bought)
    final leftCount = items.where((item) => !item.bought).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title} ($leftCount left)'),
        actions: [
          // Button in the top bar to remove all bought items
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              setState(() {
                items.removeWhere((item) => item.bought);
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // TextField and Add button row
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    onSubmitted: (_) => addItem(), // Enter key adds item
                    decoration: const InputDecoration(
                      hintText: 'Type an item...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: addItem,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          // The scrolling list
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('Your list is empty'))
                : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  leading: Icon(
                    item.bought ? Icons.check_circle : Icons.shopping_basket,
                    color: item.bought ? Colors.green : null,
                  ),
                  title: Text(
                    item.name,
                    style: TextStyle(
                      decoration: item.bought
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: item.bought ? Colors.grey : null,
                    ),
                  ),
                  // Tapping an item marks it as bought / un-marks it
                  onTap: () {
                    setState(() {
                      item.bought = !item.bought;
                    });
                  },
                  // Bin button to delete row
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        items.removeAt(index);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${item.name} removed')),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}