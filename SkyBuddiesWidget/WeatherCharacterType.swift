import Foundation

enum WeatherCharacterType: Equatable {
    case sunny, hotSun, partlyCloudy, cloudy, foggy, rainy, heavyRain, snowy, stormy

    static func from(code: Int, temperature: Double) -> WeatherCharacterType {
        let base: WeatherCharacterType
        switch code {
        case 0, 1:       base = .sunny
        case 2:          base = .partlyCloudy
        case 3:          base = .cloudy
        case 45, 48:     base = .foggy
        case 51, 53, 55, 61, 63, 80: base = .rainy
        case 65, 81, 82: base = .heavyRain
        case 71, 73, 75, 77: base = .snowy
        case 95, 96, 99: base = .stormy
        default:         base = .partlyCloudy
        }
        if base == .sunny && temperature > 32 { return .hotSun }
        return base
    }
}
