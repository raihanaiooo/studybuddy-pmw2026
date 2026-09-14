import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/chat/chat_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../app/routes.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final int _navIndex = 2;

  @override
  Widget build(BuildContext context) {
    final chatCtrl = Get.find<ChatController>();
    final auth = Get.find<AuthController>();

    final userId = auth.currentUser.value?.id ?? 'c_demo';
    final role = auth.currentUser.value?.role ?? 'customer';
    chatCtrl.currentUserId.value = userId;
    chatCtrl.currentUserRole.value = role;

    final rooms = chatCtrl.getRoomsForUser(userId, role);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(context, role),
          Expanded(
            child: rooms.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: rooms.length,
                    itemBuilder: (_, i) {
                      final room = rooms[i];
                      final otherName = chatCtrl.getOtherName(room);
                      final otherInitial = chatCtrl.getOtherInitial(room);
                      final lastMsg = room.lastMessage;
                      final unread = role == 'customer'
                          ? room.messages
                              .where((m) => !m.isRead && m.senderId != userId)
                              .length
                          : room.messages
                              .where((m) => !m.isRead && m.senderId != userId)
                              .length;

                      return _ChatListItem(
                        name: otherName,
                        initial: otherInitial ?? '?',
                        subject: room.subject,
                        lastMessage: lastMsg?.message ?? '',
                        time: lastMsg != null
                            ? _formatTime(lastMsg.timestamp)
                            : '',
                        unreadCount: unread,
                        onTap: () {
                          chatCtrl.markAsRead(room.id);
                          Get.toNamed(
                            AppRoutes.chatRoom,
                            arguments: {'roomId': room.id},
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(role),
    );
  }

  Widget _buildHeader(BuildContext context, String role) {
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
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            role == 'customer' ? 'Pesan' : 'Chat Customer',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Riwayat percakapan dengan ${role == "customer" ? "tutor" : "customer"}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.65),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline_rounded,
              size: 56, color: AppColors.textLight),
          const SizedBox(height: 12),
          Text('Belum ada percakapan', style: AppTextStyles.heading3),
          const SizedBox(height: 6),
          Text('Mulai booking tutor untuk chat',
              style: AppTextStyles.caption),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return DateFormat('HH:mm').format(dt);
    if (diff.inDays == 1) return 'Kemarin';
    if (diff.inDays < 7) return DateFormat('EEEE', 'id').format(dt);
    return DateFormat('dd/MM').format(dt);
  }

  Widget _buildBottomNav(String role) {
    if (role == 'customer') {
      return _CustomerBottomNav(currentIndex: _navIndex);
    }
    return _TutorBottomNav(currentIndex: _navIndex);
  }
}

class _ChatListItem extends StatelessWidget {
  final String name;
  final String initial;
  final String subject;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final VoidCallback onTap;

  const _ChatListItem({
    required this.name,
    required this.initial,
    required this.subject,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryBlue, Color(0xFF6BB5FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.center,
              child: Text(
                initial.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
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
                        child: Text(
                          name,
                          style: AppTextStyles.bodySemiBold.copyWith(
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        time,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                          color: unreadCount > 0
                              ? AppColors.primaryBlue
                              : AppColors.textLight,
                          fontWeight: unreadCount > 0
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subject,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 12,
                            color: unreadCount > 0
                                ? AppColors.textPrimary
                                : AppColors.textLight,
                            fontWeight: unreadCount > 0
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerBottomNav extends StatelessWidget {
  final int currentIndex;
  const _CustomerBottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_rounded, 'Beranda', 0),
          _navItem(Icons.search_rounded, 'Cari', 1),
          _navItem(Icons.chat_bubble_rounded, 'Chat', 2),
          _navItem(Icons.calendar_today_rounded, 'Jadwal', 3),
          _navItem(Icons.person_rounded, 'Profil', 4),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final active = index == currentIndex;
    return GestureDetector(
      onTap: () {
        switch (index) {
          case 0:
            Get.offAllNamed(AppRoutes.customerDashboard);
            break;
          case 1:
            Get.toNamed(AppRoutes.tutorList);
            break;
          case 2:
            break; // already here
          case 3:
            Get.toNamed(AppRoutes.customerSchedule);
            break;
          case 4:
            Get.toNamed(AppRoutes.customerProfile);
            break;
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFEEF4FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: active ? AppColors.primaryBlue : AppColors.textLight,
                size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? AppColors.primaryBlue : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorBottomNav extends StatelessWidget {
  final int currentIndex;
  const _TutorBottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.grid_view_rounded, 'Dashboard', 0),
          _navItem(Icons.calendar_today_rounded, 'Jadwal', 1),
          _navItem(Icons.chat_bubble_rounded, 'Chat', 2),
          _navItem(Icons.person_outline_rounded, 'Profil', 3),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final active = index == currentIndex;
    return GestureDetector(
      onTap: () {
        switch (index) {
          case 0:
            Get.offAllNamed(AppRoutes.tutorDashboard);
            break;
          case 1:
            Get.toNamed(AppRoutes.tutorSchedule);
            break;
          case 2:
            break; // already here
          case 3:
            Get.toNamed(AppRoutes.tutorProfile);
            break;
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFEEF4FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: active ? AppColors.primaryBlue : AppColors.textLight,
                size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? AppColors.primaryBlue : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
