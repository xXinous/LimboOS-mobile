import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/retro_decorations.dart';
import '../../characters/domain/character.dart';
import '../../characters/data/character_providers.dart';
import '../../campaigns/data/active_campaign_provider.dart';

class AgentDossierScreen extends ConsumerWidget {
  const AgentDossierScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final character = ref.watch(activeCharacterProvider);
    final activeCampaign = ref.watch(activeCampaignProvider).value;

    if (character == null) {
      return const Scaffold(body: Center(child: Text('AGENTE NÃO SELECIONADO')));
    }

    return Scaffold(
      body: RetroDecorations(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(LucideIcons.x, color: RetroTheme.kPrimary),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DOSSIÊ DO AGENTE',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          'ACESSO NÍVEL 4 // CONFIDENCIAL',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: RetroTheme.kPrimary.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white10, height: 1),

              // Agent Info
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildProfileHeader(character),
                      const SizedBox(height: 32),
                      _buildStatusCard(character, activeCampaign),
                      const SizedBox(height: 24),
                      _buildDangerLevel(character.dangerLevel),
                      const SizedBox(height: 48),
                      // Placeholder for future sections
                      _buildLockedSection('INTEL / ARQUIVOS'),
                      const SizedBox(height: 16),
                      _buildLockedSection('MEDALHAS / CONQUISTAS'),
                    ],
                  ),
                ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'RM-LINK: ESTABILIZADO',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.green.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Character character) {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: RetroTheme.kPrimary, width: 2),
          ),
          child: character.profilePhotoUrl != null
              ? CachedNetworkImage(
                  imageUrl: character.profilePhotoUrl!,
                  fit: BoxFit.cover,
                )
              : Center(
                  child: Text(
                    character.codinome.substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: RetroTheme.kPrimary),
                  ),
                ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                character.codinome.toUpperCase(),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1),
              ),
              const SizedBox(height: 4),
              Text(
                'ID: RM-${character.agentId ?? "???"}',
                style: const TextStyle(fontFamily: 'monospace', color: RetroTheme.kIndustrialSilver, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(Character character, dynamic activeCampaign) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RetroTheme.kSurfaceContainerLow,
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          _infoRow('ESTADO', character.agentStatus.name.toUpperCase(), _getStatusColor(character.agentStatus)),
          const Divider(color: Colors.white10, height: 24),
          _infoRow('MISSÃO ATUAL', activeCampaign?.name.toUpperCase() ?? 'NENHUMA', Colors.white),
          const SizedBox(height: 12),
          _infoRow('SETOR', activeCampaign?.location.toUpperCase() ?? 'DESCONHECIDO', RetroTheme.kIndustrialSilver),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: RetroTheme.kIndustrialSilver, letterSpacing: 1),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: valueColor),
        ),
      ],
    );
  }

  Widget _buildDangerLevel(int level) {
    final levels = ['—', 'BAIXO', 'MODERADO', 'ELEVADO', 'ALTO', 'CRÍTICO'];
    final color = level >= 4 ? Colors.red : level >= 2 ? RetroTheme.kPrimary : RetroTheme.kIndustrialSilver;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'PERICULOSIDADE',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: RetroTheme.kIndustrialSilver, letterSpacing: 1),
            ),
            Text(
              levels[level.clamp(0, 5)],
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color, letterSpacing: 1),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(5, (index) {
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index == 4 ? 0 : 4),
                decoration: BoxDecoration(
                  color: index < level ? color : Colors.white10,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildLockedSection(String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white.withValues(alpha: 0.2), letterSpacing: 2),
          ),
          Icon(LucideIcons.lock, size: 12, color: Colors.white.withValues(alpha: 0.1)),
        ],
      ),
    );
  }

  Color _getStatusColor(AgentStatus status) {
    switch (status) {
      case AgentStatus.vivo: return Colors.green;
      case AgentStatus.morto: return Colors.red;
      case AgentStatus.desaparecido: return Colors.orange;
    }
  }
}
