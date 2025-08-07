import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/app_colors.dart';
import '../services/auth_service.dart'; // Dibutuhkan untuk mendapatkan user ID

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late Future<Map<String, dynamic>> _walletData;

  @override
  void initState() {
    super.initState();
    _walletData = fetchWalletData();
  }

  Future<Map<String, dynamic>> fetchWalletData() async {
    // 1. Dapatkan User ID dari pengguna yang sedang login
    final userId = AuthService().currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    // 2. GUNAKAN URL VERCEL ANDA DI SINI
    final url = Uri.parse(
        'https://trash-api-azure.vercel.app/api/wallet/$userId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      // Jika dompet belum ada, tampilkan saldo 0
      return {'balance': 0, 'transactions': []};
    } else {
      throw Exception('Failed to load wallet data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _walletData,
          builder: (context, snapshot) {
            // Saat data sedang dimuat
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.white));
            }

            // Jika terjadi error
            if (snapshot.hasError) {
              return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white)));
            }

            // Jika data berhasil dimuat
            if (snapshot.hasData) {
              final walletData = snapshot.data!;
              final balance = walletData['balance'];
              final transactions = (walletData['transactions'] as List?) ?? [];

              return Column(
                children: [
                  // Header (tetap sama)
                   Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // Back button
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: AppColors.primaryGreen,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Wallet icon
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            color: AppColors.primaryGreen,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Title
                        const Text(
                          'Dompetku',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Balance Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF8FD14F),
                          Color(0xFF7BC142),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                       const Row(
                          children: [
                             Icon(
                              Icons.account_balance_wallet,
                              color: Colors.white,
                              size: 24,
                            ),
                             SizedBox(width: 8),
                             Text(
                              'Total Balance',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                             Spacer(),
                             Icon(
                              Icons.visibility,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Rp.$balance',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Transaction History Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.history,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Short by',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Last 24h',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Transaction List
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: transactions.isEmpty
                          ? const Center(
                              child: Text(
                              'Belum ada transaksi.',
                              style: TextStyle(color: Colors.white),
                            ))
                          : ListView.builder(
                              itemCount: transactions.length,
                              itemBuilder: (context, index) {
                                final transaction = transactions[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: _buildTransactionItem(
                                    description: transaction['description'],
                                    amount: 'Rp.${transaction['amount']}',
                                    isSuccess: transaction['type'] == 'credit',
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              );
            }
            // Fallback jika tidak ada data
            return const Center(
                child: Text('Tidak dapat memuat data.',
                    style: TextStyle(color: Colors.white)));
          },
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                child: const Icon(
                  Icons.home,
                  color: AppColors.grey,
                  size: 28,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: const Icon(
                Icons.grid_view,
                color: AppColors.primaryGreen,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required String description,
    required String amount,
    required bool isSuccess,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Transaction icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSuccess ? Colors.green.shade100 : Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.attach_money,
              color: isSuccess ? Colors.green.shade600 : Colors.red.shade600,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Transaction details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description, // Menggunakan deskripsi dinamis
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: const TextStyle(
                    color: AppColors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}