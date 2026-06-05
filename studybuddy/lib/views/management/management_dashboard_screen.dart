import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/manajemen/operational_controller.dart';
import '../../mock/mock_data.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/utils/responsive_helper.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../shared/widgets/status_badge.dart';
import '../../app/routes.dart';

/// Dashboard utama Manajemen dengan persistent bottom nav
class ManagementDashboardScreen extends StatefulWidget {
  const ManagementDashboardScreen({super.key});

  @override
  State<ManagementDashboardScreen> createState() =>
      _ManagementDashboardScreenState();
}

class _ManagementDashboardScreenState extends State<ManagementDashboardScreen> {
  int _navIndex = 0;

  final _navItems = const [
    BottomNavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
    BottomNavItem(icon: Icons.school_rounded, label: 'Tutor'),
    BottomNavItem(icon: Icons.people_rounded, label: 'Customer'),
    BottomNavItem(icon: Icons.assessment_rounded, label: 'Laporan'),
  ];

  void _onNavTap(int i) {
    setState(() => _navIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final stats = mockManagementStats;
    final isWide = ResponsiveHelper.isTablet(context) ||
        ResponsiveHelper.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          if (_navIndex == 0) _buildHeader(auth),
          Expanded(
            child: _buildContent(auth, stats, isWide),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _navIndex,
        onTap: _onNavTap,
        items: _navItems,
      ),
    );
  }

  Widget _buildContent(AuthController auth, Map<String, dynamic> stats, bool isWide) {
    switch (_navIndex) {
      case 0:
        return _buildDashboardTab(stats, isWide);
      case 1:
        return _buildBookingTab();
      case 2:
        return _buildTutorTab();
      case 3:
        return _buildProfileTab(auth);
      default:
        return _buildDashboardTab(stats, isWide);
    }
  }

