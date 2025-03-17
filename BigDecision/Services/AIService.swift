import Foundation

class AIService {
    static let shared = AIService()
    
    private init() {}
    
    func analyzeDecision(decision: Decision, completion: @escaping (Result<Decision.Result, Error>) -> Void) {
        // 在实际应用中，这里应该调用真实的API
        // 现在我们使用模拟数据
        
        DispatchQueue.global().async {
            // 模拟网络延迟
            Thread.sleep(forTimeInterval: 2.0)
            
            // 构建提示文本（在实际应用中会发送给AI服务）
            _ = """
            请帮我分析以下决策：

            决策主题：\(decision.title)
            选项A：\(decision.options[0].title)
            选项A描述：\(decision.options[0].description)
            选项B：\(decision.options[1].title)
            选项B描述：\(decision.options[1].description)
            补充信息：\(decision.additionalInfo)
            决策类型：\(decision.decisionType.rawValue)
            重要性：\(decision.importance)/5
            时间框架：\(decision.timeFrame.rawValue)

            请从以下几个方面进行分析：
            1. 推荐选择（A或B）
            2. 推荐理由
            3. 每个选项的优缺点
            4. 潜在风险
            5. 建议的后续行动

            请用JSON格式返回，包含以下字段：
            - recommendation: "A" 或 "B"
            - confidence: 0-1之间的数字
            - reasoning: 分析理由
            - prosA: [选项A的优点列表]
            - consA: [选项A的缺点列表]
            - prosB: [选项B的优点列表]
            - consB: [选项B的缺点列表]
            """
            
            let result = Decision.Result(
                recommendation: Bool.random() ? "A" : "B",
                confidence: Double.random(in: 0.6...0.95),
                reasoning: "基于您提供的信息，我们进行了全面分析。考虑到您的具体情况和偏好，我们认为这个选择更符合您的长期利益。",
                prosA: [
                    "优势1：\(decision.options[0].title)提供了稳定性",
                    "优势2：风险较低",
                    "优势3：更符合您当前的生活状态"
                ],
                consA: [
                    "劣势1：可能限制未来发展",
                    "劣势2：收益有限"
                ],
                prosB: [
                    "优势1：\(decision.options[1].title)提供了更多机会",
                    "优势2：潜在回报更高",
                    "优势3：有助于个人成长"
                ],
                consB: [
                    "劣势1：风险较高",
                    "劣势2：需要更多适应时间"
                ]
            )
            
            DispatchQueue.main.async {
                completion(.success(result))
            }
        }
    }
} 