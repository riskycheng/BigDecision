import Foundation
import Network

class AIService {
    private let apiKey = "sk-ezwzqwedwhtnbyitbnyohvzanpitqqlnpjucejddpozmpjxj"  // DeepSeek API Key
    private let baseURL = "https://api.siliconflow.cn/v1/chat/completions"
    private let monitor = NWPathMonitor()
    private var isNetworkAvailable = true
    
    enum AIServiceError: Error {
        case networkNotAvailable
        case requestFailed(String)
        case invalidResponse
        case parseError
        case serverBusy
        
        var localizedDescription: String {
            switch self {
            case .networkNotAvailable:
                return "网络连接不可用，请检查网络设置后重试"
            case .requestFailed(let message):
                return "请求失败：\(message)"
            case .invalidResponse:
                return "服务器响应无效，请稍后重试"
            case .parseError:
                return "AI响应格式错误，请稍后重试"
            case .serverBusy:
                return "服务器当前繁忙，请稍后重试"
            }
        }
    }
    
    init() {
        setupNetworkMonitoring()
    }
    
    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isNetworkAvailable = path.status == .satisfied
        }
        monitor.start(queue: DispatchQueue.global())
    }
    
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
        // 检查网络状态
        guard isNetworkAvailable else {
            throw AIServiceError.networkNotAvailable
        }
        
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
        
        注意：必须严格按照上述JSON格式返回，不要添加任何其他内容。
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
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AIServiceError.invalidResponse
            }
            
            // 检查HTTP状态码
            switch httpResponse.statusCode {
            case 200:
                break // 继续处理
            case 429:
                throw AIServiceError.serverBusy
            case 500...599:
                throw AIServiceError.serverBusy
            default:
                throw AIServiceError.requestFailed("HTTP状态码: \(httpResponse.statusCode)")
            }
            
            let apiResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
            
            guard let resultString = apiResponse.choices.first?.message.content else {
                throw AIServiceError.invalidResponse
            }
            
            // 清理 JSON 字符串，移除代码块标记
            let cleanedString = resultString
                .replacingOccurrences(of: "```json", with: "")
                .replacingOccurrences(of: "```", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard let resultData = cleanedString.data(using: .utf8) else {
                throw AIServiceError.invalidResponse
            }
            
            do {
                let result = try JSONDecoder().decode(Decision.Result.self, from: resultData)
                return result
            } catch {
                print("解析错误: \(error)")
                print("AI返回内容: \(resultString)")
                throw AIServiceError.parseError
            }
        } catch {
            if let aiError = error as? AIServiceError {
                throw aiError
            }
            throw AIServiceError.requestFailed(error.localizedDescription)
        }
    }
} 