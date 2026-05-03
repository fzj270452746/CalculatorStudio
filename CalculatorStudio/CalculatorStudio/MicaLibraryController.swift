import UIKit

final class MicaLibraryController: UIViewController {

    private let depot = VaultDepot.shared
    private let hub = QuillWorkbench()
    private let scroller = UIScrollView()
    private let column = UIStackView()
    private let recentSlate = LumaCardView()
    private let presetSlate = LumaCardView()
    private let learnSlate = LumaCardView()

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Preset Library"
        view.backgroundColor = UIColor(red: 0.04, green: 0.05, blue: 0.10, alpha: 1)

        NotificationCenter.default.addObserver(self, selector: #selector(reseedSections), name: VaultDepot.didShift, object: nil)

        scroller.translatesAutoresizingMaskIntoConstraints = false
        scroller.showsVerticalScrollIndicator = false
        view.addSubview(scroller)

        column.axis = .vertical
        column.spacing = 18
        column.translatesAutoresizingMaskIntoConstraints = false
        scroller.addSubview(column)

        recentSlate.header(title: "Recent Projects", subtitle: "Saved locally for quick iteration and safer App Store positioning as a real workflow tool.")
        presetSlate.header(title: "Built-in Decks", subtitle: "High-quality starters help explain design intent, not just deliver a parameter calculator.")
        learnSlate.header(title: "Learn & Guide", subtitle: "Short primers make the app friendlier for design review, education, and onboarding.")

        column.addArrangedSubview(recentSlate)
        column.addArrangedSubview(presetSlate)
        column.addArrangedSubview(learnSlate)

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

        reseedSections()
    }

    @objc private func reseedSections() {
        repackRecentSlate()
        repackPresetSlate()
        repackLearnSlate()
    }

    private func repackRecentSlate() {
        trimEmbeds(from: recentSlate)

        if depot.archives.isEmpty {
            let label = UILabel()
            label.text = "No saved projects yet. Save a tuned deck from Studio and it will appear here with recent recall."
            label.numberOfLines = 0
            label.textColor = UIColor.white.withAlphaComponent(0.76)
            label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            recentSlate.embed(label)
            return
        }

        for archive in depot.recentArchives {
            recentSlate.embed(makeArchiveGlyph(archive))
        }
    }

    private func repackPresetSlate() {
        trimEmbeds(from: presetSlate)
        for specimen in RuneBlueprint.sampleDeck {
            presetSlate.embed(makePresetGlyph(specimen))
        }
    }

