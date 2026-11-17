import SwiftUI

struct MainView: View {
    @StateObject private var store = GameStore()
    @ObservedObject private var progress = Progress.shared

    @State private var page: Page?
    @State private var dialog: Dialog?

    enum Page: String, Identifiable {
        case sale, achievements, milestones, houses, settlement
        var id: String { rawValue }
    }

    enum Dialog: Identifiable {
        case hospital, sport, bank, alipay, agency, lottery, about
        case buy(MarketCargo), sell(RoomCargo)

        var id: String {
            switch self {
            case .hospital: return "hospital"
            case .sport: return "sport"
            case .bank: return "bank"
            case .alipay: return "alipay"
            case .agency: return "agency"
            case .lottery: return "lottery"
            case .about: return "about"
            case .buy(let c): return "buy-\(c.code)"
            case .sell(let c): return "sell-\(c.code)"
            }
        }
    }

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                statusBar

                VStack(spacing: 0) {
                    personPanel
                    Spacer(minLength: Layout.panelGap)
                    tradeRow
                    Spacer(minLength: Layout.panelGap)
                    marketSwitchBar
                    Spacer(minLength: Layout.panelGap)
                    actionPanel
                }
                .padding(.horizontal, Layout.hPad)
                .padding(.top, 14)
                .padding(.bottom, 12)
                .frame(maxHeight: .infinity)

