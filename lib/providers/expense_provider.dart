// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:localstorage/localstorage.dart'; // Gives access to global 'localStorage'
// import '../models/expense.dart';
// import '../models/expense_category.dart';
// import '../models/tag.dart';

// class ExpenseProvider with ChangeNotifier {
//   List<Expense> _expenses = [];
//   List<ExpenseCategory> _categories = [];
//   List<Tag> _tags = [];
//   double _monthlyBudget = 1500.0;
//   bool _isInitialized = false;

//   // Getters
//   List<Expense> get expenses => _expenses;
//   List<ExpenseCategory> get categories => _categories;
//   List<Tag> get tags => _tags;
//   double get monthlyBudget => _monthlyBudget;
//   bool get isInitialized => _isInitialized;

//   ExpenseProvider() {
//     _loadExpensesFromStorage();
//   }

//   // --- Storage Operations ---

//   void _loadExpensesFromStorage() {
//     try {
//       // In localstorage v5+, getItem returns a String? directly
//       final storedExpenses = localStorage.getItem('expenses');
//       if (storedExpenses != null) {
//         final List<dynamic> decoded = jsonDecode(storedExpenses);
//         _expenses = decoded.map((item) => Expense.fromJson(item)).toList();
//       }

//       // Load Categories (with default values if storage is empty)
//       final storedCategories = localStorage.getItem('categories');
//       if (storedCategories != null) {
//         final List<dynamic> decoded = jsonDecode(storedCategories);
//         _categories = decoded
//             .map((item) => ExpenseCategory.fromJson(item))
//             .toList();
//       } else {
//         _categories = [
//           ExpenseCategory(id: 'c1', name: 'Food'),
//           ExpenseCategory(id: 'c2', name: 'Transport'),
//           ExpenseCategory(id: 'c3', name: 'Bills'),
//           ExpenseCategory(id: 'c4', name: 'Entertainment'),
//         ];
//       }

//       // Load Tags (with default values if storage is empty)
//       final storedTags = localStorage.getItem('tags');
//       if (storedTags != null) {
//         final List<dynamic> decoded = jsonDecode(storedTags);
//         _tags = decoded.map((item) => Tag.fromJson(item)).toList();
//       } else {
//         _tags = [Tag(id: 't1', name: 'Needs'), Tag(id: 't2', name: 'Wants')];
//       }

//       _isInitialized = true;

//       final storedBudget = localStorage.getItem('monthly_budget');
//       if (storedBudget != null) {
//         _monthlyBudget = double.tryParse(storedBudget) ?? 1500.0;
//       }
//     } catch (e) {
//       debugPrint("Error loading data from storage: $e");
//     }
//     notifyListeners();
//   }

//   void _saveExpensesToStorage() {
//     try {
//       final String encodedExpenses = jsonEncode(
//         _expenses.map((e) => e.toJson()).toList(),
//       );
//       final String encodedCategories = jsonEncode(
//         _categories.map((c) => c.toJson()).toList(),
//       );
//       final String encodedTags = jsonEncode(
//         _tags.map((t) => t.toJson()).toList(),
//       );

//       localStorage.setItem('expenses', encodedExpenses);
//       localStorage.setItem('categories', encodedCategories);
//       localStorage.setItem('tags', encodedTags);
//     } catch (e) {
//       debugPrint("Error saving data to storage: $e");
//     }
//   }

//   // --- Expense Management Methods ---

//   void addExpense(Expense expense) {
//     _expenses.add(expense);
//     _saveExpensesToStorage();
//     notifyListeners();
//   }

//   void addOrUpdateExpense(Expense expense) {
//     final index = _expenses.indexWhere((e) => e.id == expense.id);
//     if (index != -1) {
//       _expenses[index] = expense;
//     } else {
//       _expenses.add(expense);
//     }
//     _saveExpensesToStorage();
//     notifyListeners();
//   }

//   void removeExpense(String id) {
//     _expenses.removeWhere((expense) => expense.id == id);
//     _saveExpensesToStorage();
//     notifyListeners();
//   }

//   // --- Category & Tag Management Methods ---

//   void addCategory(ExpenseCategory category) {
//     _categories.add(category);
//     _saveExpensesToStorage();
//     notifyListeners();
//   }

//   void removeCategory(String id) {
//     _categories.removeWhere((category) => category.id == id);
//     _saveExpensesToStorage();
//     notifyListeners();
//   }

//   void addTag(Tag tag) {
//     _tags.add(tag);
//     _saveExpensesToStorage();
//     notifyListeners();
//   }

//   void removeTag(String id) {
//     _tags.removeWhere((tag) => tag.id == id);
//     _saveExpensesToStorage();
//     notifyListeners();
//   }

