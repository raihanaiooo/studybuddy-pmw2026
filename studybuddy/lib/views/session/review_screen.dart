import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/review_controller.dart';
import '../../controllers/session_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// Screen rating & review setelah sesi selesai
class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _commentCtrl = TextEditingController();
  int _rating = 0;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ReviewController>();
    final session = Get.find<SessionController>().currentSession.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.blueDark,
        foregroundColor: Colors.white,
        title: Text(
          'Beri Ulasan',
          style: AppTextStyles.heading3.copyWith(
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text('🎉', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              'Sesi Selesai!',
              style: AppTextStyles.heading1.copyWith(fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 8),
            Text(
              'Bagaimana pengalaman belajar kamu?',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 32),

            // Star rating
            Text('Beri Rating', style: AppTextStyles.heading3),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (i) => GestureDetector(
                  onTap: () => setState(() => _rating = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      i < _rating ? Icons.star : Icons.star_border,
                      color: AppColors.primaryYellow,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Comment
            TextField(
              controller: _commentCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Ceritakan pengalaman belajarmu bersama tutor ini...',
                hintStyle: AppTextStyles.caption,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.primaryBlue,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 28),

            // Submit
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: ctrl.isSubmitting.value || _rating == 0
                      ? null
                      : () {
                          if (session == null) return;
                          ctrl.submitReview(
                            sessionId: session.id,
                            tutorId: '', // isi dari session/booking
                            rating: _rating,
                            comment: _commentCtrl.text,
                            subject: '',
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: ctrl.isSubmitting.value
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : const Text(
                          'Kirim Ulasan',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 12),
            // Skip
            TextButton(
              onPressed: () => Get.find<ReviewController>().submitReview(
                sessionId: session?.id ?? '',
                tutorId: '',
                rating: 1,
                comment: 'Tidak ada ulasan',
                subject: '',
              ),
              child: Text(
                'Lewati',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
