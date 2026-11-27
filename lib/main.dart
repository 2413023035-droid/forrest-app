import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'data/supabase/supabase_client.dart';
import 'providers/auth_provider.dart';
import 'providers/session_provider.dart';
import 'providers/forest_provider.dart';
import 'providers/shop_provider.dart';
import 'providers/profile_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await initSupabase();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => ForestProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
      ],
      child: const ForrestApp(),
    ),
  );
}
