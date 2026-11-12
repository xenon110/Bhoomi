import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'network/http_helper.dart';

class GeminiCropDiagnosis {
  final String cropName;
  final String cropNameEn;
  final String diseaseNameHi;
  final String diseaseNameEn;
  final String severity;
  final String severityEn;
  final String dangerTitle;
  final String dangerTitleEn;
  final String dangerDescription;
  final String dangerDescriptionEn;
  final String immediateAction;
  final String immediateActionEn;
  final String cause;
  final String causeEn;
  final String organicTreatment;
  final String organicTreatmentEn;
  final String chemicalTreatment;
  final String chemicalTreatmentEn;
  final String voiceSummary;
  final String voiceSummaryEn;
  final bool isAiGenerated;
  final bool isRelevant;
  final String irrelevanceReasonHi;
  final String irrelevanceReasonEn;
  final String scanType;

  const GeminiCropDiagnosis({
    required this.cropName,
    this.cropNameEn = '',
    required this.diseaseNameHi,
    required this.diseaseNameEn,
    required this.severity,
    this.severityEn = '',
    this.dangerTitle = 'मध्यम खतरा: पत्ती झुलसा व उत्पादन में गिरावट',
    this.dangerTitleEn = 'Moderate Danger: Foliage Blight & Yield Loss',
    this.dangerDescription = 'यदि समय पर उपचार नहीं किया गया तो 30-40% तक उपज का नुकसान हो सकता है।',
    this.dangerDescriptionEn = 'Can cause 30-40% yield loss if untreated within 7-10 days.',
    this.immediateAction = 'प्रभावित पत्तियों को तुरंत हटाकर नष्ट करें और खेत में जलभराव न होने दें।',
    this.immediateActionEn = 'Prune severely infected leaves immediately and avoid overhead watering.',
    required this.cause,
    this.causeEn = '',
    required this.organicTreatment,
    this.organicTreatmentEn = '',
    required this.chemicalTreatment,
    this.chemicalTreatmentEn = '',
    required this.voiceSummary,
    this.voiceSummaryEn = '',
    this.isAiGenerated = true,
    this.isRelevant = true,
    this.irrelevanceReasonHi = '',
    this.irrelevanceReasonEn = '',
    this.scanType = 'leaf',
  });

  String getCropName(bool isHindi) =>
      isHindi ? cropName : (cropNameEn.isNotEmpty ? cropNameEn : cropName);

  String getDiseaseName(bool isHindi) =>
      isHindi ? diseaseNameHi : (diseaseNameEn.isNotEmpty ? diseaseNameEn : diseaseNameHi);

  String getSeverity(bool isHindi) =>
      isHindi ? severity : (severityEn.isNotEmpty ? severityEn : severity);

  String getDangerTitle(bool isHindi) =>
      isHindi ? dangerTitle : (dangerTitleEn.isNotEmpty ? dangerTitleEn : dangerTitle);

  String getDangerDescription(bool isHindi) =>
      isHindi ? dangerDescription : (dangerDescriptionEn.isNotEmpty ? dangerDescriptionEn : dangerDescription);

  String getImmediateAction(bool isHindi) =>
      isHindi ? immediateAction : (immediateActionEn.isNotEmpty ? immediateActionEn : immediateAction);

  String getCause(bool isHindi) =>
      isHindi ? cause : (causeEn.isNotEmpty ? causeEn : cause);

  String getOrganicTreatment(bool isHindi) =>
      isHindi ? organicTreatment : (organicTreatmentEn.isNotEmpty ? organicTreatmentEn : organicTreatment);

  String getChemicalTreatment(bool isHindi) =>
      isHindi ? chemicalTreatment : (chemicalTreatmentEn.isNotEmpty ? chemicalTreatmentEn : chemicalTreatment);

  String getVoiceSummary(bool isHindi) =>
      isHindi ? voiceSummary : (voiceSummaryEn.isNotEmpty ? voiceSummaryEn : voiceSummary);

  String getIrrelevanceReason(bool isHindi) =>
      isHindi
          ? (irrelevanceReasonHi.isNotEmpty
              ? irrelevanceReasonHi
              : 'यह फोटो किसी फसल, पौधे की पत्ती, मिट्टी या कृषि कीट की नहीं है। कृपया खेत से संबंधित स्पष्ट फोटो लें।')
          : (irrelevanceReasonEn.isNotEmpty
              ? irrelevanceReasonEn
              : 'This image does not contain a crop, leaf, soil, or agricultural pest. Please take a clear photo of a farming subject.');

  factory GeminiCropDiagnosis.irrelevant({
    required String subjectName,
    String? reasonHi,
    String? reasonEn,
  }) {
    final hi = reasonHi ??
        'यह फोटो किसी फसल, पौधे की पत्ती, मिट्टी या कृषि कीट की नहीं लग रही है। Bhoomi AI केवल कृषि व फसल निदान के लिए है।';
    final en = reasonEn ??
        'This photo does not appear to be a crop, leaf, soil, or farm pest. Bhoomi AI is trained specifically for agricultural diagnosis.';
    return GeminiCropDiagnosis(
      cropName: subjectName,
      cropNameEn: subjectName,
      diseaseNameHi: 'असंबंधित या अस्पष्ट फोटो',
      diseaseNameEn: 'Non-Agricultural Object',
      severity: 'अमान्य',
      severityEn: 'Invalid Subject',
      dangerTitle: 'कोई कृषि खतरा नहीं पाया गया',
      dangerTitleEn: 'No Agricultural Threat Detected',
      dangerDescription: hi,
      dangerDescriptionEn: en,
      immediateAction: 'कृपया खेत की स्पष्ट फोटो अपलोड करें।',
      immediateActionEn: 'Please upload a clear agricultural photo.',
      cause: hi,
      causeEn: en,
      organicTreatment: '',
      organicTreatmentEn: '',
      chemicalTreatment: '',
      chemicalTreatmentEn: '',
      voiceSummary: hi,
      voiceSummaryEn: en,
      isAiGenerated: true,
      isRelevant: false,
      irrelevanceReasonHi: hi,
      irrelevanceReasonEn: en,
      scanType: 'other',
    );
  }

