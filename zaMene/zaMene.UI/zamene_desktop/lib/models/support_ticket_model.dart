class SupportTicketModel {
  final int supportTicketID;
  final int userID;
  final String subject;
  final String message;
  String? response;
  bool isResolved;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  SupportTicketModel({
    required this.supportTicketID,
    required this.userID,
    required this.subject,
    required this.message,
    this.response,
    required this.isResolved,
    required this.createdAt,
    this.resolvedAt,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    T? pick<T>(String a, String b) {
      final v1 = json[a];
      if (v1 is T) return v1;
      final v2 = json[b];
      if (v2 is T) return v2;
      return null;
    }

    int _int(String a, String b) {
      final v = pick(a, b);
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    bool _bool(String a, String b) {
      final v = pick(a, b);
      if (v is bool) return v;
      if (v is String) return v.toLowerCase() == 'true';
      if (v is num) return v != 0;
      return false;
    }

    String _str(String a, String b) {
      final v = pick(a, b);
      if (v is String) return v;
      return '';
    }

    DateTime? _dt(String a, String b) {
      final v = pick(a, b);
      if (v is String && v.isNotEmpty) {
        return DateTime.tryParse(v);
      }
      return null;
    }

    return SupportTicketModel(
      supportTicketID: _int('supportTicketID', 'SupportTicketID'),
      userID: _int('userID', 'UserID'),
      subject: _str('subject', 'Subject'),
      message: _str('message', 'Message'),
      response: pick<String>('response', 'Response'),
      isResolved: _bool('isResolved', 'IsResolved'),
      createdAt: _dt('createdAt', 'CreatedAt') ?? DateTime.now(),
      resolvedAt: _dt('resolvedAt', 'ResolvedAt'),
    );
  }

  Map<String, dynamic> toJson() => {
        'SupportTicketID': supportTicketID,
        'UserID': userID,
        'Subject': subject,
        'Message': message,
        'Response': response,
        'IsResolved': isResolved,
        'CreatedAt': createdAt.toIso8601String(),
        'ResolvedAt': resolvedAt?.toIso8601String(),
      };
}
