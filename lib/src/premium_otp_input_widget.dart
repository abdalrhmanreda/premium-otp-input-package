import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'animated_checkmark.dart';
import 'border_loading_painter.dart';

enum OtpEntryAnimationStyle {
  scale,
  fade,
  slide,
  none,
}

enum OtpSuccessAnimationStyle {
  bounce,
  scale,
  fade,
  none,
}

class PremiumOtpInput extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool isSuccess;
  final bool isError;
  final bool isVerifying;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  // Customization parameters
  final double boxHeight;
  final double spacing;
  final double borderRadius;
  final Color defaultBorderColor;
  final Color activeBorderColor;
  final Color errorColor;
  final Color successColor;
  final Color boxBackgroundColor;
  final Color loadingBorderColor;
  final double loadingBorderStrokeWidth;
  final Color emptyDotColor;
  final double emptyDotSize;
  final TextStyle? textStyle;
  final Color successCheckmarkColor;
  final double successCheckmarkSize;
  final OtpEntryAnimationStyle entryAnimationStyle;
  final OtpSuccessAnimationStyle successAnimationStyle;
  final bool animateActiveBorder;
  final bool obscureText;
  final String obscuringCharacter;

  const PremiumOtpInput({
    super.key,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.isSuccess = false,
    this.isError = false,
    this.isVerifying = false,
    this.controller,
    this.focusNode,
    this.boxHeight = 64.0,
    this.spacing = 12.0,
    this.borderRadius = 16.0,
    this.defaultBorderColor = const Color(
      0x1FFFFFFF,
    ), // Colors.white.withOpacity(0.12)
    this.activeBorderColor = const Color(0xFFF97316),
    this.errorColor = const Color(0xFFEF5350),
    this.successColor = const Color(0xFF22C55E),
    this.boxBackgroundColor = const Color(
      0x801E293B,
    ), // const Color(0xFF1E293B).withOpacity(0.5)
    this.loadingBorderColor = const Color(0xFFF97316),
    this.loadingBorderStrokeWidth = 2.0,
    this.emptyDotColor = const Color(
      0x40FFFFFF,
    ), // Colors.white.withOpacity(0.25)
    this.emptyDotSize = 6.0,
    this.textStyle,
    this.successCheckmarkColor = Colors.white,
    this.successCheckmarkSize = 32.0,
    this.entryAnimationStyle = OtpEntryAnimationStyle.scale,
    this.successAnimationStyle = OtpSuccessAnimationStyle.bounce,
    this.animateActiveBorder = true,
    this.obscureText = false,
    this.obscuringCharacter = '●',
  });

  @override
  State<PremiumOtpInput> createState() => _PremiumOtpInputState();
}

