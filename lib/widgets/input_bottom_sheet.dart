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

  static void show(BuildContext context,
      {Expense? expenseToEdit, CashFlow? cashFlowToEdit}) {
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

  late TextEditingController _payeeController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;

  ExpenseCategory? _selectedCategory;
  Tag? _selectedTag;

  @override
  void initState() {
    super.initState();

    final editExpense = widget.expenseToEdit;

    _payeeController = TextEditingController(
      text: editExpense?.payee ?? '',
    );
    _amountController = TextEditingController(
      text: editExpense != null ? editExpense.amount.toString() : '',
    );
    _notesController = TextEditingController(
      text: editExpense?.notes ?? '',
    );
    _selectedDate = editExpense?.date ?? DateTime.now();

    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    if (editExpense != null) {
      _selectedCategory = provider.categories.firstWhere(
        (c) => c.id == editExpense.category.id,
        orElse: () => editExpense.category,
      );
      _selectedTag = provider.tags.firstWhere(
        (t) => t.id == editExpense.tag.id,
        orElse: () => editExpense.tag,
      );
    } else {
      if (provider.categories.isNotEmpty) {
        _selectedCategory = provider.categories.first;
      }
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null || _selectedTag == null) return;

    final provider = Provider.of<ExpenseProvider>(context, listen: false);

    final expense = Expense(
      id: widget.expenseToEdit?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      payee: _payeeController.text.trim(),
      amount: double.tryParse(_amountController.text.trim()) ?? 0.0,
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

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = Provider.of<ExpenseProvider>(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF23102C) : Colors.white,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            )
          ],
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Handle bar ──
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white24
                          : Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Title ──
                Text(
                  widget.expenseToEdit != null
                      ? 'Edit Expense'
                      : 'Add Expense',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // ── Payee / Vendor ──
                TextFormField(
                  controller: _payeeController,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Vendor / Payee',
                    prefixIcon:
                        const Icon(Icons.store_mall_directory_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Payee is required'
                      : null,
                ),
                const SizedBox(height: 16),

                // ── Amount ──
                TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 18),
                  decoration: InputDecoration(
                    labelText: 'Amount (${provider.currency})',
                    prefixIcon:
                        const Icon(Icons.attach_money_rounded),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  validator: (v) =>
                      v == null ||
                              double.tryParse(v) == null ||
                              double.parse(v) <= 0
                          ? 'Enter a valid amount'
                          : null,
                ),
                const SizedBox(height: 20),

                // ── Category Picker ──
                const Text(
                  'Category',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: provider.categories.length,
                    itemBuilder: (ctx, i) {
                      final cat = provider.categories[i];
                      final isSel = _selectedCategory?.id == cat.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedCategory = cat),
                          child: AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? theme.colorScheme.primary
                                      .withOpacity(0.15)
                                  : theme.colorScheme.surface,
                              borderRadius:
                                  BorderRadius.circular(20),
                              border: Border.all(
                                color: isSel
                                    ? theme.colorScheme.primary
                                    : Colors.transparent,
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CategoryIconWidget(
                                    categoryName: cat.name,
                                    size: 28),
                                const SizedBox(width: 8),
                                Text(
                                  cat.name,
                                  style: TextStyle(
                                    fontWeight: isSel
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSel
                                        ? theme.colorScheme.primary
                                        : null,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // ── Tag Picker ──
                const Text(
                  'Tag',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: provider.tags.map((tg) {
                    final isSel = _selectedTag?.id == tg.id;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedTag = tg),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel
                              ? theme.colorScheme.secondary
                                  .withOpacity(0.15)
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSel
                                ? theme.colorScheme.secondary
                                : Colors.transparent,
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          tg.name,
                          style: TextStyle(
                            fontWeight: isSel
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSel
                                ? theme.colorScheme.secondary
                                : null,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // ── Notes ──
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'Memo / Notes (optional)',
                    prefixIcon:
                        const Icon(Icons.note_alt_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // ── Date Picker ──
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now()
                          .add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.grey.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_month_rounded,
                                color: theme.colorScheme.primary,
                                size: 20),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat.yMMMd()
                                  .format(_selectedDate),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Icon(Icons.edit_calendar_outlined,
                            color: isDark
                                ? Colors.white38
                                : Colors.black38,
                            size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Submit ──
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                  ),
                  child: Text(
                    widget.expenseToEdit != null
                        ? 'Update Expense'
                        : 'Save Expense',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
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
