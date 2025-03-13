import Foundation

struct Decision: Identifiable, Codable {
    var id = UUID()
    var title: String
    var optionA: Option
    var optionB: Option
    var additionalInfo: String
    var decisionType: DecisionType
    var importance: Int // 1-5
    var timeFrame: TimeFrame
    var result: Result?
    var createdAt: Date
    
    struct Option: Codable {
        var title: String
        var description: String
    }
    
    struct Result: Codable {
        var recommendation: String // "A" 或 "B"
        var confidence: Double // 0-1
        var reasoning: String
        var prosA: [String]
        var consA: [String]
        var prosB: [String]
        var consB: [String]
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