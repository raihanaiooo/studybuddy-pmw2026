import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/tutor_document_model.dart';
import 'verification_badge.dart';

/// Baris dokumen verifikasi Tutor: label, wajib/opsional, status, aksi upload
/// (FR-PROF-06/07/08/09)
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
      child: Row(
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
                Row(
                  children: [
                    Expanded(
                      child: Text(document.label, style: AppTextStyles.bodySemiBold),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(_requirementLabel(document.requirement), style: AppTextStyles.caption),
                const SizedBox(height: 6),
                VerificationBadge(status: document.status),
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
    }
  }
}
