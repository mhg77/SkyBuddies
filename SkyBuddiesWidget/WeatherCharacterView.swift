import SwiftUI

// MARK: - Main Character View

struct WeatherCharacterView: View {
    let type: WeatherCharacterType
    let size: CGFloat

    @State private var bounce = false
    @State private var wiggle = false

    var body: some View {
        Group {
            switch type {
            case .sunny:        SunCharacter(size: size)
            case .hotSun:       HotSunCharacter(size: size)
            case .partlyCloudy: PartlyCloudyCharacter(size: size)
            case .cloudy:       CloudCharacter(size: size, color: Color(white: 0.82))
            case .foggy:        FoggyCharacter(size: size)
            case .rainy:        RainyCharacter(size: size)
            case .heavyRain:    HeavyRainCharacter(size: size)
            case .snowy:        SnowyCharacter(size: size)
            case .stormy:       StormyCharacter(size: size)
            }
        }
        .scaleEffect(bounce ? 1.05 : 1.0)
        .rotationEffect(.degrees(wiggle ? 2.5 : -2.5))
        .onAppear {
            withAnimation(.easeInOut(duration: 1.9).repeatForever(autoreverses: true)) { bounce = true }
            withAnimation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true).delay(0.4)) { wiggle = true }
        }
    }
}

// MARK: - ☀️ Normal Sun

struct SunCharacter: View {
    let size: CGFloat
    @State private var rotate = false

    var body: some View {
        ZStack {
            ForEach(0..<8) { i in
                sunRay(index: i, count: 8, color: Color(hex: "FFD60A"), border: Color(hex: "E6A000"),
                       width: size * 0.09, height: size * 0.22, dist: size * 0.48)
            }
            .rotationEffect(.degrees(rotate ? 22.5 : 0))

            Circle()
                .fill(Color(hex: "FFD60A"))
                .frame(width: size * 0.68, height: size * 0.68)
                .overlay(Circle().stroke(Color(hex: "E6A000"), lineWidth: 4))

            BigSmileShape(size: size * 0.3)
                .offset(y: size * 0.1)

            HStack(spacing: size * 0.13) {
                EyeShape(size: size * 0.14)
                EyeShape(size: size * 0.14)
            }
            .offset(y: -size * 0.06)

            HStack(spacing: size * 0.3) {
                Ellipse().fill(Color(hex: "FF7B7B").opacity(0.55)).frame(width: size * 0.13, height: size * 0.08)
                Ellipse().fill(Color(hex: "FF7B7B").opacity(0.55)).frame(width: size * 0.13, height: size * 0.08)
            }
            .offset(y: size * 0.09)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) { rotate = true }
        }
    }
}

// MARK: - 🔥 Hot Sun (screaming, sunglasses)

struct HotSunCharacter: View {
    let size: CGFloat
    @State private var rotate = false
    @State private var sweat1Y: CGFloat = 0
    @State private var sweat2Y: CGFloat = 0
    @State private var sweatOpacity: Double = 1
    @State private var shake: CGFloat = 0

