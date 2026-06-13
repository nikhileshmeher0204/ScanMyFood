import 'dart:ui';
import 'package:flutter/material.dart';

class RollingText extends StatefulWidget {
  const RollingText({
    super.key,
    required this.text,
    this.style,
    this.duration = const Duration(milliseconds: 350),
    this.staggerDelay = const Duration(milliseconds: 50),
    this.curve = Curves.easeOutBack,
  });

  final String text;
  final TextStyle? style;
  final Duration duration;
  final Duration staggerDelay;
  final Curve curve;

  @override
  State<RollingText> createState() => _RollingTextState();
}

class _RollingTextState extends State<RollingText> {
  late List<String> _currentChars;

  @override
  void initState() {
    super.initState();
    _currentChars = widget.text.split('');
  }

  @override
  void didUpdateWidget(covariant RollingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) {
      _currentChars = oldWidget.text.split('');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _currentChars = widget.text.split('');
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Inject tabular figures to prevent horizontal jitter
    final effectiveStyle = (widget.style ?? const TextStyle()).copyWith(
      fontFeatures: [
        ...(widget.style?.fontFeatures ?? []),
        const FontFeature.tabularFigures(),
      ],
    );

    final oldText = _currentChars.join();
    final newChars = widget.text.split('');
    final oldChars = oldText.split('');

    // Use a fixed max digits to keep widgets in the tree, allowing width animation
    const maxDigits = 10;

    // Pad lists from the left to align right-to-left
    final paddedOld = List<String?>.filled(maxDigits, null);
    final paddedNew = List<String?>.filled(maxDigits, null);

    for (int i = 0; i < oldChars.length; i++) {
      if (oldChars.length - i <= maxDigits) {
        paddedOld[maxDigits - oldChars.length + i] = oldChars[i];
      }
    }
    for (int i = 0; i < newChars.length; i++) {
      if (newChars.length - i <= maxDigits) {
        paddedNew[maxDigits - newChars.length + i] = newChars[i];
      }
    }

    return AnimatedSize(
      duration: widget.duration,
      curve: Curves.easeOut,
      alignment: Alignment.centerRight,
      clipBehavior: Clip.none,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          for (int i = 0; i < maxDigits; i++)
            RollingDigit(
              key: ValueKey('rolling_digit_${maxDigits - 1 - i}'),
              character: paddedNew[i],
              oldCharacter: paddedOld[i],
              delayMs: (maxDigits - 1 - i) * widget.staggerDelay.inMilliseconds,
              duration: widget.duration,
              curve: widget.curve,
              style: effectiveStyle,
            ),
        ],
      ),
    );
  }
}

class RollingDigit extends StatefulWidget {
  const RollingDigit({
    super.key,
    required this.character,
    required this.oldCharacter,
    required this.delayMs,
    required this.duration,
    required this.curve,
    required this.style,
  });

  final String? character;
  final String? oldCharacter;
  final int delayMs;
  final Duration duration;
  final Curve curve;
  final TextStyle style;

  @override
  State<RollingDigit> createState() => _RollingDigitState();
}

