import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../models/fake_data.dart';
import '../widgets/floating_hearts.dart';
import '../widgets/comment_feed.dart';

const _twitchPurple = Color(0xFF9146FF);

class TwitchLiveScreen extends StatefulWidget {
  const TwitchLiveScreen({super.key});

  @override
  State<TwitchLiveScreen> createState() => _TwitchLiveScreenState();
}

class _TwitchLiveScreenState extends State<TwitchLiveScreen> {
  CameraController? _camera;
  bool _cameraReady = false;
  bool _isLive = false;

  final List<FakeComment> _comments = [];
  final _drift = ViewerDrift(11900);
  int _viewers = 11900;
  Duration _uptime = Duration.zero;

  Timer? _commentTimer;
  Timer? _viewerTimer;
  Timer? _heartTimer;
  Timer? _uptimeTimer;

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

    _camera =
        CameraController(selected, ResolutionPreset.high, enableAudio: false);
    await _camera!.initialize();
    if (mounted) setState(() => _cameraReady = true);
  }

  void _startLive() {
    setState(() {
      _isLive = true;
      _uptime = Duration.zero;
    });
    _scheduleNextComment();
    _viewerTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      setState(() => _viewers = _drift.tick());
    });
    _heartTimer = Timer.periodic(const Duration(milliseconds: 2600), (_) {
      _heartsKey.currentState?.addHeart();
    });
    _uptimeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _uptime += const Duration(seconds: 1));
    });
    for (int i = 0; i < 6; i++) {
      Future.delayed(Duration(milliseconds: i * 120), _addComment);
    }
  }

  void _scheduleNextComment() {
    _commentTimer = Timer(nextCommentDelay(LivePlatform.twitch), () {
      if (!mounted || !_isLive) return;
      _addComment();
      _scheduleNextComment();
    });
  }

  void _stopLive() {
    _commentTimer?.cancel();
    _viewerTimer?.cancel();
    _heartTimer?.cancel();
    _uptimeTimer?.cancel();
    setState(() => _isLive = false);
  }

  void _addComment() {
    setState(() {
      _comments.add(randomComment(LivePlatform.twitch));
      if (_comments.length > 80) _comments.removeAt(0);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  String get _uptimeLabel {
    final h = _uptime.inHours;
    final m = (_uptime.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_uptime.inSeconds % 60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  void dispose() {
    _commentTimer?.cancel();
    _viewerTimer?.cancel();
    _heartTimer?.cancel();
    _uptimeTimer?.cancel();
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
          _buildCamera(),

          // Top scrim
          Positioned(
            top: 0, left: 0, right: 0, height: 170,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
            ),
          ),

          // Bottom scrim
          Positioned(
            bottom: 0, left: 0, right: 0, height: 400,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                ),
              ),
            ),
          ),

          // ── Top bar ──────────────────────────────────────────
          Positioned(
            top: topPad + 8,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  // Avatar with purple ring
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _twitchPurple, width: 2.5),
                      color: const Color(0xFF18181B),
                    ),
                    child:
                        const Icon(Icons.person, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 10),
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
                            shadows: [
                              Shadow(blurRadius: 4, color: Colors.black54)
                            ],
                          ),
                        ),
                        if (_isLive) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEB0400),
                                  borderRadius: BorderRadius.circular(4),
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
                              Text(
                                _uptimeLabel,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Viewer pill (twitch style: red dot person count)
                  if (_isLive) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person,
                              color: Color(0xFFEB0400), size: 14),
                          const SizedBox(width: 4),
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

                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32, height: 32,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black38,
                      ),
                      child:
                          const Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Stream title bar (believability detail) ──────────
          if (_isLive)
            Positioned(
              top: topPad + 58,
              left: 14,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.videogame_asset,
                        color: _twitchPurple, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'Just Chatting',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

          FloatingHeartsOverlay(key: _heartsKey),

          // ── Chat + bottom bar ────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isLive)
                  SizedBox(
                    height: 260,
                    child: CommentFeed(
                      comments: _comments,
                      scrollController: _scrollController,
                      style: FeedStyle.twitch,
                    ),
                  ),
                _TwitchBottomBar(
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

class _TwitchBottomBar extends StatelessWidget {
  final bool isLive;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final double bottomPad;

  const _TwitchBottomBar({
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
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white24),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: const Text(
                      'Send a message',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.card_giftcard,
                      color: _twitchPurple, size: 22),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onStop,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEB0400),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'End Stream',
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
                    color: _twitchPurple,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: _twitchPurple.withOpacity(0.45),
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
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
