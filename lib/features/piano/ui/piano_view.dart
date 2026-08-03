import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/audio_engine.dart';

class PianoKey {
  final String keyName;
  final String label;
  final bool isBlack;
  Rect rect;

  PianoKey({
    required this.keyName,
    required this.label,
    required this.isBlack,
    required this.rect,
  });
}

class FallingNote {
  final String keyName;
  final String label;
  final double targetX;
  final double keyTopY;
  final double keyWidth;
  double currentY;
  double speed;
  bool isHit;
  bool hasTriggeredParticles;

  FallingNote({
    required this.keyName,
    required this.label,
    required this.targetX,
    required this.keyTopY,
    required this.keyWidth,
    this.currentY = 0.0,
    this.speed = 0.5,
    this.isHit = false,
    this.hasTriggeredParticles = false,
  });
}

class HitParticle {
  double x;
  double y;
  double vx;
  double vy;
  double radius;
  double opacity;
  Color color;

  HitParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.opacity,
    required this.color,
  });

  bool update() {
    x += vx;
    y += vy;
    vy -= 0.12; // rise upwards like sparks
    opacity -= 0.035; // fade out smoothly
    return opacity > 0;
  }
}

class PianoView extends ConsumerStatefulWidget {
  final int startOctave;
  final int visibleWhiteKeysCount;
  final bool showNoteNames;
  final bool isLessonMode;
  final double noteSpeed;
  final Function(String keyName, String label)? onNotePressed;

  const PianoView({
    super.key,
    this.startOctave = 4,
    this.visibleWhiteKeysCount = 14,
    this.showNoteNames = true,
    this.isLessonMode = false,
    this.noteSpeed = 7.5,
    this.onNotePressed,
  });

  @override
  ConsumerState<PianoView> createState() => PianoViewState();
}

