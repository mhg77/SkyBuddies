import SwiftUI

// MARK: - Main Character View

struct WeatherCharacterView: View {
    let type: WeatherCharacterType
    let size: CGFloat

    @State private var bounce = false
    @State private var wiggle = false
    @State private var pulse = false

    var body: some View {
        Group {
            switch type {
            case .sunny: SunCharacter(size: size)
            case .partlyCloudy: PartlyCloudyCharacter(size: size)
            case .cloudy: CloudCharacter(size: size, color: Color(white: 0.82))
            case .foggy: FoggyCharacter(size: size)
            case .rainy: RainyCharacter(size: size)
            case .heavyRain: HeavyRainCharacter(size: size)
            case .snowy: SnowyCharacter(size: size)
            case .stormy: StormyCharacter(size: size)
            }
        }
        .scaleEffect(bounce ? 1.06 : 1.0)
        .rotationEffect(.degrees(wiggle ? 3 : -3))
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                bounce = true
            }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(0.3)) {
                wiggle = true
            }
        }
    }
}

// MARK: - Sun Character

struct SunCharacter: View {
    let size: CGFloat
    @State private var rotate = false

    var body: some View {
        ZStack {
            // Rays
            ForEach(0..<8) { i in
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(hex: "FFD60A"))
                    .frame(width: size * 0.09, height: size * 0.22)
                    .offset(y: -size * 0.48)
                    .rotationEffect(.degrees(Double(i) * 45))
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color(hex: "E6A000"), lineWidth: 2)
                            .frame(width: size * 0.09, height: size * 0.22)
                            .offset(y: -size * 0.48)
                            .rotationEffect(.degrees(Double(i) * 45))
                    )
            }
            .rotationEffect(.degrees(rotate ? 22.5 : 0))

            // Sun body
            Circle()
                .fill(Color(hex: "FFD60A"))
                .frame(width: size * 0.68, height: size * 0.68)
                .overlay(Circle().stroke(Color(hex: "E6A000"), lineWidth: 4))

            // Eyes
            HStack(spacing: size * 0.14) {
                EyeShape(size: size * 0.14)
                EyeShape(size: size * 0.14)
            }
            .offset(y: -size * 0.06)

            // Smile
            SmileShape(size: size * 0.28)
                .offset(y: size * 0.1)

            // Cheeks
            HStack(spacing: size * 0.32) {
                Circle()
                    .fill(Color(hex: "FF7B7B").opacity(0.5))
                    .frame(width: size * 0.12, height: size * 0.08)
                Circle()
                    .fill(Color(hex: "FF7B7B").opacity(0.5))
                    .frame(width: size * 0.12, height: size * 0.08)
            }
            .offset(y: size * 0.08)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                rotate = true
            }
        }
    }
}

// MARK: - Partly Cloudy

struct PartlyCloudyCharacter: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            // Sun behind cloud
            Group {
                // Sun rays (partial)
                ForEach([0, 1, 2, 7], id: \.self) { i in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(hex: "FFD60A"))
                        .frame(width: size * 0.08, height: size * 0.18)
                        .offset(y: -size * 0.38)
                        .rotationEffect(.degrees(Double(i) * 45))
                        .overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(Color(hex: "E6A000"), lineWidth: 2)
                                .frame(width: size * 0.08, height: size * 0.18)
                                .offset(y: -size * 0.38)
                                .rotationEffect(.degrees(Double(i) * 45))
                        )
                }
                Circle()
                    .fill(Color(hex: "FFD60A"))
                    .frame(width: size * 0.48, height: size * 0.48)
                    .overlay(Circle().stroke(Color(hex: "E6A000"), lineWidth: 3))
            }
            .offset(x: size * 0.12, y: -size * 0.12)

            // Cloud in front
            CloudShape()
                .fill(Color.white)
                .frame(width: size * 0.78, height: size * 0.5)
                .overlay(CloudShape().stroke(Color(hex: "CCCCCC"), lineWidth: 3.5))
                .offset(x: -size * 0.05, y: size * 0.1)

            // Cloud face
            HStack(spacing: size * 0.14) {
                EyeShape(size: size * 0.12)
                EyeShape(size: size * 0.12)
            }
            .offset(x: -size * 0.05, y: size * 0.1)

            SmileShape(size: size * 0.2)
                .offset(x: -size * 0.05, y: size * 0.22)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Cloud Character

