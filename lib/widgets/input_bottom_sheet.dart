import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/tag.dart';
import '../models/cash_flow.dart';
import 'category_icons.dart';

class InputBottomSheet extends StatefulWidget {
  final Expense? expenseToEdit;
  final CashFlow? cashFlowToEdit;

  const InputBottomSheet({
    super.key,
    this.expenseToEdit,
    this.cashFlowToEdit,
  });

  static void show(BuildContext context, {Expense? expenseToEdit, CashFlow? cashFlowToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InputBottomSheet(
        expenseToEdit: expenseToEdit,
        cashFlowToEdit: cashFlowToEdit,
      ),
    );
  }

  @override
  State<InputBottomSheet> createState() => _InputBottomSheetState();
}

class _InputBottomSheetState extends State<InputBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  
  // Tab control
  bool _isExpenseTab = true;

  // Form Fields controllers
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;

  // Expense Specific
  ExpenseCategory? _selectedCategory;
  Tag? _selectedTag;

  // Cash Flow Specific
  CashFlowType _selectedCFType = CashFlowType.toPay;
  CashFlowPeriod _selectedCFPeriod = CashFlowPeriod.monthly;

  @override
  void initState() {
    super.initState();
    
    if (widget.cashFlowToEdit != null) {
      _isExpenseTab = false;
    }

    final editExpense = widget.expenseToEdit;
    final editCashFlow = widget.cashFlowToEdit;

    _titleController = TextEditingController(
      text: editExpense?.payee ?? editCashFlow?.title ?? "",
    );
    _amountController = TextEditingController(
      text: editExpense?.amount.toString() ?? editCashFlow?.amount.toString() ?? "",
    );
    _notesController = TextEditingController(
      text: editExpense?.notes ?? "",
    );
    _selectedDate = editExpense?.date ?? editCashFlow?.date ?? DateTime.now();

    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    if (editExpense != null) {
      _selectedCategory = provider.categories.firstWhere((c) => c.id == editExpense.category.id, orElse: () => editExpense.category);
      _selectedTag = provider.tags.firstWhere((t) => t.id == editExpense.tag.id, orElse: () => editExpense.tag);
    } else {
      if (provider.categories.isNotEmpty) _selectedCategory = provider.categories.first;
      if (provider.tags.isNotEmpty) _selectedTag = provider.tags.first;
    }

    if (editCashFlow != null) {
      _selectedCFType = editCashFlow.type;
      _selectedCFPeriod = editCashFlow.period;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final provider = Provider.of<ExpenseProvider>(context, listen: false);

    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    if (_isExpenseTab) {
      if (_selectedCategory == null || _selectedTag == null) return;
      final expense = Expense(
        id: widget.expenseToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        payee: title,
        amount: amount,
        notes: _notesController.text.trim(),
        date: _selectedDate,
        category: _selectedCategory!,
        tag: _selectedTag!,
      );

      if (widget.expenseToEdit != null) {
        provider.updateExpense(expense);
      } else {
        provider.addExpense(expense);
      }
    } else {
      final cashFlow = CashFlow(
        id: widget.cashFlowToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        amount: amount,
        type: _selectedCFType,
        period: _selectedCFPeriod,
        date: _selectedDate,
      );

      if (widget.cashFlowToEdit != null) {
        provider.updateCashFlow(cashFlow);
      } else {
        provider.addCashFlow(cashFlow);
      }
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ExpenseProvider>(context);
    
    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets,
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: Container(
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark 
              ? const Color(0xFF23102C) 
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top handle bar
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark 
                          ? Colors.white24 
                          : Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Toggle tabs if not editing
                if (widget.expenseToEdit == null && widget.cashFlowToEdit == null)
                  Container(
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark 
                          ? const Color(0xFF381F4A) 
                          : const Color(0xFFF1EDF5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isExpenseTab = true),
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isExpenseTab 
                                    ? theme.colorScheme.primary 
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Add Expense',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _isExpenseTab 
                                      ? Colors.white 
                                      : (theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isExpenseTab = false),
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isExpenseTab 
                                    ? theme.colorScheme.primary 
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Add Cashflow',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: !_isExpenseTab 
                                      ? Colors.white 
                                      : (theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    widget.expenseToEdit != null ? 'Edit Transaction' : 'Edit Cashflow Entry',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),

                const SizedBox(height: 24),

                // Title input field
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: _isExpenseTab ? 'Vendor / Payee' : 'Person Name / Reason',
                    prefixIcon: const Icon(Icons.edit_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),

                // Amount input field
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    labelText: 'Amount (\$)',
                    prefixIcon: const Icon(Icons.attach_money_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  validator: (v) => v == null || double.tryParse(v) == null || double.parse(v) <= 0 
                      ? 'Enter a valid amount' 
                      : null,
                ),
                const SizedBox(height: 20),

                // Expense Tab Options
                if (_isExpenseTab) ...[
                  // Category Selection Header
                  const Text(
                    'Category',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 55,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: provider.categories.length,
                      itemBuilder: (ctx, i) {
                        final cat = provider.categories[i];
                        final isSel = _selectedCategory?.id == cat.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: ChoiceChip(
                            avatar: CategoryIconWidget(categoryName: cat.name, size: 24),
                            label: Text(cat.name),
                            selected: isSel,
                            onSelected: (val) {
                              if (val) setState(() => _selectedCategory = cat);
                            },
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tag selection
                  const Text(
                    'Tag',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: provider.tags.map((tg) {
                      final isSel = _selectedTag?.id == tg.id;
                      return ChoiceChip(
                        label: Text(tg.name),
                        selected: isSel,
                        onSelected: (val) {
                          if (val) setState(() => _selectedTag = tg);
                        },
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Notes Text field
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Memo / Notes',
                      prefixIcon: const Icon(Icons.note_alt_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  // Cash Flow Options
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<CashFlowType>(
                          value: _selectedCFType,
                          decoration: InputDecoration(
                            labelText: 'Type',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          items: const [
                            DropdownMenuItem(value: CashFlowType.toPay, child: Text('I have to Pay')),
                            DropdownMenuItem(value: CashFlowType.toReceive, child: Text('I will Get Back')),
                          ],
                          onChanged: (v) => setState(() => _selectedCFType = v!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<CashFlowPeriod>(
                          value: _selectedCFPeriod,
                          decoration: InputDecoration(
                            labelText: 'Frequency',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          items: const [
                            DropdownMenuItem(value: CashFlowPeriod.monthly, child: Text('Monthly')),
                            DropdownMenuItem(value: CashFlowPeriod.annually, child: Text('Annually')),
                          ],
                          onChanged: (v) => setState(() => _selectedCFPeriod = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],

                // Date Picker Action list tile
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context, 
                      initialDate: _selectedDate, 
                      firstDate: DateTime(2020), 
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Transaction Date: ${DateFormat.yMMMd().format(_selectedDate)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Icon(Icons.calendar_month_rounded, color: theme.colorScheme.primary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Action button
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                  ),
                  child: Text(
                    widget.expenseToEdit != null || widget.cashFlowToEdit != null 
                        ? 'Commit Changes' 
                        : 'Post Entry',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
