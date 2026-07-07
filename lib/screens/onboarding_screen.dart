import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                  children: [
                    _buildPage(
                      icon: Icons.analytics_rounded,
                      title: 'Predictive Tracking',
                      desc: 'Track expenses cleanly across custom monthly cycles with structural category ledgers.',
                    ),
                    _buildPage(
                      icon: Icons.swap_horizontal_circle_rounded,
                      title: 'Asset & Liability Sync',
                      desc: 'Manage ongoing cash flow by monitoring amounts to pay and receive metrics effortlessly.',
                    ),
                    _buildProfileInputPage(theme),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(color: _currentPage == i ? theme.colorScheme.primary : Colors.grey, borderRadius: BorderRadius.circular(4)),
                )),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.brightness == Brightness.dark ? Colors.black : Colors.white,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    if (_currentPage < 2) {
                      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                    } else {
                      if (_formKey.currentState!.validate()) {
                        Provider.of<ExpenseProvider>(context, listen: false).saveProfile(_nameController.text.trim());
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
                      }
                    }
                  },
                  child: Text(_currentPage == 2 ? 'Launch Trackly' : 'Continue', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage({required IconData icon, required String title, required String desc}) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: const Color(0xFF00E5FF)),
          const SizedBox(height: 40),
          Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 16),
          Text(desc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: Colors.grey, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildProfileInputPage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Let\'s Personalize\nYour Ledger', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text('Enter your name to customize your financial workspace dashboard context.', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 32),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Account Holder Name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              prefixIcon: const Icon(Icons.person_outline),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Name is required to build identity accounts.' : null,
          )
        ],
      ),
    );
  }
}