import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../services/api_service.dart';

class InvoiceHistoryScreen extends StatefulWidget {
  const InvoiceHistoryScreen({super.key});

  @override
  State<InvoiceHistoryScreen> createState() => _InvoiceHistoryScreenState();
}

class _InvoiceHistoryScreenState extends State<InvoiceHistoryScreen> {
  List<Invoice> _invoices = [];
  bool _isLoading = true;
  bool _hasError = false;

  // Color Scheme matching dashboard
  final Color _primaryColor = const Color(0xFFC62828);
  final Color _secondaryColor = const Color(0xFF8E0000);
  final Color _tertiaryColor = const Color(0xFFEF5350);
  final Color _surfaceColor = const Color(0xFFFFFFFF);
  final Color _onSurfaceColor = const Color(0xFF1F2937);
  final Color _surfaceVariantColor = const Color(0xFFE5E7EB);
  final Color _primaryContainerColor = const Color(0xFFFFE5E5);

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    try {
      if (!mounted) return;

      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final data = await ApiService().getInvoices();

      if (!mounted) return;

      setState(() {
        _invoices = data;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _hasError = true;
      });
      _showErrorSnackbar('Gagal memuat history invoice');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _showImageModal(String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(Invoice invoice, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Material(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20),
        elevation: 2,
        shadowColor: Colors.black,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _surfaceVariantColor.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Background Accent berdasarkan status
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        _getStatusColor(invoice.status).withOpacity(0.1),
                        _getStatusColor(invoice.status).withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Header dengan status badge yang elegant
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            _primaryColor.withOpacity(0.05),
                            _primaryContainerColor.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _primaryColor.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: _primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.receipt_long_rounded,
                                  size: 18,
                                  color: _primaryColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatDateTime(invoice.createdAt),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: _primaryColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                invoice.status,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getStatusColor(
                                  invoice.status,
                                ).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(invoice.status),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _getStatusText(invoice.status),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _getStatusColor(invoice.status),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Content Area dengan layout yang clean
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Gambar Invoice dengan frame modern
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _surfaceVariantColor,
                              width: 1,
                            ),
                            image: invoice.fileUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(invoice.fileUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            color: invoice.fileUrl == null
                                ? _surfaceVariantColor
                                : null,
                          ),
                          child: invoice.fileUrl == null
                              ? Center(
                                  child: Icon(
                                    Icons.receipt_rounded,
                                    size: 32,
                                    color: _onSurfaceColor.withOpacity(0.3),
                                  ),
                                )
                              : InkWell(
                                  onTap: () =>
                                      _showImageModal(invoice.fileUrl!),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.black.withOpacity(0.2),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.zoom_in_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                        ),

                        const SizedBox(width: 16),

                        // Info Section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Sales Code dengan icon
                              Row(
                                children: [
                                  Icon(
                                    Icons.badge_rounded,
                                    size: 14,
                                    color: _primaryColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Sales Code: ${invoice.salesCode}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _onSurfaceColor.withOpacity(0.6),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // Store Info
                              Row(
                                children: [
                                  Icon(
                                    Icons.store_rounded,
                                    size: 14,
                                    color: _tertiaryColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Rp ${_formatCurrency(invoice.totalAmount)}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: _onSurfaceColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Points Earned
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  // color: Colors.orange.withOpacity(0.1),
                                  color: _getStatusColor(
                                    invoice.status,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _getStatusColor(
                                      invoice.status,
                                    ).withOpacity(0.4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.auto_awesome_rounded,
                                      size: 12,
                                      color: _getStatusColor(invoice.status),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '+${(invoice.pointEarned)} Poin',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: _getStatusColor(invoice.status),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Amount Section dengan design premium
                        Container(
                          padding: const EdgeInsets.only(right: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/logo/1.png',
                                width: 60,
                                height: 60,
                                // color: Colors,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Divider dengan aksen
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            _surfaceVariantColor,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _primaryColor.withOpacity(0.1),
                    _primaryContainerColor.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 50,
                color: _primaryColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Invoice',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _onSurfaceColor,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload invoice pertama Anda untuk\nmengumpulkan poin reward',
              style: TextStyle(
                color: _onSurfaceColor.withOpacity(0.6),
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryColor, _secondaryColor],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/upload_invoice');
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: const Center(
                    child: Text(
                      'Upload Invoice Pertama',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: _surfaceVariantColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 50,
                color: _onSurfaceColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Gagal Memuat Data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _onSurfaceColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Silakan coba lagi beberapa saat',
              style: TextStyle(
                color: _onSurfaceColor.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: _primaryColor),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _loadInvoices,
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: Text(
                      'Coba Lagi',
                      style: TextStyle(
                        color: _primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: _surfaceVariantColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _surfaceVariantColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          width: 120,
                          decoration: BoxDecoration(
                            color: _surfaceVariantColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 14,
                          width: 80,
                          decoration: BoxDecoration(
                            color: _surfaceVariantColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _surfaceVariantColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper methods
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFA000);
      case 'approved':
        return const Color(0xFF4CAF50);
      case 'rejected':
        return const Color(0xFFF44336);
      default:
        return _onSurfaceColor.withOpacity(0.5);
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  String _formatDateTime(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? _buildLoadingState()
          : _hasError
          ? _buildErrorState()
          : _invoices.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadInvoices,
              backgroundColor: _surfaceColor,
              color: _primaryColor,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: _invoices
                    .map(
                      (invoice) => _buildInvoiceCard(
                        invoice,
                        _invoices.indexOf(invoice),
                      ),
                    )
                    .toList(),
              ),
            ),
    );
  }
}
