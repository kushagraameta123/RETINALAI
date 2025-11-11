
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/ai/ai_service.dart';

import '../models/ai_model.dart';



class AiProvider with ChangeNotifier {

  final AIService _aiService = AIService();

  RetinaDiagnosis? _diagnosis;

  List<ChatMessage> _chatHistory = [];

  bool _isAnalyzing = false;

  bool _isChatting = false;



  RetinaDiagnosis? get diagnosis => _diagnosis;

  bool get isAnalyzing => _isAnalyzing;

  List<ChatMessage> get chatHistory => _chatHistory;

  bool get isChatting => _isChatting;



  Future<void> analyzeRetinaImage(Uint8List imageData) async {

    _isAnalyzing = true;

    _diagnosis = null;

    notifyListeners();

    try {

      _diagnosis = await _aiService.analyzeRetinaImage(imageData);

    } catch (e) {

      debugPrint('Error analyzing image: $e');

    } finally {

      _isAnalyzing = false;

      notifyListeners();

    }

  }



  Future<void> medicalChat(String message) async {

    _isChatting = true;

    _chatHistory.add(ChatMessage(

      role: 'user',

      content: message,

      timestamp: DateTime.now(),

    ));

    notifyListeners();

    try {

      final response = await _aiService.medicalChat(message, _chatHistory);

      _chatHistory.add(ChatMessage(

        role: 'model',

        content: response,

        timestamp: DateTime.now(),

      ));

    } catch (e) {

      debugPrint('Error with chatbot: $e');

      _chatHistory.add(ChatMessage(

        role: 'model',

        content: 'Sorry, I am unable to provide a response right now. Please try again later.',

        timestamp: DateTime.now(),

      ));

    } finally {

      _isChatting = false;

      notifyListeners();

    }

  }



  void clearChat() {

    _chatHistory = [];

    notifyListeners();

  }

}

