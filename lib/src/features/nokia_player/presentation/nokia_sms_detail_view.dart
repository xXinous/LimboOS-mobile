import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/nokia_providers.dart';

class NokiaSmsDetailView extends ConsumerWidget {
  const NokiaSmsDetailView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sms = ref.watch(nokiaActiveSmsProvider);

    final textStyle = GoogleFonts.vt323(
      fontSize: 14,
      color: const Color(0xFF111E14),
      fontWeight: FontWeight.bold,
    );

    if (sms == null) {
      return Center(
        child: Text('NENHUMA MENSAGEM SELECIONADA', style: textStyle),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Sender Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF111E14),
              border: Border.all(color: const Color(0xFF111E14)),
            ),
            child: Text(
              'DE: ${sms.sender.toUpperCase()}',
              style: textStyle.copyWith(
                fontSize: 13,
                color: const Color(0xFFEDFEED),
              ),
            ),
          ),
          
          // Time details
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TIPO: SMS NARRATIVO', style: textStyle.copyWith(fontSize: 10, color: const Color(0xFF111E14).withValues(alpha: 0.6))),
              Text('HORA: ${sms.time}', style: textStyle.copyWith(fontSize: 10)),
            ],
          ),
          
          const Divider(color: Color(0xFF111E14), thickness: 1.5, height: 12),
          
          // Message Content Body
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF111E14), width: 1),
                color: const Color(0xFFEDFEED).withValues(alpha: 0.5),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: sms.messages.length,
                itemBuilder: (context, index) {
                  final msg = sms.messages[index];
                  final isMe = msg.isMe;
                  final screenWidth = MediaQuery.of(context).size.width;

                  return Container(
                    margin: EdgeInsets.only(
                      bottom: 12,
                      left: isMe ? 40.0 : 4.0,
                      right: isMe ? 4.0 : 40.0,
                    ),
                    child: Row(
                      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Container(
                            constraints: BoxConstraints(maxWidth: screenWidth * 0.75),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: isMe ? const Color(0xFF111E14) : const Color(0xFFEDFEED),
                              border: Border.all(color: const Color(0xFF111E14), width: 1.5),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFF111E14),
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg.text,
                                  textAlign: isMe ? TextAlign.right : TextAlign.left,
                                  style: textStyle.copyWith(
                                    fontSize: 14,
                                    height: 1.2,
                                    letterSpacing: 0.5,
                                    color: isMe ? const Color(0xFFEDFEED) : const Color(0xFF111E14),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  msg.time,
                                  style: textStyle.copyWith(
                                    fontSize: 9,
                                    color: isMe 
                                      ? const Color(0xFFEDFEED).withValues(alpha: 0.6) 
                                      : const Color(0xFF111E14).withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Bottom Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSimpleButton('REPLICAR', textStyle),
              const SizedBox(width: 8),
              _buildSimpleButton('EXCLUIR', textStyle),
            ],
          ),
          
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildSimpleButton(String label, TextStyle style) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF111E14)),
      ),
      child: Text(
        label,
        style: style.copyWith(fontSize: 10),
      ),
    );
  }
}
