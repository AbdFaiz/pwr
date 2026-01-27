import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../models/reward.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  List<Reward> rewards = [];
  bool isLoading = true;
  late ConfettiController _confettiController;
  final Map<int, bool> _redeemingStates = {};

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _loadRewards();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadRewards() async {
    try {
      final data = await ApiService().getRewards();
      if (mounted) {
        setState(() {
          rewards = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        _showErrorSnackbar('Gagal memuat rewards');
      }
    }
  }

  Future<void> _redeemReward(int rewardId, int pointsRequired) async {
    if (_redeemingStates[rewardId] == true) return;

    setState(() {
      _redeemingStates[rewardId] = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      final userPoints = user?['points'] ?? 0;

      if (userPoints < pointsRequired) {
        _showErrorSnackbar('Poin tidak cukup untuk menukar reward ini');
        return;
      }

      final response = await ApiService().redeemReward(rewardId);

      if (response['status'] == 'success') {
        _confettiController.play();
        _showSuccessDialog();
        await authProvider.loadUser();
        await _loadRewards();
      } else {
        _showErrorSnackbar(response['message'] ?? 'Redemption gagal');
      }
    } catch (e) {
      _showErrorSnackbar('Redemption gagal: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _redeemingStates[rewardId] = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[500]!, Colors.green[700]!],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.celebration_rounded,
                    color: Colors.white,
                    size: 60,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Selamat!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Reward berhasil ditukarkan!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _confettiController.stop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Mantap!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.orange,
                Colors.pink,
                Colors.purple,
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildBeautifulRewardCard(Reward reward, int userPoints) {
    final colorScheme = Theme.of(context).colorScheme;
    final canRedeem = userPoints >= reward.pointsRequired;
    final isRedeeming = _redeemingStates[reward.id] == true;
    final progress = userPoints / reward.pointsRequired;

    Color getColor(double progress) {
      if (progress < 0.25) return Colors.red;
      if (progress < 0.5) return Colors.orange;
      if (progress < 1) return Colors.yellow.shade700;
      return Colors.green;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar di Kiri
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.surfaceVariant,
                      width: 1,
                    ),
                    image: reward.imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(reward.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: reward.imageUrl == null
                        ? colorScheme.surfaceVariant
                        : null,
                  ),
                  child: reward.imageUrl == null
                      ? Center(
                          child: Icon(
                            Icons.card_giftcard_rounded,
                            size: 40,
                            color: colorScheme.onSurface.withOpacity(0.3),
                          ),
                        )
                      : null,
                ),

                const SizedBox(width: 16),

                // Info di Tengah
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reward.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        reward.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurface.withOpacity(0.7),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),

                      // Gunakan di Text atau Progress Bar
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: getColor(progress).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 14,
                                  color: getColor(progress),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$userPoints/${reward.pointsRequired} Poin',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: getColor(progress),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Circular Progress dengan Button di Kanan
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Progress Circle
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.surfaceVariant,
                          width: 3,
                        ),
                      ),
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 3,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
                        ),
                      ),
                    ),

                    // Inner Button Circle
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: canRedeem && !isRedeeming
                            ? LinearGradient(
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.secondary,
                                ],
                              )
                            : LinearGradient(
                                colors: [
                                  Colors.grey.shade400,
                                  Colors.grey.shade600,
                                ],
                              ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (canRedeem ? colorScheme.primary : Colors.grey)
                                    .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: canRedeem && !isRedeeming
                              ? () => _redeemReward(
                                  reward.id,
                                  reward.pointsRequired,
                                )
                              : null,
                          borderRadius: BorderRadius.circular(27),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: isRedeeming ? 0 : 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      canRedeem
                                          ? Icons.celebration_rounded
                                          : Icons.lock_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      'Tukar',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isRedeeming)
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
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
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalistPointsHeader(int userPoints) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0, top: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 14,
                    color: colorScheme.secondary,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '$userPoints Poin',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;

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
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.card_giftcard_rounded,
                size: 50,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Reward',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Reward akan segera tersedia\nKumpulkan poin Anda terlebih dahulu',
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 20,
                      width: 120,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 14,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 14,
                      width: 80,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userPoints = authProvider.user?['points'] ?? 0;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: isLoading
          ? _buildLoadingState()
          : rewards.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadRewards,
              backgroundColor: colorScheme.surface,
              color: colorScheme.primary,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  _buildMinimalistPointsHeader(userPoints),
                  ...rewards
                      .map(
                        (reward) =>
                            _buildBeautifulRewardCard(reward, userPoints),
                      )
                      .toList(),
                ],
              ),
            ),
    );
  }
}
