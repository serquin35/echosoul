import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/mood_entry_entity.dart';
import '../../domain/repositories/mood_repository.dart';

class MoodRepositoryImpl implements MoodRepository {
  final SupabaseClient _client;

  MoodRepositoryImpl(this._client);

  @override
  Future<List<MoodEntryEntity>> getMoodHistory() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado.');

    final response = await _client
        .from('checkins')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(30);

    return (response as List)
        .map((json) => MoodEntryEntity.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveMoodEntry(MoodEntryEntity entry) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado.');

    await _client.from('checkins').insert(entry.toMap());
  }
}
