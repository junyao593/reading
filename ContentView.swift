import SwiftUI

// MARK: - Root Content View

struct ContentView: View {
    @StateObject private var vm = NoteViewModel()

    var body: some View {
        ZStack {
            // Background
            Color(red: 0.039, green: 0.039, blue: 0.039)
                .ignoresSafeArea()

            // Ambient gradient blobs
            GeometryReader { geo in
                // Orange blob top-left
                RadialGradient(
                    colors: [Color.orange.opacity(0.22), .clear],
                    center: .center, startRadius: 0, endRadius: 220
                )
                .frame(width: 380, height: 380)
                .offset(x: -80, y: -80)
                .blur(radius: 30)

                // Pink blob bottom-right
                RadialGradient(
                    colors: [Color.pink.opacity(0.18), .clear],
                    center: .center, startRadius: 0, endRadius: 180
                )
                .frame(width: 320, height: 320)
                .offset(x: geo.size.width - 160, y: geo.size.height - 160)
                .blur(radius: 30)

                // Purple blob center
                RadialGradient(
                    colors: [Color.purple.opacity(0.12), .clear],
                    center: .center, startRadius: 0, endRadius: 150
                )
                .frame(width: 280, height: 200)
                .offset(x: geo.size.width * 0.3, y: geo.size.height * 0.4)
                .blur(radius: 35)
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)

            // Main content
            VStack(spacing: 0) {
                if vm.screen == .home {
                    HomeView(vm: vm)
                        .transition(.asymmetric(
                            insertion: .opacity,
                            removal: .opacity.combined(with: .move(edge: .leading))
                        ))
                } else {
                    ResultView(vm: vm)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .trailing)),
                            removal: .opacity
                        ))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: vm.screen)
        }
    }
}

// MARK: - Hexagon Logo

struct HexagonLogo: View {
    var body: some View {
        Canvas { context, size in
            let gradient = Gradient(colors: [
                Color(red: 0.98, green: 0.45, blue: 0.09),
                Color(red: 0.93, green: 0.28, blue: 0.60),
                Color(red: 0.55, green: 0.36, blue: 0.98)
            ])
            let linGrad = GraphicsContext.Shading.linearGradient(
                gradient,
                startPoint: .zero,
                endPoint: CGPoint(x: size.width, y: size.height)
            )
            let cx = size.width / 2
            let cy = size.height / 2

            // Outer hexagon
            var outer = Path()
            for i in 0..<6 {
                let angle = Double(i) * .pi / 3 - .pi / 2
                let x = cx + cos(angle) * cx * 0.92
                let y = cy + sin(angle) * cy * 0.92
                i == 0 ? outer.move(to: CGPoint(x: x, y: y)) : outer.addLine(to: CGPoint(x: x, y: y))
            }
            outer.closeSubpath()
            context.stroke(outer, with: linGrad, lineWidth: 2.2)

            // Inner hexagon
            var inner = Path()
            for i in 0..<6 {
                let angle = Double(i) * .pi / 3 - .pi / 2
                let x = cx + cos(angle) * cx * 0.55
                let y = cy + sin(angle) * cy * 0.55
                i == 0 ? inner.move(to: CGPoint(x: x, y: y)) : inner.addLine(to: CGPoint(x: x, y: y))
            }
            inner.closeSubpath()
            context.stroke(inner, with: linGrad.opacity(0.5), lineWidth: 1.4)

            // Center dot
            let dot = Path(ellipseIn: CGRect(x: cx - 3, y: cy - 3, width: 6, height: 6))
            context.fill(dot, with: linGrad)
        }
    }
}

#Preview {
    ContentView()
}
