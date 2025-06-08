import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// Providers
import 'state/providers/auth_provider.dart';
import 'state/providers/expense_provider.dart';
import 'state/providers/category_provider.dart';
import 'state/providers/budget_provider.dart';

// Screens (we'll create these next)
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/expenses/expense_list_screen.dart';
import 'screens/categories/category_list_screen.dart';
import 'screens/budgets/budget_list_screen.dart';
import 'screens/reports/reports_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ExpenseProvider>(
          create: (_) => ExpenseProvider(),
          update: (_, auth, expenses) {
            if (auth.user != null && expenses != null) {
              expenses.initialize(auth.user!.uid);
            }
            return expenses;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, CategoryProvider>(
          create: (_) => CategoryProvider(),
          update: (_, auth, categories) {
            if (auth.user != null && categories != null) {
              categories.initialize(auth.user!.uid);
            }
            return categories;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, BudgetProvider>(
          create: (_) => BudgetProvider(),
          update: (_, auth, budgets) {
            if (auth.user != null && budgets != null) {
              budgets.initialize(auth.user!.uid);
            }
            return budgets;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Expense Manager',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.robotoTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          textTheme: GoogleFonts.robotoTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        themeMode: ThemeMode.system,
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/expenses': (context) => const ExpenseListScreen(),
          '/categories': (context) => const CategoryListScreen(),
          '/budgets': (context) => const BudgetListScreen(),
          '/reports': (context) => const ReportsScreen(),
        },
      ),
    );
  }
}
