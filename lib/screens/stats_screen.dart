import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../widgets/category_icons.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  DateTime _focusedMonth = DateTime.now();
  bool _isYearlyView = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final theme = Theme.of(context);

    // Filter expenses by selected period (month or year)
    List<Expense> periodExpenses = provider.expenses.where((e) {
      if (_isYearlyView) {
        return e.date.year == _focusedMonth.year;
      }
      return e.date.year == _focusedMonth.year && e.date.month == _focusedMonth.month;
    }).toList();

    double totalSpent = periodExpenses.fold(0.0, (sum, i) => sum + i.amount);

    // Group by Category
    Map<String, double> categoryTotals = {};
    for (var exp in periodExpenses) {
      categoryTotals[exp.category.name] = (categoryTotals[exp.category.name] ?? 0.0) + exp.amount;
    }

    // Prepare line chart data
    List<FlSpot> spots = [];
    double maxX = 0;
    if (_isYearlyView) {
      // 12 months
      maxX = 12;
      Map<int, double> monthlyTots = {};
      for (var exp in periodExpenses) {
        monthlyTots[exp.date.month] = (monthlyTots[exp.date.month] ?? 0.0) + exp.amount;
      }
      for (int i = 1; i <= 12; i++) {
        spots.add(FlSpot(i.toDouble(), monthlyTots[i] ?? 0.0));
      }
    } else {
      // Days of the month
      final daysInMonth = DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
      maxX = daysInMonth.toDouble();
      Map<int, double> dailyTots = {};
      for (var exp in periodExpenses) {
        dailyTots[exp.date.day] = (dailyTots[exp.date.day] ?? 0.0) + exp.amount;
      }
      for (int i = 1; i <= daysInMonth; i++) {
        spots.add(FlSpot(i.toDouble(), dailyTots[i] ?? 0.0));
      }
    }
    final maxY = spots.isEmpty ? 100.0 : spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.2;

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header title
                  Row(
                    children: [
                      const Text(
                        'Stats Analysis',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() => _isYearlyView = !_isYearlyView),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _isYearlyView ? 'Year' : 'Month',
                                style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.swap_vert_rounded, color: theme.colorScheme.primary, size: 14),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left, size: 20),
                          onPressed: () => setState(() {
                            if (_isYearlyView) {
                              _focusedMonth = DateTime(_focusedMonth.year - 1, _focusedMonth.month);
                            } else {
                              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                            }
                          }),
                        ),
                        Text(
                          _isYearlyView 
                              ? DateFormat('yyyy').format(_focusedMonth)
                              : DateFormat('MMM yyyy').format(_focusedMonth),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, size: 20),
                          onPressed: () => setState(() {
                            if (_isYearlyView) {
                              _focusedMonth = DateTime(_focusedMonth.year + 1, _focusedMonth.month);
                            } else {
                              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                            }
                          }),
                        ),
                      ],
                    ),
                  ),
              const SizedBox(height: 24),

              // Total Spend Overview Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: theme.brightness == Brightness.dark 
                        ? [const Color(0xFF381F4A), const Color(0xFF2A1637)]
                        : [const Color(0xFFEADCF5), Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Outflow Total',
                      style: TextStyle(
                        fontSize: 14, 
                        color: theme.brightness == Brightness.dark ? Colors.white60 : Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${provider.currency}${totalSpent.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: theme.brightness == Brightness.dark ? Colors.white : theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      _isYearlyView 
                          ? 'Total Spend in ${_focusedMonth.year}: ${provider.currency}${totalSpent.toStringAsFixed(2)}'
                          : 'Budget set for this month: ${provider.currency}${provider.monthlyBudget.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // ── Line Graph ──
                    SizedBox(
                      height: 120,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          minX: 1,
                          maxX: maxX,
                          minY: 0,
                          maxY: maxY == 0 ? 10 : maxY,
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              color: theme.colorScheme.secondary,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: theme.colorScheme.secondary.withOpacity(0.15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'Category Allocation',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              if (sortedCategories.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: Text(
                      'No expense history for this period.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedCategories.length,
                  itemBuilder: (ctx, idx) {
                    final item = sortedCategories[idx];
                    final pct = totalSpent > 0 ? (item.value / totalSpent) : 0.0;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CategoryIconWidget(categoryName: item.key),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item.key,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        '${provider.currency}${item.value.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: pct,
                                      minHeight: 6,
                                      backgroundColor: theme.brightness == Brightness.dark 
                                          ? Colors.white12 
                                          : Colors.black12,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        theme.colorScheme.secondary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(pct * 100).toStringAsFixed(1)}% of total spend',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                )
            ],
          ),
        ),
      ),
    );
  }
}
