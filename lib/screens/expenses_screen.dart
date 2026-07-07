import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../widgets/category_icons.dart';
import '../widgets/input_bottom_sheet.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  DateTime _focusedMonth = DateTime.now();
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedExpenseId;
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Filter by month
    List<Expense> monthlyExpenses = provider.expenses.where((e) {
      return e.date.year == _focusedMonth.year &&
          e.date.month == _focusedMonth.month;
    }).toList();

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      monthlyExpenses = monthlyExpenses.where((e) {
        return e.payee.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            e.category.name
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            e.notes.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by category chip
    if (_selectedCategory != null) {
      monthlyExpenses = monthlyExpenses
          .where((e) => e.category.name == _selectedCategory)
          .toList();
    }

    // Sort newest first
    monthlyExpenses.sort((a, b) => b.date.compareTo(a.date));

    final totalSpent =
        monthlyExpenses.fold(0.0, (sum, e) => sum + e.amount);

    // Get unique categories for chips
    final allMonthlyExpenses = provider.expenses.where((e) {
      return e.date.year == _focusedMonth.year &&
          e.date.month == _focusedMonth.month;
    }).toList();
    final categories = allMonthlyExpenses
        .map((e) => e.category.name)
        .toSet()
        .toList();

    // Group expenses by date
    Map<String, List<Expense>> grouped = {};
    for (var exp in monthlyExpenses) {
      final now = DateTime.now();
      String dateStr;
      if (exp.date.year == now.year &&
          exp.date.month == now.month &&
          exp.date.day == now.day) {
        dateStr = 'Today';
      } else if (exp.date.year == now.year &&
          exp.date.month == now.month &&
          exp.date.day == now.day - 1) {
        dateStr = 'Yesterday';
      } else {
        dateStr = DateFormat('dd MMMM').format(exp.date);
      }
      grouped.putIfAbsent(dateStr, () => []).add(exp);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => setState(() => _selectedExpenseId = null),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    if (!_isSearching) ...[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Expenses',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              DateFormat('MMMM yyyy').format(_focusedMonth),
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.search, size: 20),
                        ),
                        onPressed: () =>
                            setState(() => _isSearching = true),
                      ),
                    ] else ...[
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Search expenses...',
                            border: InputBorder.none,
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                                _isSearching = false;
                              }),
                            ),
                          ),
                          onChanged: (v) =>
                              setState(() => _searchQuery = v),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ── Month Navigator ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    _MonthNavButton(
                      icon: Icons.chevron_left,
                      onTap: () => setState(() => _focusedMonth =
                          DateTime(_focusedMonth.year,
                              _focusedMonth.month - 1)),
                    ),
                    const SizedBox(width: 8),
                    _MonthNavButton(
                      icon: Icons.chevron_right,
                      onTap: () => setState(() => _focusedMonth =
                          DateTime(_focusedMonth.year,
                              _focusedMonth.month + 1)),
                    ),
                    const Spacer(),
                    // Total chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Total: ${provider.currency}${totalSpent.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Category Filter Chips ──
              if (categories.isNotEmpty)
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _FilterChip(
                        label: 'All',
                        isSelected: _selectedCategory == null,
                        onTap: () =>
                            setState(() => _selectedCategory = null),
                        theme: theme,
                      ),
                      ...categories.map((cat) => _FilterChip(
                            label: cat,
                            isSelected: _selectedCategory == cat,
                            onTap: () => setState(
                                () => _selectedCategory == cat
                                    ? _selectedCategory = null
                                    : _selectedCategory = cat),
                            theme: theme,
                          )),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // ── Expenses List ──
              Expanded(
                child: monthlyExpenses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 64,
                                color: isDark
                                    ? Colors.white24
                                    : Colors.black12),
                            const SizedBox(height: 16),
                            Text(
                              'No expenses found.',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white38
                                    : Colors.black38,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0),
                        itemCount: grouped.keys.length,
                        itemBuilder: (ctx, gIdx) {
                          final dateKey =
                              grouped.keys.elementAt(gIdx);
                          final list = grouped[dateKey]!;
                          final dayTotal = list.fold(
                              0.0, (sum, e) => sum + e.amount);

                          return Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      dateKey,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white60
                                            : Colors.black54,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      '-${provider.currency}${dayTotal.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white38
                                            : Colors.black38,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ...list.map((item) =>
                                  _ExpenseTile(
                                    expense: item,
                                    isSelected:
                                        item.id == _selectedExpenseId,
                                    onTap: () => setState(() =>
                                        _selectedExpenseId =
                                            item.id == _selectedExpenseId
                                                ? null
                                                : item.id),
                                    onEdit: () {
                                      InputBottomSheet.show(context,
                                          expenseToEdit: item);
                                      setState(() =>
                                          _selectedExpenseId = null);
                                    },
                                    onDelete: () {
                                      provider.removeExpense(item.id);
                                      setState(() =>
                                          _selectedExpenseId = null);
                                    },
                                    theme: theme,
                                  )),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────

class _MonthNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MonthNavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;
  const _FilterChip(
      {required this.label,
      required this.isSelected,
      required this.onTap,
      required this.theme});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (theme.brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black54),
            fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final Expense expense;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ThemeData theme;

  const _ExpenseTile({
    required this.expense,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<ExpenseProvider>(context, listen: false).currency;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withOpacity(0.08)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        onTap: onTap,
        leading: CategoryIconWidget(categoryName: expense.category.name),
        title: Text(
          expense.payee,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Row(
          children: [
            Text(
              expense.category.name,
              style:
                  const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            if (expense.tag.name.isNotEmpty) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  expense.tag.name,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ]
          ],
        ),
        trailing: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isSelected
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          color: Colors.blueAccent),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.redAccent),
                      onPressed: onDelete,
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '-$currency${expense.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Tax $currency${(expense.amount * 0.082).toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
