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

/// 结算数据
struct Settlement {
    let weeks: Int
    let achievements: Int
    let totalAchievements: Int
    let houses: Int
    let netWorth: Int
    let milestoneTotal: Int
}

// MARK: - 游戏状态

final class GameStore: ObservableObject {
    @Published private(set) var state: SaveData
    @Published var alert: String?
    @Published var lastLottery: Int?
    @Published var toast: String?
    @Published var isDead = false
    @Published var settlement: Settlement?

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

    // MARK: 推进一周（切市场或结算时调用）

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

        commit()
        if state.health == 0 { isDead = true }
    }

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
                // 原版 randrange(min, max) 不含上界
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

    // MARK: 买卖

    @discardableResult
    func buyCargo(_ code: String, count: Int) -> Bool {
        let price = marketPrice(code)
        guard price > 0, count > 0 else { alert = "输入数额错误！"; return false }
        guard count <= state.money / price else { alert = "现金不足！"; return false }
        guard count <= cargoFree else { alert = "库存不足！"; return false }

        if let idx = state.roomCargos.firstIndex(where: { $0.code == code }) {
            state.roomCargos[idx].priceBuy = price
            state.roomCargos[idx].num += count
        } else {
            state.roomCargos.append(RoomCargo(code: code, priceBuy: price, num: count))
        }
        state.money -= count * price
        state.cargoCur += count
        commit()
        alert = "购买成功！"
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
        commit()
        alert = "卖出成功！"
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
        alert = "花费\(GameData.hospitalCost)元，恢复健康\(real)点"
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
        alert = "花费\(GameData.sportCost)元，恢复健康\(real)点"
    }

    // MARK: 银行 / 余X宝

    @discardableResult
    func depositToBank(_ amount: Int) -> Bool {
        guard amount > 0 else { alert = "输入数额错误！"; return false }
        guard amount <= state.money else { alert = "现金不足！"; return false }
        state.money -= amount
        state.cash += amount
        commit()
        alert = "存款成功！"
        return true
    }

    @discardableResult
    func withdrawFromBank(_ amount: Int) -> Bool {
        guard amount > 0 else { alert = "输入数额错误！"; return false }
        guard amount <= state.cash else { alert = "存款不足！"; return false }
        state.money += amount
        state.cash -= amount
        commit()
        alert = "取款成功！"
        return true
    }

    @discardableResult
    func depositToAlipay(_ amount: Int) -> Bool {
        guard amount > 0 else { alert = "输入数额错误！"; return false }
        guard amount <= state.money else { alert = "现金不足！"; return false }
        state.money -= amount
        state.alimoney += amount
        commit()
        alert = "存入成功！"
        return true
    }

    @discardableResult
    func withdrawFromAlipay(_ amount: Int) -> Bool {
        guard amount > 0 else { alert = "输入数额错误！"; return false }
        guard amount <= state.alimoney else { alert = "提现余额不足！"; return false }
        state.money += amount
        state.alimoney -= amount
        commit()
        alert = "提现成功！"
        return true
    }

    // MARK: 中介

    @discardableResult
    func buyAgency(_ count: Int) -> Bool {
        guard count > 0 else { alert = "输入数额错误！"; return false }
        guard count <= state.money / GameData.agencyUnitPrice else { alert = "现金不足！"; return false }
        state.money -= count * GameData.agencyUnitPrice
        state.cargoMax += count
        commit()
        alert = "购买成功！"
        return true
    }

    // MARK: 售楼部

    func canBuy(_ b: GameData.BuildingDef) -> Bool {
        !state.buildingHouse.contains(b.name) && state.money >= b.priceWan * 10000
    }

    @discardableResult
    func buyBuilding(_ b: GameData.BuildingDef) -> Bool {
        guard state.money >= b.priceWan * 10000 else { alert = "现金不足！"; return false }
        state.buildingHouse.append(b.name)
        state.money -= b.priceWan * 10000
        state.hope = min(100, state.hope + GameData.buildingHopeGain)
        Progress.shared.addMilestone(b.name)
        commit()
        alert = "购买成功！"
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
        commit()
        alert = payout > 0 ? "恭喜获得\(payout)元！" : "未中彩~"
        return true
    }

    // MARK: 结束 / 重开

    /// 结算当前存档
    func finishRun() -> Settlement {
        let s = Settlement(
            weeks: state.week,
            achievements: satisfiedAchievements().count,
            totalAchievements: GameData.achievements.count,
            houses: state.buildingHouse.count,
            netWorth: state.money + state.cash + state.alimoney,
            milestoneTotal: Progress.shared.totalMilestones
        )
        settlement = s
        return s
    }

    func restart() {
        state = SaveData()
        rollAllMarkets()
        isDead = false
        lastLottery = nil
        settlement = nil
        alert = "已重新开始"
        save()
    }

    // MARK: 成就（全局永久，但结算按当前存档是否满足条件计数）

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
