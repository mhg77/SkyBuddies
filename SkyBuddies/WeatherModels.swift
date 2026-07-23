import Foundation

enum WeatherCode: Int {
    case clearSky = 0
    case mainlyClear = 1
    case partlyCloudy = 2
    case overcast = 3
    case fog = 45
    case depositingRimeFog = 48
    case drizzleLight = 51
    case drizzleModerate = 53
    case drizzleDense = 55
    case rainLight = 61
    case rainModerate = 63
    case rainHeavy = 65
    case snowLight = 71
    case snowModerate = 73
    case snowHeavy = 75
    case snowGrains = 77
    case rainShowersLight = 80
    case rainShowersModerate = 81
    case rainShowersViolent = 82
    case thunderstorm = 95
    case thunderstormWithHail = 96
    case thunderstormWithHeavyHail = 99

    var russianDescription: String {
        switch self {
        case .clearSky: return "Ясно"
        case .mainlyClear: return "Преимущественно ясно"
        case .partlyCloudy: return "Переменная облачность"
        case .overcast: return "Пасмурно"
        case .fog, .depositingRimeFog: return "Туман"
        case .drizzleLight, .drizzleModerate, .drizzleDense: return "Морось"
        case .rainLight: return "Небольшой дождь"
        case .rainModerate: return "Дождь"
        case .rainHeavy: return "Сильный дождь"
        case .snowLight: return "Небольшой снег"
        case .snowModerate: return "Снег"
        case .snowHeavy: return "Сильный снег"
        case .snowGrains: return "Снежная крупа"
        case .rainShowersLight: return "Ливень"
        case .rainShowersModerate, .rainShowersViolent: return "Сильный ливень"
        case .thunderstorm: return "Гроза"
        case .thunderstormWithHail, .thunderstormWithHeavyHail: return "Гроза с градом"
        }
    }

    var characterType: WeatherCharacterType {
        switch self {
        case .clearSky, .mainlyClear: return .sunny
        case .partlyCloudy: return .partlyCloudy
        case .overcast: return .cloudy
        case .fog, .depositingRimeFog: return .foggy
        case .drizzleLight, .drizzleModerate, .drizzleDense,
             .rainLight, .rainModerate, .rainShowersLight: return .rainy
        case .rainHeavy, .rainShowersModerate, .rainShowersViolent: return .heavyRain
        case .snowLight, .snowModerate, .snowHeavy, .snowGrains: return .snowy
        case .thunderstorm, .thunderstormWithHail, .thunderstormWithHeavyHail: return .stormy
        }
    }

    func characterType(temperature: Double) -> WeatherCharacterType {
        let base = characterType
        if base == .sunny && temperature > 32 { return .hotSun }
        return base
    }

    static func from(code: Int) -> WeatherCode {
        WeatherCode(rawValue: code) ?? .clearSky
    }
}

enum WeatherCharacterType: Equatable {
    case sunny, hotSun, partlyCloudy, cloudy, foggy, rainy, heavyRain, snowy, stormy
}

struct HourlyWeather: Identifiable {
    let id = UUID()
    let time: Date
    let temperature: Double
    let weatherCode: WeatherCode
    let precipitation: Double
    let windSpeed: Double
}

struct DailyWeather: Identifiable {
    let id = UUID()
    let date: Date
    let maxTemp: Double
    let minTemp: Double
    let weatherCode: WeatherCode
    let precipitationSum: Double
    let windSpeedMax: Double
    let sunrise: Date?
    let sunset: Date?
}

struct CurrentWeather {
    let temperature: Double
    let apparentTemperature: Double
    let humidity: Int
    let windSpeed: Double
    let windDirection: Int
    let weatherCode: WeatherCode
    let isDay: Bool
    let pressure: Double
    let visibility: Double
    let uvIndex: Double

    var characterType: WeatherCharacterType {
        weatherCode.characterType(temperature: temperature)
    }
}

struct WeatherData {
    let current: CurrentWeather
    let hourly: [HourlyWeather]
    let daily: [DailyWeather]
    let cityName: String
    let latitude: Double
    let longitude: Double
}

struct GeocodingResult: Identifiable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String
    let admin1: String?

    var displayName: String {
        if let region = admin1 {
            return "\(name), \(region)"
        }
        return "\(name), \(country)"
    }
}
