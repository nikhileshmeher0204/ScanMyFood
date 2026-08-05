import 'dart:io';
import 'dart:async';
import 'dart:ui';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:genui/genui.dart' hide TextPart;
import 'package:genui/genui.dart' as genui;
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:read_the_label/models/user_profile.dart';
import 'package:read_the_label/viewmodels/ai_chat_view_model.dart';
import 'package:read_the_label/views/screens/ask_ai/nutrition_catalog.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/main.dart';
import 'package:read_the_label/services/ai_context_builder.dart';
import 'package:read_the_label/services/ai_chat_service.dart';
import 'package:read_the_label/services/tools/tool_execution_client.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';
import 'package:read_the_label/views/widgets/ai_chat/agent_steps_pill.dart';

class AskAiView extends StatefulWidget {
  final String? foodContext;
  final String? mealName;
  final File? foodImage;

  const AskAiView({super.key, this.foodContext, this.mealName, this.foodImage});

  @override
  State<AskAiView> createState() => _AskAiViewState();
}

class _AskAiViewState extends State<AskAiView> {
  late final SurfaceController _controller;
  late final A2uiTransportAdapter _transport;
  late final Conversation _conversation;
  late final Catalog _catalog;

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final toolClient = context.read<ToolExecutionClient>();
    _catalog = NutritionCatalog.create(toolClient);
    _controller = SurfaceController(catalogs: [_catalog]);
    _transport = A2uiTransportAdapter(onSend: _sendAndReceive);
    _conversation = Conversation(
      controller: _controller,
      transport: _transport,
    );

    _conversation.events.listen((event) {
      if (!mounted) return;
      final viewModel = Provider.of<AiChatViewModel>(context, listen: false);
      switch (event) {
        case ConversationSurfaceAdded added:
          viewModel.appendSurface(added.surfaceId);
          _scrollToBottom();
        case ConversationSurfaceRemoved removed:
          // In Phase 3/4 we can support removal if needed
          break;
        case ConversationContentReceived content:
          viewModel.appendAiText(content.text);
          _scrollToBottom();
        case ConversationError error:
          logger.e("GenUI Conversation Error: ${error.error}");
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${error.error}')));
        default:
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSessionAndPrompt();
    });
  }

  Future<void> _initSessionAndPrompt() async {
    final viewModel = Provider.of<AiChatViewModel>(context, listen: false);

    if (widget.foodContext != null) {
      final mealScanContext =
          'Meal Name: ${widget.mealName ?? "Scanned Food"}\nScan Details: ${widget.foodContext}';
      await viewModel.startNewSession(mealContext: mealScanContext);
    } else {
      await viewModel.loadSessions();
      if (viewModel.sessions.isNotEmpty) {
        await viewModel.loadSession(viewModel.sessions.first.sessionId);
      } else {
        await viewModel.startNewSession();
      }
    }

    UserProfile? profile;
    try {
      final user = viewModel.authService.currentUser;
      if (user != null) {
        profile = await viewModel.userRepository.getUserProfile();
      }
    } catch (e) {
      logger.w('Failed to load user profile: $e');
    }

    final systemPrompt = AiContextBuilder.buildSystemPromptWrapped(
      catalog: _catalog,
      profile: profile,
      mealScanContext: viewModel.currentSession?.mealContext,
    );
    _conversation.sendRequest(ChatMessage.system(systemPrompt));
  }

  Future<void> _sendAndReceive(ChatMessage msg) async {
    if (msg.role == ChatMessageRole.system) return;

    final buffer = StringBuffer();
    for (final part in msg.parts) {
      if (part.isUiInteractionPart) {
        buffer.write(part.asUiInteractionPart!.interaction);
      } else if (part is genui.TextPart) {
        buffer.write(part.text);
      }
    }

    if (buffer.isEmpty) return;
    final text = buffer.toString();

    final viewModel = Provider.of<AiChatViewModel>(context, listen: false);
    await viewModel.sendUserMessage(text, _transport);
    _scrollToBottom();
  }

  void _handleSend() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    _inputController.clear();
    _transport.sendRequest(ChatMessage.user(text));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _transport.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AiChatViewModel>();

