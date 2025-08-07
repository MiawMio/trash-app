import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../widgets/app_logo.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';
import 'home_screen.dart';
import 'login_screen.dart'; // Pastikan ini mengarah ke LoginScreen yang benar

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.registerWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.registerSuccess),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.registerFailed}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      resizeToAvoidBottomInset: true, // Pastikan ini true untuk penyesuaian keyboard
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Top section with green background and logo
              Expanded(
                flex: 1, // Mengurangi flex menjadi 1 (dari 1) untuk memberikan lebih banyak ruang ke bawah
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(60),
                      bottomRight: Radius.circular(60),
                    ),
                  ),
                  child: const Center(
                    child: AppLogo(size: 80),
                  ),
                ),
              ),
              
              // Bottom section with register form
              Expanded(
                flex: 4, // Meningkatkan flex menjadi 4 (dari 4) untuk memberikan lebih banyak ruang
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10), // Mengurangi tinggi SizedBox sebelum judul
                      
                      // Register title
                      const Text(
                        AppStrings.register,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Subtitle
                      const Text(
                        'Create your account',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.grey,
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Name field
                      CustomTextField(
                        label: AppStrings.name,
                        hintText: 'Enter your name',
                        controller: _nameController,
                        validator: Validators.validateName,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Email field
                      CustomTextField(
                        label: AppStrings.email,
                        hintText: 'Enter your email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.validateEmail,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Password field
                      CustomTextField(
                        label: AppStrings.password,
                        hintText: '******',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        validator: Validators.validatePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Confirm Password field
                      CustomTextField(
                        label: AppStrings.confirmPassword,
                        hintText: '******',
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        validator: (value) => Validators.validateConfirmPassword(
                          value,
                          _passwordController.text,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Register button
                      CustomButton(
                        text: AppStrings.register,
                        onPressed: _register,
                        isLoading: _isLoading,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Login link
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              AppStrings.haveAccount,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.grey,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                AppStrings.login,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.primaryGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20), // Tambahkan ruang di bagian bawah
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
