import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/manajemen/tutor_approval_controller.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';

/// Screen approval tutor oleh manajemen
class TutorApprovalScreen extends StatelessWidget {
  const TutorApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TutorApprovalController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F3C),
        foregroundColor: Colors.white,
        title: Text(
          'Approval Tutor',
          style: AppTextStyles.heading3.copyWith(
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A1F3C), Color(0xFF2E3A6E)],
              ),
            ),
            child: Obx(() => Row(
              children: [
                _buildStatCard(
                  'Pending',
                  ctrl.pendingCount.toString(),
                  AppColors.primaryYellow,
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  'Disetujui',
                  ctrl.applications
                      .where((a) => a.status == 'approved')
                      .length
                      .toString(),
                  AppColors.onlineGreen,
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  'Ditolak',
                  ctrl.applications
                      .where((a) => a.status == 'rejected')
                      .length
                      .toString(),
                  AppColors.primaryRed,
                ),
              ],
            )),
          ),

          // Filter tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Obx(() => Row(
              children: [
                _buildFilterChip(ctrl, 'pending', 'Pending'),
                const SizedBox(width: 8),
                _buildFilterChip(ctrl, 'approved', 'Disetujui'),
                const SizedBox(width: 8),
                _buildFilterChip(ctrl, 'rejected', 'Ditolak'),
                const SizedBox(width: 8),
                _buildFilterChip(ctrl, 'all', 'Semua'),
              ],
            )),
          ),

          // Applications list
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryBlue),
                );
              }
              if (ctrl.filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('📋', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text(
                        'Tidak ada pendaftaran',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: ctrl.filtered.length,
                itemBuilder: (_, i) {
                  final app = ctrl.filtered[i];
                  return _buildApplicationCard(app, ctrl);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.heading2.copyWith(
                color: color,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: Colors.white60,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    TutorApprovalController ctrl,
    String status,
    String label,
  ) {
    final selected = ctrl.filterStatus.value == status;
    return GestureDetector(
      onTap: () => ctrl.filterStatus.value = status,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primaryBlue : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySemiBold.copyWith(
            fontSize: 12,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildApplicationCard(
    TutorApplication app,
    TutorApprovalController ctrl,
  ) {
    final isPending = app.status == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: _getStatusColor(app.status).withValues(alpha: 0.2),
                child: Text(
                  app.fullName[0],
                  style: AppTextStyles.heading3.copyWith(
                    color: _getStatusColor(app.status),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.fullName,
                      style: AppTextStyles.bodySemiBold.copyWith(fontSize: 15),
                    ),
                    Text(
                      '${app.university} · IPK ${app.gpa}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(app.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusLabel(app.status),
                  style: AppTextStyles.label.copyWith(
                    color: _getStatusColor(app.status),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Subjects
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: app.subjects
                .map(
                  (s) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      s,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),

          // Date
          Text(
            'Mendaftar: ${DateFormat('dd MMM yyyy').format(app.appliedAt)}',
            style: AppTextStyles.caption.copyWith(fontSize: 11),
          ),

          // Actions (only for pending)
          if (isPending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showRejectDialog(app, ctrl),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryRed,
                      side: const BorderSide(color: AppColors.primaryRed),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Tolak'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => _showApproveDialog(app, ctrl),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.onlineGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Setujui Tutor',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.onlineGreen;
      case 'rejected':
        return AppColors.primaryRed;
      default:
        return AppColors.primaryYellow;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return 'Pending';
    }
  }

  void _showApproveDialog(
    TutorApplication app,
    TutorApprovalController ctrl,
  ) {
    Get.defaultDialog(
      title: 'Setujui Tutor?',
      middleText:
          'Apakah kamu yakin ingin menyetujui ${app.fullName} sebagai tutor?',
      textConfirm: 'Ya, Setujui',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.onlineGreen,
      onConfirm: () {
        ctrl.approveApplication(app.id);
        Get.back();
      },
    );
  }

  void _showRejectDialog(
    TutorApplication app,
    TutorApprovalController ctrl,
  ) {
    Get.defaultDialog(
      title: 'Tolak Tutor?',
      middleText:
          'Apakah kamu yakin ingin menolak pendaftaran ${app.fullName}?',
      textConfirm: 'Ya, Tolak',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primaryRed,
      onConfirm: () {
        ctrl.rejectApplication(app.id);
        Get.back();
      },
    );
  }
}
