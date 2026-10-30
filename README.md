# 🌱 Kabadiwala Connect

> **"Kabadi Se Circular Bharat Tak"**  
> *Empowering informal e-waste collectors into India's formal, authorized circular economy.*

---

## 📌 Project Information

- **Competition**: Smart India Hackathon (SIH) 2026.  
- **Problem Statement ID**: 26229
- **Theme**: Clean & Green Technology
- **Team**: Hackaholics

---

## 🎯 Purpose & Vision

In India, over 90% of discarded electronics flow through the informal sector (local *kabadiwalas*). Due to information asymmetry, lack of formal market access, and absence of verifiable handover tracking, informal collectors often receive substandard pricing while toxic e-waste bypasses authorized recycler channels.

**Kabadiwala Connect** bridges this critical gap through a mobile-first, high-legibility platform tailored specifically for informal collectors with low digital literacy:

```
Informal Collector
        ↓
Transparent Demo Price Rates (Copper, Aluminium, PCBs)
        ↓
Digital Material Lot (Photos, Grade, Quantity)
        ↓
Authorized Recycler Discovery & Intelligent Matching
        ↓
Digital Handover Request
        ↓
Real-Time Handover Lifecycle Tracking
        ↓
Formalized, Circular E-Waste Processing
```

---

## ✨ Implemented Core Features

### 1. 🇮🇳 Vernacular & Multilingual Onboarding
- Full, native support for **English**, **हिन्दी (Hindi)**, and **मराठी (Marathi)** with instant runtime switching.
- High-contrast, friendly illustrative design with large touch targets.

### 2. ☀️ Dynamic Theming (Light & Dark Modes)
- **Light Mode**: Fresh eco-canvas (`#F6F8F5`) with crisp typography and subtle elevation.
- **Dark Mode**: Deep forest charcoal (`#0A130E`) with high-contrast, eye-friendly contrast ratios.

### 3. 📊 Collector Dashboard & Price Board
- Real-time ticker for copper (`₹720/kg`), aluminium (`₹180/kg`), e-waste PCBs (`₹35/kg`), and other scrap.
- Hero action button for creating new lots.
- Motivational environmental tip cards.

### 4. 📦 4-Step "Create New Lot" Wizard
1. **Add Photos**: Abstracted photo service supporting camera/gallery capture and preset quick samples without simulated camera trickery.
2. **Material Details**: Icon-based selection cards for materials, condition chips (`Good`, `Broken`, `Scrap`), and quantity steppers (`kg` / `pieces`).
3. **Estimated Value Calculation**: Transparent mathematical breakdown (`Quantity × Demo Rate = Estimated Value`) with explicit demo rate disclaimers.
4. **Review & Create**: Summary breakdown with inline edit shortcut and simulated processing state.
- **Success State**: Pulsing green check emblem, unique LOT ID (`KC-2026-00125`), and instant routing to Recycler Discovery or My Lots.

### 5. 🔍 Nearby Recyclers Discovery & Matching
- Search facilities by name or industrial area.
- Multi-criteria filter sheet: by accepted material, pickup availability, and distance range.
- Contextual lot banner: *"Recommended for Lot KC-2026-00125 (Copper)"*.
- Facility detail cards with operational hours, accepted grades, and matching rationale.

### 6. 🤝 Digital Handover Request & Tracking
- **Handover Confirmation Modal**: Displays lot summary, recycler info, and transparent confirmation terms.
- **Request Submitted State**: Request ID with `Pending Review` status.
- **4-Step Vertical Lifecycle Timeline**:
  1. ✓ **Request Sent** (Completed)
  2. ● **Recycler Reviewing** (Active/In Progress)
  3. ○ **Pickup / Drop-off** (Upcoming)
  4. ○ **Handover Confirmed** (Upcoming)

### 7. 📋 My Lots Integration
- Session persistence tracking all created lots.
- Dynamic status indicators: `Created`, `Recycler Reviewing`, `Pickup Scheduled`, `Handover Confirmed`.
- Tap-to-track shortcuts directly into the handover timeline.

---

## 🏗️ Architecture & Technology Stack

```
lib/
├── core/
│   ├── constants/             # AppColors, AppDimens, AppTypography
│   ├── localization/          # AppLocalizations (EN, HI, MR) & LanguageProvider
│   ├── navigation/            # AppRouter & AppRoutes
│   └── theme/                 # AppTheme & ThemeProvider
├── features/
│   ├── splash/                # Animated splash screen
│   ├── onboarding/            # Language selection screen
│   ├── home/                  # Dashboard, price ticker, hero CTAs, bottom nav
│   ├── lots/                  # EwasteLot model, PhotoService, RateService, LotProvider, 4-step wizard
│   ├── recyclers/             # Recycler & Handover models, RecyclerService, RecyclerProvider, Discovery & Tracking
│   ├── earnings/              # Earnings dashboard & transaction logs
│   └── profile/               # Collector profile & settings
└── shared/
    └── widgets/               # AppCard, PrimaryButton, EcoVectors
```

- **Framework**: Flutter (Channel stable, Web & Mobile)
- **State Management**: Lightweight `Provider` pattern
- **Typography**: Google Fonts (`Outfit` & `Inter`)
- **Code Quality**: Strict zero-warning analyzer compliance (`flutter analyze`)

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.24+ recommended)
- Dart SDK

### Installation & Run

```bash
# Clone repository
git clone https://github.com/B2Aryan/kabadiwala-connect.git
cd kabadiwala-connect

# Install dependencies
flutter pub get

# Run test suite
flutter test

# Run static analysis
flutter analyze

# Run on Chrome
flutter run -d chrome

# Or build Web release
flutter build web
```

---

## 🛡️ Data Integrity & Demo Notice

All market rates, recycler listings, and GPS distances in this phase represent curated demonstration data for prototype validation. Real-time rates, government EPR verification, and GPS tracking interfaces are abstracted for clean backend integration in future phases.

---

*Kabadiwala Connect — Smart India Hackathon 2026*
