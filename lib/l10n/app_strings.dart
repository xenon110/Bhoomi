import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

class AppLanguage extends ChangeNotifier {
  static final AppLanguage _instance = AppLanguage._internal();
  factory AppLanguage() => _instance;
  AppLanguage._internal() {
    try {
      final profLang = StorageService().getProfile().language;
      if (profLang.isNotEmpty) {
        _currentLang = profLang;
      }
    } catch (_) {}
  }

  String _currentLang = 'English';
  String get currentLang => _currentLang;
  bool get isHindi => _currentLang == 'हिन्दी';

  void setLanguage(String lang) {
    if (_currentLang != lang) {
      _currentLang = lang;
      StorageService().setLanguage(lang);
      notifyListeners();
    }
  }

  void toggleLanguage() {
    setLanguage(isHindi ? 'English' : 'हिन्दी');
  }

  String t(String key) {
    final Map<String, Map<String, String>> strings = {
      // Bottom Nav
      'nav_home': {'en': 'Home', 'hi': 'होम'},
      'nav_farm': {'en': 'My Farm', 'hi': 'मेरा खेत'},
      'nav_advice': {'en': 'Advice', 'hi': 'सलाह'},
      'nav_market': {'en': 'Market', 'hi': 'बाजार'},
      'nav_profile': {'en': 'Profile', 'hi': 'प्रोफ़ाइल'},

      // Top bar & App Tagline
      'app_name': {'en': 'Bhoomi', 'hi': 'भूमि'},
      'app_tagline': {'en': 'Bhoomi Se Mandi Tak', 'hi': 'भूमि से मंडी तक, हर कदम पर साथ'},

      // Home Screen
      'greeting_sub': {'en': 'YOUR FARMING COMPANION', 'hi': 'आपका सच्चा खेती साथी'},
      'greeting_title': {'en': 'Namaste,\nKisan Ji! 👋', 'hi': 'नमस्ते,\nकिसान जी! 👋'},
      'greeting_desc': {
        'en': "Let's make today's farming a little easier.",
        'hi': 'आइए आज की खेती को थोड़ा आसान बनाएं।'
      },
      'today_weather': {'en': '★ TODAY\'S WEATHER', 'hi': '★ आज का मौसम'},
      'partly_cloudy': {'en': 'Partly cloudy', 'hi': 'आंशिक रूप से बादल'},
      'rain_chance': {'en': 'rain chance', 'hi': 'बारिश की संभावना'},
      'scan_ask_title': {'en': 'Scan & Ask', 'hi': 'स्कैन करें और पूछें'},
      'scan_ask_desc': {
        'en': 'Photo your crop, get answers',
        'hi': 'फोटो लें, समाधान पाएं'
      },
      'scan_btn': {'en': 'Scan', 'hi': 'स्कैन'},
      'need_today': {'en': 'What do you need today?', 'hi': 'आज आपको क्या मदद चाहिए?'},
      'action_my_farm': {'en': 'My Farm', 'hi': 'मेरा खेत'},
      'action_my_farm_sub': {'en': 'Your fields', 'hi': 'आपके खेत'},
      'action_advice': {'en': "Today's Advice", 'hi': 'आज की सलाह'},
      'action_advice_sub': {'en': 'For your crops', 'hi': 'फसलों के लिए सलाह'},
      'action_planner': {'en': 'Farm Planner', 'hi': 'खेत प्लानर'},
      'action_planner_sub': {'en': 'Plan your land', 'hi': 'जमीन की योजना'},
      'action_market': {'en': 'Market Prices', 'hi': 'मंडी भाव'},
      'action_market_sub': {'en': 'Crop rates', 'hi': 'फसलों के भाव'},
      'reminder_head': {'en': 'A little reminder', 'hi': 'आज का छोटा सुझाव'},
      'farm_diary_link': {'en': 'Farm diary →', 'hi': 'खेत डायरी →'},
      'reminder_title': {'en': 'Check your leaves today', 'hi': 'आज पत्तियों की जांच करें'},
      'reminder_desc': {
        'en': 'Look for early signs of pests or unusual spots.',
        'hi': 'कीटों या असामान्य धब्बों के शुरुआती लक्षण देखें।'
      },
      'weather_tap_hint': {'en': 'Tap for 3-day advisory →', 'hi': '3 दिन की कृषि सलाह देखें →'},
      'season_badge': {'en': 'Rabi Season · 2026', 'hi': 'रबी मौसम · 2026'},
      'log_diary_btn': {'en': '+ Add to Diary', 'hi': '+ डायरी में जोड़ें'},

      // My Farm Screen
      'farm_header_sub': {'en': 'YOUR LAND, YOUR HARD WORK', 'hi': 'आपकी जमीन, आपकी मेहनत'},
      'farm_header_title': {'en': 'My Farm', 'hi': 'मेरा खेत'},
      'farm_header_desc': {
        'en': 'Your crops and land, all in one place.',
        'hi': 'आपकी फसलें और जमीन, सब एक जगह।'
      },
      'reg_land': {'en': 'REGISTERED LAND', 'hi': 'पंजीकृत जमीन'},
      'active_fields': {'en': 'active fields', 'hi': 'सक्रिय खेत'},
      'your_crops': {'en': 'Your crops', 'hi': 'आपकी फसलें'},
      'add_crop_btn': {'en': 'Add crop', 'hi': 'फसल जोड़ें'},
      'active_tag': {'en': 'Active', 'hi': 'सक्रिय'},
      'better_use_land': {'en': 'Make better use of your land', 'hi': 'अपनी जमीन का बेहतर उपयोग करें'},
      'planner_card_desc': {
        'en': 'Design your field layout and crop allocation.',
        'hi': 'खेत का नक्शा और फसल विभाजन तैयार करें।'
      },
      'design_land_btn': {'en': 'Design my land →', 'hi': 'खेत का नक्शा बनाएं →'},
      'farm_diary_title': {'en': 'Farm Diary', 'hi': 'खेत डायरी'},
      'farm_diary_desc': {
        'en': 'Keep track of daily field activities.',
        'hi': 'दैनिक खेत के कामों को दर्ज करें।'
      },
      'open_btn': {'en': 'Open →', 'hi': 'खोलें →'},

      // Today's Advice Screen
      'advice_sub': {'en': 'HELP FOR YOUR CROPS', 'hi': 'फसलों के लिए मददगार सुझाव'},
      'advice_title': {'en': "Today's Advice", 'hi': 'आज की सलाह'},
      'advice_desc': {'en': 'Simple guidance for your farm.', 'hi': 'आपके खेत के लिए सरल मार्गदर्शन।'},
      'for_your_crops': {'en': 'For your crops', 'hi': 'आपकी फसलों के लिए'},
      'listen_hindi': {'en': 'Listen in Hindi', 'hi': 'आवाज में सुनें'},
      'disclaimer_note': {
        'en': 'Sample guidance only. Verify local conditions and consult KVK before chemical treatment.',
        'hi': 'केवल सांकेतिक सलाह। रासायनिक उपचार से पहले स्थानीय कृषि विशेषज्ञ या KVK से संपर्क करें।'
      },

      // Market Screen
      'market_sub': {'en': 'KNOW YOUR MARKET', 'hi': 'मंडी का सही भाव'},
      'market_title': {'en': 'Market Prices', 'hi': 'मंडी भाव'},
      'market_desc': {
        'en': 'Compare indicative prices before selling.',
        'hi': 'फसल बेचने से पहले आसपास की मंडियों के भाव की तुलना करें।'
      },
      'tab_mandi_prices': {'en': 'Mandi Prices', 'hi': 'मंडी भाव'},
      'tab_sell_crop': {'en': 'Sell My Crop', 'hi': 'फसल बेचें'},
      'tab_buyers': {'en': 'Verified Buyers', 'hi': 'प्रमाणित खरीदार'},
      'select_crop': {'en': 'Select crop', 'hi': 'फसल चुनें'},
      'modal_price_label': {'en': 'MODAL MARKET PRICE', 'hi': 'औसत मंडी भाव'},
      'nearby_markets': {'en': 'Nearby markets', 'hi': 'आसपास की मंडियां'},
      'per_quintal': {'en': 'Per quintal', 'hi': 'प्रति क्विंटल'},

      // Profile Screen
      'profile_sub': {'en': 'YOUR SPACE', 'hi': 'आपकी प्रोफाइल'},
      'profile_title': {'en': 'Profile', 'hi': 'प्रोफ़ाइल'},
      'opt_personal': {'en': 'Personal details', 'hi': 'व्यक्तिगत विवरण'},
      'opt_my_farm': {'en': 'My Farm', 'hi': 'मेरा खेत'},
      'opt_diary': {'en': 'Farm Diary', 'hi': 'खेत डायरी'},
      'opt_language': {'en': 'Language', 'hi': 'भाषा बदलें'},
      'opt_help': {'en': 'Help & support', 'hi': 'मदद व किसान कॉल सेंटर'},
      'opt_notif': {'en': 'Notification Preferences', 'hi': 'सूचना प्राथमिकताएं'},
      'opt_privacy': {'en': 'Privacy & Data Protection', 'hi': 'गोपनीयता और डेटा सुरक्षा'},
    };

    final langKey = isHindi ? 'hi' : 'en';
    return strings[key]?[langKey] ?? strings[key]?['en'] ?? key;
  }
}

class AppLocalizations {
  static AppLanguage of(dynamic context) => AppLanguage();
}
