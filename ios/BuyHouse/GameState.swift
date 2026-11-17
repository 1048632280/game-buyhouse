import Foundation

// MARK: - 存档结构

struct RoomCargo: Codable, Identifiable, Equatable {
    var code: String
    var priceBuy: Int
    var num: Int
    var id: String { code }
}

struct MarketCargo: Codable, Identifiable, Equatable {
    var code: String
    var priceCur: Int
    var id: String { code }
}

struct EventRecord: Codable {
    var week: Int
    var id: String
}

struct SaveData: Codable {
    var week: Int = 0
    var weather: String = "晴天"
    var money: Int = GameData.startMoney
    var cash: Int = 0
    var alimoney: Int = 0
    var health: Int = GameData.startHealth
    var hope: Int = GameData.startHope
    var cargoCur: Int = 0
    var cargoMax: Int = GameData.startCargoMax
    var roomCargos: [RoomCargo] = []
    var markets: [[MarketCargo]] = [[], [], []]
    var marketIndex: Int = 0
    var buildingHouse: [String] = []
    var recentEvents: [EventRecord] = []
    var healthEventLastWeek: Bool = false
}

enum LotteryKind: Int, CaseIterable, Identifiable {
    case low = 1, high = 2, six = 3, odd = 4, even = 5
    var id: Int { rawValue }
    var title: String {
        switch self {
        case .low: return "1~5"
        case .high: return "6~10"
        case .six: return "6"
        case .odd: return "单"
        case .even: return "双"
        }
    }
}

/// 结算数据（只看本局）
struct Settlement {
    let weeks: Int
    let netWorth: Int
    let achievements: [String]   // 本局满足条件的成就描述
    let houses: [String]         // 本局拥有的房产名
}

// MARK: - 游戏状态

final class GameStore: ObservableObject {
    @Published private(set) var state: SaveData
    /// 失败提示，由弹窗就地显示
    @Published var alert: String?
    /// 成功后的结果文案（医院恢复量、彩票开奖），由弹窗就地显示
    @Published var lastResult: String?
    @Published var lastLottery: Int?
    @Published var toast: String?
    @Published var isDead = false
    @Published var settlement: Settlement?
    /// 本周待阅读的事件（报纸叠放）
    @Published var pendingEvents: [ActiveEvent] = []

    private let saveURL: URL

    init() {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        saveURL = dir.appendingPathComponent("buyhouse.json")
        state = Self.load(from: saveURL) ?? SaveData()
        if state.markets.count != GameData.marketCount {
            state.markets = [[], [], []]
        }
        if state.markets.allSatisfy({ $0.isEmpty }) {
            rollAllMarkets()
        }
    }

    // MARK: 存档

