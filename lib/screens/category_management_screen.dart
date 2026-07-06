import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense_category.dart';
import '../providers/expense_provider.dart';
import '../widgets/add_category_dialog.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AddCategoryDialog(
        onCategoryAdded: (categoryName) {
          final newCategory = ExpenseCategory(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: categoryName,
          );
          Provider.of<ExpenseProvider>(context, listen: false).addCategory(newCategory);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final categories = provider.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
      ),
      body: categories.isEmpty
          ? const Center(
              child: Text(
                'No categories available.\nAdd one to get started!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return ListTile(
                  leading: const Icon(Icons.category_outlined),
                  title: Text(category.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                    onPressed: () {
                      // Logic check: alert user if they try to delete a structural default
                      provider.removeCategory(category.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${category.name} removed.')),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategoryDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
    );
  }
}