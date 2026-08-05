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
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
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
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Section Title: "More Instruments"
            Text(
              "More Instruments",
              style: AppTextStyles.textWhite18,
            ),
            SizedBox(height: 8.h),
            // 2x2 Grid of Instruments
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 14.w,
              mainAxisSpacing: 14.h,
              childAspectRatio: 182.sp / 220.sp,
              children: [
                // 1. ORGAN
                _buildInstrumentCard(
                  context: context,
                  ref: ref,
                  title: "ORGAN",
                  subtitle: "Classic organ sounds",
                  folder: "organ_v2",
                  bgImageAsset: 'assets/images/img_organ.png',
                ),

                // 2. SYNTH
                _buildInstrumentCard(
                  context: context,
                  ref: ref,
                  title: "SYNTH",
                  subtitle: "Modern synth tones",
                  folder: "synth",
                  bgImageAsset: 'assets/images/img_synth.png',
                ),

                // 3. ROHDES
                _buildInstrumentCard(
                  context: context,
                  ref: ref,
                  title: "ROHDES",
                  subtitle: "Smooth electric piano",
                  folder: "rhodes",
                  bgImageAsset: 'assets/images/img_rohdes.png',
                ),

                // 4. BRIGHT
                _buildInstrumentCard(
                  context: context,
                  ref: ref,
                  title: "BRIGHT",
                  subtitle: "Bright piano sound",
                  folder: "bright",
                  bgImageAsset: 'assets/images/img_bright.png',
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
    required String bgImageAsset,
  }) {
    return GestureDetector(
      onTap: () => _openPianoWithInstrument(context, ref, folder),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF141126),
              Color(0xFF0F0F1E),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.10),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Instrument Image
              Image.asset(
                bgImageAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),

              // Title & Subtitle overlay at top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.45),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
