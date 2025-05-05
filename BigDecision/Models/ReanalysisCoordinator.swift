import Foundation
import SwiftUI

// Global coordinator for reanalysis
class ReanalysisCoordinator: ObservableObject {
    static let shared = ReanalysisCoordinator()
    
    @Published var isShowingReanalysis = false
    @Published var decisionToReanalyze: Decision? = nil
    @Published var originalDecisionId: UUID? = nil // 存储原始决策的ID，用于更新
    private var isProcessing = false
    private var workItem: DispatchWorkItem? = nil
    
    private init() {}
    
    func startReanalysis(with decision: Decision) {
        print("Starting reanalysis for decision: \(decision.id)")
        
        // 取消任何正在进行的工作项
        cancelPendingOperations()
        
        // 防止重复触发
        guard !isProcessing else {
            print("Reanalysis already in progress, ignoring request")
            return 
        }
        
        // 设置处理中状态
        isProcessing = true
        
        // 完全重置状态
        resetState()
        
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
        
        // 创建一个新的工作项
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            // 设置新的决策
            self.decisionToReanalyze = reanalysisDecision
            
            // 触发重新分析视图显示
            print("Setting isShowingReanalysis to true")
            self.isShowingReanalysis = true
            
            // 完成处理
            self.isProcessing = false
        }
        
        // 保存工作项引用
        self.workItem = workItem
        
        // 延迟执行工作项，确保动画流畅
        // 这个延迟允许当前视图先完全关闭，然后再显示重新分析视图
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }
    
    func endReanalysis() {
        print("Ending reanalysis")
        
        // 取消任何正在进行的工作项
        cancelPendingOperations()
        
        // 首先将isShowingReanalysis设置为false，这会导致sheet关闭
        isShowingReanalysis = false
        
        // 立即重置处理状态，确保可以立即开始新的重新分析
        isProcessing = false
        
        // 创建一个新的工作项来清理状态
        let cleanupWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            print("Clearing reanalysis state")
            self.resetState()
        }
        
        // 短暂延迟后清除决策数据，确保视图已完全关闭
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: cleanupWorkItem)
    }
    
    // 重置所有状态
    private func resetState() {
        self.decisionToReanalyze = nil
        self.originalDecisionId = nil
        self.isShowingReanalysis = false
    }
    
    // 取消所有正在进行的操作
    private func cancelPendingOperations() {
        workItem?.cancel()
        workItem = nil
    }
    
    // 检查当前是否是重新分析模式
    var isReanalyzing: Bool {
        return originalDecisionId != nil
    }
}
