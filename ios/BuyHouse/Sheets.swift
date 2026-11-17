import SwiftUI

// MARK: - 页面通用页头

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

// MARK: - 售楼部

struct SaleOfficeView: View {
    @ObservedObject var store: GameStore
    @Environment(\.dismiss) private var dismiss

    @State private var confirming: GameData.BuildingDef?
    @State private var error: String?

    private let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                SheetHeader(title: "售楼部") { dismiss() }
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(GameData.buildings, id: \.name) { b in
                            card(b)
                        }
                    }
                    .padding(Layout.hPad)
                }
            }

            if let b = confirming {
                confirmOverlay(b)
            }
        }
        .preferredColorScheme(.light)
    }

    private func card(_ b: GameData.BuildingDef) -> some View {
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
                    error = nil
                    confirming = b
                }
            }
            .frame(height: 214)
        }
    }

    private func confirmOverlay(_ b: GameData.BuildingDef) -> some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    confirming = nil
                    error = nil
                }

            PixelPanel(title: "购买确认") {
                VStack(spacing: 10) {
                    Text("\(b.name) · \(b.area)m²")
                        .font(Theme.pixel(12))
                        .foregroundColor(Theme.ink)
                    Text("\(b.priceWan) 万 · 声望 +\(GameData.buildingHopeGain)")
                        .font(Theme.pixel(12))
                        .foregroundColor(Theme.sub)
                    if let error {
                        Text(error)
                            .font(Theme.pixel(12))
                            .foregroundColor(Theme.red)
                    }
                    HStack(spacing: 8) {
                        PixelButton(title: "取消") {
                            confirming = nil
                            error = nil
                        }
                        PixelButton(title: "确定", primary: true) {
                            if store.buyBuilding(b) {
                                confirming = nil
                                error = nil
                            } else {
                                error = store.alert
                                store.alert = nil
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: 280)
            .padding(24)
        }
    }
}

// MARK: - 成就（全局永久）

struct AchievementsView: View {
    @ObservedObject var progress = Progress.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                SheetHeader(title: "成就 \(progress.unlockedCount)/\(GameData.achievements.count)") { dismiss() }
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
        let got = progress.isUnlocked(a.code)
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
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .background(Theme.paper)
        .overlay(Rectangle().stroke(Theme.ink, lineWidth: 1))
    }
}

// MARK: - 里程碑（全局计数）

struct MilestonesView: View {
    @ObservedObject var progress = Progress.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                SheetHeader(title: "里程碑 · 累计 \(progress.totalMilestones)") { dismiss() }
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 6) {
                        ForEach(GameData.buildings, id: \.name) { b in
                            row(b)
                        }
                    }
                    .padding(Layout.hPad)
                }
            }
        }
        .preferredColorScheme(.light)
    }

    private func row(_ b: GameData.BuildingDef) -> some View {
        let count = progress.milestoneCount(b.name)
        return HStack(spacing: 10) {
            Image(b.asset)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .opacity(count > 0 ? 1 : 0.3)
            VStack(alignment: .leading, spacing: 2) {
                Text(b.name)
                    .font(Theme.pixel(12))
                    .foregroundColor(count > 0 ? Theme.ink : Theme.sub)
                Text("\(b.area)m²")
                    .font(Theme.pixel(12))
                    .foregroundColor(Theme.soft)
            }
            Spacer(minLength: 4)
            Text("×\(count)")
                .font(Theme.pixel(24))
                .foregroundColor(count > 0 ? Theme.red : Theme.soft)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Theme.paper)
        .overlay(Rectangle().stroke(Theme.ink, lineWidth: 1))
    }
}

// MARK: - 房产（当前存档）

struct HousesView: View {
    @ObservedObject var store: GameStore
    @Environment(\.dismiss) private var dismiss

