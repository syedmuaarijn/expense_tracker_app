
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import '../models/expense.dart';
// import '../models/expense_category.dart';
// import '../models/tag.dart';
// import '../providers/expense_provider.dart';

// class AddExpenseScreen extends StatefulWidget {
//   final Expense? expenseToEdit;
//   const AddExpenseScreen({super.key, this.expenseToEdit});

//   @override
//   State<AddExpenseScreen> createState() => _AddExpenseScreenState();
// }

// class _AddExpenseScreenState extends State<AddExpenseScreen> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _payeeController;
//   late TextEditingController _amountController;
//   late TextEditingController _notesController;
  
//   late DateTime _selectedDate;
//   ExpenseCategory? _selectedCategory;
//   Tag? _selectedTag;

//   @override
//   void initState() {
//     super.initState();
//     final editItem = widget.expenseToEdit;
    
//     _payeeController = TextEditingController(text: editItem?.payee ?? "");
//     _amountController = TextEditingController(text: editItem?.amount.toString() ?? "");
//     _notesController = TextEditingController(text: editItem?.notes ?? "");
//     _selectedDate = editItem?.date ?? DateTime.now();

//     final provider = Provider.of<ExpenseProvider>(context, listen: false);
//     if (editItem != null) {
//       _selectedCategory = provider.categories.firstWhere((c) => c.id == editItem.category.id, orElse: () => editItem.category);
//       _selectedTag = provider.tags.firstWhere((t) => t.id == editItem.tag.id, orElse: () => editItem.tag);
//     } else {
//       if (provider.categories.isNotEmpty) _selectedCategory = provider.categories.first;
//       if (provider.tags.isNotEmpty) _selectedTag = provider.tags.first;
//     }
//   }

//   @override
//   void dispose() {
//     _payeeController.dispose();
//     _amountController.dispose();
//     _notesController.dispose();
//     super.dispose();
//   }

//   void _submitData() {
//     if (!_formKey.currentState!.validate() || _selectedCategory == null || _selectedTag == null) return;

//     final finalExpense = Expense(
//       id: widget.expenseToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
//       payee: _payeeController.text.trim(),
//       amount: double.parse(_amountController.text.trim()),
//       notes: _notesController.text.trim(),
//       date: _selectedDate,
//       category: _selectedCategory!,
//       tag: _selectedTag!,
//     );

//     final provider = Provider.of<ExpenseProvider>(context, listen: false);
//     if (widget.expenseToEdit != null) {
//       provider.updateExpense(finalExpense);
//     } else {
//       provider.addExpense(finalExpense);
//     }
//     Navigator.of(context).pop();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<ExpenseProvider>(context);

//     return Scaffold(
//       appBar: AppBar(title: Text(widget.expenseToEdit != null ? 'Edit Transaction' : 'New Transaction')),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               TextFormField(
//                 controller: _payeeController,
//                 decoration: InputDecoration(labelText: 'Vendor / Payee Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
//                 validator: (v) => v == null || v.trim().isEmpty ? 'Field required' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _amountController,
//                 decoration: InputDecoration(labelText: 'Amount (\$)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
//                 keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                 validator: (v) => v == null || double.tryParse(v) == null || double.parse(v) <= 0 ? 'Enter valid asset metrics' : null,
//               ),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<ExpenseCategory>(
//                 value: _selectedCategory,
//                 decoration: InputDecoration(labelText: 'Category Workspace', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
//                 items: provider.categories.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
//                 onChanged: (v) => setState(() => _selectedCategory = v),
//               ),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<Tag>(
//                 value: _selectedTag,
//                 decoration: InputDecoration(labelText: 'Organizational Tag', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
//                 items: provider.tags.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
//                 onChanged: (v) => setState(() => _selectedTag = v),
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _notesController,
//                 decoration: InputDecoration(labelText: 'Internal Memo Notes', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
//                 maxLines: 2,
//               ),
//               const SizedBox(height: 16),
//               ListTile(
//                 title: Text('Execution Date: ${DateFormat.yMMMd().format(_selectedDate)}'),
//                 trailing: const Icon(Icons.calendar_month_outlined),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.withOpacity(0.4))),
//                 onTap: () async {
//                   final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now());
//                   if (picked != null) setState(() => _selectedDate = picked);
//                 },
//               ),
//               const SizedBox(height: 32),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
//                 onPressed: _submitData,
//                 child: Text(widget.expenseToEdit != null ? 'Commit Variations' : 'Post Transaction', style: const TextStyle(fontWeight: FontWeight.bold)),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/tag.dart';
import '../providers/expense_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expenseToEdit;
  const AddExpenseScreen({super.key, this.expenseToEdit});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _payeeController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  
  late DateTime _selectedDate;
  ExpenseCategory? _selectedCategory;
  Tag? _selectedTag;

  @override
  void initState() {
    super.initState();
    final editItem = widget.expenseToEdit;
    
    _payeeController = TextEditingController(text: editItem?.payee ?? "");
    _amountController = TextEditingController(text: editItem?.amount.toString() ?? "");
    _notesController = TextEditingController(text: editItem?.notes ?? "");
    _selectedDate = editItem?.date ?? DateTime.now();

    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    if (editItem != null) {
      _selectedCategory = provider.categories.firstWhere((c) => c.id == editItem.category.id, orElse: () => editItem.category);
      _selectedTag = provider.tags.firstWhere((t) => t.id == editItem.tag.id, orElse: () => editItem.tag);
    } else {
      if (provider.categories.isNotEmpty) _selectedCategory = provider.categories.first;
      if (provider.tags.isNotEmpty) _selectedTag = provider.tags.first;
    }
  }

  @override
  void dispose() {
    _payeeController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitData() {
    if (!_formKey.currentState!.validate() || _selectedCategory == null || _selectedTag == null) return;

    final finalExpense = Expense(
      id: widget.expenseToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      payee: _payeeController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      notes: _notesController.text.trim(),
      date: _selectedDate,
      category: _selectedCategory!,
      tag: _selectedTag!,
    );

    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    if (widget.expenseToEdit != null) {
      provider.updateExpense(finalExpense);
    } else {
      provider.addExpense(finalExpense);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.expenseToEdit != null ? 'Edit Expense Details' : 'Add New Expense')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _payeeController,
                decoration: InputDecoration(labelText: 'Where did you spend? (Shop/Person)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                validator: (v) => v == null || v.trim().isEmpty ? 'Please fill this part' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'How much did you spend? (${provider.currency})', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v == null || double.tryParse(v) == null || double.parse(v) <= 0 ? 'Please enter a correct number' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ExpenseCategory>(
                value: _selectedCategory,
                decoration: InputDecoration(labelText: 'Choose Category', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: provider.categories.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Tag>(
                value: _selectedTag,
                decoration: InputDecoration(labelText: 'Choose Tag (e.g., Need / Want)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: provider.tags.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
                onChanged: (v) => setState(() => _selectedTag = v),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(labelText: 'Extra Notes (Optional)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text('Date: ${DateFormat.yMMMd().format(_selectedDate)}'),
                trailing: const Icon(Icons.calendar_month_outlined),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.withOpacity(0.4))),
                onTap: () async {
                  final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now());
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                  minimumSize: const Size.fromHeight(54), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _submitData,
                child: Text(widget.expenseToEdit != null ? 'Save Changes' : 'Add This Expense', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              )
            ],
          ),
        ),
      ),
    );
  }
}