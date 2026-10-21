import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  // Configured Gemini API Key (Can be passed via --dart-define=GEMINI_API_KEY=your_key)
  static const String _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'AQ.' 'Ab8RN6JVRuPuvXbDzcFUh3RBEElR2NGM0-howzalRXpdCkeM4Q',
  );

  // Fast, lightweight models prioritized for responsive real-time chat (< 3s response)
  static const List<String> _modelCandidates = [
    'gemini-3.5-flash-lite',
    'gemini-3.1-flash-lite',
    'gemini-3.5-flash',
    'gemini-3.8-flash',
    'gemini-flash-latest',
  ];

  static String? _workingModelName;

  static final _generationConfig = GenerationConfig(
    maxOutputTokens: 3000,
    temperature: 0.7,
  );

  static const String _systemPrompt = 
    '[SYSTEM INSTRUCTION FOR GOVI AI]:\n'
    'You are "Govi AI" (ගොවි AI), an expert Sri Lankan Agricultural and Farming Advisor.\n'
    'CRITICAL CONTENT & DETAIL REQUIREMENTS:\n'
    '1. Always provide a COMPREHENSIVE, IN-DEPTH, FULLY DETAILED, and STEP-BY-STEP response. NEVER give brief or overly short summaries. Farmers need complete and thorough practical guidance.\n'
    '2. For diseases, pests, fertilizers, cultivation practices, and crop issues, structure your detailed answer into clear sections:\n'
    '   - 📌 ගැටලුවට හේතු සහ රෝග ලක්ෂණ (Causes & Symptoms)\n'
    '   - 🌾 ක්ෂණිකව කළ යුතු පිළියම් (Immediate Remedies)\n'
    '   - 🧪 කාබනික සහ ස්වභාවික පාලන ක්‍රම (Organic & Natural Methods)\n'
    '   - 🛡️ රසායනික පාලන ක්‍රම සහ මාත්‍රාවන් (Chemical Controls & Recommended Dosages)\n'
    '   - 💡 අනාගතයේදී රෝගය වළක්වා ගැනීමට වැදගත් උපදෙස් (Long-term Prevention & Tips)\n'
    'CRITICAL FORMATTING RULES FOR YOUR RESPONSE:\n'
    '1. DO NOT use markdown symbols like "*", "**", "#", "##", "###", or "---" anywhere in your text.\n'
    '2. Use relevant, colorful Emojis (🌾, 🌱, 🐛, 🧪, 💧, ☀️, 📌, 🔹, 💡, 🛡️) to highlight headings and bullet points.\n'
    '3. Format headings clearly using emojis and clean plain text.\n'
    '4. Use "🔹" or "•" for list items instead of asterisks.\n'
    '5. Keep the language natural, polite, encouraging, practical, and clear for Sri Lankan farmers in Sinhala (or English if the user writes in English).\n\n'
    'User Question: ';

  /// Cleans raw markdown symbols (#, *, ---) from AI response text
  String _formatResponseText(String text) {
    String formatted = text;
    
    // Remove markdown headers (#, ##, ###)
    formatted = formatted.replaceAll(RegExp(r'#+\s*'), '📌 ');
    
    // Remove bold/italic markdown (**text** or *text*)
    formatted = formatted.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1');
    formatted = formatted.replaceAll(RegExp(r'\*([^*]+)\*'), r'$1');
    
    // Replace standalone asterisks at start of lines with clean bullets 🔹
    formatted = formatted.replaceAll(RegExp(r'^\s*\*\s*', multiLine: true), '🔹 ');
    formatted = formatted.replaceAll(RegExp(r'^\s*-\s*', multiLine: true), '🔹 ');
    
    // Remove horizontal rules (---)
    formatted = formatted.replaceAll(RegExp(r'---+\s*'), '\n');
    
    // Remove any remaining loose asterisks
    formatted = formatted.replaceAll('*', '');

    return formatted.trim();
  }

  /// Send a text message to Gemini AI
  Future<String> sendMessage(String text) async {
    final fullPrompt = '$_systemPrompt$text';

    // 1. Try previously working model if available
    if (_workingModelName != null) {
      try {
        final model = GenerativeModel(
          model: _workingModelName!,
          apiKey: _apiKey,
          generationConfig: _generationConfig,
        );
        final response = await model.generateContent([Content.text(fullPrompt)]);
        if (response.text != null && response.text!.trim().isNotEmpty) {
          return _formatResponseText(response.text!);
        }
      } catch (_) {
        _workingModelName = null; // Reset if it failed
      }
    }

    // 2. Iterate through candidate models starting with gemini-3.8-flash
    String lastErrorMessage = '';
    for (final modelName in _modelCandidates) {
      try {
        final model = GenerativeModel(
          model: modelName,
          apiKey: _apiKey,
          generationConfig: _generationConfig,
        );
        final response = await model.generateContent([Content.text(fullPrompt)]);
        
        if (response.text != null && response.text!.trim().isNotEmpty) {
          _workingModelName = modelName;
          return _formatResponseText(response.text!);
        }
      } catch (e) {
        lastErrorMessage = e.toString();
        continue;
      }
    }

    return 'දෝෂයක් සිදු විය: $lastErrorMessage';
  }

  /// Send an image + text for crop disease analysis
  Future<String> sendImagePrompt(Uint8List imageBytes, String prompt) async {
    final promptText = prompt.isEmpty 
        ? 'මෙම ඡායාරූපයේ ඇති වගාව හෝ ශාක රෝගය විශ්ලේෂණය කර විස්තර සහ පිළියම් ලබා දෙන්න.' 
        : prompt;

    final modelsToTry = _workingModelName != null ? [_workingModelName!] : _modelCandidates;

    for (final modelName in modelsToTry) {
      try {
        final model = GenerativeModel(
          model: modelName,
          apiKey: _apiKey,
          generationConfig: _generationConfig,
        );
        final content = Content.multi([
          TextPart('$_systemPrompt$promptText'),
          DataPart('image/jpeg', imageBytes),
        ]);
        final response = await model.generateContent([content]);
        if (response.text != null && response.text!.trim().isNotEmpty) {
          _workingModelName = modelName;
          return _formatResponseText(response.text!);
        }
      } catch (e) {
        continue;
      }
    }

    return 'ඡායාරූපය විශ්ලේෂණය කිරීමට නොහැකි විය. කරුණාකර නැවත උත්සාහ කරන්න.';
  }
}
