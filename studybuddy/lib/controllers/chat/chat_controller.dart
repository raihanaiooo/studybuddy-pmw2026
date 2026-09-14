import 'package:get/get.dart';
import '../../models/chat_room_model.dart';

class ChatController extends GetxController {
  final RxList<ChatRoomModel> chatRooms = <ChatRoomModel>[].obs;
  final RxString currentUserId = ''.obs;
  final RxString currentUserRole = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() {
    final now = DateTime.now();

    final rooms = [
      ChatRoomModel(
        id: 'cr1',
        customerId: 'c_demo',
        customerName: 'Rania Putri',
        tutorId: 't1',
        tutorName: 'Arif Rahmat',
        tutorInitial: 'A',
        subject: 'Fisika Dasar I',
        lastActivity: now.subtract(const Duration(minutes: 5)),
        messages: [
          ChatMessageModel(
            id: 'm1',
            senderId: 't1',
            senderName: 'Arif Rahmat',
            message: 'Halo Rania! Ada yang bisa dibantu untuk materi Fisika?',
            timestamp: now.subtract(const Duration(hours: 2)),
            isRead: true,
          ),
          ChatMessageModel(
            id: 'm2',
            senderId: 'c_demo',
            senderName: 'Rania Putri',
            message:
                'Kak, aku mau tanya soal Hukum Newton II. Rumus F=ma itu selalu berlaku?',
            timestamp: now.subtract(const Duration(hours: 1, minutes: 45)),
            isRead: true,
          ),
          ChatMessageModel(
            id: 'm3',
            senderId: 't1',
            senderName: 'Arif Rahmat',
            message:
                'Berlaku untuk benda dengan massa konstan ya. Kalau massa berubah (misal roket yang bakar bahan bakar), ada bentuk umumnya.',
            timestamp: now.subtract(const Duration(hours: 1, minutes: 30)),
            isRead: true,
          ),
          ChatMessageModel(
            id: 'm4',
            senderId: 'c_demo',
            senderName: 'Rania Putri',
            message: 'Oh gitu. Terus soal yang kemarin itu gimana penyelesaiannya?',
            timestamp: now.subtract(const Duration(minutes: 10)),
            isRead: true,
          ),
          ChatMessageModel(
            id: 'm5',
            senderId: 't1',
            senderName: 'Arif Rahmat',
            message:
                'Nanti aku jelasin di sesi berikutnya ya. Sekarang aku lagi siapin materinya dulu 📚',
            timestamp: now.subtract(const Duration(minutes: 5)),
            isRead: false,
          ),
        ],
      ),
      ChatRoomModel(
        id: 'cr2',
        customerId: 'c_demo',
        customerName: 'Rania Putri',
        tutorId: 't3',
        tutorName: 'Dimas Pratama',
        tutorInitial: 'D',
        subject: 'Algoritma Pemrograman',
        lastActivity: now.subtract(const Duration(hours: 3)),
        messages: [
          ChatMessageModel(
            id: 'm6',
            senderId: 't3',
            senderName: 'Dimas Pratama',
            message: 'Rania, tugas sorting yang kemarin sudah dikerjain?',
            timestamp: now.subtract(const Duration(hours: 5)),
            isRead: true,
          ),
          ChatMessageModel(
            id: 'm7',
            senderId: 'c_demo',
            senderName: 'Rania Putri',
            message: 'Sudah kak! Tapi masih bingung sama quicksort.',
            timestamp: now.subtract(const Duration(hours: 4)),
            isRead: true,
          ),
          ChatMessageModel(
            id: 'm8',
            senderId: 't3',
            senderName: 'Dimas Pratama',
            message:
                'Oke, coba baca referensi ini dulu. Nanti kita bahas pas sesi ya.',
            timestamp: now.subtract(const Duration(hours: 3)),
            isRead: false,
          ),
        ],
      ),
      ChatRoomModel(
        id: 'cr3',
        customerId: 'c_demo2',
        customerName: 'Farhan Malik',
        tutorId: 't1',
        tutorName: 'Arif Rahmat',
        tutorInitial: 'A',
        subject: 'Kalkulus II',
        lastActivity: now.subtract(const Duration(days: 1)),
        messages: [
          ChatMessageModel(
            id: 'm9',
            senderId: 'c_demo2',
            senderName: 'Farhan Malik',
            message: 'Kak, jadwal besok masih jam 7 malam?',
            timestamp: now.subtract(const Duration(days: 1, hours: 2)),
            isRead: true,
          ),
          ChatMessageModel(
            id: 'm10',
            senderId: 't1',
            senderName: 'Arif Rahmat',
            message: 'Iya betul. Siapkan materi integral ya!',
            timestamp: now.subtract(const Duration(days: 1)),
            isRead: true,
          ),
        ],
      ),
      ChatRoomModel(
        id: 'cr4',
        customerId: 'c_demo5',
        customerName: 'Maya Sari',
        tutorId: 't1',
        tutorName: 'Arif Rahmat',
        tutorInitial: 'A',
        subject: 'Fisika Dasar I',
        lastActivity: now.subtract(const Duration(days: 2)),
        messages: [
          ChatMessageModel(
            id: 'm11',
            senderId: 't1',
            senderName: 'Arif Rahmat',
            message: 'Maya, materi UAS sudah aku upload ya.',
            timestamp: now.subtract(const Duration(days: 2)),
            isRead: true,
          ),
        ],
      ),
    ];

    chatRooms.value = rooms;
  }

