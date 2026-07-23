import WidgetKit
import SwiftUI

// MARK: - Entry

struct WeatherWidgetEntry: TimelineEntry {
    let date: Date
    let cityName: String
    let temperature: Int
    let description: String
    let emoji: String
    let minTemp: Int
    let maxTemp: Int
    let humidity: Int
    let windSpeed: Int
    let pressureMmHg: Int
}

// MARK: - Provider

struct WeatherWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeatherWidgetEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (WeatherWidgetEntry) -> Void) {
        completion(.placeholder)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherWidgetEntry>) -> Void) {
        Task {
            let entry = await WidgetWeatherFetcher.fetch()
            let refresh = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now
            completion(Timeline(entries: [entry], policy: .after(refresh)))
        }
    }
}

extension WeatherWidgetEntry {
    static let placeholder = WeatherWidgetEntry(
        date: .now, cityName: "Москва", temperature: 22,
        description: "Ясно", emoji: "☀️",
        minTemp: 16, maxTemp: 26, humidity: 58, windSpeed: 3, pressureMmHg: 758
    )
}

// MARK: - Fetcher

enum WidgetWeatherFetcher {
    static func fetch() async -> WeatherWidgetEntry {
        let defaults = UserDefaults(suiteName: "group.ru.hashier.SkyBuddies") ?? .standard
        let city = defaults.string(forKey: "sb_widget_city") ?? "Москва"
        let lat  = defaults.object(forKey: "sb_widget_lat")  as? Double ?? 55.7558
        let lon  = defaults.object(forKey: "sb_widget_lon")  as? Double ?? 37.6173

        let url = URL(string:
            "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)" +
            "&current=temperature_2m,weather_code,relative_humidity_2m,wind_speed_10m,pressure_msl" +
            "&daily=temperature_2m_max,temperature_2m_min&timezone=auto&forecast_days=1"
        )!

        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let decoded = try? JSONDecoder().decode(WidgetAPIResponse.self, from: data)
        else { return .placeholder }

        let code = decoded.current.weatherCode
        return WeatherWidgetEntry(
            date: .now,
            cityName: city,
            temperature: Int(decoded.current.temperature2m.rounded()),
            description: description(for: code),
            emoji: emoji(for: code),
            minTemp: Int((decoded.daily.temperature2mMin.first ?? 0).rounded()),
            maxTemp: Int((decoded.daily.temperature2mMax.first ?? 0).rounded()),
            humidity: decoded.current.relativeHumidity2m,
            windSpeed: Int(decoded.current.windSpeed10m.rounded()),
            pressureMmHg: Int((decoded.current.pressureMsl * 0.750062).rounded())
        )
    }

    static func emoji(for code: Int) -> String {
        switch code {
        case 0:        return "☀️"
        case 1, 2:     return "🌤️"
        case 3:        return "☁️"
        case 45, 48:   return "🌫️"
        case 51...55:  return "🌦️"
        case 61...65:  return "🌧️"
        case 71...77:  return "❄️"
        case 80...82:  return "🌧️"
        case 95...99:  return "⛈️"
        default:       return "🌤️"
        }
    }

    static func description(for code: Int) -> String {
        switch code {
        case 0:        return "Ясно"
        case 1:        return "Преимущественно ясно"
        case 2:        return "Переменная облачность"
        case 3:        return "Пасмурно"
        case 45, 48:   return "Туман"
        case 51...55:  return "Морось"
        case 61:       return "Небольшой дождь"
        case 63:       return "Дождь"
        case 65:       return "Сильный дождь"
        case 71...77:  return "Снег"
        case 80...82:  return "Ливень"
        case 95...99:  return "Гроза"
        default:       return "—"
        }
    }
}

// MARK: - API Response

struct WidgetAPIResponse: Decodable {
    let current: Current
    let daily: Daily

    struct Current: Decodable {
        let temperature2m: Double
        let weatherCode: Int
        let relativeHumidity2m: Int
        let windSpeed10m: Double
        let pressureMsl: Double

        enum CodingKeys: String, CodingKey {
            case temperature2m = "temperature_2m"
            case weatherCode = "weather_code"
            case relativeHumidity2m = "relative_humidity_2m"
            case windSpeed10m = "wind_speed_10m"
            case pressureMsl = "pressure_msl"
        }
    }

    struct Daily: Decodable {
        let temperature2mMax: [Double]
        let temperature2mMin: [Double]

        enum CodingKeys: String, CodingKey {
            case temperature2mMax = "temperature_2m_max"
            case temperature2mMin = "temperature_2m_min"
        }
    }
}

// MARK: - Widget Definition

struct SkyBuddiesWidget: Widget {
    let kind = "SkyBuddiesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeatherWidgetProvider()) { entry in
            SkyBuddiesWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    widgetBackground(for: entry.emoji)
                }
        }
        .configurationDisplayName("SkyBuddies")
        .description("Текущая погода у вас на экране")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

func widgetBackground(for emoji: String) -> LinearGradient {
    let colors: [Color]
    switch emoji {
    case "☀️":        colors = [Color(hex: "1A7AC4"), Color(hex: "64B8E8")]
    case "🌤️":        colors = [Color(hex: "3A6A90"), Color(hex: "7AABC8")]
    case "🌧️", "🌦️": colors = [Color(hex: "2A4860"), Color(hex: "607890")]
    case "⛈️":        colors = [Color(hex: "181C28"), Color(hex: "384050")]
    case "❄️":        colors = [Color(hex: "5A7890"), Color(hex: "A0C0D8")]
    default:          colors = [Color(hex: "5A6878"), Color(hex: "96A8B8")]
    }
    return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
}

// MARK: - Views

struct SkyBuddiesWidgetEntryView: View {
    let entry: WeatherWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall: smallView
        case .systemMedium: mediumView
        default: smallView
        }
    }

    var smallView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: "location.fill")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white.opacity(0.75))
                Text(entry.cityName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(1)
            }

            Text(entry.emoji)
                .font(.system(size: 52))
                .padding(.vertical, 2)

            Text("\(entry.temperature)°")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundColor(.white)

            Text(entry.description)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.78))
                .lineLimit(1)

            Spacer(minLength: 0)

            Text("\(entry.minTemp)° / \(entry.maxTemp)°")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.65))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(14)
    }

    var mediumView: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                    Text(entry.cityName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }

                HStack(alignment: .bottom, spacing: 8) {
                    Text(entry.emoji)
                        .font(.system(size: 46))
                    VStack(alignment: .leading, spacing: 1) {
                        Text("\(entry.temperature)°")
                            .font(.system(size: 38, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text(entry.description)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(1)
                    }
                }

                Text("\(entry.minTemp)° / \(entry.maxTemp)°")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.65))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 1)
                .padding(.vertical, 8)

            VStack(alignment: .leading, spacing: 10) {
                statRow(icon: "humidity.fill", value: "\(entry.humidity)%", color: Color(hex: "7EC8FF"))
                statRow(icon: "wind", value: "\(entry.windSpeed) м/с", color: .white)
                statRow(icon: "gauge.medium", value: "\(entry.pressureMmHg) мм", color: Color(hex: "A0D4FF"))
            }
            .frame(width: 110)
            .padding(.leading, 14)
        }
        .padding(16)
    }

    func statRow(icon: String, value: String, color: Color) -> some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(color)
                .frame(width: 18)
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Color helper

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double( int        & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}
