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
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Filter expenses by focused month
    List<Expense> monthlyExpenses = provider.expenses.where((e) {
      return e.date.year == _focusedMonth.year && e.date.month == _focusedMonth.month;
    }).toList();

    List<Expense> searchedExpenses = monthlyExpenses.where((e) {
      return e.payee.toLowerCase().contains(_searchQuery.toLowerCase()) || 
             e.notes.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    double totalSpent = monthlyExpenses.fold(0.0, (sum, i) => sum + i.amount);

    // Group expenses by date formatted beautifully
    Map<String, List<Expense>> groupedExpenses = {};
    for (var exp in searchedExpenses) {
      String dateStr;
      final now = DateTime.now();
      final diff = now.difference(exp.date).inDays;
      if (exp.date.year == now.year && exp.date.month == now.month && exp.date.day == now.day) {
        dateStr = "Today";
      } else if (diff == 1) {
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
              // Top Greeting Header with Profile Avatar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
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
                              color: isDark ? Colors.white60 : Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            provider.userName.isNotEmpty ? provider.userName : 'Priscilla',
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
                          onChanged: (v) => setState(() => _searchQuery = v),
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
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                  )
                                ],
                              ),
                              child: const Icon(Icons.search, size: 20),
                            ),
                            onPressed: () => setState(() => _isSearching = true),
                          ),
                          const SizedBox(width: 8),
                          // Avatar representation
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE36F47), Color(0xFF4C1D6F)],
                              ),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              provider.userName.isNotEmpty ? provider.userName[0].toUpperCase() : 'P',
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

              // Outcome Card matching reference image
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                padding: const EdgeInsets.all(22.0),
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
                    const Text(
                      'Outcome',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${totalSpent.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Month-wise Bar Chart representation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildBarChartColumn("Aug", 0.4, false),
                        _buildBarChartColumn("Oct", 0.7, false),
                        _buildBarChartColumn("Dec", 0.3, false),
                        _buildBarChartColumn("Feb", 0.5, false),
                        _buildBarChartColumn("Apr", 0.8, true),
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Scrollable list of expenses
              Expanded(
                child: searchedExpenses.isEmpty
                    ? const Center(child: Text('No expenses recorded.', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        itemCount: groupedExpenses.keys.length,
                        itemBuilder: (ctx, gIdx) {
                          final dateKey = groupedExpenses.keys.elementAt(gIdx);
                          final list = groupedExpenses[dateKey]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0),
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
                                final isSelected = item.id == _selectedExpenseId;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(bottom: 10.0),
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? theme.colorScheme.primary.withOpacity(0.08) 
                                        : theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    onTap: () {
                                      setState(() {
                                        _selectedExpenseId = isSelected ? null : item.id;
                                      });
                                    },
                                    leading: CategoryIconWidget(categoryName: item.category.name),
                                    title: Text(
                                      item.payee,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Text(
                                      item.category.name,
                                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                                    ),
                                    trailing: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 200),
                                      child: isSelected
                                          ? Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                                                  onPressed: () {
                                                    InputBottomSheet.show(context, expenseToEdit: item);
                                                    setState(() => _selectedExpenseId = null);
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                                  onPressed: () {
                                                    provider.removeExpense(item.id);
                                                    setState(() => _selectedExpenseId = null);
                                                  },
                                                ),
                                              ],
                                            )
                                          : Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '-\$${item.amount.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Text(
                                                  'Tax \$${(item.amount * 0.082).toStringAsFixed(2)}',
                                                  style: const TextStyle(
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

  Widget _buildBarChartColumn(String month, double heightPct, bool isHighlighted) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 80,
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: FractionallySizedBox(
            heightFactor: heightPct,
            child: Container(
              decoration: BoxDecoration(
                color: isHighlighted 
                    ? const Color(0xFFE36F47) 
                    : Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          month,
          style: TextStyle(
            color: isHighlighted ? Colors.white : Colors.white54,
            fontSize: 11,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
          ),
        )
      ],
    );
  }
}