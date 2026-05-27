import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/nokia_providers.dart';
import '../data/intel_repository.dart';
import '../../auth/data/auth_repository.dart';
import '../../characters/data/character_providers.dart';
import '../../campaigns/data/active_campaign_provider.dart';

class NokiaScannerView extends ConsumerStatefulWidget {
  const NokiaScannerView({super.key});

  @override
  ConsumerState<NokiaScannerView> createState() => _NokiaScannerViewState();
}

class _NokiaScannerViewState extends ConsumerState<NokiaScannerView> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _isProcessing = false;
  String? _statusMessage;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleCode(String code) async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
      _statusMessage = 'RESOLVENDO...';
    });

    HapticFeedback.mediumImpact();

    try {
      final auth = ref.read(authStateChangesProvider).value;
      final character = ref.read(activeCharacterProvider);
      final campaign = ref.read(activeCampaignProvider).value;
      final repo = ref.read(intelRepositoryProvider);

      if (auth == null || character == null) {
        _showStatus('ERRO: AGENTE EXPIRADO');
        return;
      }

      // Step 1: Check redirects
      final redirectedId = await repo.resolveQrCode(code);
      final finalCode = redirectedId ?? code;

      // Step 2: Query Firestore check if it's a valid mediaAsset
      await repo.resolveQrCode(finalCode); // checking exists in redirects, or we can just try to unlock it directly
      
      // Unlock the item in the user dossier
      await repo.unlockIntel(
        uid: auth.uid,
        characterId: character.id,
        intelId: finalCode,
        campaignId: campaign?.id,
      );

      HapticFeedback.heavyImpact();
      _showStatus('INTEL DESBLOQUEADO!');
      
      // Delay and navigate back
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        ref.read(nokiaScreenStateProvider.notifier).setScreen(NokiaScreen.player);
      }
    } catch (e) {
      _showStatus('CODIGO DESCONHECIDO');
    }
  }

  void _showStatus(String msg) {
    setState(() {
      _statusMessage = msg;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusMessage = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.vt323(
      fontSize: 14,
      color: const Color(0xFFEDFEED),
      fontWeight: FontWeight.bold,
    );

    return Container(
      color: Colors.black,
      child: Column(
        children: [
          // Top scanner info bar
          Container(
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: const Color(0xFF111E14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SCANNER ATIVO',
                  style: textStyle.copyWith(color: const Color(0xFFEDFEED)),
                ),
                if (_isProcessing)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),

          // Camera Viewport
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                MobileScanner(
                  controller: _scannerController,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      final String? rawValue = barcode.rawValue;
                      if (rawValue != null && !_isProcessing) {
                        _handleCode(rawValue);
                      }
                    }
                  },
                  errorBuilder: (context, error, child) {
                    return Center(
                      child: Text(
                        'FALHA NA CAMERA\nPERMISSAO NEGADA',
                        style: textStyle.copyWith(color: Colors.white, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),

                // Targeting Reticle Overlay
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFEDFEED).withValues(alpha: 0.5),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDFEED).withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                // Toast/Processing overlay
                if (_statusMessage != null)
                  Container(
                    color: Colors.black.withValues(alpha: 0.8),
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        _statusMessage!,
                        style: textStyle.copyWith(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Bottom Cancel bar
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(nokiaScreenStateProvider.notifier).setScreen(NokiaScreen.player);
            },
            child: Container(
              height: 36,
              color: const Color(0xFFEDFEED),
              alignment: Alignment.center,
              child: Text(
                '[ CANCELAR ]',
                style: textStyle.copyWith(color: const Color(0xFF111E14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
