import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/nokia_providers.dart';

class NokiaBottomNav extends ConsumerWidget {
  final VoidCallback onBack;
  final VoidCallback onProfileOpen;
  final bool backVisible;

  const NokiaBottomNav({
    super.key,
    required this.onBack,
    required this.onProfileOpen,
    this.backVisible = true,
  });

  void _triggerHaptic() {
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeScreen = ref.watch(nokiaScreenStateProvider);
    final isMuted = ref.watch(nokiaMuteProvider);

    final textStyle = GoogleFonts.vt323(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: const Color(0xFF111E14),
    );

    return Container(
      height: 44,
      decoration: const BoxDecoration(
        color: Color(0xFFEDFEED),
        border: Border(
          top: BorderSide(color: Color(0xFF111E14), width: 2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Back Button
          if (backVisible)
            GestureDetector(
              onTap: () {
                _triggerHaptic();
                onBack();
              },
              child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEDFEED),
                border: Border.all(color: const Color(0xFF111E14), width: 1.5),
                borderRadius: BorderRadius.circular(2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF111E14),
                    offset: Offset(1, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('[<]', style: textStyle),
                  const SizedBox(width: 4),
                  Text('VOLTAR', style: textStyle),
                ],
              ),
            ),
          )
        else
          const Opacity(
            opacity: 0,
            child: IgnorePointer(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('VOLTAR'),
              ),
            ),
          ),

        // Home/Inicio Button
        GestureDetector(
          onTap: () {
            _triggerHaptic();
            ref.read(nokiaScreenStateProvider.notifier).setScreen(NokiaScreen.player);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: activeScreen == NokiaScreen.player
                  ? const Color(0xFF111E14)
                  : const Color(0xFFEDFEED),
              border: Border.all(color: const Color(0xFF111E14), width: 1.5),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                if (activeScreen != NokiaScreen.player)
                  const BoxShadow(
                    color: Color(0xFF111E14),
                    offset: Offset(1, 1),
                  ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('[*]',
                    style: textStyle.copyWith(
                        color: activeScreen == NokiaScreen.player
                            ? const Color(0xFFEDFEED)
                            : const Color(0xFF111E14))),
                const SizedBox(width: 2),
                Text('INICIO',
                    style: textStyle.copyWith(
                        color: activeScreen == NokiaScreen.player
                            ? const Color(0xFFEDFEED)
                            : const Color(0xFF111E14))),
              ],
            ),
          ),
        ),

        // Mute Button
        GestureDetector(
          onTap: () {
            _triggerHaptic();
            ref.read(nokiaMuteProvider.notifier).toggle();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEDFEED),
              border: Border.all(color: const Color(0xFF111E14), width: 1.5),
              borderRadius: BorderRadius.circular(2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF111E14),
                  offset: Offset(1, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isMuted ? '[X]' : '[~]', style: textStyle),
                const SizedBox(width: 2),
                Text(isMuted ? 'MUDO' : 'SOM', style: textStyle),
              ],
            ),
          ),
        ),

        // Dossier Button
        GestureDetector(
          onTap: () {
            _triggerHaptic();
            onProfileOpen();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: activeScreen == NokiaScreen.profile
                  ? const Color(0xFF111E14)
                  : const Color(0xFFEDFEED),
              border: Border.all(color: const Color(0xFF111E14), width: 1.5),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                if (activeScreen != NokiaScreen.profile)
                  const BoxShadow(
                    color: Color(0xFF111E14),
                    offset: Offset(1, 1),
                  ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('[#]',
                    style: textStyle.copyWith(
                        color: activeScreen == NokiaScreen.profile
                            ? const Color(0xFFEDFEED)
                            : const Color(0xFF111E14))),
                const SizedBox(width: 2),
                Text('DOSSIE',
                    style: textStyle.copyWith(
                        color: activeScreen == NokiaScreen.profile
                            ? const Color(0xFFEDFEED)
                            : const Color(0xFF111E14))),
              ],
            ),
          ),
        ),
        ],
      ),
    );
  }
}
