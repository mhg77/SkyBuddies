import SwiftUI
import UIKit

struct ContentView: View {
    @State private var service = WeatherService()
    @State private var selectedTab = 0
    @State private var showSearch = false
    @State private var searchQuery = ""
    @State private var searchTask: Task<Void, Never>?

    @State private var cityName = "Москва"
    @State private var latitude = 55.7558
    @State private var longitude = 37.6173

    var body: some View {
        ZStack {
            backgroundGradient.ignoresSafeArea()

            if showSearch {
                searchView.transition(.move(edge: .top).combined(with: .opacity))
            } else {
                mainView.transition(.opacity)
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
            switch data.current.characterType {
            case .sunny, .hotSun: colors = [Color(hex: "1A7AC4"), Color(hex: "64B8E8")]
            case .partlyCloudy:   colors = [Color(hex: "3A6A90"), Color(hex: "7AABC8")]
            case .cloudy, .foggy: colors = [Color(hex: "5A6878"), Color(hex: "96A8B8")]
            case .rainy, .heavyRain: colors = [Color(hex: "2A4860"), Color(hex: "607890")]
            case .snowy:          colors = [Color(hex: "5A7890"), Color(hex: "A0C0D8")]
            case .stormy:         colors = [Color(hex: "181C28"), Color(hex: "384050")]
            }
        } else {
            colors = [Color(hex: "1A7AC4"), Color(hex: "64B8E8")]
        }
        return LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
    }

    // MARK: - Main View

    var mainView: some View {
        VStack(spacing: 0) {
            headerView.padding(.top, 8)

            if service.isLoading {
                Spacer()
                VStack(spacing: 16) {
                    ProgressView().scaleEffect(1.6).tint(.white)
                    Text("Загружаем погоду...")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
            } else if let data = service.weatherData {
                currentWeatherHero(data: data)
                tabSelector.padding(.top, 14).padding(.bottom, 10)
                tabContent(data: data)
            } else if let err = service.errorMessage {
                Spacer()
                VStack(spacing: 14) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 48)).foregroundColor(.white)
                    Text(err)
                        .foregroundColor(.white).multilineTextAlignment(.center).padding(.horizontal)
                    Button("Повторить") {
                        Task { await service.fetchWeather(latitude: latitude, longitude: longitude, cityName: cityName) }
                    }
                    .buttonStyle(.borderedProminent).tint(.white).foregroundColor(.blue)
                }
                Spacer()
            }
        }
    }

    // MARK: - Header

    var headerView: some View {
        HStack {
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                withAnimation { showSearch = true }
            } label: {
                HStack(spacing: 7) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 13, weight: .semibold))
                    Text(cityName)
                        .font(.system(size: 21, weight: .bold))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundColor(.white)
            }
            Spacer()
            Button {
                Task { await service.fetchWeather(latitude: latitude, longitude: longitude, cityName: cityName) }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 4)
    }

    // MARK: - Current Weather Hero

    func currentWeatherHero(data: WeatherData) -> some View {
        VStack(spacing: 0) {
            WeatherCharacterView(type: data.current.characterType, size: 170)
                .padding(.vertical, 6)

            Text("\(Int(data.current.temperature.rounded()))°")
                .font(.system(size: 82, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.2), radius: 6, y: 3)

            Text(data.current.weatherCode.russianDescription)
                .font(.system(size: 19, weight: .semibold))
                .foregroundColor(.white.opacity(0.95))
                .padding(.top, 2)

            Text("Ощущается как \(Int(data.current.apparentTemperature.rounded()))°")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.72))
                .padding(.top, 4)

            // Stats pill
            HStack(spacing: 0) {
                statCell(icon: "humidity.fill", value: "\(data.current.humidity)%", label: "Влажность", iconColor: Color(hex: "7EC8FF"))
                Rectangle().fill(Color.white.opacity(0.25)).frame(width: 1, height: 38)
                statCell(icon: "wind", value: "\(Int(data.current.windSpeed)) м/с", label: "Ветер", iconColor: .white)
                Rectangle().fill(Color.white.opacity(0.25)).frame(width: 1, height: 38)
                statCell(icon: "gauge.medium", value: "\(data.current.pressureMmHg)", label: "мм рт.ст.", iconColor: Color(hex: "A0D4FF"))
            }
            .padding(.vertical, 12)
            .background(.ultraThinMaterial.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
    }

    func statCell(icon: String, value: String, label: String, iconColor: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(iconColor)
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.65))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Tab Selector (fixed equal widths)

    var tabSelector: some View {
        let labels = ["День", "Неделя", "Месяц"]
        return HStack(spacing: 4) {
            ForEach(labels.indices, id: \.self) { i in
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.spring(duration: 0.26)) { selectedTab = i }
                } label: {
                    Text(labels[i])
                        .font(.system(size: 15, weight: selectedTab == i ? .bold : .semibold))
                        .foregroundColor(selectedTab == i ? .white : .white.opacity(0.55))
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(
                            selectedTab == i
                            ? Color.white.opacity(0.26)
                            : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(4)
        .background(Color.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding(.horizontal, 20)
    }

    // MARK: - Tab Content (no TabView page to avoid scroll conflict)

    @ViewBuilder
    func tabContent(data: WeatherData) -> some View {
        Group {
            switch selectedTab {
            case 0: DayView(data: data)
            case 1: WeekView(data: data)
            default: MonthView(data: data)
            }
        }
        .frame(maxHeight: .infinity)
        .transition(.opacity)
    }

    // MARK: - Search View

    var searchView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass").foregroundColor(.white.opacity(0.65))
                TextField("", text: $searchQuery,
                          prompt: Text("Введите город...").foregroundColor(.white.opacity(0.45)))
                .foregroundColor(.white)
                .font(.system(size: 17))
                .autocorrectionDisabled()
                .onChange(of: searchQuery) { _, q in
                    searchTask?.cancel()
                    searchTask = Task {
                        try? await Task.sleep(nanoseconds: 350_000_000)
                        if !Task.isCancelled { await service.searchCities(query: q) }
                    }
                }
                Button {
                    searchQuery = ""; service.searchResults = []
                    withAnimation { showSearch = false }
                } label: {
                    Text("Отмена").foregroundColor(.white).font(.system(size: 15, weight: .semibold))
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 13)
            .background(.ultraThinMaterial.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 16).padding(.top, 58)

            if searchQuery.isEmpty {
                popularCitiesView
            } else if !service.searchResults.isEmpty {
                ScrollView {
                    VStack(spacing: 3) {
                        ForEach(service.searchResults) { city in
                            Button { selectCity(city) } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundColor(.white.opacity(0.5)).font(.system(size: 18))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(city.name)
                                            .font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                                        Text(city.displayName)
                                            .font(.system(size: 13)).foregroundColor(.white.opacity(0.6))
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12)).foregroundColor(.white.opacity(0.35))
                                }
                                .padding(.horizontal, 16).padding(.vertical, 13)
                                .background(Color.white.opacity(0.11))
                                .clipShape(RoundedRectangle(cornerRadius: 13))
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
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white.opacity(0.5))
                .textCase(.uppercase)
                .tracking(0.8)
                .padding(.horizontal, 20)
                .padding(.top, 22)

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
                        selectCity(GeocodingResult(id: 0, name: city.0, latitude: city.1,
                                                   longitude: city.2, country: "Россия", admin1: nil))
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "building.2.fill")
                                .foregroundColor(.white.opacity(0.55)).font(.system(size: 13))
                            Text(city.0)
                                .font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal, 13).padding(.vertical, 11)
                        .background(Color.white.opacity(0.13))
                        .clipShape(RoundedRectangle(cornerRadius: 13))
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func selectCity(_ city: GeocodingResult) {
        cityName = city.name; latitude = city.latitude; longitude = city.longitude
        searchQuery = ""; service.searchResults = []
        let defaults = UserDefaults(suiteName: "group.ru.hashier.SkyBuddies") ?? .standard
        defaults.set(city.name, forKey: "sb_widget_city")
        defaults.set(city.latitude, forKey: "sb_widget_lat")
        defaults.set(city.longitude, forKey: "sb_widget_lon")
        withAnimation { showSearch = false }
        Task { await service.fetchWeather(latitude: latitude, longitude: longitude, cityName: cityName) }
    }
}

