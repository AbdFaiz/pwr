import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class UploadInvoiceScreen extends StatefulWidget {
  const UploadInvoiceScreen({super.key});

  @override
  State<UploadInvoiceScreen> createState() => _UploadInvoiceScreenState();
}

class _UploadInvoiceScreenState extends State<UploadInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  XFile? _image;
  final _totalAmountController = TextEditingController();
  final _salesCodeController = TextEditingController();
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _totalAmountController.dispose();
    _salesCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Invoice'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar Invoice Section
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Foto Invoice',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_image != null)
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.colorScheme.outline.withOpacity(
                                  0.3,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(_image!.path),
                                fit: BoxFit.contain,
                              ),
                            ),
                          )
                        else
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.colorScheme.outline.withOpacity(
                                  0.3,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: theme.colorScheme.surfaceVariant,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long_rounded,
                                  size: 64,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Belum ada gambar',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Ambil Gambar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Form Section
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Detail Invoice',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _totalAmountController,
                          decoration: InputDecoration(
                            labelText: 'Total Amount',
                            hintText: 'Masukkan total amount',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.monetization_on_rounded,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Total amount wajib diisi';
                            }
                            final number = double.tryParse(
                              value.replaceAll(',', '.'),
                            );
                            if (number == null || number <= 0) {
                              return 'Harus angka positif';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _salesCodeController,
                          decoration: InputDecoration(
                            labelText: 'Sales Code',
                            hintText: 'Masukkan kode sales',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.tag_rounded,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Sales code wajib diisi';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Upload Button
                if (_image != null)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: _isLoading
                        ? ElevatedButton(
                            onPressed: null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: _handleUpload,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'Upload Invoice',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      XFile? image;

      if (kIsWeb ||
          Platform.isLinux ||
          Platform.isWindows ||
          Platform.isMacOS) {
        image = await _picker.pickImage(source: ImageSource.gallery);
      } else {
        // Show option dialog for mobile
        final source = await showDialog<ImageSource>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Pilih Sumber Gambar'),
            content: const Text('Pilih kamera atau galeri?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, ImageSource.camera),
                child: const Text('Kamera'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, ImageSource.gallery),
                child: const Text('Galeri'),
              ),
            ],
          ),
        );

        if (source != null) {
          image = await _picker.pickImage(source: source);
        }
      }

      if (image != null) {
        setState(() {
          _image = image;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Gagal mengambil gambar: $e');
    }
  }

  void _handleUpload() async {
    // Unfocus keyboard first
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate() && _image != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await ApiService().uploadInvoice(
          totalAmount: double.parse(
            _totalAmountController.text.replaceAll(',', '.'),
          ),
          salesCode: _salesCodeController.text,
          imagePath: _image!.path,
        );

        // Handle different response formats
        if (response['status'] == 'success' || response['success'] == true) {
          _showSuccessSnackBar('Invoice berhasil diupload!');
          if (mounted) {
            Navigator.pop(context);
          }
        } else {
          final message = _parseErrorMessage(response);
          _showErrorSnackBar(message);
        }
            } catch (e) {
        final errorMessage = _parseDioError(e);
        _showErrorSnackBar(errorMessage);
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      _showErrorSnackBar('Harap lengkapi semua field dan ambil gambar invoice');
    }
  }

  String _parseErrorMessage(Map<String, dynamic> response) {
    try {
      dynamic message = response['message'];

      if (message == null) {
        return 'Upload gagal';
      }

      if (message is String) {
        return message;
      } else if (message is List) {
        return message.isNotEmpty ? message.first.toString() : 'Upload gagal';
      } else if (message is Map) {
        // Handle validation errors
        final firstError = message.values.first;
        if (firstError is List) {
          return firstError.isNotEmpty
              ? firstError.first.toString()
              : 'Validation error';
        }
        return firstError.toString();
      }

      return message.toString();
    } catch (e) {
      return 'Terjadi kesalahan saat memproses response';
    }
  }

  String _parseDioError(dynamic e) {
    if (e is DioException) {
      if (e.response?.data != null) {
        try {
          final responseData = e.response!.data;
          if (responseData is Map) {
            return _parseErrorMessage(Map<String, dynamic>.from(responseData));
          } else if (responseData is String) {
            return responseData;
          }
        } catch (parseError) {
          return 'Error: ${e.message}';
        }
      }
      return 'Network error: ${e.message}';
    }
    return 'Error: $e';
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
