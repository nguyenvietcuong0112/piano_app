import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/audio_engine.dart';
import '../../../core/theme/app_text_styles.dart';

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
  final String originalKeyName;
  final String label;
  final double targetX;
  final double keyTopY;
  final double keyWidth;
  final int durationMs;
  double currentY;
  double speed;
  bool isHit;
  bool hasTriggeredParticles;
  bool hasMissed;

  FallingNote({
    required this.keyName,
    required this.originalKeyName,
    required this.label,
    required this.targetX,
    required this.keyTopY,
    required this.keyWidth,
    this.durationMs = 300,
    this.currentY = 0.0,
    this.speed = 0.5,
    this.isHit = false,
    this.hasTriggeredParticles = false,
    this.hasMissed = false,
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
  final int octaveShift;
  final int startKeyPosition;
  final int visibleWhiteKeysCount;
  final bool showNoteNames;
  final String noteLabelMode; // 'scientific', 'solfege', 'off'
  final bool isLessonMode;
  final bool isAutoGuideMode;
  final double noteSpeed;
  final Function(String keyName, String label)? onNotePressed;
  final Function(String keyName, bool isPerfect)? onNoteHit;
  final VoidCallback? onNoteMissed;

  const PianoView({
    super.key,
    this.startOctave = 4,
    this.octaveShift = 0,
    this.startKeyPosition = 0,
    this.visibleWhiteKeysCount = 14,
    this.showNoteNames = true,
    this.noteLabelMode = 'scientific',
    this.isLessonMode = false,
    this.isAutoGuideMode = false,
    this.noteSpeed = 7.5,
    this.externalActiveKeys,
    this.onNotePressed,
    this.onNoteHit,
    this.onNoteMissed,
  });

  final Set<String>? externalActiveKeys;

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

  double _currentScrollX = 0.0;
  double _targetScrollX = 0.0;
  bool _isFirstLayout = true;

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

  void addFallingNote(String keyName, String label, bool isBlack, {int durationMs = 300}) {
    if (_keys.isEmpty) return;

    int visibleOctave = (widget.startOctave + widget.octaveShift).clamp(1, 7);

    PianoKey? matchingKey = _keys
        .cast<PianoKey?>()
        .firstWhere((k) => k?.keyName == keyName, orElse: () => null);

    final double whiteKeyWidth = _keys.isNotEmpty ? _keys.first.rect.width : 30.0;
    final double visibleMinX = _currentScrollX + 5;
    final double visibleMaxX =
        _currentScrollX + (widget.visibleWhiteKeysCount * whiteKeyWidth) - 5;

    if (matchingKey != null) {
      final double keyX = matchingKey.rect.center.dx;

      if (keyX < visibleMinX ||
          keyX > visibleMaxX ||
          (matchingKey.isBlack &&
              (matchingKey.rect.left < _currentScrollX - 0.5 ||
                  matchingKey.rect.right >
                      _currentScrollX +
                          (widget.visibleWhiteKeysCount * whiteKeyWidth) +
                          0.5))) {
        String keyType = keyName.startsWith("w") ? "w" : "b";
        int posDigit = int.tryParse(keyName.substring(keyName.length - 1)) ?? 0;
        matchingKey = _keys.cast<PianoKey?>().firstWhere(
              (k) =>
                  k?.keyName == "$keyType$visibleOctave$posDigit" &&
                  (!k!.isBlack ||
                      (k.rect.left >= _currentScrollX - 0.5 &&
                          k.rect.right <=
                              _currentScrollX +
                                  (widget.visibleWhiteKeysCount *
                                      whiteKeyWidth) +
                                  0.5)),
              orElse: () => null,
            );
        matchingKey ??= _keys.cast<PianoKey?>().firstWhere(
              (k) =>
                  !k!.isBlack &&
                  k.rect.center.dx >= visibleMinX &&
                  k.rect.center.dx <= visibleMaxX,
              orElse: () => null,
            );
      }
    }

    if (matchingKey == null) {
      String keyType = keyName.startsWith("w") ? "w" : "b";
      int posDigit = int.tryParse(keyName.substring(keyName.length - 1)) ?? 0;
      matchingKey = _keys.cast<PianoKey?>().firstWhere(
            (k) => k?.keyName == "$keyType$visibleOctave$posDigit",
            orElse: () => null,
          );
      matchingKey ??= _keys.cast<PianoKey?>().firstWhere(
            (k) => k?.keyName == "$keyType${visibleOctave + 1}$posDigit",
            orElse: () => null,
          );
    }

    matchingKey ??= _keys.cast<PianoKey?>().firstWhere(
          (k) => k?.isBlack == isBlack,
          orElse: () => null,
        );
    matchingKey ??= _keys.isNotEmpty ? _keys.first : null;

    if (matchingKey == null) return;

    setState(() {
      _fallingNotes.add(FallingNote(
        keyName: matchingKey!.keyName,
        originalKeyName: keyName,
        label: label,
        targetX: matchingKey.rect.center.dx,
        keyTopY: matchingKey.rect.top,
        keyWidth: matchingKey.rect.width,
        durationMs: durationMs,
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
      const Color(0xFFCF6BEE), // Theme purple spark
      const Color(0xFFE599FF), // Bright lavender spark
      const Color(0xFFFFFFFF), // Pure white spark
      const Color(0xFFFFD54F), // Amber gold spark
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

    // Smooth horizontal keyboard scrolling animation (lerp)
    if ((_currentScrollX - _targetScrollX).abs() > 0.1) {
      _currentScrollX += (_targetScrollX - _currentScrollX) * 0.22;
      needsRepaint = true;
    } else if (_currentScrollX != _targetScrollX) {
      _currentScrollX = _targetScrollX;
      needsRepaint = true;
    }

    // Update falling notes
    if (_fallingNotes.isNotEmpty) {
      for (int i = _fallingNotes.length - 1; i >= 0; i--) {
        final note = _fallingNotes[i];
        note.currentY += note.speed;
        needsRepaint = true;

        // If note was hit by user tap, remove it immediately!
        if (note.isHit) {
          _fallingNotes.removeAt(i);
          continue;
        }

        // Trigger particle fireworks right when the note reaches key top Y line!
        if (note.currentY >= note.keyTopY) {
          if (!note.hasTriggeredParticles) {
            note.hasTriggeredParticles = true;
            _spawnHitParticles(note.targetX, note.keyTopY);

            // Auto-Play Guide Mode: Automatically trigger audio, key light & score!
            if (widget.isAutoGuideMode) {
              AudioEngine().playNote(note.originalKeyName);
              _activeKeyNames.add(note.keyName);
              int sustainMs = (note.durationMs > 0) ? note.durationMs : 250;
              Future.delayed(Duration(milliseconds: sustainMs), () {
                if (mounted) {
                  _activeKeyNames.remove(note.keyName);
                  AudioEngine().stopNote(note.originalKeyName);
                  setState(() {});
                }
              });

              if (widget.onNotePressed != null) {
                widget.onNotePressed!(note.keyName, note.label);
              }
            } else if (widget.isLessonMode && !note.hasMissed) {
              // Missed note (reached keyboard top line without user hitting it)
              note.hasMissed = true;
              widget.onNoteMissed?.call();
            }
          }

          // Disappear immediately upon hitting top line of piano!
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

    final double keyboardTop = widget.isLessonMode ? height * 0.55 : 0.0;
    final double keyboardHeight = height - keyboardTop;
    final double blackKeyHeight = keyboardHeight * 0.62;

    final List<PianoKey> whiteKeysList = [];
    final List<PianoKey> blackKeysList = [];

    for (int octave = 1; octave <= 7; octave++) {
      for (int pos = 0; pos < 7; pos++) {
        int globalWhiteIndex = (octave - 1) * 7 + pos;
        double left = globalWhiteIndex * whiteKeyWidth;
        double right = left + whiteKeyWidth;
        String keyName = "w$octave$pos";
        String label = "${_noteNamesWhite[pos]}$octave";

        var key = PianoKey(
          keyName: keyName,
          label: label,
          isBlack: false,
          rect: Rect.fromLTRB(left, keyboardTop, right, height),
        );
        whiteKeysList.add(key);

        int? bIndex = _getBlackKeyAudioIndex(pos);
        if (bIndex != null) {
          double bLeft = right - (blackKeyWidth / 2.0);
          double bRight = bLeft + blackKeyWidth;
          String bKeyName = "b$octave$bIndex";
          String bLabel = "${_noteNamesBlack[pos]}$octave";

          var bKey = PianoKey(
            keyName: bKeyName,
            label: bLabel,
            isBlack: true,
            rect: Rect.fromLTRB(
                bLeft, keyboardTop, bRight, keyboardTop + blackKeyHeight),
          );
          blackKeysList.add(bKey);
        }
      }
    }

    _keys.addAll(whiteKeysList);
    _keys.addAll(blackKeysList);

    final double maxScrollX =
        (49 - widget.visibleWhiteKeysCount) * whiteKeyWidth;
    final int targetOctave = (widget.startOctave + widget.octaveShift).clamp(1, 7);
    final int startPos = widget.startKeyPosition.clamp(0, 6);
    final int startGlobalWhiteIndex = (targetOctave - 1) * 7 + startPos;
    _targetScrollX = (startGlobalWhiteIndex * whiteKeyWidth)
        .clamp(0.0, maxScrollX < 0 ? 0.0 : maxScrollX);

    if (_isFirstLayout) {
      _currentScrollX = _targetScrollX;
      _isFirstLayout = false;
    }
  }

  PianoKey? _getKeyAt(Offset position) {
    final Offset worldPos = Offset(position.dx + _currentScrollX, position.dy);
    final double whiteKeyWidth = _keys.isNotEmpty ? _keys.first.rect.width : 30.0;
    final double visibleLeft = _currentScrollX;
    final double visibleRight =
        _currentScrollX + (widget.visibleWhiteKeysCount * whiteKeyWidth);

    for (var key in _keys.where((k) => k.isBlack)) {
      if (key.rect.left >= visibleLeft - 0.5 &&
          key.rect.right <= visibleRight + 0.5) {
        if (key.rect.contains(worldPos)) {
          return key;
        }
      }
    }
    for (var key in _keys.where((k) => !k.isBlack)) {
      if (key.rect.contains(worldPos)) {
        return key;
      }
    }
    return null;
  }

  void _handleTouch(int pointerId, Offset position) {
    PianoKey? key = _getKeyAt(position);
    String? currentActiveKey = _pointerToKeyMap[pointerId];

    if (key != null) {
      if (currentActiveKey != key.keyName) {
        if (currentActiveKey != null) {
          _activeKeyNames.remove(currentActiveKey);
          AudioEngine().stopNote(currentActiveKey);
        }
        _pointerToKeyMap[pointerId] = key.keyName;
        _activeKeyNames.add(key.keyName);
        AudioEngine().playNote(key.keyName);

        if (widget.onNotePressed != null) {
          widget.onNotePressed!(key.keyName, key.label);
        }

        if (widget.isLessonMode && !widget.isAutoGuideMode) {
          FallingNote? matchingNote;
          for (var fn in _fallingNotes) {
            if ((fn.keyName == key.keyName || fn.originalKeyName == key.keyName) && !fn.isHit && !fn.hasMissed) {
              double diff = (fn.currentY - fn.keyTopY).abs();
              if (diff <= 65) {
                matchingNote = fn;
                break;
              }
            }
          }

          if (matchingNote != null) {
            matchingNote.isHit = true;
            matchingNote.hasTriggeredParticles = true;
            _spawnHitParticles(matchingNote.targetX, matchingNote.keyTopY);
            double diff = (matchingNote.currentY - matchingNote.keyTopY).abs();
            bool isPerfect = diff <= 30;
            widget.onNoteHit?.call(key.keyName, isPerfect);
          } else {
            // Tapped wrong key or no note is near -> Miss!
            widget.onNoteMissed?.call();
          }
        }
      }
    } else {
      if (currentActiveKey != null) {
        _pointerToKeyMap.remove(pointerId);
        _activeKeyNames.remove(currentActiveKey);
        AudioEngine().stopNote(currentActiveKey);
      }
    }
    setState(() {});
  }

  void _handleTouchUp(int pointerId) {
    String? activeKey = _pointerToKeyMap.remove(pointerId);
    if (activeKey != null) {
      _activeKeyNames.remove(activeKey);
      AudioEngine().stopNote(activeKey);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        Size size = Size(constraints.maxWidth, constraints.maxHeight);
        _calculateLayout(size);

        return Listener(
          onPointerDown: (event) =>
              _handleTouch(event.pointer, event.localPosition),
          onPointerMove: (event) =>
              _handleTouch(event.pointer, event.localPosition),
          onPointerUp: (event) => _handleTouchUp(event.pointer),
          onPointerCancel: (event) => _handleTouchUp(event.pointer),
          child: ClipRect(
            child: CustomPaint(
              size: size,
              painter: PianoPainter(
                keys: _keys,
                activeKeyNames: _activeKeyNames,
                externalActiveKeys: widget.externalActiveKeys,
                fallingNotes: _fallingNotes,
                particles: _particles,
                showNoteNames: widget.showNoteNames,
                noteLabelMode: widget.noteLabelMode,
                scrollX: _currentScrollX,
              ),
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
  final Set<String>? externalActiveKeys;
  final List<FallingNote> fallingNotes;
  final List<HitParticle> particles;
  final bool showNoteNames;
  final String noteLabelMode;
  final double scrollX;

  PianoPainter({
    required this.keys,
    required this.activeKeyNames,
    this.externalActiveKeys,
    required this.fallingNotes,
    required this.particles,
    required this.showNoteNames,
    required this.noteLabelMode,
    required this.scrollX,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(-scrollX, 0);
    final Paint whiteKeyPaint = Paint()..color = const Color(0x22FFFFFF);
    final Paint whiteBorderPaint = Paint()
      ..color = const Color(0x66000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final Paint blackKeyPaint = Paint()..color = const Color(0xEC121218);   

    // Draw White Piano Keys
    for (var key in keys.where((k) => !k.isBlack)) {
      final isPressed = (externalActiveKeys?.contains(key.keyName) ?? false) ||
          activeKeyNames.contains(key.keyName);
      final Paint paint;
      if (isPressed) {
        paint = Paint()
          ..shader =  LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xDDE599FF),
              const Color(0xDDCF6BEE),
              const Color(0xDD7E26D4),
            ],
          ).createShader(key.rect);
      } else {
        paint = whiteKeyPaint;
      }

      final RRect rrect = RRect.fromRectAndCorners(
        key.rect,
        bottomLeft: const Radius.circular(4),
        bottomRight: const Radius.circular(4),
      );
      canvas.drawRRect(rrect, paint);
      canvas.drawRRect(rrect, whiteBorderPaint);

      if (isPressed) {
        final Paint pressedGlowBorder = Paint()
          ..color = const Color(0xFFE599FF).withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawRRect(rrect, pressedGlowBorder);
      }

      if (showNoteNames && noteLabelMode != 'off') {
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
        double pillWidth = (key.rect.width * 0.72).clamp(24.0, 44.0);
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

        String displayText = key.label;
        if (noteLabelMode == 'solfege') {
          displayText = displayText
              .replaceAll('C', 'Do')
              .replaceAll('D', 'Re')
              .replaceAll('E', 'Mi')
              .replaceAll('F', 'Fa')
              .replaceAll('G', 'Sol')
              .replaceAll('A', 'La')
              .replaceAll('B', 'Si');
        }

        TextPainter tp = TextPainter(
          text: TextSpan(
            text: displayText,
            style: AppTextStyles.textWhite12.copyWith(
              fontSize: 10,
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
    final double visibleLeft = scrollX;
    final double visibleRight = scrollX + size.width;

    for (var key in keys.where((k) => k.isBlack)) {
      if (key.rect.left < visibleLeft - 0.5 || key.rect.right > visibleRight + 0.5) {
        continue;
      }

      final isPressed = (externalActiveKeys?.contains(key.keyName) ?? false) ||
          activeKeyNames.contains(key.keyName);
      final Paint paint;
      if (isPressed) {
        paint = Paint()
          ..shader =  LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xDDE599FF),
              const Color(0xDDCF6BEE),
              const Color(0xDD7E26D4),
            ],
          ).createShader(key.rect);
      } else {
        paint = blackKeyPaint;
      }

      final RRect rrect = RRect.fromRectAndCorners(
        key.rect,
        bottomLeft: const Radius.circular(5),
        bottomRight: const Radius.circular(5),
      );
      canvas.drawRRect(rrect, paint);

      if (isPressed) {
        final Paint pressedGlowBorder = Paint()
          ..color = const Color(0xFFE599FF).withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawRRect(rrect, pressedGlowBorder);
      }

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

    // Draw Purple Synthesia Falling Tiles (Bars with Outer Glow)
    final double keyboardTop = keys.isNotEmpty ? keys.first.rect.top : size.height * 0.48;
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(-scrollX, 0, size.width + scrollX * 2, keyboardTop));

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

      // Outer Glow Effect (Purple)
      Paint glowPaint = Paint()
        ..color = const Color(0xFFB158F0).withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawRRect(roundedBar, glowPaint);

      // Purple Gradient Tile Body
      Paint tilePaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE599FF), // Bright lavender purple top
            Color(0xFFB158F0), // Vibrant purple
            Color(0xFF7E26D4), // Deep purple bottom
          ],
        ).createShader(barRect);

      canvas.drawRRect(roundedBar, tilePaint);

      // Inner Highlight Rim
      Paint borderPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawRRect(roundedBar, borderPaint);  

      // Note Name Label (Remove numbers/digits from label)
      final cleanLabel = note.label.replaceAll(RegExp(r'[0-9]'), '');
      if (showNoteNames && cleanLabel.isNotEmpty) {
        TextPainter tp = TextPainter(
          text: TextSpan(
            text: cleanLabel,
            style: AppTextStyles.textWhite12.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(
          canvas,
          Offset(barRect.center.dx - tp.width / 2,
              barRect.center.dy - tp.height / 2),
        );
      }
    }
    canvas.restore();

    // Draw Fireworks Particle Sparks
    for (var particle in particles) {
      final Paint pPaint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity);
      canvas.drawCircle(Offset(particle.x, particle.y), particle.radius, pPaint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PianoPainter oldDelegate) => true;
}
