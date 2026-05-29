import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../characters/data/character_providers.dart';
import '../../characters/domain/character.dart';
import '../../campaigns/data/active_campaign_provider.dart';
import '../../auth/data/auth_repository.dart';
import '../data/nokia_providers.dart';

class NokiaProfileView extends ConsumerWidget {
  const NokiaProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final character = ref.watch(activeCharacterProvider);
    // ignore: unused_local_variable
    final activeCampaign = ref.watch(activeCampaignProvider).value;
    final intelListAsync = ref.watch(campaignIntelListProvider);

    // In a real app, achievementIds would be part of the character data or a separate provider.
    // For now, we'll use placeholder counts if not available in the domain model.
    final intelCount = intelListAsync.value?.length ?? 0;
    const achievementCount = 0; // Achievement tracking to be integrated

    final textStyle = GoogleFonts.vt323(
      fontSize: 14,
      color: const Color(0xFF111E14),
      fontWeight: FontWeight.bold,
    );

    if (character == null) {
      return Center(child: Text('AGENTE NAO ENCONTRADO', style: textStyle));
    }

    final initials = character.codinome.isNotEmpty
        ? character.codinome.substring(0, 1).toUpperCase()
        : 'A';

    final dangerLevels = [
      '—',
      'BAIXO',
      'MODERADO',
      'ELEVADO',
      'ALTO',
      'CRÍTICO',
    ];
    final dangerLabel = dangerLevels[character.dangerLevel.clamp(0, 5)];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Back and Exit buttons like Web
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  ref
                      .read(nokiaScreenStateProvider.notifier)
                      .setScreen(NokiaScreen.player);
                },
                child: Text(
                  '[VOLTAR]',
                  style: textStyle.copyWith(fontSize: 10),
                ),
              ),
              Text(
                'CLASSIFICADO',
                style: textStyle.copyWith(
                  fontSize: 9,
                  color: const Color(0xFF111E14),
                  letterSpacing: 1,
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  ref.read(authRepositoryProvider).signOut();
                },
                child: Text('[SAIR]', style: textStyle.copyWith(fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Main Dossier Card (Matches Web Layout)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEDFEED),
              border: Border.all(color: const Color(0xFF111E14), width: 2),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pixel Photo Placeholder
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF111E14),
                          width: 2,
                        ),
                        color: const Color(0xFFEDFEED),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (character.profilePhotoUrl != null)
                            ColorFiltered(
                              colorFilter: const ColorFilter.matrix([
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0,
                                0,
                                0,
                                1,
                                0,
                              ]),
                              child: Image.network(
                                character.profilePhotoUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            Center(
                              child: Text(
                                initials,
                                style: textStyle.copyWith(
                                  fontSize: 28,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          // Scanline Overlay
                          IgnorePointer(
                            child: Opacity(
                              opacity: 0.1,
                              child: Column(
                                children: List.generate(
                                  28,
                                  (i) => Expanded(
                                    child: Container(
                                      color: i % 2 == 0
                                          ? const Color(0xFF111E14)
                                          : Colors.transparent,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            character.codinome.toUpperCase(),
                            style: textStyle.copyWith(
                              fontSize: 18,
                              height: 1.0,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'AGENT_ID: RM-${character.agentId ?? "XXXX"}',
                            style: textStyle.copyWith(
                              fontSize: 10,
                              color: const Color(
                                0xFF111E14,
                              ).withValues(alpha: 0.6),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: character.agentStatus == AgentStatus.vivo
                                  ? const Color(0xFF111E14)
                                  : Colors.transparent,
                              border: Border.all(
                                color: const Color(0xFF111E14),
                              ),
                            ),
                            child: Text(
                              character.agentStatus == AgentStatus.vivo
                                  ? 'ATIVO'
                                  : (character.agentStatus == AgentStatus.morto
                                        ? 'ELIMINADO'
                                        : 'DESAPARECIDO'),
                              style: textStyle.copyWith(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: character.agentStatus == AgentStatus.vivo
                                    ? const Color(0xFFEDFEED)
                                    : const Color(0xFF111E14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(
                  color: Color(0xFF111E14),
                  thickness: 1,
                  height: 1,
                ),
                const SizedBox(height: 12),

                // Stats Grid (Matching Web)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PROVAS_INTEL',
                            style: textStyle.copyWith(
                              fontSize: 8,
                              color: const Color(
                                0xFF111E14,
                              ).withValues(alpha: 0.6),
                            ),
                          ),
                          Text(
                            intelCount.toString(),
                            style: textStyle.copyWith(
                              fontSize: 20,
                              height: 1.0,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: const Color(0xFF111E14).withValues(alpha: 0.2),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MEDALHAS_REG',
                            style: textStyle.copyWith(
                              fontSize: 8,
                              color: const Color(
                                0xFF111E14,
                              ).withValues(alpha: 0.6),
                            ),
                          ),
                          Text(
                            achievementCount.toString(),
                            style: textStyle.copyWith(
                              fontSize: 20,
                              height: 1.0,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(
                  color: Color(0xFF111E14),
                  thickness: 1,
                  height: 1,
                ),
                const SizedBox(height: 12),

                // Danger Level
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'NIVEL_PERICULOSIDADE',
                          style: textStyle.copyWith(
                            fontSize: 9,
                            color: const Color(
                              0xFF111E14,
                            ).withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          dangerLabel,
                          style: textStyle.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: List.generate(5, (index) {
                        return Expanded(
                          child: Container(
                            height: 8,
                            margin: EdgeInsets.only(right: index == 4 ? 0 : 3),
                            decoration: BoxDecoration(
                              color: index < character.dangerLevel
                                  ? const Color(0xFF111E14)
                                  : Colors.transparent,
                              border: Border.all(
                                color: const Color(0xFF111E14),
                                width: 1,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Actions (Matches Web Style)
          _buildActionItem('ALVO / MISSÃO', '>>', () {
            HapticFeedback.mediumImpact();
          }, textStyle),
          const SizedBox(height: 8),
          _buildActionItem('TROCAR AGENTE', '>>', () {
            HapticFeedback.mediumImpact();
            ref.read(activeCharacterProvider.notifier).clear();
          }, textStyle),

          const SizedBox(height: 20),

          // Spotify (Matches Web Style)
          _buildSectionHeader('WALKMAN / REDE_SCN', textStyle),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF111E14), width: 2),

              color: const Color(0xFFEDFEED),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (character.spotifyPlaylistUrl != null) ...[
                  Text(
                    'WALKMAN CONECTADO',
                    style: textStyle.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    character.spotifyPlaylistUrl!,
                    style: textStyle.copyWith(
                      fontSize: 9,
                      color: const Color(0xFF111E14).withValues(alpha: 0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ] else ...[
                  Text(
                    'SEM CONEXÃO DE ÁUDIO.',
                    style: textStyle.copyWith(
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF111E14).withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Phone (Matches Web Style)
          _buildSectionHeader('CONTATO / SMS_LINK', textStyle),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF111E14), width: 2),

              color: const Color(0xFFEDFEED),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STATUS: ATIVO',
                      style: textStyle.copyWith(
                        fontSize: 8,
                        color: const Color(0xFF111E14).withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      'UNLINKED',
                      style: textStyle.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF111E14),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      '[GERAR]',
                      style: textStyle.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Gallery (Placeholder matching Web style)
          _buildSectionHeader('ARQUIVOS_VISUAIS', textStyle),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF111E14), width: 2),

              color: const Color(0xFFEDFEED),
            ),
            child: Text(
              'EM DESENVOLVIMENTO',
              style: textStyle.copyWith(
                fontSize: 10,
                color: const Color(0xFF111E14).withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 20),

          // Operational Records (Matches Web Style)
          _buildSectionHeader('REGISTROS_OPERACIONAIS', textStyle),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF111E14), width: 2),

              color: const Color(0xFFEDFEED),
            ),
            child: Row(
              children: [
                Text(
                  '[LOCK]',
                  style: textStyle.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'ARQUIVOS BLOQUEADOS',
                  style: textStyle.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    String label,
    String icon,
    VoidCallback onTap,
    TextStyle style,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF111E14), width: 2),

          color: const Color(0xFFEDFEED),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('[ ] $label', style: style.copyWith(fontSize: 12)),
            Text(icon, style: style.copyWith(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String label, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Text(
        label,
        style: style.copyWith(
          fontSize: 9,
          color: const Color(0xFF111E14).withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
