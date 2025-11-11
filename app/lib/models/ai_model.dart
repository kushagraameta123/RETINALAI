
class RetinaDiagnosis {

  final Map<String, double> diagnosis;

  final String primaryCondition;

  final double confidence;

  final String note;



  RetinaDiagnosis({

    required this.diagnosis,

    required this.primaryCondition,

    required this.confidence,

    required this.note,

  });



  factory RetinaDiagnosis.fromJson(Map<String, dynamic> json) {

    return RetinaDiagnosis(

      diagnosis: Map<String, double>.from(json['diagnosis']),

      primaryCondition: json['primaryDiagnosis']['condition'],

      confidence: json['primaryDiagnosis']['confidence']?.toDouble() ?? 0.0,

      note: json['note'] ?? '',

    );

  }

}



class ChatMessage {

  final String role;

  final String content;

  final DateTime timestamp;



  ChatMessage({

    required this.role,

    required this.content,

    required this.timestamp,

  });



  Map<String, dynamic> toJson() {

    return {

      'role': role,

      'content': content,

      'timestamp': timestamp.toIso8601String(),

    };

  }



  factory ChatMessage.fromJson(Map<String, dynamic> json) {

    return ChatMessage(

      role: json['role'],

      content: json['content'],

      timestamp: DateTime.parse(json['timestamp']),

    );

  }

}