struct CloudCharacter: View {
    let size: CGFloat
    let color: Color

    var body: some View {
        ZStack {
            CloudShape()
                .fill(color)
                .frame(width: size * 0.85, height: size * 0.58)
                .overlay(CloudShape().stroke(Color(hex: "AAAAAA"), lineWidth: 4))

            HStack(spacing: size * 0.16) {
                EyeShape(size: size * 0.14)
                EyeShape(size: size * 0.14)
            }
            .offset(y: -size * 0.04)

            SmileShape(size: size * 0.22)
                .offset(y: size * 0.1)

            HStack(spacing: size * 0.36) {
                Circle()
                    .fill(Color(hex: "FF9999").opacity(0.45))
                    .frame(width: size * 0.1, height: size * 0.07)
                Circle()
                    .fill(Color(hex: "FF9999").opacity(0.45))
                    .frame(width: size * 0.1, height: size * 0.07)
            }
            .offset(y: size * 0.07)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Rainy Character

struct RainyCharacter: View {
    let size: CGFloat
    @State private var dropOffset: CGFloat = 0
    @State private var dropOpacity: Double = 1

    var body: some View {
        ZStack {
            // Dark cloud
            CloudShape()
                .fill(Color(hex: "8CA3B8"))
                .frame(width: size * 0.82, height: size * 0.52)
                .overlay(CloudShape().stroke(Color(hex: "5A7A95"), lineWidth: 4))
                .offset(y: -size * 0.12)

            // Sad face
            HStack(spacing: size * 0.15) {
                EyeShape(size: size * 0.13, sad: true)
                EyeShape(size: size * 0.13, sad: true)
            }
            .offset(y: -size * 0.16)

            SadMouthShape(size: size * 0.2)
                .offset(y: -size * 0.03)

            // Rain drops
            HStack(spacing: size * 0.13) {
                ForEach(0..<4) { i in
                    RainDrop(size: size * 0.07)
                        .offset(y: dropOffset + CGFloat(i % 2 == 0 ? 0 : size * 0.08))
                        .opacity(dropOpacity)
                }
            }
            .offset(y: size * 0.26)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeIn(duration: 0.9).repeatForever(autoreverses: false)) {
                dropOffset = size * 0.18
                dropOpacity = 0
            }
        }
    }
}

// MARK: - Heavy Rain

struct HeavyRainCharacter: View {
    let size: CGFloat
    @State private var dropOffset: CGFloat = 0
    @State private var dropOpacity: Double = 1

    var body: some View {
        ZStack {
            CloudShape()
                .fill(Color(hex: "5A6A7A"))
                .frame(width: size * 0.84, height: size * 0.54)
                .overlay(CloudShape().stroke(Color(hex: "3A4A5A"), lineWidth: 4.5))
                .offset(y: -size * 0.14)

            HStack(spacing: size * 0.14) {
                EyeShape(size: size * 0.13, angry: true)
                EyeShape(size: size * 0.13, angry: true)
            }
            .offset(y: -size * 0.18)

            // Angry brows
            HStack(spacing: size * 0.16) {
                AngryBrow(size: size * 0.14, flipped: false)
                AngryBrow(size: size * 0.14, flipped: true)
            }
            .offset(y: -size * 0.26)

            SadMouthShape(size: size * 0.18)
                .offset(y: -size * 0.05)

            HStack(spacing: size * 0.09) {
                ForEach(0..<5) { i in
                    RainDrop(size: size * 0.065)
                        .offset(y: dropOffset + CGFloat(i % 3 == 0 ? 0 : i % 3 == 1 ? size * 0.07 : size * 0.04))
                        .opacity(dropOpacity)
                }
            }
            .offset(y: size * 0.28)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeIn(duration: 0.6).repeatForever(autoreverses: false)) {
                dropOffset = size * 0.2
                dropOpacity = 0
            }
        }
    }
}

// MARK: - Snowy Character

struct SnowyCharacter: View {
    let size: CGFloat
    @State private var flakeOffset: CGFloat = 0
    @State private var flakeOpacity: Double = 1

