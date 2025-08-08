import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';

class AdminWithdrawalApprovalScreen extends StatefulWidget {
  const AdminWithdrawalApprovalScreen({super.key});

  @override
  State<AdminWithdrawalApprovalScreen> createState() => _AdminWithdrawalApprovalScreenState();
}

class _AdminWithdrawalApprovalScreenState extends State<AdminWithdrawalApprovalScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _processRequest(String requestId, String action) async {
    final url = action == 'approve'
        ? Uri.parse('https://trash-api-azure.vercel.app/api/approve-withdrawal')
        : Uri.parse('https://trash-api-azure.vercel.app/api/reject-withdrawal');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'requestId': requestId}),
    );

    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.statusCode == 200 ? 'Aksi berhasil!' : 'Gagal: ${jsonDecode(response.body)['error']}'),
          backgroundColor: response.statusCode == 200 ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Persetujuan Penarikan')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('withdrawalRequests')
            .where('status', isEqualTo: 'pending')
            .orderBy('requested_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Tidak ada permintaan penarikan.'));
          }

          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final date = (data['requested_at'] as Timestamp?)?.toDate();
              final formattedDate = date != null ? DateFormat('dd MMM yyyy, HH:mm').format(date) : 'No date';
              final amount = (data['amount'] as num).toDouble();
              final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  title: Text(data['user_name'] ?? 'Unknown User'),
                  subtitle: Text('Jumlah: ${currencyFormatter.format(amount)}\nPada: $formattedDate'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () => _processRequest(doc.id, 'approve'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => _processRequest(doc.id, 'reject'),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}