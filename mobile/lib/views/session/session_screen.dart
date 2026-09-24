import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/session_controller.dart';
import '../../models/booking_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../app/routes.dart';

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
    if (booking == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar('Error', 'Booking tidak ditemukan');
        Get.back();
      });
      return;
    }
    if (booking.status != 'confirmed' && booking.status != 'ongoing') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Tidak Bisa Mulai',
          'Booking belum dikonfirmasi atau sudah selesai.',
        );
        Get.back();
      });
      return;
    }
    Get.find<SessionController>().startSession(booking, null);
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
          child: Obx(() {
            // Error state
            if (ctrl.errorMessage.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      ctrl.errorMessage.value,
                      style: AppTextStyles.body.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: Get.back,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Kembali'),
                    ),
                  ],
                ),
              );
            }

            // Loading state
            if (ctrl.currentSession.value == null) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Memulai sesi...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              );
            }

            // Session ready — UI normal
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isChat
                        ? Icons.chat_bubble_outline
                        : Icons.videocam_outlined,
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

                // Timer untuk sesi chat
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

                // Tombol buka Meet untuk sesi video
                if (!isChat)
                  Column(
                    children: [
                      Obx(() {
                        final hasLink =
                            ctrl.currentSession.value?.gmeetLink != null &&
                            ctrl.currentSession.value!.gmeetLink!.isNotEmpty;
                        if (!hasLink) {
                          return Column(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Colors.white70,
                                size: 24,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Link Google Meet belum tersedia.\nHubungi Tutor kamu.',
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          );
                        }
                        return SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: ctrl.openMeetLink,
                            icon: const Icon(
                              Icons.videocam_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: const Text(
                              'Buka Google Meet',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white54),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      Text(
                        'Sesi video sedang berlangsung',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => Get.toNamed(AppRoutes.chat),
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text(
                      'Buka Chat Sesi',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 60),

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
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
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
