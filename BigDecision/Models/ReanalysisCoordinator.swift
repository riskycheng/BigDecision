import Foundation
import SwiftUI

// Global coordinator for reanalysis
class ReanalysisCoordinator: ObservableObject {
    static let shared = ReanalysisCoordinator()
    
    @Published var isShowingReanalysis = false
    @Published var decisionToReanalyze: Decision? = nil
    @Published var originalDecisionId: UUID? = nil // 存储原始决策的ID，用于更新
    private var isProcessing = false
    
    private init() {}
    
    func startReanalysis(with decision: Decision) {
        print("Starting reanalysis for decision: \(decision.id)")
        
        // 防止重复触发
        guard !isProcessing else {
            print("Reanalysis already in progress, ignoring request")
            return 
        }
        isProcessing = true
        
        // 保存原始决策ID，用于后续更新
        self.originalDecisionId = decision.id
        
        // 创建一个新的决策对象，保留原始决策的所有信息（包括 ID），但清除结果
        let reanalysisDecision = Decision(
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
        
        // 先完全重置状态，然后设置新的决策
        self.decisionToReanalyze = nil
        self.isShowingReanalysis = false
        
        // 等待一个帧，确保状态已重置
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 然后设置新的决策并触发重新分析
            self.decisionToReanalyze = reanalysisDecision
            
            // 短暂延迟以确保动画流畅
            // 这个延迟允许当前视图先完全关闭，然后再显示重新分析视图
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                guard let self = self else { return }
                print("Setting isShowingReanalysis to true")
                self.isShowingReanalysis = true
                self.isProcessing = false
            }
        }
    }
    
    func endReanalysis() {
        print("Ending reanalysis")
        
        // 首先将isShowingReanalysis设置为false，这会导致sheet关闭
        isShowingReanalysis = false
        
        // 立即重置处理状态，确保可以立即开始新的重新分析
        isProcessing = false
        
        // 短暂延迟后清除决策数据，确保视图已完全关闭
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            print("Clearing decisionToReanalyze and originalDecisionId")
            self.decisionToReanalyze = nil
            self.originalDecisionId = nil
        }
    }
    
    // 检查当前是否是重新分析模式
    var isReanalyzing: Bool {
        return originalDecisionId != nil
    }
}
