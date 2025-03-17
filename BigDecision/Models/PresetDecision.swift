import Foundation

struct PresetDecision {
    let title: String
    let options: [Option]
    let decisionType: Decision.DecisionType
    let timeFrame: Decision.TimeFrame
    let importance: Int
    
    func toDecision() -> Decision {
        Decision(
            title: title,
            options: options,
            additionalInfo: "",
            decisionType: decisionType,
            importance: importance,
            timeFrame: timeFrame,
            createdAt: Date()
        )
    }
    
    static let presets: [PresetDecision] = [
        PresetDecision(
            title: "是否换工作？",
            options: [
                Option(title: "留在现公司", description: "稳定但发展有限"),
                Option(title: "接受新offer", description: "机会更多但风险更大")
            ],
            decisionType: .work,
            timeFrame: .week,
            importance: 4
        ),
        PresetDecision(
            title: "是否搬家？",
            options: [
                Option(title: "继续租住", description: "租金较高但位置方便"),
                Option(title: "购买新房", description: "需要贷款但可以积累资产")
            ],
            decisionType: .housing,
            timeFrame: .month,
            importance: 5
        ),
        PresetDecision(
            title: "是否创业？",
            options: [
                Option(title: "继续上班", description: "收入稳定但成长有限"),
                Option(title: "开始创业", description: "风险较大但机会更多")
            ],
            decisionType: .work,
            timeFrame: .month,
            importance: 5
        ),
        PresetDecision(
            title: "是否继续深造？",
            options: [
                Option(title: "直接工作", description: "可以积累经验和收入"),
                Option(title: "继续学习", description: "提升学历但需要投入时间和金钱")
            ],
            decisionType: .education,
            timeFrame: .month,
            importance: 4
        ),
        PresetDecision(
            title: "是否买车？",
            options: [
                Option(title: "继续公交出行", description: "省钱环保但不够便利"),
                Option(title: "购买私家车", description: "提升便利性但支出增加")
            ],
            decisionType: .shopping,
            timeFrame: .week,
            importance: 3
        ),
        PresetDecision(
            title: "是否换城市？",
            options: [
                Option(title: "留在当前城市", description: "生活圈子稳定但发展受限"),
                Option(title: "搬到新城市", description: "机会更多但需要重新适应")
            ],
            decisionType: .housing,
            timeFrame: .month,
            importance: 5
        ),
        PresetDecision(
            title: "是否投资理财？",
            options: [
                Option(title: "继续存款", description: "稳定无风险但收益低"),
                Option(title: "开始投资", description: "可能获得更高收益但有风险")
            ],
            decisionType: .investment,
            timeFrame: .week,
            importance: 3
        )
    ]
} 