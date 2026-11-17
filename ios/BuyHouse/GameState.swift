import Foundation

// MARK: - 存档结构（对应 buyhouse.data 的字段）

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

struct SaveData: Codable, Equatable {
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
    var marketCargos: [MarketCargo] = []
    var buildingHouse: [String] = []
    var archivePerson: [String] = []
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

// MARK: - 游戏状态

final class GameStore: ObservableObject {
    @Published private(set) var state: SaveData
    @Published var alert: String?
    @Published var lastLottery: Int?
    @Published var toast: String?
    @Published var isDead = false

    private let saveURL: URL

    init() {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        saveURL = dir.appendingPathComponent("buyhouse.json")
        state = Self.load(from: saveURL) ?? SaveData()
        if state.marketCargos.isEmpty { rollMarket() }
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

    func roomNum(_ code: String) -> Int {
        state.roomCargos.first { $0.code == code }?.num ?? 0
    }

    func marketPrice(_ code: String) -> Int {
        state.marketCargos.first { $0.code == code }?.priceCur ?? 0
    }

    var cargoFree: Int { state.cargoMax - state.cargoCur }

    /// 受现金与舱位约束的最大可买数量
    func maxBuyCount(_ code: String) -> Int {
        let price = marketPrice(code)
        guard price > 0 else { return 0 }
        return max(0, min(state.money / price, cargoFree))
    }

    /// 最大可卖数量
    func maxSellCount(_ code: String) -> Int {
        roomNum(code)
    }

    // MARK: 一周（原 click_market1）

    func tickWeek() {
        rollMarket()
        // 利息
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

    private func rollMarket() {
        let picked = GameData.cargos.shuffled().prefix(5)
        state.marketCargos = picked.map { def in
            // 原版 randrange(min, max) 不含上界
            MarketCargo(code: def.code, priceCur: Int.random(in: def.minPrice..<def.maxPrice))
        }
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

    // MARK: 买卖（原 click_market_buy / click_room_sell）

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

    // MARK: 医院 / 健身房（原版不检查现金，可透支）

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

    // MARK: 中介（买出租屋位置）

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
        commit()
        alert = "购买成功！"
        return true
    }

    // MARK: 彩票（原版 1~5 / 6~10 的判定恒真，先保真保留）

    @discardableResult
    func lotteryBet(amount: Int, kind: LotteryKind) -> Bool {
        guard amount > 0 else { alert = "输入数额错误！"; return false }
        guard amount <= state.money else { alert = "现金不足！"; return false }
        state.money -= amount

        let prize = Int.random(in: 1...10)
        var payout = 0
        switch kind {
        case .low:   if prize <= 5 { payout = amount * 2 }          // 原版恒真
        case .high:  if prize >= 6 { payout = amount * 2 }          // 原版恒真
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

    // MARK: 重新开始

    func restart() {
        state = SaveData()
        rollMarket()
        isDead = false
        lastLottery = nil
        alert = "重置成功！"
        save()
    }

    // MARK: 成就

    private func checkAchievements() {
        var unlocked: [String] = []
        let total = state.money + state.cash + state.alimoney

        func unlock(_ code: String) {
            guard !state.archivePerson.contains(code) else { return }
            state.archivePerson.append(code)
            unlocked.append(GameData.achievementDesc(code))
        }

        if total >= 1_000_000 { unlock("million") }
        if total >= 10_000_000 { unlock("ten_million") }
        if total >= 100_000_000 { unlock("hundred_million") }
        if state.cash >= 1_000_000 { unlock("million_cash") }
        if state.alimoney >= 1_000_000 { unlock("million_alimoney") }
        if !state.buildingHouse.isEmpty { unlock("one_house") }
        if state.buildingHouse.contains(where: { ["豪华住宅", "湖景别墅", "泳池私宅"].contains($0) }) {
            unlock("big_house")
        }
        if state.cargoMax >= 200 { unlock("hundred_agency") }
        if state.week >= 52 { unlock("one_year") }
        if state.week >= 156 { unlock("three_year") }
        if state.hope == 100 { unlock("hope_full") }

        if !unlocked.isEmpty {
            save()
            toast = unlocked.joined(separator: "\n")
        }
    }
}

// MARK: - 金额显示（照搬 MoneyFormat）

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

