import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/desa_colors.dart';
import '../providers/app_provider.dart';

class EditShopModal extends StatefulWidget {
  const EditShopModal({super.key});

  @override
  State<EditShopModal> createState() => _EditShopModalState();
}

class _EditShopModalState extends State<EditShopModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _kecamatanCtrl;
  String _category = 'Kuliner Tradisional';
  bool _isSaving = false;

  final List<String> _categories = [
    'Kuliner Tradisional',
    'Kerajinan Tangan',
    'Hasil Tani & Kebun',
    'Herbal & Jamu',
    'Fashion & Tekstil (Lurik)',
  ];

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AppProvider>(context, listen: false).currentUser;
    _nameCtrl = TextEditingController(text: user.shopName ?? 'Griya Tenun Lurik Lestari');
    _descCtrl = TextEditingController(text: user.shopDescription ?? 'Sentra produksi kerajinan tenun lurik otentik dan oleh-oleh khas warga Sumedang.');
    _phoneCtrl = TextEditingController(text: user.phone);
    _kecamatanCtrl = TextEditingController(text: user.kecamatan ?? 'Kecamatan Sumedang Selatan');
    if (user.shopCategory != null && _categories.contains(user.shopCategory)) {
      _category = user.shopCategory!;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _phoneCtrl.dispose();
    _kecamatanCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final provider = Provider.of<AppProvider>(context, listen: false);

    final success = await provider.updateShopProfile(
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category: _category,
      kecamatan: _kecamatanCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      whatsapp: _phoneCtrl.text.trim(),
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.currentUser;
    final isApproved = user.shopStatus == 'aktif';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kelola Profil & Toko UMKM',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: DesaColors.primary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: DesaColors.muted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Status Approval Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isApproved
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isApproved
                        ? const Color(0xFFA5D6A7)
                        : const Color(0xFFFFE082),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isApproved ? Icons.verified : Icons.hourglass_top_rounded,
                      color: isApproved ? const Color(0xFF2E7D32) : const Color(0xFFF57F17),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isApproved
                                ? 'Status: Toko Aktif (Lolos Verifikasi BUMDes)'
                                : 'Status: Menunggu Persetujuan Admin',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isApproved
                                  ? const Color(0xFF1B5E20)
                                  : const Color(0xFFE65100),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isApproved
                                ? 'Toko Anda telah disetujui. Produk yang Anda tambahkan dapat langsung tampil publik.'
                                : 'Data toko dan produk baru Anda masuk antrean verifikasi database admin desa sebelum ditayangkan di website.',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: isApproved
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFBF360C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Nama Toko
              const Text('Nama Usaha / Toko UMKM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: DesaColors.primary)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  hintText: 'Contoh: Griya Tenun Lurik Lestari',
                  filled: true,
                  fillColor: DesaColors.bg.withValues(alpha: 0.5),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: DesaColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: DesaColors.border)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Nama toko wajib diisi' : null,
              ),
              const SizedBox(height: 14),

              // Deskripsi Toko
              const Text('Deskripsi Usaha & Cerita Pengrajin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: DesaColors.primary)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Ceritakan keunikan produk desa, bahan alami, sejarah pengrajin, atau jam operasional usaha Anda...',
                  filled: true,
                  fillColor: DesaColors.bg.withValues(alpha: 0.5),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: DesaColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: DesaColors.border)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Deskripsi toko wajib diisi' : null,
              ),
              const SizedBox(height: 14),

              // Kategori
              const Text('Kategori Utama Toko', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: DesaColors.primary)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: DesaColors.bg.withValues(alpha: 0.5),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: DesaColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: DesaColors.border)),
                ),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _category = val);
                },
              ),
              const SizedBox(height: 14),

              // Kecamatan
              const Text('Kecamatan di Sumedang', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: DesaColors.primary)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _kecamatanCtrl,
                decoration: InputDecoration(
                  hintText: 'Contoh: Kecamatan Sumedang Selatan',
                  filled: true,
                  fillColor: DesaColors.bg.withValues(alpha: 0.5),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: DesaColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: DesaColors.border)),
                ),
              ),
              const SizedBox(height: 14),

              // Kontak WhatsApp
              const Text('Nomor WhatsApp / HP Toko', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: DesaColors.primary)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '08xxxxxxxxxx',
                  filled: true,
                  fillColor: DesaColors.bg.withValues(alpha: 0.5),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: DesaColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: DesaColors.border)),
                ),
              ),
              const SizedBox(height: 20),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesaColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Simpan Perubahan Toko',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
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
