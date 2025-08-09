import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:trash_app/models/wallet_model.dart';
import 'package:trash_app/services/auth_service.dart';
import '../constants/app_colors.dart';
import 'menu_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  Future<Wallet>? _walletFuture;
  String _selectedPeriod = 'Month';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final userId = _authService.currentUser?.uid;
    if (userId != null) {
      setState(() {
        _walletFuture = _fetchWallet(userId);
      });
    }
  }

  Future<Wallet> _fetchWallet(String userId) async {
    final url = Uri.parse('https://trash-api-azure.vercel.app/api/wallet?userId=$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Wallet.fromJson(jsonDecode(response.body));
    }
    if (response.statusCode == 404) {
      return Wallet(balance: 0, transactions: []);
    }
    throw Exception('Failed to load wallet data: ${response.body}');
  }

  List<Transaction> _filterTransactions(List<Transaction> allTransactions) {
    final now = DateTime.now();
    return allTransactions.where((tx) {
      final txDate = tx.createdAt;
      switch (_selectedPeriod) {
        case 'Day':
          return txDate.year == now.year && txDate.month == now.month && txDate.day == now.day;
        case 'Week':
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          return txDate.isAfter(startOfWeek);
        case 'Month':
          return txDate.year == now.year && txDate.month == now.month;
        case 'Year':
          return txDate.year == now.year;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.eco, color: AppColors.primaryGreen, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text('Rosella', style: TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _loadData),
                ],
              ),
            ),

            Expanded(
              child: FutureBuilder<Wallet>(
                future: _walletFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: Text('Tidak dapat memuat data.', style: TextStyle(color: Colors.white)));
                  }

                  final wallet = snapshot.data!;
                  final filteredTransactions = _filterTransactions(wallet.transactions);

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft, end: Alignment.bottomRight,
                              colors: [Colors.blue.shade400, AppColors.primaryGreen],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total Saldo', style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 12),
                              Text(currencyFormatter.format(wallet.balance), style: const TextStyle(color: AppColors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    _buildPeriodButton('Day'),
                                    _buildPeriodButton('Week'),
                                    _buildPeriodButton('Month'),
                                    _buildPeriodButton('Year'),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Expanded(
                                  child: LineChart(
                                    _buildChartData(filteredTransactions),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: AppColors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(Icons.home, 0),
            _buildBottomNavItem(Icons.grid_view, 1),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String period) {
    bool isSelected = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = period),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.lightGrey : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            period,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? AppColors.black : AppColors.grey,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, int index) {
    return GestureDetector(
      onTap: () {
        if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const MenuScreen()));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Icon(icon, color: index == 0 ? AppColors.primaryGreen : AppColors.grey, size: 28),
      ),
    );
  }

  LineChartData _buildChartData(List<Transaction> transactions) {
    List<FlSpot> spots = [];
    double cumulativeBalance = 0;

    transactions.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    for (var tx in transactions) {
      if (tx.type == 'credit') {
        cumulativeBalance += tx.amount;
      } else {
        cumulativeBalance -= tx.amount;
      }
      spots.add(FlSpot(tx.createdAt.millisecondsSinceEpoch.toDouble(), cumulativeBalance));
    }

    if (spots.isEmpty) {
        spots.add(FlSpot(DateTime.now().millisecondsSinceEpoch.toDouble(), 0));
    }

    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppColors.primaryGreen,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.primaryGreen.withOpacity(0.3),
          ),
        ),
      ],
    );
  }
}
