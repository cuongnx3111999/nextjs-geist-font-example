class BudgetModel {
  final String id;
  final String userId;
  final String categoryId;
  final double amount;
  final BudgetPeriod period;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isRecurring;
  final String? note;

  BudgetModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.period,
    required this.startDate,
    this.endDate,
    required this.createdAt,
    this.updatedAt,
    required this.isRecurring,
    this.note,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      categoryId: json['categoryId'] as String,
      amount: (json['amount'] as num).toDouble(),
      period: BudgetPeriod.values.firstWhere(
        (e) => e.toString() == 'BudgetPeriod.${json['period']}',
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isRecurring: json['isRecurring'] as bool,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'categoryId': categoryId,
      'amount': amount,
      'period': period.toString().split('.').last,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isRecurring': isRecurring,
      'note': note,
    };
  }

  BudgetModel copyWith({
    String? id,
    String? userId,
    String? categoryId,
    double? amount,
    BudgetPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isRecurring,
    String? note,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRecurring: isRecurring ?? this.isRecurring,
      note: note ?? this.note,
    );
  }

  @override
  String toString() {
    return 'BudgetModel(id: $id, userId: $userId, categoryId: $categoryId, amount: $amount, period: $period, startDate: $startDate, endDate: $endDate, createdAt: $createdAt, updatedAt: $updatedAt, isRecurring: $isRecurring, note: $note)';
  }

  /// Calculate the remaining budget amount for the current period
  double calculateRemainingAmount(List<ExpenseModel> expenses) {
    final periodExpenses = expenses.where((expense) {
      return expense.categoryId == categoryId &&
             isExpenseInCurrentPeriod(expense.date);
    });
    
    final totalExpenses = periodExpenses.fold(
      0.0, 
      (sum, expense) => sum + expense.amount
    );
    
    return amount - totalExpenses;
  }

  /// Check if a given date falls within the current budget period
  bool isExpenseInCurrentPeriod(DateTime expenseDate) {
    final now = DateTime.now();
    
    switch (period) {
      case BudgetPeriod.daily:
        return expenseDate.year == now.year &&
               expenseDate.month == now.month &&
               expenseDate.day == now.day;
      
      case BudgetPeriod.weekly:
        final startOfWeek = now.subtract(
          Duration(days: now.weekday - 1)
        );
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return expenseDate.isAfter(startOfWeek) && 
               expenseDate.isBefore(endOfWeek);
      
      case BudgetPeriod.monthly:
        return expenseDate.year == now.year &&
               expenseDate.month == now.month;
      
      case BudgetPeriod.yearly:
        return expenseDate.year == now.year;
      
      case BudgetPeriod.custom:
        return expenseDate.isAfter(startDate) &&
               (endDate == null || expenseDate.isBefore(endDate!));
    }
  }
}

enum BudgetPeriod {
  daily,
  weekly,
  monthly,
  yearly,
  custom
}
