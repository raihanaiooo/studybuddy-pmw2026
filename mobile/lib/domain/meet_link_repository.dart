class MeetLinkRef {
  final String id;
  final String tutorId;
  final String meetLink;
  final String? label;
  final bool isActive;
  final DateTime createdAt;

  const MeetLinkRef({
    required this.id,
    required this.tutorId,
    required this.meetLink,
    this.label,
    this.isActive = true,
    required this.createdAt,
  });
}

abstract class MeetLinkRepository {
  Future<List<MeetLinkRef>> fetchLinks(String tutorId);
  Future<MeetLinkRef> createLink({
    required String tutorId,
    required String meetLink,
    String? label,
  });
  Future<void> deleteLink(String linkId);
  Future<MeetLinkRef?> pickOneActive(String tutorId);
}

class MeetLinkBackendMissingException implements Exception {
  final String message;
  final Object? cause;

  const MeetLinkBackendMissingException(this.message, [this.cause]);

  @override
  String toString() =>
      'MeetLinkBackendMissingException: $message'
      '${cause == null ? '' : ' (cause: $cause)'}';
}
