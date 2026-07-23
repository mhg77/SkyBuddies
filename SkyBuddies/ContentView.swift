import SwiftUI

struct ContentView: View {
    @State private var service = WeatherService()
    @State private var selectedTab = 0
    @State private var showSearch = false
    @State private var searchQuery = ""
    @State private var searchTask: Task<Void, Never>?

    // Default city: Moscow
    @State private var cityName = "Москва"
    @State private var latitude = 55.7558
    @State private var longitude = 37.6173

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()

            if showSearch {
                searchView
                    .transition(.move(edge: .top).combined(with: .opacity))
            } else {
                mainView
                    .transition(.opacity)
            }
        }
        .animation(.spring(duration: 0.35), value: showSearch)
        .task {
            await service.fetchWeather(latitude: latitude, longitude: longitude, cityName: cityName)
        }
    }

    // MARK: - Background

    var backgroundGradient: some View {
        let colors: [Color]
        if let data = service.weatherData {
            switch data.current.weatherCode.characterType {
            case .sunny:
                colors = [Color(hex: "87CEEB"), Color(hex: "E0F4FF")]
            case .partlyCloudy:
                colors = [Color(hex: "9BB8D4"), Color(hex: "D6E8F5")]
            case .cloudy, .foggy:
                colors = [Color(hex: "8A9BB0"), Color(hex: "C8D5E0")]
            case .rainy, .heavyRain:
                colors = [Color(hex: "4A6A80"), Color(hex: "8AAABB")]
            case .snowy:
                colors = [Color(hex: "AAC4D8"), Color(hex: "E8F2FA")]
            case .stormy:
                colors = [Color(hex: "2D3A4A"), Color(hex: "506070")]
            }
        } else {
            colors = [Color(hex: "87CEEB"), Color(hex: "E0F4FF")]
        }
        return LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
    }

    // MARK: - Main View

    var mainView: some View {
        VStack(spacing: 0) {
            // Header
            headerView
                .padding(.top, 8)

            if service.isLoading {
                Spacer()
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                Spacer()
            } else if let data = service.weatherData {
                // Current weather hero
                currentWeatherHero(data: data)

                // Tab selector
                tabSelector
                    .padding(.vertical, 12)

                // Tab content
                TabView(selection: $selectedTab) {
                    DayView(data: data).tag(0)
                    WeekView(data: data).tag(1)
                    MonthView(data: data).tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            } else if let err = service.errorMessage {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.white)
                    Text(err)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Повторить") {
                        Task { await service.fetchWeather(latitude: latitude, longitude: longitude, cityName: cityName) }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.white)
                    .foregroundColor(.blue)
                }
                Spacer()
            }
        }
    }

    // MARK: - Header

    var headerView: some View {
        HStack {
            Button {
                withAnimation { showSearch = true }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text(cityName)
                        .font(.system(size: 20, weight: .bold))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(.white)
            }

            Spacer()

            Button {
                Task { await service.fetchWeather(latitude: latitude, longitude: longitude, cityName: cityName) }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white.opacity(0.85))
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 4)
    }

    // MARK: - Current Weather Hero

    func currentWeatherHero(data: WeatherData) -> some View {
        VStack(spacing: 0) {
            WeatherCharacterView(type: data.current.weatherCode.characterType, size: 180)
                .padding(.vertical, 8)

            Text("\(Int(data.current.temperature.rounded()))°")
                .font(.system(size: 80, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)

            Text(data.current.weatherCode.russianDescription)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
                .padding(.top, 2)

            Text("Ощущается как \(Int(data.current.apparentTemperature.rounded()))°")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.75))
                .padding(.top, 3)

            // Stats row
            HStack(spacing: 0) {
                statItem(icon: "humidity.fill", value: "\(data.current.humidity)%", label: "Влажность")
                Divider().frame(height: 36).background(Color.white.opacity(0.3))
                statItem(icon: "wind", value: "\(Int(data.current.windSpeed)) м/с", label: "Ветер")
                Divider().frame(height: 36).background(Color.white.opacity(0.3))
                statItem(icon: "gauge.medium", value: "\(Int(data.current.pressure)) мб", label: "Давление")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.18))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
    }

    func statItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.85))
            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Tab Selector

    var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(["День", "Неделя", "Месяц"].indices, id: \.self) { i in
                Button {
                    withAnimation(.spring(duration: 0.28)) { selectedTab = i }
                } label: {
                    Text(["День", "Неделя", "Месяц"][i])
                        .font(.system(size: 15, weight: selectedTab == i ? .bold : .medium))
                        .foregroundColor(selectedTab == i ? .white : .white.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            selectedTab == i
                            ? Color.white.opacity(0.28)
                            : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(.horizontal, 20)
        .background(Color.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 20)
    }

    // MARK: - Search View

    var searchView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.7))
                TextField("", text: $searchQuery, prompt: Text("Введите город...").foregroundColor(.white.opacity(0.5)))
                    .foregroundColor(.white)
                    .font(.system(size: 17))
                    .autocorrectionDisabled()
                    .onChange(of: searchQuery) { _, newValue in
                        searchTask?.cancel()
                        searchTask = Task {
                            try? await Task.sleep(nanoseconds: 350_000_000)
                            if !Task.isCancelled {
                                await service.searchCities(query: newValue)
                            }
                        }
                    }
                Button {
                    searchQuery = ""
                    service.searchResults = []
                    withAnimation { showSearch = false }
                } label: {
                    Text("Отмена")
                        .foregroundColor(.white)
                        .font(.system(size: 15, weight: .medium))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.18))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 16)
            .padding(.top, 56)

            // Popular Russian cities
            if searchQuery.isEmpty {
                popularCitiesView
            }

            // Search results
            if !service.searchResults.isEmpty {
                ScrollView {
                    VStack(spacing: 2) {
                        ForEach(service.searchResults) { city in
                            Button {
                                selectCity(city)
                            } label: {
                                HStack {
                                    Image(systemName: "location")
                                        .foregroundColor(.white.opacity(0.6))
                                        .frame(width: 24)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(city.name)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.white)
                                        Text(city.displayName)
                                            .font(.system(size: 13))
                                            .foregroundColor(.white.opacity(0.65))
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.top, 12)
                }
            }

            Spacer()
        }
    }

    var popularCitiesView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Популярные города")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal, 20)
                .padding(.top, 20)

            let cities: [(String, Double, Double)] = [
                ("Москва", 55.7558, 37.6173),
                ("Санкт-Петербург", 59.9343, 30.3351),
                ("Новосибирск", 54.9833, 82.8964),
                ("Екатеринбург", 56.8356, 60.6128),
                ("Казань", 55.7887, 49.1221),
                ("Краснодар", 45.0448, 38.9760),
                ("Сочи", 43.5992, 39.7257),
                ("Владивосток", 43.1155, 131.8855),
            ]

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(cities, id: \.0) { city in
                    Button {
                        let result = GeocodingResult(id: 0, name: city.0, latitude: city.1, longitude: city.2, country: "Россия", admin1: nil)
                        selectCity(result)
                    } label: {
                        HStack {
                            Image(systemName: "building.2")
                                .foregroundColor(.white.opacity(0.6))
                                .font(.system(size: 13))
                            Text(city.0)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func selectCity(_ city: GeocodingResult) {
        cityName = city.name
        latitude = city.latitude
        longitude = city.longitude
        searchQuery = ""
        service.searchResults = []
        withAnimation { showSearch = false }
        Task { await service.fetchWeather(latitude: latitude, longitude: longitude, cityName: cityName) }
    }
}

// MARK: - Day View (hourly)

struct DayView: View {
    let data: WeatherData

    private var todayHourly: [HourlyWeather] {
        let now = Date()
        let calendar = Calendar.current
        let endOfTomorrow = calendar.date(byAdding: .hour, value: 24, to: now) ?? now
        return data.hourly.filter { $0.time >= now && $0.time <= endOfTomorrow }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Hourly scroll
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(todayHourly) { hour in
                            HourlyCell(hour: hour)
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // Today's daily info
                if let today = data.daily.first {
                    dailyDetailCard(day: today)
                }
            }
            .padding(.bottom, 24)
        }
    }

    func dailyDetailCard(day: DailyWeather) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text("Сегодня")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text("\(Int(day.minTemp.rounded()))° / \(Int(day.maxTemp.rounded()))°")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white.opacity(0.85))
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)

            Divider().background(Color.white.opacity(0.2)).padding(.vertical, 10).padding(.horizontal, 16)

            VStack(spacing: 10) {
                if let sunrise = day.sunrise, let sunset = day.sunset {
                    detailRow(icon: "sunrise.fill", label: "Восход", value: timeString(sunrise), color: Color(hex: "FFB347"))
                    detailRow(icon: "sunset.fill", label: "Закат", value: timeString(sunset), color: Color(hex: "FF6B6B"))
                }
                detailRow(icon: "drop.fill", label: "Осадки", value: String(format: "%.1f мм", day.precipitationSum), color: Color(hex: "4A90D9"))
                detailRow(icon: "wind", label: "Ветер", value: "\(Int(day.windSpeedMax)) м/с", color: Color.white.opacity(0.8))
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
        }
        .background(Color.white.opacity(0.16))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 20)
    }

    func detailRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.75))
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
    }

    func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }
}

