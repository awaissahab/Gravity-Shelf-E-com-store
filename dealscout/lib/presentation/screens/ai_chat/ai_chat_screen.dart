import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/env.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  
  GenerativeModel? _model;

  @override
  void initState() {
    super.initState();
    _initializeAI();
    _addWelcomeMessage();
  }

  void _initializeAI() {
    if (Env.googleAiApiKey != 'YOUR_GOOGLE_AI_API_KEY') {
      _model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: Env.googleAiApiKey,
      );
    }
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(ChatMessage(
        text: "Hi! I'm your DealScout AI assistant. I can help you find the best deals nearby. Ask me anything like:\n\n• \"Best restaurant deals near me?\"\n• \"Where can I buy cheap shoes?\"\n• \"Biggest discount today?\"\n• \"Grocery deals under \$20?\"",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Add user message
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      String response;
      
      if (_model != null) {
        // Use Google AI
        final content = Content.text(text);
        final streamResponse = await _model!.generateContentStream(content);
        response = '';
        
        for (var chunk in streamResponse) {
          if (chunk.text != null) {
            response += chunk.text!;
            setState(() {});
          }
        }
      } else {
        // Fallback response when API key not configured
        await Future.delayed(const Duration(seconds: 1));
        response = _getFallbackResponse(text);
      }

      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: "Sorry, I encountered an error. Please try again.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }
  }

  String _getFallbackResponse(String query) {
    final lowerQuery = query.toLowerCase();
    
    if (lowerQuery.contains('restaurant')) {
      return "I'd recommend checking out these restaurants with great deals:\n\n🍽️ **Olive Garden** - 30% off lunch specials\n🍔 **Burger King** - Buy 1 Get 1 Free on Whoppers\n🍕 **Domino's** - 50% off large pizzas\n\nWould you like directions to any of these?";
    } else if (lowerQuery.contains('shoe') || lowerQuery.contains('fashion')) {
      return "Here are some amazing fashion deals:\n\n👟 **Nike Store** - Up to 40% off sneakers\n👗 **H&M** - 25% off entire collection\n👠 **Foot Locker** - BOGO 50% off\n\nShall I show you these on the map?";
    } else if (lowerQuery.contains('grocer')) {
      return "Check out these grocery savings:\n\n🛒 **Whole Foods** - 20% off organic produce\n🥛 **Trader Joe's** - Special discounts on dairy\n🍎 **Safeway** - Buy 2 Get 1 Free on selected items\n\nWant me to create a shopping list?";
    } else if (lowerQuery.contains('discount') || lowerQuery.contains('biggest')) {
      return "Today's biggest discounts:\n\n💥 **Electronics Hub** - 60% off laptops\n💥 **Fashion Outlet** - 70% off winter collection\n💥 **Home Decor** - 50% off everything\n\nThese deals expire soon!";
    } else {
      return "I can help you find deals on:\n\n• Restaurants & Food\n• Fashion & Shoes\n• Groceries\n• Electronics\n• Beauty Products\n• Travel\n\nWhat are you looking for today?";
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: AppConstants.animationDuration,
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.smart_toy_rounded, size: 28),
            SizedBox(width: 8),
            Text('AI Assistant'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              setState(() {
                _messages.clear();
                _addWelcomeMessage();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _MessageBubble(message: _messages[index]);
              },
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingMd,
                vertical: AppConstants.spacingSm,
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.smart_toy_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingSm),
                  const Text('AI is thinking...'),
                ],
              ),
            ),

          // Input Field
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Ask about deals...',
                      filled: true,
                      fillColor: AppTheme.surfaceLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingMd,
                        vertical: AppConstants.spacingSm,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingSm),
                FloatingActionButton(
                  mini: true,
                  onPressed: _isLoading ? null : _sendMessage,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Row(
          mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!message.isUser) ...[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppConstants.spacingSm),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                decoration: BoxDecoration(
                  gradient: message.isUser ? AppTheme.primaryGradient : null,
                  color: message.isUser ? null : AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  boxShadow: AppTheme.cardShadow(),
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: message.isUser ? Colors.white : AppTheme.textPrimaryLight,
                  ),
                ),
              ),
            ),
            if (message.isUser) const SizedBox(width: AppConstants.spacingSm),
          ],
        ),
      ),
    );
  }
}
