import Foundation

// MARK: - 事件分类

enum EventCategory: String, CaseIterable {
    case money, market, reputation, weather, health

    /// 抽取时的类别权重（行情类明显高于其他）
    var weight: Int {
        switch self {
        case .market: return 50
        case .money: return 18
        case .reputation: return 12
        case .weather: return 10
        case .health: return 10
        }
    }

    /// 一周内最多出现几条
    var weeklyCap: Int {
        switch self {
        case .money: return 2
        case .market: return 1
        case .reputation: return 2
        case .weather: return 1
        case .health: return 1
        }
    }
}

// MARK: - 事件模板

enum TemplateEffect {
    case cashPct(Double)                       // 现金百分比
    case health(Int)
    case hope(Int)
    case marketAll(ClosedRange<Double>)        // 当前市场全部货物
    case marketRandom(ClosedRange<Double>)     // 当前市场随机一种
    case marketCodes([String], ClosedRange<Double>)
}

struct EventTemplate: Identifiable {
    let id: String
    let category: EventCategory
    let headline: String
    let body: String
    let weight: Int
    let effects: [TemplateEffect]

    init(_ id: String, _ category: EventCategory, _ headline: String, _ body: String,
         weight: Int, effects: [TemplateEffect]) {
        self.id = id
        self.category = category
        self.headline = headline
        self.body = body
        self.weight = weight
        self.effects = effects
    }
}

// MARK: - 已结算的事件

enum ResolvedEffect {
    case cashPct(Double)
    case health(Int)
    case hope(Int)
    case market(codes: [String]?, factor: Double)
}

struct ActiveEvent: Identifiable {
    let id: String
    let category: EventCategory
    let headline: String
    let body: String
    let summary: String
    let positive: Bool
    let effects: [ResolvedEffect]
}

// MARK: - 事件表

enum EventTable {

    static let templates: [EventTemplate] = [

        // 财产：5% ~ 15%，只按现金结算
        .init("e_rent", .money, "房租分红到账",
              "上个季度的租金一次结清，房东直接把钱转了过来。",
              weight: 30, effects: [.cashPct(0.08)]),
        .init("e_oldstuff", .money, "旧货卖了个好价",
              "收拾屋子翻出几件旧东西，挂到网上居然被人抢着要。",
              weight: 25, effects: [.cashPct(0.05)]),
        .init("e_pipe", .money, "水管爆裂大修",
              "半夜厨房水管炸了，楼下邻居家的天花板跟着遭殃，赔了一笔。",
              weight: 20, effects: [.cashPct(-0.09)]),
        .init("e_smallprize", .money, "中了个小奖",
              "超市抽奖随手一刮，居然中了个不大不小的奖。",
              weight: 15, effects: [.cashPct(0.12)]),
        .init("e_scam", .money, "电信诈骗",
              "一个自称客服的电话，把卡里的钱划走了一大笔。",
              weight: 10, effects: [.cashPct(-0.15)]),

        // 行情
        .init("e_rush", .market, "抢购潮",
              "{货}被抢购一空，摊主连夜改价，第二天价格翻着跟头往上涨。",
              weight: 40, effects: [.marketRandom(1.40...1.80)]),
        .init("e_dull", .market, "无人问津",
              "{货}摊前一个人都没有，老板蹲在货堆后面抽烟，挂牌甩卖。",
              weight: 40, effects: [.marketRandom(0.40...0.60)]),
        .init("e_tariff", .market, "进口关税上调",
              "海关新规落地，进口货一夜之间贵了大截。",
              weight: 20, effects: [.marketCodes(["phone", "computer"], 1.20...1.50)]),

        // 声望
        .init("e_praise", .reputation, "社区表彰",
              "居委会把你的事迹写上了公告栏，路过的人都多看你两眼。",
              weight: 30, effects: [.hope(7)]),
        .init("e_complain", .reputation, "邻居投诉",
              "楼下邻居嫌你半夜搬东西，一路投诉到了物业。",
              weight: 30, effects: [.hope(-5)]),
        .init("e_donate", .reputation, "给灾区捐款",
              "新闻里灾情不轻，你顺手捐了一笔。",
              weight: 20, effects: [.cashPct(-0.05), .hope(9)]),
        .init("e_tv", .reputation, "上了本地电视",
              "本地台来小区采访，镜头正好扫到你。",
              weight: 20, effects: [.hope(12)]),

        // 健康（一周最多一条，且不会连续两周）
        .init("e_cold", .health, "感冒了",
              "换季没添衣服，鼻涕流了一整天。",
              weight: 30, effects: [.health(-7)]),
        .init("e_checkup", .health, "去医院体检",
              "例行体检，医生说你各项指标还算稳。",
              weight: 25, effects: [.health(10), .cashPct(-0.05)]),
        .init("e_insomnia", .health, "失眠",
              "楼下装修到半夜，翻来覆去睡不着。",
              weight: 25, effects: [.health(-4), .hope(-2)]),
        .init("e_fit", .health, "健身有成效",
              "坚持锻炼了一阵子，爬楼梯不喘了。",
              weight: 20, effects: [.health(6)]),

        // 天气（按当周天气唯一命中）
        .init("w_rain", .weather, "连日暴雨",
              "雨下个不停，菜市场里人挤人，菜价一天一个样。",
              weight: 0, effects: [.marketAll(1.15...1.25), .health(-2)]),
        .init("w_drizzle", .weather, "阴雨绵绵",
              "细雨下了好几天，街上湿漉漉的，没几个人愿意出门。",
              weight: 0, effects: [.marketAll(0.90...1.00), .hope(-1)]),
        .init("w_snow", .weather, "大雪封路",
              "路滑得没人愿意出门，街上冷冷清清。",
              weight: 0, effects: [.marketAll(0.85...0.95), .health(-2)]),
        .init("w_fog", .weather, "能见度很低",
              "雾大得看不清对面的楼，街上没几个人。",
              weight: 0, effects: [.marketAll(0.85...0.95), .hope(-1)]),
        .init("w_sun", .weather, "周末人潮",
              "天放晴了，街上全是出来逛的人。",
              weight: 0, effects: [.marketAll(1.05...1.15), .hope(2)]),
        .init("w_plain", .weather, "天色阴沉",
              "没什么特别的，日子照旧。",
              weight: 0, effects: []),
    ]

    private static let byID: [String: EventTemplate] = Dictionary(
        uniqueKeysWithValues: templates.map { ($0.id, $0) }
    )

    /// 天气 -> 唯一事件
    static func weatherEventID(for weather: String) -> String {
        switch weather {
        case "雷阵雨", "大雨", "暴雨": return "w_rain"
        case "小雨", "中雨", "雨加雪": return "w_drizzle"
        case "小雪", "中雪", "大雪", "暴雪": return "w_snow"
        case "雾", "沙尘": return "w_fog"
        case "晴天", "多云": return "w_sun"
        default: return "w_plain"
        }
    }

    static func template(_ id: String) -> EventTemplate? { byID[id] }

    static func candidates(category: EventCategory,
                           weather: String,
                           recent: Set<String>,
                           used: Set<String>) -> [EventTemplate] {
        if category == .weather {
            let id = weatherEventID(for: weather)
            guard !recent.contains(id), !used.contains(id), let t = byID[id] else { return [] }
            return [t]
        }
        return templates.filter {
            $0.category == category && $0.weight > 0
                && !recent.contains($0.id)
                && !used.contains($0.id)
        }
    }
}