struct HourlyCell: View {
    let hour: HourlyWeather

    var body: some View {
        VStack(spacing: 8) {
            Text(hourLabel)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.8))

            WeatherCharacterView(type: hour.weatherCode.characterType, size: 44)
                .frame(width: 44, height: 44)

            Text("\(Int(hour.temperature.rounded()))°")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)

            if hour.precipitation > 0 {
                Text("\(hour.precipitation, specifier: "%.1f")мм")
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: "7EC8FF"))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .frame(width: 68)
    }

    var hourLabel: String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: hour.time)
    }
}

// MARK: - Week View (7 days)

struct WeekView: View {
    let data: WeatherData
    private var weekDays: [DailyWeather] { Array(data.daily.prefix(7)) }

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(weekDays) { day in
                    WeekDayRow(day: day)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }
}

struct WeekDayRow: View {
    let day: DailyWeather

    var body: some View {
        HStack(spacing: 12) {
            Text(dayLabel)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 90, alignment: .leading)

            WeatherCharacterView(type: day.weatherCode.characterType, size: 38)
                .frame(width: 38, height: 38)

            Text(day.weatherCode.russianDescription)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.75))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 4) {
                Text("\(Int(day.minTemp.rounded()))°")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                Text("/")
                    .foregroundColor(.white.opacity(0.4))
                Text("\(Int(day.maxTemp.rounded()))°")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    var dayLabel: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "EEEE"
        let str = f.string(from: day.date)
        return str.prefix(1).uppercased() + str.dropFirst()
    }
}

