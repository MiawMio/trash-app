import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trash_app/services/auth_service.dart';
import '../constants/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class RequestWithdrawalScreen extends StatefulWidget {
  final double currentBalance;
  const RequestWithdrawalScreen({super.key, required this.currentBalance});

  @override
  State<RequestWithdrawalScreen> createState() => _RequestWithdrawalScreenState();
}

class _RequestWithdrawalScreenState extends State<RequestWithdrawalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengguna tidak ditemukan.')));
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://trash-api-azure.vercel.app/api/request-withdrawal'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'amount': double.parse(_amountController.text),
        }),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.statusCode == 200 ? 'Permintaan penarikan berhasil diajukan.' : 'Gagal: ${jsonDecode(response.body)['error']}'),
            backgroundColor: response.statusCode == 200 ? Colors.green : Colors.red,
          ),
        );
        if (response.statusCode == 200) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Terjadi error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tarik Dana')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Saldo Anda saat ini: Rp ${widget.currentBalance.toStringAsFixed(0)}'),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'JUMLAH PENARIKAN',
                controller: _amountController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Jumlah tidak boleh kosong';
                  final amount = double.tryParse(value);
                  if (amount == null) return 'Masukkan angka yang valid';
                  if (amount <= 0) return 'Jumlah harus lebih dari 0';
                  if (amount > widget.currentBalance) return 'Saldo tidak mencukupi';
                  return null;
                },
              ),
              const SizedBox(height: 30),
              CustomButton(
                text: 'AJUKAN PENARIKAN',
                onPressed: _submitRequest,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}