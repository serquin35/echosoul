import 'package:dio/dio.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';

/// Implements [ChatRepository] by calling the n8n webhook.
///
/// The n8n workflow receives { chatInput, sessionId } and returns
/// { output: "companion reply text" }.
class N8nChatRepositoryImpl implements ChatRepository {
  final Dio _dio;
  final String _webhookUrl;

  N8nChatRepositoryImpl({
    required Dio dio,
    required String webhookUrl,
  })  : _dio = dio,
        _webhookUrl = webhookUrl;

  @override
  Future<ChatMessage> sendMessage({
    required String userMessage,
    required String sessionId,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _webhookUrl,
        data: {
          'chatInput': userMessage,
          'sessionId': sessionId,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      final data = response.data;
      if (data == null) {
        return ChatMessage.error(
            'No recibí respuesta. Intenta de nuevo.');
      }

      // n8n ChatBot Cloud returns { output: "..." }
      final reply = data['output'] as String? ??
          data['message'] as String? ??
          data['text'] as String? ??
          'No entendí eso. ¿Puedes repetirlo?';

      return ChatMessage.fromCompanion(reply);
    } on DioException catch (e) {
      final msg = e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout
          ? 'La conexión tardó demasiado. Comprueba tu internet.'
          : 'Hubo un error al conectar. Intenta de nuevo.';
      return ChatMessage.error(msg);
    } catch (_) {
      return ChatMessage.error('Ocurrió un error inesperado.');
    }
  }
}