    var body: some View {
        ZStack {
            CloudShape()
                .fill(Color(hex: "C8D8E8"))
                .frame(width: size * 0.82, height: size * 0.52)
                .overlay(CloudShape().stroke(Color(hex: "A0B8CC"), lineWidth: 4))
                .offset(y: -size * 0.12)

            HStack(spacing: size * 0.15) {
                EyeShape(size: size * 0.13)
                EyeShape(size: size * 0.13)
            }
            .offset(y: -size * 0.16)

            SmileShape(size: size * 0.2)
                .offset(y: -size * 0.03)

            // Snowflakes
            HStack(spacing: size * 0.14) {
                ForEach(0..<4) { i in
                    Text("❄️")
                        .font(.system(size: size * 0.14))
                        .offset(y: flakeOffset + CGFloat(i % 2 == 0 ? 0 : size * 0.07))
                        .opacity(flakeOpacity)
                }
            }
            .offset(y: size * 0.24)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeIn(duration: 1.2).repeatForever(autoreverses: false)) {
                flakeOffset = size * 0.2
                flakeOpacity = 0
            }
        }
    }
}

// MARK: - Foggy Character

struct FoggyCharacter: View {
    let size: CGFloat
    @State private var fogOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // Fog lines
            VStack(spacing: size * 0.1) {
                ForEach(0..<3) { i in
                    FogLine(size: size * (i == 1 ? 0.9 : 0.7))
                        .offset(x: fogOffset * (i % 2 == 0 ? 1 : -1))
                }
            }
            .offset(y: size * 0.08)

            // Ghost face on fog
            Circle()
                .fill(Color.white.opacity(0.0001))
                .frame(width: size * 0.4, height: size * 0.4)

            HStack(spacing: size * 0.14) {
                EyeShape(size: size * 0.12)
                EyeShape(size: size * 0.12)
            }
            .offset(y: -size * 0.04)

            SmileShape(size: size * 0.18)
                .offset(y: size * 0.09)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                fogOffset = size * 0.06
            }
        }
    }
}

// MARK: - Stormy Character

struct StormyCharacter: View {
    let size: CGFloat
    @State private var boltOpacity: Double = 1
    @State private var dropOffset: CGFloat = 0

    var body: some View {
        ZStack {
            CloudShape()
                .fill(Color(hex: "3D3D50"))
                .frame(width: size * 0.85, height: size * 0.55)
                .overlay(CloudShape().stroke(Color(hex: "2A2A38"), lineWidth: 4.5))
                .offset(y: -size * 0.14)

            HStack(spacing: size * 0.14) {
                EyeShape(size: size * 0.13, angry: true)
                EyeShape(size: size * 0.13, angry: true)
            }
            .offset(y: -size * 0.18)

            HStack(spacing: size * 0.16) {
                AngryBrow(size: size * 0.14, flipped: false)
                AngryBrow(size: size * 0.14, flipped: true)
            }
            .offset(y: -size * 0.28)

            // Lightning bolt
            LightningBolt(size: size * 0.3)
                .fill(Color(hex: "FFE600"))
                .overlay(LightningBolt(size: size * 0.3).stroke(Color(hex: "E6A000"), lineWidth: 2.5))
                .opacity(boltOpacity)
                .offset(y: size * 0.16)

            // Rain drops
            HStack(spacing: size * 0.16) {
                ForEach(0..<3) { i in
                    RainDrop(size: size * 0.065)
                        .offset(x: CGFloat(i == 1 ? size * 0.1 : 0),
                                y: dropOffset + CGFloat(i % 2 == 0 ? 0 : size * 0.07))
                        .opacity(1 - dropOffset / (size * 0.2))
                }
            }
            .offset(y: size * 0.2)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.35).repeatForever(autoreverses: true)) {
                boltOpacity = 0.4
            }
            withAnimation(.easeIn(duration: 0.7).repeatForever(autoreverses: false)) {
                dropOffset = size * 0.18
            }
        }
    }
}

// MARK: - Reusable Shapes & Components

