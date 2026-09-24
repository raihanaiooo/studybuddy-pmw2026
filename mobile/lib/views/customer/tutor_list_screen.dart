import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/tutor_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../app/routes.dart';
import '../shared/widgets/customer_scaffold.dart';
import '../shared/widgets/tutor_card.dart';

class TutorListScreen extends StatelessWidget {
  const TutorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TutorController>();
    final onlineOnly =
        (Get.arguments as Map<String, dynamic>?)?['onlineOnly'] as bool? ??
        false;

    return CustomerScaffold(
      currentIndex: 1,
      appBar: AppBar(
        backgroundColor: AppColors.blueDark,
        foregroundColor: Colors.white,
        title: Text(
          onlineOnly ? '⚡ Tutor Online' : 'Cari Tutor',
          style: AppTextStyles.heading3.copyWith(
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: (v) => ctrl.searchQuery.value = v,
              decoration: InputDecoration(
                hintText: 'Cari tutor atau mata kuliah...',
                hintStyle: AppTextStyles.caption,
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textLight,
                  size: 20,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          _buildFilterSection(ctrl),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              final list = onlineOnly
                  ? ctrl.filtered.where((t) => t.isOnline).toList()
                  : ctrl.filtered;
              if (ctrl.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryBlue,
                  ),
                );
              }
              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔍', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text(
                        'Tidak ada tutor ditemukan',
                        style: AppTextStyles.bodySemiBold,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ctrl.hasActiveFilter
                            ? 'Coba ubah filter atau reset'
                            : 'Coba kata kunci lain',
                        style: AppTextStyles.caption,
                      ),
                      if (ctrl.hasActiveFilter) ...[
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: ctrl.resetFilters,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Reset Filter'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () => ctrl.fetchAllTutors(),
                color: AppColors.primaryBlue,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: list.length,
                  itemBuilder: (_, i) => TutorCard(
                    tutor: list[i],
                    onTap: () {
                      ctrl.selectTutor(list[i]);
                      Get.toNamed(AppRoutes.tutorDetail);
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(TutorController ctrl) {
    return Obx(() {
      final jenjang = ctrl.filterJenjang.value;
      final subject = ctrl.filterSubject.value;
      final hasFilter = ctrl.hasActiveFilter;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasFilter)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_alt_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Filter Aktif',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: ctrl.resetFilters,
                    child: Text(
                      'Reset',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryRed,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'Jenjang:',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _filterChip(
                  label: 'Semua',
                  selected: jenjang.isEmpty,
                  onTap: () => ctrl.setFilterJenjang(''),
                ),
                ...TutorController.jenjangOptions.map(
                  (j) => _filterChip(
                    label: j,
                    selected: jenjang == j,
                    onTap: () => ctrl.setFilterJenjang(j),
                  ),
                ),
              ],
            ),
          ),
          if (ctrl.subjectOptions.isNotEmpty) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'Mata Pelajaran:',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _filterChip(
                    label: 'Semua',
                    selected: subject.isEmpty,
                    onTap: () => ctrl.setFilterSubject(''),
                  ),
                  ...ctrl.subjectOptions.map(
                    (s) => _filterChip(
                      label: s,
                      selected: subject == s,
                      onTap: () => ctrl.setFilterSubject(s),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.primaryBlue : AppColors.border,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
