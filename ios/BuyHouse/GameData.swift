import Foundation

/// 全部数值表，直接对应 cargo.py / weather.py / data.py
enum GameData {

    // MARK: - 全局参数（data.py Person 类属性）
    static let cashInterest = 0.01
    static let alimoneyInterest = 0.05
    static let startMoney = 3000
    static let startHealth = 100
    static let startHope = 80
    static let startCargoMax = 100
    static let hospitalCost = 100
    static let sportCost = 10
    static let agencyUnitPrice = 10000   // 中介：1 个出租屋 1 万
    static let buildingHopeGain = 5

    // MARK: - 货物（cargo.py）
    struct CargoDef {
        let code: String
        let name: String
        let minPrice: Int
        let maxPrice: Int
        var asset: String { "item_\(code)" }
    }

    static let cargos: [CargoDef] = [
        .init(code: "beans", name: "转基因大豆", minPrice: 6, maxPrice: 50),
        .init(code: "mask", name: "防毒面具", minPrice: 40, maxPrice: 480),
        .init(code: "milk", name: "奶粉", minPrice: 100, maxPrice: 500),
        .init(code: "gold", name: "黄金", minPrice: 220, maxPrice: 1880),
        .init(code: "phone", name: "手机", minPrice: 999, maxPrice: 8800),
        .init(code: "computer", name: "电脑", minPrice: 2300, maxPrice: 12000),
        .init(code: "moterbike", name: "摩托车", minPrice: 4800, maxPrice: 22000),
        .init(code: "car", name: "汽车", minPrice: 20000, maxPrice: 120000),
    ]

    static func cargo(_ code: String) -> CargoDef? {
        cargos.first { $0.code == code }
    }

    static func cargoName(_ code: String) -> String {
        cargo(code)?.name ?? ""
    }

    // MARK: - 房屋（data.py buildings）
    struct BuildingDef {
        let name: String
        let area: Int
        let priceWan: Int      // 单位：万
        let asset: String
    }

    static let buildings: [BuildingDef] = [
        .init(name: "单身公寓", area: 30, priceWan: 40, asset: "house_studio"),
        .init(name: "二手旧房", area: 80, priceWan: 120, asset: "house_oldhouse"),
        .init(name: "高档小区", area: 108, priceWan: 180, asset: "house_uptown"),
        .init(name: "豪华住宅", area: 180, priceWan: 300, asset: "house_luxury"),
        .init(name: "湖景别墅", area: 320, priceWan: 600, asset: "house_lakevilla"),
        .init(name: "泳池私宅", area: 450, priceWan: 1200, asset: "house_poolvilla"),
        .init(name: "一栋小区", area: 1512, priceWan: 2500, asset: "house_complex"),
        .init(name: "一个楼盘", area: 24192, priceWan: 4000, asset: "house_estate"),
    ]

    // MARK: - 成就（data.py archives）
    struct AchievementDef: Identifiable {
        let code: String
        let desc: String
        var id: String { code }
    }

    static let achievements: [AchievementDef] = [
        .init(code: "million", desc: "身家百万"),
        .init(code: "ten_million", desc: "身家千万"),
        .init(code: "hundred_million", desc: "身家过亿"),
        .init(code: "million_cash", desc: "银行存款100万"),
        .init(code: "million_alimoney", desc: "余X宝存款100万"),
        .init(code: "one_house", desc: "拥有一所房屋"),
        .init(code: "big_house", desc: "拥有一所豪宅"),
        .init(code: "hundred_agency", desc: "购买租房100个"),
        .init(code: "one_year", desc: "度过1年(52周)"),
        .init(code: "three_year", desc: "度过3年(156周)"),
        .init(code: "hope_full", desc: "声望出名"),
    ]

    static func achievementDesc(_ code: String) -> String {
        achievements.first { $0.code == code }?.desc ?? ""
    }

    // MARK: - 天气转移（weather.py）
    struct WeatherDef {
        let name: String
        let next: [(String, Int)]
    }

