import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';
import '../scan/scan_ask_screen.dart';
import '../chat/farmer_ai_chat_screen.dart';

class VoiceAssistantModal extends StatefulWidget {
  const VoiceAssistantModal({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const VoiceAssistantModal(),
    );
  }

  @override
  State<VoiceAssistantModal> createState() => _VoiceAssistantModalState();
}

class _VoiceAssistantModalState extends State<VoiceAssistantModal>
    with SingleTickerProviderStateMixin {
  bool _isListening = false;
  String _recognizedQuery = '';
  String _assistantAnswer = '';
  bool _showScanSuggestion = false;
  late AnimationController _pulseController;

  final List<Map<String, dynamic>> _quickSampleQueriesHi = [
    {
      'query': 'मेरे टमाटर के पत्ते पीले क्यों हो रहे हैं?',
      'answer':
          'किसान जी, टमाटर में पीले पत्ते नाइट्रोजन की कमी या अर्ली ब्लाइट (झुलसा रोग) के कारण हो सकते हैं। सही पहचान के लिए कृपया स्कैन करें।',
      'showScan': true,
    },
    {
      'query': 'आज अश्वगंधा में पानी देना चाहिए या नहीं?',
      'answer':
          'पलामू में आज 30% बारिश की संभावना है। हल्की सिंचाई कर सकते हैं, पर खेत में पानी जमा न होने दें।',
      'showScan': false,
    },
    {
      'query': 'डालटनगंज मंडी में सरसों का क्या भाव है?',
      'answer':
          'डालटनगंज APMC मंडी में आज सरसों का औसत भाव ₹5,520 प्रति क्विंटल दर्ज किया गया है।',
      'showScan': false,
    },
    {
      'query': 'तुसली में जैविक खाद कब डालें?',
      'answer':
          'तुलसी की शुरुआती वृद्धि के समय 2-3 किलोग्राम सड़ी हुई गोबर की खाद या वर्मीकम्पोस्ट प्रति पौधा उपयुक्त है।',
      'showScan': false,
    },
  ];

  final List<Map<String, dynamic>> _quickSampleQueriesEn = [
    {
      'query': 'Why are my tomato leaves turning yellow?',
      'answer':
          'Farmer friend, yellow leaves on tomatoes can be due to nitrogen deficiency or early blight fungus. Please scan a leaf to confirm.',
      'showScan': true,
    },
    {
      'query': 'Should I irrigate Ashwagandha today?',
      'answer':
          'There is a 30% rain probability in Palamu today. You can provide light irrigation, but avoid standing water in the field.',
      'showScan': false,
    },
    {
      'query': 'What is the mustard rate in Daltonganj Mandi?',
      'answer':
          'Average mustard price recorded today at Daltonganj APMC is ₹5,520 per quintal.',
      'showScan': false,
    },
    {
      'query': 'When should I apply organic manure to Tulsi?',
      'answer':
          'During early vegetative growth, 2-3 kg of well-rotted cow dung manure or vermicompost per plant is recommended.',
      'showScan': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _simulateVoiceInput(Map<String, dynamic> sample) {
    setState(() {
      _isListening = true;
      _recognizedQuery = sample['query'];
      _assistantAnswer = '';
      _showScanSuggestion = false;
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() {
          _isListening = false;
          _assistantAnswer = sample['answer'];
          _showScanSuggestion = sample['showScan'] ?? false;
        });
      }
    });
  }

  void _startListening() {
    final list = AppLanguage().isHindi ? _quickSampleQueriesHi : _quickSampleQueriesEn;
    _simulateVoiceInput(list[0]);
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = AppLanguage().isHindi;
    final sampleQueries = isHindi ? _quickSampleQueriesHi : _quickSampleQueriesEn;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      decoration: const BoxDecoration(
        color: AppColors.creamBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.35),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🌾 ', style: TextStyle(fontSize: 22)),
                  Text(
                    isHindi ? 'भूमि वाणी' : 'Bhoomi Voice Assistant',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textMuted),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isHindi
                ? 'अपनी भाषा में बोलें। फसल रोग, मौसम, मंडी भाव या खाद के बारे में सीधे पूछें।'
                : 'Speak in your language. Ask about crop diseases, weather, mandi rates, or fertilizer.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),

          // Voice Waveform & Mic Button
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = _isListening ? 1.0 + (_pulseController.value * 0.18) : 1.0;
              return Transform.scale(
                scale: scale,
                child: GestureDetector(
                  onTap: _startListening,
                  child: Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      color: _isListening ? Colors.redAccent : AppColors.primaryGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening ? Colors.redAccent : AppColors.primaryGreen)
                              .withOpacity(0.35),
                          blurRadius: 24,
                          spreadRadius: _isListening ? 8 : 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.graphic_eq : Icons.mic,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            _isListening
                ? (isHindi ? 'सुन रहा हूँ... बोलिए' : 'Listening... Speak now')
                : (isHindi ? 'माइक पर टैप करके बोलें' : 'Tap microphone to speak'),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _isListening ? Colors.redAccent : AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 20),

          // Recognized Speech Bubble
          if (_recognizedQuery.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.record_voice_over, color: AppColors.primaryGreen, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        isHindi ? 'आपने पूछा:' : 'You asked:',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '“$_recognizedQuery”',
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  if (_assistantAnswer.isNotEmpty) ...[
                    const Divider(height: 20),
                    Row(
                      children: [
                        const Text('🤖 ', style: TextStyle(fontSize: 16)),
                        Text(
                          isHindi ? 'भूमि का उत्तर:' : 'Bhoomi response:',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _assistantAnswer,
                      style: const TextStyle(fontSize: 13.5, color: AppColors.textDark, height: 1.35),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          if (_showScanSuggestion) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.camera_alt, color: AppColors.primaryGreen, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isHindi
                          ? 'सटीक पहचान के लिए रोग ग्रस्त पत्ती की फोटो लें।'
                          : 'Take a photo of diseased leaf for accurate scan.',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ScanAskScreen()),
                      );
                    },
                    child: Text(isHindi ? 'फोटो खींचें' : 'Take Photo', style: const TextStyle(fontSize: 11.5)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Quick voice question chips
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              isHindi ? 'या इनमें से कोई प्रश्न चुनें:' : 'Or tap a common question below:',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: sampleQueries.map((q) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.borderLight),
                    label: Text(
                      q['query'],
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textDark),
                    ),
                    onPressed: () => _simulateVoiceInput(q),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Full conversation with Kisan AI Dost
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FarmerAiChatScreen()),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 18),
              label: Text(
                isHindi ? 'किसान AI मित्र से पूरी बातचीत करें' : 'Full Conversation with Kisan AI',
                style: const TextStyle(
                  fontFamily: 'Mukta',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

