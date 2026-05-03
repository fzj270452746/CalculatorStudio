import UIKit

final class CodexExporter {

    func saveJSON(data: Data, title: String) throws -> URL {
        let url = documentsURL.appendingPathComponent(stem(from: title)).appendingPathExtension("json")
        try data.write(to: url, options: .atomic)
        return url
    }

    func saveCSV(text: String, title: String) throws -> URL {
        let url = documentsURL.appendingPathComponent(stem(from: title)).appendingPathExtension("csv")
        guard let data = text.data(using: .utf8) else {
            throw ExportFault(reason: "CSV encoding failed.")
        }
        try data.write(to: url, options: .atomic)
        return url
    }

    func savePDF(blueprint: RuneBlueprint, ledger: QuillLedger) throws -> URL {
        let url = documentsURL.appendingPathComponent(stem(from: blueprint.title)).appendingPathExtension("pdf")
        let bounds = CGRect(x: 0, y: 0, width: 595, height: 842)
        let renderer = UIGraphicsPDFRenderer(bounds: bounds)

        try renderer.writePDF(to: url) { context in
            drawCoverPage(context: context, bounds: bounds, blueprint: blueprint, ledger: ledger)
            drawConfigurationPage(context: context, bounds: bounds, blueprint: blueprint, ledger: ledger)
        }

        return url
    }

    private var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private func stem(from title: String) -> String {
        title.lowercased().replacingOccurrences(of: " ", with: "-")
    }

    private func drawCoverPage(context: UIGraphicsPDFRendererContext, bounds: CGRect, blueprint: RuneBlueprint, ledger: QuillLedger) {
        context.beginPage()
        let palette = [
            UIColor(red: 0.20, green: 0.13, blue: 0.46, alpha: 1),
            UIColor(red: 0.09, green: 0.27, blue: 0.51, alpha: 1),
            UIColor(red: 0.04, green: 0.07, blue: 0.17, alpha: 1)
        ]
        let wash = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: palette.map(\.cgColor) as CFArray, locations: [0, 0.48, 1])
        context.cgContext.drawLinearGradient(wash!, start: CGPoint(x: 0, y: 0), end: CGPoint(x: bounds.maxX, y: bounds.maxY), options: [])

        draw(text: "CALCULATOR STUDIO", rect: CGRect(x: 36, y: 48, width: 240, height: 18), font: UIFont.systemFont(ofSize: 13, weight: .bold), color: UIColor.white.withAlphaComponent(0.74))
        draw(text: blueprint.title, rect: CGRect(x: 36, y: 86, width: 510, height: 40), font: UIFont.systemFont(ofSize: 30, weight: .bold), color: .white)
        draw(text: "RTP simulation report · generated \(stampText())", rect: CGRect(x: 36, y: 128, width: 400, height: 18), font: UIFont.systemFont(ofSize: 14, weight: .medium), color: UIColor.white.withAlphaComponent(0.74))

        let metrics = [
            ("RTP", String(format: "%.2f%%", ledger.rtp * 100), UIColor(red: 0.40, green: 0.86, blue: 0.96, alpha: 1)),
            ("Hit Rate", String(format: "%.2f%%", ledger.hitRate * 100), UIColor(red: 0.95, green: 0.55, blue: 0.65, alpha: 1)),
            ("Top Win", String(format: "%.1fx", ledger.topWin), UIColor(red: 0.98, green: 0.71, blue: 0.33, alpha: 1)),
            ("Mode", ledger.exactUsed ? "Exact" : "Monte Carlo", UIColor(red: 0.77, green: 0.51, blue: 0.99, alpha: 1))
        ]

        for (index, metric) in metrics.enumerated() {
            let originX = 36 + CGFloat(index % 2) * 260
            let originY = 200 + CGFloat(index / 2) * 120
            drawMetricPlate(frame: CGRect(x: originX, y: originY, width: 230, height: 92), title: metric.0, value: metric.1, tint: metric.2)
        }

        drawSectionChip(title: "Design Summary", origin: CGPoint(x: 36, y: 466), tint: UIColor(red: 0.34, green: 0.82, blue: 0.77, alpha: 1))
        draw(text: summaryLine(for: blueprint, ledger: ledger), rect: CGRect(x: 36, y: 498, width: 520, height: 86), font: UIFont.systemFont(ofSize: 16, weight: .medium), color: .white)

