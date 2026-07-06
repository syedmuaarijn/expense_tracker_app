import 'expense_category.dart';
import 'tag.dart';

class Expense {
  final String id;
  final String payee;
  final double amount;
  final String notes;
  final DateTime date;
  final ExpenseCategory category;
  final Tag tag;

  Expense({
    required this.id,
    required this.payee,
    required this.amount,
    required this.notes,
    required this.date,
    required this.category,
    required this.tag,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      payee: json['payee'] as String,
      amount: (json['amount'] as num).toDouble(),
      notes: json['notes'] as String,
      date: DateTime.parse(json['date'] as String),
      category: ExpenseCategory.fromJson(json['category'] as Map<String, dynamic>),
      tag: Tag.fromJson(json['tag'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payee': payee,
      'amount': amount,
      'notes': notes,
      'date': date.toIso8601String(),
      'category': category.toJson(),
      'tag': tag.toJson(),
    };
  }
}