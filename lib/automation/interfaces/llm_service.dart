/// Abstract contract for LLM services (OpenAI GPT-4o implementation).
abstract class LlmService {
  /// Generate a companion response given a conversation history.
  Future<String> generateResponse({
    required List<Map<String, String>> messages, // [{role: 'user'|'assistant', content: '...'}]
    String? systemPromptOverride,
    double temperature = 0.85,
  });

  /// Analyze a message for crisis signals.
  /// Returns severity: 'none' | 'low' | 'medium' | 'high' | 'critical'
  Future<String> analyzeCrisisSeverity({required String userMessage});
}
