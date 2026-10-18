# RunRabbit Kiosk — Project Context

## What it is
A Flutter tablet kiosk app for the **RunRabbit K-Beauty & Skincare** flagship store in Colombo, Sri Lanka.
Shoppers touch the screen, answer 3 questions (skin type → concerns → budget), and receive a curated skincare routine recommendation. No backend — all data is a local JSON asset.

## Tech stack
- Flutter + Dart (sdk >=3.4.0 <4.0.0), Material 3, `wakelock_plus` (only 3rd-party dep)
- Platform target: Android tablet (immersive sticky full-screen, both orientations)
- Languages: English + Sinhala (toggled live, no code-gen, simple map lookup with fallback)

---

## File Tree (lib/)

```
lib/
├── main.dart                   # Entry: wakelock, immersive UI, error guard, runApp(KioskApp)
├── app/
│   ├── kiosk_app.dart          # KioskApp (StatelessWidget → MaterialApp) + KioskHome (StatefulWidget)
│   │                           # Owns idle-timeout timer (default 60s), resets flow on inactivity
│   ├── brand.dart              # Brand design tokens: colors, radii, font family
│   ├── theme.dart              # buildTheme() — Material3 ThemeData from Brand tokens
│   └── strings.dart            # Strings(lang).t(key) — bilingual copy (en/si), no packages
├── data/
│   └── product_repository.dart # Abstract ProductRepository + JsonProductRepository (reads assets/data/products.json)
├── domain/
│   ├── product.dart            # Product model + Step enum (cleanser/toner/serum/moisturiser/sunscreen/mask)
│   ├── options.dart            # skinTypes[], concernOptions[], budgetOptions[], maxConcerns=3
│   └── recommendation_engine.dart  # Pure Dart, no Flutter. Scores & picks best cleanser+serum+moisturiser+sunscreen
│                                   # pads to minCount=3. Filters: inStock, avoidSkinTypes, maxPrice
└── presentation/
    ├── state/
    │   └── flow_state.dart     # KioskFlow (ChangeNotifier): stage, skinType, concerns(Set), maxPrice, lang
    │                           # Stages: idle → skin → concerns → budget → results (back() works too)
    ├── screens/
    │   ├── idle_screen.dart    # Attract screen: tap-anywhere to start, top-right language toggle pill
    │   ├── option_screens.dart # SkinTypeScreen, ConcernsScreen, BudgetScreen — all use ScreenFrame
    │   └── results_screen.dart # Calls RecommendationEngine, shows responsive grid of ProductCards + patch-test banner
    └── widgets/
        ├── adaptive.dart       # Adaptive.of(context) — scales sizes by screen width
        ├── screen_frame.dart   # Shared chrome: back button, step progress, title/subtitle, primary CTA slot
        ├── skin_type_cards.dart
        ├── concern_cards.dart
        ├── budget_cards.dart
        ├── option_grid.dart    # Generic selectable grid used by the card widgets
        └── product_card.dart   # Rich product display: image, brand, name, price, shelf, ingredients, reasons, caution
```

---

## Key Data Models

### Product fields
`id, name, brand, step(Step), price(LKR int), size, inStock, skinTypes(List<String>),`
`concerns(Map<String,int> id→weight 1-3), keyIngredients, avoidSkinTypes, note(Map<lang,String>), shelf, benefit(Map<lang,String>)`
Data source: `assets/data/products.json` → key `"products": [...]`

### KioskFlow (state — ChangeNotifier)
```dart
Stage stage;          // idle | skin | concerns | budget | results
String? skinType;     // e.g. "oily"
Set<String> concerns; // up to 3, e.g. {"acne","dullness"}
int? maxPrice;        // LKR, null = no limit
String lang;          // "en" | "si"
```

### Enumerations
- Skin types: `oily, dry, combination, sensitive, normal`
- Concerns: `acne, pores, pigmentation, dullness, aging, darkcircles, dryness, redness`
- Budget tiers (LKR): `3000, 6000, 10000, null (no limit)`
- Routine steps (Step enum): `cleanser, toner, serum, moisturiser, sunscreen, mask`

---

## Recommendation Logic (RecommendationEngine.recommend)
1. Filter products: `inStock && !avoidSkinTypes.contains(skin) && price <= maxPrice`
2. Score each: sum concern weights for chosen concerns + 2 if exact skin match / +1 if "all"
3. Pick best from routine steps [cleanser, serum, moisturiser, sunscreen] (serum only if ≥1 concern match)
4. If < minCount(3) results, pad with next highest-scored remaining products
5. Sort final list by Step.index

---

## Brand Design (brand.dart)
- Primary: #141414 (obsidian black) on white #FAFAFA background
- Accent: #D8582B (terracotta) / Sale red #E53935
- Nature tags: green #236E3B on #EFF8F2
- Caution: amber #92400E on #FEF3C7
- Card radius 18dp, pill radius 99dp, standard radius 16dp
- Material 3, InkSparkle splash

---

## Assets
```
assets/data/products.json       # Product catalogue (loaded once at startup via FutureBuilder)
assets/images/skin_types/       # Images for skin type cards
assets/images/concerns/         # Images for concern cards
```

---

## Key Conventions
- `Adaptive.of(context).s(value)` — scales all sizes by screen width; use instead of hardcoded dp
- `Strings(lang).t('key')` for all user-visible text; Sinhala falls back to English for missing keys
- `ScreenFrame` wraps every step screen (back nav, step progress dots, title, subtitle, primary button slot)
- `OptionItem(id, label, emoji, subtitle?)` is the universal tile model passed into card widgets
- `ProductRepository` is an interface — swap `JsonProductRepository` for a Shopify impl without changing screens
- Error widget replaced with `SizedBox.shrink()` (customer must never see red crash screen)
- Android back button disabled via `PopScope(canPop: false)`
- Text scale capped at 1.3x via `MediaQuery.withClampedTextScaling`
