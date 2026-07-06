import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/tag.dart';
import '../providers/expense_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _payeeController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  ExpenseCategory? _selectedCategory;
  Tag? _selectedTag;

  @override
  void initState() {
    super.initState();
    // Pre-select the first available categories and tags from provider data state
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    if (provider.categories.isNotEmpty) _selectedCategory = provider.categories.first;
    if (provider.tags.isNotEmpty) _selectedTag = provider.tags.first;
  }

  @override
  void dispose() {
    _payeeController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Date picker selection function
  Future<void> _presentDatePicker() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // The save execution pipeline
  void _submitData() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null || _selectedTag == null) return;

    final enteredPayee = _payeeController.text.trim();
    final enteredAmount = double.parse(_amountController.text.trim());
    final enteredNotes = _notesController.text.trim();

    // Instantiate a structured model payload
    final newExpense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Unique ID implementation
      payee: enteredPayee,
      amount: enteredAmount,
      notes: enteredNotes,
      date: _selectedDate,
      category: _selectedCategory!,
      tag: _selectedTag!,
    );

    // Commit to app state and disk storage via provider
    Provider.of<ExpenseProvider>(context, listen: false).addExpense(newExpense);
    
    // Smoothly exit back to previous panel view state
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Payee input
              TextFormField(
                controller: _payeeController,
                decoration: const InputDecoration(labelText: 'Payee / Store Name'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a payee.' : null,
              ),
              const SizedBox(height: 12),

              // Amount input
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount (USD)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Please enter an amount.';
                  if (double.tryParse(value) == null) return 'Please enter a valid number.';
                  if (double.parse(value) <= 0) return 'Amount must be greater than zero.';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Notes input
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes / Description'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Category Selection Dropdown
              DropdownButtonFormField<ExpenseCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: provider.categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
              ),
              const SizedBox(height: 12),

              // Tag Selection Dropdown
              DropdownButtonFormField<Tag>(
                value: _selectedTag,
                decoration: const InputDecoration(labelText: 'Tag'),
                items: provider.tags.map((tag) {
                  return DropdownMenuItem(
                    value: tag,
                    child: Text(tag.name),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedTag = value),
              ),
              const SizedBox(height: 20),

              // Date Selection Row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Transaction Date: ${DateFormat.yMMMd().format(_selectedDate)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: _presentDatePicker,
                    child: const Text('Choose Date', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Action Buttons
              ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Save Expense', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}