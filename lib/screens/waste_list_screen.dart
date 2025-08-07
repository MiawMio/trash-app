import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/waste_service.dart';

class WasteListScreen extends StatefulWidget {
  const WasteListScreen({super.key});

  @override
  State<WasteListScreen> createState() => _WasteListScreenState();
}

class _WasteListScreenState extends State<WasteListScreen> {
  final WasteService _wasteService = WasteService();
  bool _isLoading = false;

  // Fungsi untuk menampilkan dialog setor sampah
  void _showSubmitDialog(String categoryId, String categoryName) {
    final weightController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Setor Sampah $categoryName'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Berat (dalam gram)',
                hintText: 'Contoh: 1500',
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
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final weight = double.parse(weightController.text);
                  Navigator.pop(context); // Tutup dialog
                  _handleSubmit(categoryId, weight);
                }
              },
              child: const Text('Setor'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menangani proses submit
  Future<void> _handleSubmit(String categoryId, double weight) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _wasteService.submitWaste(
        categoryId: categoryId,
        weightInGrams: weight,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sampah berhasil disetor, saldo diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyetor sampah: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
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
                          child: const Icon(
                            Icons.arrow_back,
                            color: AppColors.primaryGreen,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.eco,
                          color: AppColors.primaryGreen,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'List Sampah',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildWasteItem(
                          categoryId: 'plastik', // Gunakan ID dari Firestore
                          icon: Icons.local_drink,
                          iconColor: Colors.blue.shade600,
                          title: 'Plastik',
                          price: 'Rp. 1000 Per Gram',
                          backgroundColor: const Color(0xFFD4E7DD),
                        ),
                        const SizedBox(height: 16),
                        _buildWasteItem(
                          categoryId: 'kertas',
                          icon: Icons.description,
                          iconColor: Colors.grey.shade600,
                          title: 'Kertas',
                          price: 'Rp. 100 Per Gram',
                          backgroundColor: const Color(0xFFD4E7DD),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
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

  Widget _buildWasteItem({
    required String categoryId,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String price,
    required Color backgroundColor,
  }) {
    return GestureDetector(
      onTap: () => _showSubmitDialog(categoryId, title),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: TextStyle(
                    color: AppColors.black.withOpacity(0.7),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}