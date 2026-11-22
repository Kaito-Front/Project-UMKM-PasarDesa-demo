import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/product_model.dart';
import '../data/models/category_model.dart';
import '../data/models/order_model.dart';
import '../data/models/user_model.dart';
import '../data/services/api_service.dart';

class CartEntry {
  final Product product;
  int qty;
  String note;

  CartEntry({
    required this.product,
    this.qty = 1,
    this.note = '',
  });

  int get subtotal => product.price * qty;
}

class AppProvider with ChangeNotifier {
  static const String _tokenPrefKey = 'pasardesa_mobile_token';
  static const String _userPrefKey = 'pasardesa_mobile_user';

  final ApiService _apiService = ApiService();

  List<Product> _products = [];
  List<CategoryItem> _categories = [];
  List<OrderItem> _orders = [];
  final List<CartEntry> _cart = [];
  final Set<String> _favorites = {};

  UserModel? _currentUser;
  String? _token;
  bool _isAuthLoading = false;

  bool _isLoading = false;
  String _selectedCategory = 'semua';
  String _selectedKecamatan = 'Semua Kecamatan';
  String _searchQuery = '';
  String _orderFilter = 'semua';
  String _currentRole = 'pembeli';
  String? _toastTitle;
  String? _toastMessage;
  final Set<String> _hiddenProductIds = {};

  // Getters
  String get currentRole => _currentRole;
  String? get toastTitle => _toastTitle;
  String? get toastMessage => _toastMessage;
  UserModel get currentUser => _currentUser ?? UserModel.guest();
  UserModel? get rawCurrentUser => _currentUser;
  bool get isLoggedIn => _token != null && _currentUser != null;
  bool get isAuthLoading => _isAuthLoading;
  String? get token => _token;

  List<Product> get products {
    return _products.where((p) {
      if (_hiddenProductIds.contains(p.id)) return false;
      final matchCat = _selectedCategory == 'semua' || p.category == _selectedCategory;
      final matchKec = _selectedKecamatan == 'Semua Kecamatan' || p.kecamatan == _selectedKecamatan;
      final matchSearch = _searchQuery.isEmpty || 
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.shopName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCat && matchKec && matchSearch;
    }).toList();
  }

  List<Product> get allRawProducts => _products;
  List<Product> get sellerProducts => _products; // Displayed in seller mode
  List<OrderItem> get sellerOrders => _orders;   // Orders for seller shop
  bool isProductHidden(String id) => _hiddenProductIds.contains(id);
  List<CategoryItem> get categories => _categories;
  List<OrderItem> get orders {
    if (_orderFilter == 'semua') return _orders;
    if (_orderFilter == 'diproses') return _orders.where((o) => o.status == 'diproses').toList();
    if (_orderFilter == 'dikirim') return _orders.where((o) => o.status == 'dikirim').toList();
    if (_orderFilter == 'selesai') return _orders.where((o) => ['selesai', 'diambil'].contains(o.status)).toList();
    return _orders;
  }

  List<CartEntry> get cart => _cart;
  int get cartCount => _cart.fold(0, (sum, i) => sum + i.qty);
  int get cartSubtotal => _cart.fold(0, (sum, i) => sum + i.subtotal);
  Set<String> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get selectedKecamatan => _selectedKecamatan;
  String get searchQuery => _searchQuery;
  String get orderFilter => _orderFilter;

  int get activeOrdersCount => _orders.where((o) => ['diproses', 'dikirim'].contains(o.status)).length;

  AppProvider() {
    initData();
  }

  Future<void> initData() async {
    _isLoading = true;
    notifyListeners();

    // Restore cached session from SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString(_tokenPrefKey);
      final savedUserJson = prefs.getString(_userPrefKey);

      if (savedUserJson != null && savedUserJson.isNotEmpty) {
        _currentUser = UserModel.fromJson(jsonDecode(savedUserJson));
        if (_currentUser!.role == 'penjual' || _currentUser!.role == 'keduanya') {
          _currentRole = 'penjual';
        }
      }

      if (savedToken != null && savedToken.isNotEmpty) {
        _token = savedToken;
        final freshUser = await _apiService.getMe(savedToken);
        if (freshUser != null) {
          _currentUser = freshUser;
          await prefs.setString(_userPrefKey, jsonEncode(freshUser.toJson()));
          if (_currentUser!.role == 'penjual' || _currentUser!.role == 'keduanya') {
            _currentRole = 'penjual';
          }
        }
      }
    } catch (_) {}

