class ChatMessage {
  final String? id;
  final String senderId;
  final String senderName;
  final String message;
  final int timestamp;
  final bool isAdmin;

  ChatMessage({
    this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.isAdmin = false,
  });

  factory ChatMessage.fromMap(String id, Map<dynamic, dynamic> map) {
    return ChatMessage(
      id: id,
      senderId: map['user_id']?.toString() ?? '',
      senderName: map['name']?.toString() ?? 'Unknown User',
      message: map['message']?.toString() ?? '',
      timestamp: map['time'] is int 
        ? map['time'] 
        : int.tryParse(map['time']?.toString() ?? '0') ?? 0,
      isAdmin: map['is_admin'] == true || map['is_admin'] == 1 || map['role'] == 'admin',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': senderId,
      'name': senderName,
      'message': message,
      'time': timestamp,
      'is_admin': isAdmin,
    };
  }
}