  List<ChatRoomModel> getRoomsForUser(String userId, String role) {
    if (role == 'customer') {
      return chatRooms.where((r) => r.customerId == userId).toList();
    } else {
      return chatRooms.where((r) => r.tutorId == userId).toList();
    }
  }

  String getOtherName(ChatRoomModel room) {
    if (currentUserRole.value == 'customer') {
      return room.tutorName;
    }
    return room.customerName;
  }

  String? getOtherInitial(ChatRoomModel room) {
    if (currentUserRole.value == 'customer') {
      return room.tutorInitial;
    }
    return room.customerName.isNotEmpty ? room.customerName[0] : '?';
  }

  void sendMessage(String roomId, String message, {String? senderId}) {
    final idx = chatRooms.indexWhere((r) => r.id == roomId);
    if (idx == -1) return;

    final room = chatRooms[idx];
    final actualSenderId = senderId ?? currentUserId.value;
    final isSenderCustomer = actualSenderId == room.customerId;
    final newMsg = ChatMessageModel(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      senderId: actualSenderId,
      senderName: isSenderCustomer ? room.customerName : room.tutorName,
      message: message,
      timestamp: DateTime.now(),
      isRead: true,
    );

    final updatedMessages = [...room.messages, newMsg];
    chatRooms[idx] = ChatRoomModel(
      id: room.id,
      customerId: room.customerId,
      customerName: room.customerName,
      tutorId: room.tutorId,
      tutorName: room.tutorName,
      tutorInitial: room.tutorInitial,
      subject: room.subject,
      messages: updatedMessages,
      lastActivity: DateTime.now(),
    );
    chatRooms.refresh();
  }

  void markAsRead(String roomId) {
    final idx = chatRooms.indexWhere((r) => r.id == roomId);
    if (idx == -1) return;

    final room = chatRooms[idx];
    final updatedMessages = room.messages
        .map((m) => ChatMessageModel(
              id: m.id,
              senderId: m.senderId,
              senderName: m.senderName,
              message: m.message,
              timestamp: m.timestamp,
              isRead: true,
            ))
        .toList();

    chatRooms[idx] = ChatRoomModel(
      id: room.id,
      customerId: room.customerId,
      customerName: room.customerName,
      tutorId: room.tutorId,
      tutorName: room.tutorName,
      tutorInitial: room.tutorInitial,
      subject: room.subject,
      messages: updatedMessages,
      lastActivity: room.lastActivity,
    );
    chatRooms.refresh();
  }
}
