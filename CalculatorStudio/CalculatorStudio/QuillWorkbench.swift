import Foundation
import UIKit

enum SigilAura: String, Codable, CaseIterable {
    case regular
    case wild
    case scatter
}

struct SigilToken: Codable, Hashable {
    let mark: String
    let weight: Int
    let pays: [Int: Double]
    let aura: SigilAura
}

struct WaylineTrack: Codable, Hashable {
    let title: String
    let lane: [Int]
}

struct WaysCover: Codable, Hashable {
    let title: String
    let columns: [[Int]]
}

struct RuneBlueprint: Codable {
    let title: String
    var reels: [[String]]
    var rows: Int
    var bet: Double
    var lineBet: Double
    var tokens: [SigilToken]
    var waylines: [WaylineTrack]
    var waysCover: WaysCover?
    var usesWays: Bool
    var volatilityBias: CGFloat

    var reelCount: Int { reels.count }

    var lines: Int {
        if usesWays {
            let cover = waysCover?.columns ?? Array(repeating: Array(0..<rows), count: reelCount)
            return max(cover.reduce(1) { $0 * max($1.count, 1) }, 1)
        }
        return max(waylines.count, 1)
    }

    var baseRTP: Double {
        0.90 + Double(volatilityBias) * 0.08
    }

    static let sampleDeck: [RuneBlueprint] = [
        RuneBlueprint(
            title: "Aurora Low Swing",
            reels: [
                ["A", "K", "Q", "J", "W", "A", "K", "Q", "B", "A"],
                ["A", "Q", "K", "J", "A", "W", "Q", "K", "B", "A"],
                ["K", "A", "Q", "W", "J", "A", "B", "Q", "K", "A"],
                ["Q", "A", "K", "J", "W", "A", "K", "B", "Q", "A"],
                ["A", "K", "Q", "J", "A", "W", "K", "Q", "B", "A"]
            ],
            rows: 3,
            bet: 1,
            lineBet: 0.04,
            tokens: SigilToken.defaultDeck,
            waylines: WaylineTrack.classicTwenty,
            waysCover: .allRows(reels: 5, rows: 3),
            usesWays: false,
            volatilityBias: 0.32
        ),
        RuneBlueprint(
            title: "Vegas Stripe",
            reels: [
                ["A", "K", "Q", "J", "A", "K", "W", "Q", "B", "A", "K", "S"],
                ["K", "Q", "A", "J", "W", "A", "B", "K", "Q", "S", "A", "J"],
                ["Q", "A", "K", "W", "J", "B", "A", "Q", "K", "S", "J", "A"],
                ["A", "K", "Q", "J", "W", "A", "B", "K", "Q", "S", "A", "J"],
                ["K", "A", "Q", "W", "J", "A", "K", "B", "Q", "S", "A", "J"]
            ],
            rows: 3,
            bet: 1,
            lineBet: 0.05,
            tokens: SigilToken.defaultDeck,
            waylines: WaylineTrack.classicTwenty,
            waysCover: .allRows(reels: 5, rows: 3),
            usesWays: false,
            volatilityBias: 0.47
        ),
        RuneBlueprint(
            title: "Meteor Bonus Heavy",
            reels: [
                ["A", "K", "Q", "J", "W", "B", "A", "K", "Q", "S", "B", "A"],
                ["K", "Q", "A", "W", "J", "B", "A", "K", "S", "Q", "B", "A"],
                ["Q", "A", "K", "W", "B", "J", "A", "Q", "S", "K", "B", "A"],
                ["A", "K", "Q", "J", "W", "B", "A", "S", "Q", "K", "B", "A"],
                ["K", "A", "Q", "W", "J", "B", "A", "K", "Q", "S", "B", "A"]
            ],
            rows: 4,
            bet: 2,
            lineBet: 0.05,
            tokens: SigilToken.defaultDeck,
            waylines: WaylineTrack.classicTwenty,
            waysCover: .allRows(reels: 5, rows: 4),
            usesWays: true,
            volatilityBias: 0.74
        ),
        RuneBlueprint(
            title: "Nebula Ladder",
            reels: [
                ["A", "K", "Q", "J", "A", "Q", "K", "J", "W", "A", "B"],
                ["K", "Q", "A", "J", "K", "A", "Q", "W", "J", "A", "B"],
                ["Q", "A", "K", "J", "Q", "W", "A", "K", "J", "A", "B"],
                ["J", "K", "Q", "A", "W", "Q", "A", "K", "B", "J", "A"],
                ["A", "Q", "K", "J", "A", "W", "K", "Q", "B", "A", "S"]
            ],
            rows: 3,
            bet: 1,
            lineBet: 0.04,
            tokens: SigilToken.defaultDeck,
            waylines: WaylineTrack.classicTwenty,
            waysCover: .allRows(reels: 5, rows: 3),
            usesWays: false,
            volatilityBias: 0.28
        ),
        RuneBlueprint(
            title: "Quartz Torrent",
            reels: [
                ["A", "K", "Q", "W", "B", "A", "K", "Q", "S", "J", "B", "A"],
                ["K", "Q", "A", "W", "B", "K", "A", "S", "Q", "J", "B", "A"],
                ["Q", "A", "K", "W", "B", "Q", "A", "K", "S", "J", "B", "A"],
                ["A", "K", "Q", "W", "B", "A", "S", "Q", "K", "J", "B", "A"],
                ["K", "A", "Q", "W", "B", "K", "A", "Q", "S", "J", "B", "A"]
            ],
            rows: 4,
            bet: 1.5,
            lineBet: 0.05,
            tokens: SigilToken.defaultDeck,
            waylines: WaylineTrack.classicTwenty,
            waysCover: .allRows(reels: 5, rows: 4),
            usesWays: true,
            volatilityBias: 0.81
        ),
        RuneBlueprint(
            title: "Cinder Relay",
            reels: [
                ["A", "K", "Q", "J", "A", "K", "Q", "J", "W", "A"],
                ["K", "Q", "A", "J", "K", "Q", "A", "J", "B", "A"],
                ["Q", "A", "K", "J", "Q", "A", "K", "J", "W", "A"],
                ["J", "K", "Q", "A", "J", "K", "Q", "A", "B", "A"],
                ["A", "Q", "K", "J", "A", "Q", "K", "J", "S", "A"]
            ],
            rows: 3,
            bet: 0.8,
            lineBet: 0.04,
            tokens: SigilToken.defaultDeck,
            waylines: WaylineTrack.classicTwenty,
            waysCover: .allRows(reels: 5, rows: 3),
            usesWays: false,
            volatilityBias: 0.38
        )
    ]
}

