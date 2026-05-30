import 'dart:async';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/theme/app_theme.dart';

class PickImageCard extends StatefulWidget {
  final IconData icon;
  final String titleDescription;
  final String cameraButtonText;
  final String galleryButtonText;
  final File? image;
  final bool isLoading;
  final bool hasResults;
  final Function(ImageSource) onImageCapturePressed;
  final Function(String)? onScanWithDescription;
  final VoidCallback? onScanAnother;
  final List<String>? loadingSentences;

  const PickImageCard({
    super.key,
    required this.icon,
    required this.titleDescription,
    required this.cameraButtonText,
    required this.galleryButtonText,
    required this.onImageCapturePressed,
    this.image,
    this.isLoading = false,
    this.hasResults = false,
    this.onScanWithDescription,
    this.onScanAnother,
    this.loadingSentences,
  });

  @override
  State<PickImageCard> createState() => _PickImageCardState();
}

class _PickImageCardState extends State<PickImageCard> {
  bool _isEnteringDescription = false;
  bool _hasDescriptionError = false;
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImage = widget.image != null;

    if (hasImage) {
      return Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Base Image
              Image.file(
                widget.image!,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
              // Gradient overlay to make text/buttons near bottom readable
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.5),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      stops: const [0.0, 0.4, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
              // Scanner Animation Overlay
              if (widget.isLoading)
                const Positioned.fill(
                  child: PremiumLaserScanner(),
                ),
              // Content overlay sitting at the bottom of the card
              Positioned(
                left: 10,
                right: 10,
                bottom: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 16,
                  children: [
                    if (!widget.isLoading && !widget.hasResults)
                      _buildTitleDescription(hasImage: true),
                    if (widget.isLoading)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: CyclingAnalysisText(
                          sentences: widget.loadingSentences,
                        ),
                      ),
                    if (!widget.isLoading) _buildActionArea(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Default container with DottedBorder when no image is selected
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: DottedBorder(
        borderPadding: const EdgeInsets.all(-10),
        borderType: BorderType.RRect,
        radius: const Radius.circular(20),
        color: AppColors.onSurface.withValues(alpha: 0.2),
        strokeWidth: 1,
        dashPattern: const [6, 4],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            spacing: 20,
            children: [
              Icon(
                widget.icon,
                size: 70,
                color: AppColors.onSurface.withValues(alpha: 0.5),
              ),
              _buildTitleDescription(hasImage: false),
              _buildActionArea(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows the descriptive helper text (hidden when results are available).
  Widget _buildTitleDescription({bool hasImage = false}) {
    return Text(
      widget.titleDescription,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: hasImage ? AppColors.primaryWhite : AppColors.onSurface,
        fontSize: 14,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
        shadows: hasImage
            ? const [
                Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 4.0,
                  color: Colors.black54,
                ),
              ]
            : null,
      ),
    );
  }

  /// Decides which action row to show, morphing between default buttons and description entry.
  Widget _buildActionArea(BuildContext context) {
    if (!widget.hasResults || widget.isLoading) {
      return _buildDefaultButtons(context);
    }

    final darkCardColor = Theme.of(context).colorScheme.cardBackground;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double totalWidth = constraints.maxWidth;

          // When not entering description, left button occupies a proportional share.
          // When entering description, send and cancel buttons occupy 46px each, leaving the rest for the input box.
          return Row(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 1. LEFT BUTTON / TEXT FIELD (Smooth expansion & color shift to black card)
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOutCubic,
                  constraints: const BoxConstraints(minHeight: 46),
                  decoration: BoxDecoration(
                    color: _isEnteringDescription
                        ? darkCardColor
                        : AppColors.primaryWhite,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _hasDescriptionError
                          ? AppColors.secondaryRed
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _isEnteringDescription
                        ? TextField(
                            controller: _descriptionController,
                            maxLines: null,
                            minLines: 1,
                            style: AppTextStyles.buttonTextWhite,
                            onChanged: (text) {
                              if (_hasDescriptionError &&
                                  text.trim().isNotEmpty) {
                                setState(() {
                                  _hasDescriptionError = false;
                                });
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'Add a description...',
                              hintStyle: AppTextStyles.buttonTextWhite,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              border: InputBorder.none,
                            ),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const NeverScrollableScrollPhysics(),
                            child: SizedBox(
                              width: (totalWidth - 8) * 0.55,
                              height: 46,
                              child: TextButton.icon(
                                icon: const Icon(Icons.refresh,
                                    color: AppColors.primaryBlack, size: 18),
                                label: Text(
                                  'Scan with description',
                                  style: AppTextStyles.buttonTextBlack,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                style: TextButton.styleFrom(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isEnteringDescription = true;
                                  });
                                },
                              ),
                            ),
                          ),
                  ),
                ),
              ),

              // 2. RIGHT BUTTON / SEND BUTTON (Smooth shrink to 46px & color shift to solid white)
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutCubic,
                width: _isEnteringDescription ? 46 : (totalWidth - 8) * 0.45,
                height: 46,
                decoration: BoxDecoration(
                  color: _isEnteringDescription
                      ? AppColors.primaryWhite
                      : darkCardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    child: SizedBox(
                      width:
                          _isEnteringDescription ? 46 : (totalWidth - 8) * 0.45,
                      height: 46,
                      child: _isEnteringDescription
                          ? Center(
                              child: IconButton(
                                icon: const Icon(Icons.send,
                                    color: AppColors.primaryBlack, size: 18),
                                onPressed: _handleSend,
                                padding: EdgeInsets.zero,
                              ),
                            )
                          : TextButton.icon(
                              icon: Icon(Icons.photo_library,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  size: 18),
                              label: Text(
                                'Scan another',
                                style: AppTextStyles.buttonTextWhite,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: TextButton.styleFrom(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                              ),
                              onPressed: () {
                                _resetDescriptionState();
                                widget.onScanAnother?.call();
                              },
                            ),
                    ),
                  ),
                ),
              ),

              // 3. CANCEL BUTTON (Smooth expansion from 0 to 46px)
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutCubic,
                width: _isEnteringDescription ? 46 : 0,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.secondaryRed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _isEnteringDescription
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: IconButton(
                          icon: const Icon(Icons.close,
                              color: Colors.white, size: 18),
                          onPressed: _handleCancel,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Default "Take Photo" + "Gallery" buttons shown before any analysis.
  Widget _buildDefaultButtons(BuildContext context, {Key? key}) {
    return Row(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 16,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.camera_alt_outlined,
              color: AppColors.primaryBlack),
          label: Text(widget.cameraButtonText,
              style: AppTextStyles.buttonTextBlack),
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: AppColors.primaryWhite,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: () => widget.onImageCapturePressed(ImageSource.camera),
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.photo_library,
              color: Theme.of(context).colorScheme.onPrimary),
          label: Text(widget.galleryButtonText,
              style: AppTextStyles.buttonTextWhite),
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Theme.of(context).colorScheme.cardBackground,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: () => widget.onImageCapturePressed(ImageSource.gallery),
        ),
      ],
    );
  }

  void _handleSend() {
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      setState(() {
        _hasDescriptionError = true;
      });
      // Show elegant bottom pop-up snackbar
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text(
                'Please enter a description to scan',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.secondaryRed,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
      return;
    }
    widget.onScanWithDescription?.call(description);
    _resetDescriptionState();
  }

  void _handleCancel() {
    _resetDescriptionState();
  }

  void _resetDescriptionState() {
    setState(() {
      _isEnteringDescription = false;
      _hasDescriptionError = false;
      _descriptionController.clear();
    });
  }
}

class PremiumLaserScanner extends StatefulWidget {
  const PremiumLaserScanner({super.key});