  factory GeminiCropDiagnosis.fallback({
    String crop = 'Ashwagandha leaf',
    String category = 'leaf',
  }) {
    final lower = crop.toLowerCase();

    // Check for irrelevant / non-farming test cases
    if (category == 'other' ||
        lower.contains('car') ||
        lower.contains('vehicle') ||
        lower.contains('furniture') ||
        lower.contains('room') ||
        lower.contains('selfie') ||
        lower.contains('face') ||
        lower.contains('shoe') ||
        lower.contains('laptop') ||
        lower.contains('dog') ||
        lower.contains('cat') ||
        lower.contains('non-agri') ||
        lower.contains('unclear') ||
        lower.contains('blurry') ||
        lower.contains('अस्पष्ट') ||
        lower.contains('असंबंधित')) {
      return GeminiCropDiagnosis.irrelevant(
        subjectName: crop,
        reasonHi:
            'यह फोटो किसी फसल, पौधे की पत्ती, मिट्टी या खेत के कीट की नहीं लग रही है। Bhoomi AI केवल कृषि व फसल निदान के लिए है।',
        reasonEn:
            'This photo does not appear to be a crop, leaf, soil, or agricultural pest. Bhoomi AI is trained specifically for farm diagnosis.',
      );
    }

    if (category == 'soil' || lower.contains('soil') || lower.contains('मिट्टी')) {
      return const GeminiCropDiagnosis(
        cropName: 'काली दोमट मिट्टी',
        cropNameEn: 'Black Cotton Soil',
        diseaseNameHi: 'नाइट्रोजन व सूक्ष्म पोषक तत्वों की कमी',
        diseaseNameEn: 'Nitrogen & Zinc Deficiency',
        severity: 'मध्यम कमी (60%)',
        severityEn: 'Moderate Deficiency (60%)',
        dangerTitle: 'पोषक तत्वों की गंभीर कमी से पौधों का विकास रुकना',
        dangerTitleEn: 'Nutrient Starvation: Stunted Growth & Low Tillers',
        dangerDescription: 'नाइट्रोजन और जिंक की कमी से फसल पीली पड़ जाती है, फुटाव कम होता है और 25-35% तक उत्पादन घट सकता है।',
        dangerDescriptionEn: 'Low nitrogen and zinc halts active tillering and causes leaf yellowing, reducing crop yield by 25-35%.',
        immediateAction: 'सिंचाई से पूर्व खेत में अच्छी सड़ी गोबर की खाद या वर्मीकम्पोस्ट मिलाएं।',
        immediateActionEn: 'Incorporate well-decomposed manure or vermicompost before next irrigation.',
        cause: 'लगातार सघन खेती और कम जैविक खाद के कारण मिट्टी में मुख्य पोषक तत्वों का संतुलन बिगड़ा है।',
        causeEn: 'Intensive cropping with inadequate organic manure has depleted essential soil micronutrients.',
        organicTreatment: 'जीवामृत 200 लीटर प्रति एकड़ सिंचाई के पानी के साथ चलाएं या केंचुआ खाद 4 ट्रॉली/एकड़ डालें।',
        organicTreatmentEn: 'Apply 200L/acre Jeevamrut with irrigation water and incorporate 4 tonnes/acre vermicompost.',
        chemicalTreatment: 'यूरिया 40 किग्रा और जिंक सल्फेट (21%) 10 किग्रा प्रति एकड़ पहली सिंचाई के समय प्रयोग करें।',
        chemicalTreatmentEn: 'Apply 40 kg Urea and 10 kg Zinc Sulphate (21%) per acre at first irrigation.',
        voiceSummary: 'मिट्टी में नाइट्रोजन और जिंक की कमी है। जैविक खाद और संतुलित उर्वरक का प्रयोग करें।',
        voiceSummaryEn: 'Soil test shows nitrogen and zinc deficiency. Apply organic compost and balanced fertilizers.',
        isAiGenerated: false,
        isRelevant: true,
        scanType: 'soil',
      );
    }

    if (category == 'bottle_card' ||
        lower.contains('bottle') ||
        lower.contains('card') ||
        lower.contains('fertilizer') ||
        lower.contains('pesticide') ||
        lower.contains('बोतल') ||
        lower.contains('कार्ड')) {
      return const GeminiCropDiagnosis(
        cropName: 'कृषि रसायन / मृदा कार्ड',
        cropNameEn: 'Agri Bottle / Soil Card',
        diseaseNameHi: 'मृदा स्वास्थ्य कार्ड व रसायन मात्रा विश्लेषण',
        diseaseNameEn: 'Soil Card & Chemical Dosage Breakdown',
        severity: 'सावधानी आवश्यक (Safety Check)',
        severityEn: 'Safety & Dosage Verified',
        dangerTitle: 'अधिक मात्रा से फसल झुलसने और मिट्टी खराब होने का खतरा',
        dangerTitleEn: 'Over-Dosage Burn Risk & Waiting Period Alert',
        dangerDescription: 'बिना सही माप के दवा या अधिक यूरिया डालने से पत्तियां जल सकती हैं और कटाई से पहले अवशेष बच सकते हैं।',
        dangerDescriptionEn: 'Exceeding recommended dilution burns foliage and leaves unsafe chemical residue before harvest.',
        immediateAction: '15 लीटर स्प्रे पंप में माप के ढक्कन से ही घोल बनाएं और सुबह/शाम शांत हवा में छिड़काव करें।',
        immediateActionEn: 'Measure strictly with the cap per 15L knapsack pump and wear gloves/cloth mask during calm morning hours.',
        cause: 'संतुलित NPK पोषक तत्व और सही स्प्रे मात्रा उत्पादन बढ़ाकर अनावश्यक खर्च बचाती है।',
        causeEn: 'Label instructions & soil card balance maximize nutrient uptake while cutting chemical cost by 20%.',
        organicTreatment: 'रासायनिक दवा के बजाय प्रति एकड़ 200 लीटर जीवामृत या नीम तेल (5ml/लीटर) का विकल्प भी अपनाएं।',
        organicTreatmentEn: 'Where mild, consider organic Neem oil (5ml/L) or Jeevamrit soil drench to protect beneficial microbes.',
        chemicalTreatment: 'सामान्य कीटनाशक/फफूंदनाशक मात्रा: 15 लीटर पंप में 30-35ml/ग्राम मिलाएं। कटाई से 10 दिन पहले छिड़काव बंद करें।',
        chemicalTreatmentEn: 'Standard pump mix: 30-35ml or grams per 15L tank. Observe a strict 10-day pre-harvest waiting period.',
        voiceSummary: 'बोतल या मृदा कार्ड की जांच पूरी हुई। 15 लीटर टंकी में केवल 30 मिलीलीटर मात्रा ही मिलाएं और कटाई से 10 दिन पहले रुक जाएं।',
        voiceSummaryEn: 'Label and soil card scan complete. Mix strictly 30ml per 15 litre tank and stop spraying 10 days before harvest.',
        isAiGenerated: false,
        isRelevant: true,
        scanType: 'bottle_card',
      );
    }

    if (category == 'pest' ||
        lower.contains('pest') ||
        lower.contains('aphid') ||
        lower.contains('worm') ||
        lower.contains('कीट') ||
        lower.contains('माहू')) {
      return const GeminiCropDiagnosis(
        cropName: 'माहू व रस चूसक कीट',
        cropNameEn: 'Aphids & Sucking Pests',
        diseaseNameHi: 'माहू व थ्रिप्स कीट संक्रमण',
        diseaseNameEn: 'Aphid & Sucking Pest Attack',
        severity: 'गंभीर खतरा (75%)',
        severityEn: 'High Danger (75% Infested)',
        dangerTitle: 'तीव्र रस चूसकर पौधे को सुखाना व मैल फैलाना',
        dangerTitleEn: 'Severe Danger: Rapid Foliage Desiccation & Sooty Mold',
        dangerDescription: 'हजारों माहू कीट पत्तियों और कलियों का रस चूस लेते हैं जिससे पत्तियां मुड़कर सूख जाती हैं और 40-50% फसल बर्बाद हो सकती है।',
        dangerDescriptionEn: 'Aggressive aphid colonies suck sap from tender shoots, curling leaves and risking 40-50% harvest loss in 10 days.',
        immediateAction: 'खेत में तुरंत 6-8 पीले चिपचिपे कार्ड (Yellow Sticky Traps) प्रति एकड़ लगाएं।',
        immediateActionEn: 'Deploy 6-8 Yellow Sticky Traps per acre immediately to trap flying adults.',
        cause: 'नमी और बादल छाए मौसम में पत्तियों की निचली सतह पर रस चूसक कीट तेजी से पनपते हैं।',
        causeEn: 'Humid, overcast weather triggered rapid sap-sucking pest colonies on leaf undersides.',
        organicTreatment: '5ml नीम का तेल (10,000 PPM) प्रति लीटर पानी में 1ml शैम्पू के साथ मिलाकर शाम को छिड़कें।',
        organicTreatmentEn: 'Spray cold-pressed Neem oil (10,000 PPM) @ 5ml/L mixed with mild soap in the evening.',
        chemicalTreatment: 'इमिडाक्लोप्रिड 17.8% SL 0.5 मिली प्रति लीटर पानी की दर से सुबह के समय स्प्रे करें।',
        chemicalTreatmentEn: 'Apply foliar spray of Imidacloprid 17.8% SL @ 0.5ml per litre of water.',
        voiceSummary: 'आपकी फसल पर रस चूसक माहू कीट का असर है। नीम तेल या इमिडाक्लोप्रिड का छिड़काव तुरंत करें।',
        voiceSummaryEn: 'Sap-sucking aphids detected on your crop. Spray neem oil or Imidacloprid promptly.',
        isAiGenerated: false,
        isRelevant: true,
        scanType: 'pest',
      );
    }

    if (lower.contains('wheat') || lower.contains('गेहूं')) {
      return const GeminiCropDiagnosis(
        cropName: 'गेहूं की फसल',
        cropNameEn: 'Wheat Crop',
        diseaseNameHi: 'पीला रतुआ रोग (Yellow Rust)',
        diseaseNameEn: 'Stripe / Yellow Rust',
        severity: 'गंभीर खतरा (70%)',
        severityEn: 'Severe Danger (70%)',
        dangerTitle: 'हवा से तीव्र फैलाव व बालियों में दाना न बनना',
        dangerTitleEn: 'Extreme Danger: Rapid Airborne Spread & Empty Earheads',
        dangerDescription: 'यह फफूंद हवा से पूरे खेत में फैल जाती है और पत्तियों का भोजन बनाना रोक देती है, जिससे 50-70% फसल नष्ट हो सकती है।',
        dangerDescriptionEn: 'Wind-borne fungal spores spread across entire fields in 48-72 hours, preventing grain filling and risking 50-70% total crop loss.',
        immediateAction: 'खेत में तुरंत नाइट्रोजन खाद रोकें और प्रभावित हिस्सों के आसपास तुरंत स्प्रे करें।',
        immediateActionEn: 'Halt excess nitrogen fertilizer immediately and isolate infected patch with protective fungicide spray.',
        cause: 'सर्दियों के अंत में ठंडी हवा और नमी के कारण पक्सिनिया स्ट्राइफॉर्मिस फफूंद का संक्रमण होता है।',
        causeEn: 'Cold winds and high morning humidity favored Puccinia striiformis fungal infection.',
        organicTreatment: 'खट्टी छाछ (5 लीटर) 100 लीटर पानी में मिलाकर सुबह पत्तियों पर छिड़कें।',
        organicTreatmentEn: 'Spray sour buttermilk (5L in 100L water) early morning across infected foliage.',
        chemicalTreatment: 'प्रोपिकोनाजोल 25% EC (टिल्ट) 1 मिली प्रति लीटर पानी में मिलाकर 15 दिन के अंतराल पर 2 बार छिड़कें।',
        chemicalTreatmentEn: 'Apply Propiconazole 25% EC @ 1ml per litre of water at 15-day intervals.',
        voiceSummary: 'गेहूं की पत्तियों पर पीले रतुआ के लक्षण हैं। प्रोपिकोनाजोल या छाछ के घोल का छिड़काव करें।',
        voiceSummaryEn: 'Wheat foliage shows stripe rust symptoms. Spray Propiconazole or sour buttermilk solution.',
        isAiGenerated: false,
        isRelevant: true,
        scanType: 'leaf',
      );
    }

    return const GeminiCropDiagnosis(
      cropName: 'सरसों की पत्ती',
      cropNameEn: 'Mustard Leaf',
      diseaseNameHi: 'पत्तियों का धब्बा रोग (Leaf Spot)',
      diseaseNameEn: 'Cercospora Leaf Spot',
      severity: 'मध्यम से उच्च खतरा (65%)',
      severityEn: 'Moderate to High Danger (65%)',
      dangerTitle: 'पत्तियां सूखना, समय पूर्व गिरना व दाना कमजोर होना',
      dangerTitleEn: 'Foliage Blight: Premature Leaf Drop & Shriveled Pods',
      dangerDescription: 'यह फफूंद पत्तियों के 60% हिस्से को सुखा देती है जिससे पौधों में तेल व दाने का भराव कम होता है और 30-40% नुकसान हो सकता है।',
      dangerDescriptionEn: 'Necrotic fungal spots destroy active leaf surface, causing premature defoliation and up to 35-40% seed yield loss.',
      immediateAction: 'निचली रोगग्रस्त पत्तियों को तोड़कर खेत से बाहर नष्ट करें और तेज धूप से पहले दवा का छिड़काव करें।',
      immediateActionEn: 'Prune severely spotted lower leaves and apply recommended foliar spray early in the morning.',
      cause: 'अधिक नमी और फफूंद के संक्रमण के कारण पत्तियों पर भूरे-पीले धब्बे बनते हैं।',
      causeEn: 'Excessive humidity and fungal spores produced circular brown-yellow necrotic leaf spots.',
      organicTreatment: '5ml नीम का तेल (Neem Oil) प्रति लीटर पानी में मिलाकर सुबह के समय पत्तियों के दोनों तरफ छिड़कें।',
      organicTreatmentEn: 'Spray organic Neem oil (5ml/L) thoroughly on both sides of leaves in early morning.',
      chemicalTreatment: 'मैनकोजेब 75% WP (Mancozeb) 2.5 ग्राम प्रति लीटर पानी का घोल बनाकर 10 दिन के अंतराल पर छिड़कें।',
      chemicalTreatmentEn: 'Foliar spray of Mancozeb 75% WP @ 2.5g per litre of water at 10-day intervals.',
      voiceSummary: 'आपकी फसल में लीफ स्पॉट फफूंद के लक्षण हैं। प्रभावित पत्तियों को हटाएं और सुबह के समय नीम तेल का छिड़काव करें।',
      voiceSummaryEn: 'Leaf spot fungus identified. Prune severely spotted leaves and apply neem oil early morning.',
      isAiGenerated: false,
      isRelevant: true,
      scanType: 'leaf',
    );
  }
}

