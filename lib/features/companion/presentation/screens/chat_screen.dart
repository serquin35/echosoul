import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/es_colors.dart';
import '../../../../core/constants/es_spacing.dart';
import '../../../../core/constants/es_typography.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/chat_input_bar.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('EchoSoul', style: EsTypography.headlineMedium),
            Text('En línea', style: EsTypography.caption.copyWith(color: EsColors.neonCyan)),
          ],
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: EsColors.neonCyan),
            onPressed: () {
              // TODO: Navigate to settings or profile
            },
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(EsSpacing.md),
                itemCount: 4, // Placeholder count
                reverse: true, // Newest messages at the bottom
                itemBuilder: (context, index) {
                  // Dummy data for visual layout testing
                  final isMe = index % 2 == 0;
                  final text = isMe 
                      ? 'Hola, he tenido un día un poco difícil.' 
                      : 'Hola. Siento mucho escuchar eso. Estoy aquí para escucharte, ¿quieres contarme qué pasó?';
                  
                  return ChatMessageBubble(
                    text: text,
                    isMe: isMe,
                    time: '10:${45 + index} AM',
                  );
                },
              ),
            ),
            const ChatInputBar(),
          ],
        ),
      ),
    );
  }
}
