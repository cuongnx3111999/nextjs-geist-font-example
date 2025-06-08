import 'package:flutter/foundation.dart';
import '../../models/expense.dart';
import '../../services/database_service.dart';

class ExpenseProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  List<ExpenseModel> _expenses = [];
  bool _isLoading = false;
  String? _error;
  String? _userId;

  // Getters
  List<ExpenseModel> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize with user ID
  void initialize(String userId) {
    _userId = userId;
    _loadExpenses();
  }

  // Load expenses
  void _loadExpenses() {
    if (_userId == null) return;

    _setLoading(true);
    try {
      // Listen to expense stream
      _db.getUserExpenses(_userId!).listen(
        (expenses) {
          _expenses = expenses;
          notifyListeners();
        },
        onError: (e) {
          _setError(e.toString());
        },
      );
    } finally {
      _setLoading(false);
    }
  }

  // Add expense
  Future<void> addExpense(ExpenseModel expense) async {
    _setLoading(true);
    _clearError();

    try {
      await _db.createExpense(expense);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Update expense
  Future<void> updateExpense(ExpenseModel expense) async {
    _setLoading(true);
    _clearError();

    try {
      await _db.updateExpense(expense);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Delete expense
  Future<void> deleteExpense(String expenseId) async {
    _setLoading(true);
    _clearError();

    try {
      await _db.deleteExpense(expenseId);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Get expenses by date range
  Future<List<ExpenseModel>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (_userId == null) return [];

    _setLoading(true);
    _clearError();

    try {
      return await _db.getExpensesByDateRange(_userId!, startDate, endDate);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Get total expenses for a period
  double getTotalExpenses([DateTime? startDate, DateTime? endDate]) {
    List<ExpenseModel> filteredExpenses = _expenses;
    
    if (startDate != null) {
      filteredExpenses = filteredExpenses
          .where((expense) => expense.date.isAfter(startDate))
          .toList();
    }
    
    if (endDate != null) {
      filteredExpenses = filteredExpenses
          .where((expense) => expense.date.isBefore(endDate))
          .toList();
    }

    return filteredExpenses.fold(
      0, 
      (total, expense) => total + (expense.type == ExpenseType.expense ? expense.amount : -expense.amount)
    );
  }

  // Get expenses by category
  List<ExpenseModel> getExpensesByCategory(String categoryId) {
    return _expenses.where((expense) => expense.categoryId == categoryId).toList();
  }

  // Get expenses by payment method
  List<ExpenseModel> getExpensesByPaymentMethod(PaymentMethod paymentMethod) {
    return _expenses.where((expense) => expense.paymentMethod == paymentMethod).toList();
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Dispose
  @override
  void dispose() {
    _expenses = [];
    _userId = null;
    super.dispose();
  }
}
