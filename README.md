# SimoPiso 💸

> A local-first Android expense tracker that tells you not just what you owe — but how much you need to earn.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat&logo=flutter)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?style=flat&logo=android)
![License](https://img.shields.io/badge/License-MIT-00C896?style=flat)
![Status](https://img.shields.io/badge/Status-Active-00C896?style=flat)

---

## About

SimoPiso is a personal finance app built for Filipinos who want a clear picture of their monthly obligations. It tracks subscriptions, bills, loans, and one-time expenses — then tells you the minimum income you need to cover everything while hitting your savings target.

No accounts. No cloud. Everything stays on your device.

---

## Features

- 📊 **Dashboard** — Monthly obligations summary, overdue alerts, upcoming dues, and payment progress at a glance
- 💳 **Expense Tracking** — Add, edit, and manage subscriptions, bills, loans, and one-time payments
- ⚡ **Quick Actions** — Swipe right to mark paid, swipe left to delete, with undo support
- 🧮 **Income Goal Calculator** — Enter your savings target and get a recommended minimum monthly and daily income
- 📅 **Calendar View** — See all due dates on a calendar with color-coded status markers
- 📈 **Charts & Breakdown** — Donut and bar charts showing where your money goes by category
- 🔔 **Due Date Reminders** — Notifications 3 days and 1 day before each payment is due
- 📤 **Export** — Generate monthly PDF reports or CSV files and share them instantly

---

## Screenshots

> _Coming soon — UI screenshots will be added here._

---

## Tech Stack

| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management |
| `go_router` | Navigation |
| `fl_chart` | Donut and bar charts |
| `table_calendar` | Calendar view |
| `flutter_local_notifications` | Due date reminders |
| `pdf` + `share_plus` | PDF export and sharing |
| `path_provider` | Local file storage |
| `intl` | PHP peso formatting |
| `uuid` | Unique expense IDs |

---

## Getting Started

### Prerequisites

- Flutter SDK 3.x or later
- Android Studio or VS Code with Flutter extension
- Android device or emulator (API 21+)

### Run Locally

```bash
git clone https://github.com/YOUR_USERNAME/SimoPiso.git
cd SimoPiso
flutter pub get
flutter run
```

### Build APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

---

## Project Structure

```
lib/
├── main.dart
├── app.dart                        # App entry, theme, routing
├── core/
│   ├── theme/                      # Colors and text styles
│   ├── utils/                      # Currency and date helpers
│   └── notifications/              # Notification service
├── data/
│   ├── models/                     # Expense model and enums
│   ├── repositories/               # Local JSON persistence
│   └── services/                   # PDF/CSV export
├── features/
│   ├── dashboard/                  # Home screen
│   ├── expenses/                   # Expense list and add/edit sheet
│   ├── calendar/                   # Calendar due date view
│   ├── income_goal/                # Income calculator
│   ├── charts/                     # Spending breakdown
│   └── settings/                   # Preferences and export
└── shared/
    └── widgets/                    # App shell and reusable components
```

---

## Roadmap

> Currently on **v1.0**

### Next Up
- [ ] Full per-expense notification scheduling
- [ ] Recurring expense auto-generation (monthly carry-over)
- [ ] Onboarding flow for first-time users
- [ ] Payment history per expense
- [ ] Import / backup from JSON file
- [ ] Home screen widget

### Future Ideas
- [ ] Advanced analytics and spending projections
- [ ] iOS support
- [ ] Optional encrypted cloud backup

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

<p align="center">Built by <strong>Simo</strong> · Made for 🇵🇭</p>