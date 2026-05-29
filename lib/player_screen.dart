import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
class TrackModel {
  final String title;
  final String artist;
  final String audioAssetPath;
  final String imageAssetPath;

  const TrackModel({
    required this.title,
    required this.artist,
    required this.audioAssetPath,
    required this.imageAssetPath,
  });
}

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  PlayerScreenState createState() => PlayerScreenState();
}

class PlayerScreenState extends State<PlayerScreen> {
  final List<TrackModel> _playlist = const [
    TrackModel(
      title: "Heavenly Clouds",
      artist: "Lind Erebros",
      audioAssetPath: "assets/audio/sample1.ogg",
      imageAssetPath: "album_art1.jpg",
    ),
    TrackModel(
      title: "Old Sensei",
      artist: "Lind Erebros",
      audioAssetPath: "assets/audio/sample2.ogg",
      imageAssetPath: "album_art2.jpg",
    ),
    TrackModel(
      title: "Fat Boss",
      artist: "Lind Erebros",
      audioAssetPath: "assets/audio/sample3.ogg",
      imageAssetPath: "album_art3.png",
    ),
    TrackModel(
      title: "Bridge to the other side",
      artist: "Lind Erebros",
      audioAssetPath: "assets/audio/sample4.ogg",
      imageAssetPath: "album_art4.png",
    ),
  ];

  int _currentIndex = 0;
  final AudioPlayer player = AudioPlayer();
  bool loaded = false;
  bool playing = false;

  late ConcatenatingAudioSource _audioPlaylist;

  static const Color _bgDark = Color(0xff121212);
  static const Color _accentColor = Color(0xffE5A93C);
  static const Color _textMuted = Color(0xffA0A0A0);

  @override
  void initState() {
    super.initState();
    _initAudioPlaylist();
    _setupAudioStreams();
  }

  Future<void> _initAudioPlaylist() async {
    _audioPlaylist = ConcatenatingAudioSource(
      useLazyPreparation: true,
      children: _playlist
          .map((track) => AudioSource.asset(track.audioAssetPath))
          .toList(),
    );

    try {
      await player.setAudioSource(_audioPlaylist);
      if (mounted) {
        setState(() {
          loaded = true;
        });
      }
    } catch (e) {
      debugPrint("Error initializing audio source playlist: $e");
    }
  }

  void _setupAudioStreams() {
    player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          playing = state.playing;
        });
      }
    });

    player.currentIndexStream.listen((index) {
      if (index != null && mounted) {
        setState(() {
          _currentIndex = index;
        });
      }
    });
  }

  void _nextTrack() {
    if (player.hasNext) {
      player.seekToNext();
    } else {
      player.seek(Duration.zero, index: 0);
    }
  }

  void _previousTrack() {
    if (player.position.inSeconds > 3) {
      player.seek(Duration.zero);
    } else if (player.hasPrevious) {
      player.seekToPrevious();
    } else {
      player.seek(Duration.zero, index: _playlist.length - 1);
    }
  }

  void playMusic() async => await player.play();
  void pauseMusic() async => await player.pause();

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTrack = _playlist[_currentIndex];

    return Scaffold(
      backgroundColor: _bgDark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 30),
          onPressed: () {},
        ),
        title: const Text(
          "NOW PLAYING",
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              currentTrack.imageAssetPath,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                color: Colors.black.withOpacity(0.55),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 12.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxAvailableHeight = constraints.maxHeight;
                  final artSize = (maxAvailableHeight * 0.40).clamp(180.0, 310.0);

                  return Column(
                    children: [
                      const Spacer(flex: 2),

                      Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: artSize,
                          height: artSize,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            image: DecorationImage(
                              image: AssetImage(currentTrack.imageAssetPath),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.45),
                                blurRadius: 25,
                                offset: const Offset(0, 12),
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.08),
                                blurRadius: 1,
                                offset: const Offset(-1, -1),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(flex: 3),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentTrack.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currentTrack.artist,
                                  style: const TextStyle(
                                    color: _textMuted,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          AudioVisualWaveform(
                            isPlaying: playing && loaded,
                            color: _accentColor,
                          ),
                        ],
                      ),

                      const Spacer(flex: 2),

                      StreamBuilder<Duration>(
                        stream: player.positionStream,
                        builder: (context, snapshot) {
                          final position = snapshot.data ?? Duration.zero;
                          final buffered = player.bufferedPosition;
                          final total = player.duration ?? Duration.zero;

                          return ProgressBar(
                            progress: loaded ? position : Duration.zero,
                            total: loaded ? total : Duration.zero,
                            buffered: loaded ? buffered : Duration.zero,
                            timeLabelPadding: 6,
                            timeLabelTextStyle: const TextStyle(
                                fontSize: 12,
                                color: _textMuted,
                                fontWeight: FontWeight.w600,
                                /*慢*/                           ),
                            progressBarColor: _accentColor,
                            baseBarColor: Colors.white.withOpacity(0.1),
                            bufferedBarColor: Colors.white.withOpacity(0.2),
                            thumbColor: Colors.white,
                            thumbRadius: 5,
                            thumbGlowRadius: 12,
                            onSeek: loaded
                                ? (duration) async {
                              await player.seek(duration);
                            }
                                : null,
                          );
                        },
                      ),

                      const Spacer(flex: 2),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: loaded ? _previousTrack : null,
                            iconSize: 40,
                            disabledColor: Colors.white.withOpacity(0.1),
                            color: Colors.white,
                            icon: const Icon(Icons.skip_previous_rounded),
                          ),
                          GestureDetector(
                            onTap: loaded
                                ? () {
                              if (playing) {
                                pauseMusic();
                              } else {
                                playMusic();
                              }
                            }
                                : null,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              height: 76,
                              width: 76,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: loaded ? _accentColor : _accentColor.withOpacity(0.3),
                                boxShadow: loaded
                                    ? [
                                  BoxShadow(
                                    color: _accentColor.withOpacity(0.3),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  )
                                ]
                                    : [],
                              ),
                              child: Icon(
                                playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                size: 44,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: loaded ? _nextTrack : null,
                            iconSize: 40,
                            disabledColor: Colors.white.withOpacity(0.1),
                            color: Colors.white,
                            icon: const Icon(Icons.skip_next_rounded),
                          ),
                        ],
                      ),
                      const Spacer(flex: 2),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AudioVisualWaveform extends StatefulWidget {
  final bool isPlaying;
  final Color color;

  const AudioVisualWaveform({
    super.key,
    required this.isPlaying,
    required this.color,
  });

  @override
  State<AudioVisualWaveform> createState() => _AudioVisualWaveformState();
}

class _AudioVisualWaveformState extends State<AudioVisualWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final List<double> _baseHeights = [0.2, 0.5, 0.8, 0.6, 0.3];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    if (widget.isPlaying) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant AudioVisualWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_animationController.isAnimating) {
      _animationController.repeat(reverse: true);
    } else if (!widget.isPlaying && _animationController.isAnimating) {
      _animationController.stop();
      _animationController.animateTo(0.0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(_baseHeights.length, (index) {
            double dynamicMultiplier = widget.isPlaying
                ? (_baseHeights[index] * 0.4) + (_random.nextDouble() * 0.6)
                : _baseHeights[index] * 0.25;

            double currentHeight = lerpDouble(
              _baseHeights[index] * 0.25,
              dynamicMultiplier * 28,
              _animationController.value,
            ) ?? 4.0;

            return Container(
              width: 3.5,
              height: currentHeight.clamp(4.0, 32.0),
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(widget.isPlaying ? 1.0 : 0.4),
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }),
        );
      },
    );
  }
}