    var body: some View {
        ZStack {
            ForEach(0..<12) { i in
                sunRay(index: i, count: 12, color: Color(hex: "FF7700"), border: Color(hex: "CC4400"),
                       width: size * 0.07, height: size * 0.2, dist: size * 0.46)
            }
            .rotationEffect(.degrees(rotate ? 15 : 0))

            Circle()
                .fill(RadialGradient(
                    colors: [Color(hex: "FFE040"), Color(hex: "FF7000")],
                    center: .center, startRadius: 0, endRadius: size * 0.34
                ))
                .frame(width: size * 0.68, height: size * 0.68)
                .overlay(Circle().stroke(Color(hex: "CC4400"), lineWidth: 4.5))

            HStack(spacing: size * 0.28) {
                Ellipse().fill(Color(hex: "FF2020").opacity(0.65)).frame(width: size * 0.15, height: size * 0.1)
                Ellipse().fill(Color(hex: "FF2020").opacity(0.65)).frame(width: size * 0.15, height: size * 0.1)
            }
            .offset(y: size * 0.06)

            SunglassesView(size: size)
                .offset(y: -size * 0.05)

            ScreamMouthView(size: size)
                .offset(y: size * 0.16)

            TearDropShape()
                .fill(Color(hex: "7EC8FF"))
                .frame(width: size * 0.07, height: size * 0.12)
                .offset(x: -size * 0.38, y: sweat1Y)
                .opacity(sweatOpacity)

            TearDropShape()
                .fill(Color(hex: "7EC8FF"))
                .frame(width: size * 0.07, height: size * 0.12)
                .offset(x: size * 0.38, y: sweat2Y)
                .opacity(sweatOpacity * 0.75)
        }
        .offset(x: shake)
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) { rotate = true }
            withAnimation(.easeIn(duration: 1.1).repeatForever(autoreverses: false)) {
                sweat1Y = size * 0.3; sweatOpacity = 0
            }
            withAnimation(.easeIn(duration: 1.1).repeatForever(autoreverses: false).delay(0.55)) {
                sweat2Y = size * 0.3
            }
            withAnimation(.easeInOut(duration: 0.12).repeatForever(autoreverses: true)) { shake = 1.8 }
        }
    }
}

// MARK: - ⛅ Partly Cloudy

struct PartlyCloudyCharacter: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Group {
                ForEach([0, 1, 7], id: \.self) { i in
                    sunRay(index: i, count: 8, color: Color(hex: "FFD60A"), border: Color(hex: "E6A000"),
                           width: size * 0.08, height: size * 0.16, dist: size * 0.36)
                }
                Circle()
                    .fill(Color(hex: "FFD60A"))
                    .frame(width: size * 0.46, height: size * 0.46)
                    .overlay(Circle().stroke(Color(hex: "E6A000"), lineWidth: 3))
            }
            .offset(x: size * 0.14, y: -size * 0.14)

            CloudShape()
                .fill(Color.white)
                .frame(width: size * 0.78, height: size * 0.5)
                .overlay(CloudShape().stroke(Color(hex: "CCCCCC"), lineWidth: 3.5))
                .offset(x: -size * 0.04, y: size * 0.1)

            HStack(spacing: size * 0.16) {
                EyeShape(size: size * 0.12)
                WinkEye(size: size * 0.12)
            }
            .offset(x: -size * 0.04, y: size * 0.1)

            SmugSmileShape(size: size * 0.2)
                .offset(x: -size * 0.04, y: size * 0.22)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - ☁️ Cloud

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

            SmileShape(size: size * 0.2)
                .offset(y: size * 0.1)

            RaisedBrow(size: size * 0.14)
                .offset(x: -size * 0.18, y: -size * 0.12)

            HStack(spacing: size * 0.34) {
                Ellipse().fill(Color(hex: "FF9999").opacity(0.4)).frame(width: size * 0.1, height: size * 0.07)
                Ellipse().fill(Color(hex: "FF9999").opacity(0.4)).frame(width: size * 0.1, height: size * 0.07)
            }
            .offset(y: size * 0.07)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - 🌧️ Rainy

struct RainyCharacter: View {
    let size: CGFloat
    @State private var dropY: CGFloat = 0
    @State private var dropOpacity: Double = 1
    @State private var tearY: CGFloat = 0

