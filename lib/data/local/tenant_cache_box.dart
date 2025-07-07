import 'dart:io';

import 'package:flutter/foundation.dart' show immutable;
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:QuoteApp/logs/console_logger.dart';

@immutable
class TenantCacheBox {
  final String tenantId;
  static final logger = Logger();

  TenantCacheBox({required this.tenantId});

  static Box? _tenantCacheBox;
  static Box? get tenantCashBox => _tenantCacheBox;
  static bool openBoxFlag = true;

  static Future<void> openLocalTenantValidationBox() async {
    try {
      Directory document = await getApplicationDocumentsDirectory();
      Hive.init(document.path);
      _tenantCacheBox = await Hive.openBox<String>('tenantBox');
    } catch (exp) {
      logger.error("Failed to open tenant box",
          tag: "TenantCache", exception: exp);
    }
  }

  void setTenantIdInCache() {
    if (_tenantCacheBox!.isEmpty) {
      _tenantCacheBox!.put("tenantId", tenantId);
    }
  }

  static removeTenantId() async {
    await _tenantCacheBox!.delete("tenantId");
    logger.info("Tenant ID removed, remaining keys: ${_tenantCacheBox!.keys}",
        tag: "TenantCache");
  }

  static void closeBox() {
    _tenantCacheBox!.close();
    openBoxFlag = false;
    logger.info("The box is closed", tag: "TenantCache");
  }
}