  Widget _buildDashboardTab(Map<String, dynamic> stats, bool isWide) {
    return SingleChildScrollView(
      padding: ResponsiveHelper.contentPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildStatsGrid(stats)),
                const SizedBox(width: 20),
                Expanded(flex: 2, child: _buildQuickActions()),
              ],
            )
          else ...[
            _buildStatsGrid(stats),
            const SizedBox(height: 20),
            _buildQuickActions(),
          ],
          const SizedBox(height: 20),
          _buildOprecCard(),
          const SizedBox(height: 16),
          _buildSessionChart(),
          const SizedBox(height: 16),
          _buildApprovalSection(),
          const SizedBox(height: 20),
          _buildRecentActivity(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBookingTab() {
    final ctrl = Get.put(OperationalController());
    return Padding(
      padding: ResponsiveHelper.contentPadding(context),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Summary
          Obx(() {
            final total = ctrl.bookings.length;
            final pending = ctrl.bookings.where((b) => b.status == 'pending').length;
            final done = ctrl.bookings.where((b) => b.status == 'done').length;
            return Row(
              children: [
                _miniStat('Total', total, AppColors.primaryBlue),
                const SizedBox(width: 8),
                _miniStat('Pending', pending, AppColors.primaryYellow),
                const SizedBox(width: 8),
                _miniStat('Done', done, AppColors.onlineGreen),
              ],
            );
          }),
          const SizedBox(height: 12),
          // Filter
          SizedBox(
            height: 36,
            child: Obx(() => ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _filterChip('Semua', '', ctrl),
                const SizedBox(width: 8),
                _filterChip('Pending', 'pending', ctrl),
                const SizedBox(width: 8),
                _filterChip('Confirmed', 'confirmed', ctrl),
                const SizedBox(width: 8),
                _filterChip('Done', 'done', ctrl),
              ],
            )),
          ),
          const SizedBox(height: 12),
          // List
          Expanded(
            child: Obx(() {
              final items = ctrl.filtered;
              if (items.isEmpty) {
                return Center(child: Text('Tidak ada booking', style: AppTextStyles.caption));
              }
              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final b = items[i];
                  final tutor = mockTutors.firstWhere((t) => t.id == b.tutorId, orElse: () => mockTutors.first);
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border(left: BorderSide(color: _statusColor(b.status), width: 4)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primaryBlue.withAlpha((0.1 * 255).round()),
                          child: Text(tutor.fullName[0], style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w800, fontSize: 12)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tutor.fullName, style: AppTextStyles.bodySemiBold),
                              Text('${b.customerName ?? "Customer"} • ${b.subject}', style: AppTextStyles.caption.copyWith(fontSize: 11)),
                            ],
                          ),
                        ),
                        if (b.status == 'pending')
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check_circle_rounded, color: AppColors.onlineGreen, size: 20),
                                onPressed: () { ctrl.approveBooking(b.id); Get.snackbar('Approved', 'Booking ${b.id} disetujui'); },
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel_rounded, color: AppColors.primaryRed, size: 20),
                                onPressed: () { ctrl.cancelBooking(b.id); Get.snackbar('Cancelled', 'Booking ${b.id} dibatalkan'); },
                              ),
                            ],
                          )
                        else
                          StatusBadge(status: b.status),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text('$value', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption.copyWith(fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String value, OperationalController ctrl) {
    final selected = ctrl.filterStatus.value == value;
    return GestureDetector(
      onTap: () => ctrl.filterStatus.value = value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: AppTextStyles.bodySemiBold.copyWith(fontSize: 12, color: selected ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return AppColors.primaryYellow;
      case 'confirmed': return AppColors.primaryBlue;
      case 'done': return AppColors.onlineGreen;
      case 'cancelled': return AppColors.primaryRed;
      default: return AppColors.textLight;
    }
  }

  Widget _buildTutorTab() {
    return ListView.builder(
      padding: ResponsiveHelper.contentPadding(context),
      itemCount: mockTutors.length,
      itemBuilder: (_, i) {
        final t = mockTutors[i];
        return Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.primaryBlue, AppColors.blueLight]),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(t.fullName[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.fullName, style: AppTextStyles.heading3),
                    Text('${t.university} • ${t.subjects.take(2).join(", ")}', style: AppTextStyles.caption),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 8, color: t.isOnline ? AppColors.onlineGreen : AppColors.textLight),
                      const SizedBox(width: 4),
                      Text(t.isOnline ? 'Online' : 'Offline', style: AppTextStyles.caption.copyWith(fontSize: 10)),
                    ],
                  ),
                  Text('⭐ ${t.rating}', style: AppTextStyles.bodySemiBold.copyWith(fontSize: 12)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileTab(AuthController auth) {
    return SingleChildScrollView(
      padding: ResponsiveHelper.contentPadding(context),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primaryBlue, AppColors.primaryBlue.withAlpha((0.8 * 255).round())]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(color: AppColors.primaryYellow, borderRadius: BorderRadius.circular(12)),
                  alignment: Alignment.center,
                  child: Text((auth.currentUser.value?.fullName ?? 'A')[0].toUpperCase(), style: AppTextStyles.heading1.copyWith(color: Colors.white, fontSize: 28)),
                ),
                const SizedBox(height: 12),
                Text(auth.currentUser.value?.fullName ?? 'Admin', style: AppTextStyles.heading3.copyWith(color: Colors.white)),
                const SizedBox(height: 4),
                Text('admin@demo.com', style: AppTextStyles.caption.copyWith(color: Colors.white70)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withAlpha((0.2 * 255).round()), borderRadius: BorderRadius.circular(8)),
                  child: Text('Manajemen', style: AppTextStyles.caption.copyWith(color: Colors.white)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _profileMenu(Icons.dashboard_rounded, 'Dashboard', 'Statistik platform'),
          _profileMenu(Icons.receipt_long_rounded, 'Kelola Booking', 'Approve & batalkan'),
          _profileMenu(Icons.school_rounded, 'Kelola Tutor', 'Data tutor aktif'),
          _profileMenu(Icons.assessment_rounded, 'Laporan', 'Detail statistik'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Get.find<AuthController>().logout(),
              icon: const Icon(Icons.logout_rounded, color: AppColors.primaryRed),
              label: Text('Keluar', style: TextStyle(color: AppColors.primaryRed)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primaryRed), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileMenu(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 22),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: AppTextStyles.bodySemiBold), Text(subtitle, style: AppTextStyles.caption)])),
          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textLight),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(AuthController auth) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      padding: EdgeInsets.fromLTRB(
        ResponsiveHelper.horizontalPadding(context),
        MediaQuery.of(context).padding.top + 16,
        ResponsiveHelper.horizontalPadding(context),
        24,
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Panel Manajemen 🎯',
                style: AppTextStyles.heading2.copyWith(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Obx(
                    () => Text(
                      'Halo, ${auth.currentUser.value?.fullName ?? 'Admin'}',
                      style: AppTextStyles.caption.copyWith(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.2 * 255).round()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '⚙️ Admin',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.15 * 255).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Get.find<AuthController>().logout(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.15 * 255).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats Grid ─────────────────────────────────────────────────────────

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Statistik Platform', style: AppTextStyles.heading3),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: ResponsiveHelper.isDesktop(context)
              ? 4
              : ResponsiveHelper.isTablet(context)
                  ? 4
                  : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _statCard(
              icon: Icons.hourglass_top_rounded,
              value: '5',
              label: 'Pending Approval',
              color: AppColors.primaryYellow,
            ),
            _statCard(
              icon: Icons.school_rounded,
              value: '42',
              label: 'Tutor Aktif',
              color: AppColors.onlineGreen,
            ),
            _statCard(
              icon: Icons.people_rounded,
              value: '128',
              label: 'Total Customer',
              color: Colors.white,
            ),
            _statCard(
              icon: Icons.report_problem_rounded,
              value: '3',
              label: 'Komplain',
              color: AppColors.primaryRed,
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Revenue card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFFAB5CF7)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Pendapatan',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rp ${_formatCurrency(stats['revenue'])}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.15 * 255).round()),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha((0.08 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  // ── Quick Actions ──────────────────────────────────────────────────────

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Aksi Cepat', style: AppTextStyles.heading3),
        const SizedBox(height: 12),
        _actionCard(
          icon: Icons.receipt_long_rounded,
          title: 'Kelola Booking',
          subtitle: '${mockManagementStats['pendingBookings']} menunggu',
          color: AppColors.primaryYellow,
          onTap: () => Get.toNamed(AppRoutes.operational),
        ),
        const SizedBox(height: 10),
        _actionCard(
          icon: Icons.school_rounded,
          title: 'Kelola Tutor',
          subtitle: '${mockManagementStats['activeTutors']} aktif',
          color: AppColors.onlineGreen,
          onTap: () => Get.toNamed(AppRoutes.tutorApproval),
        ),
        const SizedBox(height: 10),
        _actionCard(
          icon: Icons.assessment_rounded,
          title: 'Laporan & Statistik',
          subtitle: 'Lihat detail',
          color: AppColors.primaryBlue,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withAlpha((0.06 * 255).round()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodySemiBold),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }

  // ── Recent Activity ────────────────────────────────────────────────────

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Aktivitas Terbaru', style: AppTextStyles.heading3),
        const SizedBox(height: 12),
        _activityTile(
          icon: Icons.add_circle_outline,
          color: AppColors.onlineGreen,
          title: 'Tutor baru terdaftar',
          subtitle: 'Dimas Pratama - UGM',
          time: '2 jam lalu',
        ),
        _activityTile(
          icon: Icons.check_circle_outline,
          color: AppColors.primaryBlue,
          title: 'Booking dikonfirmasi',
          subtitle: 'b4 - Statistika oleh Fikri Akbar',
          time: '3 jam lalu',
        ),
        _activityTile(
          icon: Icons.cancel_outlined,
          color: AppColors.primaryRed,
          title: 'Booking dibatalkan',
          subtitle: 'b8 - TOEFL Prep oleh Rizky Pratama',
          time: '5 jam lalu',
        ),
        _activityTile(
          icon: Icons.star_outline,
          color: AppColors.primaryYellow,
          title: 'Review baru',
          subtitle: '5⭐ untuk Arif Rahmat',
          time: '1 hari lalu',
        ),
      ],
    );
  }

  Widget _activityTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodySemiBold),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          Text(time, style: AppTextStyles.caption.copyWith(fontSize: 10)),
        ],
      ),
    );
  }

  // ── Oprec Schedule Card ────────────────────────────────────────────────

  Widget _buildOprecCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF4A200), Color(0xFFFF9A3C)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF4A200).withAlpha((0.3 * 255).round()),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📅 Jadwal Oprec Tutor',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '1 – 15 April 2026',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pendaftaran tutor batch 3 sedang aktif',
                  style: AppTextStyles.caption.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.25 * 255).round()),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withAlpha((0.35 * 255).round())),
            ),
            child: const Text(
              'Edit',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Session Chart ──────────────────────────────────────────────────────

  Widget _buildSessionChart() {
    final data = [
      {'label': 'Sen', 'value': 38, 'color': AppColors.primaryBlue},
      {'label': 'Sel', 'value': 52, 'color': AppColors.primaryBlue},
      {'label': 'Rab', 'value': 45, 'color': AppColors.primaryBlue},
      {'label': 'Kam', 'value': 60, 'color': AppColors.primaryYellow},
      {'label': 'Jum', 'value': 48, 'color': AppColors.primaryBlue},
      {'label': 'Sab', 'value': 30, 'color': AppColors.primaryRed},
      {'label': 'Min', 'value': 20, 'color': AppColors.textLight},
    ];
    final maxVal = data.map((d) => d['value'] as int).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withAlpha((0.06 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📊 Sesi Minggu Ini', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: data.map((d) {
              final height = ((d['value'] as int) / maxVal * 60).toDouble();
              final color = d['color'] as Color;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      Container(
                        height: height,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        d['label'] as String,
                        style: AppTextStyles.caption.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Approval Tutor Section ─────────────────────────────────────────────

  Widget _buildApprovalSection() {
    final pendingTutors = [
      {'name': 'Muhammad Rizky', 'univ': 'UGM', 'subject': 'Kimia Organik'},
      {'name': 'Laila Nur Fadhilah', 'univ': 'UB', 'subject': 'Kalkulus'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Approval Tutor', style: AppTextStyles.heading3),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryRed,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${pendingTutors.length} pending',
                style: AppTextStyles.label.copyWith(color: Colors.white),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.tutorApproval),
              child: Text(
                'Lihat Semua',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...pendingTutors.map((t) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withAlpha((0.06 * 255).round()),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.accentPurple.withAlpha((0.2 * 255).round()),
                child: Text(
                  (t['name'] as String)[0],
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.accentPurple,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t['name']!, style: AppTextStyles.bodySemiBold),
                    Text(
                      '${t['subject']} • ${t['univ']}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.primaryRed, size: 20),
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.onlineGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      elevation: 0,
                    ),
                    child: const Text('Setujui',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        )),
      ],
    );
  }

  String _formatCurrency(dynamic amount) {
    final str = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
