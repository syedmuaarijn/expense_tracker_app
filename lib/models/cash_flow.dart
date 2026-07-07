enum CashFlowType { toPay, toReceive }
enum CashFlowPeriod { monthly, annually }

class CashFlow {
  final String id;
  final String title;
  final double amount;
  final CashFlowType type;
  final CashFlowPeriod period;
  final DateTime date;

  CashFlow({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.period,
    required this.date,
  });

  factory CashFlow.fromJson(Map<String, dynamic> json) {
    return CashFlow(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: CashFlowType.values[json['type'] as int],
      period: CashFlowPeriod.values[json['period'] as int],
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.index,
      'period': period.index,
      'date': date.toIso8601String(),
    };
  }
}