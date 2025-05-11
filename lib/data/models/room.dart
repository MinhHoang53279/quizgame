class Room {
  final String id;
  final String code;
  final String hostId;
  final List<String> memberIds;
  final bool started;

  Room({
    required this.id,
    required this.code,
    required this.hostId,
    required this.memberIds,
    required this.started,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      code: json['code'],
      hostId: json['hostId'],
      memberIds: List<String>.from(json['memberIds'] ?? []),
      started: json['started'] ?? false,
    );
  }
} 