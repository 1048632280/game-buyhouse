import SwiftUI

// MARK: - 通用页头

struct SheetHeader: View {
    let title: String
    let onBack: () -> Void

    var body: some View {
        ZStack {
            Text(title)
                .font(Theme.pixel(24))
                .foregroundColor(Theme.ink)
            HStack {
                PixelButton(title: "返回", height: 30, action: onBack)
                    .frame(width: 64)
                Spacer()
            }
            .padding(.horizontal, Layout.hPad)
        }
        .frame(height: 52)
        .background(Theme.paper)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Theme.ink).frame(height: 1)
        }
    }
}

// MARK: - 弹窗卡片容器

struct DialogCard<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            PixelPanel(title: title) {
                content
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: 330)
            .padding(.horizontal, 24)
        }
        .preferredColorScheme(.light)
    }
}

// MARK: - 确认框

struct ConfirmDialog: View {
    @ObservedObject var store: GameStore
    let title: String
    let message: String
    let onConfirm: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var result: String?

    var body: some View {
        DialogCard(title: title) {
            VStack(spacing: 14) {
                Text(result ?? message)
                    .font(Theme.pixel(12))
                    .foregroundColor(result == nil ? Theme.sub : Theme.ink)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                if result == nil {
                    HStack(spacing: 8) {
                        PixelButton(title: "取消") { dismiss() }
                        PixelButton(title: "确定", primary: true) {
                            onConfirm()
                            result = store.alert
                            store.alert = nil
                        }
                    }
                } else {
                    PixelButton(title: "关闭", primary: true) { dismiss() }
                }
            }
        }
    }
}

// MARK: - 数字输入框

struct NumberDialog: View {
    let title: String
    let prompt: String
    let inLabel: String
    let outLabel: String?
    var defaultValue: Int = 0
    let onIn: (Int) -> Bool
    let onOut: (Int) -> Bool

    @Environment(\.dismiss) private var dismiss
    @State private var text = ""

    var body: some View {
        DialogCard(title: title) {
            VStack(spacing: 12) {
                Text(prompt)
                    .font(Theme.pixel(12))
                    .foregroundColor(Theme.sub)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                TextField("0", text: $text)
                    .keyboardType(.numberPad)
                    .font(Theme.pixel(24))
                    .multilineTextAlignment(.center)
                    .padding(8)
                    .background(Theme.paper)
                    .overlay(Rectangle().stroke(Theme.ink, lineWidth: 1))

                HStack(spacing: 8) {
                    if let outLabel {
                        PixelButton(title: outLabel) {
                            if onOut(Int(text) ?? 0) { dismiss() }
                        }
                    }
                    PixelButton(title: inLabel, primary: true) {
                        if onIn(Int(text) ?? 0) { dismiss() }
                    }
                }
                PixelButton(title: "取消") { dismiss() }
            }
        }
        .onAppear {
            if text.isEmpty, defaultValue > 0 {
                text = String(defaultValue)
            }
        }
    }
}

// MARK: - 彩票

struct LotteryView: View {
    @ObservedObject var store: GameStore
    @Environment(\.dismiss) private var dismiss
    @State private var amount = ""
    @State private var kind: LotteryKind = .six

