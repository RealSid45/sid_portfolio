import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ljxhljrbwvawycdwewpe.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxqeGhsanJid3Zhd3ljZHdld3BlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQxNTc5NjksImV4cCI6MjA4OTczMzk2OX0.ML7vtvN-hUubGUwdPQpgjtkwmccKXna6RMazvuKzUm0',
  );
  static const String recipientEmail = String.fromEnvironment(
    'EMAIL_RECIPIENT',
    defaultValue: 'nightwingrxs75@gmail.com',
  );
  static const String messagesTable = 'contact_messages';
}

class MessageService {
  static Future<bool> sendContactMessage({
    required String name,
    required String email,
    required String message,
  }) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim();
    final cleanMsg = message.trim();

    // 1. Send via Web FormSubmit AJAX API (CORS-friendly, instant email to nightwingrxs75@gmail.com)
    bool webFormSent = await _sendViaFormSubmit(
      name: cleanName,
      email: cleanEmail,
      message: cleanMsg,
    );
    if (webFormSent) return true;

    // 2. Try Supabase DB insert as fallback
    bool supabaseSaved = await _saveToSupabase(
      name: cleanName,
      email: cleanEmail,
      message: cleanMsg,
    );

    return supabaseSaved;
  }

  static Future<bool> _sendViaFormSubmit({
    required String name,
    required String email,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://formsubmit.co/ajax/${SupabaseConfig.recipientEmail}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'message': message,
          '_subject': '🎯 New Portfolio Contact Query from $name',
          '_captcha': 'false',
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == 'true' || data['success'] == true) {
          debugPrint('Contact email sent successfully to ${SupabaseConfig.recipientEmail}!');
          return true;
        }
      }
      debugPrint('FormSubmit HTTP ${response.statusCode}: ${response.body}');
      return false;
    } catch (e) {
      debugPrint('FormSubmit error: $e');
      return false;
    }
  }

  static Future<bool> _saveToSupabase({
    required String name,
    required String email,
    required String message,
  }) async {
    try {
      final client = Supabase.instance.client;
      await client.from(SupabaseConfig.messagesTable).insert({
        'name': name,
        'email': email,
        'message': message,
        'created_at': DateTime.now().toIso8601String(),
        'read': false,
      }).timeout(const Duration(seconds: 3));
      return true;
    } catch (e) {
      debugPrint('Supabase save error: $e');
      return false;
    }
  }
}