// MARK: - Day View

struct DayView: View {
    let data: WeatherData

    private var todayHourly: [HourlyWeather] {
        let now = Date()
        let end = Calendar.current.date(byAdding: .hour, value: 25, to: now) ?? now
        return data.hourly.filter { $0.time >= now && $0.time <= end }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                // Hourly strip
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 9) {
                        ForEach(todayHourly) { h in HourlyCell(hour: h) }
                    }
                    .padding(.horizontal, 20)
                }

                if let today = data.daily.first {
                    TodayDetailCard(day: today)
                }
            }
            .padding(.bottom, 32)
        }
    }
}

struct HourlyCell: View {
    let hour: HourlyWeather

    var body: some View {
        VStack(spacing: 7) {
            Text(hourLabel)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.75))

            WeatherCharacterView(type: hour.weatherCode.characterType, size: 46)
                .frame(width: 46, height: 46)

            Text("\(Int(hour.temperature.rounded()))°")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)

            if hour.precipitation > 0.1 {
                Text(String(format: "%.1f", hour.precipitation) + "мм")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(hex: "7EC8FF"))
            } else {
                Text(" ").font(.system(size: 10))
            }
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .frame(width: 72)
    }

    var hourLabel: String {
        let f = DateFormatter(); f.dateFormat = "HH:mm"
        return f.string(from: hour.time)
    }
}

