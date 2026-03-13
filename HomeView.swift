import SwiftUI

// MARK: - Home Screen

struct HomeView: View {
    @ObservedObject var vm: NoteViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Logo + title
            VStack(spacing: 8) {
                HexagonLogo()
                    .frame(width: 44, height: 44)
                Text("Note+")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.top, 24)
            .padding(.bottom, 16)

            // Subtitle
            Text("此刻，你心里装着什么？")
                .font(.system(size: 15))
                .italic()
                .foregroundColor(.white.opacity(0.78))
                .multilineTextAlignment(.center)
                .padding(.bottom, 16)

            // Textarea
            ZStack(alignment: .topLeading) {
                if vm.note.isEmpty {
                    Text("今天有一个时刻让我感触颇深……")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.27))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                }
                TextEditor(text: $vm.note)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .focused($isFocused)
            }
            .frame(height: 120)
            .background(Color.white.opacity(0.065))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isFocused ? Color.orange.opacity(0.5) : Color.white.opacity(0.11), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 22)
            .padding(.bottom, 10)

            // Example chips (only when note is empty)
            if vm.note.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("试试这些话题 →")
                        .font(.system(size: 10.5))
                        .foregroundColor(.white.opacity(0.25))
                        .padding(.leading, 4)

                    FlowLayout(spacing: 6) {
                        ForEach(vm.examplePrompts.prefix(4), id: \.self) { prompt in
                            ChipButton(title: prompt.count > 14 ? String(prompt.prefix(14)) + "…" : prompt) {
                                vm.note = prompt
                            }
                        }
                        // Shuffle button
                        Button(action: { vm.note = vm.randomPrompt() }) {
                            HStack(spacing: 4) {
                                Image(systemName: "shuffle")
                                    .font(.system(size: 10))
                                Text("换一个")
                                    .font(.system(size: 11))
                            }
                            .foregroundColor(.white.opacity(0.35))
                            .padding(.horizontal, 11)
                            .padding(.vertical, 5)
                            .background(Color.white.opacity(0.04))
                            .overlay(
                                Capsule().stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                            .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 10)
                .transition(.opacity)
            }

            Text("匹配书籍 · 文章 · 博客中的共鸣内容")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.22))
                .padding(.bottom, 12)

            if let err = vm.errorMessage {
                Text(err)
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.97, green: 0.53, blue: 0.53))
                    .padding(.bottom, 8)
            }

            Spacer()

            // Reflect button
            Button(action: { vm.reflect() }) {
                Text("寻找共鸣")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        LinearGradient(
                            colors: [Color(red:0.98,green:0.45,blue:0.09), Color(red:0.93,green:0.28,blue:0.60)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
                    .opacity(vm.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.42 : 1.0)
            }
            .disabled(vm.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .padding(.horizontal, 22)
            .padding(.bottom, 28)
        }
        .onAppear { isFocused = true }
        .animation(.easeInOut(duration: 0.2), value: vm.note.isEmpty)
    }
}

// MARK: - Chip Button

struct ChipButton: View {
    let title: String
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(isHovered ? .white.opacity(0.85) : .white.opacity(0.55))
                .padding(.horizontal, 11)
                .padding(.vertical, 5)
                .background(isHovered ? Color.orange.opacity(0.15) : Color.white.opacity(0.06))
                .overlay(
                    Capsule()
                        .stroke(isHovered ? Color.orange.opacity(0.4) : Color.white.opacity(0.12), lineWidth: 1)
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Flow Layout (wrapping chip container)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.map { $0.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0 }.reduce(0) { $0 + $1 + spacing } - spacing
        return CGSize(width: proposal.width ?? 0, height: max(height, 0))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: ProposedViewSize(width: bounds.width, height: nil), subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            for subview in row {
                let size = subview.sizeThatFits(.unspecified)
                subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += rowHeight + spacing
        }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[LayoutSubview]] {
        var rows: [[LayoutSubview]] = [[]]
        var x: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && !rows.last!.isEmpty {
                rows.append([])
                x = 0
            }
            rows[rows.count - 1].append(subview)
            x += size.width + spacing
        }
        return rows
    }
}
