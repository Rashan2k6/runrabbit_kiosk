# RunRabbit Skin Concern Kiosk

Android tablet kiosk (Flutter). Customers pick skin type, up to 3 concerns and a
budget, then see a suggested routine with price, shelf location and cautions.
Uses dummy data in `assets/data/products.json`.

## First time setup (one time, on your computer)

This repo has the Dart code, assets and tests but not the generated `android/`
folder. Create it without touching `lib/`:

```bash
cd runrabbit_kiosk
flutter create . --platforms=android --project-name runrabbit_kiosk --org lk.runrabbit
flutter pub get
flutter analyze
flutter test
flutter run            # with a tablet or emulator connected
```

`flutter create .` keeps existing files, so `lib/`, `test/`, `pubspec.yaml` stay as they are.
If it overwrote `test/widget_test.dart` or added a default one, delete it
(it tests the default counter app).

## Lightweight build for low end tablets

```bash
flutter build apk --release --split-per-abi
```

Why it is light: one third party package (`wakelock_plus`), no images or
bundled fonts yet, no animations or ink splashes, no state management library,
simple `ChangeNotifier`. Test on an emulator with 1 to 2 GB RAM.

## Matching the website look

All colours, radius and the font are in `lib/app/brand.dart` and are
**placeholders**. Put the real RunRabbit values there. To use the brand font,
bundle one or two weights only and set `Brand.fontFamily`.

## Where things are

| Path | What |
|---|---|
| `lib/domain/` | Product model, options, recommendation engine (pure Dart) |
| `lib/data/product_repository.dart` | `ProductRepository` interface + JSON implementation. Add a Shopify one later. |
| `lib/app/strings.dart` | English and Sinhala text (Sinhala needs native review) |
| `lib/presentation/` | Screens, widgets, flow state |
| `test/` | Engine tests and full flow tests at 8 screen sizes |

## Kiosk setup on the tablet

The app goes full screen, keeps the screen on, blocks the back button and resets
after 60 s without a touch (`idleTimeout` in `KioskApp`). To stop customers
leaving the app, a staff member should turn on Android **Screen pinning**
(Settings > Security > App pinning), or use a managed kiosk mode.
