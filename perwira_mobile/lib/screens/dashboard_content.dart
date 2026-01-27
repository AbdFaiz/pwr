import 'package:flutter/material.dart';
import 'package:perwira_mobile/screens/main_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  bool _isLoading = false;
  Map<String, dynamic>? _dashboardData;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      await Provider.of<AuthProvider>(context, listen: false).loadDashboard();
      if (!mounted) return;
      _dashboardData = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).dashboardData;
    } catch (e) {
      print('Load dashboard error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadDashboardData();
    await Provider.of<AuthProvider>(context, listen: false).loadUser();
  }

  Widget _buildCustomerDashboard(AuthProvider authProvider, ThemeData theme) {
    final pointsSummary = _dashboardData?['points_summary'];
    final recentActivities = _dashboardData?['recent_activities'];

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Hero Section dengan gradient seperti website
            _buildHeroSection(authProvider, theme),
            const SizedBox(height: 24),

            // Points Card dengan design modern
            _buildPointsCard(pointsSummary, theme),
            const SizedBox(height: 20),

            // Quick Actions dalam 1 row
            _buildQuickActionsRow(theme),
            const SizedBox(height: 20),

            // Recent Activities
            if (recentActivities != null)
              _buildRecentActivities(recentActivities, theme),

            // Product Showcase - Produk Perwira Steel
            _buildProductShowcase(theme),
            const SizedBox(height: 20),

            // CTA untuk mengunjungi website
            _buildWebsiteCTA(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(AuthProvider authProvider, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFC62828), Color(0xFF8E0000), Color(0xFF5A0000)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red[900]!.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Welcome
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  'assets/logo/1.png',
                  width: 40,
                  height: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PERWIRA STEEL',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2.0,
                      ),
                    ),
                    Text(
                      'Besi Beton Andalan Indonesia',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Welcome Message
          Text(
            'Halo, ${authProvider.user?['name']?.split(' ')[0] ?? 'Mitra'}!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Terima kasih telah menjadi mitra terpercaya Perwira Steel',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // CTA Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.celebration_outlined, size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  'Kumpulkan Poin Sekarang',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsCard(
    Map<String, dynamic>? pointsSummary,
    ThemeData theme,
  ) {
    final currentPoints = pointsSummary?['current_points'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'REWARD POINTS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[600],
                  letterSpacing: 1.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.workspace_premium_outlined,
                      size: 12,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'PREMIUM',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Points Display
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.orange[50]!, Colors.orange[100]!],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$currentPoints',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.orange,
                        ),
                      ),
                      Text(
                        'Total Poin Anda',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsRow(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Akses Cepat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickActionItem(
                Icons.receipt_long_outlined,
                'Upload',
                Colors.red,
                () => Navigator.pushNamed(context, '/upload_invoice'),
              ),
              _buildQuickActionItem(
                Icons.history_outlined,
                'Riwayat',
                Colors.blue,
                () => _switchToTab(1),
              ),
              _buildQuickActionItem(
                Icons.card_giftcard_outlined,
                'Reward',
                Colors.green,
                () => _switchToTab(2),
              ),
              _buildQuickActionItem(
                Icons.person_outline,
                'Profil',
                Colors.purple,
                () => _switchToTab(3),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivities(
    Map<String, dynamic> activities,
    ThemeData theme,
  ) {
    final recentInvoices = activities['invoices'] ?? [];
    final recentRedemptions = activities['redemptions'] ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.update_outlined,
                  color: Colors.purple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Aktivitas Terbaru',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (recentInvoices.isNotEmpty) ...[
            ...recentInvoices
                .take(2)
                .map(
                  (invoice) => _buildActivityItem(
                    'Invoice ${invoice['status']}',
                    'Rp ${_formatCurrency(double.parse(invoice['total_amount'].toString()))}',
                    Icons.receipt_long_outlined,
                    _getStatusColor(invoice['status']),
                  ),
                ),
          ],

          if (recentRedemptions.isNotEmpty) ...[
            ...recentRedemptions
                .take(2)
                .map(
                  (redemption) => _buildActivityItem(
                    'Tukar ${redemption['reward_name']}',
                    '-${redemption['points_used']} poin',
                    Icons.card_giftcard_outlined,
                    Colors.orange,
                  ),
                ),
          ],

          if (recentInvoices.isEmpty && recentRedemptions.isEmpty)
            _buildEmptyActivities(),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyActivities() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'Belum ada aktivitas',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Mulai upload invoice untuk kumpulkan poin',
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductShowcase(ThemeData theme) {
    // Produk-produk dari perwirasteel.com/produk/
    final products = [
      _ProductItem('Besi Beton', 'assets/products/besi-beton.png'),
      _ProductItem('Billet Steel', 'assets/products/billet.png'),
      _ProductItem('Wiremesh', 'assets/products/wiremesh.png'),
      _ProductItem('Plat Baja', 'assets/products/plat-baja.png'),
      _ProductItem('CNP', 'assets/products/cnp.png'),
      _ProductItem('WF / H Beam', 'assets/products/wf-h-beam.png'),
      _ProductItem('Pipa', 'assets/products/pipa.png'),
      _ProductItem('Paku Beton', 'assets/products/paku-beton.png'),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Produk Perwira Steel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Solusi lengkap material konstruksi berkualitas tinggi',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return _buildProductCard(products[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(_ProductItem product) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Bisa diarahkan ke detail produk atau website
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Placeholder untuk gambar produk - nanti ganti dengan asset
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    product.imagePath,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Berkualitas Tinggi',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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

  Widget _buildWebsiteCTA() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFC62828), Color(0xFF8E0000)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red[900]!.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.public_outlined, color: Colors.white, size: 40),
          const SizedBox(height: 12),
          Text(
            'Informasi Lengkap di Website Kami',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'www.perwirasteel.com',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Kunjungi website resmi Perwira Steel untuk informasi lengkap tentang produk, spesifikasi teknis, artikel konstruksi, dan promo terbaru',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Buka website perwirasteel.com
                    // _launchWebsite();
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.open_in_new_outlined,
                          size: 18,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Kunjungi Website',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.blue;
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

  void _switchToTab(int index) {
    final mainScreenState = context
        .findRootAncestorStateOfType<MainScreenState>();
    if (mainScreenState != null) {
      mainScreenState.switchToTab(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return _buildCustomerDashboard(authProvider, theme);
  }
}

class _ProductItem {
  final String name;
  final String imagePath;

  _ProductItem(this.name, this.imagePath);
}
