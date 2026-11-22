import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/desa_colors.dart';
import '../providers/app_provider.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onSuccess;
  final String? initialTab; // 'masuk' or 'daftar'
  final String? initialRole; // 'pembeli' or 'penjual'

  const LoginScreen({
    super.key,
    this.onSuccess,
    this.initialTab = 'masuk',
    this.initialRole = 'pembeli',
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Login Form
  final _loginFormKey = GlobalKey<FormState>();
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscureLoginPassword = true;
  String? _loginError;

  // Register Form
  final _registerFormKey = GlobalKey<FormState>();
  final _regNameCtrl = TextEditingController();
  final _regPhoneCtrl = TextEditingController();
  final _regPasswordCtrl = TextEditingController();
  final _regConfirmPasswordCtrl = TextEditingController();
  final _regShopNameCtrl = TextEditingController();
  String _regRole = 'pembeli'; // 'pembeli' or 'penjual'
  String _regCategory = 'Kuliner Tradisional';
  String _regKecamatan = 'Kecamatan Sumedang Utara';
  bool _obscureRegPassword = true;
  bool _obscureRegConfirmPassword = true;
  String? _registerError;

  static const List<String> _categories = [
    'Kuliner Tradisional',
    'Hasil Tani & Kebun',
    'Kerajinan Tangan',
    'Herbal & Jamu',
    'Pakaian & Tenun',
  ];

  static const List<String> _sumedangKecamatan = [
    'Kecamatan Sumedang Utara',
    'Kecamatan Sumedang Selatan',
    'Kecamatan Cimalaka',
    'Kecamatan Tanjungsari',
    'Kecamatan Jatinangor',
    'Kecamatan Cimanggung',
    'Kecamatan Paseh',
    'Kecamatan Conggeang',
    'Kecamatan Buahdua',
    'Kecamatan Tanjungkerta',
    'Kecamatan Tanjungmedar',
    'Kecamatan Surian',
    'Kecamatan Tomo',
    'Kecamatan Ujungjaya',
    'Kecamatan Jatigede',
    'Kecamatan Darmaraja',
    'Kecamatan Wado',
    'Kecamatan Jatinunggal',
    'Kecamatan Cisitu',
    'Kecamatan Situraja',
    'Kecamatan Ganeas',
    'Kecamatan Cisarua',
    'Kecamatan Sukasari',
    'Kecamatan Pamulihan',
    'Kecamatan Rancakalong',
    'Kecamatan Cibugel',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab == 'daftar' ? 1 : 0,
    );
    if (widget.initialRole != null) {
      _regRole = widget.initialRole!;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    _regNameCtrl.dispose();
    _regPhoneCtrl.dispose();
    _regPasswordCtrl.dispose();
    _regConfirmPasswordCtrl.dispose();
    _regShopNameCtrl.dispose();
    super.dispose();
  }

  void _fillDemo(String id, String pass) {
    setState(() {
      _identifierCtrl.text = id;
      _passwordCtrl.text = pass;
      _loginError = null;
    });
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() => _loginError = null);

    final provider = Provider.of<AppProvider>(context, listen: false);
    final res = await provider.login(_identifierCtrl.text.trim(), _passwordCtrl.text);

    if (!mounted) return;
    if (res['success'] == true) {
      widget.onSuccess?.call();
      Navigator.pop(context, true);
    } else {
      setState(() => _loginError = res['message'] ?? 'Login gagal. Periksa nomor HP atau sandi.');
    }
  }

  Future<void> _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;
    if (_regPasswordCtrl.text != _regConfirmPasswordCtrl.text) {
      setState(() => _registerError = 'Konfirmasi kata sandi tidak cocok.');
      return;
    }
    if (_regRole == 'penjual' && _regShopNameCtrl.text.trim().isEmpty) {
      setState(() => _registerError = 'Nama toko UMKM wajib diisi.');
      return;
    }
    setState(() => _registerError = null);

    final provider = Provider.of<AppProvider>(context, listen: false);
    final roleParam = _regRole == 'penjual' ? 'jualan' : 'belanja';

    final res = await provider.register(
      name: _regNameCtrl.text.trim(),
      phone: _regPhoneCtrl.text.trim(),
      password: _regPasswordCtrl.text,
      role: roleParam,
      shopName: _regRole == 'penjual' ? _regShopNameCtrl.text.trim() : null,
      shopCategory: _regRole == 'penjual' ? _regCategory : null,
      kecamatan: _regKecamatan,
    );

    if (!mounted) return;
    if (res['success'] == true) {
      widget.onSuccess?.call();
      Navigator.pop(context, true);
    } else {
      setState(() => _registerError = res['message'] ?? 'Pendaftaran gagal. Silakan coba lagi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: DesaColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Akun Pasar Desa Sumedang',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: DesaColors.primary),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: DesaColors.accent,
          indicatorWeight: 3,
          labelColor: DesaColors.primary,
          unselectedLabelColor: DesaColors.muted,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Masuk Akun', icon: Icon(Icons.login_rounded, size: 18)),
            Tab(text: 'Daftar Akun Baru', icon: Icon(Icons.person_add_alt_1_rounded, size: 18)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLoginTab(provider),
          _buildRegisterTab(provider),
        ],
      ),
    );
  }

  Widget _buildLoginTab(AppProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: DesaColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: DesaColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.shield_outlined, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat Datang Kembali',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: DesaColors.primary),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Masuk untuk belanja, pantau pesanan, atau kelola toko UMKM Anda.',
                          style: TextStyle(fontSize: 11, color: DesaColors.muted, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Error Message Banner
            if (_loginError != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _loginError!,
                        style: TextStyle(color: Colors.red.shade800, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Input Identifier (Phone or Email)
            const Text('Nomor HP / WhatsApp atau Email', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: DesaColors.primary)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _identifierCtrl,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Contoh: 081234567890 atau email@pasardesa.id',
                hintStyle: const TextStyle(fontSize: 12, color: DesaColors.muted),
                prefixIcon: const Icon(Icons.person_outline, size: 20, color: DesaColors.primary),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: DesaColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: DesaColors.border)),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Nomor HP atau email wajib diisi' : null,
            ),
            const SizedBox(height: 14),

            // Input Password
            const Text('Kata Sandi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: DesaColors.primary)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscureLoginPassword,
              decoration: InputDecoration(
                hintText: 'Masukkan kata sandi',
                hintStyle: const TextStyle(fontSize: 12, color: DesaColors.muted),
                prefixIcon: const Icon(Icons.lock_outline, size: 20, color: DesaColors.primary),
                suffixIcon: IconButton(
                  icon: Icon(_obscureLoginPassword ? Icons.visibility_off : Icons.visibility, size: 18, color: DesaColors.muted),
                  onPressed: () => setState(() => _obscureLoginPassword = !_obscureLoginPassword),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: DesaColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: DesaColors.border)),
              ),
              validator: (val) => val == null || val.isEmpty ? 'Kata sandi wajib diisi' : null,
            ),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesaColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: provider.isAuthLoading ? null : _handleLogin,
                child: provider.isAuthLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Masuk Sekarang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Demo Accounts Section (Mempermudah Testing)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: DesaColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bolt, size: 16, color: DesaColors.accent),
                      SizedBox(width: 4),
                      Text(
                        'Uji Coba Cepat (Akun Tersedia)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: DesaColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ketuk salah satu akun di bawah untuk mengisi form login otomatis:',
                    style: TextStyle(fontSize: 11, color: DesaColors.muted),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildDemoChip('🏪 Penjual: Ibu Sumarsih (Tenun Lurik)', '081234567890', 'PasarLurik@2026!'),
                      _buildDemoChip('🏪 Penjual: Ibu Darmi (Kripik Tempe)', '085678901234', 'PasarLurik@2026!'),
                      _buildDemoChip('🛒 Pembeli: Rudi Hartono', '081399887766', 'WargaDesa@2026!'),
                      _buildDemoChip('🛒 Pembeli: Bambang Sudiro', '081299887766', 'WargaDesa@2026!'),
                      _buildDemoChip('🛡️ Admin: BUMDes Sumedang', '081915194171', 'DesaMandiri@2026!'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoChip(String label, String id, String pass) {
    return ActionChip(
      backgroundColor: DesaColors.bg,
      side: const BorderSide(color: DesaColors.border),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: DesaColors.primary)),
      onPressed: () => _fillDemo(id, pass),
    );
  }

  Widget _buildRegisterTab(AppProvider provider) {
    final isSeller = _regRole == 'penjual';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _registerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Role Switcher Cards
            const Text('Pilih Peran Akun Warga', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: DesaColors.primary)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _regRole = 'pembeli'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: !isSeller ? DesaColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: !isSeller ? DesaColors.primary : DesaColors.border),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.shopping_bag_outlined, color: !isSeller ? Colors.white : DesaColors.primary, size: 24),
                          const SizedBox(height: 4),
                          Text(
                            'Warga Pembeli',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: !isSeller ? Colors.white : DesaColors.primary,
                            ),
                          ),
                          Text(
                            'Belanja UMKM Desa',
                            style: TextStyle(
                              fontSize: 9.5,
                              color: !isSeller ? Colors.white70 : DesaColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _regRole = 'penjual'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isSeller ? DesaColors.accent : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isSeller ? DesaColors.accent : DesaColors.border),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.storefront_rounded, color: isSeller ? Colors.white : DesaColors.accent, size: 24),
                          const SizedBox(height: 4),
                          Text(
                            'Penjual UMKM',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSeller ? Colors.white : DesaColors.primary,
                            ),
                          ),
                          Text(
                            'Buka Toko Jualan',
                            style: TextStyle(
                              fontSize: 9.5,
                              color: isSeller ? Colors.white70 : DesaColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Error Banner
            if (_registerError != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _registerError!,
                        style: TextStyle(color: Colors.red.shade800, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Nama Lengkap
            const Text('Nama Lengkap Warga', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: DesaColors.primary)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _regNameCtrl,
              decoration: InputDecoration(
                hintText: 'Contoh: Ahmad Hidayat',
                hintStyle: const TextStyle(fontSize: 12, color: DesaColors.muted),
                prefixIcon: const Icon(Icons.person_outline, size: 20, color: DesaColors.primary),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: DesaColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: DesaColors.border)),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Nama lengkap wajib diisi' : null,
            ),
            const SizedBox(height: 14),

            // Nomor HP
            const Text('Nomor WhatsApp / HP Aktif', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: DesaColors.primary)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _regPhoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Contoh: 081234567890',
                hintStyle: const TextStyle(fontSize: 12, color: DesaColors.muted),
                prefixIcon: const Icon(Icons.phone_outlined, size: 20, color: DesaColors.primary),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: DesaColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: DesaColors.border)),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Nomor HP wajib diisi' : null,
            ),
            const SizedBox(height: 14),

            // If Penjual: Fields Toko
            if (isSeller) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: DesaColors.accent.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: DesaColors.accent.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.store, size: 16, color: DesaColors.accent),
                        SizedBox(width: 6),
                        Text('Informasi Toko UMKM Desa', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: DesaColors.accent)),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Nama Toko
                    const Text('Nama Usaha / Toko UMKM', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: DesaColors.primary)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _regShopNameCtrl,
                      decoration: InputDecoration(
                        hintText: 'Contoh: Keripik Singkong Barokah',
                        hintStyle: const TextStyle(fontSize: 12, color: DesaColors.muted),
                        prefixIcon: const Icon(Icons.storefront, size: 20, color: DesaColors.accent),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: DesaColors.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: DesaColors.border)),
                      ),
                      validator: (val) => isSeller && (val == null || val.trim().isEmpty) ? 'Nama toko wajib diisi' : null,
                    ),
                    const SizedBox(height: 10),

                    // Kategori Utama Toko
                    const Text('Kategori Utama Toko', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: DesaColors.primary)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _regCategory,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: DesaColors.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: DesaColors.border)),
                      ),
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _regCategory = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Kecamatan
            const Text('Kecamatan Asal di Sumedang', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: DesaColors.primary)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _regKecamatan,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: DesaColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: DesaColors.border)),
              ),
              items: _sumedangKecamatan.map((k) => DropdownMenuItem(value: k, child: Text(k, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _regKecamatan = val);
              },
            ),
            const SizedBox(height: 14),

            // Kata Sandi
            const Text('Kata Sandi (Minimal 6 karakter)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: DesaColors.primary)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _regPasswordCtrl,
              obscureText: _obscureRegPassword,
              decoration: InputDecoration(
                hintText: 'Masukkan kata sandi baru',
                hintStyle: const TextStyle(fontSize: 12, color: DesaColors.muted),
                prefixIcon: const Icon(Icons.lock_outline, size: 20, color: DesaColors.primary),
                suffixIcon: IconButton(
                  icon: Icon(_obscureRegPassword ? Icons.visibility_off : Icons.visibility, size: 18, color: DesaColors.muted),
                  onPressed: () => setState(() => _obscureRegPassword = !_obscureRegPassword),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: DesaColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: DesaColors.border)),
              ),
              validator: (val) => val == null || val.length < 6 ? 'Kata sandi minimal 6 karakter' : null,
            ),
            const SizedBox(height: 14),

            // Konfirmasi Kata Sandi
            const Text('Konfirmasi Kata Sandi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: DesaColors.primary)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _regConfirmPasswordCtrl,
              obscureText: _obscureRegConfirmPassword,
              decoration: InputDecoration(
                hintText: 'Ulangi kata sandi di atas',
                hintStyle: const TextStyle(fontSize: 12, color: DesaColors.muted),
                prefixIcon: const Icon(Icons.lock_reset, size: 20, color: DesaColors.primary),
                suffixIcon: IconButton(
                  icon: Icon(_obscureRegConfirmPassword ? Icons.visibility_off : Icons.visibility, size: 18, color: DesaColors.muted),
                  onPressed: () => setState(() => _obscureRegConfirmPassword = !_obscureRegConfirmPassword),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: DesaColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: DesaColors.border)),
              ),
              validator: (val) => val == null || val.isEmpty ? 'Konfirmasi kata sandi wajib diisi' : null,
            ),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSeller ? DesaColors.accent : DesaColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: provider.isAuthLoading ? null : _handleRegister,
                child: provider.isAuthLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        isSeller ? 'Daftar & Buka Toko UMKM' : 'Daftar Akun Pembeli',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
