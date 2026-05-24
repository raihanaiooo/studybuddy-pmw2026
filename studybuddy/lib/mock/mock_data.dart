import '../models/tutor_model.dart';

final List<TutorModel> mockTutors = [
  TutorModel(
    id: 't1',
    userId: 'u1',
    fullName: 'Arif Rahmat',
    avatarUrl: null,
    bio: 'Tutor Fisika & Matematika, friendly, berpengalaman mengajar UTS/UAS.',
    subjects: ['Fisika', 'Matematika'],
    rating: 4.9,
    totalSessions: 120,
    totalReviews: 54,
    isOnline: true,
    pricePerHour: 60000,
    gmeetLink: null,
    university: 'ITB',
    gpa: 3.7,
  ),
  TutorModel(
    id: 't2',
    userId: 'u2',
    fullName: 'Nadia Putri',
    avatarUrl: null,
    bio: 'Spesialis Kalkulus dan Statistik. Fokus problem solving.',
    subjects: ['Kalkulus', 'Statistika'],
    rating: 4.7,
    totalSessions: 80,
    totalReviews: 30,
    isOnline: false,
    pricePerHour: 50000,
    gmeetLink: null,
    university: 'UI',
    gpa: 3.8,
  ),
];

// Mock users (customers/tutors)
final mockUser = {
  'id': 'c_demo',
  'email': 'demo@user.test',
  'full_name': 'Demo User',
  'role': 'customer',
  'created_at': DateTime.now().toIso8601String(),
};

// Mock bookings list
final List<Map<String, dynamic>> mockBookings = [
  {
    'id': 'b1',
    'customer_id': 'c_demo',
    'tutor_id': 't1',
    'session_time': DateTime.now()
        .add(const Duration(days: 1))
        .toIso8601String(),
    'duration_minutes': 60,
    'subject': 'Fisika Dasar',
    'session_type': 'chat',
    'status': 'confirmed',
    'notes': 'Siapkan materi bab 2',
    'created_at': DateTime.now().toIso8601String(),
  },
];

// Mock sessions list
final List<Map<String, dynamic>> mockSessions = <Map<String, dynamic>>[];
