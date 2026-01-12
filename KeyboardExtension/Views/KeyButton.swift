import SwiftUI
import UIKit

struct KeyButton: View {
    let title: String
    let action: () -> Void
    var alternates: [String] = []
    var onAlternateSelected: ((String) -> Void)? = nil

    @Environment(\.colorScheme) var colorScheme
    @State private var isPressed = false
    @State private var showPopup = false
    @State private var showAlternates = false
    @State private var selectedAlternate: Int? = nil
    @GestureState private var longPressState = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main key
                Button(action: {
                    if !showAlternates {
                        action()
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(keyColor)
                            .shadow(color: Color.black.opacity(0.25), radius: 0, x: 0, y: 1)

                        Text(title)
                            .font(.system(size: 22, weight: .light))
                            .foregroundColor(textColor)
                    }
                }
                .buttonStyle(KeyPressStyle(isPressed: $isPressed, showPopup: $showPopup))
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.5)
                        .updating($longPressState) { currentState, gestureState, _ in
                            gestureState = currentState
                        }
                        .onEnded { _ in
                            if !alternates.isEmpty {
                                showAlternates = true
                                triggerHaptic(.medium)
                            }
                        }
                )

                // Key popup preview
                if showPopup && !showAlternates {
                    KeyPopup(title: title, colorScheme: colorScheme)
                        .offset(y: -55)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.5).combined(with: .opacity),
                            removal: .opacity
                        ))
                        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: showPopup)
                        .zIndex(100)
                }

                // Alternates popup
                if showAlternates && !alternates.isEmpty {
                    AlternatesPopup(
                        alternates: alternates,
                        selectedIndex: selectedAlternate,
                        colorScheme: colorScheme,
                        onSelect: { index in
                            if let alt = alternates[safe: index] {
                                onAlternateSelected?(alt)
                            }
                            showAlternates = false
                            selectedAlternate = nil
                        },
                        onDismiss: {
                            showAlternates = false
                            selectedAlternate = nil
                        }
                    )
                    .offset(y: -60)
                    .zIndex(200)
                }
            }
        }
        .frame(height: 42)
        .onChange(of: isPressed) { newValue in
            if newValue {
                showPopup = true
                triggerHaptic(.light)
            } else if !showAlternates {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showPopup = false
                }
            }
        }
    }

    private var keyColor: Color {
        if isPressed {
            return colorScheme == .dark ? Color(white: 0.7) : Color(white: 0.85)
        }
        return colorScheme == .dark ? Color(white: 0.55) : .white
    }

    private var textColor: Color {
        colorScheme == .dark ? .white : .black
    }

    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

struct KeyPressStyle: ButtonStyle {
    @Binding var isPressed: Bool
    @Binding var showPopup: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .brightness(configuration.isPressed ? 0.1 : 0)
            .animation(.spring(response: 0.15, dampingFraction: 0.6), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { newValue in
                isPressed = newValue
            }
    }
}

struct KeyPopup: View {
    let title: String
    let colorScheme: ColorScheme

    var body: some View {
        ZStack {
            // Popup background with tail
            PopupShape()
                .fill(colorScheme == .dark ? Color(white: 0.45) : .white)
                .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)

            // Key letter
            Text(title)
                .font(.system(size: 32, weight: .light))
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .offset(y: -8)
        }
        .frame(width: 56, height: 56)
    }
}

struct PopupShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let cornerRadius: CGFloat = 8
        let tailHeight: CGFloat = 10
        let tailWidth: CGFloat = 14

        // Main rectangle
        let mainRect = CGRect(x: 0, y: 0, width: rect.width, height: rect.height - tailHeight)

        path.addRoundedRect(in: mainRect, cornerSize: CGSize(width: cornerRadius, height: cornerRadius))

        // Tail
        let tailStart = CGPoint(x: rect.midX - tailWidth/2, y: rect.height - tailHeight)
        let tailTip = CGPoint(x: rect.midX, y: rect.height)
        let tailEnd = CGPoint(x: rect.midX + tailWidth/2, y: rect.height - tailHeight)

        path.move(to: tailStart)
        path.addLine(to: tailTip)
        path.addLine(to: tailEnd)
        path.closeSubpath()

        return path
    }
}

struct AlternatesPopup: View {
    let alternates: [String]
    let selectedIndex: Int?
    let colorScheme: ColorScheme
    let onSelect: (Int) -> Void
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 2) {
            ForEach(Array(alternates.enumerated()), id: \.offset) { index, alt in
                Button(action: {
                    onSelect(index)
                }) {
                    Text(alt)
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(selectedIndex == index ?
                                      (colorScheme == .dark ? Color.blue : Color.blue.opacity(0.3)) :
                                      (colorScheme == .dark ? Color(white: 0.45) : .white))
                        )
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(colorScheme == .dark ? Color(white: 0.35) : Color(white: 0.95))
                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
        )
        .onAppear {
            // Auto-dismiss after 3 seconds if no selection
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                onDismiss()
            }
        }
    }
}

// Safe array access extension
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    VStack {
        HStack {
            KeyButton(title: "A", action: {}, alternates: ["آ", "ا", "ع"])
            KeyButton(title: "B", action: {})
            KeyButton(title: "C", action: {})
        }
        .padding()
    }
    .frame(height: 100)
    .background(Color.gray.opacity(0.3))
}
