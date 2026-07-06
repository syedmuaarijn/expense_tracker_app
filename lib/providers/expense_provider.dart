import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart'; // Gives access to global 'localStorage'
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/tag.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  List<ExpenseCategory> _categories = [];
  List<Tag> _tags = [];
  bool _isInitialized = false;

  // Getters
  List<Expense> get expenses => _expenses;
  List<ExpenseCategory> get categories => _categories;
  List<Tag> get tags => _tags;
  bool get isInitialized => _isInitialized;

  ExpenseProvider() {
    _loadExpensesFromStorage();
  }

  // --- Storage Operations ---

  void _loadExpensesFromStorage() {
    try {
      // In localstorage v5+, getItem returns a String? directly
      final storedExpenses = localStorage.getItem('expenses');
      if (storedExpenses != null) {
        final List<dynamic> decoded = jsonDecode(storedExpenses);
        _expenses = decoded.map((item) => Expense.fromJson(item)).toList();
      }

      // Load Categories (with default values if storage is empty)
      final storedCategories = localStorage.getItem('categories');
      if (storedCategories != null) {
        final List<dynamic> decoded = jsonDecode(storedCategories);
        _categories = decoded.map((item) => ExpenseCategory.fromJson(item)).toList();
      } else {
        _categories = [
          ExpenseCategory(id: 'c1', name: 'Food'),
          ExpenseCategory(id: 'c2', name: 'Transport'),
          ExpenseCategory(id: 'c3', name: 'Bills'),
          ExpenseCategory(id: 'c4', name: 'Entertainment'),
        ];
      }

      // Load Tags (with default values if storage is empty)
      final storedTags = localStorage.getItem('tags');
      if (storedTags != null) {
        final List<dynamic> decoded = jsonDecode(storedTags);
        _tags = decoded.map((item) => Tag.fromJson(item)).toList();
      } else {
        _tags = [
          Tag(id: 't1', name: 'Needs'),
          Tag(id: 't2', name: 'Wants'),
        ];
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint("Error loading data from storage: $e");
    }
    notifyListeners();
  }

  void _saveExpensesToStorage() {
    try {
      final String encodedExpenses = jsonEncode(_expenses.map((e) => e.toJson()).toList());
      final String encodedCategories = jsonEncode(_categories.map((c) => c.toJson()).toList());
      final String encodedTags = jsonEncode(_tags.map((t) => t.toJson()).toList());

      localStorage.setItem('expenses', encodedExpenses);
      localStorage.setItem('categories', encodedCategories);
      localStorage.setItem('tags', encodedTags);
    } catch (e) {
      debugPrint("Error saving data to storage: $e");
    }
  }

  // --- Expense Management Methods ---

  void addExpense(Expense expense) {
    _expenses.add(expense);
    _saveExpensesToStorage();
    notifyListeners();
  }

  void addOrUpdateExpense(Expense expense) {
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
    } else {
      _expenses.add(expense);
    }
    _saveExpensesToStorage();
    notifyListeners();
  }

  void removeExpense(String id) {
    _expenses.removeWhere((expense) => expense.id == id);
    _saveExpensesToStorage();
    notifyListeners();
  }

  // --- Category & Tag Management Methods ---

  void addCategory(ExpenseCategory category) {
    _categories.add(category);
    _saveExpensesToStorage();
    notifyListeners();
  }

  void removeCategory(String id) {
    _categories.removeWhere((category) => category.id == id);
    _saveExpensesToStorage();
    notifyListeners();
  }

  void addTag(Tag tag) {
    _tags.add(tag);
    _saveExpensesToStorage();
    notifyListeners();
  }

  void removeTag(String id) {
    _tags.removeWhere((tag) => tag.id == id);
    _saveExpensesToStorage();
    notifyListeners();
  }
}