    private var owned: [GameData.BuildingDef] {
        GameData.buildings.filter { store.state.buildingHouse.contains($0.name) }
    }

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                SheetHeader(title: "房产 \(owned.count)/\(GameData.buildings.count)") { dismiss() }
                ScrollView(showsIndicators: false) {
                    if owned.isEmpty {
                        EmptyState(text: "还没有房产，去售楼部看看")
                            .padding(Layout.hPad)
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)],
                                  spacing: 8) {
                            ForEach(owned, id: \.name) { b in
                                PixelPanel {
                                    VStack(spacing: 6) {
                                        Image(b.asset)
                                            .interpolation(.none)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 110)
                                        Text(b.name)
                                            .font(Theme.pixel(12))
                                            .foregroundColor(Theme.ink)
                                        Text("\(b.area)m² · \(b.priceWan) 万")
                                            .font(Theme.pixel(12))
                                            .foregroundColor(Theme.sub)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        .padding(Layout.hPad)
                    }
                }
            }
        }
        .preferredColorScheme(.light)
    }
}

// MARK: - 结算（只看本局）

struct SettlementView: View {
    @ObservedObject var store: GameStore
    @Environment(\.dismiss) private var dismiss

    private var data: Settlement {
        if let s = store.settlement { return s }
        return Settlement(weeks: store.state.week,
                          netWorth: store.state.money + store.state.cash + store.state.alimoney,
                          achievements: store.satisfiedAchievements().map { GameData.achievementDesc($0) },
                          houses: store.state.buildingHouse)
    }

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                SheetHeader(title: "结算") { dismiss() }
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        PixelPanel(title: "本局") {
                            VStack(spacing: 8) {
                                row("生存", "\(data.weeks) 周")
                                row("净资产", Money.text(data.netWorth))
                            }
                        }

                        if !data.houses.isEmpty {
                            PixelPanel(title: "房产 \(data.houses.count)") {
                                VStack(alignment: .leading, spacing: 6) {
                                    ForEach(data.houses, id: \.self) { name in
                                        HStack(spacing: 6) {
                                            Rectangle().fill(Theme.sub).frame(width: 4, height: 4)
                                            Text(name)
                                                .font(Theme.pixel(12))
                                                .foregroundColor(Theme.ink)
                                            Spacer(minLength: 0)
                                        }
                                    }
                                }
                            }
                        }

                        if !data.achievements.isEmpty {
                            PixelPanel(title: "成就 \(data.achievements.count)") {
                                VStack(alignment: .leading, spacing: 6) {
                                    ForEach(data.achievements, id: \.self) { desc in
                                        HStack(spacing: 6) {
                                            Rectangle().fill(Theme.sub).frame(width: 4, height: 4)
                                            Text(desc)
                                                .font(Theme.pixel(12))
                                                .foregroundColor(Theme.ink)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.8)
                                            Spacer(minLength: 0)
                                        }
                                    }
                                }
                            }
                        }

                        HStack(spacing: 8) {
                            PixelButton(title: "返回") { dismiss() }
                            PixelButton(title: "重新开始", primary: true) {
                                store.restart()
                                dismiss()
                            }
                        }
                    }
                    .padding(Layout.hPad)
                }
            }
        }
        .preferredColorScheme(.light)
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(Theme.pixel(12))
                .foregroundColor(Theme.sub)
            Spacer()
            Text(value)
                .font(Theme.pixel(12))
                .foregroundColor(Theme.ink)
        }
    }
}

// MARK: - 小弹窗：确认

struct ConfirmDialog: View {
    @ObservedObject var store: GameStore
    let title: String
    let message: String
    let onConfirm: () -> Void
    let onClose: () -> Void

    @State private var result: String?

    var body: some View {
        PixelPanel(title: title) {
            VStack(spacing: 12) {
                Text(result ?? message)
                    .font(Theme.pixel(12))
                    .foregroundColor(result == nil ? Theme.sub : Theme.ink)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                if result == nil {
                    HStack(spacing: 8) {
                        PixelButton(title: "取消") { onClose() }
                        PixelButton(title: "确定", primary: true) {
                            onConfirm()
                            result = store.lastResult
                            store.lastResult = nil
                        }
                    }
                } else {
                    PixelButton(title: "关闭", primary: true) { onClose() }
                }
            }
        }
    }
}

