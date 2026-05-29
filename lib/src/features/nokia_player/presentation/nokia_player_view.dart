import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../domain/intel_item.dart';
import '../data/nokia_providers.dart';
import '../data/audio_engine_service.dart';

/* ─── PIXEL ART WIDGET ─── */
class PixelIcon extends StatelessWidget {
  final List<String> matrix;
  final double pixelSize;
  final Color color;

  const PixelIcon({
    super.key,
    required this.matrix,
    this.pixelSize = 1.5,
    this.color = const Color(0xFF111E14),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: matrix.map((row) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: row.split('').map((pixel) {
            return Container(
              width: pixelSize,
              height: pixelSize,
              color: pixel == 'X' ? color : Colors.transparent,
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  // Predefined Icons
  static const List<String> play = [
    'X       ',
    'XX      ',
    'XXX     ',
    'XXXX    ',
    'XXXXX   ',
    'XXXX    ',
    'XXX     ',
    'XX      ',
    'X       ',
  ];

  static const List<String> pause = [
    'XXX XXX',
    'XXX XXX',
    'XXX XXX',
    'XXX XXX',
    'XXX XXX',
    'XXX XXX',
    'XXX XXX',
  ];

  static const List<String> rewind = [
    '  X  XX',
    ' XX  XX',
    'XXX  XX',
    ' XX  XX',
    '  X  XX',
  ];

  static const List<String> close = [
    'X   X',
    ' X X ',
    '  X  ',
    ' X X ',
    'X   X',
  ];

  static const List<String> volume = [
    '  X  ',
    ' XX  ',
    'XXXXX',
    ' XX  ',
    '  X  ',
  ];

  static const List<String> audio = [
    '  X  ',
    ' XXX ',
    'XXXXX',
    ' XXX ',
    '  X  ',
  ];

  static const List<String> doc = [
    'XXXXX ',
    'X   XX',
    'X    X',
    'X    X',
    'XXXXXX',
  ];

  static const List<String> sms = [
    'XXXXXX',
    'X    X',
    'X XX X',
    'X    X',
    'XXXXXX',
  ];

  static const List<String> camera = [
    '  XXX  ',
    'XXXXXXX',
    'XX X XX',
    'XXXXXXX',
  ];
}

class NokiaPlayerView extends ConsumerStatefulWidget {
  const NokiaPlayerView({super.key});

  @override
  ConsumerState<NokiaPlayerView> createState() => _NokiaPlayerViewState();
}

class _NokiaPlayerViewState extends ConsumerState<NokiaPlayerView>
    with SingleTickerProviderStateMixin {
  late AnimationController _reelRotationController;
  String _activeTab = 'TODOS';
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
          Column(
            children: [
              const PixelIcon(matrix: PixelIcon.volume, pixelSize: 2.5),
              const SizedBox(height: 8),
              Text(
                'VOLUME',
                style: textStyle.copyWith(fontSize: 18, letterSpacing: 2),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFEDFEED),
              border: Border.all(color: const Color(0xFF111E14), width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF111E14),
                  offset: Offset(2, 2),
                ),
              ],
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
                      decoration: BoxDecoration(
                        color: isFilled
                            ? const Color(0xFF111E14)
                            : Colors.transparent,
                        border: Border.all(
                          color: const Color(0xFF111E14),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'NIVEL: $volume%',
            style: textStyle.copyWith(fontSize: 14, letterSpacing: 1),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () {
              setState(() {
                _showVolumeBar = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF111E14), width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF111E14),
                    offset: Offset(1, 1),
                  ),
                ],
              ),
              child: Text('VOLTAR', style: textStyle),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        // Upper Viewport: Cassette Visor or Scan Active
        Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF111E14), width: 2),
            color: const Color(0xFFEDFEED),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF111E14),
                offset: Offset(2, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (activeAudio != null) ...[
                // Track details
                Text(
                  activeAudio.title.toUpperCase(),
                  style: textStyle.copyWith(fontSize: 16),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  (activeAudio.metadata?.artist ?? 'DESCONHECIDO')
                      .toUpperCase(),
                  style: textStyle.copyWith(
                    fontSize: 12,
                    color: const Color(0xFF111E14).withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 12),

                // Tape Reels Graphics
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildReel(isRewinding),
                    const SizedBox(width: 32),
                    _buildReel(isRewinding),
                  ],
                ),

                const SizedBox(height: 12),
                _buildProgressIndicator(textStyle),
              ] else ...[
                // Scanner Trigger
                GestureDetector(
                  onTap: () {
                    ref
                        .read(nokiaScreenStateProvider.notifier)
                        .setScreen(NokiaScreen.scanner);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF111E14), width: 1),
                      color: const Color(0xFF111E14).withValues(alpha: 0.05),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const PixelIcon(matrix: PixelIcon.camera, pixelSize: 2),
                        const SizedBox(height: 8),
                        Text(
                          'ESCANEAR CODIGO QR',
                          style: textStyle.copyWith(fontSize: 14, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Middle Controls
        if (activeAudio != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: PixelIcon.rewind,
                  onTap: () {
                    ref
                        .read(nokiaAudioPlaybackStatusProvider.notifier)
                        .setStatus(NokiaAudioStatus.rewinding);
                    ref.read(audioEngineProvider).seek(Duration.zero);
                    Future.delayed(const Duration(milliseconds: 1000), () {
                      ref
                          .read(nokiaAudioPlaybackStatusProvider.notifier)
                          .setStatus(NokiaAudioStatus.loaded);
                      ref.read(audioEngineProvider).play();
                    });
                  },
                ),
                const SizedBox(width: 12),
                _buildControlButton(
                  icon: isPlaying ? PixelIcon.pause : PixelIcon.play,
                  isFilled: true,
                  onTap: () {
                    if (isPlaying) {
                      ref.read(audioEngineProvider).pause();
                    } else {
                      ref.read(audioEngineProvider).play();
                    }
                  },
                ),
                const SizedBox(width: 12),
                _buildControlButton(
                  icon: PixelIcon.close,
                  onTap: () {
                    ref.read(audioEngineProvider).stop();
                    ref.read(activeAudioIntelProvider.notifier).clear();
                  },
                ),
                const SizedBox(width: 12),
                _buildControlButton(
                  icon: PixelIcon.volume,
                  onTap: _showVolume,
                ),
              ],
            ),
          ),

        // Tabs Row
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEDFEED),
            border: Border.all(color: const Color(0xFF111E14), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF111E14),
                offset: Offset(1, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildTab('SMS', PixelIcon.sms),
              _buildTab('TODOS', null),
              _buildTab('AUDIO', PixelIcon.audio),
              _buildTab('DOCS', PixelIcon.doc),
            ],
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

  Widget _buildTab(String label, List<String>? iconMatrix) {
    final isActive = _activeTab == label;
    final tabTextStyle = GoogleFonts.vt323(
      fontSize: 10,
      fontWeight: FontWeight.bold,
      color: isActive ? const Color(0xFFEDFEED) : const Color(0xFF111E14),
    );

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeTab = label;
          });
          HapticFeedback.selectionClick();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          color: isActive ? const Color(0xFF111E14) : const Color(0xFFEDFEED),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconMatrix != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: PixelIcon(
                    matrix: iconMatrix,
                    pixelSize: 1,
                    color: isActive ? const Color(0xFFEDFEED) : const Color(0xFF111E14),
                  ),
                )
              else
                Text(
                  '[*]',
                  style: TextStyle(
                    fontSize: 8,
                    color: isActive ? const Color(0xFFEDFEED) : const Color(0xFF111E14),
                  ),
                ),
              Text(
                label,
                style: tabTextStyle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReel(bool isRewinding) {
    return RotationTransition(
      turns: _reelRotationController,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFF111E14),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFEDFEED), width: 2),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFFEDFEED),
                shape: BoxShape.circle,
              ),
            ),
            ...List.generate(4, (index) {
              return Transform.rotate(
                angle: (index * 45) * 3.14159 / 180,
                child: Container(
                  width: 28,
                  height: 2,
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
    required List<String> icon,
    required VoidCallback onTap,
    bool isFilled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isFilled ? const Color(0xFF111E14) : const Color(0xFFEDFEED),
          border: Border.all(color: const Color(0xFF111E14), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF111E14),
              offset: Offset(1, 1),
            ),
          ],
        ),
        child: PixelIcon(
          matrix: icon,
          pixelSize: 1.8,
          color: isFilled ? const Color(0xFFEDFEED) : const Color(0xFF111E14),
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
                ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
                : 0.0;

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(posStr, style: textStyle.copyWith(fontSize: 12)),
                    Text(durStr, style: textStyle.copyWith(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  height: 16,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF111E14), width: 1.5),
                  ),
                  child: Row(
                    children: List.generate(20, (index) {
                      final stepPct = (index + 1) / 20.0;
                      final isFilled = progressPct >= stepPct;
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 0.5),
                          color: isFilled ? const Color(0xFF111E14) : Colors.transparent,
                        ),
                      );
                    }),
                  ),
                ),
              ],
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
        final filteredItems = items.where((item) {
          if (_activeTab == 'TODOS') return true;
          if (_activeTab == 'AUDIO') return item.type == IntelType.audio;
          if (_activeTab == 'DOCS') {
            return item.type != IntelType.audio;
          }
          return true;
        }).toList();

        if (filteredItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const PixelIcon(matrix: PixelIcon.doc, pixelSize: 2, color: Color(0xFF111E14)),
                const SizedBox(height: 12),
                Text(
                  'VAZIO',
                  style: textStyle.copyWith(fontSize: 16, letterSpacing: 2),
                ),
              ],
            ),
          );
        }

        final activeAudio = ref.watch(activeAudioIntelProvider);

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            final item = filteredItems[index];
            final isCurrent = activeAudio?.id == item.id;

            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                if (item.type == IntelType.audio && item.mediaUrl != null) {
                  ref.read(activeAudioIntelProvider.notifier).select(item);
                  ref.read(audioEngineProvider).loadTrack(item.mediaUrl!).then((_) {
                    if (ref.read(activeAudioIntelProvider)?.id == item.id) {
                      ref.read(audioEngineProvider).play();
                    }
                  });
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => _buildDetailDialog(item, textStyle),
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isCurrent ? const Color(0xFF111E14) : const Color(0xFFEDFEED),
                  border: Border.all(color: const Color(0xFF111E14), width: 2),
                  boxShadow: [
                    if (!isCurrent)
                      const BoxShadow(
                        color: Color(0xFF111E14),
                        offset: Offset(1, 1),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    PixelIcon(
                      matrix: item.type == IntelType.audio 
                        ? PixelIcon.audio 
                        : (item.type == IntelType.visual ? PixelIcon.camera : PixelIcon.doc),
                      pixelSize: 1.2,
                      color: isCurrent ? const Color(0xFFEDFEED) : const Color(0xFF111E14),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.title.toUpperCase(),
                        style: textStyle.copyWith(
                          fontSize: 14,
                          color: isCurrent ? const Color(0xFFEDFEED) : const Color(0xFF111E14),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrent)
                      Row(
                        children: List.generate(3, (i) {
                          return Container(
                            width: 2,
                            height: 10,
                            margin: const EdgeInsets.only(left: 2),
                            color: const Color(0xFFEDFEED),
                          );
                        }),
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
      error: (err, stack) => Center(child: Text('ERRO AO CARREGAR INTEL', style: textStyle)),
    );
  }

  Widget _buildSmsList(TextStyle textStyle) {
    final smsList = ref.watch(nokiaSmsListProvider);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: smsList.length,
      itemBuilder: (context, index) {
        final sms = smsList[index];

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            ref.read(nokiaSmsListProvider.notifier).markAsRead(sms.id);
            ref.read(nokiaActiveSmsProvider.notifier).select(sms);
            ref.read(nokiaScreenStateProvider.notifier).setScreen(NokiaScreen.smsDetail);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEDFEED),
              border: Border.all(color: const Color(0xFF111E14), width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF111E14),
                  offset: Offset(1, 1),
                ),
              ],
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
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 8),
                            color: const Color(0xFF111E14),
                          ),
                        Text(
                          sms.sender.toUpperCase(),
                          style: textStyle.copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                    Text(
                      sms.time,
                      style: textStyle.copyWith(
                        fontSize: 11,
                        color: const Color(0xFF111E14).withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  sms.text,
                  style: textStyle.copyWith(
                    fontSize: 13,
                    color: const Color(0xFF111E14).withValues(alpha: 0.9),
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Color(0xFF111E14), width: 3),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (item.type == IntelType.meta && item.metadata?.icon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(item.metadata!.icon!, style: const TextStyle(fontSize: 24)),
                  ),
                Expanded(
                  child: Text(
                    '${item.type.name.toUpperCase()}: ${item.title.toUpperCase()}',
                    style: textStyle.copyWith(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(color: Color(0xFF111E14), thickness: 2),
            const SizedBox(height: 12),
            if (item.type == IntelType.visual && item.mediaUrl != null && item.mediaUrl!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                height: 180,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF111E14), width: 2),
                ),
                child: Image.network(
                  item.mediaUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(child: Text('ERRO AO CARREGAR IMAGEM')),
                ),
              ),
            ],
            if (item.type == IntelType.text && item.textContent != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF111E14), width: 1),
                ),
                child: Text(
                  item.textContent!,
                  style: textStyle.copyWith(fontSize: 12, height: 1.2),
                ),
              ),
            ],
            Text(item.description, style: textStyle.copyWith(fontSize: 14)),
            if (item.type == IntelType.meta && item.metadata?.hint != null && item.metadata!.hint!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF111E14).withValues(alpha: 0.3), width: 1, style: BorderStyle.none),
                  color: const Color(0xFF111E14).withValues(alpha: 0.05),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DICA:', style: textStyle.copyWith(fontSize: 10, color: const Color(0xFF111E14).withValues(alpha: 0.6))),
                    const SizedBox(height: 2),
                    Text(item.metadata!.hint!, style: textStyle.copyWith(fontSize: 12)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF111E14), width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF111E14),
                        offset: Offset(1, 1),
                      ),
                    ],
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
