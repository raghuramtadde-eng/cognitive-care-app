import 'package:flutter/widgets.dart';

/// A single game-tile visual: either a Material icon (tinted by
/// [accentColor]) or an emoji glyph. Emoji render in their own native
/// color regardless of [accentColor] — that field still matters for the
/// surrounding tile chrome (border, matched-state tint) in games that use
/// it, and is simply unused by games that don't (see spot_change_screen.dart).
class GameThemeItem {
  final IconData? icon;
  final String? emoji;
  final Color accentColor;

  const GameThemeItem.icon(this.icon, this.accentColor) : emoji = null;
  const GameThemeItem.emoji(this.emoji, [this.accentColor = const Color(0xFF1F6F78)])
      : icon = null;

  Widget glyph({required double size, Color? color}) {
    if (emoji != null) {
      return Text(emoji!, style: TextStyle(fontSize: size));
    }
    return Icon(icon, size: size, color: color ?? accentColor);
  }
}