// MARK: - 小弹窗：数字输入

struct NumberDialog: View {
    @ObservedObject var store: GameStore
    let title: String
    let prompt: String
    let inLabel: String
    let outLabel: String?
    var defaultValue: Int = 0
    let onIn: (Int) -> Bool
    let onOut: (Int) -> Bool
    let onClose: () -> Void

    @State private var text = ""
    @State private var error: String?

    var body: some View {
        PixelPanel(title: title) {
            VStack(spacing: 10) {
                Text(prompt)
                    .font(Theme.pixel(12))
                    .foregroundColor(Theme.sub)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                TextField("0", text: $text)
                    .keyboardType(.numberPad)
                    .font(Theme.pixel(24))
                    .multilineTextAlignment(.center)
                    .padding(6)
                    .background(Theme.paper)
                    .overlay(Rectangle().stroke(Theme.ink, lineWidth: 1))

                if let error {
                    Text(error)
                        .font(Theme.pixel(12))
                        .foregroundColor(Theme.red)
                }

                HStack(spacing: 8) {
                    PixelButton(title: "取消") { onClose() }
                    if let outLabel {
                        PixelButton(title: outLabel) {
                            if onOut(Int(text) ?? 0) { onClose() } else { fail() }
                        }
                    }
                    PixelButton(title: inLabel, primary: true) {
                        if onIn(Int(text) ?? 0) { onClose() } else { fail() }
                    }
                }
            }
        }
        .onAppear {
            if text.isEmpty, defaultValue > 0 {
                text = String(defaultValue)
            }
        }
    }

    private func fail() {
        error = store.alert
        store.alert = nil
    }
}

// MARK: - 小弹窗：彩票

struct LotteryDialog: View {
    @ObservedObject var store: GameStore
    let onClose: () -> Void

    @State private var amount = ""
    @State private var kind: LotteryKind = .six
    @State private var message: String?

    var body: some View {
        PixelPanel(title: "时时彩票") {
            VStack(spacing: 10) {
                Text("随机 1~10 号，猜中直返倍率")
                    .font(Theme.pixel(12))
                    .foregroundColor(Theme.sub)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 3), spacing: 5) {
                    ForEach(LotteryKind.allCases) { k in
                        Button {
                            kind = k
                        } label: {
                            Text(k.title)
                                .font(Theme.pixel(12))
                                .foregroundColor(Theme.ink)
                                .frame(maxWidth: .infinity, minHeight: 26)
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
                    .padding(6)
                    .background(Theme.paper)
                    .overlay(Rectangle().stroke(Theme.ink, lineWidth: 1))

                if let message {
                    Text(message)
                        .font(Theme.pixel(12))
                        .foregroundColor(Theme.red)
                        .multilineTextAlignment(.center)
                }

                HStack(spacing: 8) {
                    PixelButton(title: "关闭") { onClose() }
                    PixelButton(title: "下注", primary: true) {
                        if store.lotteryBet(amount: Int(amount) ?? 0, kind: kind) {
                            amount = ""
                            message = store.lastResult
                            store.lastResult = nil
                        } else {
                            message = store.alert
                            store.alert = nil
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 小弹窗：关于

struct AboutDialog: View {
    let onClose: () -> Void

    var body: some View {
        PixelPanel(title: "关于") {
            VStack(spacing: 8) {
                Text("买房记").font(Theme.pixel(24)).foregroundColor(Theme.ink)
                Text("v1.3 · iOS 移植版")
                    .font(Theme.pixel(12))
                    .foregroundColor(Theme.sub)
                Text("原作：绫里千寻")
                    .font(Theme.pixel(12))
                    .foregroundColor(Theme.sub)
                PixelButton(title: "返回") { onClose() }
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
