import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final companionNameProvider = FutureProvider<String>((ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;
  
  if (user == null) return 'Echo';
  
  try {
    final response = await supabase
        .from('companion_settings')
        .select('companion_name')
        .eq('user_id', user.id)
        .single();
    
    return response['companion_name'] as String? ?? 'Echo';
  } catch (e) {
    return 'Echo'; // Fallback en caso de error
  }
});
