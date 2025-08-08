import 'package:flutter/material.dart';
import 'package:trash_app/screens/admin_approval_screen.dart';
import 'package:trash_app/screens/wallet_screen.dart';
import '../constants/app_colors.dart';
import '../services/profile_service.dart';
import 'profile_screen.dart';
import 'bank_sampah_info_screen.dart';
import 'waste_list_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final ProfileService _profileService = ProfileService();
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    try {
      final profile = await _profileService.getUserProfile();
      if (mounted) {
        setState(() {
          _userRole = profile['role'];
        });
      }
    } catch (e) {
      // Handle error
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
                    'Menu',
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
                    // HANYA MUNCUL JIKA ROLE ADALAH ADMIN
                    if (_userRole == 'admin')
                      _buildMenuItem(
                        icon: Icons.approval,
                        iconColor: Colors.blueAccent,
                        title: 'Persetujuan\nSetoran',
                        backgroundColor: Colors.blue.shade100,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AdminApprovalScreen()),
                          );
                        },
                      ),
                    
                    // HANYA MUNCUL JIKA ROLE ADALAH USER
                    if (_userRole == 'user')
                      Column(
                        children: [
                          // 'List Sampah' sekarang menjadi menu utama untuk user
                          _buildMenuItem(
                            icon: Icons.delete_outline,
                            iconColor: AppColors.primaryGreen,
                            title: 'List\nSampah',
                            backgroundColor: const Color(0xFFE8F5E8),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const WasteListScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    
                    // MENU YANG MUNCUL UNTUK SEMUA ROLE
                    const SizedBox(height: 20),
                    _buildMenuItem(
                      icon: Icons.account_balance_wallet,
                      iconColor: Colors.orange.shade700,
                      title: 'Dompetku',
                      backgroundColor: Colors.orange.shade100,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const WalletScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildMenuItem(
                      icon: Icons.info_outline,
                      iconColor: Colors.green.shade600,
                      title: 'Informasi Bank\nSampah',
                      backgroundColor: Colors.lightGreen.shade100,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BankSampahInfoScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      iconColor: AppColors.black,
                      title: 'Profile',
                      backgroundColor: Colors.grey.shade200,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProfileScreen()),
                        );
                      },
                    ),
                    const Spacer(),
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

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 30,
              ),
            ),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}