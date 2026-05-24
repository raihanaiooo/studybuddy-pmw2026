import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/operational_controller.dart';
import '../../mock/mock_data.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class OperationalScreen extends StatelessWidget {
  const OperationalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(OperationalController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Operasional'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummary(ctrl),
            const SizedBox(height: 12),
            _buildFilters(ctrl),
            const SizedBox(height: 12),
            Expanded(child: _buildList(ctrl)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(OperationalController ctrl) {
    return Obx(() {
      final total = ctrl.bookings.length;
      final pending = ctrl.bookings.where((b) => b.status == 'pending').length;
      final confirmed = ctrl.bookings
          .where((b) => b.status == 'confirmed')
          .length;
      final cancelled = ctrl.bookings
          .where((b) => b.status == 'cancelled')
          .length;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statCard('Total', total.toString()),
          _statCard('Pending', pending.toString()),
          _statCard('Confirmed', confirmed.toString()),
          _statCard('Cancelled', cancelled.toString()),
        ],
      );
    });
  }

  Widget _statCard(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(value, style: AppTextStyles.heading3),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(OperationalController ctrl) {
    final statuses = ['', 'pending', 'confirmed', 'cancelled'];
    return Obx(() {
      return Row(
        children: statuses.map((s) {
          final selected = ctrl.filterStatus.value == s;
          final label = s.isEmpty ? 'All' : s[0].toUpperCase() + s.substring(1);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: selected,
              onSelected: (_) {
                ctrl.filterStatus.value = s;
              },
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildList(OperationalController ctrl) {
    return Obx(() {
      final items = ctrl.filtered;
      if (items.isEmpty) {
        return Center(child: Text('No bookings', style: AppTextStyles.body));
      }
      return ListView.separated(
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final b = items[i];
          final tutor = mockTutors.firstWhere(
            (t) => t.id == b.tutorId,
            orElse: () => mockTutors.first,
          );
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(child: Text(tutor.fullName.split(' ').first[0])),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tutor.fullName, style: AppTextStyles.heading3),
                        const SizedBox(height: 4),
                        Text(
                          '${b.subject} · ${DateFormat('dd MMM yyyy HH:mm').format(b.sessionTime)}',
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(height: 6),
                        Text('Status: ${b.status}', style: AppTextStyles.body),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      if (b.status == 'pending')
                        ElevatedButton(
                          onPressed: () {
                            Get.defaultDialog(
                              title: 'Konfirmasi',
                              middleText: 'Setujui booking ${b.id}?',
                              textConfirm: 'Ya',
                              textCancel: 'Batal',
                              onConfirm: () {
                                ctrl.approveBooking(b.id);
                                Get.back();
                                Get.snackbar(
                                  'Approved',
                                  'Booking ${b.id} approved',
                                );
                              },
                            );
                          },
                          child: const Text('Approve'),
                        ),
                      const SizedBox(height: 6),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        onPressed: () {
                          Get.defaultDialog(
                            title: 'Konfirmasi',
                            middleText: 'Batalkan booking ${b.id}?',
                            textConfirm: 'Ya',
                            textCancel: 'Batal',
                            onConfirm: () {
                              ctrl.cancelBooking(b.id);
                              Get.back();
                              Get.snackbar(
                                'Cancelled',
                                'Booking ${b.id} cancelled',
                              );
                            },
                          );
                        },
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
