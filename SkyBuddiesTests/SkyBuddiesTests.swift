import Testing
@testable import SkyBuddies

// MARK: - WeatherCode mapping

@Suite("WeatherCode.from(code:)")
struct WeatherCodeFromTests {

    @Test("Known WMO codes map to correct cases")
    func knownCodes() {
        #expect(WeatherCode.from(code: 0)  == .clearSky)
        #expect(WeatherCode.from(code: 1)  == .mainlyClear)
        #expect(WeatherCode.from(code: 2)  == .partlyCloudy)
        #expect(WeatherCode.from(code: 3)  == .overcast)
        #expect(WeatherCode.from(code: 45) == .fog)
        #expect(WeatherCode.from(code: 48) == .depositingRimeFog)
        #expect(WeatherCode.from(code: 51) == .drizzleLight)
        #expect(WeatherCode.from(code: 53) == .drizzleModerate)
        #expect(WeatherCode.from(code: 55) == .drizzleDense)
        #expect(WeatherCode.from(code: 61) == .rainLight)
        #expect(WeatherCode.from(code: 63) == .rainModerate)
        #expect(WeatherCode.from(code: 65) == .rainHeavy)
        #expect(WeatherCode.from(code: 71) == .snowLight)
        #expect(WeatherCode.from(code: 75) == .snowHeavy)
        #expect(WeatherCode.from(code: 77) == .snowGrains)
        #expect(WeatherCode.from(code: 80) == .rainShowersLight)
        #expect(WeatherCode.from(code: 82) == .rainShowersViolent)
        #expect(WeatherCode.from(code: 95) == .thunderstorm)
        #expect(WeatherCode.from(code: 96) == .thunderstormWithHail)
        #expect(WeatherCode.from(code: 99) == .thunderstormWithHeavyHail)
    }

    @Test("Unknown code falls back to clearSky")
    func unknownCodeFallback() {
        #expect(WeatherCode.from(code: -1)  == .clearSky)
        #expect(WeatherCode.from(code: 999) == .clearSky)
        #expect(WeatherCode.from(code: 42)  == .clearSky)
    }
}

// MARK: - WeatherCode.characterType

@Suite("WeatherCode.characterType")
struct WeatherCodeCharacterTypeTests {

    @Test("Clear sky and mainly clear → sunny")
    func clearIsSunny() {
        #expect(WeatherCode.clearSky.characterType    == .sunny)
        #expect(WeatherCode.mainlyClear.characterType == .sunny)
    }

    @Test("Partly cloudy → partlyCloudy")
    func partlyCloudyCharacter() {
        #expect(WeatherCode.partlyCloudy.characterType == .partlyCloudy)
    }

    @Test("Overcast → cloudy")
    func overcastIsCloudy() {
        #expect(WeatherCode.overcast.characterType == .cloudy)
    }

    @Test("Fog codes → foggy")
    func fogIsFoggy() {
        #expect(WeatherCode.fog.characterType               == .foggy)
        #expect(WeatherCode.depositingRimeFog.characterType == .foggy)
    }

    @Test("Light/moderate rain → rainy")
    func lightRainIsRainy() {
        #expect(WeatherCode.drizzleLight.characterType    == .rainy)
        #expect(WeatherCode.rainLight.characterType       == .rainy)
        #expect(WeatherCode.rainShowersLight.characterType == .rainy)
    }

    @Test("Heavy rain / violent showers → heavyRain")
    func heavyRainCharacter() {
        #expect(WeatherCode.rainHeavy.characterType           == .heavyRain)
        #expect(WeatherCode.rainShowersModerate.characterType == .heavyRain)
        #expect(WeatherCode.rainShowersViolent.characterType  == .heavyRain)
    }

    @Test("Snow codes → snowy")
    func snowCharacter() {
        #expect(WeatherCode.snowLight.characterType    == .snowy)
        #expect(WeatherCode.snowModerate.characterType == .snowy)
        #expect(WeatherCode.snowHeavy.characterType    == .snowy)
        #expect(WeatherCode.snowGrains.characterType   == .snowy)
    }

    @Test("Thunderstorm codes → stormy")
    func thunderstormIsStormy() {
        #expect(WeatherCode.thunderstorm.characterType            == .stormy)
        #expect(WeatherCode.thunderstormWithHail.characterType    == .stormy)
        #expect(WeatherCode.thunderstormWithHeavyHail.characterType == .stormy)
    }
}

// MARK: - WeatherCode.characterType(temperature:)

@Suite("WeatherCode.characterType(temperature:)")
struct WeatherCodeHotSunTests {

    @Test("Clear sky + temp > 32 → hotSun")
    func hotSunAboveThreshold() {
        #expect(WeatherCode.clearSky.characterType(temperature: 33)   == .hotSun)
        #expect(WeatherCode.clearSky.characterType(temperature: 32.1) == .hotSun)
        #expect(WeatherCode.mainlyClear.characterType(temperature: 40) == .hotSun)
    }

    @Test("Clear sky + temp ≤ 32 → sunny (not hotSun)")
    func normalSunBelowThreshold() {
        #expect(WeatherCode.clearSky.characterType(temperature: 32)   == .sunny)
        #expect(WeatherCode.clearSky.characterType(temperature: 31.9) == .sunny)
        #expect(WeatherCode.clearSky.characterType(temperature: 0)    == .sunny)
    }

