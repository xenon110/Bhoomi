<div align="center">

# 🌾 भूमि (Bhoomi)
### *Smart, Offline-First Digital Companion for Indian Farmers*

[![Flutter](https://img.shields.io/badge/Flutter-3.41.7-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11.5-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Turso](https://img.shields.io/badge/Turso_DB-Edge_SQLite-4FF8D2?style=for-the-badge&logo=sqlite&logoColor=black)](https://turso.tech)
[![Android](https://img.shields.io/badge/Android-SDK_34-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://android.com)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Web-E65100?style=for-the-badge)](#)
[![Language](https://img.shields.io/badge/Languages-Hindi%20%7C%20English-2E7D32?style=for-the-badge)](#)

<p align="center">
  <b>Bhoomi</b> bridges the technological divide for Indian agriculture by delivering real-time mandi arbitrage, AI-assisted leaf pest diagnosis, localized micro-weather advisories, farmland rentals, and digital farm ledger tracking — built to work seamlessly offline and sync directly to Turso Edge Cloud.
</p>

</div>

---

## 🌟 Key Highlights & Features

### 🔍 1. AI Crop Doctor & Leaf Scanner
- **Instant Disease Detection**: Scan crop leaves using the camera or photo gallery to identify blights, fungal rusts, and leaf spots.
- **Voice Advisory & Audio Playback**: Listen to agronomic solutions in clear Hindi or English tailored for rural accessibility.
- **Direct Diary Integration**: Automatically log diagnosed pests and corrective chemical/organic remedies straight into the Farm Diary.

### 📈 2. Mandi Arbitrage & Price Intelligence
- **Live APMC Rates**: Real-time market rates and MSP comparison across major Indian mandis (Neemuch, Mandsaur, Kota, Khanna, Rajkot).
- **Sell Crop Listings**: Publish commodity produce with quantity, asking price, and contact details synced to the community marketplace.
- **Arbitrage Insights**: Visual indications of which neighboring mandi offers peak profit margins after transit costs.

### 🌦️ 3. Agro-Meteorological Weather Station
- **3-Day Localized Forecast**: Micro-climatic temperature, rainfall likelihood, humidity, and wind velocity metrics.
- **Farm Advisory Banners**: Dynamic warnings for frost, unexpected rain, or optimal pesticide spraying windows.

### 📖 4. Kheti Diary & Kisan Bahi-Khata (Ledger)
- **Activity Log**: Keep structured records of field sowing, irrigation rounds, fertilizer treatments, and harvest yields.
- **Financial Ledger**: Track income and expense cashflow per crop cycle with balance breakdowns.
- **Turso Cloud Sync**: Dual-engine synchronization — instant offline responsiveness with automatic cloud backup to libSQL / Turso Edge.

### 🚜 5. Equipment Rental & Land Marketplace
- **Farm Machinery**: Rent high-capacity tractors, rotavators, laser levelers, and drip equipment on an hourly or daily basis.
- **Farmland Listings**: Explore verified agricultural plots for lease or sale with tubewell, soil health, and road access indicators.

### 🏛️ 6. Kisan Yojana & Subsidies Guide
- Curated directory of central and state welfare initiatives (PM-Kisan, PM Fasal Bima, Solar Pump schemes) with step-by-step eligibility instructions.

---

## 🏗️ Technical Architecture

```
               ┌────────────────────────────────────────────────────────┐
               │                 Flutter Client (Mobile / Web)           │
               └───────────────┬────────────────────────┬───────────────┘
                               │                        │
                    Offline Persistence         Cloud Edge Synchronization
                               │                        │
               ┌───────────────▼────────┐      ┌────────▼───────────────┐
               │ StorageService (Cache) │◄────►│   Turso Cloud Service  │
               │  - localStorage (Web)  │      │ - libSQL HTTP Pipeline │
               │  - JSON Mirror (Disk)  │      │ - Edge SQLite Replica  │
               └────────────────────────┘      └────────────────────────┘
```

- **Frontend**: Flutter 3.41 with pure custom Canvas painters for native vector illustrations and zero-overflow flexible cards.
- **Typography**: Google Font **Mukta** for bilingual legibility.
- **Design System**: *Maati Organic Palette* (`#1E4D2B` Forest Green, `#F6F2E9` Warm Cream, `#F2B134` Harvest Gold).
- **Backend / Database**: **Turso Edge SQLite** (`libsql://bhoomi-xenon110.aws-ap-south-1.turso.io`) providing low-latency distributed SQL across India.

---

## 📱 Pre-built Android Release APK

The production release APK is pre-compiled and ready for deployment:

| Attribute | Value |
|:---|:---|
| **File Name** | `Bhoomi-release.apk` |
| **Workspace Path** | `C:\Users\yashs\Downloads\Kishan\Bhoomi-release.apk` |
| **Build Path** | `build/app/outputs/flutter-apk/app-release.apk` |
| **Package ID** | `com.kisansaathi.app` |
| **Size** | `59.3 MB` |
| **Target SDK** | Android 14 (API 34) |

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`v3.41.7` or higher)
- [Dart SDK](https://dart.dev/get-dart) (`v3.11.5` or higher)
- [Android Studio / Command Line Tools](https://developer.android.com/studio) with SDK 34 and JDK 17
- Chrome (for Flutter Web preview)

### Setup & Run
```bash
# 1. Clone the repository
git clone https://github.com/xenon110/Bhoomi.git
cd Bhoomi

# 2. Install dependencies
flutter pub get

# 3. Run on Chrome (Web)
flutter run -d chrome

# 4. Run on Connected Android Device
flutter run -d android

# 5. Build Release APK
flutter build apk --release
```

---

## 🗄️ Database Tables (Turso Edge Cloud)

| Table Name | Description | Key Fields |
|:---|:---|:---|
| `bhoomi_diary` | Farmer field journal entries | `id`, `title`, `category`, `date`, `notes` |
| `bhoomi_crops` | Registered crops and acreage | `id`, `name`, `variety`, `area_acres`, `sowing_date`, `status` |
| `bhoomi_market_listings` | Farmer crop sale listings | `id`, `crop_name`, `variety`, `quantity_qtl`, `price_per_qtl`, `location`, `seller_phone` |
| `bhoomi_ledger` | Agricultural financial cashbook | `id`, `title`, `amount`, `type`, `date`, `category` |

---

## 🤝 Contributing
Contributions, feedback, and suggestions to enrich rural agriculture are warmly welcome:
1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/CoolFeature`)
3. Commit your Changes (`git commit -m 'Add CoolFeature'`)
4. Push to the Branch (`git push origin feature/CoolFeature`)
5. Open a Pull Request

---

<div align="center">
  <b>Built with ❤️ for Indian Kisan by <a href="https://github.com/xenon110">xenon110</a></b>
</div>
