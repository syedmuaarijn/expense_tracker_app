import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../models/cash_flow.dart';
import '../widgets/input_bottom_sheet.dart';

class CashFlowScreen extends StatefulWidget {
  const CashFlowScreen({super.key});

  @override
  State<CashFlowScreen> createState() => _CashFlowScreenState();
}

class _CashFlowScreenState extends State<CashFlowScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedFlowId;

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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Cash Flow Registry',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.primary,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'Monthly Registry'),
            Tab(text: 'Annual Registry'),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: () => setState(() => _selectedFlowId = null),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildFlowList(
              provider.cashFlows.where((c) => c.period == CashFlowPeriod.monthly).toList(),
              provider,
            ),
            _buildFlowList(
              provider.cashFlows.where((c) => c.period == CashFlowPeriod.annually).toList(),
              provider,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowList(List<CashFlow> items, ExpenseProvider provider) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'No records found.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    final theme = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      itemCount: items.length,
      itemBuilder: (ctx, idx) {
        final item = items[idx];
        final isPay = item.type == CashFlowType.toPay;
        final isSelected = item.id == _selectedFlowId;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12.0),
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
            onTap: () => setState(() => _selectedFlowId = isSelected ? null : item.id),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isPay 
                    ? Colors.redAccent.withOpacity(0.12) 
                    : Colors.greenAccent.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPay ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                color: isPay ? Colors.redAccent : Colors.greenAccent,
                size: 22,
              ),
            ),
            title: Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              isPay ? "Outcome Liability" : "Income Receivable",
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
                            InputBottomSheet.show(context, cashFlowToEdit: item);
                            setState(() => _selectedFlowId = null);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () {
                            provider.removeCashFlow(item.id);
                            setState(() => _selectedFlowId = null);
                          },
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isPay ? "-" : "+"}${provider.currency}${item.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: isPay ? Colors.redAccent : Colors.greenAccent,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Deferred',
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        )
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}
