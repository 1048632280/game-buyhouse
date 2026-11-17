import UIKit

/// 自适应布局常量：按屏幕宽度收敛间距与控件尺寸
enum Layout {
    static var screenWidth: CGFloat {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        return scenes.first?.screen.bounds.width ?? UIScreen.main.bounds.width
    }

    static var isCompact: Bool { screenWidth < 360 }

    static var hPad: CGFloat { isCompact ? 8 : 10 }

    static var contentWidth: CGFloat { screenWidth - hPad * 2 }

    static var gridGap: CGFloat { isCompact ? 6 : 8 }

    /// 4 列按钮的单元宽度
    static var cell4: CGFloat { (contentWidth - 24 - gridGap * 3) / 4 }

    static var statsLabelWidth: CGFloat { 46 }

    static var barWidth: CGFloat { isCompact ? 56 : 66 }

    static var iconScale: CGFloat { isCompact ? 1.5 : 2 }

    /// 出租屋 / 市场两栏的最小高度，保证左右等高的观感
    static var tradeMinHeight: CGFloat { isCompact ? 262 : 280 }
}
