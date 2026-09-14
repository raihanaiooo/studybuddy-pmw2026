import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../mock/mock_data.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/utils/responsive_helper.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../app/routes.dart';

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

  void _onNavTap(int i) => setState(() => _navIndex = i);

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final stats = mockManagementStats;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          if (_navIndex == 0)
            _buildHeader(auth)
          else
            SizedBox(height: MediaQuery.of(context).padding.top),
          Expanded(child: _buildContent(auth, stats)),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _navIndex,
        onTap: _onNavTap,
        items: _navItems,
      ),
    );
  }

  Widget _buildContent(AuthController auth, Map<String, dynamic> stats) {
    switch (_navIndex) {
      case 0:
        return _buildDashboardTab(stats);
      case 1:
        return _buildTutorListTab();
      case 2:
        return _buildCustomerListTab();
      case 3:
        return _buildLaporanTab(stats);
      default:
        return _buildDashboardTab(stats);
    }
  }

  // ── DASHBOARD TAB ────────────────────────────────────────────────────

  Widget _buildDashboardTab(Map<String, dynamic> stats) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOprecCard(),
          _buildSessionChart(),
          _buildApprovalSection(),
          _buildActiveTutorSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────────────

  Widget _buildHeader(AuthController auth) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1F3C), Color(0xFF2E3A6E), Color(0xFF1A5EAA)],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        22,
        MediaQuery.of(context).padding.top + 20,
        22,
        28,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Panel Manajemen',
                        style: TextStyle(
                          color: Color(0x99FFFFFF),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Obx(
                        () => Text(
                          auth.currentUser.value?.fullName ??
                              'Admin Study Buddy',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4A200),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '⚙️ Admin',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _mgmtStat('5', 'Pending Approval', const Color(0xFFFFD166)),
                  const SizedBox(width: 10),
                  _mgmtStat('42', 'Tutor Aktif', const Color(0xFF6EE7B7)),
                  const SizedBox(width: 10),
                  _mgmtStat('128', 'Total Customer', Colors.white),
                  const SizedBox(width: 10),
                  _mgmtStat('3', 'Komplain', const Color(0xFFFF6B74)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mgmtStat(String num, String label, Color numColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              num,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: numColor,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.60),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── OPREC CARD ────────────────────────────────────────────────────────

  Widget _buildOprecCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF4A200), Color(0xFFFF9A3C)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF4A200).withOpacity(0.30),
            blurRadius: 20,
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
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.75),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '1 – 15 April 2026',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pendaftaran tutor batch 3 sedang aktif',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.80),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              border: Border.all(color: Colors.white.withOpacity(0.35)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Edit',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SESSION CHART ─────────────────────────────────────────────────────

  Widget _buildSessionChart() {
    final data = [
      {'label': 'Sen', 'value': 38, 'color': AppColors.primaryBlue},
      {'label': 'Sel', 'value': 52, 'color': AppColors.primaryBlue},
      {'label': 'Rab', 'value': 45, 'color': AppColors.primaryBlue},
      {'label': 'Kam', 'value': 60, 'color': AppColors.primaryYellow},
      {'label': 'Jum', 'value': 48, 'color': AppColors.primaryBlue},
      {'label': 'Sab', 'value': 30, 'color': AppColors.primaryRed},
      {
        'label': 'Min',
        'value': 20,
        'color': AppColors.primaryBlue.withOpacity(0.4),
      },
    ];
    final maxVal = data
        .map((d) => d['value'] as int)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7F0)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Sesi Minggu Ini',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1F3C),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((d) {
                final barH = ((d['value'] as int) / maxVal * 60).toDouble();
                final color = d['color'] as Color;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: barH,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          d['label'] as String,
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── APPROVAL SECTION ──────────────────────────────────────────────────

  Widget _buildApprovalSection() {
    final pendingTutors = [
      {
        'name': 'Muhammad Rizky',
        'subject': 'Kimia Organik',
        'univ': 'Universitas Gadjah Mada',
        'date': '18 Mar\n2026',
        'tags': ['Kimia Organik', 'Biokimia', 'S1 UGM', 'IPK 3.72'],
        'initial': 'M',
        'gradStart': const Color(0xFF7C3AED),
        'gradEnd': const Color(0xFFA78BFA),
      },
      {
        'name': 'Laila Nur Fadhilah',
        'subject': 'Matematika',
        'univ': 'Universitas Brawijaya',
        'date': '17 Mar\n2026',
        'tags': ['Kalkulus', 'Aljabar Linear', 'S1 UB', 'IPK 3.89'],
        'initial': 'L',
        'gradStart': const Color(0xFF0891B2),
        'gradEnd': const Color(0xFF22D3EE),
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Approval Tutor',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1F3C),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '5 pending',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.tutorApproval),
                child: Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...pendingTutors.map((t) => _approvalCard(t)),
        ],
      ),
    );
  }

  Widget _approvalCard(Map<String, dynamic> t) {
    final tags = t['tags'] as List<String>;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7F0)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: avatar + name + date
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [t['gradStart'] as Color, t['gradEnd'] as Color],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: Text(
                  t['initial'] as String,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t['name'] as String,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1F3C),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${t['subject']} · ${t['univ']}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                t['date'] as String,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Tags
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: tags.map((tag) {
              final isBlue =
                  tag.contains(' ') &&
                  !tag.startsWith('S1') &&
                  !tag.startsWith('IPK');
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: isBlue
                      ? const Color(0xFFEEF4FF)
                      : const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: isBlue
                        ? AppColors.primaryBlue
                        : const Color(0xFF6B7280),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Docs
          Row(
            children: [
              Expanded(child: _docChip('📄', 'KTM / KHS', 'PDF · 1.2 MB')),
              const SizedBox(width: 8),
              Expanded(child: _docChip('🎓', 'Transkrip', 'PDF · 0.8 MB')),
            ],
          ),
          const SizedBox(height: 12),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFE5E7F0),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '✕ Tolak',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF22C55E).withOpacity(0.30),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '✓ Setujui Tutor',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _docChip(String emoji, String name, String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        border: Border.all(color: const Color(0xFFE5E7F0)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1F3C),
                  ),
                ),
                Text(
                  type,
                  style: const TextStyle(fontSize: 9, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── ACTIVE TUTOR LIST ─────────────────────────────────────────────────

  Widget _buildActiveTutorSection() {
    final tutors = [
      {
        'initial': 'A',
        'name': 'Arif Rahmat',
        'subject': 'Fisika & Matematika',
        'status': 'active',
        'sessions': '320 sesi',
        'gradStart': AppColors.primaryBlue,
        'gradEnd': AppColors.blueLight,
      },
      {
        'initial': 'S',
        'name': 'Siti Nuraini',
        'subject': 'Kimia Dasar',
        'status': 'active',
        'sessions': '210 sesi',
        'gradStart': AppColors.primaryRed,
        'gradEnd': const Color(0xFFFF6B74),
      },
      {
        'initial': 'B',
        'name': 'Budi Santoso',
        'subject': 'Matematika',
        'status': 'pending',
        'sessions': '185 sesi',
        'gradStart': AppColors.primaryYellow,
        'gradEnd': const Color(0xFFFFD166),
      },
      {
        'initial': 'D',
        'name': 'Dewi Angraini',
        'subject': 'Statistik & Data Science',
        'status': 'active',
        'sessions': '142 sesi',
        'gradStart': const Color(0xFF7C3AED),
        'gradEnd': const Color(0xFFA78BFA),
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tutor Aktif',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1F3C),
                ),
              ),
              Text(
                'Lihat Semua',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...tutors.map((t) => _tutorListItem(t)),
        ],
      ),
    );
  }

  Widget _tutorListItem(Map<String, dynamic> t) {
    final status = t['status'] as String;
    final isActive = status == 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7F0)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [t['gradStart'] as Color, t['gradEnd'] as Color],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            alignment: Alignment.center,
            child: Text(
              t['initial'] as String,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t['name'] as String,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1F3C),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  t['subject'] as String,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isActive ? '● Aktif' : '⏸ Cuti',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: isActive
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFD97706),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                t['sessions'] as String,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── CUSTOMER LIST TAB ─────────────────────────────────────────────────

  Widget _buildCustomerListTab() {
    final customers = [
      {'name': 'Rania Putri', 'email': 'rania@demo.com', 'bookings': 12, 'initial': 'R'},
      {'name': 'Farhan Malik', 'email': 'farhan@demo.com', 'bookings': 8, 'initial': 'F'},
      {'name': 'Rani Putri', 'email': 'rani@demo.com', 'bookings': 5, 'initial': 'R'},
      {'name': 'Fikri Akbar', 'email': 'fikri@demo.com', 'bookings': 3, 'initial': 'F'},
      {'name': 'Maya Sari', 'email': 'maya@demo.com', 'bookings': 7, 'initial': 'M'},
      {'name': 'Andi Wijaya', 'email': 'andi@demo.com', 'bookings': 4, 'initial': 'A'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              Text('Daftar Customer', style: AppTextStyles.heading3),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${customers.length} customer',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            padding: ResponsiveHelper.contentPadding(context),
            itemCount: customers.length,
            itemBuilder: (_, i) {
              final c = customers[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accentPurple,
                            AppColors.accentPurple.withOpacity(0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        c['initial'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c['name'] as String,
                              style: AppTextStyles.bodySemiBold),
                          Text(c['email'] as String,
                              style: AppTextStyles.caption.copyWith(fontSize: 11)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${c['bookings']} booking',
                          style: AppTextStyles.bodySemiBold.copyWith(
                            fontSize: 12,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        Text(
                          'Total sesi',
                          style: AppTextStyles.caption.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── LAPORAN TAB ───────────────────────────────────────────────────────

  Widget _buildLaporanTab(Map<String, dynamic> stats) {
    return SingleChildScrollView(
      padding: ResponsiveHelper.contentPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('Laporan & Statistik', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          _buildStatCard('Total Pengguna', '${stats['totalUsers']}', Icons.people_rounded, AppColors.primaryBlue),
          const SizedBox(height: 10),
          _buildStatCard('Total Tutor', '${stats['totalTutors']}', Icons.school_rounded, AppColors.onlineGreen),
          const SizedBox(height: 10),
          _buildStatCard('Total Booking', '${stats['totalBookings']}', Icons.receipt_long_rounded, AppColors.primaryYellow),
          const SizedBox(height: 10),
          _buildStatCard('Sesi Selesai', '${stats['totalSessions']}', Icons.check_circle_rounded, AppColors.accentTeal),
          const SizedBox(height: 10),
          _buildStatCard('Revenue', 'Rp${(stats['revenue'] as int).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}', Icons.account_balance_wallet_rounded, AppColors.primaryRed),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aktivitas Terakhir', style: AppTextStyles.bodySemiBold),
                const SizedBox(height: 12),
                _activityItem('Booking baru dari Rania Putri', '2 menit lalu'),
                _activityItem('Tutor Arif Rahmat menyelesaikan sesi', '15 menit lalu'),
                _activityItem('Customer baru: Farhan Malik', '1 jam lalu'),
                _activityItem('Tutor Dimas Pratama online', '2 jam lalu'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Get.find<AuthController>().logout(),
              icon: const Icon(Icons.logout_rounded, color: AppColors.primaryRed),
              label: const Text('Keluar', style: TextStyle(color: AppColors.primaryRed)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryRed),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                Text(value, style: AppTextStyles.heading3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityItem(String text, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: AppTextStyles.caption.copyWith(fontSize: 12)),
          ),
          Text(time, style: AppTextStyles.caption.copyWith(fontSize: 10, color: AppColors.textLight)),
        ],
      ),
    );
  }

  // ── TUTOR LIST TAB ─────────────────────────────────────────────────────

  Widget _buildTutorListTab() {
    return ListView.builder(
      padding: ResponsiveHelper.contentPadding(context),
      itemCount: mockTutors.length,
      itemBuilder: (_, i) {
        final t = mockTutors[i];
        return Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.blueLight],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  t.fullName[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.fullName, style: AppTextStyles.heading3),
                    Text(
                      '${t.university} · ${t.subjects.take(2).join(", ")}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: t.isOnline
                            ? AppColors.onlineGreen
                            : AppColors.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        t.isOnline ? 'Online' : 'Offline',
                        style: AppTextStyles.caption.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                  Text(
                    '⭐ ${t.rating}',
                    style: AppTextStyles.bodySemiBold.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

}
