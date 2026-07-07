import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../models/fake_data.dart';
import '../widgets/floating_hearts.dart';
import '../widgets/comment_feed.dart';

class TikTokLiveScreen extends StatefulWidget {
  const TikTokLiveScreen({super.key});

  @override
  State<TikTokLiveScreen> createState() => _TikTokLiveScreenState();
}

class _TikTokLiveScreenState extends State<TikTokLiveScreen> {
  CameraController? _camera;
  bool _cameraReady = false;
  bool _isLive = false;

  final List<FakeComment> _comments = [];
  final _drift = ViewerDrift(25600);
  int _viewers = 25600;
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
    _heartTimer = Timer.periodic(const Duration(milliseconds: 750), (_) {
      _heartsKey.currentState?.addHeart();
    });
    for (int i = 0; i < 5; i++) {
      Future.delayed(Duration(milliseconds: i * 150), _addComment);
    }
  }

  void _scheduleNextComment() {
    _commentTimer = Timer(nextCommentDelay(LivePlatform.tiktok), () {
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
      _comments.add(randomComment(LivePlatform.tiktok));
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
    if (!_cameraReady || _camera == null) return Container(color: Colors.black);
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
            top: 0, left: 0, right: 0, height: 200,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.65), Colors.transparent],
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
                  colors: [Colors.black.withOpacity(0.85), Colors.transparent],
                ),
              ),
            ),
          ),

          // ── TOP BAR – always anchored at top ─────────────────
          Positioned(
            top: topPad + 10,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar with cyan ring
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF69C9D0), width: 2),
                      color: Colors.grey[850],
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 10),

                  // Username + live/viewers row
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
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: const Text(
                                  'LIVE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.remove_red_eye_outlined, color: Colors.white70, size: 12),
                              const SizedBox(width: 3),
                              Text(
                                formatViewers(_viewers),
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Following pill
                  if (_isLive) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF69C9D0),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        'Following',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],

                  // Close X
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32, height: 32,
                      decoration: const BoxDecoration(
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

          // ── Right-side action buttons ─────────────────────────
          if (_isLive)
            Positioned(
              right: 12,
              bottom: botPad + 100,
              child: Column(
                children: [
                  _SideButton(icon: Icons.person_add, label: 'Invite', onTap: () {}),
                  const SizedBox(height: 22),
                  _SideButton(icon: Icons.share, label: 'Share', onTap: () {}),
                  const SizedBox(height: 22),
                  GestureDetector(
                    onTap: () => _heartsKey.currentState?.addHeart(),
                    child: Column(
                      children: const [
                        Icon(Icons.favorite, color: Colors.red, size: 32),
                        SizedBox(height: 4),
                        Text('Like', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // ── Floating hearts ───────────────────────────────────
          FloatingHeartsOverlay(key: _heartsKey),

          // ── Comments + bottom bar ─────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 68,
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
                      usernameColor: const Color(0xFF69C9D0),
                      giftAccent: const Color(0xFFFF004F),
                    ),
                  ),
                _TikTokBottomBar(
                  isLive: _isLive,
                  onStart: _startLive,
                  onStop: _stopLive,
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

class _SideButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SideButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44, height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white12,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}

class _TikTokBottomBar extends StatelessWidget {
  final bool isLive;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final double bottomPad;

  const _TikTokBottomBar({
    required this.isLive,
    required this.onStart,
    required this.onStop,
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
                Expanded(
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(21),
                      border: Border.all(color: Colors.white24),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Text(
                      'Add a comment...',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onStop,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'End Live',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
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
                  width: 180,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF004F), Color(0xFF69C9D0)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF004F).withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Go LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
