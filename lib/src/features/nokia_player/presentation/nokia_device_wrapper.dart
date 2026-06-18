import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../nokia_theme.dart';
import '../data/nokia_providers.dart';
import 'nokia_bottom_nav.dart';

class ScanlinePainter extends CustomPainter {
  const ScanlinePainter();

  // Paint estático: alocado uma única vez, não a cada chamada de paint()
  static final _paint = Paint()
    ..color = NokiaTheme.kBlackInk.withValues(alpha: 0.03)
    ..strokeWidth = 1.0;

  @override
  void paint(Canvas canvas, Size size) {
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), _paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class NokiaDeviceWrapper extends ConsumerWidget {
  final Widget child;

  const NokiaDeviceWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeScreen = ref.watch(nokiaScreenStateProvider);
    final audioPlaybackStatus = ref.watch(nokiaAudioPlaybackStatusProvider);

    final isScanning =
        audioPlaybackStatus == NokiaAudioStatus.rewinding ||
        audioPlaybackStatus == NokiaAudioStatus.loading ||
        activeScreen == NokiaScreen.scanner;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: NokiaTheme.kLcdGreen, // LCD Green background
        body: SafeArea(
          child: Stack(
            children: [
              // Screen Inner Borders
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: NokiaTheme.kBlackInk.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                ),
              ),

              // Screen Content Column
              Column(
                children: [
                  // Viewport
                  Expanded(child: child),

                  // Bottom Navigation Bar (Hidden during scanning)
                  if (!isScanning)
                    NokiaBottomNav(
                      onBack: () =>
                      ref
                          .read(nokiaScreenStateProvider.notifier)
                          .setScreen(NokiaScreen.player),
                      onProfileOpen: () {
                        ref
                            .read(nokiaScreenStateProvider.notifier)
                            .setScreen(NokiaScreen.profile);
                      },
                      backVisible: activeScreen != NokiaScreen.player,
                    ),
                ],
              ),

              // CRT Scanline Overlay
              const Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: ScanlinePainter()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