  @override
  State<PremiumLaserScanner> createState() => _PremiumLaserScannerState();
}

class _PremiumLaserScannerState extends State<PremiumLaserScanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final topPosition = _animation.value * height;
            return Stack(
              children: [
                // Subtle scanning glow that moves with the line
                Positioned(
                  top: topPosition - 40,
                  left: 0,
                  right: 0,
                  height: 80,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.primaryWhite.withValues(alpha: 0.08),
                            AppColors.primaryWhite.withValues(alpha: 0.18),
                            AppColors.primaryWhite.withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.4, 0.5, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
                // Sleek horizontal laser line
                Positioned(
                  top: topPosition - 1.5,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryWhite.withValues(alpha: 0.8),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.4),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                        gradient: const LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.primaryWhite,
                            Colors.transparent,
                          ],
                          stops: [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class CyclingAnalysisText extends StatefulWidget {
  final List<String>? sentences;
  const CyclingAnalysisText({super.key, this.sentences});

  @override
  State<CyclingAnalysisText> createState() => _CyclingAnalysisTextState();
}

class _CyclingAnalysisTextState extends State<CyclingAnalysisText> {
  late final List<String> _sentences;

  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Default to a premium fallback set if none passed
    _sentences = widget.sentences ?? [
      'Analysis in progress',
      'Identifying food items',
      'Calculating portions',
      'Checking what you cooked',
      'Reading the label',
      'Deciphering ingredients',
    ];
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _sentences.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 17,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.15),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        child: PremiumShimmerText(
          key: ValueKey<int>(_currentIndex),
          text: _sentences[_currentIndex],
          style: textStyle,
        ),
      ),
    );
  }
}

class PremiumShimmerText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const PremiumShimmerText({
    super.key,
    required this.text,
    required this.style,
  });

  @override
  State<PremiumShimmerText> createState() => _PremiumShimmerTextState();
}

class _PremiumShimmerTextState extends State<PremiumShimmerText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double slide = _controller.value;
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.55),
                Colors.white,
                Colors.white.withValues(alpha: 0.55),
              ],
              stops: const [0.35, 0.5, 0.65],
              begin: Alignment(-2.0 + (slide * 4.0), -0.5),
              end: Alignment(-1.0 + (slide * 4.0), 0.5),
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: widget.style,
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}