        drawSectionChip(title: "Interpretation", origin: CGPoint(x: 36, y: 616), tint: UIColor(red: 0.95, green: 0.43, blue: 0.63, alpha: 1))
        draw(text: reportInsights(for: blueprint, ledger: ledger).joined(separator: "\n\n"), rect: CGRect(x: 36, y: 648, width: 520, height: 140), font: UIFont.systemFont(ofSize: 14, weight: .medium), color: UIColor.white.withAlphaComponent(0.92))
    }

    private func drawConfigurationPage(context: UIGraphicsPDFRendererContext, bounds: CGRect, blueprint: RuneBlueprint, ledger: QuillLedger) {
        context.beginPage()
        UIColor.white.setFill()
        context.cgContext.fill(bounds)

        draw(text: blueprint.title, rect: CGRect(x: 36, y: 42, width: 420, height: 28), font: UIFont.systemFont(ofSize: 24, weight: .bold), color: UIColor(red: 0.08, green: 0.11, blue: 0.22, alpha: 1))
        draw(text: "Configuration and outcome detail", rect: CGRect(x: 36, y: 72, width: 320, height: 18), font: UIFont.systemFont(ofSize: 13, weight: .semibold), color: UIColor.darkGray)

        drawKeyValueBlock(frame: CGRect(x: 36, y: 110, width: 250, height: 122), title: "Core Setup", lines: [
            "Reels: \(blueprint.reelCount)",
            "Rows: \(blueprint.rows)",
            "Bet: \(String(format: "%.2f", blueprint.bet))",
            "Format: \(blueprint.usesWays ? "Ways" : "Lines")",
            "Count: \(blueprint.lines)"
        ])

        drawKeyValueBlock(frame: CGRect(x: 308, y: 110, width: 250, height: 122), title: "Outcome", lines: [
            "Mode: \(ledger.exactUsed ? "Exact enumeration" : "Monte Carlo simulation")",
            "Spins: \(ledger.spinCount)",
            "Top win: \(String(format: "%.1fx", ledger.topWin))",
            "Hit rate: \(String(format: "%.2f%%", ledger.hitRate * 100))",
            "RTP: \(String(format: "%.2f%%", ledger.rtp * 100))"
        ])

        drawSectionLabel(title: "Paytable", point: CGPoint(x: 36, y: 260), tint: UIColor(red: 0.53, green: 0.24, blue: 0.94, alpha: 1))
        let pays = blueprint.tokens.map { token in
            "\(token.mark) [\(token.aura.rawValue)] · weight \(token.weight) · 3: \(token.pays[3] ?? 0) · 4: \(token.pays[4] ?? 0) · 5: \(token.pays[5] ?? 0)"
        }.joined(separator: "\n")
        draw(text: pays, rect: CGRect(x: 36, y: 286, width: 522, height: 154), font: UIFont.monospacedSystemFont(ofSize: 11, weight: .regular), color: UIColor(red: 0.12, green: 0.15, blue: 0.22, alpha: 1))

        drawSectionLabel(title: "Reel Strips", point: CGPoint(x: 36, y: 456), tint: UIColor(red: 0.22, green: 0.65, blue: 0.92, alpha: 1))
        let reels = blueprint.reels.enumerated().map { "R\($0.offset + 1): \($0.element.joined(separator: ", "))" }.joined(separator: "\n")
        draw(text: reels, rect: CGRect(x: 36, y: 482, width: 522, height: 124), font: UIFont.monospacedSystemFont(ofSize: 10.5, weight: .regular), color: UIColor(red: 0.12, green: 0.15, blue: 0.22, alpha: 1))

        drawSectionLabel(title: "Distribution Bands", point: CGPoint(x: 36, y: 626), tint: UIColor(red: 0.95, green: 0.56, blue: 0.46, alpha: 1))
        let bands = ledger.paybandRows.map {
            "\($0.title) · probability \(String(format: "%.3f", $0.probability)) · average win \(String(format: "%.2f", $0.averageWin))"
        }.joined(separator: "\n")
        draw(text: bands, rect: CGRect(x: 36, y: 652, width: 522, height: 100), font: UIFont.systemFont(ofSize: 12, weight: .medium), color: UIColor(red: 0.12, green: 0.15, blue: 0.22, alpha: 1))
    }

    private func drawMetricPlate(frame: CGRect, title: String, value: String, tint: UIColor) {
        let plate = UIBezierPath(roundedRect: frame, cornerRadius: 22)
        tint.withAlphaComponent(0.16).setFill()
        plate.fill()

        let outline = UIBezierPath(roundedRect: frame, cornerRadius: 22)
        tint.withAlphaComponent(0.34).setStroke()
        outline.lineWidth = 1
        outline.stroke()

        draw(text: title.uppercased(), rect: CGRect(x: frame.minX + 16, y: frame.minY + 14, width: frame.width - 32, height: 14), font: UIFont.systemFont(ofSize: 12, weight: .bold), color: tint)
        draw(text: value, rect: CGRect(x: frame.minX + 16, y: frame.minY + 40, width: frame.width - 32, height: 30), font: UIFont.systemFont(ofSize: 24, weight: .bold), color: .white)
    }

    private func drawSectionChip(title: String, origin: CGPoint, tint: UIColor) {
        let rect = CGRect(x: origin.x, y: origin.y, width: 132, height: 24)
        let chip = UIBezierPath(roundedRect: rect, cornerRadius: 12)
        tint.withAlphaComponent(0.18).setFill()
        chip.fill()
        draw(text: title, rect: rect.insetBy(dx: 10, dy: 4), font: UIFont.systemFont(ofSize: 11, weight: .bold), color: tint)
    }

    private func drawSectionLabel(title: String, point: CGPoint, tint: UIColor) {
        draw(text: title, rect: CGRect(x: point.x, y: point.y, width: 220, height: 18), font: UIFont.systemFont(ofSize: 14, weight: .bold), color: tint)
    }

    private func drawKeyValueBlock(frame: CGRect, title: String, lines: [String]) {
        let plate = UIBezierPath(roundedRect: frame, cornerRadius: 18)
        UIColor(red: 0.96, green: 0.97, blue: 0.99, alpha: 1).setFill()
        plate.fill()

        UIColor(red: 0.87, green: 0.89, blue: 0.94, alpha: 1).setStroke()
        plate.lineWidth = 1
        plate.stroke()

        draw(text: title, rect: CGRect(x: frame.minX + 14, y: frame.minY + 14, width: frame.width - 28, height: 18), font: UIFont.systemFont(ofSize: 13, weight: .bold), color: UIColor(red: 0.10, green: 0.13, blue: 0.22, alpha: 1))
        draw(text: lines.joined(separator: "\n"), rect: CGRect(x: frame.minX + 14, y: frame.minY + 38, width: frame.width - 28, height: frame.height - 50), font: UIFont.systemFont(ofSize: 12, weight: .medium), color: UIColor(red: 0.20, green: 0.23, blue: 0.31, alpha: 1))
    }

    private func summaryLine(for blueprint: RuneBlueprint, ledger: QuillLedger) -> String {
        "This \(blueprint.reelCount)x\(blueprint.rows) configuration runs in \(blueprint.usesWays ? "ways" : "line") mode with \(blueprint.lines) active \(blueprint.usesWays ? "paths" : "lanes"). The analyzed outcome produced \(String(format: "%.2f%%", ledger.rtp * 100)) RTP and a \(String(format: "%.2f%%", ledger.hitRate * 100)) hit rate over \(ledger.spinCount) evaluated spins."
    }

    private func reportInsights(for blueprint: RuneBlueprint, ledger: QuillLedger) -> [String] {
        let cadence: String
        if ledger.hitRate < 0.18 {
            cadence = "• Cadence is intentionally sparse, which supports a more dramatic session profile but may require stronger feedback on near-miss moments."
        } else if ledger.hitRate < 0.34 {
            cadence = "• Cadence sits in a middle lane that should feel readable for most prototype reviews without overwhelming the reward texture."
        } else {
            cadence = "• Cadence is brisk, so frequent reinforcement is likely. Watch for overexposure if low-tier wins stack too often."
        }

        let swing = ledger.topWin >= 100
            ? "• Top-win headroom is notably high, which suits a high-volatility fantasy and marketing-friendly jackpot language."
            : "• Top-win headroom is restrained to moderate, which should read as more approachable in early sessions."

        let topology = blueprint.usesWays
            ? "• Ways coverage is active across multiple rows per reel, increasing perceived action before any paytable escalation."
            : "• Fixed line topology keeps positional intent clearer, making paytable adjustments easier to read during tuning reviews."

        return [cadence, swing, topology]
    }

    private func stampText() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }

    private func draw(text: String, rect: CGRect, font: UIFont, color: UIColor) {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: style
        ]
        text.draw(with: rect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil)
    }
}

private struct ExportFault: LocalizedError {
    let reason: String
    var errorDescription: String? { reason }
}
