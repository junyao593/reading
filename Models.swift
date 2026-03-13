import SwiftUI

// MARK: - Data Models

struct ReadingItem: Identifiable, Codable {
    let id = UUID()
    var quote: String
    var author: String
    var source: String?
    var book: String?
    var sourceType: String?
    var year: Int?
    var genre: String
    var reflection: String
    var topic: String
    var url: String?

    var displaySource: String {
        source ?? book ?? "未知来源"
    }

    enum CodingKeys: String, CodingKey {
        case quote, author, source, book, year, genre, reflection, topic, url
        case sourceType = "source_type"
    }
}

// MARK: - Genre Style

struct GenreStyle {
    let color: Color
    let bgOpacity: Double
    let borderOpacity: Double
}

extension String {
    var genreStyle: GenreStyle {
        switch self {
        case "小说":   return GenreStyle(color: Color(red: 0.39, green: 0.40, blue: 0.96), bgOpacity: 0.18, borderOpacity: 0.40)
        case "哲学":   return GenreStyle(color: Color(red: 0.96, green: 0.62, blue: 0.04), bgOpacity: 0.15, borderOpacity: 0.35)
        case "心理":   return GenreStyle(color: Color(red: 0.06, green: 0.73, blue: 0.51), bgOpacity: 0.15, borderOpacity: 0.35)
        case "回忆录": return GenreStyle(color: Color(red: 0.93, green: 0.28, blue: 0.60), bgOpacity: 0.15, borderOpacity: 0.35)
        case "散文":   return GenreStyle(color: Color(red: 0.98, green: 0.45, blue: 0.09), bgOpacity: 0.15, borderOpacity: 0.35)
        case "诗歌":   return GenreStyle(color: Color(red: 0.66, green: 0.33, blue: 0.98), bgOpacity: 0.18, borderOpacity: 0.40)
        case "新闻":   return GenreStyle(color: Color(red: 0.08, green: 0.72, blue: 0.65), bgOpacity: 0.15, borderOpacity: 0.35)
        case "博客":   return GenreStyle(color: Color(red: 0.96, green: 0.25, blue: 0.37), bgOpacity: 0.15, borderOpacity: 0.35)
        default:       return GenreStyle(color: Color(red: 0.39, green: 0.40, blue: 0.96), bgOpacity: 0.18, borderOpacity: 0.40)
        }
    }
}