    final fetchedProds = await _apiService.getProducts();
    final fetchedCats = await _apiService.getCategories();
    final fetchedOrds = await _apiService.getOrders();

    _products = fetchedProds;
    _categories = fetchedCats;
    _orders = fetchedOrds;
    _isLoading = false;
    notifyListeners();
  }

  void setSelectedCategory(String cat) {
    _selectedCategory = cat;
    notifyListeners();
  }

  void setSelectedKecamatan(String kec) {
    _selectedKecamatan = kec;
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setOrderFilter(String filter) {
    _orderFilter = filter;
    notifyListeners();
  }

  void toggleFavorite(String productId) {
    if (_favorites.contains(productId)) {
      _favorites.remove(productId);
    } else {
      _favorites.add(productId);
    }
    notifyListeners();
  }

  // Cart Management
  void addToCart(Product product, {int qty = 1, String note = ''}) {
    final existingIndex = _cart.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      _cart[existingIndex].qty += qty;
    } else {
      _cart.add(CartEntry(product: product, qty: qty, note: note));
    }
    notifyListeners();
  }

  void updateCartQty(String productId, int newQty) {
    if (newQty <= 0) {
      _cart.removeWhere((item) => item.product.id == productId);
    } else {
      final index = _cart.indexWhere((item) => item.product.id == productId);
      if (index >= 0) {
        _cart[index].qty = newQty;
      }
    }
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // Checkout process
  Future<OrderItem?> checkoutCart({
    required String buyerName,
    required String phone,
    required String kecamatan,
    required String address,
    required String paymentMethod,
    required String shippingMethod,
    String? notes,
  }) async {
    if (_cart.isEmpty) return null;

    final items = _cart.map((entry) => {
      'productId': entry.product.id,
      'productName': entry.product.name,
      'price': entry.product.price,
      'qty': entry.qty,
      'note': entry.note,
    }).toList();

    final newOrder = await _apiService.createOrder(
      buyerName: buyerName,
      phone: phone,
      kecamatan: kecamatan,
      address: address,
      items: items,
      paymentMethod: paymentMethod,
      shippingMethod: shippingMethod,
      notes: notes,
    );

    if (newOrder != null) {
      _orders.insert(0, newOrder);
      clearCart();
      notifyListeners();
    }
    return newOrder;
  }

  // Real-time Status Sync & Confirm Receipt
  Future<void> confirmOrderReceived(String orderId) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      _orders[index] = _orders[index].copyWith(status: 'selesai');
      notifyListeners();
      await _apiService.updateOrderStatus(orderId, 'selesai');
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      _orders[index] = _orders[index].copyWith(status: newStatus);
      notifyListeners();
      await _apiService.updateOrderStatus(orderId, newStatus);
    }
  }

  Future<void> _saveUserToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentUser != null) {
        await prefs.setString(_userPrefKey, jsonEncode(_currentUser!.toJson()));
      } else {
        await prefs.remove(_userPrefKey);
      }
    } catch (_) {}
  }

  // Switch role between Pembeli and Penjual
  void setRole(String role) {
    _currentRole = role;
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(role: role);
      _saveUserToPrefs();
    }
    notifyListeners();
  }

  void toggleRole() {
    setRole(_currentRole == 'pembeli' ? 'penjual' : 'pembeli');
  }

  void triggerToast(String title, String message) {
    _toastTitle = title;
    _toastMessage = message;
    notifyListeners();

    Future.delayed(const Duration(seconds: 3), () {
      if (_toastTitle == title) {
        _toastTitle = null;
        _toastMessage = null;
        notifyListeners();
      }
    });
  }

  void clearToast() {
    _toastTitle = null;
    _toastMessage = null;
    notifyListeners();
  }

  void toggleProductHidden(String id) {
    if (_hiddenProductIds.contains(id)) {
      _hiddenProductIds.remove(id);
      triggerToast('Produk Aktif', 'Produk ditampilkan kembali di katalog desa.');
    } else {
      _hiddenProductIds.add(id);
      triggerToast('Produk Disembunyikan', 'Produk dinonaktifkan dari katalog belanja.');
    }
    notifyListeners();
  }

  void setToken(String? t) {
    _token = t;
    notifyListeners();
  }

  // Authentication: Login
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    _isAuthLoading = true;
    notifyListeners();

    final res = await _apiService.login(identifier, password);
    _isAuthLoading = false;

    if (res['success'] == true && res['token'] != null && res['user'] != null) {
      _token = res['token'];
      _currentUser = res['user'] as UserModel;
      if (_currentUser!.role == 'penjual' || _currentUser!.role == 'keduanya') {
        _currentRole = 'penjual';
      } else {
        _currentRole = 'pembeli';
      }

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenPrefKey, _token!);
        await prefs.setString(_userPrefKey, jsonEncode(_currentUser!.toJson()));
      } catch (_) {}

      triggerToast('Berhasil Masuk!', 'Selamat datang, ${_currentUser!.name}');
    }
    notifyListeners();
    return res;
  }

  // Authentication: Register
  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String password,
    required String role,
    String? shopName,
    String? shopCategory,
    String? kecamatan,
  }) async {
    _isAuthLoading = true;
    notifyListeners();

    final res = await _apiService.register(
      name: name,
      phone: phone,
      password: password,
      role: role,
      shopName: shopName,
      shopCategory: shopCategory,
      kecamatan: kecamatan,
    );
    _isAuthLoading = false;

    if (res['success'] == true && res['token'] != null && res['user'] != null) {
      _token = res['token'];
      _currentUser = res['user'] as UserModel;
      if (_currentUser!.role == 'penjual' || _currentUser!.role == 'keduanya') {
        _currentRole = 'penjual';
      } else {
        _currentRole = 'pembeli';
      }

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenPrefKey, _token!);
        await prefs.setString(_userPrefKey, jsonEncode(_currentUser!.toJson()));
      } catch (_) {}

      triggerToast('Pendaftaran Berhasil!', 'Akun ${_currentUser!.name} berhasil dibuat.');
    }
    notifyListeners();
    return res;
  }

  // Authentication: Logout
  Future<void> logout() async {
    final oldToken = _token;
    _token = null;
    _currentUser = null;
    _currentRole = 'pembeli';
    _cart.clear();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenPrefKey);
      await prefs.remove(_userPrefKey);
    } catch (_) {}

    triggerToast('Berhasil Keluar', 'Anda telah keluar dari akun.');
    notifyListeners();

    if (oldToken != null) {
      await _apiService.logout(oldToken);
    }
  }

  Future<void> addProduct(Product product) async {
    _isLoading = true;
    notifyListeners();

    final shopId = currentUser.shopId ?? 'toko-1';
    final created = await _apiService.createProduct(
      name: product.name,
      price: product.price,
      stock: product.stock,
      category: product.category,
      description: product.description,
      kecamatan: product.kecamatan,
      shopId: shopId,
      imageUrl: product.imageUrl,
      token: _token,
    );

    _isLoading = false;
    if (created != null) {
      _products.insert(0, created);
      if (created.isHidden) {
        triggerToast('Produk Masuk Database!', '${created.name} berhasil tersimpan di database dan menunggu persetujuan admin desa.');
      } else {
        triggerToast('Produk Berhasil Terbit!', '${created.name} berhasil tersimpan di database & langsung tampil di website!');
      }
    } else {
      // Fallback local
      _products.insert(0, product);
      triggerToast('Produk Ditambahkan (Lokal)', '${product.name} berhasil disimpan sementara.');
    }
    notifyListeners();
  }

  Future<bool> updateShopProfile({
    required String name,
    required String description,
    String? category,
    String? kecamatan,
    String? phone,
    String? whatsapp,
  }) async {
    final success = await _apiService.updateShopProfile(
      name: name,
      description: description,
      category: category,
      kecamatan: kecamatan,
      phone: phone,
      whatsapp: whatsapp,
      token: _token,
    );

    _currentUser = currentUser.copyWith(
      shopName: name,
      shopDescription: description,
      shopCategory: category ?? currentUser.shopCategory,
      kecamatan: kecamatan ?? currentUser.kecamatan,
      phone: phone ?? currentUser.phone,
    );
    _saveUserToPrefs();

    if (success) {
      triggerToast('Profil Toko Tersinkron!', 'Deskripsi & informasi toko berhasil diperbarui ke database.');
    } else {
      triggerToast('Profil Toko Diperbarui', 'Data toko berhasil diperbarui di perangkat.');
    }
    notifyListeners();
    return success;
  }

  Future<bool> updateUserProfile({
    required String name,
    required String phone,
    String? kecamatan,
  }) async {
    final success = await _apiService.updateUserProfile(
      name: name,
      phone: phone,
      kecamatan: kecamatan,
      token: _token,
    );

    _currentUser = currentUser.copyWith(
      name: name,
      phone: phone,
      kecamatan: kecamatan ?? currentUser.kecamatan,
    );
    _saveUserToPrefs();

    triggerToast('Profil Diperbarui', 'Data identitas warga berhasil diperbarui.');
    notifyListeners();
    return success;
  }
}
