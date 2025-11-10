class ChatMessage {
  final String role; // 'user' or 'assistant'
  final String text;

  ChatMessage(this.role, this.text);

  factory ChatMessage.user(String t) => ChatMessage('user', t);

  factory ChatMessage.assistant(String t) => ChatMessage('assistant', t);

  Map<String, dynamic> toJson() => {'role': role, 'content': text};
}
