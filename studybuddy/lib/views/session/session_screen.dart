import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/session_controller.dart';
import '../../models/booking_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// Screen sesi belajar: timer chat atau launch Google Meet
class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  @override
  void initState() {
    super.initState();
    final booking = Get.arguments as BookingModel?;
    if (booking != null) {
      Get.find<SessionController>().startSession(
        booking.id,
        booking.sessionType == 'video' ? null : null, // GMeet link dari tutor
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SessionController>();
    final booking = Get.arguments as BookingModel?;
    final isChat = booking?.sessionType == 'chat';

    return Scaffold(
      backgroundColor: AppColors.blueDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon sesi
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isChat ? Icons.chat_bubble_outline : Icons.videocam_outlined,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Sesi Sedang Berlangsung',
                style: AppTextStyles.heading2.copyWith(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                booking?.subject ?? '',
                style: AppTextStyles.caption.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 40),

              // Timer (untuk sesi chat)
              if (isChat)
                Obx(
                  () => Text(
                    ctrl.timerFormatted,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 52,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),

              if (!isChat)
                Column(
                  children: [
                    const Icon(
                      Icons.open_in_new,
                      color: Colors.white70,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Google Meet sudah terbuka di browser',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

              const SizedBox(height: 60),

              // End session button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _confirmEnd(ctrl),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Akhiri Sesi',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmEnd(SessionController ctrl) {
    Get.defaultDialog(
      title: 'Akhiri Sesi?',
      middleText: 'Kamu akan diminta memberikan ulasan setelah sesi berakhir.',
      textConfirm: 'Ya, Akhiri',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primaryRed,
      onConfirm: () {
        Get.back();
        ctrl.endSession();
      },
    );
  }
}
