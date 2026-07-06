import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tag.dart';
import '../providers/expense_provider.dart';
import '../widgets/add_tag_dialog.dart';

class TagManagementScreen extends StatelessWidget {
  const TagManagementScreen({super.key});

  void _showAddTagDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AddTagDialog(
        onTagAdded: (tagName) {
          final newTag = Tag(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: tagName,
          );
          Provider.of<ExpenseProvider>(context, listen: false).addTag(newTag);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final tags = provider.tags;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Tags'),
      ),
      body: tags.isEmpty
          ? const Center(
              child: Text(
                'No tags available.\nAdd one to group your records!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: tags.length,
              itemBuilder: (context, index) {
                final tag = tags[index];
                return ListTile(
                  leading: const Icon(Icons.label_outline),
                  title: Text(tag.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                    onPressed: () {
                      provider.removeTag(tag.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Tag "${tag.name}" removed.')),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTagDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Tag'),
      ),
    );
  }
}