class _RollingDigitState extends State<RollingDigit> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideInAnimation;
  late Animation<double> _slideOutAnimation;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _fadeOutAnimation;
  late Animation<double> _scaleInAnimation;
  late Animation<double> _scaleOutAnimation;
  late Animation<double> _blurInAnimation;
  late Animation<double> _blurOutAnimation;

  String? _displayCharacter;
  String? _previousCharacter;
  bool _animating = false;
  bool _slideUp = true;

  bool _isDigit(String? char) {
    if (char == null) return false;
    return RegExp(r'^[0-9]$').hasMatch(char);
  }

  @override
  void initState() {
    super.initState();
    _displayCharacter = widget.character;
    _previousCharacter = widget.oldCharacter;

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _initAnimations();
  }

  void _initAnimations() {
    _slideOutAnimation = Tween<double>(begin: 0.0, end: _slideUp ? -1.0 : 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeIn),
      ),
    );

    _slideInAnimation = Tween<double>(begin: _slideUp ? 1.0 : -1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 1.0, curve: widget.curve),
      ),
    );

    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeIn),
      ),
    );

    _scaleOutAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeIn),
      ),
    );

    _scaleInAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 1.0, curve: widget.curve),
      ),
    );

    _blurOutAnimation = Tween<double>(begin: 0.0, end: 4.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeIn),
      ),
    );

    _blurInAnimation = Tween<double>(begin: 4.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 1.0, curve: widget.curve),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant RollingDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.character != oldWidget.character) {
      _previousCharacter = oldWidget.character;
      _displayCharacter = widget.character;

      // Determine slide direction
      final oldIsNum = _isDigit(_previousCharacter);
      final newIsNum = _isDigit(_displayCharacter);
      if (oldIsNum && newIsNum) {
        final oldVal = int.parse(_previousCharacter!);
        final newVal = int.parse(_displayCharacter!);
        _slideUp = newVal > oldVal;
      } else {
        _slideUp = true;
      }

      _initAnimations();
      _animating = true;
      _controller.reset();

      Future.delayed(Duration(milliseconds: widget.delayMs), () {
        if (mounted) {
          _controller.forward().then((_) {
            if (mounted) {
              setState(() {
                _animating = false;
              });
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasChanges = widget.character != widget.oldCharacter;

    // For null character slots, return truly zero-width widget
    // so the Row (and its wrapping AnimatedSize) only reflects visible digits
    if (widget.character == null && widget.oldCharacter == null) {
      return const SizedBox.shrink();
    }

    if (!hasChanges && !_animating) {
      if (widget.character == null) {
        return const SizedBox.shrink();
      }
      return Text(
        widget.character!,
        style: widget.style,
      );
    }

    final fontSize = widget.style.fontSize ?? 14.0;
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Layout reserve spacer (forces stack to occupy exactly text size)
        Opacity(
          opacity: 0.0,
          child: Text(
            _displayCharacter ?? _previousCharacter ?? '0',
            style: widget.style,
          ),
        ),
        Positioned.fill(
          child: OverflowBox(
            minHeight: fontSize * 2.6,
            maxHeight: fontSize * 2.6,
            minWidth: 0.0,
            maxWidth: double.infinity,
            alignment: Alignment.center,
            child: ClipRect(
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black,
                      Colors.black,
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.2, 0.8, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    if (_animating && _previousCharacter != null)
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return FractionalTranslation(
                            translation: Offset(0.0, _slideOutAnimation.value),
                            child: ImageFiltered(
                              imageFilter: ImageFilter.blur(
                                sigmaX: _blurOutAnimation.value,
                                sigmaY: _blurOutAnimation.value,
                                tileMode: TileMode.decal,
                              ),
                              child: ScaleTransition(
                                scale: _scaleOutAnimation,
                                child: FadeTransition(
                                  opacity: _fadeOutAnimation,
                                  child: Text(
                                    _previousCharacter!,
                                    style: widget.style,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        final content = ScaleTransition(
                          scale: _animating ? _scaleInAnimation : const AlwaysStoppedAnimation(1.0),
                          child: FadeTransition(
                            opacity: _animating ? _fadeInAnimation : const AlwaysStoppedAnimation(1.0),
                            child: Text(
                              _displayCharacter ?? '',
                              style: widget.style,
                            ),
                          ),
                        );

                        if (_animating) {
                          return FractionalTranslation(
                            translation: Offset(0.0, _slideInAnimation.value),
                            child: ImageFiltered(
                              imageFilter: ImageFilter.blur(
                                sigmaX: _blurInAnimation.value,
                                sigmaY: _blurInAnimation.value,
                                tileMode: TileMode.decal,
                              ),
                              child: content,
                            ),
                          );
                        } else {
                          return content;
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
