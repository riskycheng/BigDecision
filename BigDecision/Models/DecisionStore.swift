import Foundation
import SwiftUI

class DecisionStore: ObservableObject {
    @Published private(set) var decisions: [Decision] = []
    private let saveKey = "savedDecisions"
    
    init() {
        loadDecisions()
    }
    
    func addDecision(_ decision: Decision) {
        decisions.append(decision)
        saveDecisions()
    }
    
    func updateDecision(_ decision: Decision) {
        if let index = decisions.firstIndex(where: { $0.id == decision.id }) {
            decisions[index] = decision
            saveDecisions()
        }
    }
    
    func deleteDecision(_ decision: Decision) {
        decisions.removeAll { $0.id == decision.id }
        saveDecisions()
    }
    
    func toggleFavorite(_ decision: Decision) {
        if let index = decisions.firstIndex(where: { $0.id == decision.id }) {
            var updatedDecision = decision
            updatedDecision.isFavorited.toggle()
            decisions[index] = updatedDecision
            saveDecisions()
        }
    }
    
    var favoriteDecisions: [Decision] {
        decisions.filter { $0.isFavorited }
    }
    
    private func saveDecisions() {
        if let encoded = try? JSONEncoder().encode(decisions) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadDecisions() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Decision].self, from: data) {
            decisions = decoded
        }
    }
    
    // 统计相关方法
    func decisionsCount(for type: Decision.DecisionType) -> Int {
        decisions.filter { $0.decisionType == type }.count
    }
    
    func averageConfidence() -> Double {
        let confidences = decisions.compactMap { $0.result?.confidence }
        return confidences.isEmpty ? 0 : confidences.reduce(0, +) / Double(confidences.count)
    }
    
    func decisionsInTimeRange(_ range: DateInterval) -> [Decision] {
        decisions.filter { range.contains($0.createdAt) }
    }
    
    func decisionsGroupedByType() -> [(type: Decision.DecisionType, count: Int)] {
        var groupedDecisions: [Decision.DecisionType: Int] = [:]
        Decision.DecisionType.allCases.forEach { groupedDecisions[$0] = 0 }
        
        decisions.forEach { decision in
            groupedDecisions[decision.decisionType, default: 0] += 1
        }
        
        return groupedDecisions.sorted { $0.value > $1.value }
            .map { (type: $0.key, count: $0.value) }
    }
}

extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
} 