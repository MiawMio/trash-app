import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class BankSampahInfoScreen extends StatelessWidget {
  const BankSampahInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: SafeArea(
        child: Column(
          children: [
            // Header with logo and title
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
                  // Logo with leaf design
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
            
            // Main content area
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Title section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'TENTANG',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'BANK SAMPAH ROSELLA',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Character image section
                    Expanded(
                      flex: 2,
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: AppColors.primaryGreen,
                            width: 3,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.purple.shade200,
                                  Colors.purple.shade100,
                                  Colors.white,
                                ],
                              ),
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person,
                                    size: 80,
                                    color: Colors.purple,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Karakter Maskot\nBank Sampah Rosella',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.purple,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Text content section
                    Expanded(
                      flex: 2,
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: AppColors.primaryGreen,
                            width: 2,
                          ),
                        ),
                        child: const SingleChildScrollView(
                          child: Text(
                            'Bank Sampah Rosella adalah sebuah inisiatif komunitas yang bertujuan untuk mengelola sampah dengan cara yang berkelanjutan dan ramah lingkungan. \n\n'
                            'Kami berkomitmen untuk:\n'
                            '• Mengurangi volume sampah yang berakhir di TPA\n'
                            '• Memberikan nilai ekonomis pada sampah yang dapat didaur ulang\n'
                            '• Meningkatkan kesadaran masyarakat tentang pengelolaan sampah\n'
                            '• Menciptakan lingkungan yang lebih bersih dan sehat\n\n'
                            'Bergabunglah dengan kami dalam misi menjaga kelestarian lingkungan melalui pengelolaan sampah yang bijak dan bertanggung jawab.',
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: 14,
                              height: 1.5,
                              letterSpacing: 0.3,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
                Navigator.popUntil(context, (route) => route.isFirst);
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
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                child: const Icon(
                  Icons.grid_view,
                  color: AppColors.primaryGreen,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}