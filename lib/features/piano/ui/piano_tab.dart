import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/audio_engine.dart';

import '../state/piano_provider.dart';

class PianoTab extends ConsumerWidget {
  const PianoTab({super.key});

  void _openPianoWithInstrument(
      BuildContext context, WidgetRef ref, String instrumentFolder) {
    ref.read(pianoSettingsProvider.notifier).setSoundPreset(instrumentFolder);
    AudioEngine().loadInstrument(instrumentFolder);
    context.push('/play');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Map<String, String>> instruments = [
      {
        "name": "Acoustic Piano",
        "folder": "bright",
        "icon": "🎹",
        "desc": "Classic rich piano tone"
      },
      {
        "name": "Organ",
        "folder": "organ_v2",
        "icon": "📻",
        "desc": "Vibrant electronic organ"
      },
      {
        "name": "Synth Piano",
        "folder": "synth",
        "icon": "⚡",
        "desc": "Modern synthesizer keyboard"
      },
      {
        "name": "Fender Rhodes",
        "folder": "rhodes",
        "icon": "🎷",
        "desc": "Smooth vintage electric piano"
      },
      {
        "name": "Bright Piano",
        "folder": "bright",
        "icon": "✨",
        "desc": "Clear crisp acoustic piano"
      },
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: instruments.length,
        itemBuilder: (context, index) {
          final inst = instruments[index];

          return GestureDetector(
            onTap: () =>
                _openPianoWithInstrument(context, ref, inst["folder"]!),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        inst["icon"]!,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          inst["name"]!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          inst["desc"]!,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B21A8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow_rounded,
                            color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          "PLAY",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
