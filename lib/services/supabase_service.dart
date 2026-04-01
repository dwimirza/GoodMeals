import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://fovmziytkgqovveavnbr.supabase.co',
      anonKey: 'sb_publishable_bf6D626Ed1QVOBEZCemL7Q__33pgXEF',
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentUser => client.auth.currentUser;

  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;

  static Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    await client.auth.signUp(
      email: email,
      password: password,
      data: {
        'username': username,
      },
    );
  }

  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }
}