class _PremiumOtpInputState extends State<PremiumOtpInput>
    with TickerProviderStateMixin {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChange);

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.08,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.08,
          end: 0.96,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.96,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30.0,
      ),
    ]).animate(_bounceController);

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    if (widget.isVerifying) {
      _loadingController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant PremiumOtpInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSuccess && !oldWidget.isSuccess) {
      if (widget.successAnimationStyle == OtpSuccessAnimationStyle.bounce) {
        _bounceController.forward(from: 0.0);
      }
    }
    if (widget.isVerifying && !oldWidget.isVerifying) {
      _loadingController.repeat();
    } else if (!widget.isVerifying && oldWidget.isVerifying) {
      _loadingController.stop();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    // Only dispose if created internally
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    if (widget.controller == null) {
      _controller.dispose();
    }
    _bounceController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _onTextChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentText = _controller.text;
    final activeIndex = currentText.length.clamp(0, widget.length - 1);
    final spacing = widget.spacing;
    final boxHeight = widget.boxHeight;

    Widget content = GestureDetector(
      onTap: () {
        if (!widget.isSuccess && !_focusNode.hasFocus) {
          _focusNode.requestFocus();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Hidden TextField to capture input (only active when not successful)
          if (!widget.isSuccess)
            SizedBox(
              width: 0,
              height: 0,
              child: Opacity(
                opacity: 0,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  maxLength: widget.length,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  showCursor: false,
                  enableInteractiveSelection: false,
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  onChanged: (val) {
                    widget.onChanged?.call(val);
                    if (val.length == widget.length) {
                      widget.onCompleted?.call(val);
                    }
                  },
                ),
              ),
            ),

          // 2. AnimatedSwitcher to transition from 6 boxes to a single green-glowing checkmark box
          AnimatedSwitcher(
            duration: widget.successAnimationStyle == OtpSuccessAnimationStyle.none
                ? Duration.zero
                : const Duration(milliseconds: 500),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (Widget child, Animation<double> animation) {
              switch (widget.successAnimationStyle) {
                case OtpSuccessAnimationStyle.bounce:
                case OtpSuccessAnimationStyle.scale:
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                case OtpSuccessAnimationStyle.fade:
                  return FadeTransition(opacity: animation, child: child);
                case OtpSuccessAnimationStyle.none:
                  return child;
              }
            },
            child: widget.isSuccess
                ? Container(
                    key: const ValueKey('success_checkmark_box'),
                    width: widget.boxHeight,
                    height: widget.boxHeight,
                    decoration: BoxDecoration(
                      color: widget.boxBackgroundColor,
                      borderRadius: BorderRadius.circular(
                        widget.borderRadius,
                      ),
                      border: Border.all(
                        color: widget.successColor,
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.successColor.withValues(alpha: 0.3),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: AnimatedCheckmark(
                      size: widget.successCheckmarkSize,
                      strokeWidth: widget.successCheckmarkSize * 0.11,
                      color: widget.successCheckmarkColor,
                      duration: widget.successAnimationStyle == OtpSuccessAnimationStyle.none
                          ? Duration.zero
                          : const Duration(milliseconds: 600),
                    ),
                  )
                : LayoutBuilder(
                    key: const ValueKey('otp_input_grid'),
                    builder: (context, constraints) {
                      final totalWidth = constraints.maxWidth;
                      final boxWidth =
                          (totalWidth - (widget.length - 1) * spacing) /
                          widget.length;

                      // Border colors & glows
                      final accentColor = widget.isError
                          ? widget.errorColor
                          : widget.activeBorderColor;

                      final activeBorderGlow =
                          (widget.isError
                                  ? widget.errorColor
                                  : widget.activeBorderColor)
                              .withValues(alpha: 0.35);

                      return SizedBox(
                        height:
                            boxHeight + 10, // Extra height for scaling room
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Bottom Layer: Static Box Containers
                            AnimatedBuilder(
                              animation: _loadingController,
                              builder: (context, child) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: List.generate(widget.length, (
                                    index,
                                  ) {
                                    final char = index < currentText.length
                                        ? currentText[index]
                                        : '';
                                    final isBoxActive =
                                        _isFocused && (index == activeIndex);

                                    // Determine border color for individual static boxes
                                    Color boxBorderColor =
                                        widget.defaultBorderColor;
                                    if (widget.isError) {
                                      boxBorderColor = widget.errorColor;
                                    }

                                    return SizedBox(
                                      width: boxWidth,
                                      child: AnimatedScale(
                                        scale: (widget.animateActiveBorder && isBoxActive) ? 1.06 : 1.0,
                                        duration: widget.animateActiveBorder
                                            ? const Duration(
                                                milliseconds: 200,
                                              )
                                            : Duration.zero,
                                        curve: Curves.easeOutCubic,
                                        child: CustomPaint(
                                          foregroundPainter:
                                              widget.isVerifying
                                              ? BorderLoadingPainter(
                                                  rotationValue:
                                                      _loadingController
                                                          .value,
                                                  color: widget
                                                      .loadingBorderColor,
                                                  strokeWidth: widget
                                                      .loadingBorderStrokeWidth,
                                                  borderRadius:
                                                      widget.borderRadius,
                                                )
                                              : null,
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 250,
                                            ),
                                            height: boxHeight,
                                            decoration: BoxDecoration(
                                              color:
                                                  widget.boxBackgroundColor,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    widget.borderRadius,
                                                  ),
                                              border: Border.all(
                                                color: boxBorderColor,
                                                width: widget.isError
                                                    ? 1.5
                                                    : 1.0,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: AnimatedSwitcher(
                                              duration: widget.entryAnimationStyle == OtpEntryAnimationStyle.none
                                                  ? Duration.zero
                                                  : const Duration(
                                                      milliseconds: 200,
                                                    ),
                                              switchInCurve:
                                                  Curves.easeOutBack,
                                              switchOutCurve: Curves.easeIn,
                                              transitionBuilder:
                                                  (
                                                    Widget child,
                                                    Animation<double>
                                                    animation,
                                                  ) {
                                                    switch (widget.entryAnimationStyle) {
                                                      case OtpEntryAnimationStyle.scale:
                                                        return ScaleTransition(
                                                          scale: Tween<double>(
                                                            begin: 0.6,
                                                            end: 1.0,
                                                          ).animate(animation),
                                                          child: FadeTransition(
                                                            opacity: animation,
                                                            child: child,
                                                          ),
                                                        );
                                                      case OtpEntryAnimationStyle.fade:
                                                        return FadeTransition(
                                                          opacity: animation,
                                                          child: child,
                                                        );
                                                      case OtpEntryAnimationStyle.slide:
                                                        return SlideTransition(
                                                          position: Tween<Offset>(
                                                            begin: const Offset(0.0, 0.35),
                                                            end: Offset.zero,
                                                          ).animate(animation),
                                                          child: FadeTransition(
                                                            opacity: animation,
                                                            child: child,
                                                          ),
                                                        );
                                                      case OtpEntryAnimationStyle.none:
                                                        return child;
                                                    }
                                                  },
                                              child: char.isNotEmpty
                                                  ? Text(
                                                      widget.obscureText
                                                          ? widget.obscuringCharacter
                                                          : char,
                                                      key: ValueKey<String>(
                                                        '${index}_$char',
                                                      ),
                                                      style:
                                                          widget.textStyle ??
                                                          GoogleFonts.outfit(
                                                            fontSize:
                                                                widget
                                                                    .boxHeight *
                                                                0.375,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                            color:
                                                                Colors.white,
                                                          ),
                                                    )
                                                  : Container(
                                                      key: ValueKey<String>(
                                                        '${index}_empty',
                                                      ),
                                                      width:
                                                          widget.emptyDotSize,
                                                      height:
                                                          widget.emptyDotSize,
                                                      decoration:
                                                          BoxDecoration(
                                                            color: widget
                                                                .emptyDotColor,
                                                            shape: BoxShape
                                                                .circle,
                                                          ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                );
                              },
                            ),

                            // Top Layer: Sliding Active Border Highlight
                            if (_isFocused && !widget.isError)
                              AnimatedPositioned(
                                duration: widget.animateActiveBorder
                                    ? const Duration(milliseconds: 250)
                                    : Duration.zero,
                                curve: Curves.easeOutCubic,
                                left: activeIndex * (boxWidth + spacing),
                                width: boxWidth,
                                height: boxHeight,
                                child: IgnorePointer(
                                  child: AnimatedScale(
                                    scale: 1.06,
                                    duration: widget.animateActiveBorder
                                        ? const Duration(
                                            milliseconds: 200,
                                          )
                                        : Duration.zero,
                                    curve: Curves.easeOutCubic,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          widget.borderRadius,
                                        ),
                                        border: Border.all(
                                          color: accentColor,
                                          width: 2.0,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: activeBorderGlow,
                                            blurRadius: 12,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );

    if (widget.successAnimationStyle == OtpSuccessAnimationStyle.bounce) {
      return ScaleTransition(
        scale: _bounceAnimation,
        child: content,
      );
    }
    return content;
  }
}