    private static func load(from url: URL) -> SaveData? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(SaveData.self, from: data)
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(state) else { return }
        try? data.write(to: saveURL, options: .atomic)
    }

    private func commit() {
        save()
        checkAchievements()
    }

    // MARK: 查询

    var currentMarket: [MarketCargo] {
        let i = state.marketIndex
        guard state.markets.indices.contains(i) else { return [] }
        return state.markets[i]
    }

    func roomNum(_ code: String) -> Int {
        state.roomCargos.first { $0.code == code }?.num ?? 0
    }

    func marketPrice(_ code: String) -> Int {
        currentMarket.first { $0.code == code }?.priceCur ?? 0
    }

    var cargoFree: Int { state.cargoMax - state.cargoCur }

    func maxBuyCount(_ code: String) -> Int {
        let price = marketPrice(code)
        guard price > 0 else { return 0 }
        return max(0, min(state.money / price, cargoFree))
    }

    func maxSellCount(_ code: String) -> Int {
        roomNum(code)
    }

    // MARK: 推进一周

    func tickWeek() {
        rollAllMarkets()

        if state.cash > 0 {
            state.cash += Int(Double(state.cash) * GameData.cashInterest)
        }
        if state.alimoney > 0 {
            state.alimoney += Int(Double(state.alimoney) * GameData.alimoneyInterest)
        }
        state.week += 1
        state.weather = nextWeather(from: state.weather)
        state.health -= Int.random(in: 0..<3)
        if state.health < 0 { state.health = 0 }

        // 本周事件：先结算，再作为报纸叠在市场栏上
        let events = rollEvents()
        applyEvents(events)
        pendingEvents = events
        state.healthEventLastWeek = events.contains { $0.category == .health }
        let horizon = state.week - 3
        state.recentEvents = state.recentEvents.filter { $0.week > horizon }
            + events.map { EventRecord(week: state.week, id: $0.id) }

        commit()
        if state.health == 0 { isDead = true }
    }

    /// 玩家点掉最上面一张报纸
    func dismissEvent() {
        guard !pendingEvents.isEmpty else { return }
        pendingEvents.removeFirst()
    }

    var hasPendingEvents: Bool { !pendingEvents.isEmpty }

    /// 切换市场 = 强制度过一周
    func switchMarket(to index: Int) {
        guard index != state.marketIndex, state.markets.indices.contains(index) else { return }
        state.marketIndex = index
        tickWeek()
    }

    private func rollAllMarkets() {
        var markets: [[MarketCargo]] = []
        for _ in 0..<GameData.marketCount {
            let picked = GameData.cargos.shuffled().prefix(GameData.marketSlots)
            markets.append(picked.map { def in
                MarketCargo(code: def.code, priceCur: Int.random(in: def.minPrice..<def.maxPrice))
            })
        }
        state.markets = markets
        save()
    }

    private func nextWeather(from current: String) -> String {
        guard let def = GameData.weathers.first(where: { $0.name == current }) else {
            return GameData.weathers[0].name
        }
        let total = def.next.reduce(0) { $0 + $1.1 }
        var roll = Int.random(in: 0..<max(total, 1))
        for (name, weight) in def.next {
            if roll < weight { return name }
            roll -= weight
        }
        return def.next.first?.0 ?? "晴天"
    }

    // MARK: - 事件引擎

    private static func rollEventCount() -> Int {
        let r = Int.random(in: 0..<100)
        if r < 35 { return 1 }
        if r < 80 { return 2 }
        return 3
    }

    private func rollEvents() -> [ActiveEvent] {
        let count = Self.rollEventCount()
        var caps: [EventCategory: Int] = [:]
        var used = Set<String>()
        let recent = Set(state.recentEvents.filter { $0.week > state.week - 3 }.map { $0.id })
        var result: [ActiveEvent] = []

        for _ in 0..<count {
            let candidates = EventCategory.allCases.filter { category in
                guard (caps[category] ?? 0) < category.weeklyCap else { return false }
                if category == .health && state.healthEventLastWeek { return false }
                return !EventTable.candidates(category: category,
                                              weather: state.weather,
                                              recent: recent,
                                              used: used).isEmpty
            }
            guard let category = pickCategory(candidates) else { break }
            let pool = EventTable.candidates(category: category,
                                             weather: state.weather,
                                             recent: recent,
                                             used: used)
            guard let template = pickTemplate(pool) else { break }
            caps[category, default: 0] += 1
            used.insert(template.id)
            result.append(resolve(template))
        }
        return result
    }

    private func pickCategory(_ list: [EventCategory]) -> EventCategory? {
        let total = list.reduce(0) { $0 + $1.weight }
        guard total > 0 else { return nil }
        var roll = Int.random(in: 0..<total)
        for c in list {
            if roll < c.weight { return c }
            roll -= c.weight
        }
        return list.last
    }

    private func pickTemplate(_ list: [EventTemplate]) -> EventTemplate? {
        let total = list.reduce(0) { $0 + $1.weight }
        guard total > 0 else { return nil }
        var roll = Int.random(in: 0..<total)
        for t in list {
            if roll < t.weight { return t }
            roll -= t.weight
        }
        return list.last
    }

    private func resolve(_ template: EventTemplate) -> ActiveEvent {
        let randomGood = currentMarket.randomElement()
        let randomName = randomGood.map { GameData.cargoName($0.code) } ?? "货"

        var body = template.body
        body = body.replacingOccurrences(of: "{货}", with: randomName)

        var effects: [ResolvedEffect] = []
        var parts: [String] = []
        var positive = true

        for effect in template.effects {
            switch effect {
            case .cashPct(let p):
                effects.append(.cashPct(p))
                parts.append("现金 \(p >= 0 ? "+" : "−")\(Int((abs(p) * 100).rounded()))%")
                if p < 0 { positive = false }

            case .health(let v):
                effects.append(.health(v))
                parts.append("健康 \(v >= 0 ? "+" : "−")\(abs(v))")
                if v < 0 { positive = false }

            case .hope(let v):
                effects.append(.hope(v))
                parts.append("声望 \(v >= 0 ? "+" : "−")\(abs(v))")
                if v < 0 { positive = false }

            case .marketAll(let range):
                let f = Double.random(in: range)
                effects.append(.market(codes: nil, factor: f))
                parts.append("全场 ×\(String(format: "%.2f", f))")
                if f < 1 { positive = false }

            case .marketRandom(let range):
                guard let good = randomGood else { break }
                let f = Double.random(in: range)
                effects.append(.market(codes: [good.code], factor: f))
                parts.append("\(randomName) ×\(String(format: "%.2f", f))")
                if f < 1 { positive = false }

            case .marketCodes(let codes, let range):
                let f = Double.random(in: range)
                effects.append(.market(codes: codes, factor: f))
                let names = codes.map { GameData.cargoName($0) }.joined(separator: "、")
                parts.append("\(names) ×\(String(format: "%.2f", f))")
                if f < 1 { positive = false }
            }
        }

        return ActiveEvent(id: template.id,
                           category: template.category,
                           headline: template.headline,
                           body: body,
                           summary: parts.isEmpty ? "无变化" : parts.joined(separator: " · "),
                           positive: positive,
                           effects: effects)
    }

    private func applyEvents(_ events: [ActiveEvent]) {
        for event in events {
            for effect in event.effects {
                switch effect {
                case .cashPct(let p):
                    let delta = Int((Double(state.cash) * p).rounded())
                    state.cash = max(0, state.cash + delta)

                case .health(let v):
                    state.health = min(100, max(0, state.health + v))

                case .hope(let v):
                    state.hope = min(100, max(0, state.hope + v))

                case .market(let codes, let factor):
                    let i = state.marketIndex
                    guard state.markets.indices.contains(i) else { continue }
                    for idx in state.markets[i].indices {
                        if let codes, !codes.contains(state.markets[i][idx].code) { continue }
                        let price = Double(state.markets[i][idx].priceCur) * factor
                        state.markets[i][idx].priceCur = max(1, Int(price.rounded()))
                    }
                }
            }
        }
    }

    // MARK: 买卖

    @discardableResult
    func buyCargo(_ code: String, count: Int) -> Bool {
        let price = marketPrice(code)
        guard price > 0, count > 0 else { alert = "输入数额错误！"; return false }
        guard count <= state.money / price else { alert = "现金不足！"; return false }
        guard count <= cargoFree else { alert = "库存不足！"; return false }

        let existed = state.roomCargos.contains { $0.code == code }
        if !existed && state.roomCargos.count >= GameData.roomSlots {
            alert = "货架已满（最多 \(GameData.roomSlots) 种）"
            return false
        }

        if let idx = state.roomCargos.firstIndex(where: { $0.code == code }) {
            state.roomCargos[idx].priceBuy = price
            state.roomCargos[idx].num += count
        } else {
            state.roomCargos.append(RoomCargo(code: code, priceBuy: price, num: count))
        }
        state.money -= count * price
        state.cargoCur += count
        alert = nil
        commit()
        return true
    }

    @discardableResult
    func sellCargo(_ code: String, count: Int) -> Bool {
        let price = marketPrice(code)
        guard price > 0 else { alert = "市场不存在该货物！"; return false }
        guard count > 0, count <= roomNum(code) else { alert = "输入数额错误！"; return false }

        if let idx = state.roomCargos.firstIndex(where: { $0.code == code }) {
            state.roomCargos[idx].num -= count
            if state.roomCargos[idx].num <= 0 {
                state.roomCargos.remove(at: idx)
            }
        }
        state.money += count * price
        state.cargoCur -= count
        alert = nil
        commit()
        return true
    }

    // MARK: 医院 / 健身房

    func hospital() {
        let add: Int
        switch state.health {
        case 80...100: add = Int.random(in: 10...20)
        case 60..<80: add = Int.random(in: 20...40)
        default: add = Int.random(in: 10...50)
        }
        let real = min(add, 100 - state.health)
        state.health += real
        state.money -= GameData.hospitalCost
        commit()
        lastResult = "花费\(GameData.hospitalCost)元，恢复健康\(real)点"
    }

    func sport() {
        let add: Int
        switch state.health {
        case 80...100: add = Int.random(in: 5...10)
        case 60..<80: add = Int.random(in: 3...6)
        default: add = Int.random(in: 0...3)
        }
        let real = min(add, 100 - state.health)
        state.health += real
        state.money -= GameData.sportCost
        commit()
        lastResult = "花费\(GameData.sportCost)元，恢复健康\(real)点"
    }

    // MARK: 银行 / 余X宝

    @discardableResult
    func depositToBank(_ amount: Int) -> Bool {
        guard amount > 0 else { alert = "输入数额错误！"; return false }
        guard amount <= state.money else { alert = "现金不足！"; return false }
        state.money -= amount
        state.cash += amount
        alert = nil
        commit()
        return true
    }

    @discardableResult
    func withdrawFromBank(_ amount: Int) -> Bool {
        guard amount > 0 else { alert = "输入数额错误！"; return false }
        guard amount <= state.cash else { alert = "存款不足！"; return false }
        state.money += amount
        state.cash -= amount
        alert = nil
        commit()
        return true
    }

    @discardableResult
    func depositToAlipay(_ amount: Int) -> Bool {
        guard amount > 0 else { alert = "输入数额错误！"; return false }
        guard amount <= state.money else { alert = "现金不足！"; return false }
        state.money -= amount
        state.alimoney += amount
        alert = nil
        commit()
        return true
    }

    @discardableResult
    func withdrawFromAlipay(_ amount: Int) -> Bool {
        guard amount > 0 else { alert = "输入数额错误！"; return false }
        guard amount <= state.alimoney else { alert = "提现余额不足！"; return false }
        state.money += amount
        state.alimoney -= amount
        alert = nil
        commit()
        return true
    }

    // MARK: 中介

    @discardableResult
    func buyAgency(_ count: Int) -> Bool {
        guard count > 0 else { alert = "输入数额错误！"; return false }
        guard count <= state.money / GameData.agencyUnitPrice else { alert = "现金不足！"; return false }
        state.money -= count * GameData.agencyUnitPrice
        state.cargoMax += count
        alert = nil
        commit()
        return true
    }

    // MARK: 售楼部

    func canBuy(_ b: GameData.BuildingDef) -> Bool {
        !state.buildingHouse.contains(b.name) && state.money >= b.priceWan * 10000
    }

    @discardableResult
    func buyBuilding(_ b: GameData.BuildingDef) -> Bool {
        guard !state.buildingHouse.contains(b.name) else {
            alert = "已经拥有这套房了"
            return false
        }
        guard state.money >= b.priceWan * 10000 else {
            alert = "现金不足！"
            return false
        }
        state.buildingHouse.append(b.name)
        state.money -= b.priceWan * 10000
        state.hope = min(100, state.hope + GameData.buildingHopeGain)
        Progress.shared.addMilestone(b.name)
        alert = nil
        commit()
        return true
    }

    // MARK: 彩票

    @discardableResult
    func lotteryBet(amount: Int, kind: LotteryKind) -> Bool {
        guard amount > 0 else { alert = "输入数额错误！"; return false }
        guard amount <= state.money else { alert = "现金不足！"; return false }
        state.money -= amount

        let prize = Int.random(in: 1...10)
        var payout = 0
        switch kind {
        case .low:   if prize <= 5 { payout = amount * 2 }      // 原版恒真
        case .high:  if prize >= 6 { payout = amount * 2 }      // 原版恒真
        case .six:   if prize == 6 { payout = amount * 10 }
        case .odd:   if prize % 2 == 1 { payout = amount * 2 }
        case .even:  if prize % 2 == 0 { payout = amount * 2 }
        }
        state.money += payout
        lastLottery = prize
        lastResult = payout > 0 ? "开彩 \(prize) · 恭喜获得\(payout)元！" : "开彩 \(prize) · 未中彩~"
        alert = nil
        commit()
        return true
    }

    // MARK: 结束 / 重开

    func finishRun() -> Settlement {
        let s = Settlement(
            weeks: state.week,
            netWorth: state.money + state.cash + state.alimoney,
            achievements: satisfiedAchievements().map { GameData.achievementDesc($0) },
            houses: state.buildingHouse
        )
        settlement = s
        return s
    }

    func restart() {
        state = SaveData()
        rollAllMarkets()
        isDead = false
        lastLottery = nil
        lastResult = nil
        alert = nil
        settlement = nil
        save()
    }

    // MARK: 成就

    func satisfiedAchievements() -> [String] {
        var codes: [String] = []
        let total = state.money + state.cash + state.alimoney

        if total >= 1_000_000 { codes.append("million") }
        if total >= 10_000_000 { codes.append("ten_million") }
        if total >= 100_000_000 { codes.append("hundred_million") }
        if state.cash >= 1_000_000 { codes.append("million_cash") }
        if state.alimoney >= 1_000_000 { codes.append("million_alimoney") }
        if !state.buildingHouse.isEmpty { codes.append("one_house") }
        if state.buildingHouse.contains(where: { ["豪华住宅", "湖景别墅", "泳池私宅"].contains($0) }) {
            codes.append("big_house")
        }
        if state.cargoMax >= 200 { codes.append("hundred_agency") }
        if state.week >= 52 { codes.append("one_year") }
        if state.week >= 156 { codes.append("three_year") }
        if state.hope == 100 { codes.append("hope_full") }
        return codes
    }

    private func checkAchievements() {
        var fresh: [String] = []
        for code in satisfiedAchievements() {
            if Progress.shared.unlock(code) {
                fresh.append(GameData.achievementDesc(code))
            }
        }
        if !fresh.isEmpty {
            toast = fresh.joined(separator: "\n")
        }
    }
}

// MARK: - 金额显示

enum Money {
    static func text(_ value: Int) -> String {
        var s = ""
        let yi = value / 100_000_000
        let wan = value % 100_000_000 / 10_000
        let yuan = value % 10_000
        if yi > 0 { s += "\(yi)亿" }
        if wan > 0 { s += "\(wan)万" }
        s += "\(yuan)元"
        return s
    }
}
