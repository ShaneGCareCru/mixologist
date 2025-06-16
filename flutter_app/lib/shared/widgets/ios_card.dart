import 'package:flutter/cupertino.dart';
import '../../theme/ios_theme.dart';

/// iOS-style card widget that replaces Material's Card and GlassmorphicCard
class iOSCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? borderRadius;

  const iOSCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding ?? iOSTheme.cardPadding,
      decoration: BoxDecoration(
        color: backgroundColor ?? iOSTheme.adaptiveColor(
          context, 
          CupertinoColors.systemBackground, 
          iOSTheme.darkSecondaryBackground
        ),
        borderRadius: BorderRadius.circular(borderRadius ?? iOSTheme.largeRadius),
        boxShadow: iOSTheme.cardShadow,
      ),
      child: child,
    );
  }
}

/// iOS-style button that replaces ElevatedButton
class iOSButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final double? minHeight;

  const iOSButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
    this.minHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: minHeight ?? iOSTheme.minimumTouchTarget,
      width: double.infinity,
      child: CupertinoButton.filled(
        onPressed: onPressed,
        borderRadius: BorderRadius.circular(borderRadius ?? iOSTheme.mediumRadius),
        padding: padding ?? iOSTheme.buttonPadding,
        color: backgroundColor ?? iOSTheme.whiskey,
        child: child,
      ),
    );
  }
}

/// iOS-style text field that replaces TextField
class iOSTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final String? prefix;
  final int? maxLines;
  final String? errorText;
  final Widget? prefixIcon;

  const iOSTextField({
    super.key,
    this.controller,
    this.placeholder,
    this.prefix,
    this.maxLines = 1,
    this.errorText,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (prefix != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              prefix!,
              style: iOSTheme.subhead.copyWith(
                color: iOSTheme.adaptiveColor(context, CupertinoColors.label, CupertinoColors.label),
              ),
            ),
          ),
        ],
        Row(
          children: [
            if (prefixIcon != null) ...[
              prefixIcon!,
              const SizedBox(width: 8),
            ],
            Expanded(
              child: CupertinoTextField(
                controller: controller,
                placeholder: placeholder,
                maxLines: maxLines,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: iOSTheme.adaptiveColor(
                    context, 
                    CupertinoColors.tertiarySystemFill, 
                    iOSTheme.darkTertiaryBackground
                  ),
                  borderRadius: BorderRadius.circular(iOSTheme.smallRadius),
                  border: errorText != null ? Border.all(
                    color: CupertinoColors.destructiveRed,
                    width: 1,
                  ) : null,
                ),
                style: iOSTheme.body.copyWith(
                  color: iOSTheme.adaptiveColor(context, CupertinoColors.label, CupertinoColors.label),
                ),
                placeholderStyle: iOSTheme.body.copyWith(
                  color: iOSTheme.adaptiveColor(context, CupertinoColors.placeholderText, CupertinoColors.placeholderText),
                ),
              ),
            ),
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: iOSTheme.caption1.copyWith(
              color: CupertinoColors.destructiveRed,
            ),
          ),
        ],
      ],
    );
  }
}