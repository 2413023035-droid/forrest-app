import 'package:supabase_flutter/supabase_flutter.dart';

/// Ambil nilai dari --dart-define saat build:
///   flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co
///               --dart-define=SUPABASE_ANON_KEY=eyJxxx
const String _supabaseUrl     = String.fromEnvironment('SUPABASE_URL');
const String _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

/// Singleton global Supabase client
final supabase = Supabase.instance.client;

Future<void> initSupabase() async {
  assert(_supabaseUrl.isNotEmpty,
      'SUPABASE_URL tidak di-set. Gunakan --dart-define=SUPABASE_URL=...');
  assert(_supabaseAnonKey.isNotEmpty,
      'SUPABASE_ANON_KEY tidak di-set. Gunakan --dart-define=SUPABASE_ANON_KEY=...');

  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );
}