    var body: some View {
        ZStack {
            CloudShape()
                .fill(Color(hex: "8CA3B8"))
                .frame(width: size * 0.82, height: size * 0.52)
                .overlay(CloudShape().stroke(Color(hex: "5A7A95"), lineWidth: 4))
                .offset(y: -size * 0.12)

            HStack(spacing: size * 0.15) {
                ZStack {
                    EyeShape(size: size * 0.13, sad: true)
                    TearDropShape()
                        .fill(Color(hex: "7EC8FF"))
                        .frame(width: size * 0.06, height: size * 0.1)
                        .offset(y: size * 0.12 + tearY)
                        .opacity(1 - tearY / (size * 0.1))
                }
                ZStack {
                    EyeShape(size: size * 0.13, sad: true)
                    TearDropShape()
                        .fill(Color(hex: "7EC8FF"))
                        .frame(width: size * 0.06, height: size * 0.1)
                        .offset(y: size * 0.12 + tearY + size * 0.04)
                        .opacity(1 - max(0, (tearY - size * 0.02)) / (size * 0.08))
                }
            }
            .offset(y: -size * 0.16)

            BigSadMouthShape(size: size * 0.24)
                .offset(y: -size * 0.01)

            HStack(spacing: size * 0.12) {
                ForEach(0..<4) { i in
                    RainDrop(size: size * 0.07)
                        .offset(y: dropY + CGFloat(i % 2 == 0 ? 0 : size * 0.07))
                        .opacity(dropOpacity)
                }
            }
            .offset(y: size * 0.26)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeIn(duration: 0.9).repeatForever(autoreverses: false)) {
                dropY = size * 0.18; dropOpacity = 0
            }
            withAnimation(.easeIn(duration: 1.4).repeatForever(autoreverses: false)) {
                tearY = size * 0.1
            }
        }
    }
}

// MARK: - ⛈️ Heavy Rain

struct HeavyRainCharacter: View {
    let size: CGFloat
    @State private var dropY: CGFloat = 0
    @State private var dropOpacity: Double = 1

    var body: some View {
        ZStack {
            CloudShape()
                .fill(Color(hex: "5A6A7A"))
                .frame(width: size * 0.84, height: size * 0.54)
                .overlay(CloudShape().stroke(Color(hex: "3A4A5A"), lineWidth: 4.5))
                .offset(y: -size * 0.14)

            HStack(spacing: size * 0.14) {
                AngryBrow(size: size * 0.15, flipped: false)
                AngryBrow(size: size * 0.15, flipped: true)
            }
            .offset(y: -size * 0.28)

            HStack(spacing: size * 0.14) {
                EyeShape(size: size * 0.13, angry: true)
                EyeShape(size: size * 0.13, angry: true)
            }
            .offset(y: -size * 0.18)

            BigSadMouthShape(size: size * 0.22)
                .offset(y: -size * 0.04)

            HStack(spacing: size * 0.08) {
                ForEach(0..<5) { i in
                    RainDrop(size: size * 0.07)
                        .rotationEffect(.degrees(-15))
                        .offset(y: dropY + CGFloat(i % 3 == 0 ? 0 : i % 3 == 1 ? size * 0.06 : size * 0.03))
                        .opacity(dropOpacity)
                }
            }
            .offset(y: size * 0.28)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeIn(duration: 0.55).repeatForever(autoreverses: false)) {
                dropY = size * 0.2; dropOpacity = 0
            }
        }
    }
}

// MARK: - ❄️ Snowy

struct SnowyCharacter: View {
    let size: CGFloat
    @State private var flakeY: CGFloat = 0
    @State private var flakeOpacity: Double = 1
    @State private var shiver: CGFloat = 0

    var body: some View {
        ZStack {
            CloudShape()
                .fill(Color(hex: "C8D8E8"))
                .frame(width: size * 0.82, height: size * 0.52)
                .overlay(CloudShape().stroke(Color(hex: "A0B8CC"), lineWidth: 4))
                .offset(y: -size * 0.12)

            HStack(spacing: size * 0.15) {
                SquintEye(size: size * 0.13)
                SquintEye(size: size * 0.13)
            }
            .offset(y: -size * 0.16)

            ChatterMouthShape(size: size * 0.2)
                .offset(y: -size * 0.02)

            HStack(spacing: size * 0.3) {
                Ellipse().fill(Color(hex: "99BBFF").opacity(0.45)).frame(width: size * 0.11, height: size * 0.07)
                Ellipse().fill(Color(hex: "99BBFF").opacity(0.45)).frame(width: size * 0.11, height: size * 0.07)
            }
            .offset(y: size * 0.05)

            HStack(spacing: size * 0.14) {
                ForEach(0..<4) { i in
                    Text("❄️")
                        .font(.system(size: size * 0.13))
                        .offset(y: flakeY + CGFloat(i % 2 == 0 ? 0 : size * 0.07))
                        .opacity(flakeOpacity)
                }
            }
            .offset(y: size * 0.24)
        }
        .offset(x: shiver)
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeIn(duration: 1.3).repeatForever(autoreverses: false)) {
                flakeY = size * 0.22; flakeOpacity = 0
            }
            withAnimation(.easeInOut(duration: 0.1).repeatForever(autoreverses: true)) {
                shiver = 1.5
            }
        }
    }
}

