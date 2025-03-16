import Foundation

struct Decision: Identifiable, Codable {
    let id: UUID
    let title: String
    let optionA: Option
    let optionB: Option
    let additionalInfo: String
    let decisionType: DecisionType
    let importance: Int // 1-5
    let timeFrame: TimeFrame
    var result: Result?
    let createdAt: Date
    var isFavorited: Bool
    
    init(id: UUID = UUID(), title: String, optionA: Option, optionB: Option, additionalInfo: String, decisionType: DecisionType, importance: Int, timeFrame: TimeFrame, result: Result? = nil, createdAt: Date = Date(), isFavorited: Bool = false) {
        self.id = id
        self.title = title
        self.optionA = optionA
        self.optionB = optionB
        self.additionalInfo = additionalInfo
        self.decisionType = decisionType
        self.importance = importance
        self.timeFrame = timeFrame
        self.result = result
        self.createdAt = createdAt
        self.isFavorited = isFavorited
    }
    
    struct Option: Codable {
        let title: String
        let description: String
    }
    
    struct Result: Codable {
        let recommendation: String // "A" 或 "B"
        let confidence: Double // 0-1
        let reasoning: String
        let prosA: [String]
        let consA: [String]
        let prosB: [String]
        let consB: [String]
    }
    
    enum DecisionType: String, Codable, CaseIterable {
        case work = "工作"
        case relationship = "感情"
        case education = "教育"
        case housing = "住房"
        case travel = "旅行"
        case shopping = "购物"
        case investment = "投资"
        case other = "其他"
        
        var icon: String {
            switch self {
            case .work: return "briefcase.fill"
            case .relationship: return "heart.fill"
            case .education: return "graduationcap.fill"
            case .housing: return "house.fill"
            case .travel: return "airplane"
            case .shopping: return "cart.fill"
            case .investment: return "dollarsign.circle.fill"
            case .other: return "ellipsis"
            }
        }
    }
    
    enum TimeFrame: String, Codable, CaseIterable {
        case immediate = "立即"
        case days = "几天内"
        case week = "一周内"
        case month = "一个月内"
        case longTerm = "长期考虑"
    }
    
    // 从预设决定创建新决定
    static func fromPreset(_ preset: PresetDecision) -> Decision {
        Decision(
            title: preset.title,
            optionA: preset.optionA,
            optionB: preset.optionB,
            additionalInfo: "",
            decisionType: preset.decisionType,
            importance: preset.importance,
            timeFrame: preset.timeFrame
        )
    }
} 