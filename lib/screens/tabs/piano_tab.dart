import 'package:flutter/material.dart';
import '../../audio/audio_engine.dart';
import '../play_piano_screen.dart';

class PianoTab extends StatefulWidget {
  const PianoTab({super.key});

  @override
  State<PianoTab> createState() => _PianoTabState();
}

class _PianoTabState extends State<PianoTab> {
  void _openPianoWithInstrument(
      BuildContext context, String instrumentFolder) async {
    await AudioEngine().loadInstrument(instrumentFolder);
    setState(() {});
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PlayPianoScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentFolder = AudioEngine().currentInstrument;

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
          final isSelected = inst["folder"] == currentFolder;

          return GestureDetector(
            onTap: () => _openPianoWithInstrument(context, inst["folder"]!),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? Colors.greenAccent : Colors.white10,
                  width: isSelected ? 2 : 1,
                ),
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
                      color: Colors.amber.withOpacity(0.2),
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
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.greenAccent
                          : const Color(0xFF6B21A8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isSelected ? "SELECTED" : "SELECT",
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
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