struct TodayDetailCard: View {
    let day: DailyWeather

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Сегодня")
                    .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                Spacer()
                Text("\(Int(day.minTemp.rounded()))° / \(Int(day.maxTemp.rounded()))°")
                    .font(.system(size: 16, weight: .semibold)).foregroundColor(.white.opacity(0.85))
            }
            .padding(.horizontal, 18).padding(.top, 16)

            Rectangle().fill(Color.white.opacity(0.18)).frame(height: 1).padding(.vertical, 12).padding(.horizontal, 18)

            VStack(spacing: 12) {
                if let sr = day.sunrise, let ss = day.sunset {
                    detailRow(icon: "sunrise.fill", label: "Восход", value: timeStr(sr), color: Color(hex: "FFB347"))
                    detailRow(icon: "sunset.fill",  label: "Закат",  value: timeStr(ss), color: Color(hex: "FF7070"))
                }
                detailRow(icon: "drop.fill", label: "Осадки",
                          value: String(format: "%.1f мм", day.precipitationSum), color: Color(hex: "7EC8FF"))
                detailRow(icon: "wind", label: "Ветер макс",
                          value: "\(Int(day.windSpeedMax)) м/с", color: .white.opacity(0.8))
            }
            .padding(.horizontal, 18).padding(.bottom, 16)
        }
        .background(.ultraThinMaterial.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 20)
    }

    func detailRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon).foregroundColor(color).frame(width: 26)
            Text(label).font(.system(size: 14)).foregroundColor(.white.opacity(0.72))
            Spacer()
            Text(value).font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
        }
    }

    func timeStr(_ d: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "HH:mm"; return f.string(from: d)
    }
}

// MARK: - Week View

struct WeekView: View {
    let data: WeatherData
    @State private var selectedDay: DailyWeather?
    private var days: [DailyWeather] { Array(data.daily.prefix(7)) }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 8) {
                ForEach(days) { day in
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        selectedDay = day
                    } label: {
                        WeekDayRow(day: day)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20).padding(.bottom, 32)
        }
        .sheet(item: $selectedDay) { day in
            DayDetailSheet(day: day)
        }
    }
}

struct WeekDayRow: View {
    let day: DailyWeather

