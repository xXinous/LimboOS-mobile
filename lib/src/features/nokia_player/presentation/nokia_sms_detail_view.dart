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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF111E14), width: 1),
              ),
              child: SingleChildScrollView(
                child: Text(
                  sms.text,
                  style: textStyle.copyWith(
                    fontSize: 13,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Back prompt help
          Center(
            child: Text(
              'APERTE [VOLTAR] PARA SAIR',
              style: textStyle.copyWith(
                fontSize: 10,
                color: const Color(0xFF111E14).withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
