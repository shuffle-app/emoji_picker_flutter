import 'dart:math';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:emoji_picker_flutter/src/emoji_picker_internal_utils.dart';
import 'package:flutter/material.dart';

/// Helper class that provides extended usage
class EmojiPickerUtils {
  /// Singleton Constructor
  factory EmojiPickerUtils() {
    return _singleton;
  }

  EmojiPickerUtils._internal();

  static final EmojiPickerUtils _singleton = EmojiPickerUtils._internal();
  final List<Emoji> _allAvailableEmojiEntities = [];
  RegExp? _emojiRegExp;

  /// Returns list of recently used emoji from cache
  Future<List<RecentEmoji>> getRecentEmojis() async {
    return EmojiPickerInternalUtils().getRecentEmojis();
  }

  /// Search for related emoticons based on keywords
  Future<List<Emoji>> searchEmoji(String keyword, List<CategoryEmoji> data,
      {bool checkPlatformCompatibility = true}) async {
    if (keyword.isEmpty) return [];

    if (_allAvailableEmojiEntities.isEmpty) {
      final emojiPickerInternalUtils = EmojiPickerInternalUtils();

      data.removeWhere((e) => e.category == Category.RECENT);
      final availableCategoryEmoji = checkPlatformCompatibility
          ? await emojiPickerInternalUtils.filterUnsupported(data)
          : data;

      // Set all the emoji entities
      for (var emojis in availableCategoryEmoji) {
        _allAvailableEmojiEntities.addAll(emojis.emoji);
      }
    }

    return _allAvailableEmojiEntities
        .toSet()
        .where(
            (emoji) => emoji.name.toLowerCase().contains(keyword.toLowerCase()))
        .toSet()
        .toList();
  }

  /// Add an emoji to recently used list or increase its counter
  Future<void> addEmojiToRecentlyUsed({
    required GlobalKey<EmojiPickerState> key,
    required Emoji emoji,
    Config config = const Config(),
  }) async {
    return EmojiPickerInternalUtils()
        .addEmojiToRecentlyUsed(emoji: emoji, config: config)
        .then((recentEmojiList) =>
            key.currentState?.updateRecentEmoji(recentEmojiList));
  }

  /// Produce a list of spans to adjust style for emoji characters.
  /// Spans enclosing emojis will have [parentStyle] combined with [emojiStyle].
  /// Other spans will not have an explicit style (this method does not set
  /// [parentStyle] to the whole text.
  List<InlineSpan> setEmojiTextStyle(String text,
      {required TextStyle emojiStyle, TextStyle? parentStyle}) {
    final finalEmojiStyle =
        parentStyle == null ? emojiStyle : parentStyle.merge(emojiStyle);
    final matches = getEmojiRegex().allMatches(text).toList();
    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final match in matches) {
      spans
        ..add(TextSpan(text: text.substring(cursor, match.start)))
        ..add(
          TextSpan(
            text: text.substring(match.start, match.end),
            style: finalEmojiStyle,
          ),
        );
      cursor = match.end;
    }
    spans.add(TextSpan(text: text.substring(cursor, text.length)));
    return spans;
  }

  /// Applies skin tone to given emoji
  Emoji applySkinTone(Emoji emoji, String color) {
    final codeUnits = emoji.emoji.codeUnits;
    var result = List<int>.empty(growable: true)
      ..addAll(codeUnits.sublist(0, min(codeUnits.length, 2)))
      ..addAll(color.codeUnits);
    if (codeUnits.length >= 2) {
      result.addAll(codeUnits.sublist(2));
    }
    return emoji.copyWith(emoji: String.fromCharCodes(result));
  }

  /// Clears the list of recent emojis
  Future<void> clearRecentEmojis(
      {required GlobalKey<EmojiPickerState> key}) async {
    return await EmojiPickerInternalUtils()
        .clearRecentEmojisInLocalStorage()
        .then((_) => key.currentState?.updateRecentEmoji([], refresh: true));
  }

  /// Returns the emoji regex
  RegExp getEmojiRegex() {
    return _emojiRegExp ??= _generateEmojiRegExp();
  }

  RegExp _generateEmojiRegExp() {
    final regExBuffer = StringBuffer();
    for (final list in defaultEmojiSet) {
      for (final emoji in list.emoji) {
        // Put emoji inclusive skin tone before actualy emoji
        // to avoid color and emoji being seperated
        if (emoji.hasSkinTone) {
          for (final skinTone in SkinTone.values) {
            regExBuffer.write(
              '${applySkinTone(emoji, skinTone).emoji}$delimiter',
            );
          }
        }
        regExBuffer.write('${emoji.emoji}$delimiter');
      }
    }
    final regExString = regExBuffer.toString();
    return RegExp(regExString.substring(0, regExString.length - 1));
  }
}