    var body: some View {
        DialogCard(title: "时时彩票") {
            VStack(spacing: 12) {
                Text("随机 1~10 号，猜中直返倍率")
                    .font(Theme.pixel(12))
                    .foregroundColor(Theme.sub)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 3), spacing: 6) {
                    ForEach(LotteryKind.allCases) { k in
                        Button {
                            kind = k
                        } label: {
                            Text(k.title)
                                .font(Theme.pixel(12))
                                .foregroundColor(Theme.ink)
                                .frame(maxWidth: .infinity, minHeight: 30)
                                .background(kind == k ? Theme.yellow : Theme.paper)
                                .overlay(Rectangle().stroke(Theme.ink, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }

                TextField("押注数（元）", text: $amount)
                    .keyboardType(.numberPad)
                    .font(Theme.pixel(12))
                    .multilineTextAlignment(.center)
                    .padding(8)
                    .background(Theme.paper)
                    .overlay(Rectangle().stroke(Theme.ink, lineWidth: 1))

                if let prize = store.lastLottery {
                    Text("上期开彩结果：\(prize)")
                        .font(Theme.pixel(12))
                        .foregroundColor(Theme.sub)
                }
                if let msg = store.alert {
                    Text(msg)
                        .font(Theme.pixel(12))
                        .foregroundColor(Theme.red)
                        .multilineTextAlignment(.center)
                }

                HStack(spacing: 8) {
                    PixelButton(title: "关闭") { dismiss() }
                    PixelButton(title: "下注", primary: true) {
                        if store.lotteryBet(amount: Int(amount) ?? 0, kind: kind) {
                            amount = ""
                            store.alert = nil
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 售楼部

struct SaleOfficeView: View {
    @ObservedObject var store: GameStore
    @Environment(\.dismiss) private var dismiss
    @State private var pending: GameData.BuildingDef?

    private let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                SheetHeader(title: "售楼部") { dismiss() }

                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(GameData.buildings, id: \.name) { b in
                            buildingCard(b)
                        }
                    }
                    .padding(Layout.hPad)
                }
            }
        }
        .preferredColorScheme(.light)
        .storeAlert(store)
    }

    private func buildingCard(_ b: GameData.BuildingDef) -> some View {
        let owned = store.state.buildingHouse.contains(b.name)
        return PixelPanel {
            VStack(spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(b.name)
                        .font(Theme.pixel(12))
                        .foregroundColor(Theme.ink)
                        .lineLimit(1)
                    Spacer(minLength: 4)
                    Text("\(b.area)m²")
                        .font(Theme.pixel(12))
                        .foregroundColor(Theme.sub)
                        .lineLimit(1)
                }

                Image(b.asset)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 116)
                    .frame(maxWidth: .infinity)

                HStack {
                    Text("\(b.priceWan) 万")
                        .font(Theme.pixel(24))
                        .foregroundColor(Theme.red)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Spacer(minLength: 0)
                }

                PixelButton(title: owned ? "已拥有" : "购入",
                            primary: !owned,
                            enabled: !owned,
                            height: 30) {
                    pending = b
                }
            }
            .frame(height: 214)
        }
        .alert("确定购买 \(b.name)？", isPresented: Binding(
            get: { pending?.name == b.name },
            set: { if !$0 { pending = nil } }
        )) {
            Button("取消", role: .cancel) { pending = nil }
            Button("确定") {
                if let p = pending { store.buyBuilding(p) }
                pending = nil
            }
        } message: {
            Text("\(b.priceWan) 万，声望 +\(GameData.buildingHopeGain)")
        }
    }
}

// MARK: - 成就

struct ArchiveView: View {
    @ObservedObject var store: GameStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                SheetHeader(title: "已获成就") { dismiss() }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 6) {
                        ForEach(GameData.achievements) { a in
                            row(a)
                        }
                    }
                    .padding(Layout.hPad)
                }
            }
        }
        .preferredColorScheme(.light)
    }

    private func row(_ a: GameData.AchievementDef) -> some View {
        let got = store.state.archivePerson.contains(a.code)
        return HStack(spacing: 10) {
            Image("star")
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .opacity(got ? 1 : 0.22)
            Text(a.desc)
                .font(Theme.pixel(12))
                .foregroundColor(got ? Theme.ink : Theme.sub)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer(minLength: 4)
            Text(got ? "已获得" : "未解锁")
                .font(Theme.pixel(12))
                .foregroundColor(got ? Theme.deepGreen : Theme.soft)
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .background(Theme.paper)
        .overlay(Rectangle().stroke(Theme.ink, lineWidth: 1))
    }
}

// MARK: - 关于

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        DialogCard(title: "关于") {
            VStack(spacing: 10) {
                Text("买房记").font(Theme.pixel(24)).foregroundColor(Theme.ink)
                Text("v1.3").font(Theme.pixel(12)).foregroundColor(Theme.sub)
                Text("iOS 移植版 · 原作：绫里千寻")
                    .font(Theme.pixel(12))
                    .foregroundColor(Theme.sub)
                    .multilineTextAlignment(.center)
                PixelButton(title: "返回") { dismiss() }
                    .padding(.top, 4)
            }
        }
    }
}

