import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../theme/ios_theme.dart';

class SectionPreview extends StatefulWidget {
  final String title;
  final IconData icon;
  final Widget previewContent;
  final Widget expandedContent;
  final int totalItems;
  final int? completedItems;
  final bool expanded;
  final VoidCallback onOpen;
  final VoidCallback onClose;

  const SectionPreview({
    super.key,
    required this.title,
    required this.icon,
    required this.previewContent,
    required this.expandedContent,
    required this.totalItems,
    this.completedItems,
    required this.expanded,
    required this.onOpen,
    required this.onClose,
  });

  @override
  State<SectionPreview> createState() => _SectionPreviewState();
}

class _SectionPreviewState extends State<SectionPreview>
    with SingleTickerProviderStateMixin {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final progress = widget.completedItems != null
        ? '${widget.completedItems}/${widget.totalItems}'
        : '${widget.totalItems}';

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedSize(
        duration: MediaQuery.of(context).disableAnimations
            ? Duration.zero
            : const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: Theme.of(context).brightness == Brightness.dark
                  ? [
                      Colors.white.withOpacity( 0.1),
                      Colors.white.withOpacity( 0.05),
                    ]
                  : [
                      Colors.white.withOpacity( 0.25),
                      Colors.white.withOpacity( 0.1),
                    ],
            ),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity( 0.2)
                  : Colors.white.withOpacity( 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withOpacity( 0.5)
                    : Colors.grey.withOpacity( 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity( 0.2)
                  : Colors.white.withOpacity( 0.1),
              child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: widget.expanded ? widget.onClose : widget.onOpen,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        children: [
                          Icon(widget.icon,
                              color: iOSTheme.whiskey),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(widget.title,
                                style: iOSTheme.title2),
                          ),
                          Text(progress,
                              style: iOSTheme.caption1),
                        ],
                      ),
                    ),
                  ),
                  AnimatedCrossFade(
                    duration: MediaQuery.of(context).disableAnimations
                        ? Duration.zero
                        : const Duration(milliseconds: 300),
                    firstChild: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: widget.previewContent,
                    ),
                    secondChild: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: widget.expandedContent,
                    ),
                    crossFadeState: widget.expanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                  ),
                ],
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _hovering && !widget.expanded ? 1.0 : 0.0,
                child: Container(
                  color: Colors.black54,
                  alignment: Alignment.center,
                  child: Text(
                    'View All',
                    style: iOSTheme.headline.copyWith(color: Colors.white),
                  ),
                ),
              ),
              if (widget.expanded)
                Positioned(
                  top: 4,
                  right: 4,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: widget.onClose,
                    child: Icon(
                      CupertinoIcons.xmark,
                      color: iOSTheme.whiskey,
                    ),
                  ),
                ),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }
}