class GeminiMandiAdvice {
  final String cropName;
  final String mspRate;
  final String trend;
  final String trendHindi;
  final String recommendation;
  final String recommendationEn;
  final String analysis;
  final String analysisEn;
  final String bestMandi;

  const GeminiMandiAdvice({
    required this.cropName,
    required this.mspRate,
    required this.trend,
    required this.trendHindi,
    required this.recommendation,
    this.recommendationEn = 'Hold 7-10 days: Expect price gain due to millers demand.',
    required this.analysis,
    this.analysisEn = 'Active wholesale procurement keeping modal rates above benchmark MSP.',
    required this.bestMandi,
  });

  String getRecommendation(bool isHindi) => isHindi ? recommendation : (recommendationEn.isNotEmpty ? recommendationEn : recommendation);
  String getAnalysis(bool isHindi) => isHindi ? analysis : (analysisEn.isNotEmpty ? analysisEn : analysis);
  String getTrend(bool isHindi) => isHindi ? trendHindi : trend;

  factory GeminiMandiAdvice.fallback(String crop) {
    if (crop.toLowerCase().contains('mustard')) {
      return const GeminiMandiAdvice(
        cropName: 'Mustard',
        mspRate: '₹5,650 / Qtl (MSP)',
        trend: 'Bullish (+₹45)',
        trendHindi: 'तेजी (मजबूत मांग)',
        recommendation: '7-10 दिन रोकें (Hold): तेल मिलों की मांग से भाव में और सुधार संभव।',
        recommendationEn: 'Hold 7-10 days: Oil mill buying and festive demand driving prices higher.',
        analysis: 'त्योहारी मांग और प्रमुख तेल मिलों की लिवाली से सरसों के भाव MSP से ऊपर बने हुए हैं।',
        analysisEn: 'High crushing demand from domestic solvent plants keeping prices firm.',
        bestMandi: 'Sasaram Mandi (₹5,680/Qtl)',
      );
    }
    return const GeminiMandiAdvice(
      cropName: 'Crop',
      mspRate: '₹2,425 / Qtl (MSP)',
      trend: 'Bullish (+₹25)',
      trendHindi: 'स्थिर व सकारात्मक',
      recommendation: 'स्थानीय मंडियों में औसत भाव अच्छा है। 50% उपज बेच सकते हैं।',
      recommendationEn: 'Modal prices are attractive. Good window to liquidate 50% of stock.',
      analysis: 'सरकारी खरीद केंद्रों और स्थानीय व्यापारियों द्वारा सक्रिय खरीदारी जारी है।',
      analysisEn: 'Government procurement centers and regional grain aggregators buying steadily.',
      bestMandi: 'Daltonganj APMC',
    );
  }
}

