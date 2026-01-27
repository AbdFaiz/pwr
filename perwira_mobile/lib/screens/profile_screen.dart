import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (user != null) {
      _nameController.text = user['name'] ?? '';
      _phoneController.text = user['phone'] ?? '';
      _emailController.text = user['email'] ?? '';
      _addressController.text = user['address'] ?? '';
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
      password: _passwordController.text.isNotEmpty
          ? _passwordController.text.trim()
          : null,
    );

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile berhasil diperbarui!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      setState(() {
        _isEditing = false;
        _passwordController.clear();
        _confirmPasswordController.clear();
        _showPassword = false;
        _showConfirmPassword = false;
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui profile. Silakan coba lagi.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _loadProfileData();
        _passwordController.clear();
        _confirmPasswordController.clear();
        _showPassword = false;
        _showConfirmPassword = false;
      }
    });
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Logout?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1D21),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Anda akan keluar dari akun ini',
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        child: Text(
                          'Batal',
                          style: TextStyle(color: Color(0xFF6B7280)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await context.read<AuthProvider>().logout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Logout'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    if (user == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Color(0xFFFAFBFC),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Content
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),

                    // Profile Identity Card
                    _buildProfileIdentity(user),
                    const SizedBox(height: 20),

                    // Stats Overview
                    _buildStatsOverview(user),
                    const SizedBox(height: 24),

                    // Profile Form
                    _buildProfileForm(),
                    const SizedBox(height: 32),

                    // Logout Button
                    _buildLogoutButton(),
                    const SizedBox(height: 40),
                  ]),
                ),
              ],
            ),
    );
  }

  Widget _buildProfileIdentity(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar with decorative background
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Color(0xFFC62828),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFC62828).withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    user['name']?[0].toUpperCase() ?? 'U',
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Color(0xFFC62828), width: 2),
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    size: 12,
                    color: Color(0xFFC62828),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            user['name'] ?? 'No Name',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user['email'] ?? 'No Email',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0xFFC62828).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              user['role']?.toUpperCase() ?? 'USER',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFFC62828),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.auto_awesome_rounded,
              value: '${user['points'] ?? 0}',
              label: 'Poin',
              color: Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatItem(
              icon: Icons.workspace_premium_rounded,
              value: 'Premium',
              label: 'Status',
              color: Color(0xFF8B5CF6),
            ),
          ),
          if (user['sales_code'] != null) ...[
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatItem(
                icon: Icons.badge_rounded,
                value: user['sales_code']!,
                label: 'Kode Sales',
                color: Color(0xFF06B6D4),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Informasi Profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),

                  if (!_isEditing)
                    IconButton(
                      onPressed: _toggleEdit,
                      icon: Icon(Icons.edit_rounded, color: Color(0xFFC62828)),
                    ),
                  if (_isEditing)
                    GestureDetector(
                      onTap: _toggleEdit,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFFF3F4F6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Form Fields
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  _buildModernTextField(
                    controller: _nameController,
                    label: 'Nama Lengkap',
                    icon: Icons.person_outline_rounded,
                    enabled: _isEditing,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harap masukkan nama lengkap';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildModernTextField(
                    controller: _phoneController,
                    label: 'Nomor Telepon',
                    icon: Icons.phone_iphone_rounded,
                    enabled: _isEditing,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildModernTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    enabled: _isEditing,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harap masukkan email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Harap masukkan email yang valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildModernTextField(
                    controller: _addressController,
                    label: 'Alamat',
                    icon: Icons.location_on_outlined,
                    enabled: _isEditing,
                    maxLines: 2,
                  ),

                  // Password Section
                  if (_isEditing) ...[
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Ubah Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    _buildModernTextField(
                      controller: _passwordController,
                      label: 'Password Baru',
                      icon: Icons.lock_outline_rounded,
                      obscureText: !_showPassword,
                      enabled: _isEditing,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildModernTextField(
                      controller: _confirmPasswordController,
                      label: 'Konfirmasi Password Baru',
                      icon: Icons.lock_reset_rounded,
                      obscureText: !_showConfirmPassword,
                      enabled: _isEditing,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _showConfirmPassword = !_showConfirmPassword;
                          });
                        },
                        icon: Icon(
                          _showConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      validator: (value) {
                        if (_passwordController.text.isNotEmpty &&
                            value != _passwordController.text) {
                          return 'Password tidak cocok';
                        }
                        return null;
                      },
                    ),
                  ],
                ],
              ),
            ),

            // Save Button
            if (_isEditing) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFC62828),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Simpan Perubahan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    bool obscureText = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(
        color: enabled ? Color(0xFF111827) : Color(0xFF9CA3AF),
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.only(left: 16, right: 12),
          child: Icon(icon, size: 20, color: Color(0xFF6B7280)),
        ),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFC62828), width: 1.5),
        ),
        filled: !enabled,
        fillColor: !enabled ? Color(0xFFF9FAFB) : Colors.white,
        labelStyle: TextStyle(color: Color(0xFF6B7280)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: OutlinedButton(
        onPressed: _logout,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(color: Color(0xFFFECACA)),
          backgroundColor: Color(0xFFFEF2F2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 20),
            const SizedBox(width: 8),
            Text(
              'Keluar',
              style: TextStyle(
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
