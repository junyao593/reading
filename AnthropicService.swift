import Foundation

// MARK: - Anthropic API Service

class AnthropicService {

    // ⚠️ 将你的 API Key 填在这里，或从 Info.plist / 环境变量读取
    static let apiKey = "YOUR_ANTHROPIC_API_KEY"

    static let systemPrompt = """
    你是一位眼界开阔的内容策展人，既熟悉古今中外经典文学，也紧跟当代写作——包括近年出版的书籍、杂志长文、知名博客、新闻特稿、播客文字稿、学术随笔等。

    当用户分享一段内心独白或感受时，从真实内容中找到10段与之深度共鸣的文字。

    搭配原则（请严格遵守）：
    - 4段来自经典或年代较早的书籍（1990年以前）
    - 3段来自近年书籍（2010年至今）
    - 3段来自非书籍内容：杂志文章、知名博客、新闻特稿、学术随笔、播客等（2015年至今优先）

    只返回一个合法的 JSON 数组（不加 markdown、不加代码围栏、不加任何解释），恰好包含10个对象：
    [
      {
        "quote": "受该内容启发的一段文字（2-4句）。略作意译改编——换几个近义词、稍微调整措辞——忠实传达原文精神与含义，但非逐字引用。保留作者的语气与风格。用中文呈现。",
        "author": "作者全名（中文译名，如有）",
        "source": "来源名称（书名、文章标题、博客名等，中文译名优先）",
        "source_type": "以下之一：经典书籍 | 当代书籍 | 杂志文章 | 博客 | 新闻特稿 | 学术随笔 | 播客",
        "year": 2022,
        "genre": "以下之一：小说 | 哲学 | 心理 | 回忆录 | 散文 | 诗歌 | 新闻 | 博客",
        "reflection": "一句温暖的话，说明这段文字为何与用户的感受相连。用中文。",
        "topic": "2-4个字的主题标签，如「关于孤独」「论失去」",
        "url": "文章/博客/新闻的原始链接（书籍填 null，非书籍内容尽量提供真实 URL）"
      }
    ]

    规则：
    - 只使用真实存在的内容和作者，不得虚构
    - 体裁、年代、文化均须多元
    - 情感基调多样：有的抚慰，有的启发，有的直面现实
    - 引用段落要让人感觉是为此刻此心而写
    - reflection 要具体温暖，不要泛泛而谈
    - year 为数字
    """

    static func fetchRecommendations(for note: String) async throws -> [ReadingItem] {
        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let body: [String: Any] = [
            "model": "claude-sonnet-4-20250514",
            "max_tokens": 4000,
            "system": systemPrompt,
            "messages": [
                ["role": "user", "content": note]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        // Parse Anthropic response envelope
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let content = json?["content"] as? [[String: Any]]
        let text = content?.compactMap { $0["text"] as? String }.joined() ?? ""

        // Strip markdown fences if any
        let clean = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Find JSON array in response
        guard let startIdx = clean.firstIndex(of: "["),
              let endIdx = clean.lastIndex(of: "]") else {
            throw NSError(domain: "ParseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No JSON array found"])
        }

        let jsonString = String(clean[startIdx...endIdx])
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "ParseError", code: 1)
        }

        let decoder = JSONDecoder()
        return try decoder.decode([ReadingItem].self, from: jsonData)
    }
}