extension WaysCover {
    static func allRows(reels: Int, rows: Int) -> WaysCover {
        WaysCover(title: "All Ways", columns: Array(repeating: Array(0..<rows), count: reels))
    }
}

extension SigilToken {
    static let defaultDeck: [SigilToken] = [
        .init(mark: "A", weight: 20, pays: [3: 5, 4: 20, 5: 80], aura: .regular),
        .init(mark: "K", weight: 18, pays: [3: 4, 4: 15, 5: 60], aura: .regular),
        .init(mark: "Q", weight: 16, pays: [3: 3, 4: 12, 5: 40], aura: .regular),
        .init(mark: "J", weight: 15, pays: [3: 2.5, 4: 10, 5: 30], aura: .regular),
        .init(mark: "W", weight: 8, pays: [3: 12, 4: 50, 5: 200], aura: .wild),
        .init(mark: "B", weight: 6, pays: [3: 20, 4: 80, 5: 320], aura: .scatter),
        .init(mark: "S", weight: 5, pays: [:], aura: .scatter)
    ]
}

extension WaylineTrack {
    static let classicTwenty: [WaylineTrack] = [
        .init(title: "L1", lane: [0, 0, 0, 0, 0]), .init(title: "L2", lane: [1, 1, 1, 1, 1]),
        .init(title: "L3", lane: [2, 2, 2, 2, 2]), .init(title: "L4", lane: [0, 1, 2, 1, 0]),
        .init(title: "L5", lane: [2, 1, 0, 1, 2]), .init(title: "L6", lane: [0, 0, 1, 0, 0]),
        .init(title: "L7", lane: [2, 2, 1, 2, 2]), .init(title: "L8", lane: [1, 0, 0, 0, 1]),
        .init(title: "L9", lane: [1, 2, 2, 2, 1]), .init(title: "L10", lane: [0, 1, 1, 1, 0]),
        .init(title: "L11", lane: [2, 1, 1, 1, 2]), .init(title: "L12", lane: [1, 1, 0, 1, 1]),
        .init(title: "L13", lane: [1, 1, 2, 1, 1]), .init(title: "L14", lane: [0, 1, 0, 1, 0]),
        .init(title: "L15", lane: [2, 1, 2, 1, 2]), .init(title: "L16", lane: [1, 0, 1, 2, 1]),
        .init(title: "L17", lane: [1, 2, 1, 0, 1]), .init(title: "L18", lane: [0, 2, 0, 2, 0]),
        .init(title: "L19", lane: [2, 0, 2, 0, 2]), .init(title: "L20", lane: [1, 0, 2, 0, 1])
    ]
}

