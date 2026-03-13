import SwiftUI

// MARK: - Result Screen

struct ResultView: View {
    @ObservedObject var vm: NoteViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Sticky header
            HStack(spacing: 10) {
                Button(action: { vm.reset() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.09))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("相关阅读")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    Text(vm.isLoading ? "正在书海中寻找共鸣…" : "找到 \(vm.results.count) 条内容")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.38))
                }

                Spacer()

                if vm.likedIDs.count > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 10))
                        Text("\(vm.likedIDs.count)")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(red: 0.88, green: 0.11, blue: 0.28))
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(red: 0.067, green: 0.067, blue: 0.067).opacity(0.96))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.white.opacity(0.06)),
                alignment: .bottom
            )

            // Content
            ScrollView {
                VStack(spacing: 11) {
                    // Note preview
                    HStack {
                        Text(""\(vm.note.count > 90 ? String(vm.note.prefix(90)) + "…" : vm.note)"")
                            .font(.system(size: 12))
                            .italic()
                            .foregroundColor(.white.opacity(0.4))
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    .padding(.horizontal, 13)
                    .padding(.vertical, 9)
                    .background(Color.white.opacity(0.04))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.top, 10)

                    if vm.isLoading {
                        ForEach(0..<10, id: \.self) { i in
                            SkeletonCard()
                                .transition(.opacity)
                        }
                    } else {
                        ForEach(Array(vm.results.enumerated()), id: \.element.id) { index, item in
                            BookCard(item: item, isLiked: vm.likedIDs.contains(item.id)) {
                                vm.toggleLike(item)
                            }
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .bottom)),
                                removal: .opacity
                            ))
                        }
                    }

                    if !vm.isLoading && !vm.results.isEmpty {
                        Button(action: { vm.reset() }) {
                            Text("写另一条笔记")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.55))
                                .padding(.horizontal, 24)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.07))
                                .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1))
                                .clipShape(Capsule())
                        }
                        .padding(.vertical, 6)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 24)
                .animation(.easeOut(duration: 0.35), value: vm.isLoading)
            }
        }
    }
}

// MARK: - Book Card

struct BookCard: View {
    let item: ReadingItem
    let isLiked: Bool
    let onToggleLike: () -> Void

    @State private var urlExpanded = false
    private var style: GenreStyle { item.genre.genreStyle }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Top row: genre tag + year + like button
            HStack(spacing: 6) {
                Circle()
                    .fill(style.color)
                    .frame(width: 7, height: 7)
                Text(item.genre)
                    .font(.system(size: 10, weight: .semibold))
                    .textCase(.uppercase)
                    .tracking(0.9)
                    .foregroundColor(style.color)
                if let year = item.year {
                    Text("\(year)")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.28))
                }
                Spacer()
                Button(action: onToggleLike) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(isLiked ? Color(red: 0.88, green: 0.11, blue: 0.28) : Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .animation(.easeInOut(duration: 0.15), value: isLiked)
            }
            .padding(.bottom, 10)

            // Quote
            Text(""\(item.quote)"")
                .font(.system(size: 13.5))
                .italic()
                .foregroundColor(.white.opacity(0.87))
                .lineSpacing(5)
                .padding(.bottom, 10)

            // Author + source
            VStack(alignment: .leading, spacing: 3) {
                Text("— \(item.author)")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.53))
                HStack(spacing: 6) {
                    Text("《\(item.displaySource)》")
                        .font(.system(size: 11.5))
                        .foregroundColor(.white.opacity(0.35))
                    if let st = item.sourceType {
                        Text(st)
                            .font(.system(size: 9.5))
                            .foregroundColor(.white.opacity(0.4))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.07))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
            }
            .padding(.bottom, 10)

            Divider().overlay(Color.white.opacity(0.08))
                .padding(.bottom, 10)

            // Reflection
            Text(item.reflection)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.48))
                .lineSpacing(4)
                .padding(.bottom, item.url != nil ? 8 : 4)

            // URL link (if available)
            if let urlStr = item.url, let url = URL(string: urlStr) {
                Link(destination: url) {
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.up.right.square")
                            .font(.system(size: 11))
                        Text("阅读原文")
                            .font(.system(size: 11.5, weight: .medium))
                    }
                    .foregroundColor(style.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(style.color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(style.color.opacity(0.35), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.bottom, 4)
            }

            // Disclaimer
            Text("* 以上段落为意译改编，非原文逐字引用")
                .font(.system(size: 10))
                .italic()
                .foregroundColor(.white.opacity(0.2))
        }
        .padding(15)
        .background(style.color.opacity(style.bgOpacity))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(style.color.opacity(style.borderOpacity), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

// MARK: - Skeleton Card

struct SkeletonCard: View {
    @State private var phase: CGFloat = -1

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 7) {
                Circle().fill(Color.white.opacity(0.1)).frame(width: 7, height: 7)
                shimmerBar(width: 55, height: 10)
            }
            ForEach([1.0, 0.93, 0.8, 0.96, 0.65, 0.5], id: \.self) { w in
                shimmerBar(width: nil, height: 10, widthFraction: w)
            }
        }
        .padding(15)
        .background(Color.white.opacity(0.04))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.06), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .onAppear { withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) { phase = 1 } }
    }

    func shimmerBar(width: CGFloat? = nil, height: CGFloat, widthFraction: CGFloat = 1.0) -> some View {
        GeometryReader { geo in
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: .white.opacity(0.07), location: 0),
                            .init(color: .white.opacity(0.13), location: 0.5),
                            .init(color: .white.opacity(0.07), location: 1),
                        ],
                        startPoint: UnitPoint(x: phase - 0.3, y: 0),
                        endPoint: UnitPoint(x: phase + 0.3, y: 0)
                    )
                )
                .frame(width: width ?? geo.size.width * widthFraction, height: height)
        }
        .frame(height: height)
    }
}
