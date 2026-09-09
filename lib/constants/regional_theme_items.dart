import 'package:flutter/widgets.dart';

import '../models/game_theme_item.dart';
import '../models/patient.dart';

/// Culturally-familiar content for progressive game difficulty, one
/// distinct set per [CulturalTheme] -- deliberately independent of the
/// patient's UI [Patient.language] (see patient.dart's doc comment and
/// patient_setup_screen.dart, where a caregiver picks this separately).
/// Layered on top of (never replacing) each game's original generic pool
/// at higher difficulty levels — see each game screen's own level-gated
/// pool helper.
///
/// Deliberately small and conservative rather than exhaustive: every item
/// is chosen only from facts confident enough to state plainly, not
/// guessed or stereotyped.
///  - Tea: Assam is one of the world's best-known tea-growing regions.
///  - Bamboo / rice / fish / hills: genuinely everyday materials, staple
///    crop and diet, and defining geography across the wider NER, not
///    attributed to one specific state.
///  - Gamusa: a specific, well-documented Assamese hand-woven cloth,
///    traditionally offered as a mark of respect and hospitality.
///  - Sangai: Manipur's state animal (a brow-antlered deer found only in
///    the Keibul Lamjao floating sanctuary), a widely-documented, safe,
///    non-stereotyping symbol.
///  - Loktak Lake / its floating phumdis (vegetation islands): Manipur's
///    single best-known and most-documented geographic feature.
///
/// The Manipur set is intentionally the smallest and most conservative of
/// the three — broader imagery (a named textile, dance form, or festival)
/// is a good candidate for a future pass with native-speaker/community
/// review, not guessed here (see project memory for the standing caveat
/// this shares with the Manipuri UI translations).
class RegionalThemeSet {
  /// Added to (never replacing) Memory Match's and Spot the Change's
  /// generic pool at level 3+.
  final List<GameThemeItem> matchAndSpotItems;

  /// Fully re-skins Sequence Recall's tile set at level 4+ (its board
  /// already uses all 8 tiles at max level, so this replaces rather than
  /// adds — see sequence_recall_screen.dart).
  final List<GameThemeItem> sequenceItems;

  const RegionalThemeSet({required this.matchAndSpotItems, required this.sequenceItems});
}

const _generalNer = RegionalThemeSet(
  matchAndSpotItems: [
    GameThemeItem.emoji('🏔️'), // hills
    GameThemeItem.emoji('🎋'), // bamboo
    GameThemeItem.emoji('🌾'), // rice / paddy
    GameThemeItem.emoji('🐟'), // fish
  ],
  sequenceItems: [
    GameThemeItem.emoji('🪴', Color(0xFF2E7D4F)), // gardening
    GameThemeItem.emoji('🧺', Color(0xFF8D6E63)), // basket
    GameThemeItem.emoji('🧹', Color(0xFF6A4C93)), // household chore
    GameThemeItem.emoji('🌾', Color(0xFFE07A3E)), // rice / paddy
    GameThemeItem.emoji('🎋', Color(0xFF1F6F78)), // bamboo
    GameThemeItem.emoji('🌿', Color(0xFF3E8914)), // greenery
    GameThemeItem.emoji('🏔️', Color(0xFF5B7C99)), // hills
    GameThemeItem.emoji('🐟', Color(0xFF2D5F6B)), // fish
  ],
);

const _assam = RegionalThemeSet(
  matchAndSpotItems: [
    GameThemeItem.emoji('🍵'), // tea
    GameThemeItem.emoji('🎋'), // bamboo
    GameThemeItem.emoji('🌾'), // rice / paddy
    GameThemeItem.emoji('🧣'), // gamusa (woven cloth, offered as a mark of respect)
    GameThemeItem.emoji('🐟'), // fish
    GameThemeItem.emoji('🏔️'), // hills
  ],
  sequenceItems: [
    GameThemeItem.emoji('🫖', Color(0xFF2D5F6B)), // kettle
    GameThemeItem.emoji('🍵', Color(0xFFC9A227)), // teacup
    GameThemeItem.emoji('🌿', Color(0xFF3E8914)), // tea leaves
    GameThemeItem.emoji('🪴', Color(0xFF2E7D4F)), // gardening
    GameThemeItem.emoji('🧺', Color(0xFF8D6E63)), // household basket
    GameThemeItem.emoji('🧹', Color(0xFF6A4C93)), // household chore
    GameThemeItem.emoji('🌾', Color(0xFFE07A3E)), // rice / paddy
    GameThemeItem.emoji('🎋', Color(0xFF1F6F78)), // bamboo
  ],
);

const _manipur = RegionalThemeSet(
  matchAndSpotItems: [
    GameThemeItem.emoji('🦌'), // Sangai, Manipur's state animal
    GameThemeItem.emoji('🌊'), // Loktak Lake
    GameThemeItem.emoji('🪷'), // floating phumdi vegetation
    GameThemeItem.emoji('🌾'), // rice / paddy
    GameThemeItem.emoji('🐟'), // fish
  ],
  sequenceItems: [
    GameThemeItem.emoji('🛶', Color(0xFF2D5F6B)), // boat on Loktak Lake
    GameThemeItem.emoji('🌊', Color(0xFF1F6F78)), // lake water
    GameThemeItem.emoji('🪷', Color(0xFFD46A9F)), // floating phumdi vegetation
    GameThemeItem.emoji('🦌', Color(0xFF8D6E63)), // Sangai
    GameThemeItem.emoji('🐟', Color(0xFF2E7D4F)), // fish
    GameThemeItem.emoji('🌾', Color(0xFFE07A3E)), // rice / paddy
    GameThemeItem.emoji('🧺', Color(0xFF6A4C93)), // basket
    GameThemeItem.emoji('🧹', Color(0xFFC9A227)), // household chore
  ],
);

const regionalThemeSets = <CulturalTheme, RegionalThemeSet>{
  CulturalTheme.generalNer: _generalNer,
  CulturalTheme.assam: _assam,
  CulturalTheme.manipur: _manipur,
};
