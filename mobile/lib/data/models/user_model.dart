class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'pembeli', 'penjual', 'admin', 'keduanya'
  final String? shopName;
  final String? shopId;
  final String? shopDescription;
  final String? shopCategory;
  final String? shopStatus; // 'aktif', 'menunggu', 'ditolak'
  final bool shopVerified;
  final String? kecamatan;
  final bool isEmailVerified;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role = 'pembeli',
    this.shopName,
    this.shopId,
    this.shopDescription,
    this.shopCategory,
    this.shopStatus = 'menunggu',
    this.shopVerified = false,
    this.kecamatan,
    this.isEmailVerified = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? 'USR-01',
      name: json['name']?.toString() ?? 'Warga Sumedang',
      email: json['email']?.toString() ?? 'warga@pasardesa.id',
      phone: json['phone']?.toString() ?? '081915194171',
      role: json['role']?.toString() ?? 'pembeli',
      shopName: json['shopName']?.toString() ?? (json['shop'] != null ? json['shop']['name'] : null),
      shopId: json['shopId']?.toString() ?? (json['shop'] != null ? json['shop']['id']?.toString() : null),
      shopDescription: json['shopDescription']?.toString() ?? (json['shop'] != null ? json['shop']['description'] : null),
      shopCategory: json['shopCategory']?.toString() ?? (json['shop'] != null ? json['shop']['category'] : null),
      shopStatus: json['shopStatus']?.toString() ?? (json['shop'] != null ? json['shop']['status'] : 'menunggu'),
      shopVerified: json['shopVerified'] ?? (json['shop'] != null ? json['shop']['verified'] ?? false : false),
      kecamatan: json['kecamatan']?.toString(),
      isEmailVerified: json['isEmailVerified'] ?? json['email_verified_at'] != null,
    );
  }

  static UserModel guest() {
    return UserModel(
      id: '',
      name: 'Tamu Warga',
      email: '',
      phone: '',
      role: 'pembeli',
      shopStatus: 'menunggu',
      shopVerified: false,
      isEmailVerified: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'shopName': shopName,
      'shopId': shopId,
      'shopDescription': shopDescription,
      'shopCategory': shopCategory,
      'shopStatus': shopStatus,
      'shopVerified': shopVerified,
      'kecamatan': kecamatan,
      'isEmailVerified': isEmailVerified,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? shopName,
    String? shopId,
    String? shopDescription,
    String? shopCategory,
    String? shopStatus,
    bool? shopVerified,
    String? kecamatan,
    bool? isEmailVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      shopName: shopName ?? this.shopName,
      shopId: shopId ?? this.shopId,
      shopDescription: shopDescription ?? this.shopDescription,
      shopCategory: shopCategory ?? this.shopCategory,
      shopStatus: shopStatus ?? this.shopStatus,
      shopVerified: shopVerified ?? this.shopVerified,
      kecamatan: kecamatan ?? this.kecamatan,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}
