import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../../core/utils/language_controller.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiService _geminiService = GeminiService();

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final isSinhala = LanguageController.instance.isSinhala;
    _messages.add(
      ChatMessage(
        text: isSinhala
            ? '🌱 ආයුබෝවන්! මම ඔබගේ "ගොවි AI" උපදේශක සහයකයා. 🌾\n\nඔබගේ වගාවන්හි පළිබෝධ පාලනය, පොහොර යෙදීම, රෝග හඳුනා ගැනීම හෝ කාලගුණ උපදෙස් පිළිබඳව ඕනෑම ප්‍රශ්නයක් පහතින් අසන්න.'
            : '🌱 Welcome! I am your "Govi AI" Farming Advisor. 🌾\n\nAsk me anything about pest control, fertilizer usage, plant disease diagnosis, or weather advice for your crops!',
        isUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSubmitted(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty || _isLoading) return;

    _textController.clear();
    setState(() {
      _messages.add(ChatMessage(text: trimmedText, isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();

    final response = await _geminiService.sendMessage(trimmedText);

    if (mounted) {
      setState(() {
        _messages.add(ChatMessage(text: response, isUser: false));
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageController.instance,
      builder: (context, lang, child) {
        final isSinhala = LanguageController.instance.isSinhala;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.lightLavender,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.lavenderDarkText),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🌱', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSinhala ? 'ගොවි AI උපදේශක' : 'Govi AI Assistant',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lavenderDarkText,
                      ),
                    ),
                    Text(
                      isSinhala ? 'Gemini AI මගින් බලගැන්වේ' : 'Powered by Gemini AI',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.lavenderDarkText.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              // Suggestions Chips Bar
              _buildSuggestionsBar(isSinhala),

              // Chat Messages List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _buildMessageRow(message);
                  },
                ),
              ),

              // Loading Indicator
              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.cardMint,
                          shape: BoxShape.circle,
                        ),
                        child: const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isSinhala ? '🌾 ගොවි AI උපදෙස් සූදානම් කරමින්...' : '🌾 Govi AI is preparing advice...',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.lavenderDarkText.withAlpha(200),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              // Input Bar
              _buildInputBar(isSinhala),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSuggestionsBar(bool isSinhala) {
    final suggestions = isSinhala
        ? [
            '🌾 වී වගාවට කාබනික පොහොර',
            '🐛 කොළ කෑමේ පණුවන් පාලනය',
            '🍅 තක්කාලි වගාවේ රෝග',
            '🌧️ වැසි සමයේ වගා උපදෙස්',
            '🌽 ඉරිඟු වගාවේ පළිබෝධ',
          ]
        : [
            '🌾 Organic fertilizers for paddy',
            '🐛 Pest control tips',
            '🍅 Tomato plant care',
            '🌧️ Rainy season advice',
            '🌽 Corn crop pests',
          ];

    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ActionChip(
            backgroundColor: AppColors.cardMint,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            label: Text(
              suggestions[index],
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E634F),
              ),
            ),
            onPressed: () => _handleSubmitted(suggestions[index]),
          );
        },
      ),
    );
  }

  Widget _buildMessageRow(ChatMessage message) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Avatar Icon
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Text('🌱', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 8),
          ],

          // Message Content Bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isUser ? AppColors.darkPill : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                border: isUser ? null : Border.all(color: AppColors.lightLavender, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.5,
                  letterSpacing: 0.1,
                  fontWeight: isUser ? FontWeight.w500 : FontWeight.w400,
                  color: isUser ? Colors.white : AppColors.lavenderDarkText,
                ),
              ),
            ),
          ),

          // User Avatar Icon
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.darkPill,
                shape: BoxShape.circle,
              ),
              child: const Text('👨‍🌾', style: TextStyle(fontSize: 16)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputBar(bool isSinhala) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                textInputAction: TextInputAction.send,
                onSubmitted: _handleSubmitted,
                decoration: InputDecoration(
                  hintText: isSinhala ? 'ඔබගේ වගා ප්‍රශ්නය මෙහි සටහන් කරන්න...' : 'Ask your farming question...',
                  hintStyle: TextStyle(
                    color: AppColors.lavenderDarkText.withAlpha(140),
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: AppColors.primary,
              shape: const CircleBorder(),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
