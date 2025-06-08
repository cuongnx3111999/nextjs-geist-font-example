class ExpenseModel {
  final String id;
  final double amount;
  final String categoryId;
  final String userId;
  final String? note;
  final DateTime date;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? attachmentUrl;
  final ExpenseType type;
  final PaymentMethod paymentMethod;

  ExpenseModel({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.userId,
    this.note,
    required this.date,
    required this.createdAt,
    this.updatedAt,
    this.attachmentUrl,
    required this.type,
    required this.paymentMethod,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      userId: json['userId'] as String,
      note: json['note'] as String?,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      attachmentUrl: json['attachmentUrl'] as String?,
      type: ExpenseType.values.firstWhere(
        (e) => e.toString() == 'ExpenseType.${json['type']}',
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString() == 'PaymentMethod.${json['paymentMethod']}',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'categoryId': categoryId,
      'userId': userId,
      'note': note,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'attachmentUrl': attachmentUrl,
      'type': type.toString().split('.').last,
      'paymentMethod': paymentMethod.toString().split('.').last,
    };
  }

  ExpenseModel copyWith({
    String? id,
    double? amount,
    String? categoryId,
    String? userId,
    String? note,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? attachmentUrl,
    ExpenseType? type,
    PaymentMethod? paymentMethod,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      userId: userId ?? this.userId,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      type: type ?? this.type,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  @override
  String toString() {
    return 'ExpenseModel(id: $id, amount: $amount, categoryId: $categoryId, userId: $userId, note: $note, date: $date, createdAt: $createdAt, updatedAt: $updatedAt, attachmentUrl: $attachmentUrl, type: $type, paymentMethod: $paymentMethod)';
  }
}

enum ExpenseType {
  expense,
  income
}

enum PaymentMethod {
  cash,
  creditCard,
  debitCard,
  bankTransfer,
  digitalWallet,
  other
}
