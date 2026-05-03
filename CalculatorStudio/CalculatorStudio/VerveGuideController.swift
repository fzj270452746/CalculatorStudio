import UIKit

final class VerveGuideController: UIViewController {

    private let scroller = UIScrollView()
    private let column = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Guide"
        view.backgroundColor = UIColor(red: 0.04, green: 0.05, blue: 0.10, alpha: 1)

        scroller.translatesAutoresizingMaskIntoConstraints = false
        scroller.showsVerticalScrollIndicator = false
        view.addSubview(scroller)

        column.axis = .vertical
        column.spacing = 18
        column.translatesAutoresizingMaskIntoConstraints = false
        scroller.addSubview(column)

        NSLayoutConstraint.activate([
            scroller.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroller.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroller.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroller.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            column.topAnchor.constraint(equalTo: scroller.contentLayoutGuide.topAnchor, constant: 14),
            column.leadingAnchor.constraint(equalTo: scroller.frameLayoutGuide.leadingAnchor, constant: 20),
            column.trailingAnchor.constraint(equalTo: scroller.frameLayoutGuide.trailingAnchor, constant: -20),
            column.bottomAnchor.constraint(equalTo: scroller.contentLayoutGuide.bottomAnchor, constant: -120),
            column.widthAnchor.constraint(lessThanOrEqualToConstant: 760),
            column.centerXAnchor.constraint(equalTo: scroller.centerXAnchor)
        ])

        let intro = LumaCardView()
        intro.header(title: "How to Read the Studio", subtitle: "A short learning lane helps position the app as a practical design and education tool.")
        let introText = UILabel()
        introText.text = "Start with a preset or saved project, adjust reels and paytable in the Advanced Editor, then rerun the studio to review RTP, hit cadence, reward spread, and export a shareable report."
        introText.numberOfLines = 0
        introText.textColor = .white
        introText.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        intro.embed(introText)
        column.addArrangedSubview(intro)

        for shard in GuideShard.sampleDeck {
            let slate = LumaCardView()
            slate.header(title: shard.title, subtitle: shard.detail)
            let body = UILabel()
            body.text = extendedGuideCopy(for: shard.title)
            body.numberOfLines = 0
            body.textColor = .white
            body.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            slate.embed(body)
            column.addArrangedSubview(slate)
        }
    }

    private func extendedGuideCopy(for title: String) -> String {
        switch title {
        case "RTP":
            return "A healthy RTP target still needs context. Combine RTP with hit rate and top-win range so the experience does not feel misleadingly dry or overly generous in short sessions."
        case "Exact vs Monte Carlo":
            return "Exact enumeration is best for smaller 3-row footprints and compact strip lengths. Once the combinational space grows, simulation gives you faster iteration and avoids runaway CPU cost."
        case "Paytable Tuning":
            return "When regular rows pay too aggressively, your base game can lose contrast. A steadier ladder with one or two premium spikes usually reads more clearly in diagnostics and reports."
        default:
            return "Ways systems often feel more active than fixed paylines because multiple rows are live together. That improves visible feedback, but it can also blur symbol distinctiveness if coverage is too wide."
        }
    }
}
