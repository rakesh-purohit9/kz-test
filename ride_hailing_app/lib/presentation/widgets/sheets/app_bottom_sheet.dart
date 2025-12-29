import 'package:flutter/material.dart';
import '../../../core/constants/constants.dart';

/// Uber-style swipeable bottom sheet
class AppBottomSheet extends StatelessWidget {
  final Widget child;
  final double? initialHeight;
  final double? maxHeight;
  final bool showHandle;
  final bool isDismissible;
  final VoidCallback? onClose;
  final EdgeInsets? padding;

  const AppBottomSheet({
    super.key,
    required this.child,
    this.initialHeight,
    this.maxHeight,
    this.showHandle = true,
    this.isDismissible = true,
    this.onClose,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.bottomSheetTopRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.overlayLight,
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHandle) ...[
            const SizedBox(height: AppSpacing.sm),
            const _DragHandle(),
            const SizedBox(height: AppSpacing.sm),
          ],
          Flexible(
            child: Padding(
              padding: padding ?? AppSpacing.bottomSheetPadding,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  /// Show as modal bottom sheet
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = true,
    double? initialHeight,
    double? maxHeight,
    bool showHandle = true,
    EdgeInsets? padding,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (context) => AppBottomSheet(
        initialHeight: initialHeight,
        maxHeight: maxHeight,
        showHandle: showHandle,
        isDismissible: isDismissible,
        padding: padding,
        child: child,
      ),
    );
  }
}

/// Drag handle for bottom sheets
class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.bottomSheetHandleWidth,
      height: AppSpacing.bottomSheetHandleHeight,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
      ),
    );
  }
}

/// Draggable bottom sheet with snap points
class DraggableSheet extends StatefulWidget {
  final Widget child;
  final double minChildSize;
  final double maxChildSize;
  final double initialChildSize;
  final bool snap;
  final List<double>? snapSizes;
  final DraggableScrollableController? controller;

  const DraggableSheet({
    super.key,
    required this.child,
    this.minChildSize = 0.25,
    this.maxChildSize = 0.85,
    this.initialChildSize = 0.4,
    this.snap = true,
    this.snapSizes,
    this.controller,
  });

  @override
  State<DraggableSheet> createState() => _DraggableSheetState();
}

class _DraggableSheetState extends State<DraggableSheet> {
  late DraggableScrollableController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? DraggableScrollableController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _controller,
      minChildSize: widget.minChildSize,
      maxChildSize: widget.maxChildSize,
      initialChildSize: widget.initialChildSize,
      snap: widget.snap,
      snapSizes: widget.snapSizes,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.bottomSheetTopRadius),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.overlayLight,
                blurRadius: 10,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.sm),
              const _DragHandle(),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: widget.child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Sheet header with title and close button
class SheetHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onClose;
  final Widget? trailing;

  const SheetHeader({
    super.key,
    required this.title,
    this.onClose,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          if (onClose != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClose,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )
          else
            const SizedBox(width: 24),
          Expanded(
            child: Text(
              title,
              style: AppTypography.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
          if (trailing != null)
            trailing!
          else
            const SizedBox(width: 24),
        ],
      ),
    );
  }
}
