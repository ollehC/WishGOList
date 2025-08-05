import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/main/flutter/core/app.dart';
import 'src/main/flutter/core/providers/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize core services
  await AppProviders.initialize();
  
  runApp(
    MultiProvider(
      providers: AppProviders.providers,
      child: const WishGoApp(),
    ),
  );
}