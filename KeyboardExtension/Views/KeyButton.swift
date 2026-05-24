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
    @State private var longPressWorkItem: DispatchWorkItem?
    @State private var didTriggerLongPress = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(keyColor)
                        .shadow(color: Color.black.opacity(0.25), radius: 0, x: 0, y: 1)

                    Text(title)
                        .font(.system(size: 22, weight: .light))
                        .foregroundColor(textColor)
                }
                .scaleEffect(isPressed ? 0.92 : 1.0)
                .brightness(isPressed ? 0.1 : 0)
                .animation(.spring(response: 0.15, dampingFraction: 0.6), value: isPressed)

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
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        handlePressChanged(value, geometry: geometry)
                    }
                    .onEnded { value in
                        handlePressEnded(value, geometry: geometry)
                    }
            )
        }
        .frame(height: 42)
        .onDisappear {
            resetPressState()
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

    private func handlePressChanged(_ value: DragGesture.Value, geometry: GeometryProxy) {
        if !isPressed {
            beginPress()
        }

        if showAlternates {
            selectedAlternate = alternateIndex(at: value.location, geometry: geometry)
        }
    }

    private func handlePressEnded(_ value: DragGesture.Value, geometry: GeometryProxy) {
        longPressWorkItem?.cancel()

        if showAlternates {
            let selectedIndex = alternateIndex(at: value.location, geometry: geometry) ?? selectedAlternate
            if let selectedIndex, let alt = alternates[safe: selectedIndex] {
                onAlternateSelected?(alt)
            } else if isInsideKey(value.location, geometry: geometry) {
                action()
            }
        } else if !didTriggerLongPress {
            action()
        }

        resetPressState()
    }

    private func beginPress() {
        isPressed = true
        showPopup = true
        didTriggerLongPress = false
        selectedAlternate = nil
        triggerHaptic(.light)

        let workItem = DispatchWorkItem {
            guard isPressed, !alternates.isEmpty else { return }
            didTriggerLongPress = true
            showPopup = false
            showAlternates = true
            selectedAlternate = nil
            triggerHaptic(.medium)
        }
        longPressWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45, execute: workItem)
    }

    private func resetPressState() {
        longPressWorkItem?.cancel()
        longPressWorkItem = nil
        isPressed = false
        showAlternates = false
        selectedAlternate = nil
        didTriggerLongPress = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            if !isPressed && !showAlternates {
                showPopup = false
            }
        }
    }

    private func alternateIndex(at location: CGPoint, geometry: GeometryProxy) -> Int? {
        guard !alternates.isEmpty, location.y < geometry.size.height * 0.35 else { return nil }

        let itemWidth: CGFloat = 44
        let spacing: CGFloat = 2
        let horizontalPadding: CGFloat = 4
        let totalWidth = CGFloat(alternates.count) * itemWidth +
            CGFloat(max(alternates.count - 1, 0)) * spacing +
            horizontalPadding * 2
        let contentLeft = geometry.size.width / 2 - totalWidth / 2 + horizontalPadding
        let relativeX = location.x - contentLeft
        let stride = itemWidth + spacing
        let index = Int(floor(relativeX / stride))
        let cellX = relativeX - CGFloat(index) * stride

        guard index >= 0, index < alternates.count, cellX >= 0, cellX <= itemWidth else {
            return nil
        }

        return index
    }

    private func isInsideKey(_ location: CGPoint, geometry: GeometryProxy) -> Bool {
        location.x >= 0 &&
            location.x <= geometry.size.width &&
            location.y >= 0 &&
            location.y <= geometry.size.height
    }

    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
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
