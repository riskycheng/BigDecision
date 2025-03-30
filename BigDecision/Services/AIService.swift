import Foundation

class AIService {
    private let apiKey = "sk-ezwzqwedwhtnbyitbnyohvzanpitqqlnpjucejddpozmpjxj"  // DeepSeek API Key
    private let baseURL = "https://api.siliconflow.cn/v1/chat/completions"
    
    struct Message: Codable {
        let role: String
        let content: String
    }
    
    struct ChatRequest: Codable {
        let model: String
        let messages: [Message]
        let stream: Bool
        let max_tokens: Int
        let temperature: Double
        let top_p: Double
        let top_k: Int
        let frequency_penalty: Double
        let n: Int
    }
    
    struct Choice: Codable {
        let message: Message
        let finish_reason: String?
    }
    
    struct ChatResponse: Codable {
        let choices: [Choice]
    }
    
    func analyzeDecision(_ decision: Decision) async throws -> Decision.Result {
        let systemPrompt = """
        你是一个专业的决策分析助手。请基于用户提供的信息，分析两个选项并给出建议。
        你需要：
        1. 分析每个选项的优点和缺点
        2. 给出最终推荐（用A表示第一个选项，用B表示第二个选项）
        3. 给出推荐的置信度（0-1之间的小数）
        4. 提供详细的分析理由
        
        请确保回复格式如下：
        {
            "recommendation": "A或B",
            "confidence": 0.75,
            "reasoning": "详细的分析理由",
            "prosA": ["优点1", "优点2", ...],
            "consA": ["缺点1", "缺点2", ...],
            "prosB": ["优点1", "优点2", ...],
            "consB": ["缺点1", "缺点2", ...]
        }
        """
        
        let userPrompt = """
        决策标题：\(decision.title)
        
        选项A：\(decision.options[0].title)
        选项A描述：\(decision.options[0].description)
        
        选项B：\(decision.options[1].title)
        选项B描述：\(decision.options[1].description)
        
        补充信息：\(decision.additionalInfo ?? "无")
        重要程度：\(decision.importance)/5
        决策时间框架：\(decision.timeFrame.rawValue)
        决策类型：\(decision.decisionType.rawValue)
        """
        
        let messages = [
            Message(role: "system", content: systemPrompt),
            Message(role: "user", content: userPrompt)
        ]
        
        let request = ChatRequest(
            model: "deepseek-ai/DeepSeek-R1-Distill-Qwen-7B",
            messages: messages,
            stream: false,
            max_tokens: 1024,
            temperature: 0.7,
            top_p: 0.7,
            top_k: 50,
            frequency_penalty: 0.5,
            n: 1
        )
        
        var urlRequest = URLRequest(url: URL(string: baseURL)!)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        let response = try JSONDecoder().decode(ChatResponse.self, from: data)
        
        guard let resultString = response.choices.first?.message.content,
              let resultData = resultString.data(using: .utf8),
              let result = try? JSONDecoder().decode(Decision.Result.self, from: resultData) else {
            throw NSError(domain: "AIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse AI response"])
        }
        
        return result
    }
} 