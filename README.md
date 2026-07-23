# SkyBuddies

A Russian-market weather app for iOS built with SwiftUI, featuring Duolingo-style cartoon weather characters and a Yandex Weather-inspired layout.

---

## Features

### Forecast Views
- **Day** — hourly breakdown for the next 24 hours with precipitation amounts
- **Week** — 7-day forecast with one-tap detail popup
- **Month** — 16-day forecast with color-coded temperature bars relative to the period range

### Cartoon Characters
Each weather condition is represented by an expressive, animated character:

| Condition | Character |
|-----------|-----------|
| Clear sky | Rotating sun with a big grin and rosy cheeks |
| Hot (>32°C) | Screaming sun in sunglasses — shaking, sweating |
| Partly cloudy | Winking cloud with a smug smile |
| Overcast | Bored cloud with one raised eyebrow |
| Fog | Confused character with mismatched brows |
| Rain | Sad cloud with animated tears and falling drops |
| Heavy rain | Furious cloud with angled rain drops |
| Snow | Shivering cloud with chattering-teeth mouth |
| Thunderstorm | Enraged cloud with pulsing lightning glow |

### Home Screen Widget (WidgetKit)
- **Small** — character, temperature, description, min/max
- **Medium** — character, temperature, description + humidity, wind speed, pressure panel
- Updates every 30 minutes; reflects the last city selected in the app
- Data shared between app and widget via App Groups

### Day Detail Popup
Tap any row in Week or Month view to open a bottom sheet with:
- Full-size character animation
- Min / Max temperature
- Sunrise & sunset times
- Precipitation and max wind speed

### City Search
- Autocomplete search powered by Open-Meteo Geocoding API (Russian locale)
- Quick-pick grid of 8 popular Russian cities

### Other Details
- Pressure displayed in **мм рт. ст.** (mmHg)
- Haptic feedback on tab switches and city / day selection
- App icon: the screaming hot-sun character

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI | SwiftUI, `@Observable` |
| Networking | `URLSession` + `async/await` |
| Weather API | [Open-Meteo](https://open-meteo.com) — free, no API key required |
| Geocoding | Open-Meteo Geocoding API |
| Widget | WidgetKit (`StaticConfiguration`, `TimelineProvider`) |
| Animations | SwiftUI native animations |
| Haptics | `UIImpactFeedbackGenerator` |
| Min deployment | iOS 17 |

---

## Architecture

```
SkyBuddies/
├── WeatherModels.swift        # Data models, WMO weather codes
├── WeatherService.swift       # Open-Meteo API client (@Observable)
├── WeatherCharacterView.swift # All cartoon characters & shapes
└── ContentView.swift          # Main UI — search, hero, day/week/month tabs

SkyBuddiesWidget/
├── SkyBuddiesWidgetBundle.swift  # Widget entry point
├── SkyBuddiesWidget.swift        # Timeline provider, views
├── WeatherCharacterView.swift    # Character views (shared copy for widget target)
└── WeatherCharacterType.swift    # WeatherCharacterType enum + WMO mapping
```

---

## Weather Data

Powered by [Open-Meteo](https://open-meteo.com) — an open-source weather API with:
- Hourly and daily forecasts up to 16 days
- WMO weather interpretation codes
- Automatic timezone detection
- No registration or API key required

---
