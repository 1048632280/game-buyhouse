import SwiftUI
import UIKit

/// 像素风主题：调色板、字体、面板与按钮
enum Theme {
    // 取自 Kenney Tiny City 的 33 色调色板
    static let ink       = Color(hex: 0x3F2631)
    static let sub       = Color(hex: 0x52607C)
    static let mid       = Color(hex: 0x5A6988)
    static let soft      = Color(hex: 0x8B9BB4)
    static let line      = Color(hex: 0xC0CBDC)
    static let paper     = Color(hex: 0xE9D4D0)
    static let bg        = Color(hex: 0xC0CBDC)
    static let red       = Color(hex: 0xC34B35)
    static let orange    = Color(hex: 0xE38628)
    static let yellow    = Color(hex: 0xFDBE53)
    static let green     = Color(hex: 0x84C669)
    static let deepGreen = Color(hex: 0x479F4A)
    static let blue      = Color(hex: 0x009ADC)

    /// 方舟像素 12px；字号请只用 12 / 24 / 36，否则像素会歪
    static func pixel(_ size: CGFloat) -> Font {
        for name in ["ArkPixel12pxMonozh-Hans", "Ark Pixel 12px Mono zh-Hans", "ArkPixel12"] {
            if UIFont(name: name, size: size) != nil {
                return .custom(name, size: size)
            }
        }
        return .system(size: size, weight: .regular, design: .monospaced)
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}

// MARK: - 像素图

struct PixelImage: View {
    let name: String
    var scale: CGFloat = 2

    private var pixelSize: CGSize {
        UIImage(named: name)?.size ?? CGSize(width: 16, height: 16)
    }

    var body: some View {
        Image(name)
            .interpolation(.none)
            .resizable()
            .scaledToFit()
            .frame(width: pixelSize.width * scale, height: pixelSize.height * scale)
    }
}

// MARK: - 面板（双层描边 + 标题标签）

struct PixelPanel<Content: View>: View {
    let title: String?
    let content: Content

    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        content
            .padding(.horizontal, 10)
            .padding(.top, title == nil ? 10 : 20)
            .padding(.bottom, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.paper)
            .overlay(Rectangle().stroke(Theme.ink, lineWidth: 1))
            .overlay(
                Rectangle()
                    .stroke(Theme.line, lineWidth: 1)
                    .padding(1)
            )
            .overlay(alignment: .topLeading) {
                if let title {
                    titleTab(title)
                        .offset(x: 7, y: -9)
                }
            }
    }

    private func titleTab(_ text: String) -> some View {
        HStack(spacing: 5) {
            Rectangle()
                .fill(Theme.ink)
                .frame(width: 4, height: 4)
            Text(text)
                .font(Theme.pixel(12))
                .foregroundColor(Theme.ink)
                .lineLimit(1)
                .fixedSize()
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(Theme.paper)
        .overlay(Rectangle().stroke(Theme.ink, lineWidth: 1))
    }
}

// MARK: - 点线分隔

struct DottedLine: View {
    var color: Color = Theme.line
    var body: some View {
        GeometryReader { geo in
            Path { p in
                p.move(to: CGPoint(x: 0, y: 0.5))
                p.addLine(to: CGPoint(x: geo.size.width, y: 0.5))
            }
            .stroke(color, style: StrokeStyle(lineWidth: 1, dash: [2, 2]))
        }
        .frame(height: 1)
    }
}

// MARK: - 带刻度的状态条

struct StatBar: View {
    let value: Int
    let color: Color
    var width: CGFloat = 66

    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle().fill(Theme.line)
            Rectangle()
                .fill(color)
                .frame(width: max(0, (width - 4) * CGFloat(min(max(value, 0), 100)) / 100))
                .padding(.leading, 2)
            HStack(spacing: 1) {
                ForEach(0..<9, id: \.self) { _ in
                    Rectangle()
                        .fill(Theme.ink.opacity(0.18))
                        .frame(width: 1, height: 4)
                    Spacer(minLength: 0)
                }
                Rectangle().fill(Color.clear).frame(width: 1, height: 4)
            }
            .padding(.horizontal, 2)
        }
        .frame(width: width, height: 10)
        .overlay(Rectangle().stroke(Theme.ink, lineWidth: 1))
    }
}

// MARK: - 按钮（常态 / 按下两态）

struct PixelButtonStyle: ButtonStyle {
    let primary: Bool

    func makeBody(configuration: Configuration) -> some View {
        let imageName: String
        if configuration.isPressed && primary {
            imageName = "ui_button_pressed"
        } else {
            imageName = primary ? "ui_button" : "ui_panel"
        }

        return configuration.label
            .background(
                Image(imageName)
                    .interpolation(.none)
                    .resizable(capInsets: EdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6),
                               resizingMode: .stretch)
            )
            .brightness(configuration.isPressed && !primary ? -0.08 : 0)
            .offset(y: configuration.isPressed ? 1 : 0)
    }
}

struct PixelButton: View {
    let title: String
    var icon: String? = nil
    var primary: Bool = false
    var enabled: Bool = true
    var height: CGFloat = 34
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                if let icon {
                    Image(icon)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                }
                Text(title)
                    .font(Theme.pixel(12))
                    .foregroundColor(Theme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(.horizontal, 2)
            .frame(maxWidth: .infinity)
            .frame(height: height)
        }
        .buttonStyle(PixelButtonStyle(primary: primary))
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.4)
    }
}

// MARK: - 空态

struct EmptyState: View {
    let text: String

    var body: some View {
        Text(text)
            .font(Theme.pixel(12))
            .foregroundColor(Theme.soft)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .overlay(
                GeometryReader { geo in
                    Path { p in
                        p.addRect(CGRect(origin: .zero, size: geo.size).insetBy(dx: 0.5, dy: 0.5))
                    }
                    .stroke(Theme.soft.opacity(0.6),
                            style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                }
            )
    }
}
