import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:read_the_label/models/agent_step_record.dart';

class AgentStepsPill extends StatefulWidget {
  final List<AgentStepRecord> steps;
  final bool isRunning;
  final String? runningLabel;

  const AgentStepsPill({
    super.key,
    required this.steps,
    required this.isRunning,
    this.runningLabel,
  });

  @override
  State<AgentStepsPill> createState() => _AgentStepsPillState();
}

class _AgentStepsPillState extends State<AgentStepsPill> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isRunning) {
      return _buildRunningPill();
    } else {
      return _buildCompletedPill();
    }
  }

  Widget _buildRunningPill() {
    final label = widget.runningLabel ?? 'Thinking...';
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12, width: 0.8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white38),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextShimmer(text: label),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedPill() {
    if (widget.steps.isEmpty) return const SizedBox.shrink();

    final stepCount = widget.steps.length;
    final successfulCount = widget.steps.where((s) => s.success).length;
    final allSuccessful = successfulCount == stepCount;

    return Align(
      alignment: Alignment.centerLeft,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white12, width: 0.8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            allSuccessful ? Icons.check : Icons.error_outline,
                            size: 14,
                            color: allSuccessful ? Colors.greenAccent : Colors.redAccent,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$stepCount ${stepCount == 1 ? 'step' : 'steps'}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            size: 14,
                            color: Colors.white38,
                          ),
                        ],
                      ),
                      if (_isExpanded) ...[
                        const SizedBox(height: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 300),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: widget.steps.map((step) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      step.success
                                          ? Icons.check_circle_outline
                                          : Icons.error_outline,
                                      size: 12,
                                      color: step.success ? Colors.greenAccent : Colors.redAccent,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        step.humanLabel,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.6),
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
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TextShimmer extends StatefulWidget {
  final String text;
  const TextShimmer({super.key, required this.text});

  @override
  State<TextShimmer> createState() => _TextShimmerState();
}

class _TextShimmerState extends State<TextShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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
        final double offset = _controller.value;
        return ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Colors.white.withOpacity(0.4),
              Colors.white.withOpacity(1.0),
              Colors.white.withOpacity(0.4),
            ],
            stops: [
              (offset - 0.25).clamp(0.0, 1.0),
              offset,
              (offset + 0.25).clamp(0.0, 1.0),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: Text(
            widget.text,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
}
