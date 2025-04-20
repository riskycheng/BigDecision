import Foundation
import Network
import SwiftUI
import Combine

enum AIModelType: String, CaseIterable {
    case standard = "标准"
    case professional = "专业"
    case advanced = "高级"
    
    var modelName: String {
        switch self {
        case .standard:
            return "deepseek-ai/DeepSeek-R1-Distill-Qwen-7B"
        case .professional:
            return "deepseek-ai/DeepSeek-R1-Distill-Qwen-14B"
        case .advanced:
            return "Pro/deepseek-ai/DeepSeek-R1"
        }
    }
    
    var features: (icon: String, title: String, description: String) {
        switch self {
        case .standard:
            return ("bolt", "简洁高效", "快速分析决策选项，提供简明有效的建议")
        case .professional:
            return ("chart.bar.xaxis", "精准科学", "科学量化各种因素，提供精准深入的决策依据")
        case .advanced:
            return ("brain.head.profile", "思考可视化", "实时展示AI思考过程，提供全面透明的决策建议")
        }
    }
    
    var supportsStreaming: Bool {
        return self == .advanced
    }
}

class AIService: ObservableObject {
    private let apiKey = "sk-ezwzqwedwhtnbyitbnyohvzanpitqqlnpjucejddpozmpjxj"  // DeepSeek API Key
    private let baseURL = "https://api.siliconflow.cn/v1/chat/completions"
    private let monitor = NWPathMonitor()
    private var isNetworkAvailable = true
    @AppStorage("aiModelType") var aiModelType: String = AIModelType.professional.rawValue
    
    // 流式分析状态
    @Published var isStreaming = false
    @Published var streamedThinkingSteps: [String] = []
    @Published var streamingComplete = false
    private var streamingTask: Task<Void, Never>? = nil
    private var cancellables = Set<AnyCancellable>()
    
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
    
    // 流式响应结构
    struct StreamChoice: Codable {
        struct Delta: Codable {
            let content: String?
            let reasoning_content: String?
        }
        let delta: Delta
        let finish_reason: String?
    }
    
    struct StreamResponse: Codable {
        let choices: [StreamChoice]
    }
    
    func analyzeDecision(_ decision: Decision) async throws -> Decision.Result {
        // 检查网络状态
        guard isNetworkAvailable else {
            throw AIServiceError.networkNotAvailable
        }
        
        // 获取当前选择的模型类型
        let modelType = AIModelType(rawValue: aiModelType) ?? .professional
        
        // 如果是高级模式，使用流式分析
        if modelType == .advanced {
            return try await analyzeDecisionWithStreaming(decision)
        } else {
            return try await analyzeDecisionStandard(decision)
        }
    }
    
    private func getSystemPrompt(isStreaming: Bool) -> String {
        if isStreaming {
            return """
            你是一个专业的决策分析助手。请基于用户提供的信息，分析两个选项并给出建议。
            请在回答问题时，先展示你的思考过程，然后再给出最终答案。请一步一步详细思考。
            
            你需要：
            1. 分析每个选项的优点和缺点
            2. 给出最终推荐（用A表示第一个选项，用B表示第二个选项）
            3. 给出推荐的置信度（0-1之间的小数）
            4. 提供详细的分析理由
            
            请确保最终回复格式如下：
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
        } else {
            return """
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
        }
    }
    
