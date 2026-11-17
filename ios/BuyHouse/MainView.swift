import SwiftUI

struct MainView: View {
    @StateObject private var store = GameStore()
    @State private var present: Present?

    enum Present: Identifiable {
        case sale, archive, about
        case hospital, sport, bank, alipay, agency, lottery
        case buy(MarketCargo), sell(RoomCargo)

        var id: String {
            switch self {
            case .sale: return "sale"
            case .archive: return "archive"
            case .about: return "about"
            case .hospital: return "hospital"
            case .sport: return "sport"
            case .bank: return "bank"
            case .alipay: return "alipay"
            case .agency: return "agency"
            case .lottery: return "lottery"
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

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        personPanel
                        tradeRow
                        housePanel
                        actionPanel
                    }
                    .padding(.horizontal, Layout.hPad)
                    .padding(.top, 14)
                    .padding(.bottom, 12)
                }

                tickBar
            }

            if store.isDead { deadOverlay }
            if let toast = store.toast { toastOverlay(toast) }
        }
        .preferredColorScheme(.light)
        .sheet(item: $present) { item in
            sheetView(item)
        }
        .storeAlert(store)
    }

    // MARK: - 顶部状态条

    private var statusBar: some View {
        HStack(spacing: 8) {
            PixelImage(name: GameData.weatherAsset(store.state.weather), scale: 2)
            Text(store.state.weather)
                .font(Theme.pixel(12))
                .foregroundColor(Theme.ink)

            Spacer(minLength: 8)

            Button {
                present = .archive
            } label: {
                HStack(spacing: 4) {
                    Image("star")
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                    Text("\(store.state.archivePerson.count)/\(GameData.achievements.count)")
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
                    HStack(spacing: 16) {
                        barCell("健康", store.state.health, Theme.red)
                        barCell("声望", store.state.hope, Theme.green)
                    }
                }
            } else {
                HStack(alignment: .top, spacing: 10) {
                    moneyColumn
                    Spacer(minLength: 6)
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

    // MARK: - 左右两栏：出租屋 / 市场

    private var tradeRow: some View {
        HStack(alignment: .top, spacing: 8) {
            roomPanel
            marketPanel
        }
    }

    private var roomPanel: some View {
        PixelPanel(title: "出租屋 \(store.state.cargoCur)/\(store.state.cargoMax)") {
            VStack(spacing: 0) {
                if store.state.roomCargos.isEmpty {
                    EmptyState(text: "还没有存货")
                }
                ForEach(store.state.roomCargos) { item in
                    Button {
                        present = .sell(item)
                    } label: {
                        rowContent(asset: GameData.cargo(item.code)?.asset ?? "item_beans",
                                   name: GameData.cargoName(item.code),
                                   value: "×\(item.num)")
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
        PixelPanel(title: "市场") {
            VStack(spacing: 0) {
                if store.state.marketCargos.isEmpty {
                    EmptyState(text: "行情刷新中")
                }
                ForEach(store.state.marketCargos) { item in
                    Button {
                        present = .buy(item)
                    } label: {
                        rowContent(asset: GameData.cargo(item.code)?.asset ?? "item_beans",
                                   name: GameData.cargoName(item.code),
                                   value: "\(item.priceCur)")
                    }
                    .buttonStyle(.plain)
                    if item.id != store.state.marketCargos.last?.id {
                        DottedLine()
                    }
                }
            }
        }
    }

    private func rowContent(asset: String, name: String, value: String) -> some View {
        HStack(spacing: 6) {
            PixelImage(name: asset, scale: 2)
            Text(name)
                .font(Theme.pixel(12))
                .foregroundColor(Theme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(value)
                .font(Theme.pixel(12))
                .foregroundColor(Theme.sub)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }

    // MARK: - 我的房产

    private var ownedBuildings: [GameData.BuildingDef] {
        GameData.buildings.filter { store.state.buildingHouse.contains($0.name) }
    }

    private var housePanel: some View {
        PixelPanel(title: "房产 \(ownedBuildings.count)/\(GameData.buildings.count)") {
            if ownedBuildings.isEmpty {
                EmptyState(text: "还没有房产，去售楼部看看")
            } else {
                HStack(alignment: .bottom, spacing: 12) {
                    ForEach(ownedBuildings.prefix(4), id: \.name) { b in
                        VStack(spacing: 3) {
                            Image(b.asset)
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 64)
                            Text(b.name)
                                .font(Theme.pixel(12))
                                .foregroundColor(Theme.ink)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    if ownedBuildings.count > 4 {
                        Text("+\(ownedBuildings.count - 4)")
                            .font(Theme.pixel(12))
                            .foregroundColor(Theme.sub)
                    }
                }
            }
        }
    }

    // MARK: - 操作

    private var actionPanel: some View {
        PixelPanel(title: "操作") {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: Layout.gridGap), count: 4),
                      spacing: Layout.gridGap) {
                PixelButton(title: "医院", icon: "act_hospital", height: 40) { present = .hospital }
                PixelButton(title: "健身房", icon: "act_gym", height: 40) { present = .sport }
                PixelButton(title: "银行", icon: "act_bank", height: 40) { present = .bank }
                PixelButton(title: "余X宝", icon: "act_alipay", height: 40) { present = .alipay }
                PixelButton(title: "中介", icon: "act_agent", height: 40) { present = .agency }
                PixelButton(title: "彩票", icon: "act_lottery", height: 40) { present = .lottery }
                PixelButton(title: "售楼部", icon: "act_sales", height: 40) { present = .sale }
                PixelButton(title: "关于", icon: "act_about", height: 40) { present = .about }
            }
        }
    }

    // MARK: - 底部

    private var tickBar: some View {
        VStack(spacing: 0) {
            Rectangle().fill(Theme.ink.opacity(0.25)).frame(height: 1)
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("健康 \(store.state.health)")
                        .font(Theme.pixel(12))
                        .foregroundColor(Theme.sub)
                    Text("库存 \(store.state.cargoCur)/\(store.state.cargoMax)")
                        .font(Theme.pixel(12))
                        .foregroundColor(Theme.sub)
                }
                PixelButton(title: "过一周", primary: true, height: 46) {
                    store.tickWeek()
                }
            }
            .padding(.horizontal, Layout.hPad)
            .padding(.vertical, 8)
            .background(Theme.bg)
        }
    }

    // MARK: - 遮罩

    private func toastOverlay(_ text: String) -> some View {
        VStack {
            Spacer()
            PixelPanel(title: "成就解锁") {
                VStack(spacing: 10) {
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
            .padding(.horizontal, 40)
            .padding(.bottom, 100)
        }
    }

    private var deadOverlay: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()
            PixelPanel(title: "游戏结束") {
                VStack(spacing: 14) {
                    Text("共生存 \(store.state.week) 周")
                        .font(Theme.pixel(12))
                        .foregroundColor(Theme.red)
                    PixelButton(title: "重新开始") { store.restart() }
                }
                .frame(width: 200)
            }
            .padding(50)
        }
    }

    // MARK: - 弹窗路由

    @ViewBuilder
    private func sheetView(_ item: Present) -> some View {
        switch item {
        case .sale:
            SaleOfficeView(store: store)
        case .archive:
            ArchiveView(store: store)
        case .about:
            AboutView()
        case .hospital:
            ConfirmDialog(store: store, title: "医院",
                          message: "花费 \(GameData.hospitalCost) 元恢复健康，确定？") {
                store.hospital()
            }
        case .sport:
            ConfirmDialog(store: store, title: "健身房",
                          message: "花费 \(GameData.sportCost) 元恢复健康，确定？") {
                store.sport()
            }
        case .bank:
            NumberDialog(title: "存取款",
                         prompt: "周息 \(Int(GameData.cashInterest * 100))%",
                         inLabel: "存款", outLabel: "取款",
                         onIn: { store.depositToBank($0) },
                         onOut: { store.withdrawFromBank($0) })
        case .alipay:
            NumberDialog(title: "余X宝",
                         prompt: "周息 \(Int(GameData.alimoneyInterest * 100))%",
                         inLabel: "存入", outLabel: "提现",
                         onIn: { store.depositToAlipay($0) },
                         onOut: { store.withdrawFromAlipay($0) })
        case .agency:
            NumberDialog(title: "购买出租屋",
                         prompt: "1 个 / 1 万元，当前 \(store.state.cargoMax) 个",
                         inLabel: "确定", outLabel: nil,
                         onIn: { store.buyAgency($0) },
                         onOut: { _ in false })
        case .lottery:
            LotteryView(store: store)
        case .buy(let item):
            let maxCount = store.maxBuyCount(item.code)
            NumberDialog(title: "买入 \(GameData.cargoName(item.code))",
                         prompt: "单价 \(item.priceCur) 元 · 最多可买 \(maxCount)",
                         inLabel: "买入", outLabel: nil,
                         defaultValue: maxCount,
                         onIn: { store.buyCargo(item.code, count: $0) },
                         onOut: { _ in false })
        case .sell(let item):
            NumberDialog(title: "卖出 \(GameData.cargoName(item.code))",
                         prompt: "现价 \(store.marketPrice(item.code)) 元 · 持有 \(item.num)",
                         inLabel: "卖出", outLabel: nil,
                         defaultValue: item.num,
                         onIn: { store.sellCargo(item.code, count: $0) },
                         onOut: { _ in false })
        }
    }
}

// MARK: - 统一提示框

extension View {
    func storeAlert(_ store: GameStore) -> some View {
        self.alert(store.alert ?? "", isPresented: Binding(
            get: { store.alert != nil },
            set: { if !$0 { store.alert = nil } }
        )) {
            Button("确定", role: .cancel) {}
        }
    }
}
