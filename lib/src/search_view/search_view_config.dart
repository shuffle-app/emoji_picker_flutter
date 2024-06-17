import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

/// Callback function for custom search view
typedef SearchViewBuilder = Widget Function(
  Config config,
  EmojiViewState state,
  VoidCallback showEmojiView,
);

/// Search view Config
class SearchViewConfig {
  /// Constructor
  const SearchViewConfig({
    this.backgroundColor = const Color(0xFFEBEFF2),
    this.buttonColor = Colors.transparent,
    this.buttonIconColor = Colors.black26,
    this.hintTextColor = Colors.black26,
    this.hintText = 'Search',
    this.textStyle = const TextStyle(color: Colors.black26),
    this.customSearchView,
  });

  /// Text style of search bar
  final TextStyle textStyle;

  /// Hint text color of search bar
  final Color hintTextColor;

  /// Background color of search bar
  final Color backgroundColor;

  /// Fill color of hide search view button
  final Color buttonColor;

  /// Icon color of hide search view button
  final Color buttonIconColor;

  /// Custom hint text
  final String? hintText;

  /// Custom search bar
  /// Hot reload is not supported
  final SearchViewBuilder? customSearchView;

  @override
  bool operator ==(other) {
    return (other is SearchViewConfig) &&
        other.backgroundColor == backgroundColor &&
        other.buttonColor == buttonColor &&
        other.buttonIconColor == buttonIconColor &&
        other.hintText == hintText &&
        other.hintTextColor == hintTextColor;
  }

  @override
  int get hashCode =>
      backgroundColor.hashCode ^
      buttonColor.hashCode ^
      buttonIconColor.hashCode ^
      hintText.hashCode ^
      hintTextColor.hashCode;
}