    private func analyzeDecisionStandard(_ decision: Decision) async throws -> Decision.Result {
        let systemPrompt = getSystemPrompt(isStreaming: false)
        
        let userPrompt = """
        决策标题：\(decision.title)
        
        选项A：\(decision.options[0].title)
        选项A描述：\(decision.options[0].description)
        
        选项B：\(decision.options[1].title)
        选项B描述：\(decision.options[1].description)
        
        补充信息：\(decision.additionalInfo.isEmpty ? "无" : decision.additionalInfo)
        重要程度：\(decision.importance)/5
        决策时间框架：\(decision.timeFrame.rawValue)
        决策类型：\(decision.decisionType.rawValue)
        """
        
        let messages = [
            Message(role: "system", content: systemPrompt),
            Message(role: "user", content: userPrompt)
        ]
        
        // 获取当前选择的模型类型
        let modelType = AIModelType(rawValue: aiModelType) ?? .professional
        
        let request = ChatRequest(
            model: modelType.modelName,
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
    
    // 流式分析方法
    private func analyzeDecisionWithStreaming(_ decision: Decision) async throws -> Decision.Result {
        // 重置流式状态
        DispatchQueue.main.async {
            self.isStreaming = true
            self.streamedThinkingSteps = []
            self.streamingComplete = false
        }
        
        let systemPrompt = getSystemPrompt(isStreaming: true)
        
        let userPrompt = """
        决策标题：\(decision.title)
        
        选项A：\(decision.options[0].title)
        选项A描述：\(decision.options[0].description)
        
        选项B：\(decision.options[1].title)
        选项B描述：\(decision.options[1].description)
        
        补充信息：\(decision.additionalInfo.isEmpty ? "无" : decision.additionalInfo)
        重要程度：\(decision.importance)/5
        决策时间框架：\(decision.timeFrame.rawValue)
        决策类型：\(decision.decisionType.rawValue)
        """
        
        let messages = [
            Message(role: "system", content: systemPrompt),
            Message(role: "user", content: userPrompt)
        ]
        
        // 获取当前选择的模型类型
        let modelType = AIModelType(rawValue: aiModelType) ?? .professional
        
        let request = ChatRequest(
            model: modelType.modelName,
            messages: messages,
            stream: true,
            max_tokens: 2048,  // 增加token限制以容纳思考过程
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
        
        // 创建一个Future来处理最终结果
        return try await withCheckedThrowingContinuation { continuation in
            var fullContent = ""
            var fullReasoning = ""
            
            // 取消之前的任务
            streamingTask?.cancel()
            
            // 创建新的流式处理任务
            streamingTask = Task {
                do {
                    let (bytes, response) = try await URLSession.shared.bytes(for: urlRequest)
                    
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
                    
                    // 处理流式响应
                    for try await line in bytes.lines {
                        if Task.isCancelled { break }
                        
                        // 跳过空行和[DONE]标记
                        if line.isEmpty || line == "data: [DONE]" { continue }
                        
                        // 处理数据行
                        if line.hasPrefix("data: ") {
                            let jsonString = String(line.dropFirst(6))
                            
                            do {
                                let streamResponse = try JSONDecoder().decode(StreamResponse.self, from: jsonString.data(using: .utf8)!)
                                
                                if let choice = streamResponse.choices.first {
                                    // 处理内容更新
                                    if let content = choice.delta.content {
                                        fullContent += content
                                    }
                                    
                                    // 处理思考过程更新
                                    if let reasoning = choice.delta.reasoning_content, !reasoning.isEmpty {
                                        fullReasoning += reasoning
                                        
                                        // 打印思考过程到控制台
                                        print("[思考过程]: \(reasoning)")
                                        
                                        // 更新UI显示的思考步骤
                                        DispatchQueue.main.async {
                                            // 将思考过程添加到数组中
                                            self.streamedThinkingSteps.append(reasoning)
                                            
                                            // 通知观察者数据已更新
                                            self.objectWillChange.send()
                                        }
                                    }
                                    
                                    // 检查是否完成
                                    if choice.finish_reason != nil {
                                        DispatchQueue.main.async {
                                            self.streamingComplete = true
                                        }
                                    }
                                }
                            } catch {
                                // 忽略解析错误，继续处理下一行
                                continue
                            }
                        }
                    }
                    
                    // 流式传输完成后，解析JSON结果
                    let cleanedString = fullContent
                        .replacingOccurrences(of: "```json", with: "")
                        .replacingOccurrences(of: "```", with: "")
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    guard let resultData = cleanedString.data(using: .utf8) else {
                        throw AIServiceError.invalidResponse
                    }
                    
                    do {
                        let result = try JSONDecoder().decode(Decision.Result.self, from: resultData)
                        
                        // 更新UI状态
                        DispatchQueue.main.async {
                            self.isStreaming = false
                            self.streamingComplete = true
                        }
                        
                        // 返回结果
                        continuation.resume(returning: result)
                    } catch {
                        print("解析错误: \(error)")
                        print("AI返回内容: \(fullContent)")
                        continuation.resume(throwing: AIServiceError.parseError)
                    }
                } catch {
                    // 更新UI状态
                    DispatchQueue.main.async {
                        self.isStreaming = false
                    }
                    
                    if let aiError = error as? AIServiceError {
                        continuation.resume(throwing: aiError)
                    } else {
                        continuation.resume(throwing: AIServiceError.requestFailed(error.localizedDescription))
                    }
                }
            }
        }
    }
    
    // 取消流式分析
    func cancelStreaming() {
        streamingTask?.cancel()
        streamingTask = nil
        
        DispatchQueue.main.async {
            self.isStreaming = false
            self.streamingComplete = true
        }
    }
} 
