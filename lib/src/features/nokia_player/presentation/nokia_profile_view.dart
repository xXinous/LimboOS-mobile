import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../characters/data/character_providers.dart';
import '../../campaigns/data/active_campaign_provider.dart';
import '../../auth/data/auth_repository.dart';

class NokiaProfileView extends ConsumerWidget {
  const NokiaProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final character = ref.watch(activeCharacterProvider);
    final activeCampaign = ref.watch(activeCampaignProvider).value;

    final textStyle = GoogleFonts.vt323(
      fontSize: 14,
      color: const Color(0xFF111E14),
      fontWeight: FontWeight.bold,
    );

    if (character == null) {
      return Center(
        child: Text('AGENTE NAO ENCONTRADO', style: textStyle),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Codinome & ID
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF111E14), width: 2),
                ),
                child: Center(
                  child: Text(
                    character.codinome.isNotEmpty
                        ? character.codinome.substring(0, 1).toUpperCase()
                        : 'A',
                    style: textStyle.copyWith(fontSize: 24, height: 1.0),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.codinome.toUpperCase(),
                      style: textStyle.copyWith(fontSize: 18, height: 1.0),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ID: RM-${character.agentId ?? "???"}',
                      style: textStyle.copyWith(
                        fontSize: 11,
                        color: const Color(0xFF111E14).withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(color: Color(0xFF111E14), thickness: 1.5, height: 16),

          // Info block
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF111E14)),
            ),
            child: Column(
              children: [
                _buildInfoRow('ESTADO', character.agentStatus.name.toUpperCase(), textStyle),
                const SizedBox(height: 6),
                _buildInfoRow('MISSAO', (activeCampaign?.name ?? 'NENHUMA').toUpperCase(), textStyle),
                const SizedBox(height: 6),
                _buildInfoRow('SETOR', (activeCampaign?.location ?? 'DESCONHECIDO').toUpperCase(), textStyle),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Danger Level
          Text('PERICULOSIDADE', style: textStyle.copyWith(fontSize: 11)),
          const SizedBox(height: 4),
          Row(
            children: List.generate(5, (index) {
              final isLit = index < character.dangerLevel;
              return Expanded(
                child: Container(
                  height: 10,
                  margin: EdgeInsets.only(right: index == 4 ? 0 : 4),
                  decoration: BoxDecoration(
                    color: isLit ? const Color(0xFF111E14) : Colors.transparent,
                    border: Border.all(color: const Color(0xFF111E14), width: 1),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    ref.read(activeCharacterProvider.notifier).clear();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF111E14)),
                    ),
                    child: Text(
                      'TROCAR AGENTE',
                      style: textStyle.copyWith(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    ref.read(authRepositoryProvider).signOut();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF111E14)),
                      color: const Color(0xFF111E14),
                    ),
                    child: Text(
                      'SAIR',
                      style: textStyle.copyWith(fontSize: 12, color: const Color(0xFFEDFEED)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, TextStyle style) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style.copyWith(fontSize: 11, color: const Color(0xFF111E14).withValues(alpha: 0.6))),
        Expanded(
          child: Text(
            value,
            style: style.copyWith(fontSize: 11),
            textAlign: Alignment.centerRight.x > 0 ? TextAlign.right : TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