// MARK: - Month View (up to 16 days)

struct MonthView: View {
    let data: WeatherData

    var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                ForEach(data.daily) { day in
                    MonthDayRow(day: day)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }
}

struct MonthDayRow: View {
    let day: DailyWeather

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 1) {
                Text(dayName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Text(dateStr)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(width: 72, alignment: .leading)

            WeatherCharacterView(type: day.weatherCode.characterType, size: 32)
                .frame(width: 32, height: 32)

            // Temp bar
            GeometryReader { geo in
                tempBar(in: geo.size.width)
            }
            .frame(height: 8)

            Text("\(Int(day.minTemp.rounded()))° / \(Int(day.maxTemp.rounded()))°")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 72, alignment: .trailing)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(Color.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    func tempBar(in width: CGFloat) -> some View {
        let allTemps = [-30.0, 40.0]
        let range = allTemps[1] - allTemps[0]
        let minFrac = (day.minTemp - allTemps[0]) / range
        let maxFrac = (day.maxTemp - allTemps[0]) / range
        let barColor = barColorForTemp(day.maxTemp)

        return ZStack(alignment: .leading) {
            Capsule()
                .fill(Color.white.opacity(0.2))
                .frame(height: 8)
            Capsule()
                .fill(barColor)
                .frame(width: max(4, (maxFrac - minFrac) * width), height: 8)
                .offset(x: minFrac * width)
        }
    }

    func barColorForTemp(_ t: Double) -> Color {
        switch t {
        case ..<0: return Color(hex: "7EC8FF")
        case 0..<10: return Color(hex: "A8E6CF")
        case 10..<20: return Color(hex: "FFD93D")
        case 20..<30: return Color(hex: "FF9500")
        default: return Color(hex: "FF3B30")
        }
    }

    var dayName: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "EEEE"
        let str = f.string(from: day.date)
        return String((str.prefix(1).uppercased() + str.dropFirst()).prefix(3))
    }

    var dateStr: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "d MMM"
        return f.string(from: day.date)
    }
}

#Preview {
    ContentView()
}