    private func repackLearnSlate() {
        trimEmbeds(from: learnSlate)

        for shard in GuideShard.sampleDeck {
            learnSlate.embed(makeGuideGlyph(shard))
        }

        let lane = UIButton(type: .system)
        lane.setTitle("Open Full Guide", for: .normal)
        lane.setTitleColor(.white, for: .normal)
        lane.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        lane.backgroundColor = UIColor(red: 0.40, green: 0.30, blue: 0.95, alpha: 1)
        lane.layer.cornerRadius = 16
        lane.layer.cornerCurve = .continuous
        lane.heightAnchor.constraint(equalToConstant: 50).isActive = true
        lane.addTarget(self, action: #selector(openGuide), for: .touchUpInside)
        learnSlate.embed(lane)
    }

    private func makeArchiveGlyph(_ archive: ArchiveCodex) -> UIView {
        let button = UIButton(type: .system)
        button.setTitle(nil, for: .normal)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        button.layer.cornerRadius = 18
        button.layer.cornerCurve = .continuous
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 86).isActive = true
        button.accessibilityIdentifier = archive.id.uuidString
        button.addTarget(self, action: #selector(recallArchive(_:)), for: .touchUpInside)

        let title = UILabel()
        title.text = archive.title
        title.textColor = .white
        title.font = UIFont.systemFont(ofSize: 17, weight: .bold)

        let meta = UILabel()
        meta.text = "\(archive.blueprint.reelCount) reels · \(archive.blueprint.rows) rows · \(archive.blueprint.usesWays ? "Ways" : "Lines") \(archive.blueprint.lines)"
        meta.textColor = UIColor.white.withAlphaComponent(0.72)
        meta.font = UIFont.systemFont(ofSize: 13, weight: .semibold)

        let memo = UILabel()
        let stats = [
            archive.memo.isEmpty ? nil : archive.memo,
            archive.cachedRTP.map { String(format: "RTP %.2f%%", $0 * 100) },
            archive.cachedHitRate.map { String(format: "Hit %.1f%%", $0 * 100) }
        ].compactMap { $0 }.joined(separator: " · ")
        memo.text = stats.isEmpty ? "Saved locally" : stats
        memo.textColor = UIColor.white.withAlphaComponent(0.62)
        memo.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        memo.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [title, meta, memo])
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: button.topAnchor, constant: 14),
            stack.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -14),
            stack.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -14)
        ])
        return button
    }

    private func makePresetGlyph(_ specimen: RuneBlueprint) -> UIView {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        button.layer.cornerRadius = 18
        button.layer.cornerCurve = .continuous
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 92).isActive = true
        button.accessibilityIdentifier = specimen.title
        button.addTarget(self, action: #selector(recallPreset(_:)), for: .touchUpInside)

        let title = UILabel()
        title.text = specimen.title
        title.textColor = .white
        title.font = UIFont.systemFont(ofSize: 17, weight: .bold)

        let meta = UILabel()
        meta.text = "\(specimen.reelCount)x\(specimen.rows) · \(specimen.usesWays ? "Ways" : "Lines") \(specimen.lines) · target RTP \(Int(specimen.baseRTP * 100))%"
        meta.textColor = UIColor.white.withAlphaComponent(0.72)
        meta.font = UIFont.systemFont(ofSize: 13, weight: .semibold)

        let note = UILabel()
        note.text = presetNarrative(for: specimen.title)
        note.textColor = UIColor.white.withAlphaComponent(0.62)
        note.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        note.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [title, meta, note])
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: button.topAnchor, constant: 14),
            stack.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -14),
            stack.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -14)
        ])
        return button
    }

    private func makeGuideGlyph(_ shard: GuideShard) -> UIView {
        let shell = UIView()
        shell.backgroundColor = shard.tint.withAlphaComponent(0.12)
        shell.layer.cornerRadius = 18
        shell.layer.cornerCurve = .continuous

        let title = UILabel()
        title.text = shard.title
        title.textColor = shard.tint
        title.font = UIFont.systemFont(ofSize: 15, weight: .bold)

        let detail = UILabel()
        detail.text = shard.detail
        detail.textColor = .white
        detail.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        detail.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [title, detail])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        shell.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: shell.topAnchor, constant: 14),
            stack.leadingAnchor.constraint(equalTo: shell.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: shell.trailingAnchor, constant: -14),
            stack.bottomAnchor.constraint(equalTo: shell.bottomAnchor, constant: -14)
        ])
        return shell
    }

    private func trimEmbeds(from slate: LumaCardView) {
        slate.subviews.compactMap { $0 as? UIStackView }.first?.arrangedSubviews.dropFirst(2).forEach { view in
            view.removeFromSuperview()
        }
    }

    private func presetNarrative(for title: String) -> String {
        switch title {
        case "Aurora Low Swing": return "Dense base icons and modest ceiling for onboarding-friendly rhythm."
        case "Vegas Stripe": return "Classic line cadence with recognizable medium-volatility pacing."
        case "Meteor Bonus Heavy": return "Scatter-forward design that trades steadiness for event spikes."
        case "Nebula Ladder": return "Stepping symbol spread meant for smoother retention arcs."
        case "Quartz Torrent": return "Higher reel density and wider ways coverage for loud sessions."
        default: return "Prototype deck for math review, visualization, and export-ready reporting."
        }
    }

    @objc private func recallArchive(_ sender: UIButton) {
        guard let raw = sender.accessibilityIdentifier, let id = UUID(uuidString: raw), let archive = depot.revealArchive(id: id) else { return }
        let ledger = try? hub.inspect(blueprint: archive.blueprint, spins: 100, exact: false)
        depot.ledger = ledger
        tabBarController?.selectedIndex = 0
    }

    @objc private func recallPreset(_ sender: UIButton) {
        guard let title = sender.accessibilityIdentifier,
              let specimen = RuneBlueprint.sampleDeck.first(where: { $0.title == title }) else { return }
        depot.importBlueprint(specimen)
        depot.ledger = try? hub.inspect(blueprint: specimen, spins: 100, exact: false)
        tabBarController?.selectedIndex = 0
    }

    @objc private func openGuide() {
        navigationController?.pushViewController(VerveGuideController(), animated: true)
    }
}
