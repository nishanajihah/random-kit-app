//lib/services/device_capability_service.dart

import 'package:vibration/vibration.dart';
import '../utils/app_logger.dart';

// Service to detect device hardware capabilities
// Performs a silent scan on app startup to detemine availablle features
class DeviceCapabilityService {
  // Singleton pattern
  static final DeviceCapabilityService _instance =
      DeviceCapabilityService._internal();
  factory DeviceCapabilityService() => _instance;
  DeviceCapabilityService._internal();

  // Capability flags
  bool? _hasVibrator;
  bool _isScanning = false;
  bool _scanComplete = false;

  // Getters
  bool get hasVibrator => _hasVibrator ?? false;
  bool get isScanning => _isScanning;
  bool get isScanComplete => _scanComplete;

  // Perform hardware capability scan
  // Should be called once during app initialization
  Future<void> scanCapabilities() async {
    if (_scanComplete) {
      AppLogger.info("Hardware capability scan already complete - skipping");
      return;
    }

    _isScanning = true;
    AppLogger.info("Starting hardware capability scan...");

    try {
      //  Check if device has vibrator
      _hasVibrator = await Vibration.hasVibrator();

      AppLogger.info("Hardware capability scan complete:");
      AppLogger.info(
        " - Has Vibrator support: ${_hasVibrator == true ? 'Yes' : 'No'}",
      );
    } catch (e) {
      AppLogger.error("Hardware scan failed", e);
      _hasVibrator =
          false; // Assume no vibrator if error occurs default to false on error
    } finally {
      _isScanning = false;
      _scanComplete = true;
    }
  }

  // Reset the scan state (useful for testing)
  void resetScan() {
    _hasVibrator = null;
    _scanComplete = false;
    _isScanning = false;
    AppLogger.debug("Hardware capability scan state reset");
  }

  // Get a detailed capability report (for debugging)
  Map<String, dynamic> getCapabilityReport() {
    return {
      'hasVibrator': _hasVibrator,
      'isScanning': _isScanning,
      'isScanComplete': _scanComplete,
    };
  }
}
