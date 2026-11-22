import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/desa_colors.dart';
import '../providers/app_provider.dart';
import '../widgets/edit_shop_modal.dart';
import 'chat_ai_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback? onOpenOnboarding;
  final VoidCallback? onOpenSplash;

  const ProfileScreen({
    super.key,
    this.onOpenOnboarding,
    this.onOpenSplash,
  });

  void _showLogoutDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Konfirmasi Keluar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DesaColors.primary)),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun Pasar Desa? Sesi login pada perangkat ini akan diakhiri.',
          style: TextStyle(fontSize: 13, color: DesaColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: DesaColors.muted, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              provider.logout();
            },
            child: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.currentUser;
    final isLoggedIn = provider.isLoggedIn;
    final isSeller = provider.currentRole == 'penjual';

    return Scaffold(
      backgroundColor: DesaColors.bg,
      appBar: AppBar(
        backgroundColor: DesaColors.bg,
        elevation: 0,
        title: const Text(
          'Akun Profil Warga',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: DesaColors.primary),
        ),
        actions: [
          if (isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
              tooltip: 'Keluar Akun',
              onPressed: () => _showLogoutDialog(context, provider),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Card or Login Banner
            if (isLoggedIn) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: DesaColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: DesaColors.primary,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0] : 'W',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DesaColors.primary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.phone.isNotEmpty ? user.phone : user.email,
                            style: const TextStyle(fontSize: 12, color: DesaColors.muted),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: DesaColors.highlight.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Warga Terverifikasi',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: DesaColors.highlight),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Role Toggle Button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSeller ? DesaColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSeller ? DesaColors.primary : DesaColors.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSeller ? Icons.store : Icons.shopping_bag_outlined,
                      color: isSeller ? Colors.white : DesaColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSeller ? 'Mode Toko Penjual Aktif' : 'Buka Dashboard Toko Penjual',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSeller ? Colors.white : DesaColors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isSeller 
                                ? user.shopName ?? 'Griya Tenun Lurik Lestari' 
                                : 'Beralih ke mode penjual UMKM Sumedang',
                            style: TextStyle(
                              fontSize: 11,
                              color: isSeller ? Colors.white.withValues(alpha: 0.75) : DesaColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: isSeller,
                      activeThumbColor: DesaColors.accent,
                      onChanged: (val) {
                        provider.setRole(val ? 'penjual' : 'pembeli');
                        provider.triggerToast('Beralih Mode', val ? 'Mode Toko Penjual diaktifkan' : 'Mode Pembeli diaktifkan');
                      },
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Not Logged In Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: DesaColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: DesaColors.accent.withValues(alpha: 0.12),
                      child: const Icon(Icons.person_outline, size: 32, color: DesaColors.accent),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Belum Masuk Akun Warga',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: DesaColors.primary),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Masuk atau daftar untuk belanja produk UMKM desa, melacak pesanan, atau membuka toko jualan Anda.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: DesaColors.muted, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DesaColors.accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.login_rounded, size: 18),
                        label: const Text('Masuk / Daftar Akun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Settings & Info List
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: DesaColors.border),
              ),
              child: Column(
                children: [
                  if (isLoggedIn) ...[
                    ListTile(
                      leading: const Icon(Icons.storefront, color: DesaColors.primary),
                      title: const Text('Kelola Profil & Deskripsi Toko', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        user.shopStatus == 'aktif'
                            ? 'Toko Aktif • Lolos Kurasi BUMDes ✓'
                            : 'Status: Menunggu Persetujuan Admin Desa ⏳',
                        style: TextStyle(
                          fontSize: 11,
                          color: user.shopStatus == 'aktif' ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: DesaColors.muted),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const EditShopModal(),
                        );
                      },
                    ),
                    const Divider(height: 1),
                  ],
                  ListTile(
                    leading: const Icon(Icons.help_outline, color: DesaColors.accent),
                    title: const Text('Tampilkan Panduan Onboarding', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Pelajari cara belanja dan buka toko UMKM', style: TextStyle(fontSize: 11, color: DesaColors.muted)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: DesaColors.muted),
                    onTap: onOpenOnboarding,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.animation, color: DesaColors.primary),
                    title: const Text('Tampilkan Splash Screen', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Animasi logo Palet Lurik Kontemporer', style: TextStyle(fontSize: 11, color: DesaColors.muted)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: DesaColors.muted),
                    onTap: onOpenSplash,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.auto_awesome, color: DesaColors.accent),
                    title: const Text('Asisten AI Desa Sumedang', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Konsultasi produk dan rekomendasi BUMDes', style: TextStyle(fontSize: 11, color: DesaColors.muted)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: DesaColors.muted),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChatAiScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.phone_android, color: DesaColors.highlight),
                    title: const Text('Status Versi Aplikasi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Pasar Desa Mobile v1.2.0 (Lurik Kontemporer)', style: TextStyle(fontSize: 11, color: DesaColors.muted)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: DesaColors.highlight.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('v1.2.0', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: DesaColors.highlight)),
                    ),
                  ),
                  if (isLoggedIn) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.logout_rounded, color: Colors.red),
                      title: const Text('Keluar dari Akun (Logout)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red)),
                      subtitle: const Text('Akhiri sesi login di perangkat ini', style: TextStyle(fontSize: 11, color: DesaColors.muted)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.red),
                      onTap: () => _showLogoutDialog(context, provider),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

