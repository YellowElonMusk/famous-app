import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../models/fake_data.dart';
import '../widgets/floating_hearts.dart';
import '../widgets/comment_feed.dart';

class InstagramLiveScreen extends StatefulWidget {
  const InstagramLiveScreen({super.key});

  @override
  State<InstagramLiveScreen> createState() => _InstagramLiveScreenState();
}

class _InstagramLiveScreenState extends State<InstagramLiveScreen> {
  CameraController? _camera;
  bool _cameraReady = false;
  bool _isLive = false;

  final List<FakeComment> _comments = [];
  final _drift = ViewerDrift(24800);
  int _viewers = 24800;
  Timer? _commentTimer;
  Timer? _viewerTimer;
  Timer? _heartTimer;

  final _scrollController = ScrollController();
  final _heartsKey = GlobalKey<FloatingHeartsOverlayState>();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    CameraDescription? front;
    for (final c in cameras) {
      if (c.lensDirection == CameraLensDirection.front) {
        front = c;
        break;
      }
    }
    final selected = front ?? (cameras.isNotEmpty ? cameras.first : null);
    if (selected == null) return;

    _camera = CameraController(selected, ResolutionPreset.high, enableAudio: false);
    await _camera!.initialize();
    if (mounted) setState(() => _cameraReady = true);
  }

  void _startLive() {
    setState(() => _isLive = true);
    _scheduleNextComment();
    _viewerTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      setState(() => _viewers = _drift.tick());
    });
    _heartTimer = Timer.periodic(const Duration(milliseconds: 900), (_) {
      _heartsKey.currentState?.addHeart();
    });
    for (int i = 0; i < 4; i++) {
      Future.delayed(Duration(milliseconds: i * 200), _addComment);
    }
  }

  void _scheduleNextComment() {
    _commentTimer = Timer(nextCommentDelay(LivePlatform.instagram), () {
      if (!mounted || !_isLive) return;
      _addComment();
      _scheduleNextComment();
    });
  }

  void _stopLive() {
    _commentTimer?.cancel();
    _viewerTimer?.cancel();
    _heartTimer?.cancel();
    setState(() => _isLive = false);
  }

  void _addComment() {
    setState(() {
      _comments.add(randomComment(LivePlatform.instagram));
      if (_comments.length > 60) _comments.removeAt(0);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _commentTimer?.cancel();
    _viewerTimer?.cancel();
    _heartTimer?.cancel();
    _camera?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildCamera() {
    if (!_cameraReady || _camera == null) {
      return Container(color: Colors.black);
    }
    final previewSize = _camera!.value.previewSize;
    if (previewSize == null) return CameraPreview(_camera!);
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: previewSize.height,
          height: previewSize.width,
          child: CameraPreview(_camera!),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final botPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Camera fills full screen ──────────────────────────
          _buildCamera(),

          // ── Top gradient scrim ────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0, height: 160,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.72), Colors.transparent],
                ),
              ),
            ),
          ),

          // ── Bottom gradient scrim ─────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0, height: 380,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.88), Colors.transparent],
                ),
              ),
            ),
          ),

          // ── TOP BAR – always anchored at top ─────────────────
          Positioned(
            top: topPad + 8,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // IG-gradient avatar
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCB045)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                      child: const CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFF333333),
                        child: Icon(Icons.person, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Username + LIVE pill
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'your_username',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                          ),
                        ),
                        if (_isLive) ...[
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE1306C),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Viewer count pill
                  if (_isLive) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.remove_red_eye_outlined, color: Colors.white70, size: 13),
                          const SizedBox(width: 5),
                          Text(
                            formatViewers(_viewers),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],

                  // Close X
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black38,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Floating hearts ───────────────────────────────────
          FloatingHeartsOverlay(key: _heartsKey),

          // ── Comments + bottom bar ─────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isLive)
                  SizedBox(
                    height: 240,
                    child: CommentFeed(
                      comments: _comments,
                      scrollController: _scrollController,
                      usernameColor: const Color(0xFFE1306C),
                      giftAccent: const Color(0xFFE1306C),
                    ),
                  ),
                _IGBottomBar(
                  isLive: _isLive,
                  onStart: _startLive,
                  onStop: _stopLive,
                  onHeart: () => _heartsKey.currentState?.addHeart(),
                  bottomPad: botPad,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IGBottomBar extends StatelessWidget {
  final bool isLive;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onHeart;
  final double bottomPad;

  const _IGBottomBar({
    required this.isLive,
    required this.onStart,
    required this.onStop,
    required this.onHeart,
    required this.bottomPad,
  });

  @override
  Widget build(BuildContext context) {
    final pad = bottomPad > 0 ? bottomPad : 12.0;
    return Padding(
      padding: EdgeInsets.fromLTRB(14, 6, 14, pad),
      child: isLive
          ? Row(
              children: [
                // Comment input (decorative)
                Expanded(
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Text(
                      'Say something...',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Heart
                GestureDetector(
                  onTap: onHeart,
                  child: Container(
                    width: 42, height: 42,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white12,
                    ),
                    child: const Icon(Icons.favorite_border, color: Colors.white, size: 22),
                  ),
                ),
                const SizedBox(width: 10),
                // End live
                GestureDetector(
                  onTap: onStop,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1306C),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Text(
                      'End',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: GestureDetector(
                onTap: onStart,
                child: Container(
                  width: 170,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF833AB4), Color(0xFFE1306C), Color(0xFFFCB045)],
                    ),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE1306C).withOpacity(0.45),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Go Live',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
