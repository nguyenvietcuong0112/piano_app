import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/audio_engine.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/gradient_border_card.dart';
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
    return AppScaffold(
      horizontalPadding: 16.w,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(top: 12.h, bottom: 90.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GradientBorderCard(
              height: 155.h,
              borderRadius: 22,
              bgImageAsset: 'assets/images/img_acoustic_piano.png',
              imageFit: BoxFit.fill,
              onTap: () => _openPianoWithInstrument(context, ref, 'bright'),
              padding: EdgeInsets.all(18.r),
              child: Row(
                children: [
                  // Text Column
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "ACOUSTIC ",
                                style: AppTextStyles.textWhite20,
                              ),
                              TextSpan(
                                text: "PIANO",
                                style: AppTextStyles.textPurple20,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          "Learn Piano anywhere,\nanytime. Real keys, real feel.",
                          style: AppTextStyles.textGrey12.copyWith(height: 1.3),
                        ),
                        SizedBox(height: 14.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.r),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFB158F0), Color(0xFF7E26D4)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFB158F0).withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18.sp),
                              SizedBox(width: 4.w),
                              Text(
                                "Play Now",
                                style: AppTextStyles.textWhite12.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 22.h),

            // Section Title: "More Instruments"
            Text(
              "More Instruments",
              style: AppTextStyles.textWhite18,
            ),
            SizedBox(height: 12.h),

            // 2x2 Grid of Instruments
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 14.w,
              mainAxisSpacing: 14.h,
              childAspectRatio: 0.82,
              children: [
                // 1. ORGAN
                _buildInstrumentCard(
                  context: context,
                  ref: ref,
                  title: "ORGAN",
                  subtitle: "Classic organ sounds",
                  folder: "organ_v2",
                  gradientColors: const [Color(0xFF381552), Color(0xFF190E29)],
                  borderColor: const Color(0xFFB158F0),
                  iconData: Icons.speaker_rounded,
                ),

                // 2. SYNTH
                _buildInstrumentCard(
                  context: context,
                  ref: ref,
                  title: "SYNTH",
                  subtitle: "Modern synth tones",
                  folder: "synth",
                  gradientColors: const [Color(0xFF0C2B4E), Color(0xFF08172B)],
                  borderColor: const Color(0xFF29B6F6),
                  iconData: Icons.graphic_eq_rounded,
                ),

                // 3. ROHDES
                _buildInstrumentCard(
                  context: context,
                  ref: ref,
                  title: "ROHDES",
                  subtitle: "Smooth electric piano",
                  folder: "rhodes",
                  gradientColors: const [Color(0xFF0A3337), Color(0xFF061B1E)],
                  borderColor: const Color(0xFF26A69A),
                  iconData: Icons.album_rounded,
                ),

                // 4. BRIGHT
                _buildInstrumentCard(
                  context: context,
                  ref: ref,
                  title: "BRIGHT",
                  subtitle: "Bright piano sound",
                  folder: "bright",
                  gradientColors: const [Color(0xFF45220E), Color(0xFF201006)],
                  borderColor: const Color(0xFFFFA726),
                  iconData: Icons.auto_awesome_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstrumentCard({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required String folder,
    required List<Color> gradientColors,
    required Color borderColor,
    required IconData iconData,
  }) {
    return GestureDetector(
      onTap: () => _openPianoWithInstrument(context, ref, folder),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: borderColor.withValues(alpha: 0.35), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Stack(
            children: [
              // Instrument Visual Preview Container
              Positioned(
                bottom: -10.h,
                left: 0,
                right: 0,
                height: 110.h,
                child: Center(
                  child: Container(
                    width: 110.w,
                    height: 100.h,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(iconData, color: borderColor, size: 36.sp),
                        SizedBox(height: 8.h),
                        // Mini Piano keys graphic
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(6, (i) {
                            return Container(
                              width: 8.w,
                              height: 32.h,
                              margin: EdgeInsets.symmetric(horizontal: 1.w),
                              decoration: BoxDecoration(
                                color: (i == 1 || i == 4) ? Colors.black87 : Colors.white,
                                borderRadius: BorderRadius.vertical(bottom: Radius.circular(2.r)),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Title & Subtitle Top Padding
              Padding(
                padding: EdgeInsets.all(14.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.textWhite16.copyWith(fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: AppTextStyles.textGrey12,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