// MARK: - 🌫️ Foggy

struct FoggyCharacter: View {
    let size: CGFloat
    @State private var fogX: CGFloat = 0

    var body: some View {
        ZStack {
            VStack(spacing: size * 0.1) {
                ForEach(0..<3) { i in
                    FogLine(size: size * (i == 1 ? 0.88 : 0.68))
                        .offset(x: fogX * (i % 2 == 0 ? 1 : -1))
                        .opacity(i == 0 ? 0.7 : i == 1 ? 0.9 : 0.6)
                }
            }
            .offset(y: size * 0.06)

            HStack(spacing: size * 0.16) {
                ZStack {
                    EyeShape(size: size * 0.12)
                    RaisedBrow(size: size * 0.12)
                        .offset(y: -size * 0.1)
                }
                ZStack {
                    EyeShape(size: size * 0.12)
                    AngryBrow(size: size * 0.12, flipped: false)
                        .offset(x: -size * 0.01, y: -size * 0.1)
                }
            }
            .offset(y: -size * 0.04)

            WavyMouthShape(size: size * 0.18)
                .offset(y: size * 0.1)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) { fogX = size * 0.07 }
        }
    }
}

// MARK: - ⚡ Stormy

struct StormyCharacter: View {
    let size: CGFloat
    @State private var boltScale: CGFloat = 1
    @State private var boltOpacity: Double = 1
    @State private var dropY: CGFloat = 0
    @State private var dropOpacity: Double = 1
    @State private var glowRadius: CGFloat = 0

    var body: some View {
        ZStack {
            CloudShape()
                .fill(Color(hex: "2E3240"))
                .frame(width: size * 0.85, height: size * 0.55)
                .overlay(CloudShape().stroke(Color(hex: "1A1A28"), lineWidth: 5))
                .shadow(color: Color(hex: "8040FF").opacity(0.3 + glowRadius * 0.01), radius: glowRadius)
                .offset(y: -size * 0.14)

            HStack(spacing: size * 0.12) {
                AngryBrow(size: size * 0.17, flipped: false)
                AngryBrow(size: size * 0.17, flipped: true)
            }
            .offset(y: -size * 0.3)

            HStack(spacing: size * 0.13) {
                EyeShape(size: size * 0.14, angry: true)
                EyeShape(size: size * 0.14, angry: true)
            }
            .offset(y: -size * 0.19)

            BigSadMouthShape(size: size * 0.2)
                .offset(y: -size * 0.04)

            LightningBolt()
                .fill(Color(hex: "FFE600"))
                .frame(width: size * 0.2, height: size * 0.32)
                .overlay(
                    LightningBolt()
                        .stroke(Color(hex: "FF9900"), lineWidth: 2.5)
                        .frame(width: size * 0.2, height: size * 0.32)
                )
                .shadow(color: Color(hex: "FFE600").opacity(0.8), radius: glowRadius * 0.5)
                .scaleEffect(boltScale)
                .opacity(boltOpacity)
                .offset(y: size * 0.16)

            HStack(spacing: size * 0.15) {
                ForEach(0..<3) { i in
                    RainDrop(size: size * 0.065)
                        .rotationEffect(.degrees(-10))
                        .offset(y: dropY + CGFloat(i % 2 == 0 ? 0 : size * 0.06))
                        .opacity(dropOpacity)
                }
            }
            .offset(y: size * 0.22)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
                boltOpacity = 0.25; boltScale = 1.1
            }
            withAnimation(.easeIn(duration: 0.65).repeatForever(autoreverses: false)) {
                dropY = size * 0.18; dropOpacity = 0
            }
            withAnimation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
                glowRadius = 8
            }
        }
    }
}

