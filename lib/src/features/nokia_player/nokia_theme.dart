import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema centralizado para a interface Nokia LCD do Limbo OS.
///
/// Todas as cores e estilos do player Nokia devem referenciar estas
/// constantes em vez de usar literais espalhados pelo código.
class NokiaTheme {
  NokiaTheme._(); // não instanciável

  // ─── Paleta Principal ───────────────────────────────────────────────────────

  /// Verde LCD da tela Nokia (fundo e texto em destaque)
  static const Color kGreenLcd = Color(0xFFEDFEED);

  /// Alias para kGreenLcd (compatibilidade)
  static const Color kLcdGreen = kGreenLcd;

  /// Preto/Verde escuro da tinta Nokia (bordas, texto principal, fill de botão)
  static const Color kBlackInk = Color(0xFF111E14);

  // ─── Derivados comuns ───────────────────────────────────────────────────────

  /// kBlackInk com alpha reduzido — usado em bordas suaves e separadores
  static Color kBlackInkSubtle = kBlackInk.withValues(alpha: 0.15);

  /// kBlackInk com alpha baixo — sombra leve
  static Color kBlackInkShadow = kBlackInk.withValues(alpha: 0.1);

  // ─── BoxDecorations reutilizáveis ───────────────────────────────────────────

  /// Borda padrão Nokia: 2px preta + sombra offset de 1px
  static BoxDecoration cardDecoration({bool filled = false}) => BoxDecoration(
    color: filled ? kBlackInk : kGreenLcd,
    border: Border.all(color: kBlackInk, width: 2),
    boxShadow: const [
      BoxShadow(color: Color(0xFF111E14), offset: Offset(1, 1)),
    ],
  );

  /// Borda de 2px sem sombra
  static BoxDecoration borderDecoration({double width = 2}) => BoxDecoration(
    color: kGreenLcd,
    border: Border.all(color: kBlackInk, width: width),
  );

  // ─── TextStyles base ────────────────────────────────────────────────────────

  /// Estilo VT323 padrão para toda a interface Nokia
  static TextStyle textStyle({
    double fontSize = 14,
    Color color = const Color(0xFF111E14),
    FontWeight fontWeight = FontWeight.bold,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.vt323(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
      );
}
