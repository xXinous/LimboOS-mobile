import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/retro_decorations.dart';
import '../../auth/data/auth_repository.dart';
import '../data/character_repository.dart';
import '../data/character_providers.dart';
import '../domain/character.dart';

class SelectAgentScreen extends ConsumerWidget {
  const SelectAgentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('NÃO AUTENTICADO')));
    }

    final charactersAsync = ref.watch(userCharactersProvider(user.uid));

    return Scaffold(
      body: RetroDecorations(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: constraints.maxWidth),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(left: 16),
                              decoration: const BoxDecoration(
                                border: Border(
                                  left: BorderSide(color: RetroTheme.kPrimary, width: 4),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'SELECIONAR AGENTE',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  Text(
                                    'CREDENCIAIS ATIVAS PARA: ${user.email?.toUpperCase()}',
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                ],
                              ),
                            ).animate().fadeIn().slideX(begin: -0.1),
                            const SizedBox(width: 16), // Espaço mínimo garantido
                            IconButton(
                              onPressed: () => ref.read(authRepositoryProvider).signOut(),
                              icon: const Icon(LucideIcons.log_out, color: RetroTheme.kIndustrialSilver),
                              tooltip: 'Sair do Sistema',
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                ),
              ),

              const Divider(color: Colors.white10, height: 1),

              // Character List
              Expanded(
                child: charactersAsync.when(
                  data: (characters) {
                    if (characters.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.shield_alert, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              'NENHUM AGENTE ENCONTRADO',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'AGUARDANDO DESIGNAÇÃO PELO ADMINISTRADOR',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ).animate().fadeIn();
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: characters.length,
                      itemBuilder: (context, index) {
                        final character = characters[index];
                        return AgentCard(
                          character: character,
                          onTap: () {
                            final campaignId = character.campaignId;
                            final unlocked = List<String>.from(character.unlockedCampaigns);
                            if (campaignId != null && !unlocked.contains(campaignId)) {
                              unlocked.add(campaignId);
                            }
                            final characterForSelection = character.copyWith(
                              campaignId: null,
                              unlockedCampaigns: unlocked,
                            );
                            ref.read(activeCharacterProvider.notifier).select(characterForSelection);
                          },
                        ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1);
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: RetroTheme.kPrimary),
                  ),
                  error: (err, stack) => Center(
                    child: Text('ERRO DE COMUNICAÇÃO: $err', style: const TextStyle(color: Colors.red)),
                  ),
                ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'ACESSO RESTRITO // PROTOCOLO RUNNING MAN V4.0',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: RetroTheme.kIndustrialSilver.withValues(alpha: 0.2),
                    letterSpacing: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AgentCard extends StatelessWidget {
  final Character character;
  final VoidCallback onTap;

  const AgentCard({
    super.key,
    required this.character,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(character.agentStatus);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: RetroTheme.kSurfaceContainerLow,
            border: Border.all(color: Colors.white10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Status vertical bar
                Container(
                  width: 6,
                  color: statusColor,
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Avatar placeholder
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                          ),
                          child: Center(
                            child: Text(
                              character.codinome.isNotEmpty ? character.codinome[0].toUpperCase() : '?',
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Text Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                character.codinome.toUpperCase(),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'ESTADO: ${character.agentStatus.name.toUpperCase()}',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: statusColor.withValues(alpha: 0.7),
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // ID indicator
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.chevron_right, size: 16, color: Colors.white24),
                            if (character.agentId != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  character.agentId!,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 8,
                                    color: Colors.white10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(AgentStatus status) {
    switch (status) {
      case AgentStatus.vivo:
        return Colors.green;
      case AgentStatus.morto:
        return Colors.red;
      case AgentStatus.desaparecido:
        return Colors.orange;
    }
  }
}
