import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:trash_app/services/auth_service.dart';
import '../constants/app_colors.dart';

// Model untuk Wallet dan Transaksi
class Wallet {
  final double balance;
  final List<Transaction> transactions;

  Wallet({required this.balance, required this.transactions});

  factory Wallet.fromJson(Map<String, dynamic> json) {
    var txList = json['transactions'] as List;
    List<Transaction> transactions = txList.map((i) => Transaction.fromJson(i)).toList();
    return Wallet(
      balance: (json['balance'] as num).toDouble(),
      transactions: transactions,
    );
  }
}

class Transaction {
  final String description;
  final double amount;
  final DateTime createdAt;

  Transaction({required this.description, required this.amount, required this.createdAt});

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      description: json['description'],
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}


class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final AuthService _authService = AuthService();
  Future<Wallet>? _walletFuture;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  void _loadWalletData() {
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
    } else {
      // Jika dompet tidak ditemukan, buat dompet baru untuk pengguna
      if (response.statusCode == 404) {
        return Wallet(balance: 0, transactions: []);
      }
      throw Exception('Failed to load wallet data: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Dompetku', style: TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: _loadWalletData, // Tombol refresh
                  )
                ],
              ),
            ),
            
            // Konten Utama
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
                    return const Center(child: Text('Tidak dapat memuat data dompet.', style: TextStyle(color: Colors.white)));
                  }

                  final wallet = snapshot.data!;
                  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

                  return Column(
                    children: [
                      // Balance Card
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF8FD14F), Color(0xFF7BC142)]),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Saldo', style: TextStyle(color: Colors.white, fontSize: 16)),
                            const SizedBox(height: 12),
                            Text(currencyFormatter.format(wallet.balance), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      
                      // Transaction History Header
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Icon(Icons.history, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Riwayat Transaksi', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      
                      // Transaction List
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: wallet.transactions.isEmpty
                              ? const Center(child: Text("Belum ada transaksi.", style: TextStyle(color: Colors.white70)))
                              : ListView.builder(
                                  itemCount: wallet.transactions.length,
                                  itemBuilder: (context, index) {
                                    final tx = wallet.transactions[index];
                                    return _buildTransactionItem(
                                      description: tx.description,
                                      amount: currencyFormatter.format(tx.amount),
                                      date: DateFormat('dd MMM yyyy, HH:mm').format(tx.createdAt),
                                    );
                                  },
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
    );
  }

  Widget _buildTransactionItem({required String description, required String amount, required String date}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: const Icon(Icons.arrow_downward, color: Colors.green),
        title: Text(description, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(date),
        trailing: Text(amount, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
      ),
    );
  }
}