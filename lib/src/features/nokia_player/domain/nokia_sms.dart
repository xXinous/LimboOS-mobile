class NokiaMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final String time;
  final int timestamp;
  final bool isMe;

  NokiaMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.time,
    required this.timestamp,
    required this.isMe,
  });
}

class NokiaSms {
  final String id;
  final String sender;
  final String text;
  final String time;
  final bool read;
  final List<NokiaMessage> messages;

  NokiaSms({
    required this.id,
    required this.sender,
    required this.text,
    required this.time,
    this.read = false,
    this.messages = const [],
  });

  NokiaSms copyWith({
    String? id,
    String? sender,
    String? text,
    String? time,
    bool? read,
    List<NokiaMessage>? messages,
  }) {
    return NokiaSms(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      text: text ?? this.text,
      time: time ?? this.time,
      read: read ?? this.read,
      messages: messages ?? this.messages,
    );
  }

  factory NokiaSms.fromMap(Map<String, dynamic> map) {
    return NokiaSms(
      id: map['id'] as String,
      sender: map['sender'] as String,
      text: map['text'] as String,
      time: map['time'] as String,
      read: map['read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender': sender,
      'text': text,
      'time': time,
      'read': read,
    };
  }
}
