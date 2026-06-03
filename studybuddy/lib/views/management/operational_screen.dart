import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/manajemen/operational_controller.dart';
import '../../mock/mock_data.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/utils/responsive_helper.dart';
import '../../shared/widgets/status_badge.dart';

/// Screen operasional: kelola semua booking, approve/cancel
class OperationalScreen extends StatelessWidget {
  const OperationalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(OperationalController());
    final isWide = ResponsiveHelper.isTablet(context) ||
        ResponsiveHelper.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.blueDark,
        foregroundColor: Colors.white,
        title: Text(
          'Kelola Booking',
          style: AppTextStyles.heading3.copyWith(
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: Get.back,
        ),
      ),
      body: ContentConstraint(
        child: Padding(
          padding: ResponsiveHelper.contentPadding(context),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildSummary(ctrl),
              const SizedBox(height: 16),
              _buildFilters(ctrl),
              const SizedBox(height: 12),
              Expanded(child: _buildList(ctrl, isWide)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(OperationalController ctrl) {
    return Obx(() {
      final total = ctrl.bookings.length;
      final pending = ctrl.bookings.where((b) => b.status == 'pending').length;
      final confirmed =
          ctrl.bookings.where((b) => b.status == 'confirmed').length;
      final cancelled =
          ctrl.bookings.where((b) => b.status == 'cancelled').length;
      final done = ctrl.bookings.where((b) => b.status == 'done').length;

      return Row(
        children: [
          _summaryCard('Total', total, AppColors.primaryBlue),
          const SizedBox(width: 8),
          _summaryCard('Pending', pending, AppColors.primaryYellow),
          const SizedBox(width: 8),
          _summaryCard('Confirmed', confirmed, AppColors.onlineGreen),
          const SizedBox(width: 8),
          _summaryCard('Done', done, AppColors.accentTeal),
          const SizedBox(width: 8),
          _summaryCard('Cancelled', cancelled, AppColors.primaryRed),
        ],
      );
    });
  }

  Widget _summaryCard(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha((0.08 * 255).round()),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(OperationalController ctrl) {
    final statuses = [
      {'key': '', 'label': 'Semua', 'icon': Icons.filter_list_rounded},
      {'key': 'pending', 'label': 'Pending', 'icon': Icons.schedule_rounded},
      {'key': 'confirmed', 'label': 'Confirmed', 'icon': Icons.check_circle_outline_rounded},
      {'key': 'done', 'label': 'Done', 'icon': Icons.done_all_rounded},
      {'key': 'cancelled', 'label': 'Cancelled', 'icon': Icons.cancel_outlined},
    ];

    return SizedBox(
      height: 38,
      child: Obx(() {
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: statuses.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final s = statuses[i];
            final selected = ctrl.filterStatus.value == s['key'];
            return GestureDetector(
              onTap: () => ctrl.filterStatus.value = s['key'] as String,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primaryBlue : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? AppColors.primaryBlue
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      s['icon'] as IconData,
                      size: 14,
                      color: selected ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      s['label'] as String,
                      style: AppTextStyles.bodySemiBold.copyWith(
                        fontSize: 12,
                        color: selected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildList(OperationalController ctrl, bool isWide) {
    return Obx(() {
      final items = ctrl.filtered;
      if (items.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.inbox_rounded, size: 48, color: AppColors.textLight),
              const SizedBox(height: 12),
              Text('Tidak ada booking', style: AppTextStyles.body.copyWith(color: AppColors.textLight)),
            ],
          ),
        );
      }

      if (isWide) {
        // Table layout for wide screens
        return _buildDataTable(items, ctrl);
      }

      // Card layout for mobile
      return ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _bookingCard(items[i], ctrl),
      );
    });
  }

  Widget _buildDataTable(List items, OperationalController ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Tutor')),
            DataColumn(label: Text('Customer')),
            DataColumn(label: Text('Mata Kuliah')),
            DataColumn(label: Text('Tanggal')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Aksi')),
          ],
          rows: items.map((b) {
            final tutor = mockTutors.firstWhere(
              (t) => t.id == b.tutorId,
              orElse: () => mockTutors.first,
            );
            return DataRow(
              cells: [
                DataCell(Text(b.id, style: AppTextStyles.caption)),
                DataCell(Text(tutor.fullName, style: AppTextStyles.bodySemiBold)),
                DataCell(Text(b.customerName ?? '-', style: AppTextStyles.body)),
                DataCell(Text(b.subject, style: AppTextStyles.body)),
                DataCell(Text(
                  DateFormat('dd MMM yyyy').format(b.sessionDate),
                  style: AppTextStyles.caption,
                )),
                DataCell(StatusBadge(status: b.status)),
                DataCell(_buildActions(b, ctrl, compact: true)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _bookingCard(dynamic b, OperationalController ctrl) {
    final tutor = mockTutors.firstWhere(
      (t) => t.id == b.tutorId,
      orElse: () => mockTutors.first,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: _statusColor(b.status),
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withAlpha((0.05 * 255).round()),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryBlue.withAlpha((0.1 * 255).round()),
                child: Text(
                  tutor.fullName[0],
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tutor.fullName, style: AppTextStyles.heading3),
                    Text(
                      '${b.customerName ?? "Customer"} • ${b.subject}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              StatusBadge(status: b.status),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textLight),
              const SizedBox(width: 6),
              Text(
                DateFormat('EEEE, dd MMM yyyy', 'id').format(b.sessionDate),
                style: AppTextStyles.caption,
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time_rounded, size: 14, color: AppColors.textLight),
              const SizedBox(width: 6),
              Text(
                '${b.startTime.substring(0, 5)} - ${b.endTime.substring(0, 5)}',
                style: AppTextStyles.caption,
              ),
              const Spacer(),
              if (b.sessionType == 'video')
                Icon(Icons.videocam_rounded, size: 16, color: AppColors.primaryBlue)
              else
                Icon(Icons.chat_rounded, size: 16, color: AppColors.accentTeal),
            ],
          ),
          const SizedBox(height: 10),
          _buildActions(b, ctrl),
        ],
      ),
    );
  }

  Widget _buildActions(dynamic b, OperationalController ctrl, {bool compact = false}) {
    if (b.status != 'pending') {
      return Text(
        '${b.durationMinutes} menit',
        style: AppTextStyles.caption.copyWith(fontSize: 11),
      );
    }

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check_circle_rounded, color: AppColors.onlineGreen, size: 20),
            onPressed: () => _confirmApprove(b.id, ctrl),
            tooltip: 'Approve',
          ),
          IconButton(
            icon: const Icon(Icons.cancel_rounded, color: AppColors.primaryRed, size: 20),
            onPressed: () => _confirmCancel(b.id, ctrl),
            tooltip: 'Cancel',
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _confirmCancel(b.id, ctrl),
            icon: const Icon(Icons.close_rounded, size: 16),
            label: const Text('Tolak'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryRed,
              side: const BorderSide(color: AppColors.primaryRed),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _confirmApprove(b.id, ctrl),
            icon: const Icon(Icons.check_rounded, size: 16),
            label: const Text('Setujui'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  void _confirmApprove(String id, OperationalController ctrl) {
    Get.defaultDialog(
      title: 'Konfirmasi',
      middleText: 'Setujui booking $id?',
      textConfirm: 'Ya',
      textCancel: 'Batal',
      onConfirm: () {
        ctrl.approveBooking(id);
        Get.back();
        Get.snackbar('Berhasil', 'Booking $id disetujui');
      },
    );
  }

  void _confirmCancel(String id, OperationalController ctrl) {
    Get.defaultDialog(
      title: 'Konfirmasi',
      middleText: 'Batalkan booking $id?',
      textConfirm: 'Ya',
      textCancel: 'Batal',
      onConfirm: () {
        ctrl.cancelBooking(id);
        Get.back();
        Get.snackbar('Dibatalkan', 'Booking $id dibatalkan');
      },
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.primaryYellow;
      case 'confirmed':
        return AppColors.primaryBlue;
      case 'done':
        return AppColors.onlineGreen;
      case 'cancelled':
        return AppColors.primaryRed;
      default:
        return AppColors.textLight;
    }
  }
}
