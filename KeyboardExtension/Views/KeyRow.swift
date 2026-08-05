import Foundation
import SwiftUI

/// A QWERTY row whose visible key caps stay in their familiar positions while
/// the complete row is partitioned into contiguous touch cells. Small boundary
/// corrections favor common Finglish letters without moving or reordering keys.
struct KeyRow: View {
    let keys: [String]
    let previousCharacter: Character?
    let isWordStart: Bool
    var visualHorizontalInset: CGFloat = 0
    var rowHeight: CGFloat = 49
    var keyHeight: CGFloat = 42
    let title: (String) -> String
    let action: (String) -> Void
    let alternates: [String: [String]]
    let onAlternateSelected: (String) -> Void

    var body: some View {
        GeometryReader { geometry in
            let layout = KeyboardTouchModel.layout(
                keys: keys,
                width: geometry.size.width,
                visualHorizontalInset: visualHorizontalInset,
                previousCharacter: previousCharacter,
                isWordStart: isWordStart
            )

            ZStack(alignment: .topLeading) {
                ForEach(Array(layout.cells.enumerated()), id: \.offset) { index, cell in
                    let key = keys[index]
                    KeyButton(
                        title: title(key),
                        action: { action(key) },
                        alternates: alternates[key] ?? [],
                        onAlternateSelected: onAlternateSelected,
                        visualWidth: layout.visualKeyWidth,
                        visualHeight: keyHeight,
                        visualCenterOffset: cell.visualCenterX - cell.midX,
                        cellHeight: rowHeight
                    )
                    .frame(width: cell.width, height: rowHeight)
                    .offset(x: cell.minX)
                }
            }
            .frame(width: geometry.size.width, height: rowHeight, alignment: .topLeading)
        }
        .frame(height: rowHeight)
        // Persian suggestions remain RTL; the Latin QWERTY surface must not flip.
        .environment(\.layoutDirection, .leftToRight)
    }
}

struct KeyboardTouchCell {
    let minX: CGFloat
    let maxX: CGFloat
    let visualCenterX: CGFloat

    var width: CGFloat { maxX - minX }
    var midX: CGFloat { (minX + maxX) / 2 }
}

struct KeyboardTouchLayout {
    let cells: [KeyboardTouchCell]
    let visualKeyWidth: CGFloat
}

enum KeyboardTouchModel {
    private static let visualGap: CGFloat = 6
    private static let maximumBoundaryShift: CGFloat = 3
    private static let probabilityFloor = 0.0005

    // Initial prior generated from the 3,003 reachable, single-word dictionary
    // keys. It is intentionally a bounded editorial prior, not user telemetry.
    private static let characterPrior: [String: Double] = [
        "a": 0.161108, "b": 0.036429, "c": 0.011919, "d": 0.043504,
        "e": 0.083627, "f": 0.013371, "g": 0.021341, "h": 0.077164,
        "i": 0.076143, "j": 0.007548, "k": 0.034449, "l": 0.025597,
        "m": 0.060911, "n": 0.069872, "o": 0.065544, "p": 0.010671,
        "q": 0.001459, "r": 0.050789, "s": 0.051386, "t": 0.043759,
        "u": 0.019098, "v": 0.007684, "w": 0.002947, "x": 0.000217,
        "y": 0.011898, "z": 0.011564,
    ]

    // Word starts have a very different distribution from letters inside a word.
    private static let wordStartPrior: [String: Double] = [
        "a": 0.068557, "b": 0.117026, "c": 0.036582, "d": 0.062307,
        "e": 0.016310, "f": 0.021021, "g": 0.039766, "h": 0.043821,
        "i": 0.015355, "j": 0.017775, "k": 0.095429, "l": 0.011053,
        "m": 0.121387, "n": 0.073287, "o": 0.019077, "p": 0.035907,
        "q": 0.002940, "r": 0.022729, "s": 0.081145, "t": 0.044393,
        "u": 0.008028, "v": 0.012392, "w": 0.006958, "x": 0.000000,
        "y": 0.012650, "z": 0.014104,
    ]

    // Only strong, well-supported transitions are blended in. Missing letters
    // retain the global prior, and every boundary correction remains capped.
    private static let transitionPrior: [Character: [String: Double]] = [
        "c": ["h": 0.61469],
        "g": ["h": 0.35886],
        "h": ["a": 0.38661, "e": 0.14418, "o": 0.14496],
        "k": ["h": 0.50802],
        "m": ["i": 0.44409, "a": 0.22992],
        "o": ["o": 0.20947, "n": 0.18711, "r": 0.11942],
        "s": ["h": 0.41027, "t": 0.20078],
    ]

    static func layout(
        keys: [String],
        width: CGFloat,
        visualHorizontalInset: CGFloat,
        previousCharacter: Character?,
        isWordStart: Bool
    ) -> KeyboardTouchLayout {
        guard !keys.isEmpty, width > 0 else {
            return KeyboardTouchLayout(cells: [], visualKeyWidth: 0)
        }

        let count = keys.count
        let inset = min(max(visualHorizontalInset, 0), width / 3)
        let innerWidth = max(width - inset * 2, CGFloat(count))
        let totalGap = visualGap * CGFloat(max(count - 1, 0))
        let visualKeyWidth = max((innerWidth - totalGap) / CGFloat(count), 1)
        let visualStride = visualKeyWidth + visualGap
        let visualCenters = (0..<count).map {
            inset + visualKeyWidth / 2 + CGFloat($0) * visualStride
        }

        var boundaries: [CGFloat] = [0]
        if count > 1 {
            for index in 0..<(count - 1) {
                let midpoint = (visualCenters[index] + visualCenters[index + 1]) / 2
                let leftPriority = priority(
                    for: keys[index],
                    previousCharacter: previousCharacter,
                    isWordStart: isWordStart
                )
                let rightPriority = priority(
                    for: keys[index + 1],
                    previousCharacter: previousCharacter,
                    isWordStart: isWordStart
                )
                let ratio = max(leftPriority, probabilityFloor) /
                    max(rightPriority, probabilityFloor)
                let shift = maximumBoundaryShift * CGFloat(
                    tanh(0.5 * log(ratio))
                )

                // Preserve at least one point for every remaining touch cell.
                let minimum = boundaries.last! + 1
                let remainingCells = CGFloat(count - index - 1)
                let maximum = width - remainingCells
                boundaries.append(min(max(midpoint + shift, minimum), maximum))
            }
        }
        boundaries.append(width)

        let cells = (0..<count).map { index in
            KeyboardTouchCell(
                minX: boundaries[index],
                maxX: boundaries[index + 1],
                visualCenterX: visualCenters[index]
            )
        }
        return KeyboardTouchLayout(cells: cells, visualKeyWidth: visualKeyWidth)
    }

    private static func priority(
        for key: String,
        previousCharacter: Character?,
        isWordStart: Bool
    ) -> Double {
        let base = characterPrior[key] ?? probabilityFloor
        if isWordStart {
            return wordStartPrior[key] ?? probabilityFloor
        }

        guard let previousCharacter,
              let transitions = transitionPrior[previousCharacter] else {
            return base
        }

        let contextual = transitions[key] ?? base
        return max(base * 0.4 + contextual * 0.6, probabilityFloor)
    }
}