class GeminiSmartBriefing {
  final String irrigationAdviceHi;
  final String irrigationAdviceEn;
  final String diseaseWindowHi;
  final String diseaseWindowEn;
  final String marketActionHi;
  final String marketActionEn;
  final String hiddenConclusionHi;
  final String hiddenConclusionEn;
  final String riskLevel; // 'low', 'moderate', 'high'
  final bool isAiGenerated;

  const GeminiSmartBriefing({
    required this.irrigationAdviceHi,
    required this.irrigationAdviceEn,
    required this.diseaseWindowHi,
    required this.diseaseWindowEn,
    required this.marketActionHi,
    required this.marketActionEn,
    required this.hiddenConclusionHi,
    required this.hiddenConclusionEn,
    required this.riskLevel,
    this.isAiGenerated = false,
  });

  String getIrrigationAdvice(bool isHindi) => isHindi ? irrigationAdviceHi : irrigationAdviceEn;
  String getDiseaseWindow(bool isHindi) => isHindi ? diseaseWindowHi : diseaseWindowEn;
  String getMarketAction(bool isHindi) => isHindi ? marketActionHi : marketActionEn;
  String getHiddenConclusion(bool isHindi) => isHindi ? hiddenConclusionHi : hiddenConclusionEn;

  factory GeminiSmartBriefing.computed({
    required double soilMoistureRoot,
    required int humidity,
    required int rainChance,
    required double netProfit,
    required String topCrop,
    required int bestRate,
    required double soilPh,
  }) {
    final needWater = soilMoistureRoot < 22.0 && rainChance < 40;
    final wetRisk = rainChance >= 60 || humidity >= 78;
    final risk = wetRisk ? 'high' : (humidity >= 65 ? 'moderate' : 'low');

    final irrigHi = needWater
        ? 'मिट्टी की जड़ नमी (${soilMoistureRoot.toStringAsFixed(0)}%) कम है — सुबह हल्की सिंचाई करें।'
        : (rainChance >= 50
            ? 'कल बारिश ($rainChance%) की संभावना है — आज सिंचाई रोकें व पानी बचाएं।'
            : 'जड़ स्तर नमी (${soilMoistureRoot.toStringAsFixed(0)}%) पर्याप्त है — 2 दिन सिंचाई की जरूरत नहीं।');
    final irrigEn = needWater
        ? 'Root soil moisture (${soilMoistureRoot.toStringAsFixed(0)}%) is low — apply light morning irrigation.'
        : (rainChance >= 50
            ? 'Rain probability is $rainChance% — skip irrigation today to prevent waterlogging.'
            : 'Root soil moisture (${soilMoistureRoot.toStringAsFixed(0)}%) is adequate — hold irrigation for 2 days.');

    final diseaseHi = wetRisk
        ? 'नमी ($humidity%) अधिक है — फफूंद/ब्लाइट का खतरा उच्च, नीम तेल 5ml/L से बचाव करें।'
        : (humidity >= 65
            ? 'मध्यम नमी ($humidity%) — सुबह शांत हवा में जैविक स्प्रे सुरक्षित है।'
            : 'मौसम साफ है — कीटनाशक छिड़काव और निराई के लिए सर्वोत्तम समय।');
    final diseaseEn = wetRisk
        ? 'High humidity ($humidity%) creates fungal blight risk — apply preventive Neem Oil (5ml/L).'
        : (humidity >= 65
            ? 'Moderate humidity ($humidity%) — safe window for early morning foliar spray.'
            : 'Dry clear window — ideal for spraying, weeding, and sun-drying harvest.');

    final mktHi = '$topCrop का औसत मंडी भाव ₹$bestRate/क्विंटल है — ग्रेडिंग के बाद ही बेचें।';
    final mktEn = '$topCrop benchmark stands at ₹$bestRate/Qtl — grade cleanly before mandi dispatch.';

    final conclusionHi =
        'सैटेलाइट मिट्टी जांच (pH $soilPh) व ${rainChance >= 50 ? "बारिश पूर्वानुमान" : "मौजूदा नमी"} को देखते हुए ${needWater ? "सिंचाई के साथ सूक्ष्म पोषक" : "अनावश्यक सिंचाई रोक कर खाद की बचत"} करना सबसे लाभदायक रहेगा।';
    final conclusionEn =
        'Combining satellite soil pH ($soilPh), root moisture (${soilMoistureRoot.toStringAsFixed(0)}%), and weather: ${needWater ? "irrigate lightly with micronutrients" : "holding water today prevents nutrient leaching and saves diesel/pump costs"}.';

    return GeminiSmartBriefing(
      irrigationAdviceHi: irrigHi,
      irrigationAdviceEn: irrigEn,
      diseaseWindowHi: diseaseHi,
      diseaseWindowEn: diseaseEn,
      marketActionHi: mktHi,
      marketActionEn: mktEn,
      hiddenConclusionHi: conclusionHi,
      hiddenConclusionEn: conclusionEn,
      riskLevel: risk,
      isAiGenerated: false,
    );
  }
}

class GeminiLedgerInsight {
  final String breakEvenHi;
  final String breakEvenEn;
  final String costTipHi;
  final String costTipEn;
  final String rotationHi;
  final String rotationEn;
  final bool isAiGenerated;

  const GeminiLedgerInsight({
    required this.breakEvenHi,
    required this.breakEvenEn,
    required this.costTipHi,
    required this.costTipEn,
    required this.rotationHi,
    required this.rotationEn,
    this.isAiGenerated = false,
  });

  String getBreakEven(bool isHindi) => isHindi ? breakEvenHi : breakEvenEn;
  String getCostTip(bool isHindi) => isHindi ? costTipHi : costTipEn;
  String getRotation(bool isHindi) => isHindi ? rotationHi : rotationEn;

