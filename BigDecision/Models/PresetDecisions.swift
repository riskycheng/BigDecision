import Foundation

struct PresetDecision {
    let title: String
    let optionA: Decision.Option
    let optionB: Decision.Option
    let decisionType: Decision.DecisionType
    let importance: Int
    let timeFrame: Decision.TimeFrame
    
    static let presets: [PresetDecision] = [
        // 工作相关
        PresetDecision(
            title: "是否接受新工作机会",
            optionA: Decision.Option(title: "接受新工作", description: "薪资更高，但工作压力可能更大"),
            optionB: Decision.Option(title: "保持现状", description: "当前工作稳定，但发展空间有限"),
            decisionType: .work,
            importance: 5,
            timeFrame: .week
        ),
        PresetDecision(
            title: "是否尝试创业",
            optionA: Decision.Option(title: "开始创业", description: "有更大的发展空间，但风险也更高"),
            optionB: Decision.Option(title: "继续就职", description: "收入稳定，风险较小"),
            decisionType: .work,
            importance: 5,
            timeFrame: .month
        ),
        
        // 生活相关
        PresetDecision(
            title: "是否搬家到新城市",
            optionA: Decision.Option(title: "搬到新城市", description: "新的机会和环境，但需要重新适应"),
            optionB: Decision.Option(title: "留在当前城市", description: "熟悉的环境，但可能错过新机会"),
            decisionType: .housing,
            importance: 4,
            timeFrame: .month
        ),
        PresetDecision(
            title: "选择度假目的地",
            optionA: Decision.Option(title: "海边度假", description: "放松身心，享受阳光和海滩"),
            optionB: Decision.Option(title: "城市旅行", description: "体验文化，参观景点"),
            decisionType: .travel,
            importance: 2,
            timeFrame: .week
        ),
        
        // 投资理财
        PresetDecision(
            title: "投资决策",
            optionA: Decision.Option(title: "股票投资", description: "潜在收益高，但风险也大"),
            optionB: Decision.Option(title: "稳健理财", description: "收益相对较低，但更加稳定"),
            decisionType: .investment,
            importance: 4,
            timeFrame: .days
        ),
        
        // 教育相关
        PresetDecision(
            title: "是否继续深造",
            optionA: Decision.Option(title: "继续学习", description: "提升学历和专业能力，但需要投入时间和金钱"),
            optionB: Decision.Option(title: "直接就业", description: "尽早积累工作经验，有收入"),
            decisionType: .education,
            importance: 4,
            timeFrame: .month
        ),
        
        // 购物相关
        PresetDecision(
            title: "电子产品购买决策",
            optionA: Decision.Option(title: "购买新款", description: "性能更好，但价格较高"),
            optionB: Decision.Option(title: "购买旧款", description: "性价比高，但可能很快过时"),
            decisionType: .shopping,
            importance: 2,
            timeFrame: .days
        ),
        
        // 感情相关
        PresetDecision(
            title: "是否开始异地恋",
            optionA: Decision.Option(title: "尝试异地恋", description: "维持感情，但需要克服距离"),
            optionB: Decision.Option(title: "结束关系", description: "避免异地带来的问题，但可能后悔"),
            decisionType: .relationship,
            importance: 5,
            timeFrame: .week
        )
    ]
    
    static func random() -> PresetDecision {
        presets.randomElement()!
    }
} 