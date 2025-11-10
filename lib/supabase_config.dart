import 'package:supabase_flutter/supabase_flutter.dart';

// TODO: Replace these with your actual Supabase project credentials
// You can find these in your Supabase project settings > API
const String supabaseUrl = 'https://iaqjjbfbrzxtlpjbskms.supabase.co';
const String supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlhcWpqYmZicnp4dGxwamJza21zIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgzNDc2MTEsImV4cCI6MjA3MzkyMzYxMX0.52CgqDrSo7WQMdrTiF6r2Z70HyKAfbyhklyySMY5MAk';

Future<void> initSupabase() async {
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
}