  factory GeminiLedgerInsight.computed({
    required double totalExpense,
    required double totalIncome,
    required String topCategory,
    required String topCrop,
    required int mandiRate,
  }) {
    final profit = totalIncome - totalExpense;
    final requiredQty = mandiRate > 0 ? (totalExpense / mandiRate) : 3.5;

    return GeminiLedgerInsight(
      breakEvenHi:
          'आपका कुल खर्च ₹${totalExpense.toStringAsFixed(0)} है। ₹$mandiRate/क्विंटल के मंडी भाव पर लागत निकालने के लिए लगभग ${requiredQty.toStringAsFixed(1)} क्विंटल $topCrop बिक्री पर्याप्त है (${profit >= 0 ? "अभी ₹${profit.toStringAsFixed(0)} लाभ में हैं" : "कटाई बिक्री बाकी है"})।',
      breakEvenEn:
          'At total recorded spend ₹${totalExpense.toStringAsFixed(0)} and mandi rate ₹$mandiRate/Qtl, selling just ${requiredQty.toStringAsFixed(1)} Qtl of $topCrop covers all costs (${profit >= 0 ? "currently ₹${profit.toStringAsFixed(0)} net positive" : "awaiting harvest sale"}).',
      costTipHi:
          'सबसे अधिक खर्च "$topCategory" में दिख रहा है। मृदा जांच अनुसार खाद देने व किसान समूह से थोक खरीद से 15-20% खर्च घटाया जा सकता है।',
      costTipEn:
          'Your highest expense category is "$topCategory". Bulk cooperative input buying and soil-tested split urea dosing can cut input costs by 15-20%.',
      rotationHi:
          'फसल चक्र सुझाव: अगली खाली अवधि में 60-दिन की मूंग या उड़द लगाएं — यह मिट्टी में मुफ्त नाइट्रोजन बढ़ाकर अगले सीजन का यूरिया खर्च आधा कर देगी।',
      rotationEn:
          'Crop Rotation Tip: Plant short-duration 60-day Moong/Urad in the summer window to fix natural nitrogen and cut next season Urea cost by ~40%.',
      isAiGenerated: false,
    );
  }
}

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  /// Google Gemini API Key configured via `--dart-define=GEMINI_API_KEY=...`
  static String apiKey = const String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  static bool get hasApiKey => apiKey.trim().isNotEmpty;

  static const String _primaryModel = 'gemini-flash-latest';
  static const String _secondaryModel = 'gemini-2.5-flash';

  /// Diagnoses crop disease, soil condition, or pest attack using Gemini AI
  Future<GeminiCropDiagnosis> diagnoseCrop({
    required String cropName,
    String? symptoms,
    String category = 'leaf',
    Uint8List? imageBytes,
    String? mimeType,
  }) async {
    final lowerName = cropName.toLowerCase();
    final isExplicitIrrelevant = category == 'other' ||
        lowerName.contains('car') ||
        lowerName.contains('vehicle') ||
        lowerName.contains('furniture') ||
        lowerName.contains('selfie') ||
        lowerName.contains('face') ||
        lowerName.contains('shoe') ||
        lowerName.contains('laptop') ||
        lowerName.contains('non-agri') ||
        lowerName.contains('unclear') ||
        lowerName.contains('blurry') ||
        lowerName.contains('अस्पष्ट') ||
        lowerName.contains('असंबंधित');

    final prompt = '''
You are an expert Indian agricultural scientist (कृषि वैज्ञानिक) and computer vision crop doctor for the Indian farmer app "Bhoomi".
The farmer has uploaded or scanned a photo from their phone to diagnose:
Photo / Subject: $cropName
Category: $category (Options: leaf, soil, pest, bottle_card [pesticide/fertilizer bottle or Govt Soil Health Card], other/test)
Visual symptoms or context: ${symptoms ?? 'Photo uploaded from phone gallery / camera'}

CRITICAL TASK:
1. Relevance Verification: Inspect this photo / subject. Is it related to agriculture/farming (crop, plant, leaf, tree, fruit, flower, agricultural soil, farmland, farm pest/insect, fertilizer bag/pesticide bottle, Govt Soil Health Card, farming tool)?
   - If Category is "bottle_card" or photo shows a pesticide/fertilizer bottle or Soil Health Card: treat as RELEVANT! Extract exact chemical name or N-P-K / pH readings, put dosage hazards in danger_title/danger_desc, exact 15L sprayer pump dosage in immediate_action & chemical_treatment, and safer organic alternatives in organic_treatment.
   - If NOT agricultural (e.g. human face/selfie, car/vehicle, room/furniture, shoe, dog/cat, electronics, abstract/blurry non-farming photo):
     Set "is_relevant": false.
     Explain kindly in "irrelevance_reason_hi" and "irrelevance_reason_en" why it was rejected.
   - If YES, it IS agricultural:
     Set "is_relevant": true.

2. Diagnosis (provide both Hindi and English fields):
   - What is the disease/pest/deficiency? (disease_name_hi & disease_name_en)
   - Danger Level & Severity (severity & severity_en, e.g. "गंभीर खतरा 75%" / "High Danger 75%")
   - WHAT IS THE DANGER IN THAT PLANT:
     - danger_title & danger_title_en (short headline e.g. Rapid Blight & Yield Loss)
     - danger_desc & danger_desc_en (damage & harvest loss estimate if untreated)
   - WHAT TO DO (ACTION PLAN):
     - immediate_action & immediate_action_en (immediate containment step today)
     - organic_treatment & organic_treatment_en (desi / organic solution)
     - chemical_treatment & chemical_treatment_en (approved chemical fungicide/pesticide with exact dosage)
   - cause & cause_en (why it happened)
   - voice_summary & voice_summary_en (spoken advisory)

Respond ONLY with a valid raw JSON object (no markdown, no extra text) with these exact keys:
{
  "is_relevant": true,
  "irrelevance_reason_hi": "यह फोटो किसी फसल, पत्ती, मिट्टी या कृषि कीट की नहीं है...",
  "irrelevance_reason_en": "This image does not contain a crop, leaf, soil, or farm pest...",
  "scan_type": "$category",
  "crop_name": "$cropName",
  "crop_name_en": "$cropName",
  "disease_name_hi": "रोग का हिंदी नाम",
  "disease_name_en": "Disease English Name",
  "severity": "गंभीर खतरा (75%)",
  "severity_en": "High Danger (75%)",
  "danger_title": "पत्ती झुलसा व 40% उपज नुकसान का खतरा",
  "danger_title_en": "Rapid Foliage Blight & 40% Yield Loss Risk",
  "danger_desc": "यदि 7 दिन में दवा नहीं डाली तो फफूंद पूरे खेत में फैलकर दाना नहीं बनने देगी।",
  "danger_desc_en": "Fungal spores will spread across the crop in 7 days preventing grain formation.",
  "immediate_action": "प्रभावित पत्तियों को तोड़कर खेत से दूर नष्ट करें और अतिरिक्त नमी रोकें।",
  "immediate_action_en": "Prune severely spotted leaves immediately and avoid overhead watering.",
  "cause": "1 sentence explanation in Hindi of why this happened",
  "cause_en": "1 sentence explanation in English of why this happened",
  "organic_treatment": "1-2 practical sentences in Hindi on organic solution",
  "organic_treatment_en": "1-2 practical sentences in English on organic solution",
  "chemical_treatment": "1-2 practical sentences in Hindi on approved pesticide/fungicide with dosage",
  "chemical_treatment_en": "1-2 practical sentences in English on approved pesticide/fungicide with dosage",
  "voice_summary": "2 sentences spoken in conversational Hindi",
  "voice_summary_en": "2 sentences spoken in conversational English"
}
''';

    final parts = <Map<String, dynamic>>[];
    if (imageBytes != null && imageBytes.isNotEmpty) {
      parts.add({
        'inline_data': {
          'mime_type': mimeType ?? 'image/jpeg',
          'data': base64Encode(imageBytes),
        }
      });
    }
    parts.add({'text': prompt});

    final payload = jsonEncode({
      'contents': [
        {
          'parts': parts,
        }
      ],
      'generationConfig': {
        'temperature': 0.4,
        'maxOutputTokens': 800,
      }
    });

    if (hasApiKey) {
      for (final model in [_primaryModel, _secondaryModel]) {
        try {
          final url = 'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=${apiKey.trim()}';
        final response = await httpPost(
          url,
          headers: {'Content-Type': 'application/json'},
          body: payload,
        ).timeout(const Duration(milliseconds: 3200));

        if (response != null && response.isNotEmpty) {
          final data = jsonDecode(response);
          final candidates = data['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final text = candidates[0]['content']?['parts']?[0]?['text'] as String?;
            if (text != null && text.trim().isNotEmpty) {
              // Strip code fences if present
              String cleanJson = text.trim();
              if (cleanJson.startsWith('```json')) {
                cleanJson = cleanJson.substring(7);
              }
              if (cleanJson.startsWith('```')) {
                cleanJson = cleanJson.substring(3);
              }
              if (cleanJson.endsWith('```')) {
                cleanJson = cleanJson.substring(0, cleanJson.length - 3);
              }
              cleanJson = cleanJson.trim();

              final parsed = jsonDecode(cleanJson);
              final isRel = parsed['is_relevant'] == true ||
                  (parsed['is_relevant'] is String && parsed['is_relevant'].toString().toLowerCase() == 'true');

              if (!isRel || isExplicitIrrelevant) {
                return GeminiCropDiagnosis.irrelevant(
                  subjectName: cropName,
                  reasonHi: parsed['irrelevance_reason_hi'] as String?,
                  reasonEn: parsed['irrelevance_reason_en'] as String?,
                );
              }

              return GeminiCropDiagnosis(
                cropName: parsed['crop_name'] ?? cropName,
                cropNameEn: parsed['crop_name_en'] ?? cropName,
                diseaseNameHi: parsed['disease_name_hi'] ?? 'पहचाना गया रोग',
                diseaseNameEn: parsed['disease_name_en'] ?? 'Identified Issue',
                severity: parsed['severity'] ?? 'मध्यम (65%)',
                severityEn: parsed['severity_en'] ?? 'Moderate (65%)',
                dangerTitle: parsed['danger_title'] ?? 'मध्यम से उच्च खतरा: पत्ती झुलसा व उत्पादन में गिरावट',
                dangerTitleEn: parsed['danger_title_en'] ?? 'Moderate to High Danger: Foliage Blight & Yield Loss',
                dangerDescription: parsed['danger_desc'] ?? 'यदि समय पर उपचार नहीं किया गया तो 30-40% तक उपज का नुकसान हो सकता है।',
                dangerDescriptionEn: parsed['danger_desc_en'] ?? 'Can cause 30-40% yield loss if untreated within 7-10 days.',
                immediateAction: parsed['immediate_action'] ?? 'प्रभावित पत्तियों को तुरंत हटाकर नष्ट करें और जलभराव रोकें।',
                immediateActionEn: parsed['immediate_action_en'] ?? 'Prune severely infected leaves immediately and avoid overhead watering.',
                cause: parsed['cause'] ?? 'मौसम और नमी के कारण संक्रमण।',
                causeEn: parsed['cause_en'] ?? 'Weather and humidity conditions favored infection.',
                organicTreatment: parsed['organic_treatment'] ?? 'नीम तेल 5ml प्रति लीटर पानी में छिड़कें।',
                organicTreatmentEn: parsed['organic_treatment_en'] ?? 'Apply cold-pressed neem oil spray.',
                chemicalTreatment: parsed['chemical_treatment'] ?? 'फफूंदनाशक का नियत मात्रा में छिड़काव करें।',
                chemicalTreatmentEn: parsed['chemical_treatment_en'] ?? 'Apply approved fungicide at recommended dosage.',
                voiceSummary: parsed['voice_summary'] ?? 'रोग नियंत्रण के लिए सुबह के समय छिड़काव करें।',
                voiceSummaryEn: parsed['voice_summary_en'] ?? 'Apply treatments early in the morning for best results.',
                isAiGenerated: true,
                isRelevant: true,
                scanType: parsed['scan_type'] ?? category,
              );
            }
          }
        }
      } catch (e) {
        debugPrint('Gemini model $model error: $e');
      }
    }
    }

    return GeminiCropDiagnosis.fallback(crop: cropName, category: category);
  }

  /// Ask general farming question to Kisan AI Assistant
  Future<String> askKisanAi(String question, {bool isHindi = true}) async {
    final prompt = isHindi
        ? 'आप भारतीय किसानों के सहायक AI मित्र हैं। किसान के इस सवाल का 2-3 वाक्यों में सीधा, सटीक और व्यावहारिक उत्तर हिंदी में दें: $question'
        : 'You are an Indian agriculture AI expert assistant. Answer the farmer\'s question in 2-3 clear, practical sentences: $question';

    final payload = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.6,
        'maxOutputTokens': 400,
      }
    });

    if (hasApiKey) {
      try {
        final url = 'https://generativelanguage.googleapis.com/v1beta/models/$_primaryModel:generateContent?key=${apiKey.trim()}';
        final response = await httpPost(
          url,
          headers: {'Content-Type': 'application/json'},
          body: payload,
        );

        if (response != null && response.isNotEmpty) {
          final data = jsonDecode(response);
          final candidates = data['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final text = candidates[0]['content']?['parts']?[0]?['text'] as String?;
            if (text != null && text.trim().isNotEmpty) {
              return text.trim();
            }
          }
        }
      } catch (_) {}
    }

    return isHindi
        ? 'किसान भाई, मौसम और अपनी फसल की स्थिति अनुसार उचित खाद और हल्की सिंचाई करें।'
        : 'Dear farmer, apply timely watering and balanced fertilizer based on crop growth stage.';
  }

  /// Conversational Farmer AI assistant for natural village-level agricultural advice
  Future<String> chatWithFarmerAi({
    required List<Map<String, String>> history,
    required String userMessage,
    bool isHindi = true,
    String? farmContext,
  }) async {
    final liveFieldBlock = (farmContext != null && farmContext.trim().isNotEmpty)
        ? '\n\nLIVE TELEMETRY FOR THIS FARMER (use exact numbers naturally when relevant!):\n$farmContext\n'
        : '';

    final systemInstruction = '''
You are "Kisan AI Dost" (किसान AI मित्र), a warm, supportive, highly experienced agricultural scientist and friendly village elder for Indian farmers.
The farmer will talk to you in their local everyday language (Hindi, Bhojpuri-tinted Hindi, Hinglish, or simple English).$liveFieldBlock
Your conversational guidelines:
1. GREETING & TONE:
   - Greet warmly like a trusted village friend: "राम राम किसान भाई!", "नमस्ते किसान जी!", or "Hello Kisan Ji!".
   - Be empathetic, practical, and respectful. Treat the farmer as a valued friend.
2. FARMING ADVICE RULES:
   - If live soil moisture, rain probability, or soil pH telemetry is provided above, explicitly cite those real figures (e.g. root moisture %, rain chance %, soil pH) when giving irrigation or spray advice!
   - If the farmer asks about soil/land condition (e.g., "मेरी जमीन की हालत ऐसी है, पानी दूं या नहीं? / Should I water or not?"):
     Explain clearly: check 2-3 inches of topsoil moisture. If dry and crumbly, irrigate lightly; if clayey and moist, hold off 2-3 days to avoid root rot.
   - If the farmer asks about plant condition (e.g. "पत्तियां पीली पड़ रही हैं / Leaves turning yellow"):
     Give immediate cause (Nitrogen deficit, over-watering, or early blight) and provide:
     a) Desi / Organic solution (Neem oil, Jeevamrit, Wood ash)
     b) Chemical solution with exact dosage (Urea, Zinc, Mancozeb)
   - If asked about weather, fertilizer per bigha/acre, or mandi selling timing:
     Give practical Indian farming numbers (e.g. 1 bigha = 0.25-0.33 acre, recommended Urea dosage in split applications).
3. LANGUAGE & FORMATTING (KEEP CRISP, NO LONG PARAGRAPHS):
   - Reply in the EXACT language/dialect the farmer spoke (Hindi, Hinglish, or English).
   - Format EVERY answer cleanly in maximum 3 short scannable bullet lines:
     • Action: (Direct 1-line verdict)
     • Why: (Brief reason citing live soil moisture / pH / weather if relevant)
     • Exact Dose: (Practical desi + chemical measurement per liter or acre)
''';

    final contents = <Map<String, dynamic>>[];
    for (final h in history.take(6)) {
      final role = h['role'] == 'user' ? 'user' : 'model';
      contents.add({
        'role': role,
        'parts': [
          {'text': h['text'] ?? ''}
        ]
      });
    }

    contents.add({
      'role': 'user',
      'parts': [
        {'text': '$systemInstruction\n\nFarmer says: $userMessage'}
      ]
    });

    final payload = jsonEncode({
      'contents': contents,
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 500,
      }
    });

    if (hasApiKey) {
      try {
        final url = 'https://generativelanguage.googleapis.com/v1beta/models/$_primaryModel:generateContent?key=${apiKey.trim()}';
        final response = await httpPost(
          url,
          headers: {'Content-Type': 'application/json'},
          body: payload,
        ).timeout(const Duration(milliseconds: 3500));

        if (response != null && response.isNotEmpty) {
          final data = jsonDecode(response);
          final candidates = data['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final text = candidates[0]['content']?['parts']?[0]?['text'] as String?;
            if (text != null && text.trim().isNotEmpty) {
              return text.trim();
            }
          }
        }
      } catch (_) {}
    }

    final qLower = userMessage.toLowerCase();
    if (qLower.contains('पानी') || qLower.contains('water') || qLower.contains('सिंचाई') || qLower.contains('नमी') || qLower.contains('moisture')) {
      return isHindi
          ? '• निर्णय: ऊपरी 2-3 इंच मिट्टी दबाकर देखें — सूखी हो तभी हल्का पानी दें।\n• कारण: नमी होने पर सिंचाई करने से जड़ सड़न का खतरा रहता है।\n• सलाह: सुबह या शाम के समय ही हल्की सिंचाई करें।'
          : '• Action: Check top 2–3 inches of soil — irrigate lightly only if dry and crumbly.\n• Why: Watering wet soil or before rain triggers root rot.\n• Timing: Water in cool morning or evening hours.';
    }

    if (qLower.contains('पीली') || qLower.contains('yellow') || qLower.contains('पत्ती') || qLower.contains('leaf') || qLower.contains('पौधा')) {
      return isHindi
          ? '• कारण: नाइट्रोजन की कमी या शुरुआती फफूंद संक्रमण।\n• देसी उपाय: नीम तेल 5ml/लीटर पानी में मिलाकर सुबह छिड़कें।\n• खाद मात्रा: हल्की सिंचाई के साथ 20-25 किग्रा यूरिया प्रति एकड़ दें।'
          : '• Cause: Nitrogen deficit or early leaf fungus.\n• Organic: Spray Neem Oil (5ml/L water) early morning.\n• Fertilizer: Top-dress 20–25 kg Urea/acre with light moisture.';
    }

    if (qLower.contains('खाद') || qLower.contains('यूरिया') || qLower.contains('डीएपी') || qLower.contains('fertilizer') || qLower.contains('urea')) {
      return isHindi
          ? '• बुवाई खाद: प्रति एकड़ 1 बोरी DAP (50 किग्रा) + 1 बोरी पोटाश।\n• पहली सिंचाई: 40-45 किग्रा यूरिया + 5 किग्रा जिंक सल्फेट (21%)।\n• लाभ: कल्ले मजबूत होंगे और दाने का भराव बढ़ेगा।'
          : '• Basal Dose: 1 bag DAP (50kg) + 1 bag Potash per acre.\n• 1st Irrigation: 40–45 kg Urea + 5 kg Zinc Sulphate (21%).\n• Result: Boosts strong tillering and grain filling.';
    }

    if (qLower.contains('कीट') || qLower.contains('pest') || qLower.contains('इल्ली') || qLower.contains('कीड़े')) {
      return isHindi
          ? '• तुरंत कदम: खेत में 6-8 पीले चिपचिपे कार्ड प्रति एकड़ लगाएं।\n• जैविक स्प्रे: 5ml नीम तेल (10,000 PPM) प्रति लीटर पानी में शाम को छिड़कें।\n• रासायनिक: अधिक प्रकोप पर इमिडाक्लोप्रिड 0.5 ml/लीटर स्प्रे करें।'
          : '• Action: Place 6–8 Yellow Sticky Traps per acre.\n• Organic: Spray Neem Oil (5ml/L) in evening hours.\n• Severe Case: Use Imidacloprid @ 0.5 ml/L water.';
    }

    return isHindi
        ? '• निर्णय: अपनी फसल, जमीन की नमी या खाद का नाम लिखकर पूछें।\n• मदद: मैं तुरंत सही मात्रा व सिंचाई का सुझाव दूंगा।'
        : '• Ready: Ask about your soil moisture, irrigation, yellow leaves, or fertilizer.\n• Help: I will reply with exact dosages and actions.';
  }

  /// Real-time Mandi market intelligence powered by Gemini AI
  Future<GeminiMandiAdvice> getMandiAdvice({
    required String cropName,
    String region = 'Jharkhand/Bihar',
  }) async {
    final prompt = '''
You are an expert Indian commodity market and APMC mandi analyst for Indian farmers.
Analyze current market conditions, official MSP (2024-2026), and price trends for:
Crop: $cropName
Region: $region

Respond ONLY with a valid raw JSON object (no markdown, no backticks) with these exact keys:
{
  "crop_name": "$cropName",
  "msp_rate": "₹... / Qtl (MSP)",
  "trend": "Bullish (+₹45) / Bearish (-₹20) / Stable",
  "trend_hi": "तेजी (+₹45) / मंदी (-₹20) / स्थिर",
  "recommendation_hi": "1-2 sentences in Hindi advising whether to sell now or hold",
  "recommendation_en": "1-2 sentences in English advising whether to sell now or hold",
  "analysis_hi": "1-2 sentences in Hindi explaining why based on demand and arrival",
  "analysis_en": "1-2 sentences in English explaining why based on demand and arrival",
  "best_mandi": "Name of best nearby mandi with estimated rate, e.g. Sasaram Mandi (₹5,680)"
}
''';

    final payload = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.3,
        'maxOutputTokens': 500,
      }
    });

    if (hasApiKey) {
      for (final model in [_primaryModel, _secondaryModel]) {
        try {
          final url = 'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=${apiKey.trim()}';
        final response = await httpPost(
          url,
          headers: {'Content-Type': 'application/json'},
          body: payload,
        ).timeout(const Duration(milliseconds: 3200));

        if (response != null && response.isNotEmpty) {
          final data = jsonDecode(response);
          final candidates = data['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final text = candidates[0]['content']?['parts']?[0]?['text'] as String?;
            if (text != null && text.trim().isNotEmpty) {
              String cleanJson = text.trim();
              if (cleanJson.startsWith('```json')) cleanJson = cleanJson.substring(7);
              if (cleanJson.startsWith('```')) cleanJson = cleanJson.substring(3);
              if (cleanJson.endsWith('```')) cleanJson = cleanJson.substring(0, cleanJson.length - 3);
              cleanJson = cleanJson.trim();

              final parsed = jsonDecode(cleanJson);
              return GeminiMandiAdvice(
                cropName: parsed['crop_name'] ?? cropName,
                mspRate: parsed['msp_rate'] ?? '₹2,425 / Qtl (MSP)',
                trend: parsed['trend'] ?? 'Bullish (+₹30)',
                trendHindi: parsed['trend_hi'] ?? 'तेजी (+₹30)',
                recommendation: parsed['recommendation_hi'] ?? parsed['recommendation'] ?? 'अच्छे भाव पर 50% उपज बेचें।',
                recommendationEn: parsed['recommendation_en'] ?? 'Attractive prices. Consider selling 50% of harvest.',
                analysis: parsed['analysis_hi'] ?? parsed['analysis'] ?? 'मंडियों में मांग सामान्य से बेहतर बनी हुई है।',
                analysisEn: parsed['analysis_en'] ?? 'Wholesale procurement demand remains firm across key terminal mandis.',
                bestMandi: parsed['best_mandi'] ?? 'Local Benchmark APMC',
              );
            }
          }
        }
      } catch (e) {
        debugPrint('Gemini Mandi model $model error: $e');
      }
    }
    }

    return GeminiMandiAdvice.fallback(cropName);
  }

  /// Fetches live APMC Mandi rates dynamically for any crop
  Future<List<Map<String, dynamic>>?> fetchLiveMandiPrices({
    required String cropName,
    String region = 'Jharkhand & Bihar',
  }) async {
    final prompt = '''
You are a live Indian APMC Mandi price system reporting real Agmarknet prices for Indian farmers.
For crop: "$cropName" in region: "$region", provide real current market price records for 3 prominent mandis (e.g. Daltonganj, Garhwa, Sasaram/Ranchi or regional benchmark APMC mandi).

Respond ONLY with a valid JSON array of 3 objects (no markdown code fence, no text before or after):
[
  {
    "cropName": "$cropName",
    "mandiName": "Daltonganj Mandi",
    "district": "Palamu",
    "distance": "18 km",
    "minPrice": 5350,
    "maxPrice": 5650,
    "modalPrice": 5520,
    "arrival": "1,200 बोरी",
    "priceChange": "+₹45",
    "isUp": true,
    "variety": "Standard",
    "source": "Agmarknet APMC Live Feed"
  }
]
''';

    final payload = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.2,
        'maxOutputTokens': 600,
      }
    });

    if (hasApiKey) {
      for (final model in [_primaryModel, _secondaryModel]) {
        try {
          final url = 'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=${apiKey.trim()}';
        final response = await httpPost(
          url,
          headers: {'Content-Type': 'application/json'},
          body: payload,
        ).timeout(const Duration(milliseconds: 3200));

        if (response != null && response.isNotEmpty) {
          final data = jsonDecode(response);
          final candidates = data['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final text = candidates[0]['content']?['parts']?[0]?['text'] as String?;
            if (text != null && text.trim().isNotEmpty) {
              String cleanJson = text.trim();
              if (cleanJson.startsWith('```json')) cleanJson = cleanJson.substring(7);
              if (cleanJson.startsWith('```')) cleanJson = cleanJson.substring(3);
              if (cleanJson.endsWith('```')) cleanJson = cleanJson.substring(0, cleanJson.length - 3);
              cleanJson = cleanJson.trim();

              final parsed = jsonDecode(cleanJson);
              if (parsed is List) {
                return parsed.map((e) => Map<String, dynamic>.from(e as Map)).toList();
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Gemini live mandi prices model $model error: $e');
      }
    }
    }
    return null;
  }

  /// Synthesizes Weather, Satellite Soil Moisture, SoilGrids pH, Mandi & Ledger into a 3-point Smart Briefing
  Future<GeminiSmartBriefing> generateSmartBriefing({
    required String promptContext,
    required double soilMoistureRoot,
    required int humidity,
    required int rainChance,
    required double netProfit,
    required String topCrop,
    required int bestRate,
    required double soilPh,
  }) async {
    final prompt = '''
You are the chief precision agronomist for the "Bhoomi" Indian Farmer App.
Analyze the farmer's live satellite telemetry and financial context below and draw actionable, high-value conclusions:

$promptContext

Respond ONLY with a valid raw JSON object (no markdown, no backticks) with these exact keys:
{
  "irrigation_hi": "1 concise Hindi sentence deciding water today vs hold based on root moisture & rain probability",
  "irrigation_en": "1 concise English sentence deciding water today vs hold based on root moisture & rain probability",
  "disease_hi": "1 concise Hindi sentence assessing fungal/pest outbreak pressure from humidity/temp + preventive tip",
  "disease_en": "1 concise English sentence assessing fungal/pest outbreak pressure from humidity/temp + preventive tip",
  "market_hi": "1 concise Hindi sentence connecting mandi price & profit outlook",
  "market_en": "1 concise English sentence connecting mandi price & profit outlook",
  "conclusion_hi": "1 surprising or money-saving cross-data insight in Hindi combining soil pH, moisture, and expenses",
  "conclusion_en": "1 surprising or money-saving cross-data insight in English combining soil pH, moisture, and expenses",
  "risk_level": "low | moderate | high"
}
''';

    final payload = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.35,
        'maxOutputTokens': 550,
      }
    });

    if (hasApiKey) {
      try {
        final url = 'https://generativelanguage.googleapis.com/v1beta/models/$_primaryModel:generateContent?key=${apiKey.trim()}';
        final response = await httpPost(
          url,
          headers: {'Content-Type': 'application/json'},
          body: payload,
        ).timeout(const Duration(milliseconds: 3500));

        if (response != null && response.isNotEmpty) {
          final data = jsonDecode(response);
          final candidates = data['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final text = candidates[0]['content']?['parts']?[0]?['text'] as String?;
            if (text != null && text.trim().isNotEmpty) {
              String cleanJson = text.trim();
              if (cleanJson.startsWith('```json')) cleanJson = cleanJson.substring(7);
              if (cleanJson.startsWith('```')) cleanJson = cleanJson.substring(3);
              if (cleanJson.endsWith('```')) cleanJson = cleanJson.substring(0, cleanJson.length - 3);
              cleanJson = cleanJson.trim();

              final parsed = jsonDecode(cleanJson);
              return GeminiSmartBriefing(
                irrigationAdviceHi: (parsed['irrigation_hi'] ?? '').toString(),
                irrigationAdviceEn: (parsed['irrigation_en'] ?? '').toString(),
                diseaseWindowHi: (parsed['disease_hi'] ?? '').toString(),
                diseaseWindowEn: (parsed['disease_en'] ?? '').toString(),
                marketActionHi: (parsed['market_hi'] ?? '').toString(),
                marketActionEn: (parsed['market_en'] ?? '').toString(),
                hiddenConclusionHi: (parsed['conclusion_hi'] ?? '').toString(),
                hiddenConclusionEn: (parsed['conclusion_en'] ?? '').toString(),
                riskLevel: (parsed['risk_level'] ?? 'low').toString().toLowerCase(),
                isAiGenerated: true,
              );
            }
          }
        }
      } catch (e) {
        debugPrint('Gemini Smart Briefing fallback: $e');
      }
    }

    return GeminiSmartBriefing.computed(
      soilMoistureRoot: soilMoistureRoot,
      humidity: humidity,
      rainChance: rainChance,
      netProfit: netProfit,
      topCrop: topCrop,
      bestRate: bestRate,
      soilPh: soilPh,
    );
  }

  /// Generates financial Break-Even, Input Cost Savings, and Crop Rotation conclusions from Ledger + Mandi data
  Future<GeminiLedgerInsight> analyzeLedgerInsights({
    required String promptContext,
    required double totalExpense,
    required double totalIncome,
    required String topCategory,
    required String topCrop,
    required int mandiRate,
  }) async {
    final prompt = '''
You are an expert Indian agricultural economist advising a farmer based on their Kisan Bahi-Khata ledger and live Mandi prices:

$promptContext
Highest spend category: $topCategory | Primary Crop: $topCrop | Benchmark Mandi Rate: ₹$mandiRate/Qtl

Respond ONLY with a valid raw JSON object (no markdown, no backticks):
{
  "break_even_hi": "1-2 Hindi sentences stating exact break-even quantity needed at ₹$mandiRate/Qtl to recover ₹${totalExpense.toStringAsFixed(0)} spend",
  "break_even_en": "1-2 English sentences stating exact break-even quantity needed at ₹$mandiRate/Qtl to recover ₹${totalExpense.toStringAsFixed(0)} spend",
  "cost_tip_hi": "1-2 Hindi sentences on reducing highest spend category ($topCategory) safely without hurting yield",
  "cost_tip_en": "1-2 English sentences on reducing highest spend category ($topCategory) safely without hurting yield",
  "rotation_hi": "1-2 Hindi sentences recommending a high-profit nitrogen-fixing next crop (e.g. Moong/Urad/Mustard)",
  "rotation_en": "1-2 English sentences recommending a high-profit nitrogen-fixing next crop (e.g. Moong/Urad/Mustard)"
}
''';

    final payload = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.35,
        'maxOutputTokens': 500,
      }
    });

    if (hasApiKey) {
      try {
        final url = 'https://generativelanguage.googleapis.com/v1beta/models/$_primaryModel:generateContent?key=${apiKey.trim()}';
        final response = await httpPost(
          url,
          headers: {'Content-Type': 'application/json'},
          body: payload,
        ).timeout(const Duration(milliseconds: 3500));

        if (response != null && response.isNotEmpty) {
          final data = jsonDecode(response);
          final candidates = data['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final text = candidates[0]['content']?['parts']?[0]?['text'] as String?;
            if (text != null && text.trim().isNotEmpty) {
              String cleanJson = text.trim();
              if (cleanJson.startsWith('```json')) cleanJson = cleanJson.substring(7);
              if (cleanJson.startsWith('```')) cleanJson = cleanJson.substring(3);
              if (cleanJson.endsWith('```')) cleanJson = cleanJson.substring(0, cleanJson.length - 3);
              cleanJson = cleanJson.trim();

              final parsed = jsonDecode(cleanJson);
              return GeminiLedgerInsight(
                breakEvenHi: (parsed['break_even_hi'] ?? '').toString(),
                breakEvenEn: (parsed['break_even_en'] ?? '').toString(),
                costTipHi: (parsed['cost_tip_hi'] ?? '').toString(),
                costTipEn: (parsed['cost_tip_en'] ?? '').toString(),
                rotationHi: (parsed['rotation_hi'] ?? '').toString(),
                rotationEn: (parsed['rotation_en'] ?? '').toString(),
                isAiGenerated: true,
              );
            }
          }
        }
      } catch (e) {
        debugPrint('Gemini Ledger Insight fallback: $e');
      }
    }

    return GeminiLedgerInsight.computed(
      totalExpense: totalExpense,
      totalIncome: totalIncome,
      topCategory: topCategory,
      topCrop: topCrop,
      mandiRate: mandiRate,
    );
  }
}