    var body: some View {
        HStack(spacing: 12) {
            Text(dayLabel)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 96, alignment: .leading)

            WeatherCharacterView(type: day.weatherCode.characterType, size: 40)
                .frame(width: 40, height: 40)

            Text(day.weatherCode.russianDescription)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.72))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 3) {
                Text("\(Int(day.minTemp.rounded()))°")
                    .font(.system(size: 15)).foregroundColor(Color(hex: "7EC8FF"))
                Text("·").foregroundColor(.white.opacity(0.3))
                Text("\(Int(day.maxTemp.rounded()))°")
                    .font(.system(size: 15, weight: .bold)).foregroundColor(.white)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 11)).foregroundColor(.white.opacity(0.3))
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .background(.ultraThinMaterial.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    var dayLabel: String {
        let f = DateFormatter(); f.locale = Locale(identifier: "ru_RU"); f.dateFormat = "EEEE"
        let s = f.string(from: day.date)
        return s.prefix(1).uppercased() + s.dropFirst()
    }
}

// MARK: - Month View

struct MonthView: View {
    let data: WeatherData
    @State private var selectedDay: DailyWeather?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 5) {
                ForEach(data.daily) { day in
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        selectedDay = day
                    } label: {
                        MonthDayRow(day: day, allDays: data.daily)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20).padding(.bottom, 32)
        }
        .sheet(item: $selectedDay) { day in
            DayDetailSheet(day: day)
        }
    }
}

struct MonthDayRow: View {
    let day: DailyWeather
    let allDays: [DailyWeather]

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 1) {
                Text(dayName)
                    .font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                Text(dateStr)
                    .font(.system(size: 12, weight: .medium)).foregroundColor(.white.opacity(0.58))
            }
            .frame(width: 48, alignment: .leading)

            WeatherCharacterView(type: day.weatherCode.characterType, size: 34)
                .frame(width: 34, height: 34)

            GeometryReader { geo in
                tempBar(width: geo.size.width)
            }
            .frame(height: 8)

            Text("\(Int(day.minTemp.rounded()))°/\(Int(day.maxTemp.rounded()))°")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 70, alignment: .trailing)

            Image(systemName: "chevron.right")
                .font(.system(size: 10)).foregroundColor(.white.opacity(0.28))
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .background(.ultraThinMaterial.opacity(0.35))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    func tempBar(width: CGFloat) -> some View {
        let minT = allDays.map(\.minTemp).min() ?? -10
        let maxT = allDays.map(\.maxTemp).max() ?? 30
        let range = max(1, maxT - minT)
        let lo = (day.minTemp - minT) / range
        let hi = (day.maxTemp - minT) / range

        return ZStack(alignment: .leading) {
            Capsule().fill(Color.white.opacity(0.18)).frame(height: 8)
            Capsule()
                .fill(barColor)
                .frame(width: max(6, (hi - lo) * width), height: 8)
                .offset(x: lo * width)
        }
    }

    var barColor: Color {
        switch day.maxTemp {
        case ..<0:    return Color(hex: "99CCFF")
        case 0..<10:  return Color(hex: "AADDC4")
        case 10..<20: return Color(hex: "FFD93D")
        case 20..<30: return Color(hex: "FF9500")
        default:      return Color(hex: "FF3B30")
        }
    }

    var dayName: String {
        let f = DateFormatter(); f.locale = Locale(identifier: "ru_RU"); f.dateFormat = "EEE"
        let s = f.string(from: day.date)
        return s.prefix(1).uppercased() + s.dropFirst()
    }

    var dateStr: String {
        let f = DateFormatter(); f.locale = Locale(identifier: "ru_RU"); f.dateFormat = "d MMM"
        return f.string(from: day.date)
    }
}

// MARK: - Day Detail Sheet (popup)

struct DayDetailSheet: View {
    let day: DailyWeather
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            sheetGradient.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Handle
                    Capsule()
                        .fill(Color.white.opacity(0.35))
                        .frame(width: 40, height: 4)
                        .padding(.top, 14)
                        .padding(.bottom, 20)

                    // Day & date
                    VStack(spacing: 5) {
                        Text(fullDayName)
                            .font(.system(size: 24, weight: .bold)).foregroundColor(.white)
                        Text(fullDate)
                            .font(.system(size: 15, weight: .medium)).foregroundColor(.white.opacity(0.68))
                    }
                    .padding(.bottom, 18)

