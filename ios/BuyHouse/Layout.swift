import UIKit

/// 自适应布局常量：按屏幕宽度收敛间距，按屏幕高度切换紧凑模式
enum Layout {
    static var screenSize: CGSize {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        return scenes.first?.screen.bounds.size ?? UIScreen.main.bounds.size
    }

    static var screenWidth: CGFloat { screenSize.width }
    static var screenHeight: CGFloat { screenSize.height }

    /// 窄屏（SE 一代、mini 竖屏）
    static var isCompact: Bool { screenWidth < 360 }
    /// 矮屏（SE 一代 568、8/SE2 667）
    static var isShort: Bool { screenHeight < 700 }

    static var hPad: CGFloat { isCompact ? 8 : 10 }

    static var contentWidth: CGFloat { screenWidth - hPad * 2 }

    /// 面板之间的竖向间距
    static var panelGap: CGFloat { isShort ? 8 : 10 }

    /// 四列按钮的列间距
    static var gridGap: CGFloat { isCompact ? 6 : 8 }

    /// 列表行高
    static var rowHeight: CGFloat { isShort ? 36 : 42 }

    /// 操作区按钮高度
    static var actionHeight: CGFloat { isShort ? 32 : 40 }

    /// 出租屋 / 市场两栏的最小高度：正好装下 5 行
    static var tradeListHeight: CGFloat {
        rowHeight * CGFloat(GameData.roomSlots) + CGFloat(GameData.roomSlots - 1) + 30
    }

    static var statsLabelWidth: CGFloat { 46 }

    static var barWidth: CGFloat { isCompact ? 56 : 66 }
}
