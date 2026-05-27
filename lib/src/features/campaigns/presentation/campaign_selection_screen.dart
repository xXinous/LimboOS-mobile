import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/retro_decorations.dart';
import '../../auth/data/auth_repository.dart';
import '../../characters/data/character_providers.dart';
import '../data/campaign_repository.dart';
import '../domain/campaign.dart';

import '../../characters/presentation/agent_dossier_screen.dart';

class CampaignSelectionScreen extends ConsumerStatefulWidget {
  const CampaignSelectionScreen({super.key});

  @override
  ConsumerState<CampaignSelectionScreen> createState() => _CampaignSelectionScreenState();
}

class _CampaignSelectionScreenState extends ConsumerState<CampaignSelectionScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeCharacter = ref.watch(activeCharacterProvider);
    final campaignsAsync = ref.watch(activeCampaignsProvider);

    return Scaffold(
      body: RetroDecorations(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => _showSecurityMenu(context),
                      icon: const Icon(LucideIcons.menu, color: RetroTheme.kPrimary),
                      tooltip: 'Menu de Segurança',
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'SELECIONAR MISSÃO',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            'AGENTE: ${activeCharacter?.codinome.toUpperCase() ?? "DESCONHECIDO"}',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: RetroTheme.kPrimary.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48), // Spacer to balance the menu icon
                  ],
                ),
              ),

              const Divider(color: Colors.white10, height: 1),

              // Campaign Carousel
              Expanded(
                child: campaignsAsync.when(
                  data: (campaigns) {
                    final filteredCampaigns = _filterCampaigns(campaigns, activeCharacter);
                    
                    if (filteredCampaigns.isEmpty) {
                      return const Center(child: Text('NENHUMA MISSÃO DISPONÍVEL'));
                    }

                    return Column(
                      children: [
                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) => setState(() => _currentIndex = index),
                            itemCount: filteredCampaigns.length,
                            itemBuilder: (context, index) {
                              return CampaignCard(
                                campaign: filteredCampaigns[index],
                                isActive: _currentIndex == index,
                                onSelect: () => _handleCampaignSelect(filteredCampaigns[index]),
                              );
                            },
                          ),
                        ),
                        // Indicator
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              filteredCampaigns.length,
                              (index) => Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: _currentIndex == index ? 24 : 8,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: _currentIndex == index 
                                      ? RetroTheme.kPrimary 
                                      : RetroTheme.kPrimary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: RetroTheme.kPrimary),
                  ),
                  error: (err, stack) => Center(
                    child: Text('ERRO: $err', style: const TextStyle(color: Colors.red)),
                  ),
                ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'STATUS: CONEXÃO SEGURA',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.green.withValues(alpha: 0.5),
                      ),
                    ),
                    Text(
                      'RM-OS V4.0',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: RetroTheme.kIndustrialSilver.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Campaign> _filterCampaigns(List<Campaign> all, dynamic character) {
    if (character == null) return [];
    final unlocked = Set<String>.from(character.unlockedCampaigns);
    // Adiciona a campanha atual se houver
    if (character.campaignId != null) unlocked.add(character.campaignId);
    
    return all.where((c) => unlocked.contains(c.id)).toList();
  }

  Future<void> _handleCampaignSelect(Campaign campaign) async {
    final activeCharacter = ref.read(activeCharacterProvider);
    final user = ref.read(authRepositoryProvider).currentUser;
    
    if (activeCharacter != null && user != null) {
      await ref.read(campaignRepositoryProvider).setActiveCampaign(
        user.uid,
        activeCharacter.id,
        campaign.id,
      );
      
      // Update local state to trigger router redirect
      ref.read(activeCharacterProvider.notifier).select(
        activeCharacter.copyWith(campaignId: campaign.id),
      );
    }
  }

  void _showSecurityMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: RetroTheme.kSurface,
      builder: (context) => const SecurityMenu(),
    );
  }

  void _showAgentDossier(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AgentDossierScreen()),
    );
  }
}

class SecurityMenu extends ConsumerWidget {
  const SecurityMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: const BoxDecoration(
        color: RetroTheme.kSurface,
        border: Border(top: BorderSide(color: RetroTheme.kPrimary, width: 2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _menuItem(
            context,
            icon: LucideIcons.id_card,
            title: 'DOSSIÊ DO AGENTE',
            onTap: () {
              Navigator.pop(context);
              (context.findAncestorStateOfType<_CampaignSelectionScreenState>()!)
                  ._showAgentDossier(context);
            },
          ),
          const SizedBox(height: 16),
          _menuItem(
            context,
            icon: LucideIcons.users,
            title: 'ALTERNAR AGENTE',
            onTap: () {
              Navigator.pop(context);
              ref.read(activeCharacterProvider.notifier).clear();
            },
          ),
          const SizedBox(height: 16),
          _menuItem(
            context,
            icon: LucideIcons.log_out,
            title: 'DESCONECTAR LINK',
            color: Colors.red,
            onTap: () {
              Navigator.pop(context);
              ref.read(authRepositoryProvider).signOut();
            },
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = RetroTheme.kPrimary,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: RetroTheme.kSurfaceContainerLow,
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const Spacer(),
            Icon(LucideIcons.chevron_right, size: 16, color: color.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}

class CampaignCard extends StatelessWidget {
  final Campaign campaign;
  final bool isActive;
  final VoidCallback onSelect;

  const CampaignCard({
    super.key,
    required this.campaign,
    required this.isActive,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: 300.ms,
      curve: Curves.easeOutCubic,
      margin: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: isActive ? 24 : 48,
      ),
      decoration: BoxDecoration(
        color: RetroTheme.kSurfaceContainerLow,
        border: Border.all(
          color: isActive ? RetroTheme.kPrimary : Colors.white10,
          width: isActive ? 2 : 1,
        ),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: RetroTheme.kPrimary.withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
        ],
      ),
      child: ClipRRect(
        child: Stack(
          children: [
            // Background Image with Overlay
            Positioned.fill(
              child: Image.network(
                campaign.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(color: Colors.black),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.8),
                      Colors.black,
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Text(
                    campaign.location.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: RetroTheme.kPrimary,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    campaign.name.toUpperCase(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    campaign.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: RetroTheme.kIndustrialSilver.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Tech Info
                  Row(
                    children: [
                      _infoBadge(LucideIcons.calendar, campaign.year),
                      const SizedBox(width: 16),
                      _infoBadge(LucideIcons.cpu, campaign.rpgSystem),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onSelect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: RetroTheme.kPrimary,
                        foregroundColor: Colors.black,
                        shape: const RoundedRectangleBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'INICIAR OPERAÇÃO',
                        style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBadge(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 12, color: RetroTheme.kIndustrialSilver),
        const SizedBox(width: 4),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: RetroTheme.kIndustrialSilver,
          ),
        ),
      ],
    );
  }
}
