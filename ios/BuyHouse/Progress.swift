import Foundation

/// 跨存档的永久数据：成就解锁状态、里程碑计数
final class Progress: ObservableObject {
    static let shared = Progress()

    private enum Keys {
        static let achievements = "bh.progress.achievements"
        static let milestones = "bh.progress.milestones"
    }

    private let defaults = UserDefaults.standard

    @Published private(set) var achievements: Set<String> = []
    @Published private(set) var milestones: [String: Int] = [:]

    private init() {
        if let list = defaults.array(forKey: Keys.achievements) as? [String] {
            achievements = Set(list)
        }
        if let map = defaults.dictionary(forKey: Keys.milestones) as? [String: Int] {
            milestones = map
        }
    }

    // MARK: - 成就

    @discardableResult
    func unlock(_ code: String) -> Bool {
        guard !achievements.contains(code) else { return false }
        achievements.insert(code)
        defaults.set(Array(achievements).sorted(), forKey: Keys.achievements)
        return true
    }

    func isUnlocked(_ code: String) -> Bool {
        achievements.contains(code)
    }

    var unlockedCount: Int { achievements.count }

    // MARK: - 里程碑：每间房子累计购买次数

    func addMilestone(_ building: String) {
        milestones[building, default: 0] += 1
        defaults.set(milestones, forKey: Keys.milestones)
    }

    func milestoneCount(_ building: String) -> Int {
        milestones[building] ?? 0
    }

    var totalMilestones: Int {
        milestones.values.reduce(0, +)
    }

    // MARK: - 清空（调试用）

    func resetAll() {
        achievements = []
        milestones = [:]
        defaults.removeObject(forKey: Keys.achievements)
        defaults.removeObject(forKey: Keys.milestones)
    }
}
