import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/tutor_document_model.dart';
import '../../../controllers/profile_controller.dart';
import 'verification_badge.dart';

class DocumentTile extends StatelessWidget {
  final TutorDocumentModel document;

  const DocumentTile({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.description_outlined,
                  color: AppColors.primaryBlue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(document.label, style: AppTextStyles.bodySemiBold),
                    const SizedBox(height: 2),
                    Text(
                      _requirementLabel(document.requirement),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => _pickAndUpload(context),
                child: Text(
                  document.fileUrl == null ? 'Upload' : 'Ganti',
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              VerificationBadge(status: document.status),
              if (document.fileUrl != null) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.check_circle,
                  size: 14,
                  color: AppColors.onlineGreen,
                ),
                const SizedBox(width: 4),
                Text('File tersedia', style: AppTextStyles.caption),
              ],
            ],
          ),
          if (document.rejectionNote != null &&
              document.rejectionNote!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 14,
                    color: AppColors.primaryRed,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      document.rejectionNote!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickAndUpload(BuildContext context) async {
    // v10: pickFiles() langsung return List<PlatformFile>?
    final pickedFiles = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (pickedFiles == null || pickedFiles.isEmpty) return;
    final picked = pickedFiles.single;

    // v10: bytes tidak otomatis di-load, harus baca manual
    final bytes = await picked.readAsBytes();

    // Validasi ukuran pakai bytes.length (bukan picked.size)
    const maxSize = 5 * 1024 * 1024;
    if (bytes.length > maxSize) {
      Get.snackbar(
        'File Terlalu Besar',
        'Ukuran file maksimal 5MB. File kamu ${(bytes.length / 1024 / 1024).toStringAsFixed(2)}MB.',
      );
      return;
    }

    if (bytes.isEmpty) {
      Get.snackbar('Gagal', 'Tidak bisa membaca file.');
      return;
    }

    // Preview + konfirmasi
    if (!context.mounted) return;
    _showConfirmDialog(
      context,
      fileName: picked.name,
      fileSize: bytes.length, // pakai bytes.length
      onConfirm: () async {
        final ctrl = Get.find<ProfileController>();
        await ctrl.uploadDocument(
          documentId: document.id,
          jenisDokumen: document.type,
          filePath: picked.path ?? '',
          fileName: picked.name,
          fileBytes: bytes,
        );
      },
    );
  }

  void _showConfirmDialog(
    BuildContext context, {
    required String fileName,
    required int fileSize,
    required Future<void> Function() onConfirm,
  }) {
    final sizeMb = (fileSize / 1024 / 1024).toStringAsFixed(2);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Upload'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('File:', style: AppTextStyles.caption),
            Text(
              fileName,
              style: AppTextStyles.bodySemiBold,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text('Ukuran: $sizeMb MB', style: AppTextStyles.caption),
            const SizedBox(height: 12),
            Text(
              'File akan diunggah dan menunggu verifikasi Admin.',
              style: AppTextStyles.caption,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Get.back();
              await onConfirm();
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  String _requirementLabel(DocumentRequirement r) {
    switch (r) {
      case DocumentRequirement.required:
        return 'Wajib';
      case DocumentRequirement.conditional:
        return 'Bersyarat';
      case DocumentRequirement.optional:
        return 'Opsional';
      case DocumentRequirement.unclassified:
        return 'Klasifikasi menunggu konfirmasi';
    }
  }
}
