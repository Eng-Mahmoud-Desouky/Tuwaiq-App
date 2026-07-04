import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../../shared/theme/app_colors.dart';

class PostVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool isLocal;
  final bool autoPlay;
  final bool startMuted;
  final bool loop;

  const PostVideoPlayer({
    super.key,
    required this.videoUrl,
    this.isLocal = false,
    this.autoPlay = true,
    this.startMuted = true,
    this.loop = true,
  });

  @override
  State<PostVideoPlayer> createState() => _PostVideoPlayerState();
}

class _PostVideoPlayerState extends State<PostVideoPlayer> with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isMuted = true;
  double _currentVisibility = 0.0;

  @override
  void initState() {
    super.initState();
    _isMuted = widget.startMuted;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeController();
    super.dispose();
  }

  void _disposeController() {
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (_controller != null && _controller!.value.isPlaying) {
        _controller!.pause();
        setState(() {});
      }
    }
  }

  Future<void> _initializeController() async {
    if (_controller != null) return;

    try {
      final controller = widget.isLocal
          ? VideoPlayerController.file(File(widget.videoUrl))
          : VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

      _controller = controller;

      await controller.setVolume(_isMuted ? 0.0 : 1.0);
      await controller.setLooping(widget.loop);
      await controller.initialize();

      if (mounted && _controller == controller) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });

        // If visibility is already focused, play the video immediately after initialization
        if (widget.autoPlay && _currentVisibility > 70.0) {
          _controller?.play();
        }
      }
    } catch (e) {
      debugPrint('Error initializing video player: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  void _togglePlay() {
    if (!_isInitialized || _controller == null) return;
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
  }

  void _toggleMute() {
    if (!_isInitialized || _controller == null) return;
    setState(() {
      _isMuted = !_isMuted;
      _controller!.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (!mounted) return;

    final visiblePercentage = info.visibleFraction * 100;
    _currentVisibility = visiblePercentage;

    if (visiblePercentage == 0.0) {
      // Completely scrolled out of view -> dispose controller to free VRAM decoders
      if (_controller != null) {
        _disposeController();
        setState(() {});
      }
    } else if (visiblePercentage > 30.0) {
      // Scrolling into view -> initialize controller if not yet initialized
      if (_controller == null && !_hasError) {
        _initializeController();
      }
    }

    // Autoplay / Pause logic based on 70% threshold
    if (_controller != null && _isInitialized) {
      if (visiblePercentage > 70.0) {
        if (widget.autoPlay && !_controller!.value.isPlaying) {
          _controller!.play();
          setState(() {});
        }
      } else {
        if (_controller!.value.isPlaying) {
          _controller!.pause();
          setState(() {});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('video_${widget.videoUrl}'),
      onVisibilityChanged: _handleVisibilityChanged,
      child: AspectRatio(
        aspectRatio: _isInitialized && _controller != null
            ? _controller!.value.aspectRatio
            : 16 / 9,
        child: Container(
          color: Colors.black,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_isInitialized && _controller != null)
                GestureDetector(
                  onTap: _togglePlay,
                  child: VideoPlayer(_controller!),
                )
              else if (_hasError)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      'فشل تحميل الفيديو',
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                    ),
                  ],
                )
              else
                // Sleek skeleton / buffering loader or static thumbnail placeholder
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black87, Colors.black54],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                ),

              // Play / Pause fading overlay indicator
              if (_isInitialized && _controller != null && !_controller!.value.isPlaying)
                GestureDetector(
                  onTap: _togglePlay,
                  child: Container(
                    color: Colors.black26,
                    child: const Center(
                      child: Icon(
                        Icons.play_arrow,
                        size: 64,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),

              // Mute overlay button in bottom-right & Linear progress at bottom
              if (_isInitialized && _controller != null) ...[
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: _toggleMute,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        _isMuted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: 4,
                    child: VideoProgressIndicator(
                      _controller!,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: AppColors.primary,
                        bufferedColor: Colors.white30,
                        backgroundColor: Colors.white10,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