class PianoViewState extends ConsumerState<PianoView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final List<PianoKey> _keys = [];
  final Set<String> _activeKeyNames = {};
  final List<FallingNote> _fallingNotes = [];
  final List<HitParticle> _particles = [];
  final Map<int, String> _pointerToKeyMap = {};
  final Random _rand = Random();

  final List<String> _noteNamesWhite = ["C", "D", "E", "F", "G", "A", "B"];
  final List<String> _noteNamesBlack = [
    "C#",
    "D#",
    "",
    "F#",
    "G#",
    "A#",
    ""
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _animController.addListener(() {
      _updateAnimationLoop();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void addFallingNote(String keyName, String label, bool isBlack) {
    if (_keys.isEmpty) return;

    PianoKey? matchingKey = _keys
        .cast<PianoKey?>()
        .firstWhere((k) => k?.keyName == keyName, orElse: () => null);

    if (matchingKey == null) {
      String keyType = keyName.startsWith("w") ? "w" : "b";
      int posDigit = int.tryParse(keyName.substring(keyName.length - 1)) ?? 0;
      String mappedKeyName = "$keyType${widget.startOctave}$posDigit";
      matchingKey = _keys
          .cast<PianoKey?>()
          .firstWhere((k) => k?.keyName == mappedKeyName, orElse: () => null);
    }

    matchingKey ??= _keys
        .cast<PianoKey?>()
        .firstWhere((k) => k?.isBlack == isBlack, orElse: () => null);
    matchingKey ??= _keys.isNotEmpty ? _keys.first : null;

    if (matchingKey == null) return;

    setState(() {
      _fallingNotes.add(FallingNote(
        keyName: matchingKey!.keyName,
        label: label,
        targetX: matchingKey.rect.center.dx,
        keyTopY: matchingKey.rect.top,
        keyWidth: matchingKey.rect.width,
        currentY: 0.0,
        speed: widget.noteSpeed,
      ));
    });
  }

  void clearFallingNotes() {
    setState(() {
      _fallingNotes.clear();
      _particles.clear();
    });
  }

  void _spawnHitParticles(double x, double y) {
    final List<Color> sparkColors = [
      const Color(0xFFFFD54F), // Amber bright
      const Color(0xFFFFA726), // Golden orange
      const Color(0xFFFFFFFF), // Pure white spark
      const Color(0xFFFFE082), // Soft gold
    ];

    for (int i = 0; i < 22; i++) {
      double angle = _rand.nextDouble() * pi; // upwards hemisphere
      double speed = _rand.nextDouble() * 4.5 + 1.5;
      _particles.add(HitParticle(
        x: x + (_rand.nextDouble() * 20 - 10),
        y: y + (_rand.nextDouble() * 6 - 3),
        vx: cos(angle) * speed * 0.8,
        vy: -sin(angle) * speed,
        radius: _rand.nextDouble() * 3.5 + 1.5,
        opacity: 1.0,
        color: sparkColors[_rand.nextInt(sparkColors.length)],
      ));
    }
  }

  void _updateAnimationLoop() {
    bool needsRepaint = false;

    // Update falling notes
    if (_fallingNotes.isNotEmpty) {
      for (int i = _fallingNotes.length - 1; i >= 0; i--) {
        final note = _fallingNotes[i];
        note.currentY += note.speed;
        needsRepaint = true;

        // Trigger particle fireworks right when the note reaches key top Y line!
        if (note.currentY >= note.keyTopY && !note.hasTriggeredParticles) {
          note.hasTriggeredParticles = true;
          _spawnHitParticles(note.targetX, note.keyTopY);
        }

        if (note.currentY > note.keyTopY + 60) {
          _fallingNotes.removeAt(i);
        }
      }
    }

    // Update particles
    if (_particles.isNotEmpty) {
      needsRepaint = true;
      _particles.removeWhere((particle) => !particle.update());
    }

    if (needsRepaint && mounted) {
      setState(() {});
    }
  }

  int? _getBlackKeyAudioIndex(int whiteIndex) {
    switch (whiteIndex) {
      case 0:
        return 0; // C# -> b<oct>0
      case 1:
        return 1; // D# -> b<oct>1
      case 3:
        return 2; // F# -> b<oct>2
      case 4:
        return 3; // G# -> b<oct>3
      case 5:
        return 4; // A# -> b<oct>4
      default:
        return null;
    }
  }

  void _calculateLayout(Size size) {
    _keys.clear();
    final double width = size.width;
    final double height = size.height;

    final double whiteKeyWidth = width / widget.visibleWhiteKeysCount;
    final double blackKeyWidth = whiteKeyWidth * 0.60;

    final double keyboardTop = widget.isLessonMode ? height * 0.48 : 0.0;
    final double keyboardHeight = height - keyboardTop;
    final double blackKeyHeight = keyboardHeight * 0.62;

    final int octaves = (widget.visibleWhiteKeysCount / 7).ceil() + 1;

    final List<PianoKey> whiteKeysList = [];
    final List<PianoKey> blackKeysList = [];

    int whiteIndex = 0;
    for (int oct = widget.startOctave;
        oct < (widget.startOctave + octaves);
        oct++) {
      for (int i = 0; i < 7; i++) {
        if (whiteIndex >= widget.visibleWhiteKeysCount) break;

        double left = whiteIndex * whiteKeyWidth;
        double right = left + whiteKeyWidth;
        String keyName = "w$oct$i";
        String label = "${_noteNamesWhite[i]}$oct";

        var key = PianoKey(
          keyName: keyName,
          label: label,
          isBlack: false,
          rect: Rect.fromLTRB(left, keyboardTop, right, height),
        );
        whiteKeysList.add(key);

        int? bIndex = _getBlackKeyAudioIndex(i);
        if (bIndex != null) {
          double bLeft = right - (blackKeyWidth / 2.0);
          double bRight = bLeft + blackKeyWidth;
          String bKeyName = "b$oct$bIndex";
          String bLabel = "${_noteNamesBlack[i]}$oct";

          var bKey = PianoKey(
            keyName: bKeyName,
            label: bLabel,
            isBlack: true,
            rect: Rect.fromLTRB(
                bLeft, keyboardTop, bRight, keyboardTop + blackKeyHeight),
          );
          blackKeysList.add(bKey);
        }

        whiteIndex++;
      }
    }

    _keys.addAll(whiteKeysList);
    _keys.addAll(blackKeysList);
  }

  PianoKey? _getKeyAt(Offset position) {
    for (var key in _keys.where((k) => k.isBlack)) {
      if (key.rect.contains(position)) {
        return key;
      }
    }
    for (var key in _keys.where((k) => !k.isBlack)) {
      if (key.rect.contains(position)) {
        return key;
      }
    }
    return null;
  }

  void _onPointerDown(PointerDownEvent event) {
    PianoKey? touchedKey = _getKeyAt(event.localPosition);
    if (touchedKey != null) {
      _pointerToKeyMap[event.pointer] = touchedKey.keyName;
      if (_activeKeyNames.add(touchedKey.keyName)) {
        AudioEngine().playNote(touchedKey.keyName);
        widget.onNotePressed?.call(touchedKey.keyName, touchedKey.label);
        _checkNoteHit(touchedKey.keyName);
        _spawnHitParticles(
            touchedKey.rect.center.dx, touchedKey.rect.top);
        setState(() {});
      }
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    PianoKey? currentKey = _getKeyAt(event.localPosition);
    String? prevKeyName = _pointerToKeyMap[event.pointer];

    if (currentKey?.keyName != prevKeyName) {
      if (prevKeyName != null) {
        _activeKeyNames.remove(prevKeyName);
        AudioEngine().stopNote(prevKeyName);
      }
      if (currentKey != null) {
        _pointerToKeyMap[event.pointer] = currentKey.keyName;
        if (_activeKeyNames.add(currentKey.keyName)) {
          AudioEngine().playNote(currentKey.keyName);
          widget.onNotePressed?.call(currentKey.keyName, currentKey.label);
          _checkNoteHit(currentKey.keyName);
          _spawnHitParticles(
              currentKey.rect.center.dx, currentKey.rect.top);
        }
      } else {
        _pointerToKeyMap.remove(event.pointer);
      }
      setState(() {});
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    String? releasedKey = _pointerToKeyMap.remove(event.pointer);
    if (releasedKey != null) {
      _activeKeyNames.remove(releasedKey);
      AudioEngine().stopNote(releasedKey);
      setState(() {});
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    String? releasedKey = _pointerToKeyMap.remove(event.pointer);
    if (releasedKey != null) {
      _activeKeyNames.remove(releasedKey);
      AudioEngine().stopNote(releasedKey);
      setState(() {});
    }
  }

  void _checkNoteHit(String keyName) {
    for (var note in _fallingNotes) {
      if (note.keyName == keyName && !note.isHit) {
        note.isHit = true;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final Size size = Size(constraints.maxWidth, constraints.maxHeight);
        _calculateLayout(size);

        return Listener(
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          onPointerUp: _onPointerUp,
          onPointerCancel: _onPointerCancel,
          child: CustomPaint(
            size: size,
            painter: PianoPainter(
              keys: _keys,
              activeKeyNames: _activeKeyNames,
              fallingNotes: _fallingNotes,
              particles: _particles,
              showNoteNames: widget.showNoteNames,
            ),
          ),
        );
      },
    );
  }
}

class PianoPainter extends CustomPainter {
  final List<PianoKey> keys;
  final Set<String> activeKeyNames;
  final List<FallingNote> fallingNotes;
  final List<HitParticle> particles;
  final bool showNoteNames;

  PianoPainter({
    required this.keys,
    required this.activeKeyNames,
    required this.fallingNotes,
    required this.particles,
    required this.showNoteNames,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint whiteKeyPaint = Paint()..color = const Color(0x22FFFFFF);
    final Paint whiteBorderPaint = Paint()
      ..color = const Color(0x66000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final Paint blackKeyPaint = Paint()..color = const Color(0xEC121218);
    final Paint pressedWhiteKeyPaint = Paint()..color = const Color(0x994CAF50);
    final Paint pressedBlackKeyPaint = Paint()..color = const Color(0xD02E7D32);

    // Draw White Piano Keys
    for (var key in keys.where((k) => !k.isBlack)) {
      final isPressed = activeKeyNames.contains(key.keyName);
      final paint = isPressed ? pressedWhiteKeyPaint : whiteKeyPaint;

      final RRect rrect = RRect.fromRectAndCorners(
        key.rect,
        bottomLeft: const Radius.circular(4),
        bottomRight: const Radius.circular(4),
      );
      canvas.drawRRect(rrect, paint);
      canvas.drawRRect(rrect, whiteBorderPaint);

      if (showNoteNames) {
        int oct = int.tryParse(key.label.substring(key.label.length - 1)) ?? 4;
        Color pillColor;
        switch (oct) {
          case 3:
            pillColor = const Color(0xDD4CAF50);
            break;
          case 4:
            pillColor = const Color(0xDD26A69A);
            break;
          case 5:
            pillColor = const Color(0xDD29B6F6);
            break;
          case 6:
            pillColor = const Color(0xDDAB47BC);
            break;
          default:
            pillColor = const Color(0xDDCE93D8);
        }

        double centerX = key.rect.center.dx;
        double pillWidth = (key.rect.width * 0.68).clamp(22.0, 40.0);
        double pillHeight = 22.0;
        double pillBottom = key.rect.bottom - 12.0;

        Rect pillRect = Rect.fromLTRB(
          centerX - pillWidth / 2,
          pillBottom - pillHeight,
          centerX + pillWidth / 2,
          pillBottom,
        );

        final Paint pillPaint = Paint()..color = pillColor;
        canvas.drawRRect(
          RRect.fromRectAndRadius(pillRect, const Radius.circular(11)),
          pillPaint,
        );

        TextPainter tp = TextPainter(
          text: TextSpan(
            text: key.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(
          canvas,
          Offset(centerX - tp.width / 2,
              pillBottom - pillHeight / 2 - tp.height / 2),
        );
      }
    }

    // Draw Black Piano Keys
    for (var key in keys.where((k) => k.isBlack)) {
      final isPressed = activeKeyNames.contains(key.keyName);
      final paint = isPressed ? pressedBlackKeyPaint : blackKeyPaint;

      final RRect rrect = RRect.fromRectAndCorners(
        key.rect,
        bottomLeft: const Radius.circular(5),
        bottomRight: const Radius.circular(5),
      );
      canvas.drawRRect(rrect, paint);

      if (!isPressed) {
        final Path highlightPath = Path()
          ..moveTo(key.rect.left + 2, key.rect.top)
          ..lineTo(key.rect.right - 2, key.rect.top)
          ..lineTo(key.rect.right - 4, key.rect.top + key.rect.height * 0.48)
          ..lineTo(key.rect.left + 2, key.rect.top + key.rect.height * 0.48)
          ..close();

        final Paint glossPaint = Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0x55FFFFFF),
              Color(0x10FFFFFF),
            ],
          ).createShader(key.rect);

        canvas.drawPath(highlightPath, glossPaint);
      }
    }

    // Draw Golden Synthesia Falling Tiles (Bars with Outer Glow)
    for (var note in fallingNotes) {
      double tileWidth = (note.keyWidth * 0.72).clamp(18.0, 36.0);
      double tileHeight = 44.0;
      double topY = note.currentY - tileHeight;

      Rect barRect = Rect.fromLTWH(
        note.targetX - tileWidth / 2,
        topY,
        tileWidth,
        tileHeight,
      );

      RRect roundedBar = RRect.fromRectAndRadius(
        barRect,
        const Radius.circular(10),
      );

      // Outer Glow Effect
      Paint glowPaint = Paint()
        ..color = const Color(0xFFFFB300).withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawRRect(roundedBar, glowPaint);

      // Golden Gradient Tile Body
      Paint tilePaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFF176), // Bright yellow-gold top
            Color(0xFFFFB300), // Amber gold
            Color(0xFFF57C00), // Deep warm orange bottom
          ],
        ).createShader(barRect);

      canvas.drawRRect(roundedBar, tilePaint);

      // Inner Highlight Rim
      Paint borderPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawRRect(roundedBar, borderPaint);

      // Light Beam Effect at Key Contact Line
      if (note.currentY >= note.keyTopY - 10) {
        Paint beamPaint = Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.white,
              const Color(0xFFFFD54F).withValues(alpha: 0.8),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
                center: Offset(note.targetX, note.keyTopY), radius: 30),
          );
        canvas.drawCircle(Offset(note.targetX, note.keyTopY), 24, beamPaint);
      }
    }

    // Draw Hit Sparkles / Particle Fireworks Effect
    for (var particle in particles) {
      Paint pPaint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity.clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.radius,
        pPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PianoPainter oldDelegate) {
    return true;
  }
}
