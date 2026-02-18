// 爬宠展览活动模型
class Exhibition {
  final String id;
  final String title;
  final String subtitle;
  final String content;
  final String location;
  final DateTime startTime;
  final DateTime? endTime;
  final String? imageUrl;
  final String organizer;
  final String? ticketInfo;
  final bool isHighlight;
  final DateTime createdAt;

  Exhibition({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.location,
    required this.startTime,
    this.endTime,
    this.imageUrl,
    required this.organizer,
    this.ticketInfo,
    this.isHighlight = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'content': content,
      'location': location,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'image_url': imageUrl,
      'organizer': organizer,
      'ticket_info': ticketInfo,
      'is_highlight': isHighlight ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Exhibition.fromMap(Map<String, dynamic> map) {
    return Exhibition(
      id: map['id'],
      title: map['title'],
      subtitle: map['subtitle'],
      content: map['content'],
      location: map['location'],
      startTime: DateTime.parse(map['start_time']),
      endTime: map['end_time'] != null ? DateTime.parse(map['end_time']) : null,
      imageUrl: map['image_url'],
      organizer: map['organizer'],
      ticketInfo: map['ticket_info'],
      isHighlight: map['is_highlight'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
