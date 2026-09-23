import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/tutor_document_model.dart';
import 'verification_badge.dart';

class DocumentTile extends StatelessWidget {
  final TutorDocumentModel document;
  final VoidCallback onUpload;

  const DocumentTile({
    super.key,
    required this.document,
    required this.onUpload,
  });

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
                onPressed: onUpload,
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
                Icon(
                  Icons.check_circle,
                  size: 14,
                  color: AppColors.onlineGreen,
                ),
                const SizedBox(width: 4),
                Text('File tersedia', style: AppTextStyles.caption),
              ],
            ],
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
