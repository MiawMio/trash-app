import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';

class AdminApprovalScreen extends StatefulWidget {
  const AdminApprovalScreen({super.key});

  @override
  State<AdminApprovalScreen> createState() => _AdminApprovalScreenState();
}

class _AdminApprovalScreenState extends State<AdminApprovalScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _processSubmission(String submissionId, String action) async {
    final String urlPath = action == 'approve'
        ? 'https://trash-api-azure.vercel.app/api/approve' // <-- URL BARU DAN BERSIH
        : 'https://trash-api-azure.vercel.app/api/reject'; // <-- URL BARU DAN BERSIH
    final url = Uri.parse(urlPath);
    
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Aksi'),
          content: Text('Apakah Anda yakin ingin ${action == 'approve' ? 'menyetujui' : 'menolak'} setoran ini?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              child: Text(action == 'approve' ? 'Setujui' : 'Tolak'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'submissionId': submissionId,
      }),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.statusCode == 200
              ? 'Aksi berhasil!'
              : 'Aksi gagal. Status: ${response.statusCode} - ${response.body}'),
          backgroundColor: response.statusCode == 200 ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: SafeArea(
        child: Column(
          children: [
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
                  const Text('Persetujuan Setoran', style: TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('wasteSubmissions')
                    .where('status', isEqualTo: 'pending')
                    .orderBy('created_at', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white,));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Tidak ada setoran untuk disetujui.', style: TextStyle(color: Colors.white)));
                  }

                  return ListView(
                    padding: const EdgeInsets.all(10),
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final timestamp = data['created_at'] as Timestamp?;
                      final date = timestamp?.toDate();
                      final formattedDate = date != null ? DateFormat('dd MMM yyyy, HH:mm').format(date) : 'No date';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text('${data['user_name'] ?? 'No Name'} - ${data['category_name']}'),
                          subtitle: Text('${data['weight_in_grams']} gram - Diajukan pada $formattedDate'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check_circle, color: Colors.green, size: 30),
                                onPressed: () => _processSubmission(doc.id, 'approve'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel, color: Colors.red, size: 30),
                                onPressed: () => _processSubmission(doc.id, 'reject'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
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