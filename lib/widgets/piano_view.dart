import 'package:flutter/material.dart';

import '../audio/audio_engine.dart';

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
  double currentY;
  double speed;
  bool isHit;

  FallingNote({
    required this.keyName,
    required this.label,
    required this.targetX,
    required this.keyTopY,
    this.currentY = 0.0,
    this.speed = 0.5,
    this.isHit = false,
  });
}

class PianoView extends StatefulWidget {
  final int startOctave;
  final int visibleWhiteKeysCount;
  final bool showNoteNames;
  final bool isLessonMode;
  final Function(String keyName, String label)? onNotePressed;

  const PianoView({
    super.key,
    this.startOctave = 4,
    this.visibleWhiteKeysCount = 14,
    this.showNoteNames = true,
    this.isLessonMode = false,
    this.onNotePressed,
  });

  @override
  State<PianoView> createState() => PianoViewState();
}

class PianoViewState extends State<PianoView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final List<PianoKey> _keys = [];
  final Set<String> _activeKeyNames = {};
  final List<FallingNote> _fallingNotes = [];
  final Map<int, String> _pointerToKeyMap = {};

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
      _updateFallingNotes();
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
        currentY: 0.0,
        speed: 7.5,
      ));
    });
  }

  void clearFallingNotes() {
    setState(() {
      _fallingNotes.clear();
    });
  }

  void _updateFallingNotes() {
    if (_fallingNotes.isEmpty) return;
    bool needsRepaint = false;

    for (int i = _fallingNotes.length - 1; i >= 0; i--) {
      _fallingNotes[i].currentY += _fallingNotes[i].speed;
      needsRepaint = true;
      // Allow notes to float lower down onto the key head surface (keyTopY + 50)
      if (_fallingNotes[i].currentY > _fallingNotes[i].keyTopY + 50) {
        _fallingNotes.removeAt(i);
      }
    }

    if (needsRepaint && mounted) {
      setState(() {});
    }
  }

  void _calculateLayout(Size size) {
    _keys.clear();
    final double width = size.width;
    final double height = size.height;

    final double whiteKeyWidth = width / widget.visibleWhiteKeysCount;
    final double blackKeyWidth = whiteKeyWidth * 0.60;

    // Free Play mode keyboard takes 100% of height; Lesson mode leaves top 48% for falling notes channel
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

        if (i != 2 && i != 6) {
          double bLeft = right - (blackKeyWidth / 2.0);
          double bRight = bLeft + blackKeyWidth;
          String bKeyName = "b$oct$i";
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
      }
      if (currentKey != null) {
        _pointerToKeyMap[event.pointer] = currentKey.keyName;
        if (_activeKeyNames.add(currentKey.keyName)) {
          AudioEngine().playNote(currentKey.keyName);
          widget.onNotePressed?.call(currentKey.keyName, currentKey.label);
          _checkNoteHit(currentKey.keyName);
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
      setState(() {});
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    String? releasedKey = _pointerToKeyMap.remove(event.pointer);
    if (releasedKey != null) {
      _activeKeyNames.remove(releasedKey);
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
  final bool showNoteNames;

  PianoPainter({
    required this.keys,
    required this.activeKeyNames,
    required this.fallingNotes,
    required this.showNoteNames,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint whiteKeyPaint = Paint()..color = const Color(0xFFF9F9FB);
    final Paint whiteBorderPaint = Paint()
      ..color = const Color(0xFFD0D0D5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final Paint blackKeyPaint = Paint()..color = const Color(0xFF1E1E24);
    final Paint pressedKeyPaint = Paint()..color = const Color(0xFF4CAF50);
    final Paint noteBubblePaint = Paint()..color = const Color(0xFFFFA726);

    // 1. Draw White Keys
    for (var key in keys.where((k) => !k.isBlack)) {
      final isPressed = activeKeyNames.contains(key.keyName);
      final paint = isPressed ? pressedKeyPaint : whiteKeyPaint;

      final RRect rrect = RRect.fromRectAndCorners(
        key.rect,
        bottomLeft: const Radius.circular(4),
        bottomRight: const Radius.circular(4),
      );
      canvas.drawRRect(rrect, paint);
      canvas.drawRRect(rrect, whiteBorderPaint);

      // Note Badges matching screenshot exactly
      if (showNoteNames) {
        int oct = int.tryParse(key.label.substring(key.label.length - 1)) ?? 4;
        Color pillColor;
        switch (oct) {
          case 3:
            pillColor = const Color(0xFFA8E063); // Light lime green (A3, B3)
            break;
          case 4:
            pillColor = const Color(0xFF80E2B7); // Mint green (C4..B4)
            break;
          case 5:
            pillColor = const Color(0xFF80D8FF); // Sky blue (C5, D5)
            break;
          default:
            pillColor = const Color(0xFFCE93D8);
        }

        double centerX = key.rect.center.dx;
        double pillWidth = (key.rect.width * 0.65).clamp(24.0, 42.0);
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
              color: Color(0xFF1B3828),
              fontSize: 12,
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

    // 2. Draw Black Keys with 3D Gloss Sheen (matching user's screenshot)
    for (var key in keys.where((k) => k.isBlack)) {
      final isPressed = activeKeyNames.contains(key.keyName);
      final paint = isPressed ? pressedKeyPaint : blackKeyPaint;

      final RRect rrect = RRect.fromRectAndCorners(
        key.rect,
        bottomLeft: const Radius.circular(5),
        bottomRight: const Radius.circular(5),
      );
      canvas.drawRRect(rrect, paint);

      if (!isPressed) {
        // Subtle 3D Gloss Highlight Sheen matching the original piano key screenshot
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

    // 3. Draw Waterfall Falling Notes
    for (var note in fallingNotes) {
      canvas.drawCircle(
          Offset(note.targetX, note.currentY), 26, noteBubblePaint);

      TextPainter tp = TextPainter(
        text: const TextSpan(
          text: "🎵",
          style: TextStyle(fontSize: 20),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas,
          Offset(note.targetX - tp.width / 2, note.currentY - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant PianoPainter oldDelegate) {
    return true;
  }
}
