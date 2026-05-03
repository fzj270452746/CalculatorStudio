import UIKit

struct GuideShard {
    let title: String
    let detail: String
    let tint: UIColor

    static let sampleDeck: [GuideShard] = [
        .init(title: "RTP", detail: "Return to player is long-run expected return divided by total wager, useful for balancing but never the whole player story.", tint: UIColor(red: 0.39, green: 0.84, blue: 0.95, alpha: 1)),
        .init(title: "Exact vs Monte Carlo", detail: "Exact mode enumerates manageable reel spaces. Monte Carlo samples broader spaces faster and is safer for larger prototypes.", tint: UIColor(red: 0.81, green: 0.50, blue: 0.99, alpha: 1)),
        .init(title: "Paytable Tuning", detail: "Regular symbol stairs shape baseline rhythm, while wild and scatter behavior usually shape headline volatility.", tint: UIColor(red: 0.98, green: 0.72, blue: 0.33, alpha: 1)),
        .init(title: "Ways Coverage", detail: "Expanding active rows per reel lifts perceived activity quickly, so adjust coverage with care before raising raw payouts.", tint: UIColor(red: 0.96, green: 0.43, blue: 0.63, alpha: 1))
    ]
}
