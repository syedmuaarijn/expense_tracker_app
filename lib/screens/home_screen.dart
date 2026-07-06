import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart'; // Extends collection grouping capabilities
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import 'add_expense_screen.dart';
import 'category_management_screen.dart';
import 'tag_management_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final expenses = provider.expenses;

    // Calculate total spending dynamic amount
    double totalSpending = expenses.fold(0.0, (sum, item) => sum + item.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'categories') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CategoryManagementScreen()),
                );
              } else if (value == 'tags') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TagManagementScreen()),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'categories',
                child: Row(
                  children: [
                    Icon(Icons.category, size: 20),
                    SizedBox(width: 8),
                    Text('Manage Categories'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'tags',
                child: Row(
                  children: [
                    Icon(Icons.local_offer, size: 20),
                    SizedBox(width: 8),
                    Text('Manage Tags'),
                  ],
                ),
              ),
            ],
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.history), text: 'History'),
            Tab(icon: Icon(Icons.pie_chart_outline), text: 'By Category'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Total Summary Card Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Spending',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${totalSpending.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          
          // Tab Content Views Array
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHistoryTab(expenses, provider),
                _buildCategoryTab(expenses),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Tab 1 UI View: Chronological History List
  Widget _buildHistoryTab(List<Expense> expenses, ExpenseProvider provider) {
    if (expenses.isEmpty) {
      return const Center(child: Text('No expenses recorded yet.'));
    }

    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        // Reverse order to show latest items on top
        final expense = expenses[expenses.length - 1 - index];
        return Dismissible(
          key: Key(expense.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right:20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            provider.removeExpense(expense.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Deleted entry for ${expense.payee}')),
            );
          },
          child: ListTile(
            leading: CircleAvatar(
              child: const Icon(Icons.monetization_on_outlined),
            ),
            title: Text(expense.payee, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              '${expense.category.name} • ${expense.tag.name}\n${DateFormat.yMMMd().format(expense.date)}',
            ),
            isThreeLine: true,
            trailing: Text(
              '-\$${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  // Tab 2 UI View: Dynamic Expense Bucket Groupings via package:collection
  Widget _buildCategoryTab(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return const Center(child: Text('No categorical data available.'));
    }

    // Grouping computation matrix
    final Map<String, List<Expense>> groupedExpenses = groupBy(
      expenses,
      (Expense expense) => expense.category.name,
    );

    return ListView(
      children: groupedExpenses.entries.map((entry) {
        final categoryName = entry.key;
        final categoryExpenses = entry.value;
        final categoryTotal = categoryExpenses.fold(0.0, (sum, item) => sum + item.amount);

        return ExpansionTile(
          leading: const Icon(Icons.folder_open),
          title: Text(categoryName, style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: Text(
            '\$${categoryTotal.toStringAsFixed(2)}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          children: categoryExpenses.map((expense) {
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 32),
              title: Text(expense.payee),
              subtitle: Text(DateFormat.yMMMd().format(expense.date)),
              trailing: Text('\$${expense.amount.toStringAsFixed(2)}'),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}