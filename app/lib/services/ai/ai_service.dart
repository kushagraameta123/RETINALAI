
import 'dart:convert';

import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../models/ai_model.dart';



class AIService {

  // NOTE: This URL must be set to your deployed AI backend (Vercel/Node.js)

  static const String aiBackendUrl = 'https://api.yourhealthcareapp.com/ai'; 



  Future<RetinaDiagnosis> analyzeRetinaImage(Uint8List imageData) async {

    final response = await http.post(

      Uri.parse('$aiBackendUrl/analyze-retina'),

      body: json.encode({'imageData': base64.encode(imageData)}),

    );



    if (response.statusCode == 200) {

      return RetinaDiagnosis.fromJson(json.decode(response.body));

    } else {

      throw Exception('Failed to analyze image');

    }

  }



  Future<String> medicalChat(String message, List<ChatMessage> chatHistory) async {

    final response = await http.post(

      Uri.parse('$aiBackendUrl/chatbot'),

      body: json.encode({

        'message': message,

        'chatHistory': chatHistory.map((msg) => msg.toJson()).toList(),

      }),

    );

    

    if (response.statusCode == 200) {

      return json.decode(response.body)['response'];

    } else {

      throw Exception('Failed to get response from chatbot');

    }

  }

}

