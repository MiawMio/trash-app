import 'package:flutter/material.dart';
import 'package:trash_app/services/waste_submission_service.dart';
import '../constants/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class SubmitWasteScreen extends StatefulWidget {
  const SubmitWasteScreen({super.key});

  @override
  State<SubmitWasteScreen> createState() => _SubmitWasteScreenState();
}

class _SubmitWasteScreenState extends State<SubmitWasteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _wasteSubmissionService = WasteSubmissionService();
  String? _selectedWasteType = 'Plastik';
  bool _isLoading = false;

  final List<String> _wasteTypes = ['Plastik', 'Kertas', 'Kaca', 'Logam'];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _wasteSubmissionService.submitWaste(
        _selectedWasteType!,
        double.parse(_weightController.text.trim()),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Setoran sampah berhasil diajukan!'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengajukan setoran: $e'),
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
                  const Text('Setor Sampah', style: TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _selectedWasteType,
                        items: _wasteTypes.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedWasteType = newValue;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Jenis Sampah',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'BERAT (GRAM)',
                        controller: _weightController,
                        keyboardType: TextInputType.number,
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
                      const SizedBox(height: 40),
                      CustomButton(
                        text: 'AJUKAN',
                        onPressed: _submit,
                        isLoading: _isLoading,
                      ),
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