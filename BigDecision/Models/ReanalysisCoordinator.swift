import Foundation
import SwiftUI

// Global coordinator for reanalysis
class ReanalysisCoordinator: ObservableObject {
    static let shared = ReanalysisCoordinator()
    
    @Published var isShowingReanalysis = false
    @Published var decisionToReanalyze: Decision? = nil
    
    private init() {}
    
    func startReanalysis(with decision: Decision) {
        // 创建一个新的决策对象，保留原始决策的所有信息（包括 ID），但清除结果
        self.decisionToReanalyze = Decision(
            id: decision.id, // 保留原始决策的 ID
            title: decision.title,
            options: decision.options,
            additionalInfo: decision.additionalInfo,
            decisionType: decision.decisionType,
            importance: decision.importance,
            timeFrame: decision.timeFrame,
            result: nil,
            createdAt: decision.createdAt, // 保留原始创建时间
            isFavorited: decision.isFavorited // 保留收藏状态
        )
        
        // 短暂延迟以确保动画流畅
        // 这个延迟允许当前视图先完全关闭，然后再显示重新分析视图
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isShowingReanalysis = true
        }
    }
    
    func endReanalysis() {
        // 首先将isShowingReanalysis设置为false，这会导致sheet关闭
        isShowingReanalysis = false
        
        // 短暂延迟后清除决策数据，确保视图已完全关闭
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.decisionToReanalyze = nil
        }
    }
}
