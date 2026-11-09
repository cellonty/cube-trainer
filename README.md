# 🧊 Cube Trainer

A Flutter app for learning and drilling Rubik's Cube algorithms on 3×3 and 2×2. It covers CFOP, Roux, Ortega and CLL/EG, and includes a WCA-style timer.

**390 cases · 1511 algorithms · 9 languages · works offline**

🇷🇺 [Читать на русском](README_RU.md)

---

## ✨ Features

- **Several algorithms per case.** Tap one to make it your main alg. You can also add your own: it is accepted only if it actually solves the case on the virtual cube.
- **Algorithm player.** Animated 3D cube with step forward/back, speed control and drag-to-rotate.
- **Learning progress.** Mark each case New / Learning / Learned, add favourites and notes, and search across sets.
- **Smart trainer.** Slow and in-progress cases come up more often. You get practice scrambles, a hint button, your 5 slowest cases, and filters by set, status and favourites.
- **Timer.** WCA inspection (+2 / DNF), multiple sessions (3×3 and 2×2), +2 / DNF / delete per solve, best, ao5, ao12, ao100, mean, and a chart with a rolling ao5. The spacebar works on a keyboard.
- **Grayscale mode.** Only the stickers used in the current step stay coloured. For OLL that is just yellow; for F2L, just the pair you are solving.
- **Themes.** Light, dark or system theme, with 6 accent colours.
- **9 languages:** English, Русский, Українська, 中文, Español, Deutsch, Français, Português, Italiano.
- **Private.** No account and no internet needed. All progress stays on your device.

## 📚 Algorithm sets

| Puzzle | Method | Set | Cases | Algorithms |
|---|---|---|---:|---:|
| 3×3 | CFOP | F2L | 41 | 164 |
| 3×3 | CFOP | 2-Look OLL | 10 | 41 |
| 3×3 | CFOP | OLL | 57 | 252 |
| 3×3 | CFOP | 2-Look PLL | 6 | 23 |
| 3×3 | CFOP | PLL | 21 | 90 |
| 3×3 | CFOP | COLL | 40 | 160 |
| 3×3 | CFOP | ELL | 25 | 99 |
| 3×3 | Roux | CMLL | 42 | 171 |
| 3×3 | Roux | LSE | 15 | 15 |
| 2×2 | Ortega | Ortega OLL | 7 | 28 |
| 2×2 | Ortega | PBL | 6 | 24 |
| 2×2 | CLL / EG | CLL | 40 | 158 |
| 2×2 | CLL / EG | EG-1 | 40 | 137 |
| 2×2 | CLL / EG | EG-2 | 40 | 149 |
| | | **Total** | **390** | **1511** |

## ✅ How the algorithms are verified

- Every algorithm comes from a public, well-known source (see below).
- Each one was run on a cube simulator and kept only if it really solves its case, allowing for a final AUF. Algorithms that failed were removed.
- `flutter test` repeats this check in Dart on every run, so a broken algorithm fails the build.
- This check found two errors in the old database. PLL Ua and Ub were swapped, and the CMLL "T Top Row" algorithm actually solved "U Bottom Row". Both are fixed.

## 📲 Download

Get the latest APK from **[Releases](../../releases)**, then open it on your Android phone.

If Android says "App not installed", uninstall the old version first. This happens when the old version was signed with a different key.

## 🛠️ Build from source

Requirements: Flutter (stable) with a Dart SDK matching `pubspec.yaml`, plus Java 17 for Android builds.

```bash
flutter pub get
flutter analyze
flutter test              # also verifies every algorithm
flutter build apk --release
```

The APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

## 🤖 GitHub Actions

The `Build & test` workflow runs on every push and pull request, and you can also start it by hand. It analyzes the code, runs the tests and builds a release APK. You can download the APK from the run page as the `cube-trainer-apk` artifact.

To sign builds with your own key, add these repository secrets (Settings → Secrets and variables → Actions):

| Secret | Value |
|---|---|
| `KEYSTORE_BASE64` | your `.jks` file, base64-encoded |
| `KEYSTORE_PASSWORD` | keystore password |
| `KEY_PASSWORD` | key password |
| `KEY_ALIAS` | key alias |

Without these secrets, the workflow signs the APK with a temporary key that changes on every run. Each new build then has to be installed after uninstalling the old one.

## 🗂️ Project structure

```
lib/
├── data/        algorithm database (alg_data.dart)
├── l10n/        translations for 9 languages
├── logic/       alg tools, scrambles, stats, timer
├── models/      algorithm models and cube simulator
├── screens/     home, set, case, trainer, timer, session, settings
├── services/    app state and saved settings
├── theme/       colours and themes
└── widgets/     3D cube, last-layer view, alg player, shared UI
test/            widget tests and algorithm verification
```

## ⚠️ Known limitations

- Timer scrambles are random-move, not random-state like official WCA scrambles.
- EG-1 "L 3" and EG-2 "L 5" have only one verified algorithm each.

## 🙏 Sources and credits

- [SpeedCubeDB](https://speedcubedb.com): main algorithm source
- [CubeSkills](https://www.cubeskills.com): OLL
- Kian Mansour and Bradley K. Hobbs: CMLL / LSE

## 📄 License

[MIT](LICENSE)