// MARK: - Supporting Shapes & Components

@ViewBuilder
func sunRay(index: Int, count: Int, color: Color, border: Color,
            width: CGFloat, height: CGFloat, dist: CGFloat) -> some View {
    RoundedRectangle(cornerRadius: 3)
        .fill(color)
        .frame(width: width, height: height)
        .offset(y: -dist)
        .rotationEffect(.degrees(Double(index) * (360.0 / Double(count))))
        .overlay(
            RoundedRectangle(cornerRadius: 3)
                .stroke(border, lineWidth: 1.8)
                .frame(width: width, height: height)
                .offset(y: -dist)
                .rotationEffect(.degrees(Double(index) * (360.0 / Double(count))))
        )
}

// MARK: Eyes

struct EyeShape: View {
    let size: CGFloat
    var sad: Bool = false
    var angry: Bool = false

    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color.white)
                .frame(width: size, height: size * 1.3)
                .overlay(Ellipse().stroke(Color.black, lineWidth: max(1.5, size * 0.12)))

            Circle()
                .fill(Color(hex: "1A1A2E"))
                .frame(width: size * 0.55, height: size * 0.55)
                .offset(y: angry ? size * 0.12 : 0)

            Circle()
                .fill(Color.white)
                .frame(width: size * 0.2, height: size * 0.2)
                .offset(x: size * 0.12, y: -size * 0.1)
        }
    }
}

struct WinkEye: View {
    let size: CGFloat

    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: size * 0.5))
            path.addQuadCurve(
                to: CGPoint(x: size, y: size * 0.5),
                control: CGPoint(x: size * 0.5, y: -size * 0.1)
            )
        }
        .stroke(Color(hex: "1A1A2E"), style: StrokeStyle(lineWidth: max(2, size * 0.15), lineCap: .round))
        .frame(width: size, height: size)
    }
}

struct SquintEye: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color.white)
                .frame(width: size, height: size * 0.6)
                .overlay(Ellipse().stroke(Color.black, lineWidth: max(1.5, size * 0.1)))
            Circle()
                .fill(Color(hex: "1A1A2E"))
                .frame(width: size * 0.38, height: size * 0.38)
        }
    }
}

// MARK: Mouths

struct SmileShape: View {
    let size: CGFloat
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addQuadCurve(to: CGPoint(x: size, y: 0), control: CGPoint(x: size / 2, y: size * 0.5))
        }
        .stroke(Color(hex: "1A1A2E"), style: StrokeStyle(lineWidth: max(2, size * 0.1), lineCap: .round))
        .frame(width: size, height: size * 0.5)
        .offset(x: -size / 2)
    }
}

struct BigSmileShape: View {
    let size: CGFloat
    var body: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addQuadCurve(to: CGPoint(x: size, y: 0), control: CGPoint(x: size / 2, y: size * 0.65))
            }
            .stroke(Color(hex: "1A1A2E"), style: StrokeStyle(lineWidth: max(2.5, size * 0.11), lineCap: .round))
            .frame(width: size, height: size * 0.65)

            RoundedRectangle(cornerRadius: 3)
                .fill(Color.white)
                .frame(width: size * 0.55, height: size * 0.1)
                .offset(y: size * 0.22)
                .mask(
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addQuadCurve(to: CGPoint(x: size, y: 0), control: CGPoint(x: size / 2, y: size * 0.65))
                        path.addLine(to: CGPoint(x: size, y: size * 0.65))
                        path.addLine(to: CGPoint(x: 0, y: size * 0.65))
                        path.closeSubpath()
                    }
                    .frame(width: size, height: size * 0.65)
                    .offset(x: -size / 2)
                )
        }
        .offset(x: -size / 2)
        .frame(width: size, height: size * 0.65)
    }
}

