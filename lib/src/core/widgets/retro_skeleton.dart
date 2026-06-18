import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';

/// Retro-themed skeleton loading widgets that maintain the Limbo OS immersion.
/// 
/// Instead of generic Material spinners, these show ASCII/pixel-art styled
/// loading states that feel like "the system is decoding data" rather than
/// "the internet is slow".
class RetroSkeleton extends StatelessWidget {
  final Widget child;

  const RetroSkeleton._({required this.child});

  /// Full screen boot-up skeleton for home_screen.dart
  /// Shows a "system initializing" animation on dark background.
  static Widget fullScreen() {
    return const _FullScreenBootSkeleton();
  }

  /// Agent list skeleton for select_agent_screen.dart
  /// Shows pulsing agent card placeholders.
  static Widget agentList() {
    return const _AgentListSkeleton();
  }

  /// Campaign carousel skeleton for campaign_selection_screen.dart
  /// Shows a large card placeholder with decoding text.
  static Widget campaignCarousel() {
    return const _CampaignCarouselSkeleton();
  }

  /// Nokia LCD-style list skeleton for nokia_player_view.dart intel list
  /// Shows pulsing lines in the Nokia green LCD style.
  static Widget nokiaList() {
    return const _NokiaListSkeleton();
  }

  @override
  Widget build(BuildContext context) => child;
}

// ─── FULL SCREEN BOOT SKELETON ───────────────────────────────────────────────

class _FullScreenBootSkeleton extends StatelessWidget {
  const _FullScreenBootSkeleton();

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.spaceGrotesk(
      fontSize: 10,
      fontWeight: FontWeight.bold,
      color: RetroTheme.kPrimary.withValues(alpha: 0.6),
      letterSpacing: 2,
    );

    return Scaffold(
      backgroundColor: RetroTheme.kSurface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('LIMBO OS v4.0', style: textStyle)
                  .animate(onPlay: (c) => c.repeat())
                  .fadeIn(duration: 300.ms)
                  .then()
                  .fadeOut(duration: 300.ms, delay: 600.ms)
                  .then()
                  .fadeIn(duration: 200.ms),
              const SizedBox(height: 8),
              Text('INICIALIZANDO MODULOS...', style: textStyle.copyWith(fontSize: 9))
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 400.ms),
              const SizedBox(height: 16),
              // Progress blocks
              _buildProgressBlocks(),
              const SizedBox(height: 16),
              Text(
                '░░░░░░░░░░░░░░░░░░░░░░░░░░░░',
                style: textStyle.copyWith(
                  fontSize: 8,
                  color: RetroTheme.kPrimary.withValues(alpha: 0.15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBlocks() {
    return SizedBox(
      height: 6,
      child: Row(
        children: List.generate(16, (index) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 2),
              decoration: BoxDecoration(
                color: RetroTheme.kPrimary.withValues(alpha: 0.3),
              ),
            )
                .animate(delay: (index * 80).ms)
                .fadeIn(duration: 200.ms)
                .then()
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fade(
                  begin: 0.3,
                  end: 1.0,
                  duration: (400 + index * 50).ms,
                ),
          );
        }),
      ),
    );
  }
}

// ─── AGENT LIST SKELETON ─────────────────────────────────────────────────────

class _AgentListSkeleton extends StatelessWidget {
  const _AgentListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: RetroTheme.kSurfaceContainerLow,
              border: Border.all(color: Colors.white10),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Status bar placeholder
                  Container(
                    width: 6,
                    color: RetroTheme.kPrimary.withValues(alpha: 0.2),
                  ),
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
                              border: Border.all(
                                color: RetroTheme.kPrimary.withValues(alpha: 0.1),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Text placeholders
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 14,
                                  width: 120,
                                  color: RetroTheme.kPrimary.withValues(alpha: 0.1),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 8,
                                  width: 80,
                                  color: RetroTheme.kPrimary.withValues(alpha: 0.05),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
              .animate(delay: (index * 150).ms)
              .fadeIn(duration: 300.ms)
              .slideX(begin: -0.05)
              .then()
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fade(begin: 0.5, end: 1.0, duration: 800.ms),
        );
      },
    );
  }
}

// ─── CAMPAIGN CAROUSEL SKELETON ──────────────────────────────────────────────

class _CampaignCarouselSkeleton extends StatelessWidget {
  const _CampaignCarouselSkeleton();

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.spaceGrotesk(
      fontSize: 11,
      fontWeight: FontWeight.bold,
      color: RetroTheme.kPrimary.withValues(alpha: 0.5),
      letterSpacing: 2,
    );

    return Column(
      children: [
        Expanded(
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              decoration: BoxDecoration(
                color: RetroTheme.kSurfaceContainerLow,
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 10,
                          width: 80,
                          color: RetroTheme.kPrimary.withValues(alpha: 0.15),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 20,
                          width: 200,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 8,
                          width: double.infinity,
                          color: Colors.white.withValues(alpha: 0.04),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 8,
                          width: 180,
                          color: Colors.white.withValues(alpha: 0.04),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'DECODIFICANDO MISSÕES...',
                          style: textStyle,
                        )
                            .animate(onPlay: (c) => c.repeat())
                            .fadeIn(duration: 400.ms)
                            .then()
                            .fadeOut(duration: 400.ms, delay: 400.ms)
                            .then()
                            .fadeIn(duration: 300.ms),
                      ],
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.95, 0.95))
                .then()
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fade(begin: 0.6, end: 1.0, duration: 1000.ms),
          ),
        ),
        // Indicator placeholder
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: index == 0 ? 24 : 8,
                height: 4,
                decoration: BoxDecoration(
                  color: RetroTheme.kPrimary.withValues(alpha: index == 0 ? 0.3 : 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ─── NOKIA LCD LIST SKELETON ─────────────────────────────────────────────────

class _NokiaListSkeleton extends StatelessWidget {
  const _NokiaListSkeleton();

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.vt323(
      fontSize: 14,
      color: const Color(0xFF111E14),
      fontWeight: FontWeight.bold,
    );

    return Column(
      children: [
        const SizedBox(height: 12),
        Text(
          'CARREGANDO INTEL...',
          style: textStyle.copyWith(
            fontSize: 12,
            letterSpacing: 1,
            color: const Color(0xFF111E14).withValues(alpha: 0.5),
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .fadeIn(duration: 300.ms)
            .then()
            .fadeOut(duration: 300.ms, delay: 500.ms)
            .then()
            .fadeIn(duration: 200.ms),
        const SizedBox(height: 12),
        ...List.generate(5, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8, left: 12, right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEDFEED),
              border: Border.all(
                color: const Color(0xFF111E14).withValues(alpha: 0.15),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                // Icon placeholder
                Container(
                  width: 8,
                  height: 8,
                  color: const Color(0xFF111E14).withValues(alpha: 0.15),
                ),
                const SizedBox(width: 12),
                // Text placeholder
                Container(
                  height: 12,
                  width: 80.0 + (index * 20.0),
                  color: const Color(0xFF111E14).withValues(alpha: 0.1),
                ),
              ],
            ),
          )
              .animate(delay: (index * 100).ms)
              .fadeIn(duration: 200.ms)
              .then()
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fade(
                begin: 0.4,
                end: 1.0,
                duration: (600 + index * 80).ms,
              );
        }),
      ],
    );
  }
}