struct QuillLedger {
    struct Barlet {
        let title: String
        let amount: CGFloat
        let tint: UIColor
    }

    struct Slice {
        let title: String
        let amount: CGFloat
        let tint: UIColor
    }

    let rtp: Double
    let hitRate: Double
    let topWin: Double
    let spinCount: Int
    let exactUsed: Bool
    let distribution: [Barlet]
    let contribution: [Slice]
    let returnTrail: [CGFloat]
    let paybandRows: [PaybandRow]
    let rawPayouts: [Double]
}

struct PaybandRow {
    let title: String
    let probability: Double
    let averageWin: Double
}

final class QuillWorkbench {

    struct HaltSignal: Error {}

    private let tonePool: [UIColor] = [
        UIColor(red: 0.98, green: 0.45, blue: 0.55, alpha: 1),
        UIColor(red: 0.37, green: 0.80, blue: 0.99, alpha: 1),
        UIColor(red: 0.56, green: 0.88, blue: 0.61, alpha: 1),
        UIColor(red: 0.95, green: 0.77, blue: 0.37, alpha: 1),
        UIColor(red: 0.75, green: 0.53, blue: 0.99, alpha: 1),
        UIColor(red: 0.31, green: 0.95, blue: 0.80, alpha: 1)
    ]

    func inspect(blueprint: RuneBlueprint, spins: Int, exact: Bool, shouldHalt: (() -> Bool)? = nil) throws -> QuillLedger {
        let sanitizedSpins = max(100, min(spins, 20_000))
        if exact, let precise = try exactLedger(for: blueprint, shouldHalt: shouldHalt) {
            return precise
        }
        return try monteCarloLedger(for: blueprint, spins: sanitizedSpins, shouldHalt: shouldHalt)
    }

