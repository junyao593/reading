import SwiftUI

// MARK: - ViewModel

@MainActor
class NoteViewModel: ObservableObject {
    @Published var note: String = ""
    @Published var results: [ReadingItem] = []
    @Published var likedIDs: Set<UUID> = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var screen: AppScreen = .home

    enum AppScreen {
        case home, result
    }

    let examplePrompts = [
        "最近总是一个人待着，不觉得孤独，但也说不上自在。",
        "和一个老朋友许久没联系了，也不知道该从哪里开口。",
        "换了新工作，明明是自己想要的，却总有一种说不清的失落。",
        "今天突然想起小时候的某个傍晚，说不清为什么，就是很想念。",
        "最近很难集中注意力，脑子里总是装着很多事，却哪件都没做完。",
        "感觉自己在慢慢变成另一个人，也不知道是好是坏。",
        "今天看到一句话，突然就哭了，自己也不明白为什么。",
        "有时候很想逃离现在的生活，但又不知道去哪里。",
    ]

    func reflect() {
        guard !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        Task {
            isLoading = true
            screen = .result
            results = []
            errorMessage = nil
            do {
                results = try await AnthropicService.fetchRecommendations(for: note)
            } catch {
                errorMessage = "出错了，请重试。"
                screen = .home
            }
            isLoading = false
        }
    }

    func toggleLike(_ item: ReadingItem) {
        if likedIDs.contains(item.id) {
            likedIDs.remove(item.id)
        } else {
            likedIDs.insert(item.id)
        }
    }

    func reset() {
        screen = .home
        results = []
        likedIDs = []
        errorMessage = nil
    }

    func randomPrompt() -> String {
        examplePrompts.randomElement() ?? examplePrompts[0]
    }
}
