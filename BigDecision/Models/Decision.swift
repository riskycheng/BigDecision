import Foundation

struct Option: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
}

struct Decision: Identifiable, Codable {
    var id = UUID()
    var title: String
    var options: [Option]
    var additionalInfo: String
    var decisionType: DecisionType
    var importance: Int // 1-5
    var timeFrame: TimeFrame
    var result: Result?
    var isFavorited: Bool
    var createdAt: Date
    
    init(id: UUID = UUID(), title: String, options: [Option], additionalInfo: String, decisionType: DecisionType, importance: Int, timeFrame: TimeFrame, result: Result? = nil, createdAt: Date = Date(), isFavorited: Bool = false) {
        self.id = id
        self.title = title
        self.options = options
        self.additionalInfo = additionalInfo
        self.decisionType = decisionType
        self.importance = importance
        self.timeFrame = timeFrame
        self.result = result
        self.createdAt = createdAt
        self.isFavorited = isFavorited
    }
    
    struct Result: Codable {
        let recommendation: String // "A" 或 "B"
        let confidence: Double // 0-1
        let reasoning: String
        let prosA: [String]
        let consA: [String]
        let prosB: [String]
        let consB: [String]
        var thinkingProcess: String? // 思考过程
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
}

enum ShareContentType {
    case summary
    case detailed
    case image
} 