import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static bool _initialized = false;
  static late Box _box;
  Timer? _btcTimer;

  Future<void> init() async {
    if (_initialized) return;
    if (kIsWeb) {
      // On web, no need to set directory
      _box = await Hive.openBox('exampleBox');
    } else {
      final dir = await getApplicationDocumentsDirectory();
      Hive.init(dir.path);
      _box = await Hive.openBox('exampleBox');
    }
    _initialized = true;
  }

  Future<int> insertExample(String name) async {
    await init();
    int key = await _box.add({'name': name});
    return key;
  }

  Future<List<Map<String, dynamic>>> getExamples() async {
    await init();
    return _box.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  void startBtcPriceLoop({Duration interval = const Duration(minutes: 1)}) {
    _btcTimer?.cancel();
    _btcTimer = Timer.periodic(interval, (_) async {
      await fetchAndSaveBtcPrice();
    });
    // Fetch immediately on start
    fetchAndSaveBtcPrice();
  }

  void stopBtcPriceLoop() {
    _btcTimer?.cancel();
    _btcTimer = null;
  }

  Future<void> fetchAndSaveBtcPrice() async {
    await init();
    try {
      final response = await http.get(Uri.parse('https://api.kraken.com/0/public/Ticker?pair=XXBTZUSD'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final price = data['result']?['XXBTZUSD']?['c']?[0];
        if (price != null) {
          await _box.add({'name': 'BTC', 'price': price, 'timestamp': DateTime.now().toIso8601String()});
        }
      }
    } catch (e) {
      // Handle error (optional: log or ignore)
    }
  }
}