struct SmugSmileShape: View {
    let size: CGFloat
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: size * 0.2))
            path.addQuadCurve(to: CGPoint(x: size, y: 0), control: CGPoint(x: size * 0.6, y: size * 0.55))
        }
        .stroke(Color(hex: "1A1A2E"), style: StrokeStyle(lineWidth: max(2, size * 0.1), lineCap: .round))
        .frame(width: size, height: size * 0.55)
        .offset(x: -size / 2)
    }
}

struct BigSadMouthShape: View {
    let size: CGFloat
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: size * 0.45))
            path.addQuadCurve(to: CGPoint(x: size, y: size * 0.45), control: CGPoint(x: size / 2, y: -size * 0.15))
        }
        .stroke(Color(hex: "1A1A2E"), style: StrokeStyle(lineWidth: max(2.5, size * 0.11), lineCap: .round))
        .frame(width: size, height: size * 0.6)
        .offset(x: -size / 2)
    }
}

struct ChatterMouthShape: View {
    let size: CGFloat
    var body: some View {
        ZStack {
            Path { path in
                let steps = 5
                let stepW = size / CGFloat(steps)
                path.move(to: CGPoint(x: 0, y: size * 0.3))
                for i in 0..<steps {
                    let x = CGFloat(i + 1) * stepW
                    let y: CGFloat = i % 2 == 0 ? 0 : size * 0.55
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(Color(hex: "1A1A2E"), style: StrokeStyle(lineWidth: max(2, size * 0.1), lineCap: .round, lineJoin: .round))
            .frame(width: size, height: size * 0.55)
            .offset(x: -size / 2)
        }
    }
}

struct WavyMouthShape: View {
    let size: CGFloat
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: size * 0.3))
            path.addCurve(
                to: CGPoint(x: size, y: size * 0.3),
                control1: CGPoint(x: size * 0.33, y: 0),
                control2: CGPoint(x: size * 0.67, y: size * 0.6)
            )
        }
        .stroke(Color(hex: "1A1A2E"), style: StrokeStyle(lineWidth: max(2, size * 0.1), lineCap: .round))
        .frame(width: size, height: size * 0.6)
        .offset(x: -size / 2)
    }
}

// MARK: Brows

struct AngryBrow: View {
    let size: CGFloat
    let flipped: Bool

    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: flipped ? 0 : size * 0.4))
            path.addLine(to: CGPoint(x: size, y: flipped ? size * 0.4 : 0))
        }
        .stroke(Color(hex: "1A1A2E"), style: StrokeStyle(lineWidth: max(2, size * 0.2), lineCap: .round))
        .frame(width: size, height: size * 0.4)
    }
}

struct RaisedBrow: View {
    let size: CGFloat

    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: size * 0.3))
            path.addQuadCurve(to: CGPoint(x: size, y: 0), control: CGPoint(x: size * 0.5, y: -size * 0.2))
        }
        .stroke(Color(hex: "1A1A2E"), style: StrokeStyle(lineWidth: max(2, size * 0.18), lineCap: .round))
        .frame(width: size, height: size * 0.5)
    }
}

// MARK: Hot Sun Accessories

struct SunglassesView: View {
    let size: CGFloat

    var body: some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: "1A1A2E"))
                .frame(width: size * 0.07, height: size * 0.035)
            lens(size: size)
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: "1A1A2E"))
                .frame(width: size * 0.07, height: size * 0.03)
            lens(size: size)
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: "1A1A2E"))
                .frame(width: size * 0.07, height: size * 0.035)
        }
    }

    func lens(size: CGFloat) -> some View {
        let w = size * 0.23
        let h = size * 0.155
        let r = size * 0.055
        return ZStack {
            RoundedRectangle(cornerRadius: r)
                .fill(Color(hex: "0A0A1A"))
                .frame(width: w, height: h)
            Ellipse()
                .fill(Color.white.opacity(0.22))
                .frame(width: size * 0.07, height: size * 0.04)
                .offset(x: -size * 0.05, y: -size * 0.025)
            RoundedRectangle(cornerRadius: r)
                .stroke(Color(hex: "1A1A2E"), lineWidth: 2)
                .frame(width: w, height: h)
        }
    }
}

