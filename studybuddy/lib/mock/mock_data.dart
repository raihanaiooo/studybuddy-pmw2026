import '../models/tutor_model.dart';

// ── Mock Tutors ───────────────────────────────────────────────────────────────

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
    gmeetLink: 'meet.google.com/arif-fis-xyz',
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

// ── Mock Users ────────────────────────────────────────────────────────────────

final mockUser = {
  'id': 'c_demo',
  'email': 'demo@user.test',
  'full_name': 'Demo User',
  'role': 'customer',
  'created_at': DateTime.now().toIso8601String(),
};

// ── Mock Bookings ─────────────────────────────────────────────────────────────

final _now = DateTime.now();

final List<Map<String, dynamic>> mockBookings = [
  {
    'id': 'b1',
    'customer_id': 'c_demo',
    'customer_name': 'Rania Putri',
    'tutor_id': 't1',
    'session_date': DateTime(
      _now.year,
      _now.month,
      _now.day + 1,
    ).toIso8601String().split('T')[0],
    'start_time': '14:00:00',
    'end_time': '16:00:00',
    'duration_minutes': 120,
    'subject': 'Fisika Dasar I',
    'session_type': 'video',
    'status': 'pending',
    'notes': 'Siapkan materi bab 2',
    'created_at': _now.toIso8601String(),
  },
  {
    'id': 'b2',
    'customer_id': 'c_demo2',
    'customer_name': 'Farhan Malik',
    'tutor_id': 't1',
    'session_date': DateTime(
      _now.year,
      _now.month,
      _now.day + 1,
    ).toIso8601String().split('T')[0],
    'start_time': '19:00:00',
    'end_time': '20:00:00',
    'duration_minutes': 60,
    'subject': 'Kalkulus II',
    'session_type': 'chat',
    'status': 'pending',
    'notes': null,
    'created_at': _now.toIso8601String(),
  },
  {
    'id': 'b3',
    'customer_id': 'c_demo3',
    'customer_name': 'Rani Putri',
    'tutor_id': 't1',
    'session_date': DateTime(
      _now.year,
      _now.month,
      _now.day,
    ).toIso8601String().split('T')[0],
    'start_time': '13:00:00',
    'end_time': '14:00:00',
    'duration_minutes': 60,
    'subject': 'Kalkulus',
    'session_type': 'video',
    'status': 'pending',
    'notes': null,
    'created_at': _now.toIso8601String(),
  },
  {
    'id': 'b4',
    'customer_id': 'c_demo4',
    'customer_name': 'Fikri Akbar',
    'tutor_id': 't1',
    'session_date': DateTime(
      _now.year,
      _now.month,
      _now.day,
    ).toIso8601String().split('T')[0],
    'start_time': '19:00:00',
    'end_time': '20:00:00',
    'duration_minutes': 60,
    'subject': 'Statistika',
    'session_type': 'chat',
    'status': 'confirmed',
    'notes': null,
    'created_at': _now.toIso8601String(),
  },
];

// ── Mock Sessions ─────────────────────────────────────────────────────────────

final List<Map<String, dynamic>> mockSessions = <Map<String, dynamic>>[];
