import '../entities/mood_entry_entity.dart';

abstract class MoodRepository {
  Future<List<MoodEntryEntity>> getMoodHistory();
  Future<void> saveMoodEntry(MoodEntryEntity entry);
}
