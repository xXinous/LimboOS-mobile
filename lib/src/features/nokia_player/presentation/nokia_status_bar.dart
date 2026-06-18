import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:battery_plus/battery_plus.dart';
import '../nokia_theme.dart';
import '../data/nokia_providers.dart';

class NokiaStatusBar extends ConsumerStatefulWidget {
  const NokiaStatusBar({super.key});

  @override
  ConsumerState<NokiaStatusBar> createState() => _NokiaStatusBarState();
}

class _NokiaStatusBarState extends ConsumerState<NokiaStatusBar> {
  final Battery _battery = Battery();
  int _batteryLevel = 75;
  StreamSubscription<BatteryState>? _batterySubscription;
  late Timer _clockTimer;
  String _timeStr = '12:00';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _getBatteryLevel();
    // 60s é suficiente: o relógio exibe apenas HH:MM
    _clockTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _updateTime();
    });

    _batterySubscription = _battery.onBatteryStateChanged.listen((BatteryState state) {
      _getBatteryLevel();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final newTimeStr = '$hour:$minute';
    // Evita rebuild desnecessário se o minuto não mudou
    if (newTimeStr != _timeStr) {
      setState(() {
        _timeStr = newTimeStr;
      });
    }
  }

  Future<void> _getBatteryLevel() async {
    try {
      final level = await _battery.batteryLevel;
      setState(() {
        _batteryLevel = level;
      });
    } catch (_) {
      // Fallback if battery_plus has issues
    }
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _batterySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final volume = ref.watch(nokiaVolumeProvider);
    final isMuted = ref.watch(nokiaMuteProvider);
    final signalBarsCount = isMuted ? 0 : (volume / 20).ceil();

    final textStyle = GoogleFonts.vt323(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: NokiaTheme.kBlackInk,
      height: 1.0,
    );

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: NokiaTheme.kGreenLcd,
        border: Border(
          bottom: BorderSide(color: NokiaTheme.kBlackInk, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Signal (HP)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('HP', style: textStyle.copyWith(fontSize: 12)),
              const SizedBox(width: 4),
              ...List.generate(5, (index) {
                final level = index + 1;
                final isFilled = signalBarsCount >= level;
                return Container(
                  width: 2,
                  height: (level * 2 + 2).toDouble(),
                  margin: const EdgeInsets.only(left: 1),
                  color: isFilled
                      ? const Color(0xFF111E14)
                      : const Color(0xFF111E14).withValues(alpha: 0.1),
                );
              }),
            ],
          ),

          // Center Clock
          Text(
            _timeStr,
            style: textStyle.copyWith(letterSpacing: 1),
          ),

          // Battery (MP)
          Row(
            children: [
              Text('MP', style: textStyle.copyWith(fontSize: 12)),
              const SizedBox(width: 4),
              // Battery border frame
              Container(
                width: 18,
                height: 10,
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF111E14), width: 1),
                  borderRadius: BorderRadius.circular(1),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _batteryLevel / 100.0,
                  child: Container(
                    color: const Color(0xFF111E14),
                  ),
                ),
              ),
              // Battery tip
              Container(
                width: 1,
                height: 4,
                color: const Color(0xFF111E14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
