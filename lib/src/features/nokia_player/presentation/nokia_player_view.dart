import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../domain/intel_item.dart';
import '../data/nokia_providers.dart';
import '../data/audio_engine_service.dart';

class NokiaPlayerView extends ConsumerStatefulWidget {
  const NokiaPlayerView({super.key});

  @override
  ConsumerState<NokiaPlayerView> createState() => _NokiaPlayerViewState();
}

class _NokiaPlayerViewState extends ConsumerState<NokiaPlayerView>
    with SingleTickerProviderStateMixin {
  late AnimationController _reelRotationController;
  String _activeTab = 'SMS';
  bool _showVolumeBar = false;
  Timer? _volumeTimer;

  @override
  void initState() {
    super.initState();
    _reelRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _reelRotationController.dispose();
    _volumeTimer?.cancel();
    super.dispose();
  }

  void _showVolume() {
    setState(() {
      _showVolumeBar = true;
    });
    _volumeTimer?.cancel();
    _volumeTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showVolumeBar = false;
        });
      }
    });
  }

  void _adjustVolume(int newVolume) {
    ref.read(nokiaVolumeProvider.notifier).setVolume(newVolume);
    _showVolume();
  }

  @override
  Widget build(BuildContext context) {
    final audioPlaybackStatus = ref.watch(nokiaAudioPlaybackStatusProvider);
    final activeAudio = ref.watch(activeAudioIntelProvider);

    final isPlaying = audioPlaybackStatus == NokiaAudioStatus.playing;
    final isRewinding = audioPlaybackStatus == NokiaAudioStatus.rewinding;

    if (isPlaying) {
      if (!_reelRotationController.isAnimating) {
        _reelRotationController.repeat();
      }
    } else {
      if (_reelRotationController.isAnimating) {
        _reelRotationController.stop();
      }
    }

    final textStyle = GoogleFonts.vt323(
      fontSize: 14,
      color: const Color(0xFF111E14),
      fontWeight: FontWeight.bold,
    );

    if (_showVolumeBar) {
      final volume = ref.watch(nokiaVolumeProvider);
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('[+]', style: textStyle.copyWith(fontSize: 16)),
              const SizedBox(width: 6),
              Text('VOLUME', style: textStyle.copyWith(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF111E14), width: 2),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: List.generate(10, (index) {
                final level = (index + 1) * 10;
                final isFilled = volume >= level;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _adjustVolume(level);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      color: isFilled
                          ? const Color(0xFF111E14)
                          : Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(
                              0xFF111E14,
                            ).withValues(alpha: isFilled ? 0.0 : 0.2),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          Text('NIVEL: $volume%', style: textStyle.copyWith(fontSize: 12)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              setState(() {
                _showVolumeBar = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF111E14)),
              ),
              child: Text('VOLTAR', style: textStyle.copyWith(fontSize: 12)),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        // Upper Viewport: Cassette Visor or Scan Active
        Container(
          height: 120,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF111E14), width: 2),
            color: const Color(0xFFEDFEED),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (activeAudio != null) ...[
                // Track details
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    activeAudio.title.toUpperCase(),
                    style: textStyle.copyWith(fontSize: 15),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  (activeAudio.metadata?.artist ?? 'DESCONHECIDO')
                      .toUpperCase(),
                  style: textStyle.copyWith(
                    fontSize: 11,
                    color: const Color(0xFF111E14).withValues(alpha: 0.6),
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 8),

                // Tape Reels Graphics
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildReel(isRewinding),
                    const SizedBox(width: 24),
                    _buildReel(isRewinding),
                  ],
                ),

                const SizedBox(height: 6),
                // Audio Engine Position/Duration Stream
                _buildProgressIndicator(textStyle),
              ] else ...[
                // Scanner Trigger / QR prompt
                GestureDetector(
                  onTap: () {
                    ref
                        .read(nokiaScreenStateProvider.notifier)
                        .setScreen(NokiaScreen.scanner);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF111E14),
                        width: 1,
                      ),
                      color: const Color(0xFF111E14).withValues(alpha: 0.05),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '[O]',
                          style: textStyle.copyWith(fontSize: 14),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'ESCANEAR CODIGO QR',
                          style: textStyle.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Middle Controls (Play, Pause, Rewind, Stop)
        if (activeAudio != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Rewind
                _buildControlButton(
                  textIcon: '<<',
                  onTap: () {
                    ref
                        .read(nokiaAudioPlaybackStatusProvider.notifier)
                        .setStatus(NokiaAudioStatus.rewinding);
                    ref.read(audioEngineProvider).seek(Duration.zero);
                    Future.delayed(const Duration(milliseconds: 800), () {
                      ref
                          .read(nokiaAudioPlaybackStatusProvider.notifier)
                          .setStatus(NokiaAudioStatus.loaded);
                      ref.read(audioEngineProvider).play();
                    });
                  },
                ),
                const SizedBox(width: 8),

                // Play / Pause
                _buildControlButton(
                  textIcon: isPlaying ? '||' : '|>',
                  isFilled: true,
                  onTap: () {
                    if (isPlaying) {
                      ref.read(audioEngineProvider).pause();
                    } else {
                      ref.read(audioEngineProvider).play();
                    }
                  },
                ),
                const SizedBox(width: 8),

                // Stop / Eject
                _buildControlButton(
                  textIcon: '[x]',
                  onTap: () {
                    ref.read(audioEngineProvider).stop();
                    ref.read(activeAudioIntelProvider.notifier).clear();
                  },
                ),
                const SizedBox(width: 8),

                // Volume Button
                _buildControlButton(
                  textIcon: '[+]',
                  onTap: _showVolume,
                ),
              ],
            ),
          ),

        // Tabs Row: SMS, TODOS, AUDIO, DOCS
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF111E14), width: 1),
          ),
          child: Row(
            children: ['SMS', 'TODOS', 'AUDIO', 'DOCS'].map((tab) {
              final isActive = _activeTab == tab;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _activeTab = tab;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    color: isActive
                        ? const Color(0xFF111E14)
                        : Colors.transparent,
                    child: Text(
                      tab,
                      style: textStyle.copyWith(
                        fontSize: 11,
                        color: isActive
                            ? const Color(0xFFEDFEED)
                            : const Color(0xFF111E14),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Bottom Area: Scrollable List
        Expanded(
          child: _activeTab == 'SMS'
              ? _buildSmsList(textStyle)
              : _buildIntelList(textStyle),
        ),
      ],
    );
  }

  Widget _buildReel(bool isRewinding) {
    return RotationTransition(
      turns: _reelRotationController,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: const Color(0xFF111E14),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFEDFEED), width: 2),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFEDFEED),
                shape: BoxShape.circle,
              ),
            ),
            // Spokes
            ...List.generate(4, (index) {
              return Transform.rotate(
                angle: (index * 45) * 3.14159 / 180,
                child: Container(
                  width: 20,
                  height: 1.5,
                  color: const Color(0xFFEDFEED),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required String textIcon,
    required VoidCallback onTap,
    bool isFilled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isFilled ? const Color(0xFF111E14) : Colors.transparent,
          border: Border.all(color: const Color(0xFF111E14), width: 1.5),
          borderRadius: BorderRadius.circular(isFilled ? 16 : 4),
        ),
        child: Text(
          textIcon,
          style: GoogleFonts.vt323(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isFilled ? const Color(0xFFEDFEED) : const Color(0xFF111E14),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(TextStyle textStyle) {
    final engine = ref.watch(audioEngineProvider);
    return StreamBuilder<Duration>(
      stream: engine.positionStream,
      builder: (context, snapshotPos) {
        final position = snapshotPos.data ?? Duration.zero;
        return StreamBuilder<Duration?>(
          stream: engine.durationStream,
          builder: (context, snapshotDur) {
            final duration = snapshotDur.data ?? Duration.zero;

            final posStr = _formatDuration(position);
            final durStr = _formatDuration(duration);

            final double progressPct = duration.inMilliseconds > 0
                ? (position.inMilliseconds / duration.inMilliseconds).clamp(
                    0.0,
                    1.0,
                  )
                : 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(posStr, style: textStyle.copyWith(fontSize: 10)),
                      Text(durStr, style: textStyle.copyWith(fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Segmented LCD Progress Bar (20 steps)
                  Row(
                    children: List.generate(20, (index) {
                      final stepPct = (index + 1) / 20.0;
                      final isFilled = progressPct >= stepPct;
                      return Expanded(
                        child: Container(
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 0.5),
                          color: isFilled
                              ? const Color(0xFF111E14)
                              : const Color(0xFF111E14).withValues(alpha: 0.08),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final mins = duration.inMinutes.toString().padLeft(2, '0');
    final secs = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  Widget _buildIntelList(TextStyle textStyle) {
    final intelListAsync = ref.watch(campaignIntelListProvider);

    return intelListAsync.when(
      data: (items) {
        // Filter locally by tab type
        final filteredItems = items.where((item) {
          if (_activeTab == 'TODOS') return true;
          if (_activeTab == 'AUDIO') return item.type == IntelType.audio;
          if (_activeTab == 'DOCS') {
            return item.type == IntelType.text || item.type == IntelType.visual;
          }
          return true;
        }).toList();

        if (filteredItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'NENHUM INTEL DESBLOQUEADO',
                  style: textStyle.copyWith(color: const Color(0xFF111E14)),
                ),
                const SizedBox(height: 4),
                Text(
                  'ESCANEIE UM CODIGO QR PARA COMECAR',
                  style: textStyle.copyWith(
                    fontSize: 10,
                    color: const Color(0xFF111E14).withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          );
        }

        final activeAudio = ref.watch(activeAudioIntelProvider);

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            final item = filteredItems[index];
            final isCurrent = activeAudio?.id == item.id;

            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                if (item.type == IntelType.audio && item.mediaUrl != null) {
                  ref.read(activeAudioIntelProvider.notifier).select(item);
                  ref.read(audioEngineProvider).loadTrack(item.mediaUrl!).then((
                    _,
                  ) {
                    if (ref.read(activeAudioIntelProvider)?.id == item.id) {
                      ref.read(audioEngineProvider).play();
                    }
                  });
                } else {
                  // Show text document / photo details in a simple alert dialog styled like retro LCD
                  showDialog(
                    context: context,
                    builder: (context) => _buildDetailDialog(item, textStyle),
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? const Color(0xFF111E14)
                      : Colors.transparent,
                  border: Border.all(
                    color: isCurrent
                        ? const Color(0xFF111E14)
                        : const Color(0xFF111E14).withValues(alpha: 0.1),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isCurrent
                              ? const Color(0xFFEDFEED)
                              : const Color(0xFF111E14),
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        item.type.name.substring(0, 3),
                        style: textStyle.copyWith(
                          fontSize: 9,
                          color: isCurrent
                              ? const Color(0xFFEDFEED)
                              : const Color(0xFF111E14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.title.toUpperCase(),
                        style: textStyle.copyWith(
                          color: isCurrent
                              ? const Color(0xFFEDFEED)
                              : const Color(0xFF111E14),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrent)
                      Text(
                        '|>',
                        style: textStyle.copyWith(
                          color: const Color(0xFFEDFEED),
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF111E14)),
      ),
      error: (err, stack) =>
          Center(child: Text('ERRO AO CARREGAR INTEL', style: textStyle)),
    );
  }

  Widget _buildSmsList(TextStyle textStyle) {
    final smsList = ref.watch(nokiaSmsListProvider);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: smsList.length,
      itemBuilder: (context, index) {
        final sms = smsList[index];

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            // Mark as read
            ref.read(nokiaSmsListProvider.notifier).markAsRead(sms.id);
            // Open message detail
            ref.read(nokiaActiveSmsProvider.notifier).select(sms);
            ref
                .read(nokiaScreenStateProvider.notifier)
                .setScreen(NokiaScreen.smsDetail);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF111E14).withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (!sms.read)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF111E14),
                              shape: BoxShape.circle,
                            ),
                          ),
                        Text(
                          sms.sender.toUpperCase(),
                          style: textStyle.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                    Text(
                      sms.time,
                      style: textStyle.copyWith(
                        fontSize: 10,
                        color: const Color(0xFF111E14).withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  sms.text,
                  style: textStyle.copyWith(
                    fontSize: 11,
                    color: const Color(0xFF111E14).withValues(alpha: 0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailDialog(IntelItem item, TextStyle textStyle) {
    return Dialog(
      backgroundColor: const Color(0xFFEDFEED),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFF111E14), width: 3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${item.type.name.toUpperCase()}: ${item.title.toUpperCase()}',
              style: textStyle.copyWith(fontSize: 16),
            ),
            const Divider(color: Color(0xFF111E14), thickness: 1.5),
            const SizedBox(height: 8),
            if (item.type == IntelType.visual &&
                item.mediaUrl != null &&
                item.mediaUrl!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                height: 160,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF111E14), width: 2),
                ),
                child: Image.network(
                  item.mediaUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        'FALHA AO CARREGAR IMAGEM',
                        style: textStyle.copyWith(fontSize: 10),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF111E14),
                        strokeWidth: 2,
                      ),
                    );
                  },
                ),
              ),
            ],
            Text(item.description, style: textStyle.copyWith(fontSize: 12)),
            if (item.textContent != null && item.textContent!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF111E14)),
                ),
                child: Text(
                  item.textContent!,
                  style: textStyle.copyWith(
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF111E14)),
                  ),
                  child: Text('FECHAR', style: textStyle),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
