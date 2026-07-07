import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../widgets/category_icons.dart';
import '../widgets/input_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = "";
  DateTime _focusedMonth = DateTime.now();
  String? _selectedExpenseId;
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Returns the total spend for a given year + month from the full expense list.
  double _monthTotal(List<Expense> expenses, int year, int month) {
    return expenses
        .where((e) => e.date.year == year && e.date.month == month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Filter expenses by focused month
    List<Expense> monthlyExpenses = provider.expenses.where((e) {
      return e.date.year == _focusedMonth.year &&
          e.date.month == _focusedMonth.month;
    }).toList();

    List<Expense> searchedExpenses = monthlyExpenses.where((e) {
      return e.payee.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.notes.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Sort by newest first
    searchedExpenses.sort((a, b) => b.date.compareTo(a.date));

    double totalSpent =
        monthlyExpenses.fold(0.0, (sum, i) => sum + i.amount);

    // ── Build real bar chart data for Jan-Dec of current year ──
    final now = DateTime.now();
    final int currentYear = now.year;
    final List<_BarData> barData = List.generate(12, (i) {
      final monthNum = i + 1; // 1 to 12
      final d = DateTime(currentYear, monthNum);
      final total = _monthTotal(provider.expenses, d.year, d.month);
      final isCurrent =
          d.year == _focusedMonth.year && d.month == _focusedMonth.month;
      
      return _BarData(
        label: DateFormat('MMM').format(d),
        total: total,
        isFocused: isCurrent,
        isOverBudget: provider.monthlyBudget > 0 && total > provider.monthlyBudget,
        currency: provider.currency,
        onTap: () => setState(() => _focusedMonth = d),
      );
    });

    // Scale ceiling = budget (so bars show spend as % of budget).
    // Falls back to max spend if somehow higher (e.g. over-budget month).
    final maxSpend = provider.monthlyBudget > 0
        ? barData.map((b) => b.total).fold(provider.monthlyBudget,
            (prev, t) => t > prev ? t : prev)
        : barData.map((b) => b.total).reduce((a, b) => a > b ? a : b);

    // Group expenses by date
    Map<String, List<Expense>> groupedExpenses = {};
    for (var exp in searchedExpenses) {
      final now2 = DateTime.now();
      String dateStr;
      if (exp.date.year == now2.year &&
          exp.date.month == now2.month &&
          exp.date.day == now2.day) {
        dateStr = "Today";
      } else if (exp.date.year == now2.year &&
          exp.date.month == now2.month &&
          exp.date.day == now2.day - 1) {
        dateStr = "Yesterday";
      } else {
        dateStr = DateFormat('dd MMMM').format(exp.date);
      }
      groupedExpenses.putIfAbsent(dateStr, () => []).add(exp);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => setState(() => _selectedExpenseId = null),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Greeting Header ──
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!_isSearching) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello,',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white60
                                  : Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            provider.userName.isNotEmpty
                                ? provider.userName
                                : 'Priscilla',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ] else
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Search expenses...',
                            border: InputBorder.none,
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = "";
                                  _isSearching = false;
                                });
                              },
                            ),
                          ),
                          onChanged: (v) =>
                              setState(() => _searchQuery = v),
                        ),
                      ),
                    if (!_isSearching)
                      Row(
                        children: [
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                  )
                                ],
                              ),
                              child: const Icon(Icons.search, size: 20),
                            ),
                            onPressed: () =>
                                setState(() => _isSearching = true),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFE36F47),
                                  Color(0xFF4C1D6F)
                                ],
                              ),
                              border: Border.all(
                                  color: Colors.white, width: 2),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              provider.userName.isNotEmpty
                                  ? provider.userName[0].toUpperCase()
                                  : 'P',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          )
                        ],
                      )
                  ],
                ),
              ),

              // ── Outcome Card with REAL Bar Chart ──
              Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 8.0),
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3D1D50), Color(0xFF261134)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3D1D50).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Month navigation row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Text(
                                  'Outcome',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${provider.currency}${totalSpent.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        // Budget progress ring hint
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              DateFormat('MMM yyyy')
                                  .format(_focusedMonth),
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Budget ${provider.currency}${provider.monthlyBudget.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 11),
                            ),
                            const SizedBox(height: 4),
                            // Budget usage bar
                            SizedBox(
                              width: 80,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: provider.monthlyBudget > 0
                                      ? (totalSpent /
                                              provider.monthlyBudget)
                                          .clamp(0.0, 1.0)
                                      : 0.0,
                                  minHeight: 4,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.12),
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                    totalSpent >
                                            provider.monthlyBudget
                                        ? Colors.redAccent
                                        : const Color(0xFFE36F47),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // ── Real Bar Chart (Scrollable, 6 visible at a time) ──
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final itemWidth = constraints.maxWidth / 6;
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: barData.map((b) {
                              return SizedBox(
                                width: itemWidth,
                                child: _buildRealBar(b, maxSpend),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Scrollable Expense List ──
              Expanded(
                child: searchedExpenses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 56,
                              color: isDark
                                  ? Colors.white24
                                  : Colors.black12,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No expenses for this month.',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white38
                                    : Colors.black38,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0),
                        itemCount: groupedExpenses.keys.length,
                        itemBuilder: (ctx, gIdx) {
                          final dateKey =
                              groupedExpenses.keys.elementAt(gIdx);
                          final list = groupedExpenses[dateKey]!;

                          return Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12.0),
                                child: Text(
                                  dateKey,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              ...list.map((item) {
                                final isSelected =
                                    item.id == _selectedExpenseId;
                                return AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(
                                      bottom: 10.0),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                            .withOpacity(0.08)
                                        : theme.colorScheme.surface,
                                    borderRadius:
                                        BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : Colors.transparent,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 6),
                                    onTap: () {
                                      setState(() {
                                        _selectedExpenseId = isSelected
                                            ? null
                                            : item.id;
                                      });
                                    },
                                    leading: CategoryIconWidget(
                                        categoryName:
                                            item.category.name),
                                    title: Text(
                                      item.payee,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Text(
                                      item.category.name,
                                      style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13),
                                    ),
                                    trailing: AnimatedSwitcher(
                                      duration: const Duration(
                                          milliseconds: 200),
                                      child: isSelected
                                          ? Row(
                                              mainAxisSize:
                                                  MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons
                                                          .edit_outlined,
                                                      color: Colors
                                                          .blueAccent),
                                                  onPressed: () {
                                                    InputBottomSheet
                                                        .show(context,
                                                            expenseToEdit:
                                                                item);
                                                    setState(() =>
                                                        _selectedExpenseId =
                                                            null);
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons
                                                          .delete_outline,
                                                      color: Colors
                                                          .redAccent),
                                                  onPressed: () {
                                                    provider
                                                        .removeExpense(
                                                            item.id);
                                                    setState(() =>
                                                        _selectedExpenseId =
                                                            null);
                                                  },
                                                ),
                                              ],
                                            )
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '-${provider.currency}${item.amount.toStringAsFixed(2)}',
                                                  style:
                                                      const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w900,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Text(
                                                  'Tax ${provider.currency}${(item.amount * 0.082).toStringAsFixed(2)}',
                                                  style:
                                                      const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          );
                        },
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRealBar(_BarData data, double maxSpend) {
    // Zero-spend months show a tiny sliver so the bar is still visible.
    // Non-zero months scale accurately against the budget ceiling.
    const double emptySliver = 0.04;
    final double heightRatio = maxSpend > 0
        ? (data.total == 0 ? emptySliver : (data.total / maxSpend).clamp(0.0, 1.0))
        : emptySliver;

    return GestureDetector(
      onTap: data.onTap,
      child: Column(
        children: [
          // Amount label on focused bar
          if (data.isFocused && data.total > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${data.currency}${data.total.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Container(
            width: 28,
            height: 80,
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: FractionallySizedBox(
              heightFactor: heightRatio,
              child: Container(
                decoration: BoxDecoration(
                  color: data.isFocused
                      ? (data.isOverBudget ? Colors.redAccent : const Color(0xFFE36F47))
                      : Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.label,
            style: TextStyle(
              color: data.isFocused ? Colors.white : Colors.white54,
              fontSize: 11,
              fontWeight:
                  data.isFocused ? FontWeight.bold : FontWeight.normal,
            ),
          )
        ],
      ),
    );
  }
}

// Data class for bar chart
class _BarData {
  final String label;
  final double total;
  final bool isFocused;
  final bool isOverBudget;
  final String currency;
  final VoidCallback onTap;

  const _BarData({
    required this.label,
    required this.total,
    required this.isFocused,
    required this.isOverBudget,
    required this.currency,
    required this.onTap,
  });
}