    func serializeDeck(_ blueprint: RuneBlueprint) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(blueprint)
    }

    func csvSheet(for blueprint: RuneBlueprint, ledger: QuillLedger) -> String {
        var rows: [String] = [
            "title,rtp,hit_rate,top_win,spins,mode,bet,rows,reels,lines",
            "\(escape(blueprint.title)),\(ledger.rtp),\(ledger.hitRate),\(ledger.topWin),\(ledger.spinCount),\(ledger.exactUsed ? "exact" : "monte_carlo"),\(blueprint.bet),\(blueprint.rows),\(blueprint.reelCount),\(blueprint.lines)",
            "",
            "band,probability,average_win"
        ]

        rows.append(contentsOf: ledger.paybandRows.map { "\(escape($0.title)),\($0.probability),\($0.averageWin)" })
        rows.append("")
        rows.append("symbol,weight,aura,pay_3,pay_4,pay_5")
        rows.append(contentsOf: blueprint.tokens.map {
            "\($0.mark),\($0.weight),\($0.aura.rawValue),\($0.pays[3] ?? 0),\($0.pays[4] ?? 0),\($0.pays[5] ?? 0)"
        })
        return rows.joined(separator: "\n")
    }

    private func exactLedger(for blueprint: RuneBlueprint, shouldHalt: (() -> Bool)?) throws -> QuillLedger? {
        let footprintLimit = 250_000
        var footprint = 1

        for reel in blueprint.reels {
            let branchCount = boundedPower(base: reel.count, exponent: blueprint.rows, limit: footprintLimit)
            guard branchCount > 0 else { return nil }

            let (next, overflow) = footprint.multipliedReportingOverflow(by: branchCount)
            if overflow || next > footprintLimit {
                return nil
            }
            footprint = next
        }

        guard footprint <= 250_000, blueprint.rows <= 3, blueprint.reelCount <= 5 else { return nil }

        let windows = blueprint.reels.map { reelWindows(for: $0, rows: blueprint.rows) }
        var payouts: [Double] = []
        var picks: [[[String]]] = Array(repeating: [], count: blueprint.reelCount)
        try enumerateWindows(windows, at: 0, picks: &picks, shouldHalt: shouldHalt) { stack in
            payouts.append(self.settle(windowStack: stack, blueprint: blueprint))
        }
        return forgeLedger(from: payouts, blueprint: blueprint, exactUsed: true)
    }

    private func monteCarloLedger(for blueprint: RuneBlueprint, spins: Int, shouldHalt: (() -> Bool)?) throws -> QuillLedger {
        var payouts: [Double] = []
        payouts.reserveCapacity(spins)
        let weights = blueprint.tokens.reduce(into: [String: Int]()) { $0[$1.mark] = $1.weight }
        let preparedReels = blueprint.reels.map { rebuild(reel: $0, weights: weights) }

        for index in 0..<spins {
            if index % 64 == 0, shouldHalt?() == true {
                throw HaltSignal()
            }
            let stack = preparedReels.map { reel -> [[String]] in
                [windowFromSpin(reel: reel, rows: blueprint.rows)]
            }
            payouts.append(settle(windowStack: stack, blueprint: blueprint))
        }
        return forgeLedger(from: payouts, blueprint: blueprint, exactUsed: false)
    }

    private func settle(windowStack: [[[String]]], blueprint: RuneBlueprint) -> Double {
        let windows = windowStack.map { $0[0] }
        return blueprint.usesWays ? settleWays(windows: windows, blueprint: blueprint) : settleLines(windows: windows, blueprint: blueprint)
    }

    private func settleLines(windows: [[String]], blueprint: RuneBlueprint) -> Double {
        var total = 0.0
        for line in blueprint.waylines where line.lane.count == blueprint.reelCount {
            let marks = zip(windows, line.lane).map { reel, row in reel[safe: row] ?? "" }
            total += evaluate(sequence: marks, stake: blueprint.lineBet, tokens: blueprint.tokens)
        }
        total += scatterWin(in: windows, blueprint: blueprint)
        return total
    }

    private func settleWays(windows: [[String]], blueprint: RuneBlueprint) -> Double {
        let cover = blueprint.waysCover?.columns ?? Array(repeating: Array(0..<blueprint.rows), count: blueprint.reelCount)
        let active = blueprint.tokens.filter { $0.aura != .scatter }
        let wild = wildMark(in: blueprint.tokens)
        var total = 0.0

        for token in active {
            var chain = 0
            var multiplier = 1.0

            for reelIndex in 0..<windows.count {
                let rows = cover[safe: reelIndex] ?? []
                var hitCount = 0
                for row in rows {
                    guard let mark = windows[reelIndex][safe: row] else { continue }
                    if mark == token.mark || mark == wild {
                        hitCount += 1
                    }
                }
                let count = Double(hitCount)
                guard count > 0 else { break }
                chain += 1
                multiplier *= count
            }

            if chain >= 3, let pay = token.pays[chain] {
                total += pay * blueprint.lineBet * multiplier
            }
        }

        total += scatterWin(in: windows, blueprint: blueprint)
        return total
    }

    private func evaluate(sequence: [String], stake: Double, tokens: [SigilToken]) -> Double {
        let wild = wildMark(in: tokens)
        guard let base = sequence.first(where: { $0 != wild }) else { return 0 }
        var chain = 0
        for mark in sequence {
            if mark == base || mark == wild { chain += 1 } else { break }
        }
        guard chain >= 3,
              let token = tokens.first(where: { $0.mark == base }),
              let pay = token.pays[chain] else { return 0 }
        return pay * stake
    }

    private func scatterWin(in windows: [[String]], blueprint: RuneBlueprint) -> Double {
        let scatters = blueprint.tokens.filter { $0.aura == .scatter }
        guard !scatters.isEmpty else { return 0 }

        var counts: [String: Int] = [:]
        for reel in windows {
            for mark in reel {
                counts[mark, default: 0] += 1
            }
        }

        var total = 0.0
        for token in scatters {
            let count = counts[token.mark, default: 0]
            if count >= 3, let pay = token.pays[min(count, 5)] ?? token.pays[3] {
                total += pay * blueprint.lineBet
            }
        }
        return total
    }

    private func wildMark(in tokens: [SigilToken]) -> String {
        tokens.first(where: { $0.aura == .wild })?.mark ?? "W"
    }

    private func forgeLedger(from payouts: [Double], blueprint: RuneBlueprint, exactUsed: Bool) -> QuillLedger {
        let spins = max(payouts.count, 1)
        let spend = Double(spins) * blueprint.bet
        let earned = payouts.reduce(0, +)
        let rtp = spend == 0 ? 0 : earned / spend
        let hits = Double(payouts.filter { $0 > 0 }.count) / Double(spins)
        let topWin = payouts.max() ?? 0

        var drift = 0.0
        var trail: [CGFloat] = []
        let stride = max(spins / 24, 1)
        for (index, payout) in payouts.enumerated() {
            drift += payout - blueprint.bet
            if index % stride == 0 { trail.append(CGFloat(drift / Double(index + 1))) }
        }

        let grouped = bucketize(payouts, bet: blueprint.bet)
        let bars = grouped.enumerated().map { offset, pair in
            QuillLedger.Barlet(title: pair.0, amount: CGFloat(pair.1) / CGFloat(spins), tint: tonePool[offset % tonePool.count])
        }

        return QuillLedger(
            rtp: rtp,
            hitRate: hits,
            topWin: blueprint.bet == 0 ? topWin : topWin / blueprint.bet,
            spinCount: spins,
            exactUsed: exactUsed,
            distribution: bars,
            contribution: symbolSlices(from: blueprint),
            returnTrail: normalizeTrail(trail),
            paybandRows: paybands(from: payouts, bet: blueprint.bet),
            rawPayouts: payouts
        )
    }

    private func symbolSlices(from blueprint: RuneBlueprint) -> [QuillLedger.Slice] {
        let totalWeight = max(blueprint.tokens.reduce(0) { $0 + $1.weight }, 1)
        return blueprint.tokens.prefix(5).enumerated().map { offset, token in
            QuillLedger.Slice(title: token.mark, amount: CGFloat(token.weight) / CGFloat(totalWeight), tint: tonePool[offset % tonePool.count])
        }
    }

    private func paybands(from payouts: [Double], bet: Double) -> [PaybandRow] {
        let bands: [(String, (Double) -> Bool)] = [
            ("Miss", { $0 == 0 }),
            ("Small", { $0 > 0 && $0 < bet * 2 }),
            ("Win", { $0 >= bet * 2 && $0 < bet * 10 }),
            ("Big", { $0 >= bet * 10 })
        ]
        return bands.map { title, filter in
            let shard = payouts.filter(filter)
            return PaybandRow(
                title: title,
                probability: payouts.isEmpty ? 0 : Double(shard.count) / Double(payouts.count),
                averageWin: shard.isEmpty ? 0 : shard.reduce(0, +) / Double(shard.count)
            )
        }
    }

    private func bucketize(_ payouts: [Double], bet: Double) -> [(String, Int)] {
        var rack: [String: Int] = [:]
        for payout in payouts {
            let key: String
            if payout == 0 { key = "Miss" }
            else {
                let ratio = payout / max(bet, 0.01)
                switch ratio {
                case ..<2: key = "x1"
                case ..<5: key = "x2"
                case ..<10: key = "x5"
                case ..<25: key = "x10"
                default: key = "x25+"
                }
            }
            rack[key, default: 0] += 1
        }
        let order = ["Miss", "x1", "x2", "x5", "x10", "x25+"]
        return order.compactMap { key in
            guard let amount = rack[key] else { return nil }
            return (key, amount)
        }
    }

    private func reelWindows(for reel: [String], rows: Int) -> [[[String]]] {
        reel.indices.map { [window(reel: reel, start: $0, rows: rows)] }
    }

    private func windowFromSpin(reel: [String], rows: Int) -> [String] {
        window(reel: reel, start: Int.random(in: 0..<reel.count), rows: rows)
    }

    private func window(reel: [String], start: Int, rows: Int) -> [String] {
        (0..<rows).map { reel[(start + $0) % reel.count] }
    }

    private func rebuild(reel: [String], weights: [String: Int]) -> [String] {
        var rebuilt: [String] = []
        for mark in reel {
            let copies = max(1, Int(round(Double(max(weights[mark] ?? 1, 1)) / 10.0)))
            for _ in 0..<copies { rebuilt.append(mark) }
        }
        return rebuilt.shuffled()
    }

    private func enumerateWindows(_ shelves: [[[[String]]]], at index: Int, picks: inout [[[String]]], shouldHalt: (() -> Bool)?, visit: ([[[String]]]) -> Void) throws {
        if shouldHalt?() == true {
            throw HaltSignal()
        }
        if index == shelves.count { visit(picks); return }
        for window in shelves[index] {
            picks[index] = window
            try enumerateWindows(shelves, at: index + 1, picks: &picks, shouldHalt: shouldHalt, visit: visit)
        }
    }

    private func normalizeTrail(_ entries: [CGFloat]) -> [CGFloat] {
        guard let min = entries.min(), let max = entries.max(), max != min else {
            return entries.isEmpty ? [0.5, 0.52, 0.49, 0.56] : Array(repeating: 0.5, count: entries.count)
        }
        return entries.map { ($0 - min) / (max - min) }
    }

    private func boundedPower(base: Int, exponent: Int, limit: Int) -> Int {
        guard base > 0, exponent >= 0 else { return 0 }
        if exponent == 0 { return 1 }

        var result = 1
        for _ in 0..<exponent {
            let (next, overflow) = result.multipliedReportingOverflow(by: base)
            if overflow || next > limit {
                return limit + 1
            }
            result = next
        }
        return result
    }

    private func escape(_ text: String) -> String {
        "\"\(text.replacingOccurrences(of: "\"", with: "\"\""))\""
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