    static let weathers: [WeatherDef] = [
        .init(name: "晴天", next: [("晴天", 500), ("多云", 200), ("阴天", 100), ("沙尘", 10),
                                  ("雷阵雨", 100), ("小雨", 88), ("雨加雪", 1), ("小雪", 1)]),
        .init(name: "多云", next: [("晴天", 300), ("多云", 300), ("阴天", 200), ("沙尘", 10),
                                  ("雷阵雨", 100), ("小雨", 88), ("雨加雪", 1), ("小雪", 1)]),
        .init(name: "阴天", next: [("晴天", 200), ("多云", 200), ("阴天", 200), ("沙尘", 10),
                                  ("雷阵雨", 200), ("小雨", 170), ("雨加雪", 10), ("小雪", 10)]),
        .init(name: "沙尘", next: [("晴天", 300), ("多云", 300), ("阴天", 200), ("沙尘", 10),
                                ("雷阵雨", 100), ("小雨", 88), ("雨加雪", 1), ("小雪", 1)]),
        .init(name: "雷阵雨", next: [("晴天", 100), ("多云", 150), ("阴天", 150), ("沙尘", 10),
                                    ("雷阵雨", 200), ("小雨", 270), ("中雨", 100),
                                    ("雨加雪", 10), ("小雪", 10)]),
        .init(name: "小雨", next: [("晴天", 100), ("多云", 100), ("阴天", 200), ("沙尘", 10),
                                  ("雷阵雨", 200), ("小雨", 170), ("中雨", 200),
                                  ("雨加雪", 10), ("小雪", 10)]),
        .init(name: "中雨", next: [("晴天", 100), ("多云", 100), ("阴天", 100), ("雷阵雨", 100),
                                  ("小雨", 100), ("中雨", 200), ("大雨", 200), ("暴雨", 100)]),
        .init(name: "大雨", next: [("晴天", 50), ("多云", 50), ("阴天", 100), ("雷阵雨", 100),
                                  ("小雨", 100), ("中雨", 200), ("大雨", 200), ("暴雨", 200)]),
        .init(name: "暴雨", next: [("晴天", 50), ("多云", 50), ("阴天", 100), ("雷阵雨", 100),
                                  ("小雨", 100), ("中雨", 200), ("大雨", 200), ("暴雨", 200)]),
        .init(name: "雨加雪", next: [("晴天", 100), ("多云", 100), ("阴天", 100), ("小雨", 200),
                                    ("雨加雪", 200), ("小雪", 200), ("中雪", 100)]),
        .init(name: "小雪", next: [("晴天", 100), ("多云", 100), ("阴天", 100), ("小雨", 50),
                                  ("雨加雪", 100), ("小雪", 250), ("中雪", 300)]),
        .init(name: "中雪", next: [("晴天", 50), ("多云", 50), ("阴天", 50), ("小雪", 250),
                                  ("中雪", 300), ("大雪", 200), ("暴雪", 100)]),
        .init(name: "大雪", next: [("晴天", 50), ("多云", 50), ("阴天", 50), ("小雪", 150),
                                  ("中雪", 300), ("大雪", 300), ("暴雪", 100)]),
        .init(name: "暴雪", next: [("晴天", 50), ("多云", 50), ("阴天", 50), ("小雪", 150),
                                  ("中雪", 200), ("大雪", 300), ("暴雪", 200)]),
    ]

    /// 天气名 -> 素材名
    static let weatherAssets: [String: String] = [
        "晴天": "weather_sunny", "多云": "weather_partly_cloudy", "阴天": "weather_overcast",
        "沙尘": "weather_fog", "雷阵雨": "weather_thunderstorm", "小雨": "weather_light_rain",
        "中雨": "weather_moderate_rain", "大雨": "weather_heavy_rain",
        "暴雨": "weather_rainstorm", "雨加雪": "weather_sleet", "小雪": "weather_light_snow",
        "中雪": "weather_moderate_snow", "大雪": "weather_heavy_snow", "暴雪": "weather_blizzard",
    ]

    static func weatherAsset(_ name: String) -> String {
        weatherAssets[name] ?? "weather_sunny"
    }
}