//   void updateBudget(double newAmount) {
//     _monthlyBudget = newAmount;
//     localStorage.setItem('monthly_budget', newAmount.toString());
//     notifyListeners();
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/tag.dart';
import '../models/cash_flow.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  List<ExpenseCategory> _categories = [];
  List<Tag> _tags = [];
  List<CashFlow> _cashFlows = [];

  String _userName = "";
  bool _hasSeenOnboarding = false;
  bool _isDarkMode = true;
  double _monthlyBudget = 2000.0;
  String _currency = "\$";
  bool _isInitialized = false;

  // Getters
  List<Expense> get expenses => _expenses;
  List<ExpenseCategory> get categories => _categories;
  List<Tag> get tags => _tags;
  List<CashFlow> get cashFlows => _cashFlows;
  String get userName => _userName;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get isDarkMode => _isDarkMode;
  double get monthlyBudget => _monthlyBudget;
  String get currency => _currency;
  bool get isInitialized => _isInitialized;

  ExpenseProvider() {
    _loadDataFromStorage();
  }

  void _loadDataFromStorage() {
    try {
      _userName = localStorage.getItem('user_name') ?? "";
      _hasSeenOnboarding =
          (localStorage.getItem('has_onboarded') ?? "false") == "true";
      _isDarkMode = (localStorage.getItem('is_dark_mode') ?? "true") == "true";
      _monthlyBudget =
          double.tryParse(localStorage.getItem('monthly_budget') ?? "2000.0") ??
          2000.0;
      _currency = localStorage.getItem('currency') ?? "\$";

      final storedExpenses = localStorage.getItem('expenses');
      if (storedExpenses != null) {
        _expenses = (jsonDecode(storedExpenses) as List)
            .map((i) => Expense.fromJson(i))
            .toList();
      }

      final storedCashFlows = localStorage.getItem('cash_flows');
      if (storedCashFlows != null) {
        _cashFlows = (jsonDecode(storedCashFlows) as List)
            .map((i) => CashFlow.fromJson(i))
            .toList();
      }

      final storedCategories = localStorage.getItem('categories');
      if (storedCategories != null) {
        _categories = (jsonDecode(storedCategories) as List)
            .map((i) => ExpenseCategory.fromJson(i))
            .toList();
      } else {
        _categories = [
          ExpenseCategory(id: 'c1', name: 'Food'),
          ExpenseCategory(id: 'c2', name: 'Transport'),
          ExpenseCategory(id: 'c3', name: 'Bills'),
        ];
      }

      final storedTags = localStorage.getItem('tags');
      if (storedTags != null) {
        _tags = (jsonDecode(storedTags) as List)
            .map((i) => Tag.fromJson(i))
            .toList();
      } else {
        _tags = [Tag(id: 't1', name: 'Needs'), Tag(id: 't2', name: 'Wants')];
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint("Storage error: $e");
    }
    notifyListeners();
  }

  void _saveToStorage() {
    localStorage.setItem('user_name', _userName);
    localStorage.setItem('has_onboarded', _hasSeenOnboarding.toString());
    localStorage.setItem('is_dark_mode', _isDarkMode.toString());
    localStorage.setItem('monthly_budget', _monthlyBudget.toString());
    localStorage.setItem('currency', _currency);
    localStorage.setItem(
      'expenses',
      jsonEncode(_expenses.map((e) => e.toJson()).toList()),
    );
    localStorage.setItem(
      'cash_flows',
      jsonEncode(_cashFlows.map((c) => c.toJson()).toList()),
    );
    localStorage.setItem(
      'categories',
      jsonEncode(_categories.map((c) => c.toJson()).toList()),
    );
    localStorage.setItem(
      'tags',
      jsonEncode(_tags.map((t) => t.toJson()).toList()),
    );
  }

  // Setters
  void saveProfile(String name) {
    _userName = name;
    _hasSeenOnboarding = true;
    _saveToStorage();
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveToStorage();
    notifyListeners();
  }

  void updateBudget(double amount) {
    _monthlyBudget = amount;
    _saveToStorage();
    notifyListeners();
  }

  void updateCurrency(String currencyStr) {
    _currency = currencyStr;
    _saveToStorage();
    notifyListeners();
  }

  // Operational Upgrades
  void addExpense(Expense e) {
    _expenses.add(e);
    _saveToStorage();
    notifyListeners();
  }

  void updateExpense(Expense updated) {
    final idx = _expenses.indexWhere((e) => e.id == updated.id);
    if (idx != -1) {
      _expenses[idx] = updated;
      _saveToStorage();
      notifyListeners();
    }
  }

  void removeExpense(String id) {
    _expenses.removeWhere((e) => e.id == id);
    _saveToStorage();
    notifyListeners();
  }

  void clearAllExpenses() {
    _expenses.clear();
    _saveToStorage();
    notifyListeners();
  }

  void addCashFlow(CashFlow cf) {
    _cashFlows.add(cf);
    _saveToStorage();
    notifyListeners();
  }

  void removeCashFlow(String id) {
    _cashFlows.removeWhere((c) => c.id == id);
    _saveToStorage();
    notifyListeners();
  }

  void addCategory(ExpenseCategory c) {
    _categories.add(c);
    _saveToStorage();
    notifyListeners();
  }

  void removeCategory(String id) {
    _categories.removeWhere((c) => c.id == id);
    _saveToStorage();
    notifyListeners();
  }

  void addTag(Tag t) {
    _tags.add(t);
    _saveToStorage();
    notifyListeners();
  }

  void removeTag(String id) {
    _tags.removeWhere((t) => t.id == id);
    _saveToStorage();
    notifyListeners();
  }

  void updateCashFlow(CashFlow updatedCf) {
  final idx = _cashFlows.indexWhere((c) => c.id == updatedCf.id);
  if (idx != -1) {
    _cashFlows[idx] = updatedCf;
    _saveToStorage();
    notifyListeners();
  }
}
}
