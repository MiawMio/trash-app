import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();

  // Fungsi _logout yang diubah untuk menampilkan dialog konfirmasi
  Future<void> _logout(BuildContext context) async {
    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false); // Tidak jadi logout
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true); // Konfirmasi logout
              },
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) { // Hanya jika pengguna mengkonfirmasi logout
      try {
        await AuthService().signOut();
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
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
                  // Logo
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
                  // Profile title
                  const Text(
                    'Profile',
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

            // Profile Card with real-time updates
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: StreamBuilder<Map<String, dynamic>>(
                stream: _profileService.getProfileStream(),
                builder: (context, snapshot) {
                  final profileData = snapshot.data ?? {};
                  final photoUrl = profileData['photoUrl'];
                  final name = profileData['name'] ?? 'Masukan Nama';
                  final email = profileData['email'] ?? 'email@example.com';

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Profile Image
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryGreen,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: photoUrl != null
                                ? (photoUrl.startsWith('http')
                                    ? Image.network(
                                        photoUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.purple.shade100,
                                            child: const Icon(
                                              Icons.person,
                                              size: 50,
                                              color: Colors.purple,
                                            ),
                                          );
                                        },
                                      )
                                    : Image.file(
                                        File(photoUrl),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.purple.shade100,
                                            child: const Icon(
                                              Icons.person,
                                              size: 50,
                                              color: Colors.purple,
                                            ),
                                          );
                                        },
                                      ))
                                : Container(
                                    color: Colors.purple.shade100,
                                    child: const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.purple,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Name
                        Text(
                          name,
                          style: const TextStyle(
                            color: AppColors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        // Email
                        Text(
                          email,
                          style: TextStyle(
                            color: AppColors.grey.withOpacity(0.8),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 20),

                        // Edit Button
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB8E6C1),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'EDIT',
                                style: TextStyle(
                                  color: AppColors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            // Keluar Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: GestureDetector(
                onTap: () => _logout(context), // Memanggil fungsi _logout yang kini memiliki dialog
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB8E6C1),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'KELUAR',
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),
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
}