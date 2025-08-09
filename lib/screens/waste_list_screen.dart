import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:trash_app/services/auth_service.dart';
import 'package:trash_app/models/waste_category.dart';
import '../constants/app_colors.dart';

class WasteListScreen extends StatefulWidget {
  const WasteListScreen({super.key});

  @override
  State<WasteListScreen> createState() => _WasteListScreenState();
}

class _WasteListScreenState extends State<WasteListScreen> {
  late Future<List<WasteCategory>> _wasteCategoriesFuture;

  @override
  void initState() {
    super.initState();
    _wasteCategoriesFuture = _fetchWasteCategories();
  }

  Future<List<WasteCategory>> _fetchWasteCategories() async {
    final response = await http.get(Uri.parse('https://trash-api-azure.vercel.app/api/waste-categories'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => WasteCategory.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load waste categories');
    }
  }

  void _showSubmissionDialog(WasteCategory category) {
    final weightController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final authService = AuthService();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Setor ${category.name}'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Menampilkan harga dan unit yang benar
                Text('Harga: Rp ${category.price.toStringAsFixed(0)} / ${category.unit}'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    // Mengubah label input menjadi kg
                    labelText: 'Berat (kg)', 
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Berat tidak boleh kosong';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Masukkan angka yang valid';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final userId = authService.currentUser?.uid;
                  if (userId == null) return;
                  
                  // Konversi input kg ke gram sebelum dikirim ke API
                  final weightInKg = double.parse(weightController.text);
                  final weightInGrams = weightInKg * 1000;

                  final response = await http.post(
                    Uri.parse('https://trash-api-azure.vercel.app/api/submissions'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'userId': userId,
                      'categoryId': category.id,
                      'weightInGrams': weightInGrams, // API tetap menerima dalam gram
                    }),
                  );

                  Navigator.pop(context); // Close dialog

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response.statusCode == 200
                          ? 'Pengajuan berhasil!'
                          : 'Gagal mengajukan.'),
                      backgroundColor: response.statusCode == 200 ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Ajukan'),
            ),
          ],
        );
      },
    );
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
                  const Text('List Sampah', style: TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<WasteCategory>>(
                future: _wasteCategoriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Tidak ada data sampah.', style: TextStyle(color: Colors.white)));
                  }

                  final categories = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return _buildWasteItem(
                        category: category,
                        icon: _getIconForCategory(category.name),
                        onTap: () => _showSubmissionDialog(category),
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

  Widget _buildWasteItem({required WasteCategory category, required IconData icon, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 40, color: AppColors.primaryGreen),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  // Menampilkan harga per unit yang benar (kg atau gram)
                  Text('Rp ${category.price.toStringAsFixed(0)} / ${category.unit}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  IconData _getIconForCategory(String name) {
    switch (name.toLowerCase()) {
      case 'kertas':
        return Icons.description;
      case 'plastik':
        return Icons.local_drink;
      case 'kaca':
        return Icons.broken_image;
      case 'logam':
        return Icons.construction;
      default:
        return Icons.recycling;
    }
  }
}