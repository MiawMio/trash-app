import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class BankSampahInfoScreen extends StatelessWidget {
  // Tidak perlu lagi menerima role
  const BankSampahInfoScreen({super.key});

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
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.primaryGreen,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Informasi',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Konten Utama
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'TENTANG BANK SAMPAH ROSELLA',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Bank Sampah Rosella adalah sebuah inisiatif komunitas yang bertujuan untuk mengelola sampah dengan cara yang berkelanjutan dan ramah lingkungan. Bank Sampah Rosella Berdiri Berasal dari Inovasi Kelurahan Parittokaya Tahun 2013 Oleh Almarhumah Bu Endah Lurah. \n\n'
                        'Kami berkomitmen untuk:\n'
                        '• Mengurangi volume sampah yang berakhir di TPA\n'
                        '• Memberikan nilai ekonomis pada sampah yang dapat didaur ulang\n'
                        '• Meningkatkan kesadaran masyarakat tentang pengelolaan sampah\n'
                        '• Menciptakan lingkungan yang lebih bersih dan sehat\n\n',
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 14,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      
                      // Tombol khusus admin sudah dihapus dari sini
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}