                bottomBar
            }

            if let dialog { dialogOverlay(dialog) }
            if store.isDead { deadOverlay }
            if let toast = store.toast { toastOverlay(toast) }
        }
        .preferredColorScheme(.light)
        .sheet(item: $page) { item in
            pageView(item)
        }
    }

    // MARK: - 顶部

    private var statusBar: some View {
        HStack(spacing: 8) {
            PixelImage(name: GameData.weatherAsset(store.state.weather), scale: 2)
            Text(store.state.weather)
                .font(Theme.pixel(12))
                .foregroundColor(Theme.ink)

            Spacer(minLength: 8)

            Button {
                page = .achievements
            } label: {
                HStack(spacing: 4) {
                    Image("star")
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                    Text("\(progress.unlockedCount)/\(GameData.achievements.count)")
                        .font(Theme.pixel(12))
                        .foregroundColor(Theme.ink)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Theme.paper)
                .overlay(Rectangle().stroke(Theme.ink, lineWidth: 1))
            }
            .buttonStyle(.plain)

            Text("第 \(store.state.week) 周")
                .font(Theme.pixel(12))
                .foregroundColor(Theme.sub)
        }
        .padding(.horizontal, Layout.hPad + 2)
        .frame(height: 44)
        .background(Theme.paper)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Theme.ink).frame(height: 1)
        }
    }

    // MARK: - 个人信息

    private var personPanel: some View {
        PixelPanel(title: "个人信息") {
            if Layout.isCompact {
                VStack(alignment: .leading, spacing: 10) {
                    moneyColumn
                    HStack(spacing: 14) {
                        barCell("健康", store.state.health, Theme.red)
                        barCell("声望", store.state.hope, Theme.green)
                    }
                }
            } else {
                HStack(alignment: .top, spacing: 10) {
                    moneyColumn
                    Spacer(minLength: 4)
                    VStack(alignment: .leading, spacing: 10) {
                        barCell("健康", store.state.health, Theme.red)
                        barCell("声望", store.state.hope, Theme.green)
                    }
                }
            }
        }
    }

    private var moneyColumn: some View {
        VStack(alignment: .leading, spacing: 7) {
            statRow("现 金", Money.text(store.state.money))
            statRow("存 款", Money.text(store.state.cash))
            statRow("余X宝", Money.text(store.state.alimoney))
        }
    }

    private func statRow(_ label: String, _ value: String) -> some View {
        HStack(spacing: 6) {
            Text(label)
                .font(Theme.pixel(12))
                .foregroundColor(Theme.sub)
                .frame(width: Layout.statsLabelWidth, alignment: .leading)
            Text(value)
                .font(Theme.pixel(12))
                .foregroundColor(Theme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    private func barCell(_ label: String, _ value: Int, _ color: Color) -> some View {
        HStack(spacing: 6) {
            Text(label)
                .font(Theme.pixel(12))
                .foregroundColor(Theme.sub)
            StatBar(value: value, color: color, width: Layout.barWidth)
            Text("\(value)")
                .font(Theme.pixel(12))
                .foregroundColor(Theme.ink)
                .frame(width: 20, alignment: .trailing)
        }
    }

    // MARK: - 两栏

    private var tradeRow: some View {
        HStack(alignment: .top, spacing: 8) {
            roomPanel
            marketPanel
                .overlay(alignment: .top) {
                    if store.hasPendingEvents {
                        eventOverlay
                    }
                }
        }
    }

    /// 报纸叠在市场栏上，一张一张点掉（不加背景，不遮住下面的行情）
    private var eventOverlay: some View {
        ZStack(alignment: .top) {
            if store.pendingEvents.count > 1 {
                ForEach(1..<store.pendingEvents.count, id: \.self) { i in
                    Image("event_paper")
                        .interpolation(.none)
                        .resizable(capInsets: EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4),
                                   resizingMode: .stretch)
                        .frame(height: 196)
                        .offset(x: CGFloat(i) * 3, y: CGFloat(i) * 4)
                }
            }
            if let event = store.pendingEvents.first {
                NewspaperCard(event: event)
                    .frame(height: 196)
            }
        }
        .padding(.horizontal, 6)
        .padding(.top, 6)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.16)) {
                store.dismissEvent()
            }
        }
    }

    private var roomPanel: some View {
        PixelPanel(title: "出租屋 \(store.state.cargoCur)/\(store.state.cargoMax)", minHeight: Layout.tradeListHeight) {
            VStack(spacing: 0) {
                if store.state.roomCargos.isEmpty {
                    EmptyState(text: "还没有存货")
                }
                ForEach(store.state.roomCargos) { item in
                    Button {
                        dialog = .sell(item)
                    } label: {
                        HStack(spacing: 4) {
                            PixelImage(name: GameData.cargo(item.code)?.asset ?? "item_beans", scale: 2)
                            Text(GameData.cargoName(item.code))
                                .font(Theme.pixel(12))
                                .foregroundColor(Theme.ink)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                            Spacer(minLength: 2)
                            Text("\(item.priceBuy)")
                                .font(Theme.pixel(12))
                                .foregroundColor(Theme.sub)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                            Text("×\(item.num)")
                                .font(Theme.pixel(12))
                                .foregroundColor(Theme.ink)
                                .lineLimit(1)
                        }
                        .frame(height: Layout.rowHeight)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    if item.id != store.state.roomCargos.last?.id {
                        DottedLine()
                    }
                }
            }
        }
    }

    private var marketPanel: some View {
        PixelPanel(title: "市场", minHeight: Layout.tradeListHeight) {
            VStack(spacing: 0) {
                if store.currentMarket.isEmpty {
                    EmptyState(text: "休市")
                }
                ForEach(store.currentMarket) { item in
                    Button {
                        dialog = .buy(item)
                    } label: {
                        HStack(spacing: 4) {
                            PixelImage(name: GameData.cargo(item.code)?.asset ?? "item_beans", scale: 2)
                            Text(GameData.cargoName(item.code))
                                .font(Theme.pixel(12))
                                .foregroundColor(Theme.ink)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                            Spacer(minLength: 2)
                            Text("\(item.priceCur)")
                                .font(Theme.pixel(12))
                                .foregroundColor(Theme.sub)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .frame(height: Layout.rowHeight)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    if item.id != store.currentMarket.last?.id {
                        DottedLine()
                    }
                }
            }
            .disabled(store.hasPendingEvents)
        }
    }

    // MARK: - 市场切换（原来房产那一栏）

    private var marketSwitchBar: some View {
        PixelPanel(title: "切换市场") {
            HStack(spacing: 6) {
                ForEach(0..<GameData.marketCount, id: \.self) { i in
                    let active = i == store.state.marketIndex
                    Button {
                        store.switchMarket(to: i)
                    } label: {
                        Text(GameData.marketNames[i])
                            .font(Theme.pixel(12))
                            .foregroundColor(Theme.ink)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .frame(maxWidth: .infinity)
                            .frame(height: Layout.isShort ? 30 : 34)
                            .background(active ? Theme.yellow : Theme.paper)
                            .overlay(Rectangle().stroke(Theme.ink, lineWidth: active ? 2 : 1))
                    }
                    .buttonStyle(.plain)
                    .disabled(active || store.hasPendingEvents)
                }
            }
        }
    }

    // MARK: - 操作

    private var actionPanel: some View {
        PixelPanel(title: "操作") {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: Layout.gridGap), count: 4),
                      spacing: Layout.gridGap) {
                PixelButton(title: "医院", icon: "act_hospital", height: Layout.actionHeight) { dialog = .hospital }
                PixelButton(title: "健身房", icon: "act_gym", height: Layout.actionHeight) { dialog = .sport }
                PixelButton(title: "银行", icon: "act_bank", height: Layout.actionHeight) { dialog = .bank }
                PixelButton(title: "余X宝", icon: "act_alipay", height: Layout.actionHeight) { dialog = .alipay }
                PixelButton(title: "中介", icon: "act_agent", height: Layout.actionHeight) { dialog = .agency }
                PixelButton(title: "彩票", icon: "act_lottery", height: Layout.actionHeight) { dialog = .lottery }
                PixelButton(title: "售楼部", icon: "act_sales", height: Layout.actionHeight) { page = .sale }
                PixelButton(title: "关于", icon: "act_about", height: Layout.actionHeight) { dialog = .about }
            }
        }
    }

    // MARK: - 底部

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Rectangle().fill(Theme.ink.opacity(0.25)).frame(height: 1)
            HStack(spacing: 8) {
                PixelButton(title: "房产 \(store.state.buildingHouse.count)", height: Layout.isShort ? 40 : 44) {
                    page = .houses
                }
                PixelButton(title: "结束游戏", height: Layout.isShort ? 40 : 44) {
                    _ = store.finishRun()
                    page = .settlement
                }
                PixelButton(title: "里程碑 \(progress.totalMilestones)", height: Layout.isShort ? 40 : 44) {
                    page = .milestones
                }
            }
            .padding(.horizontal, Layout.hPad)
            .padding(.vertical, 8)
            .background(Theme.bg)
        }
    }

    // MARK: - 弹窗

    private func dialogOverlay(_ item: Dialog) -> some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { dialog = nil }

            Group {
                switch item {
                case .hospital:
                    ConfirmDialog(store: store, title: "医院",
                                  message: "花费 \(GameData.hospitalCost) 元恢复健康，确定？",
                                  onConfirm: { store.hospital() },
                                  onClose: { dialog = nil })
                case .sport:
                    ConfirmDialog(store: store, title: "健身房",
                                  message: "花费 \(GameData.sportCost) 元恢复健康，确定？",
                                  onConfirm: { store.sport() },
                                  onClose: { dialog = nil })
                case .bank:
                    NumberDialog(store: store, title: "存取款",
                                 prompt: "周息 \(Int(GameData.cashInterest * 100))%",
                                 inLabel: "存款", outLabel: "取款",
                                 onIn: { store.depositToBank($0) },
                                 onOut: { store.withdrawFromBank($0) },
                                 onClose: { dialog = nil })
                case .alipay:
                    NumberDialog(store: store, title: "余X宝",
                                 prompt: "周息 \(Int(GameData.alimoneyInterest * 100))%",
                                 inLabel: "存入", outLabel: "提现",
                                 onIn: { store.depositToAlipay($0) },
                                 onOut: { store.withdrawFromAlipay($0) },
                                 onClose: { dialog = nil })
                case .agency:
                    NumberDialog(store: store, title: "购买出租屋",
                                 prompt: "1 个 / 1 万元，当前 \(store.state.cargoMax) 个",
                                 inLabel: "确定", outLabel: nil,
                                 onIn: { store.buyAgency($0) },
                                 onOut: { _ in false },
                                 onClose: { dialog = nil })
                case .lottery:
                    LotteryDialog(store: store, onClose: { dialog = nil })
                case .about:
                    AboutDialog(onClose: { dialog = nil })
                case .buy(let item):
                    NumberDialog(store: store, title: "买入 \(GameData.cargoName(item.code))",
                                 prompt: "单价 \(item.priceCur) 元 · 最多可买 \(store.maxBuyCount(item.code))",
                                 inLabel: "买入", outLabel: nil,
                                 defaultValue: store.maxBuyCount(item.code),
                                 onIn: { store.buyCargo(item.code, count: $0) },
                                 onOut: { _ in false },
                                 onClose: { dialog = nil })
                case .sell(let item):
                    NumberDialog(store: store, title: "卖出 \(GameData.cargoName(item.code))",
                                 prompt: "现价 \(store.marketPrice(item.code)) 元 · 持有 \(item.num)",
                                 inLabel: "卖出", outLabel: nil,
                                 defaultValue: item.num,
                                 onIn: { store.sellCargo(item.code, count: $0) },
                                 onOut: { _ in false },
                                 onClose: { dialog = nil })
                }
            }
            .frame(maxWidth: 300)
            .padding(.horizontal, 24)
        }
    }

    // MARK: - 提示浮层

    private func toastOverlay(_ text: String) -> some View {
        VStack {
            Spacer()
            PixelPanel(title: "成就解锁") {
                VStack(spacing: Layout.panelGap) {
                    Text(text)
                        .font(Theme.pixel(12))
                        .foregroundColor(Theme.ink)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                    PixelButton(title: "知道了", primary: true) {
                        store.toast = nil
                    }
                }
            }
            .frame(maxWidth: 300)
            .padding(.horizontal, 40)
            .padding(.bottom, 110)
        }
    }

    private var deadOverlay: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
            PixelPanel(title: "游戏结束") {
                VStack(spacing: 12) {
                    Text("共生存 \(store.state.week) 周")
                        .font(Theme.pixel(12))
                        .foregroundColor(Theme.red)
                    HStack(spacing: 8) {
                        PixelButton(title: "结算") {
                            _ = store.finishRun()
                            store.isDead = false
                            page = .settlement
                        }
                        PixelButton(title: "重开", primary: true) {
                            store.restart()
                        }
                    }
                }
                .frame(width: 220)
            }
            .padding(40)
        }
    }

    // MARK: - 页面

    @ViewBuilder
    private func pageView(_ item: Page) -> some View {
        switch item {
        case .sale:
            SaleOfficeView(store: store)
        case .achievements:
            AchievementsView()
        case .milestones:
            MilestonesView()
        case .houses:
            HousesView(store: store)
        case .settlement:
            SettlementView(store: store)
        }
    }
}