    return Scaffold(
      body: Stack(
        children: [
          // Liquid twist shader background
          const LiquidTwistBackground(),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Frosted glass premium App Bar
                _buildAppBar(context, viewModel),

                // Chat message log area
                Expanded(
                  child: viewModel.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF6B4EFF),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16,
                            bottom: 100, // Cushion for the floating input bar
                          ),
                          itemCount: viewModel.chatItems.length,
                          itemBuilder: (context, index) {
                            final item = viewModel.chatItems[index];
                            final isLast =
                                index == viewModel.chatItems.length - 1;
                            return _buildChatItem(item, isLast);
                          },
                        ),
                ),
              ],
            ),
          ),

          // Floating Apple Music style input row
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _buildFloatingInputBar(context, viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AiChatViewModel viewModel) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.transparent,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryWhite.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  onPressed: () {
                    // If we are showing as a nested PageView item (home_page index 3), we can't pop.
                    // Only pop if we are a pushed screen (e.g. opened from scan views).
                    final modalRoute = ModalRoute.of(context);
                    if (modalRoute != null && modalRoute.canPop) {
                      Navigator.pop(context);
                    }
                  },
                  icon: Icon(
                    Icons.close,
                    color: AppColors.primaryWhite.withValues(alpha: 0.8),
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viewModel.currentSession?.title ?? 'Nutrition AI Chat',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white70),
            onPressed: () => _showSessionHistorySheet(context, viewModel),
          ),
          IconButton(
            icon: const Icon(Icons.add_comment_outlined, color: Colors.white70),
            onPressed: () async {
              AiChatService.instance.clearSessionCache(
                viewModel.currentSession?.sessionId ?? '',
              );
              await viewModel.startNewSession();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Started a new chat session')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(ChatItem item, bool isLast) {
    final viewModel = Provider.of<AiChatViewModel>(context, listen: false);
    // Use AppColors semantic label system (mirrors Apple UIColor.label / .tertiaryLabel).
    // This avoids computing from a hardcoded background and gives warm-tinted white
    // for active text and a properly dimmed tone for past messages.
    final Color activeColor = AppColors.label; // 0xFFFFFFFF — full label
    final Color inactiveColor =
        AppColors.tertiaryLabel; // rgba(235,235,245,0.3)

    // Apple Music lyrics: active line is large & bright, past lines are small & dimmed
    const double activeFontSize = 20.0;
    const double inactiveFontSize = 17.0;

    final Color textColor = isLast ? activeColor : inactiveColor;
    final double fontSize = isLast ? activeFontSize : inactiveFontSize;
    final FontWeight fontWeight = isLast ? FontWeight.w800 : FontWeight.w500;
    // Keep baseColor available for non-text elements (steps card, etc.)
    final Color baseColor = AppColors.label;

    switch (item.type) {
      case ChatItemType.userText:
        return Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: isLast ? 32 : 18,
              left: isLast ? 24 : 48,
              right: 20,
            ),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: fontSize,
                fontWeight: fontWeight,
                height: 1.25,
                color: textColor,
                letterSpacing: isLast ? -0.8 : -0.2,
              ),
              child: Text(item.text, textAlign: TextAlign.end),
            ),
          ),
        );

      case ChatItemType.aiText:
        return Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: isLast ? 32 : 18,
              left: 20,
              right: isLast ? 24 : 48,
            ),
            child: MarkdownBody(
              data: item.text,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  height: 1.25,
                  color: textColor,
                  letterSpacing: isLast ? -0.8 : -0.2,
                ),
                strong: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w900,
                  fontSize: fontSize,
                  color: textColor,
                ),
                em: TextStyle(
                  fontFamily: 'Inter',
                  fontStyle: FontStyle.italic,
                  fontSize: fontSize,
                  color: textColor,
                ),
                h1: TextStyle(
                  fontFamily: 'Inter',
                  color: textColor,
                  fontSize: isLast ? 32 : 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                  height: 1.2,
                ),
                h2: TextStyle(
                  fontFamily: 'Inter',
                  color: textColor,
                  fontSize: isLast ? 26 : 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  height: 1.3,
                ),
                h3: TextStyle(
                  fontFamily: 'Inter',
                  color: textColor,
                  fontSize: isLast ? 22 : 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
                listBullet: TextStyle(
                  fontFamily: 'Inter',
                  color: textColor,
                  fontSize: fontSize,
                ),
                blockquote: TextStyle(
                  fontFamily: 'Inter',
                  color: textColor.withOpacity(0.6),
                  fontSize: fontSize * 0.9,
                  fontStyle: FontStyle.italic,
                ),
                code: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: fontSize * 0.85,
                  color: textColor.withOpacity(0.8),
                ),
              ),
            ),
          ),
        );

      case ChatItemType.surface:
        final surfaceContext = _controller.contextFor(item.surfaceId!);
        if (surfaceContext == null) return const SizedBox.shrink();
        return Align(
          alignment: Alignment.center,
          child: Container(
            margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white12, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Surface(surfaceContext: surfaceContext),
                ),
              ),
            ),
          ),
        );

      case ChatItemType.steps:
        final steps = item.steps ?? [];
        return AgentStepsPill(
          steps: steps,
          isRunning: viewModel.isAgentRunning,
          runningLabel: viewModel.currentRunningLabel,
        );
    }
  }

  Widget _buildFloatingInputBar(
    BuildContext context,
    AiChatViewModel viewModel,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white12, width: 1.0),
          ),
          child: Row(
            children: [
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: _inputController,
                  onSubmitted: (_) => _handleSend(),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: Colors.white,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Ask about nutrition, logs, daily goals...',
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Colors.white38,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _handleSend,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF6B4EFF), Color(0xFF00F2FE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_upward,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSessionHistorySheet(
    BuildContext context,
    AiChatViewModel viewModel,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141420),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Chat Sessions',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (viewModel.sessions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          'No past sessions. Start a new chat!',
                          style: TextStyle(color: Colors.white38),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: viewModel.sessions.length,
                        itemBuilder: (context, index) {
                          final session = viewModel.sessions[index];
                          final isSelected =
                              viewModel.currentSession?.sessionId ==
                              session.sessionId;
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0x1F6B4EFF)
                                  : const Color(0x0DFFFFFF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF6B4EFF)
                                    : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: ListTile(
                              title: Text(
                                session.title,
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF6B4EFF)
                                      : Colors.white,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                              subtitle: Text(
                                session.mealContext != null
                                    ? 'Scan Context'
                                    : 'General Chat',
                                style: const TextStyle(
                                  color: Colors.white30,
                                  fontSize: 11,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.white38,
                                ),
                                onPressed: () async {
                                  await viewModel.deleteSession(
                                    session.sessionId,
                                  );
                                  setSheetState(() {});
                                },
                              ),
                              onTap: () async {
                                Navigator.pop(context);
                                await viewModel.loadSession(session.sessionId);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class LiquidTwistBackground extends StatefulWidget {
  const LiquidTwistBackground({super.key});

  @override
  State<LiquidTwistBackground> createState() => _LiquidTwistBackgroundState();
}

class _LiquidTwistBackgroundState extends State<LiquidTwistBackground>
    with SingleTickerProviderStateMixin {
  // ─── Debug switch ───────────────────────────────────────────────────────────
  // Set to true to disable the blur overlay and see the raw shader output.
  static const bool _kDisableBlur = false;
  // ────────────────────────────────────────────────────────────────────────────
  late final Ticker _ticker;
  final Stopwatch _stopwatch = Stopwatch();
  ui.FragmentProgram? _program;
  ui.Image? _image;
  Color _bgColor = const Color(0xFF121212);
  double _elapsedSeconds = 0.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      if (mounted) {
        setState(() {
          _elapsedSeconds =
              _stopwatch.elapsedMicroseconds / Duration.microsecondsPerSecond;
        });
      }
    });
    _stopwatch.start();
    _ticker.start();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
        'assets/shaders/liquid_twist.frag',
      );

      final imageProvider = const AssetImage(
        'assets/images/ai_chat_cover_image.jpg',
      );
      final imageStream = imageProvider.resolve(const ImageConfiguration());
      final completer = Completer<ui.Image>();

      ImageStreamListener? listener;
      listener = ImageStreamListener((info, _) {
        completer.complete(info.image);
        imageStream.removeListener(listener!);
      });
      imageStream.addListener(listener);

      final image = await completer.future;

      final uiViewModel = Provider.of<UiViewModel>(context, listen: false);
      final bgColor = await uiViewModel.extractDominantColor(
        'assets/images/ai_chat_cover_image.jpg',
      );
      debugPrint('EXTRACTED BG COLOR: $bgColor');

      if (mounted) {
        setState(() {
          _program = program;
          _image = image;
          _bgColor = bgColor;
        });
      }
    } catch (e) {
      debugPrint('Error loading liquid twist assets: $e');
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_program == null || _image == null) {
      // Fallback base color while loading
      return Container(color: const Color(0xFF121212));
    }

    return Stack(
      children: [
        CustomPaint(
          size: Size.infinite,
          painter: LiquidTwistPainter(
            program: _program!,
            image: _image!,
            bgColor: _bgColor,
            time:
                _elapsedSeconds *
                0.5, // Slow down time multiplier for a gentler, more premium drift
          ),
        ),
        // The signature blur overlay that blends the twisted fluid into the premium aesthetic.
        // Disable with _kDisableBlur = true to inspect the raw shader.
        if (!_kDisableBlur)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60.0, sigmaY: 60.0),
              child: Container(color: Colors.black.withValues(alpha: 0.15)),
            ),
          ),
      ],
    );
  }
}

class LiquidTwistPainter extends CustomPainter {
  final ui.FragmentProgram program;
  final ui.Image image;
  final Color bgColor;
  final double time;

  LiquidTwistPainter({
    required this.program,
    required this.image,
    required this.bgColor,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final shader = program.fragmentShader();

    // Set uniform inputs for the shader
    // index 0: u_resolution.x
    shader.setFloat(0, size.width);
    // index 1: u_resolution.y
    shader.setFloat(1, size.height);
    // index 2: u_time
    shader.setFloat(2, time);

    // Dynamic background color uniforms
    // index 3: u_bgColor.r
    shader.setFloat(3, bgColor.red / 255.0);
    // index 4: u_bgColor.g
    shader.setFloat(4, bgColor.green / 255.0);
    // index 5: u_bgColor.b
    shader.setFloat(5, bgColor.blue / 255.0);

    // Set image sampler
    shader.setImageSampler(0, image);

    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant LiquidTwistPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.image != image ||
        oldDelegate.bgColor != bgColor ||
        oldDelegate.program != program;
  }
}
