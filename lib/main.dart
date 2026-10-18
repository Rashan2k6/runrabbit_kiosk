import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'app/kiosk_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Full screen, hides the status and navigation bars.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // Both orientations are allowed; the layout adapts.
  await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  // Never let the tablet screen turn off while the kiosk is running.
  await WakelockPlus.enable();

  // Safety net: a widget error must never show the red error screen to a customer.
  FlutterError.onError = (details) => debugPrint(details.exceptionAsString());
  ErrorWidget.builder = (details) => const SizedBox.shrink();

  runApp(KioskApp());
}
