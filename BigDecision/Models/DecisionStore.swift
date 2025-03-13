import Foundation
import SwiftUI

class DecisionStore: ObservableObject {
    @Published var decisions: [Decision] = []
    
    private let savePath = FileManager.documentsDirectory.appendingPathComponent("SavedDecisions")
    
    init() {
        loadDecisions()
    }
    
    func loadDecisions() {
        do {
            let data = try Data(contentsOf: savePath)
            decisions = try JSONDecoder().decode([Decision].self, from: data)
        } catch {
            decisions = []
        }
    }
    
    func saveDecisions() {
        do {
            let data = try JSONEncoder().encode(decisions)
            try data.write(to: savePath, options: [.atomic, .completeFileProtection])
        } catch {
            print("无法保存决策: \(error.localizedDescription)")
        }
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
        if let index = decisions.firstIndex(where: { $0.id == decision.id }) {
            decisions.remove(at: index)
            saveDecisions()
        }
    }
    
    func resetData() {
        decisions = []
        saveDecisions()
    }
}

extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
} 