struct EyeShape: View {
    let size: CGFloat
    var sad: Bool = false
    var angry: Bool = false

    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color.white)
                .frame(width: size, height: size * 1.25)
                .overlay(Ellipse().stroke(Color.black, lineWidth: max(1.5, size * 0.12)))

            Circle()
                .fill(Color(hex: "1A1A2E"))
                .frame(width: size * 0.55, height: size * 0.55)
                .offset(y: angry ? size * 0.1 : 0)

            Circle()
                .fill(Color.white)
                .frame(width: size * 0.2, height: size * 0.2)
                .offset(x: size * 0.12, y: -size * 0.1)
        }
    }
}

struct SmileShape: View {
    let size: CGFloat

    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addQuadCurve(
                to: CGPoint(x: size, y: 0),
                control: CGPoint(x: size / 2, y: size * 0.55)
            )
        }
        .stroke(Color(hex: "1A1A2E"), style: StrokeStyle(lineWidth: max(2, size * 0.1), lineCap: .round))
        .frame(width: size, height: size * 0.55)
        .offset(x: -size / 2)
    }
}

struct SadMouthShape: View {
    let size: CGFloat

    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: size * 0.4))
            path.addQuadCurve(
                to: CGPoint(x: size, y: size * 0.4),
                control: CGPoint(x: size / 2, y: -size * 0.1)
            )
        }
        .stroke(Color(hex: "1A1A2E"), style: StrokeStyle(lineWidth: max(2, size * 0.1), lineCap: .round))
        .frame(width: size, height: size * 0.5)
        .offset(x: -size / 2)
    }
}

struct AngryBrow: View {
    let size: CGFloat
    let flipped: Bool

    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: flipped ? 0 : size * 0.35))
            path.addLine(to: CGPoint(x: size, y: flipped ? size * 0.35 : 0))
        }
        .stroke(Color(hex: "1A1A2E"), style: StrokeStyle(lineWidth: max(2, size * 0.18), lineCap: .round))
        .frame(width: size, height: size * 0.35)
    }
}

struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()

        path.move(to: CGPoint(x: w * 0.2, y: h))
        path.addLine(to: CGPoint(x: w * 0.8, y: h))
        path.addArc(center: CGPoint(x: w * 0.78, y: h * 0.65),
                    radius: h * 0.35, startAngle: .degrees(90), endAngle: .degrees(0), clockwise: true)
        path.addArc(center: CGPoint(x: w * 0.65, y: h * 0.38),
                    radius: h * 0.38, startAngle: .degrees(20), endAngle: .degrees(150), clockwise: true)
        path.addArc(center: CGPoint(x: w * 0.38, y: h * 0.28),
                    radius: h * 0.32, startAngle: .degrees(10), endAngle: .degrees(160), clockwise: true)
        path.addArc(center: CGPoint(x: w * 0.2, y: h * 0.58),
                    radius: h * 0.42, startAngle: .degrees(260), endAngle: .degrees(90), clockwise: true)
        path.closeSubpath()
        return path
    }
}

struct RainDrop: View {
    let size: CGFloat

    var body: some View {
        Capsule()
            .fill(Color(hex: "4A90D9"))
            .frame(width: size * 0.45, height: size)
            .overlay(Capsule().stroke(Color(hex: "2A6AA9"), lineWidth: 1.5))
    }
}

struct FogLine: View {
    let size: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color(white: 0.78).opacity(0.9))
            .frame(width: size, height: 10)
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(white: 0.6), lineWidth: 1.5))
    }
}

struct LightningBolt: Shape {
    let size: CGFloat

    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: w * 0.62, y: 0))
        path.addLine(to: CGPoint(x: w * 0.3, y: h * 0.48))
        path.addLine(to: CGPoint(x: w * 0.58, y: h * 0.48))
        path.addLine(to: CGPoint(x: w * 0.28, y: h))
        path.addLine(to: CGPoint(x: w * 0.72, y: h * 0.52))
        path.addLine(to: CGPoint(x: w * 0.46, y: h * 0.52))
        path.closeSubpath()
        return path
    }
}

// MARK: - Small icon for lists

struct WeatherIcon: View {
    let type: WeatherCharacterType
    let size: CGFloat

    var body: some View {
        WeatherCharacterView(type: type, size: size)
            .frame(width: size, height: size)
    }
}

// MARK: - Hex color helper

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