    @Test("Non-sunny code + high temp → NOT hotSun")
    func highTempDoesNotUpgradeOtherCodes() {
        #expect(WeatherCode.overcast.characterType(temperature: 40)   == .cloudy)
        #expect(WeatherCode.rainLight.characterType(temperature: 35)  == .rainy)
        #expect(WeatherCode.thunderstorm.characterType(temperature: 38) == .stormy)
    }
}

// MARK: - CurrentWeather.pressureMmHg

@Suite("CurrentWeather.pressureMmHg conversion")
struct PressureConversionTests {

    func makeWeather(pressure hPa: Double) -> CurrentWeather {
        CurrentWeather(
            temperature: 20, apparentTemperature: 18,
            humidity: 60, windSpeed: 5, windDirection: 180,
            weatherCode: .clearSky, isDay: true,
            pressure: hPa, visibility: 10, uvIndex: 3
        )
    }

    @Test("Standard atmosphere: 1013.25 hPa ≈ 760 mmHg")
    func standardAtmosphere() {
        let w = makeWeather(pressure: 1013.25)
        #expect(w.pressureMmHg == 760)
    }

    @Test("750 hPa → 563 mmHg")
    func lowPressure() {
        let w = makeWeather(pressure: 750)
        #expect(w.pressureMmHg == 563)
    }

    @Test("1000 hPa → 750 mmHg")
    func roundPressure() {
        let w = makeWeather(pressure: 1000)
        #expect(w.pressureMmHg == 750)
    }
}

// MARK: - CurrentWeather.characterType

@Suite("CurrentWeather.characterType delegates temperature")
struct CurrentWeatherCharacterTypeTests {

    func makeWeather(code: WeatherCode, temperature: Double) -> CurrentWeather {
        CurrentWeather(
            temperature: temperature, apparentTemperature: temperature - 2,
            humidity: 50, windSpeed: 3, windDirection: 90,
            weatherCode: code, isDay: true,
            pressure: 1013, visibility: 10, uvIndex: 2
        )
    }

    @Test("Hot clear day returns hotSun")
    func hotClearDay() {
        let w = makeWeather(code: .clearSky, temperature: 35)
        #expect(w.characterType == .hotSun)
    }

    @Test("Normal clear day returns sunny")
    func normalClearDay() {
        let w = makeWeather(code: .clearSky, temperature: 25)
        #expect(w.characterType == .sunny)
    }

    @Test("Rainy day ignores temperature")
    func rainyDay() {
        let w = makeWeather(code: .rainHeavy, temperature: 35)
        #expect(w.characterType == .heavyRain)
    }
}

// MARK: - WeatherCode.russianDescription

@Suite("WeatherCode.russianDescription")
struct RussianDescriptionTests {

    @Test("Key descriptions are in Russian")
    func spotCheckDescriptions() {
        #expect(WeatherCode.clearSky.russianDescription == "Ясно")
        #expect(WeatherCode.overcast.russianDescription == "Пасмурно")
        #expect(WeatherCode.fog.russianDescription      == "Туман")
        #expect(WeatherCode.rainLight.russianDescription == "Небольшой дождь")
        #expect(WeatherCode.rainModerate.russianDescription == "Дождь")
        #expect(WeatherCode.rainHeavy.russianDescription == "Сильный дождь")
        #expect(WeatherCode.snowLight.russianDescription == "Небольшой снег")
        #expect(WeatherCode.thunderstorm.russianDescription == "Гроза")
    }

    @Test("All drizzle codes share 'Морось' description")
    func drizzleDescription() {
        #expect(WeatherCode.drizzleLight.russianDescription    == "Морось")
        #expect(WeatherCode.drizzleModerate.russianDescription == "Морось")
        #expect(WeatherCode.drizzleDense.russianDescription    == "Морось")
    }
}

// MARK: - GeocodingResult.displayName

@Suite("GeocodingResult.displayName")
struct GeocodingResultDisplayNameTests {

    @Test("With admin1 region shows city and region")
    func withRegion() {
        let r = GeocodingResult(id: 1, name: "Казань", latitude: 55.79,
                                longitude: 49.12, country: "Россия", admin1: "Татарстан")
        #expect(r.displayName == "Казань, Татарстан")
    }

    @Test("Without admin1 falls back to country")
    func withoutRegion() {
        let r = GeocodingResult(id: 2, name: "Москва", latitude: 55.76,
                                longitude: 37.62, country: "Россия", admin1: nil)
        #expect(r.displayName == "Москва, Россия")
    }
}

// MARK: - Array safe subscript

@Suite("Array safe subscript")
struct ArraySafeSubscriptTests {

    @Test("Valid index returns element")
    func validIndex() {
        let arr = [10, 20, 30]
        #expect(arr[safe: 0] == 10)
        #expect(arr[safe: 2] == 30)
    }

    @Test("Out-of-bounds returns nil")
    func outOfBounds() {
        let arr = [1, 2, 3]
        #expect(arr[safe: 3]  == nil)
        #expect(arr[safe: -1] == nil)
    }

    @Test("Empty array always returns nil")
    func emptyArray() {
        let arr: [Int] = []
        #expect(arr[safe: 0] == nil)
    }
}