                    // Character
                    WeatherCharacterView(type: day.weatherCode.characterType, size: 130)
                        .padding(.bottom, 10)

                    Text(day.weatherCode.russianDescription)
                        .font(.system(size: 19, weight: .semibold)).foregroundColor(.white)
                        .padding(.bottom, 22)

                    // Min/Max card
                    HStack(spacing: 0) {
                        VStack(spacing: 5) {
                            Text("Минимум")
                                .font(.system(size: 12, weight: .medium)).foregroundColor(.white.opacity(0.62))
                            Text("\(Int(day.minTemp.rounded()))°")
                                .font(.system(size: 42, weight: .black, design: .rounded))
                                .foregroundColor(Color(hex: "7EC8FF"))
                        }
                        .frame(maxWidth: .infinity)

                        Rectangle().fill(Color.white.opacity(0.22)).frame(width: 1, height: 60)

                        VStack(spacing: 5) {
                            Text("Максимум")
                                .font(.system(size: 12, weight: .medium)).foregroundColor(.white.opacity(0.62))
                            Text("\(Int(day.maxTemp.rounded()))°")
                                .font(.system(size: 42, weight: .black, design: .rounded))
                                .foregroundColor(Color(hex: "FF9500"))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 18)
                    .background(.ultraThinMaterial.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)

                    // Details grid
                    VStack(spacing: 8) {
                        if let sr = day.sunrise, let ss = day.sunset {
                            HStack(spacing: 8) {
                                detailCard(icon: "sunrise.fill", label: "Восход",
                                           value: timeStr(sr), color: Color(hex: "FFB347"))
                                detailCard(icon: "sunset.fill", label: "Закат",
                                           value: timeStr(ss), color: Color(hex: "FF7070"))
                            }
                        }
                        HStack(spacing: 8) {
                            detailCard(icon: "drop.fill", label: "Осадки",
                                       value: String(format: "%.1f мм", day.precipitationSum),
                                       color: Color(hex: "7EC8FF"))
                            detailCard(icon: "wind", label: "Ветер макс",
                                       value: "\(Int(day.windSpeedMax)) м/с",
                                       color: .white.opacity(0.85))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationCornerRadius(28)
        .presentationDragIndicator(.hidden)
    }

    func detailCard(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color).font(.system(size: 20)).frame(width: 28)
            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.system(size: 12, weight: .medium)).foregroundColor(.white.opacity(0.62))
                Text(value)
                    .font(.system(size: 17, weight: .bold)).foregroundColor(.white)
            }
            Spacer()
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(.ultraThinMaterial.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .frame(maxWidth: .infinity)
    }

    var sheetGradient: some View {
        let colors: [Color]
        switch day.weatherCode.characterType {
        case .sunny, .hotSun: colors = [Color(hex: "1060A8"), Color(hex: "2A90D0")]
        case .partlyCloudy:   colors = [Color(hex: "2A5070"), Color(hex: "5080A0")]
        case .cloudy, .foggy: colors = [Color(hex: "384050"), Color(hex: "607080")]
        case .rainy, .heavyRain: colors = [Color(hex: "1E3C50"), Color(hex: "385870")]
        case .snowy:          colors = [Color(hex: "304860"), Color(hex: "6090A8")]
        case .stormy:         colors = [Color(hex: "0E1420"), Color(hex: "2A3040")]
        }
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var fullDayName: String {
        let f = DateFormatter(); f.locale = Locale(identifier: "ru_RU"); f.dateFormat = "EEEE"
        let s = f.string(from: day.date)
        return s.prefix(1).uppercased() + s.dropFirst()
    }

    var fullDate: String {
        let f = DateFormatter(); f.locale = Locale(identifier: "ru_RU"); f.dateFormat = "d MMMM"
        return f.string(from: day.date)
    }

    func timeStr(_ d: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "HH:mm"; return f.string(from: d)
    }
}

#Preview { ContentView() }