struct ScreamMouthView: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color(hex: "180800"))
                .frame(width: size * 0.3, height: size * 0.19)
                .overlay(Ellipse().stroke(Color(hex: "0A0000"), lineWidth: 2))

            HStack(spacing: 1.5) {
                ForEach(0..<4) { _ in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white)
                        .frame(width: size * 0.052, height: size * 0.065)
                }
            }
            .offset(y: -size * 0.048)

            Ellipse()
                .fill(Color(hex: "E03030"))
                .frame(width: size * 0.15, height: size * 0.08)
                .offset(y: size * 0.045)
        }
    }
}

// MARK: Cloud & Rain

struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        var p = Path()
        p.move(to: CGPoint(x: w * 0.2, y: h))
        p.addLine(to: CGPoint(x: w * 0.8, y: h))
        p.addArc(center: CGPoint(x: w * 0.78, y: h * 0.65), radius: h * 0.35,
                 startAngle: .degrees(90), endAngle: .degrees(0), clockwise: true)
        p.addArc(center: CGPoint(x: w * 0.65, y: h * 0.38), radius: h * 0.38,
                 startAngle: .degrees(20), endAngle: .degrees(150), clockwise: true)
        p.addArc(center: CGPoint(x: w * 0.38, y: h * 0.28), radius: h * 0.32,
                 startAngle: .degrees(10), endAngle: .degrees(160), clockwise: true)
        p.addArc(center: CGPoint(x: w * 0.2, y: h * 0.58), radius: h * 0.42,
                 startAngle: .degrees(260), endAngle: .degrees(90), clockwise: true)
        p.closeSubpath()
        return p
    }
}

struct RainDrop: View {
    let size: CGFloat
    var body: some View {
        Capsule()
            .fill(Color(hex: "4A90D9"))
            .frame(width: size * 0.42, height: size)
            .overlay(Capsule().stroke(Color(hex: "2A6AA9"), lineWidth: 1.5))
    }
}

struct FogLine: View {
    let size: CGFloat
    var body: some View {
        RoundedRectangle(cornerRadius: 7)
            .fill(Color(white: 0.76).opacity(0.88))
            .frame(width: size, height: 11)
            .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color(white: 0.58), lineWidth: 1.5))
    }
}

struct TearDropShape: Shape {
    func path(in rect: CGRect) -> Path {
        let cx = rect.midX
        let w = rect.width, h = rect.height
        var p = Path()
        p.move(to: CGPoint(x: cx, y: 0))
        p.addCurve(to: CGPoint(x: cx + w * 0.5, y: h * 0.65),
                   control1: CGPoint(x: cx + w * 0.5, y: h * 0.15),
                   control2: CGPoint(x: cx + w * 0.5, y: h * 0.4))
        p.addArc(center: CGPoint(x: cx, y: h * 0.65), radius: w * 0.5,
                 startAngle: .degrees(0), endAngle: .degrees(180), clockwise: false)
        p.addCurve(to: CGPoint(x: cx, y: 0),
                   control1: CGPoint(x: cx - w * 0.5, y: h * 0.4),
                   control2: CGPoint(x: cx - w * 0.5, y: h * 0.15))
        p.closeSubpath()
        return p
    }
}

struct LightningBolt: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        var p = Path()
        p.move(to: CGPoint(x: w * 0.62, y: 0))
        p.addLine(to: CGPoint(x: w * 0.3, y: h * 0.46))
        p.addLine(to: CGPoint(x: w * 0.58, y: h * 0.46))
        p.addLine(to: CGPoint(x: w * 0.28, y: h))
        p.addLine(to: CGPoint(x: w * 0.72, y: h * 0.54))
        p.addLine(to: CGPoint(x: w * 0.46, y: h * 0.54))
        p.closeSubpath()
        return p
    }
}

// MARK: - Color extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}
