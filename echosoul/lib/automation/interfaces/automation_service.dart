/// Abstract contract for all n8n automation triggers.
/// Implementations call n8n webhook URLs — never directly to Twilio/Vapi/OpenAI.
abstract class AutomationService {
  /// Trigger the morning check-in workflow for a specific user.
  Future<void> triggerMorningCheckin({required String userId});

  /// Trigger the evening check-in workflow.
  Future<void> triggerEveningCheckin({required String userId});

  /// Report a crisis event — triggers the crisis detection workflow.
  Future<void> reportCrisis({
    required String userId,
    required String severity,       // 'low' | 'medium' | 'high' | 'critical'
    required String triggerSource,  // 'conversation' | 'checkin' | 'inactivity'
    String? triggerSummary,         // anonymized summary — NO literal user text
  });

  /// Trigger the weekly wellbeing summary workflow.
  Future<void> triggerWeeklySummary({required String userId});
}
