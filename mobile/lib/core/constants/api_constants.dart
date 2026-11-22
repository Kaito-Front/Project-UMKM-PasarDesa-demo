import 'package:flutter/foundation.dart';

class ApiConstants {
  // Alamat Server:
  static const String productionBaseUrl = 'https://umkmdesa.smkn1sumedang.sch.id/api';
  static const String emulatorBaseUrl = 'http://10.0.2.2:8000/api';
  static const String lanBaseUrl = 'http://172.16.11.132:8000/api';
  static const String localhostBaseUrl = 'http://127.0.0.1:8000/api';

  // Mode Pengembangan Lokal (Aktif):
  // - Jika dijalankan di Web/Chrome, otomatis ke http://127.0.0.1:8000/api
  // - Jika dijalankan di HP Android fisik, otomatis ke IP Wi-Fi http://172.16.11.132:8000/api
  static String activeBaseUrl = kIsWeb ? localhostBaseUrl : lanBaseUrl;

  // Endpoint di bawah ini tidak perlu diubah sama sekali:
  static const String products = '/products';
  static const String categories = '/categories';
  static const String shops = '/shops';
  static const String orders = '/orders';
  static const String stats = '/stats';
  static const String chatAi = '/chat/ai';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';
}
