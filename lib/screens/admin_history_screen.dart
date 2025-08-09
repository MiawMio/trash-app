import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';

// Model untuk data riwayat
class SubmissionHistory {
  final String userName;
  final String categoryName;
  final double weight;
  final String status;
  final DateTime processedAt;

  SubmissionHistory({
    required this.userName,
    required this.categoryName,
    required this.weight,
    required this.status,
    required this.processedAt,
  });

  factory SubmissionHistory.fromJson(Map<String, dynamic> json) {
    // Parsing waktu dari string ISO 8601 (UTC)
    final utcTime = json['processed_at'] != null
        ? DateTime.parse(json['processed_at'])
        : DateTime.now();
        
    return SubmissionHistory(
      userName: json['user_name'] ?? 'Unknown User',
      categoryName: json['category_name'] ?? 'No Category',
      weight: (json['weight_in_grams'] as num).toDouble(),
      status: json['status'] ?? 'unknown',
      // BAGIAN YANG DIPERBAIKI: Konversi waktu UTC ke waktu lokal perangkat
      processedAt: utcTime.toLocal(),
    );
  }
}

class AdminHistoryScreen extends StatefulWidget {
  const AdminHistoryScreen({super.key});

  @override
  State<AdminHistoryScreen> createState() => _AdminHistoryScreenState();
}

class _AdminHistoryScreenState extends State<AdminHistoryScreen> {
  late Future<List<SubmissionHistory>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _fetchHistory();
  }

  Future<List<SubmissionHistory>> _fetchHistory() async {
    final response = await http.get(Uri.parse('https://trash-api-azure.vercel.app/api/history'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => SubmissionHistory.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load history');
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
                  const Text('History Penyetujuan', style: TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<SubmissionHistory>>(
                future: _historyFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Belum ada riwayat.', style: TextStyle(color: Colors.white)));
                  }

                  final historyList = snapshot.data!;

                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: historyList.length,
                    itemBuilder: (context, index) {
                      final item = historyList[index];
                      final isApproved = item.status == 'approved';
                      final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(item.processedAt);
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: Icon(
                            isApproved ? Icons.check_circle : Icons.cancel,
                            color: isApproved ? Colors.green : Colors.red,
                          ),
                          title: Text('${item.userName} - ${item.categoryName}'),
                          subtitle: Text('${item.weight} gram - ${formattedDate}'),
                          trailing: Text(
                            isApproved ? 'Disetujui' : 'Ditolak',
                            style: TextStyle(
                              color: isApproved ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 