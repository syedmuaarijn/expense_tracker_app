import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import 'category_management_screen.dart';
import 'tag_management_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// Common currencies: symbol → display label
const _kCurrencies = {
  '\$': 'USD – \$',
  '€': 'EUR – €',
  '£': 'GBP – £',
  '¥': 'JPY – ¥',
  '₹': 'INR – ₹',
  '₩': 'KRW – ₩',
  'CHF': 'CHF',
  'A\$': 'AUD – A\$',
  'C\$': 'CAD – C\$',
  'AED': 'AED',
  'SAR': 'SAR',
  'PKR': 'PKR',
};

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _budgetController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedCurrency = '\$';

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    _nameController.text = provider.userName;
    _budgetController.text = provider.monthlyBudget.toString();
    _selectedCurrency = provider.currency;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    if (!_formKey.currentState!.validate()) return;
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    provider.saveProfile(_nameController.text.trim());
    provider.updateBudget(double.parse(_budgetController.text.trim()));
    provider.updateCurrency(_selectedCurrency);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile settings committed successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final theme = Theme.of(context);

    // Initial avatar letters
    final initials = provider.userName.isNotEmpty 
        ? provider.userName[0].toUpperCase() 
        : 'U';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Profile Settings',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Avatar
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE36F47), Color(0xFF4C1D6F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  provider.userName.isNotEmpty ? provider.userName : 'Trackly Account Holder',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),

                // Textfields for parameters
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'User Identity Name',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Identity name is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                  labelText: 'Monthly Budget Limit ($_selectedCurrency)',
                    prefixIcon: const Icon(Icons.wallet_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  validator: (v) => v == null || double.tryParse(v) == null ? 'Enter valid budget amount' : null,
                ),
                const SizedBox(height: 16),

                // ── Currency Selector ──
                DropdownButtonFormField<String>(
                  value: _selectedCurrency,
                  decoration: InputDecoration(
                    labelText: 'Currency',
                    prefixIcon: const Icon(Icons.currency_exchange_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  items: _kCurrencies.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedCurrency = v);
                  },
                ),
                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.brightness == Brightness.dark ? const Color(0xFF1B0B24) : Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Save Profile & Budget Info', style: TextStyle(fontWeight: FontWeight.bold)),
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 12),

                // Navigation helpers
                Card(
                  elevation: 0,
                  child: ListTile(
                    leading: const Icon(Icons.category_outlined),
                    title: const Text('Manage Expense Categories'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => const CategoryManagementScreen()),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  child: ListTile(
                    leading: const Icon(Icons.bookmark_border_rounded),
                    title: const Text('Manage Search Tags'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => const TagManagementScreen()),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  child: SwitchListTile(
                    secondary: Icon(provider.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
                    title: const Text('Dark Mode Palette'),
                    value: provider.isDarkMode,
                    onChanged: (val) {
                      provider.toggleTheme();
                    },
                  ),
                ),

                const SizedBox(height: 32),
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                  icon: const Icon(Icons.delete_forever_rounded),
                  label: const Text('Wipe All App Data'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Erase All Records?'),
                        content: const Text('This will permanently delete all your tracking details, categories, and tags. This action is irreversible.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () {
                              provider.clearAllExpenses();
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('All data cleared successfully!')),
                              );
                            },
                            child: const Text('Yes, Delete All'),
                          )
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
