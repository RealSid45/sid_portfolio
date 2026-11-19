import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String messagesTable = 'contact_messages';
}

class MessageService {
  static SupabaseClient get _client => Supabase.instance.client;

  static Future<bool> sendContactMessage({
    required String name,
    required String email,
    required String message,
  }) async {
    try {
      await _client.from(SupabaseConfig.messagesTable).insert({
        'name': name.trim(),
        'email': email.trim(),
        'message': message.trim(),
        'created_at': DateTime.now().toIso8601String(),
        'read': false,
      });
      return true;
    } on PostgrestException catch (e) {
      debugPrint('Supabase error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return false;
    }
  }
}
