import 'package:flutter/cupertino.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../theme/ios_theme.dart';

/// iOS-style search bar that replaces Material's SearchAnchor
class iOSSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String placeholder;
  final List<String>? animatedPlaceholders; // Optional animated placeholders
  final List<String> suggestions;
  final Function(String)? onSubmitted;
  final Function(String)? onSuggestionTapped;

  const iOSSearchBar({
    super.key,
    required this.controller,
    required this.placeholder,
    this.animatedPlaceholders,
    this.suggestions = const [],
    this.onSubmitted,
    this.onSuggestionTapped,
  });

  @override
  State<iOSSearchBar> createState() => _iOSSearchBarState();
}

class _iOSSearchBarState extends State<iOSSearchBar> {
  bool _showSuggestions = false;
  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final query = widget.controller.text.toLowerCase();
    setState(() {
      _filteredSuggestions = widget.suggestions
          .where((suggestion) => suggestion.toLowerCase().contains(query))
          .toList();
      _showSuggestions = query.isNotEmpty && _filteredSuggestions.isNotEmpty;
    });
  }

  void _onSuggestionTap(String suggestion) {
    widget.controller.text = suggestion;
    setState(() {
      _showSuggestions = false;
    });
    widget.onSuggestionTapped?.call(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: iOSTheme.adaptiveColor(
              context, 
              CupertinoColors.tertiarySystemFill, 
              iOSTheme.darkTertiaryBackground
            ),
            borderRadius: BorderRadius.circular(iOSTheme.smallRadius),
          ),
          child: Stack(
            children: [
              CupertinoTextField(
                controller: widget.controller,
                placeholder: widget.animatedPlaceholders == null ? widget.placeholder : null,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(),
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    CupertinoIcons.search,
                    color: CupertinoColors.placeholderText,
                    size: 18,
                  ),
                ),
            suffix: widget.controller.text.isNotEmpty
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Icon(
                      CupertinoIcons.clear_circled_solid,
                      color: CupertinoColors.placeholderText,
                      size: 18,
                    ),
                    onPressed: () {
                      widget.controller.clear();
                      setState(() {
                        _showSuggestions = false;
                      });
                    }, minimumSize: Size(20, 20),
                  )
                : null,
            style: iOSTheme.body.copyWith(
              color: iOSTheme.adaptiveColor(context, CupertinoColors.label, CupertinoColors.label),
            ),
            placeholderStyle: iOSTheme.body.copyWith(
              color: CupertinoColors.placeholderText,
            ),
            onSubmitted: (value) {
              setState(() {
                _showSuggestions = false;
              });
              widget.onSubmitted?.call(value);
            },
            onTap: () {
              if (widget.controller.text.isNotEmpty && _filteredSuggestions.isNotEmpty) {
                setState(() {
                  _showSuggestions = true;
                });
              }
            },
          ),
          if (widget.animatedPlaceholders != null && widget.controller.text.isEmpty)
            Positioned(
              left: 34,
              top: 0,
              bottom: 0,
              right: 40,
              child: IgnorePointer(
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AnimatedTextKit(
                    animatedTexts: widget.animatedPlaceholders!
                        .map((text) => TyperAnimatedText(
                              text,
                              textStyle: iOSTheme.body.copyWith(
                                color: CupertinoColors.placeholderText,
                              ),
                              speed: const Duration(milliseconds: 50),
                            ))
                        .toList(),
                    repeatForever: true,
                    pause: const Duration(milliseconds: 1000),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_showSuggestions) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: iOSTheme.adaptiveColor(
                context, 
                CupertinoColors.systemBackground, 
                iOSTheme.darkSecondaryBackground
              ),
              borderRadius: BorderRadius.circular(iOSTheme.smallRadius),
              boxShadow: iOSTheme.cardShadow,
            ),
            child: Column(
              children: _filteredSuggestions.map((suggestion) {
                return CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  onPressed: () => _onSuggestionTap(suggestion),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.clock,
                        size: 16,
                        color: CupertinoColors.placeholderText,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          suggestion,
                          style: iOSTheme.body.copyWith(
                            color: iOSTheme.adaptiveColor(context, CupertinoColors.label, CupertinoColors.label),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}

/// iOS-style chip widget for quick search options
class iOSChip extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isSelected;

  const iOSChip({
    super.key,
    required this.label,
    this.onPressed,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isSelected 
          ? iOSTheme.whiskey 
          : iOSTheme.adaptiveColor(
              context, 
              CupertinoColors.tertiarySystemFill, 
              iOSTheme.darkTertiaryBackground
            ),
      borderRadius: BorderRadius.circular(20),
      onPressed: onPressed,
      child: Text(
        label,
        style: iOSTheme.subhead.copyWith(
          color: isSelected 
              ? CupertinoColors.white 
              : iOSTheme.adaptiveColor(context, CupertinoColors.label, CupertinoColors.label),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}