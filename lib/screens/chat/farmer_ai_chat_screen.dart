import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import '../../models/diary_entry.dart';
import '../../services/agro_intel_service.dart';
import '../../services/gemini_service.dart';
import '../../services/storage_service.dart';
import '../../services/turso/turso_service.dart';
import '../../theme/app_theme.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final String time;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
  });
}

class FarmerAiChatScreen extends StatefulWidget {
  const FarmerAiChatScreen({Key? key}) : super(key: key);

  @override
  State<FarmerAiChatScreen> createState() => _FarmerAiChatScreenState();
}

class _FarmerAiChatScreenState extends State<FarmerAiChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final StorageService _storage = StorageService();

  bool _isLoading = false;
  bool _isSpeaking = false;
  String? _currentlySpeakingText;
  FarmIntelSnapshot? _farmSnapshot;

  bool get isHindi => AppLanguage().isHindi;

  late List<ChatMessage> _messages;

  final List<Map<String, String>> _villagerQuickQuestions = [
    {
      'hi': '💦 मेरी जमीन में नमी कम है, पानी दूं या नहीं?',
      'en': '💦 My soil is dry, should I irrigate today or wait?',
    },
    {
      'hi': '🌿 पत्तियों में पीलापन आ रहा है, क्या समाधान है?',
      'en': '🌿 Leaves are turning yellow, what should I do?',
    },
    {
      'hi': '🧪 1 एकड़ में कितना यूरिया और DAP डालना चाहिए?',
      'en': '🧪 How much Urea and DAP per acre is recommended?',
    },
    {
      'hi': '🐛 फसल पर रस चूसक कीड़े लग रहे हैं, देसी उपाय बताएं',
      'en': '🐛 Sucking pests on my crop, tell me an organic remedy',
    },
    {
      'hi': '🌧️ कल बारिश का अंदेशा है, क्या आज कीटनाशक छिड़कूं?',
      'en': '🌧️ Rain expected tomorrow, should I spray pesticide today?',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initWelcomeMessage();
    _loadLiveContext();
  }

  Future<void> _loadLiveContext() async {
    try {
      final snap = await AgroIntelService().buildFarmIntelSnapshot();
      if (mounted) {
        setState(() => _farmSnapshot = snap);
      }
    } catch (_) {}
  }

  void _initWelcomeMessage() {
    _messages = [
      ChatMessage(
        text: isHindi
            ? 'राम राम किसान भाई! 🙏 अपनी जमीन, पानी, पत्तियों या खाद के बारे में अपनी भाषा में पूछें — सीधा व सटीक जवाब पाएं।'
            : 'Ram Ram Kisan Ji! 🙏 Ask me anything about soil moisture, irrigation timing, crop leaves, or fertilizer dosage.',
        isUser: false,
        time: _formatCurrentTime(),
      ),
    ];
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
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

  Future<void> _sendMessage(String query) async {
    final text = query.trim();
    if (text.isEmpty || _isLoading) return;

    _textController.clear();
    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: true,
          time: _formatCurrentTime(),
        ),
      );
      _isLoading = true;
    });
    _scrollToBottom();

    // Prepare conversational history
    final history = _messages.map((m) {
      return {
        'role': m.isUser ? 'user' : 'model',
        'text': m.text,
      };
    }).toList();

    final reply = await GeminiService().chatWithFarmerAi(
      history: history,
      userMessage: text,
      isHindi: isHindi,
      farmContext: _farmSnapshot?.promptContext,
    );

    TursoService().insertAiChatCloud(
      role: 'user',
      message: text,
      locationName: _farmSnapshot?.locationLabel,
    );
    TursoService().insertAiChatCloud(
      role: 'assistant',
      message: reply,
      locationName: _farmSnapshot?.locationLabel,
    );

    if (mounted) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: reply,
            isUser: false,
            time: _formatCurrentTime(),
          ),
        );
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _speakMessage(String text) {
    setState(() {
      _isSpeaking = true;
      _currentlySpeakingText = text;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.volume_up_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 7),
      ),
    );

    Future.delayed(const Duration(seconds: 7), () {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _currentlySpeakingText = null;
        });
      }
    });
  }

  void _saveAdviceToDiary(String advice) async {
    final entry = DiaryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: isHindi ? 'AI किसान सलाह' : 'Kisan AI Advice',
      category: isHindi ? 'खेत परामर्श' : 'Farm Consultation',
      date: 'Today, Just now',
      notes: advice,
    );
    await _storage.addDiaryEntry(entry);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isHindi ? '✓ खेत डायरी में सुरक्षित कर लिया गया' : '✓ Saved to Farm Diary!',
            style: const TextStyle(fontFamily: 'Mukta', fontWeight: FontWeight.w500),
          ),
          backgroundColor: AppColors.primaryGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _openVoiceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDD6C4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.mic_rounded, color: Colors.white, size: 38),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isHindi ? 'बोलिए किसान जी, AI सुन रहा है...' : 'Speak now, Kisan AI is listening...',
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isHindi
                    ? 'उदा. "मेरी जमीन में पानी देना चाहिए या नहीं?"'
                    : 'e.g. "Should I water my crop today or not?"',
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _villagerQuickQuestions.take(3).map((q) {
                  final text = isHindi ? q['hi']! : q['en']!;
                  return ActionChip(
                    backgroundColor: const Color(0xFFF7F5EE),
                    label: Text(
                      text,
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _sendMessage(text);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5EE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.mintTint,
                borderRadius: BorderRadius.circular(19),
                border: Border.all(color: const Color(0xFFA6DBB2), width: 1.2),
              ),
              child: const Center(
                child: Icon(Icons.psychology_rounded, color: AppColors.primaryGreen, size: 22),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isHindi ? 'किसान AI मित्र' : 'Kisan AI Dost',
                        style: const TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2E7D32),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    isHindi ? 'हमेशा सक्रिय · अपनी स्थानीय भाषा में पूछें' : 'Always Active · Ask in your language',
                    style: const TextStyle(
                      fontFamily: 'Mukta',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textDark, size: 22),
            tooltip: isHindi ? 'बातचीत रीसेट करें' : 'Reset Chat',
            onPressed: () {
              setState(() {
                _initWelcomeMessage();
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Live Field Telemetry Bento Pill Bar
            if (_farmSnapshot != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: AppColors.borderLight)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTelemetryPill(
                        icon: Icons.wb_sunny_outlined,
                        label: '${_farmSnapshot!.weather.temperature.round()}°C · ${_farmSnapshot!.weather.rainChance}%',
                        bg: const Color(0xFFFEF7E6),
                        fg: const Color(0xFFB45309),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildTelemetryPill(
                        icon: Icons.water_drop_rounded,
                        label: isHindi
                            ? 'नमी ${_farmSnapshot!.weather.soilMoistureRoot}%'
                            : 'Moist ${_farmSnapshot!.weather.soilMoistureRoot}%',
                        bg: const Color(0xFFEBF7FD),
                        fg: const Color(0xFF0369A1),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildTelemetryPill(
                        icon: Icons.science_outlined,
                        label: 'Soil pH ${_farmSnapshot!.soil.ph}',
                        bg: AppColors.mintTint,
                        fg: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),

            // Messages List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildMessageBubble(msg);
                },
              ),
            ),

            if (_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isHindi ? 'किसान AI उत्तर तैयार कर रहा है...' : 'Kisan AI is thinking...',
                      style: const TextStyle(
                        fontFamily: 'Mukta',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

            // Horizontal Quick Prompt Chips
            Container(
              height: 40,
              margin: const EdgeInsets.only(bottom: 6),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: _villagerQuickQuestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final item = _villagerQuickQuestions[index];
                  final label = isHindi ? item['hi']! : item['en']!;
                  return Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _sendMessage(label),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFDDD6C4), width: 0.8),
                        ),
                        child: Center(
                          child: Text(
                            label,
                            style: const TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Input Bar
            Container(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE5DECE), width: 1)),
              ),
              child: Row(
                children: [
                  // Mic button for voice input
                  Material(
                    color: const Color(0xFFEFF8F1),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _openVoiceDialog,
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.mic_rounded, color: AppColors.primaryGreen, size: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Text input field
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                      decoration: InputDecoration(
                        hintText: isHindi
                            ? 'अपनी स्थानीय भाषा में पूछें (उदा. जमीन में पानी दूं?)...'
                            : 'Ask in your everyday language...',
                        hintStyle: const TextStyle(
                          fontFamily: 'Mukta',
                          fontSize: 13.5,
                          color: AppColors.textMuted,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF7F5EE),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Send button
                  Material(
                    color: AppColors.primaryGreen,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => _sendMessage(_textController.text),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    if (msg.isUser) {
      // User message
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 40),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFF1E4D2B),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                msg.text,
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                msg.time,
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 10,
                  color: Color(0xFFA6DBB2),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Kisan AI message
    final isPlaying = _isSpeaking && _currentlySpeakingText == msg.text;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14, right: 30),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          border: Border.all(color: const Color(0xFFE5DECE), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              offset: Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.mintTint,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.eco_rounded, size: 14, color: AppColors.primaryGreen),
                ),
                const SizedBox(width: 6),
                Text(
                  isHindi ? 'किसान AI मित्र' : 'Kisan AI Companion',
                  style: const TextStyle(
                    fontFamily: 'Mukta',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const Spacer(),
                Text(
                  msg.time,
                  style: const TextStyle(
                    fontFamily: 'Mukta',
                    fontSize: 10.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              msg.text,
              style: const TextStyle(
                fontFamily: 'Mukta',
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
                height: 1.38,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                // Listen Button
                Material(
                  color: isPlaying ? AppColors.accentGold : const Color(0xFFEFF8F1),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => _speakMessage(msg.text),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPlaying ? Icons.volume_up_rounded : Icons.volume_up_outlined,
                            size: 15,
                            color: isPlaying ? Colors.white : AppColors.primaryGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isPlaying
                                ? (isHindi ? 'सुन रहे हैं...' : 'Playing...')
                                : (isHindi ? 'सुनें' : 'Listen'),
                            style: TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isPlaying ? Colors.white : AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Save to Diary button
                Material(
                  color: const Color(0xFFF7F5EE),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => _saveAdviceToDiary(msg.text),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bookmark_add_outlined, size: 14, color: AppColors.textDark),
                          const SizedBox(width: 4),
                          Text(
                            isHindi ? 'डायरी' : 'Diary',
                            style: const TextStyle(
                              fontFamily: 'Mukta',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryPill({
    required IconData icon,
    required String label,
    required Color bg,
    required Color fg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Mukta',
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

