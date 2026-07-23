import Foundation
import Observation

@MainActor
@Observable
class WeatherService {
    var weatherData: WeatherData?
    var isLoading = false
    var errorMessage: String?
    var searchResults: [GeocodingResult] = []

    private let calendar = Calendar.current

    func fetchWeather(latitude: Double, longitude: Double, cityName: String) async {
        isLoading = true
        errorMessage = nil

        let urlString = """
        https://api.open-meteo.com/v1/forecast?\
        latitude=\(latitude)&longitude=\(longitude)\
        &current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,\
        cloud_cover,pressure_msl,surface_pressure,wind_speed_10m,wind_direction_10m,wind_gusts_10m,\
        uv_index,visibility\
        &hourly=temperature_2m,precipitation_probability,weather_code,wind_speed_10m,precipitation\
        &daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,precipitation_sum,\
        wind_speed_10m_max\
        &timezone=auto&forecast_days=35
        """

        guard let url = URL(string: urlString) else {
            errorMessage = "Неверный URL"
            isLoading = false
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
            weatherData = parseResponse(decoded, cityName: cityName, latitude: latitude, longitude: longitude)
        } catch {
            errorMessage = "Не удалось загрузить погоду: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func searchCities(query: String) async {
        guard query.count >= 2 else {
            searchResults = []
            return
        }

        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "https://geocoding-api.open-meteo.com/v1/search?name=\(encoded)&count=10&language=ru&format=json"

        guard let url = URL(string: urlString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(GeocodingResponse.self, from: data)
            searchResults = (decoded.results ?? []).map {
                GeocodingResult(
                    id: $0.id,
                    name: $0.name,
                    latitude: $0.latitude,
                    longitude: $0.longitude,
                    country: $0.country ?? "",
                    admin1: $0.admin1
                )
            }
        } catch {
            searchResults = []
        }
    }

    private func parseResponse(_ r: OpenMeteoResponse, cityName: String, latitude: Double, longitude: Double) -> WeatherData {
        let c = r.current
        let current = CurrentWeather(
            temperature: c.temperature2m,
            apparentTemperature: c.apparentTemperature,
            humidity: c.relativeHumidity2m,
            windSpeed: c.windSpeed10m,
            windDirection: c.windDirection10m,
            weatherCode: WeatherCode.from(code: c.weatherCode),
            isDay: c.isDay == 1,
            pressure: c.pressureMsl,
            visibility: c.visibility / 1000,
            uvIndex: c.uvIndex
        )

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime]

        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"

        let hourly: [HourlyWeather] = r.hourly.time.enumerated().compactMap { i, timeStr in
            guard let date = hourFormatter.date(from: timeStr) else { return nil }
            return HourlyWeather(
                time: date,
                temperature: r.hourly.temperature2m[i],
                weatherCode: WeatherCode.from(code: r.hourly.weatherCode[i]),
                precipitation: r.hourly.precipitation[i],
                windSpeed: r.hourly.windSpeed10m[i]
            )
        }

        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "yyyy-MM-dd"

        let daily: [DailyWeather] = r.daily.time.enumerated().compactMap { i, timeStr in
            guard let date = dayFormatter.date(from: timeStr) else { return nil }
            let sunrise = r.daily.sunrise[safe: i].flatMap { hourFormatter.date(from: $0) }
            let sunset = r.daily.sunset[safe: i].flatMap { hourFormatter.date(from: $0) }
            return DailyWeather(
                date: date,
                maxTemp: r.daily.temperature2mMax[i],
                minTemp: r.daily.temperature2mMin[i],
                weatherCode: WeatherCode.from(code: r.daily.weatherCode[i]),
                precipitationSum: r.daily.precipitationSum[i],
                windSpeedMax: r.daily.windSpeed10mMax[i],
                sunrise: sunrise,
                sunset: sunset
            )
        }

        return WeatherData(
            current: current,
            hourly: hourly,
            daily: daily,
            cityName: cityName,
            latitude: latitude,
            longitude: longitude
        )
    }
}

// MARK: - API Response Models

struct OpenMeteoResponse: Decodable {
    let current: CurrentResponse
    let hourly: HourlyResponse
    let daily: DailyResponse

    struct CurrentResponse: Decodable {
        let temperature2m: Double
        let relativeHumidity2m: Int
        let apparentTemperature: Double
        let isDay: Int
        let precipitation: Double
        let weatherCode: Int
        let cloudCover: Int
        let pressureMsl: Double
        let surfacePressure: Double
        let windSpeed10m: Double
        let windDirection10m: Int
        let windGusts10m: Double
        let uvIndex: Double
        let visibility: Double

        enum CodingKeys: String, CodingKey {
            case temperature2m = "temperature_2m"
            case relativeHumidity2m = "relative_humidity_2m"
            case apparentTemperature = "apparent_temperature"
            case isDay = "is_day"
            case precipitation
            case weatherCode = "weather_code"
            case cloudCover = "cloud_cover"
            case pressureMsl = "pressure_msl"
            case surfacePressure = "surface_pressure"
            case windSpeed10m = "wind_speed_10m"
            case windDirection10m = "wind_direction_10m"
            case windGusts10m = "wind_gusts_10m"
            case uvIndex = "uv_index"
            case visibility
        }
    }

    struct HourlyResponse: Decodable {
        let time: [String]
        let temperature2m: [Double]
        let precipitationProbability: [Int]
        let weatherCode: [Int]
        let windSpeed10m: [Double]
        let precipitation: [Double]

        enum CodingKeys: String, CodingKey {
            case time
            case temperature2m = "temperature_2m"
            case precipitationProbability = "precipitation_probability"
            case weatherCode = "weather_code"
            case windSpeed10m = "wind_speed_10m"
            case precipitation
        }
    }

    struct DailyResponse: Decodable {
        let time: [String]
        let weatherCode: [Int]
        let temperature2mMax: [Double]
        let temperature2mMin: [Double]
        let sunrise: [String]
        let sunset: [String]
        let precipitationSum: [Double]
        let windSpeed10mMax: [Double]

        enum CodingKeys: String, CodingKey {
            case time
            case weatherCode = "weather_code"
            case temperature2mMax = "temperature_2m_max"
            case temperature2mMin = "temperature_2m_min"
            case sunrise, sunset
            case precipitationSum = "precipitation_sum"
            case windSpeed10mMax = "wind_speed_10m_max"
        }
    }
}

struct GeocodingResponse: Decodable {
    let results: [GeocodingAPIResult]?

    struct GeocodingAPIResult: Decodable {
        let id: Int
        let name: String
        let latitude: Double
        let longitude: Double
        let country: String?
        let admin1: String?
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
