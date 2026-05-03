import UIKit

final class AxiomStudioController: UIViewController {

    private let hub: QuillWorkbench
    private let depot = VaultDepot.shared
    private let scroller = UIScrollView()
    private let column = UIStackView()

    private let overviewSlate = LumaCardView()
    private let inputSlate = LumaCardView()
    private let detailSlate = LumaCardView()
    private let graphSlate = LumaCardView()
    private let compareSlate = LumaCardView()
    private let insightSlate = LumaCardView()

    private let reelsField = OrpheusEntryField(caption: "Reels", seed: "5")
    private let rowsField = OrpheusEntryField(caption: "Rows", seed: "3")
    private let linesField = OrpheusEntryField(caption: "Lines / Ways", seed: "20")
    private let betField = OrpheusEntryField(caption: "Total Bet", seed: "1.00")
    private let roundsField = OrpheusEntryField(caption: "Monte Carlo Spins", seed: "100")
    private let exactFlip = UISwitch()

    private let rtpValue = UILabel()
    private let hitValue = UILabel()
    private let rangeValue = UILabel()
    private let modeValue = UILabel()
    private let deckValue = UILabel()
    private let archiveValue = UILabel()
    private let runGlyph = UIButton(type: .system)
    private let payoutGraph = ZephyrBarsView()
    private let shareGraph = HaloDonutView()
    private let lineGraph = FjordCurveView()
    private let insightRack = UIStackView()

    private var currentDraft = RuneBlueprint.sampleDeck[0]
    private var pulseToken = UUID()
    private var isPulsing = false

    init(hub: QuillWorkbench) {
        self.hub = hub
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        currentDraft = depot.blueprint
        chromaSetup()
        latticeSetup()
        heedDepot()
        syncFields()

        if let ledger = depot.ledger ?? (try? hub.inspect(blueprint: currentDraft, spins: 100, exact: false)) {
            depot.blueprint = currentDraft
            depot.ledger = ledger
            refresh(with: ledger)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass else { return }
        pairRows().forEach {
            $0.axis = traitCollection.horizontalSizeClass == .regular ? .horizontal : .vertical
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private func chromaSetup() {
        title = "RTP Studio"
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(storeArchive))
        view.backgroundColor = UIColor(red: 0.03, green: 0.04, blue: 0.11, alpha: 1)

        let glaze = CAGradientLayer()
        glaze.colors = [
            UIColor(red: 0.35, green: 0.16, blue: 0.79, alpha: 1).cgColor,
            UIColor(red: 0.08, green: 0.10, blue: 0.24, alpha: 1).cgColor,
            UIColor(red: 0.02, green: 0.03, blue: 0.07, alpha: 1).cgColor
        ]
        glaze.locations = [0, 0.35, 1]
        glaze.frame = view.bounds
        view.layer.insertSublayer(glaze, at: 0)
        view.layer.setValue(glaze, forKey: "glaze")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        (view.layer.value(forKey: "glaze") as? CAGradientLayer)?.frame = view.bounds
    }

    private func latticeSetup() {
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

            column.topAnchor.constraint(equalTo: scroller.contentLayoutGuide.topAnchor, constant: 12),
            column.leadingAnchor.constraint(equalTo: scroller.frameLayoutGuide.leadingAnchor, constant: 20),
            column.trailingAnchor.constraint(equalTo: scroller.frameLayoutGuide.trailingAnchor, constant: -20),
            column.bottomAnchor.constraint(equalTo: scroller.contentLayoutGuide.bottomAnchor, constant: -120),
            column.widthAnchor.constraint(lessThanOrEqualToConstant: 760),
            column.centerXAnchor.constraint(equalTo: scroller.centerXAnchor)
        ])

        forgeOverview()
        forgeInput()
        forgeDetail()
        forgeGraphs()
        forgeInsights()
        forgeCompare()
    }

    private func forgeOverview() {
        overviewSlate.header(title: "Simulation Pulse", subtitle: "Balance RTP, hit cadence and reward spread from a single screen.")

        let strip = UIStackView()
        strip.axis = .horizontal
        strip.spacing = 12
        strip.distribution = .fillEqually

        [rtpValue, hitValue, rangeValue].forEach {
            $0.font = UIFont.systemFont(ofSize: 24, weight: .bold)
            $0.textColor = .white
            $0.numberOfLines = 2
        }

        strip.addArrangedSubview(makeMetric(title: "RTP", gauge: rtpValue, tint: UIColor(red: 0.28, green: 0.88, blue: 0.83, alpha: 1)))
        strip.addArrangedSubview(makeMetric(title: "Hit Rate", gauge: hitValue, tint: UIColor(red: 0.99, green: 0.56, blue: 0.37, alpha: 1)))
        strip.addArrangedSubview(makeMetric(title: "Top Win", gauge: rangeValue, tint: UIColor(red: 0.79, green: 0.47, blue: 0.99, alpha: 1)))

        runGlyph.setTitle("Run Analysis", for: .normal)
        runGlyph.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        runGlyph.tintColor = .white
        runGlyph.backgroundColor = UIColor(red: 0.50, green: 0.28, blue: 1.0, alpha: 1)
        runGlyph.layer.cornerRadius = 18
        runGlyph.layer.cornerCurve = .continuous
        runGlyph.heightAnchor.constraint(equalToConstant: 54).isActive = true
        runGlyph.addTarget(self, action: #selector(runPulse), for: .touchUpInside)

        overviewSlate.embed(strip)
        overviewSlate.embed(runGlyph)
        column.addArrangedSubview(overviewSlate)
    }

    private func forgeInput() {
        inputSlate.header(title: "Config Builder", subtitle: "Tune the envelope here, then open the deeper editor for strips, pays and ways.")

        let rowA = makePair(reelsField, rowsField)
        let rowB = makePair(linesField, betField)
        let grid = UIStackView(arrangedSubviews: [rowA, rowB, roundsField])
        grid.axis = .vertical
        grid.spacing = 12

        let flipTitle = UILabel()
        flipTitle.text = "Exact mode"
        flipTitle.textColor = .white
        flipTitle.font = UIFont.systemFont(ofSize: 16, weight: .semibold)

        let flipHint = UILabel()
        flipHint.text = "Uses full enumeration only for smaller reel spaces. Otherwise it falls back to Monte Carlo."
        flipHint.textColor = UIColor.white.withAlphaComponent(0.68)
        flipHint.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        flipHint.numberOfLines = 2

        exactFlip.onTintColor = UIColor(red: 0.25, green: 0.77, blue: 0.75, alpha: 1)
        exactFlip.setContentHuggingPriority(.required, for: .horizontal)
        exactFlip.setContentCompressionResistancePriority(.required, for: .horizontal)

        let flipTextStack = UIStackView(arrangedSubviews: [flipTitle, flipHint])
        flipTextStack.axis = .vertical
        flipTextStack.spacing = 4
        flipTextStack.alignment = .fill
        flipTextStack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let flipLine = UIStackView(arrangedSubviews: [flipTextStack, exactFlip])
        flipLine.axis = .horizontal
        flipLine.alignment = .center
        flipLine.spacing = 16
        flipLine.distribution = .fill

        let sliderRack = EmberSliderRack(caption: "Volatility Bias", value: Float(currentDraft.volatilityBias))
        sliderRack.onShift = { [weak self] fraction in
            self?.currentDraft.volatilityBias = fraction
        }

        let forge = UIButton(type: .system)
        forge.setTitle("Open Advanced Editor", for: .normal)
        forge.setTitleColor(.white, for: .normal)
        forge.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        forge.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        forge.layer.cornerRadius = 16
        forge.layer.cornerCurve = .continuous
        forge.heightAnchor.constraint(equalToConstant: 48).isActive = true
        forge.addTarget(self, action: #selector(openDetailEditor), for: .touchUpInside)

        inputSlate.embed(grid)
        inputSlate.embed(flipLine)
        inputSlate.embed(sliderRack)
        inputSlate.embed(forge)
        column.addArrangedSubview(inputSlate)
    }

    private func forgeDetail() {
        detailSlate.header(title: "Math Layout", subtitle: "A quick readout of the current strip topology and symbol inventory.")
        [archiveValue, modeValue, deckValue].forEach {
            $0.textColor = .white
            $0.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            $0.numberOfLines = 0
        }
        archiveValue.textColor = UIColor(red: 0.55, green: 0.89, blue: 0.95, alpha: 1)
        archiveValue.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        detailSlate.embed(archiveValue)
        detailSlate.embed(modeValue)
        detailSlate.embed(deckValue)
        column.addArrangedSubview(detailSlate)
    }

    private func forgeGraphs() {
        graphSlate.header(title: "Visual Diagnostics", subtitle: "Reward spread, symbol share and return drift update together.")
        payoutGraph.heightAnchor.constraint(equalToConstant: 180).isActive = true
        shareGraph.heightAnchor.constraint(equalToConstant: 180).isActive = true
        lineGraph.heightAnchor.constraint(equalToConstant: 140).isActive = true
        graphSlate.embed(payoutGraph)
        graphSlate.embed(shareGraph)
        graphSlate.embed(lineGraph)
        column.addArrangedSubview(graphSlate)
    }

    private func forgeInsights() {
        insightSlate.header(title: "Result Insights", subtitle: "Short human-readable guidance helps present this run as a design workflow, not just a calculator pass.")
        insightRack.axis = .vertical
        insightRack.spacing = 12
        insightSlate.embed(insightRack)
        column.addArrangedSubview(insightSlate)
    }

    private func forgeCompare() {
        compareSlate.header(title: "Comparison Lane", subtitle: "Preset snapshots help with tuning passes and audit review.")
        let strip = UIStackView()
        strip.axis = .vertical
        strip.spacing = 12

        for specimen in RuneBlueprint.sampleDeck {
            let glyph = UIButton(type: .system)
            glyph.setTitle(specimen.title, for: .normal)
            glyph.setTitleColor(.white, for: .normal)
            glyph.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            glyph.contentHorizontalAlignment = .left
            glyph.contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
            glyph.backgroundColor = UIColor.white.withAlphaComponent(0.07)
            glyph.layer.cornerRadius = 16
            glyph.layer.cornerCurve = .continuous
            glyph.accessibilityIdentifier = specimen.title
            glyph.addTarget(self, action: #selector(loadSpecimen(_:)), for: .touchUpInside)
            strip.addArrangedSubview(glyph)
        }

        compareSlate.embed(strip)
        column.addArrangedSubview(compareSlate)
    }

    private func makeMetric(title: String, gauge: UILabel, tint: UIColor) -> UIView {
        let shell = UIView()
        shell.backgroundColor = tint.withAlphaComponent(0.12)
        shell.layer.cornerRadius = 20
        shell.layer.cornerCurve = .continuous

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = tint
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)

        let stack = UIStackView(arrangedSubviews: [titleLabel, gauge])
        stack.axis = .vertical
        stack.spacing = 10
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

    private func makePair(_ leading: UIView, _ trailing: UIView) -> UIStackView {
        let row = UIStackView(arrangedSubviews: [leading, trailing])
        row.axis = traitCollection.horizontalSizeClass == .regular ? .horizontal : .vertical
        row.spacing = 12
        row.distribution = .fillEqually
        return row
    }

    private func pairRows() -> [UIStackView] {
        inputSlate.subviews.compactMap { $0 as? UIStackView }.flatMap { stack in
            stack.arrangedSubviews.compactMap { $0 as? UIStackView }
        }
    }

    @objc private func runPulse() {
        view.endEditing(true)

        var draft = currentDraft
        let reelCount = Int(reelsField.ink) ?? draft.reelCount
        draft.rows = Int(rowsField.ink) ?? draft.rows
        draft.bet = Double(betField.ink) ?? draft.bet
        let lineHint = linesField.ink.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if let hinted = Int(lineHint), !draft.usesWays, hinted > 0, hinted != draft.waylines.count {
            var lines = Array(draft.waylines.prefix(hinted))
            while lines.count < hinted {
                lines.append(WaylineTrack(title: "L\(lines.count + 1)", lane: Array(repeating: min(1, max(draft.rows - 1, 0)), count: draft.reelCount)))
            }
            draft.waylines = lines
        }
        let spins = Int(roundsField.ink) ?? 100
        let eligibleExact = draft.rows <= 3 && draft.reelCount <= 5
        let exact = exactFlip.isOn && eligibleExact

        if reelCount != draft.reelCount {
            draft.reels = rebuiltReels(from: draft, target: reelCount)
        }

        if draft.rows < 3 || draft.bet <= 0 {
            let sheet = SolsticePrompt(title: "Check your inputs", detail: "Rows and total bet need usable values before the simulation can start.", accent: .systemPink)
            present(sheet, animated: true)
            return
        }

        pulseToken = UUID()
        let token = pulseToken

        let veil = BorealSpinnerController()
        veil.modalPresentationStyle = .overFullScreen
        present(veil, animated: false)

        isPulsing = true
        runGlyph.isEnabled = false
        runGlyph.alpha = 0.65

        DispatchQueue.global(qos: .userInitiated).async { [hub] in
            let ledger = try? hub.inspect(blueprint: draft, spins: spins, exact: exact, shouldHalt: { [weak self] in
                self?.pulseToken != token
            })

            DispatchQueue.main.async { [weak self] in
                guard let self, self.pulseToken == token else { return }
                veil.dismiss(animated: false) { [weak self] in
                    guard let self else { return }
                    guard let ledger else {
                        self.isPulsing = false
                        self.runGlyph.isEnabled = true
                        self.runGlyph.alpha = 1
                        return
                    }
                    self.currentDraft = draft
                    self.depot.blueprint = draft
                    self.depot.ledger = ledger
                    self.syncFields()
                    self.refresh(with: ledger)
                    if self.exactFlip.isOn && !eligibleExact {
                        self.present(SolsticePrompt(title: "Exact mode eased back", detail: "This reel space is too broad for safe full enumeration, so the run completed in Monte Carlo mode instead.", accent: UIColor(red: 0.98, green: 0.64, blue: 0.28, alpha: 1)), animated: true)
                    }
                    self.isPulsing = false
                    self.runGlyph.isEnabled = true
                    self.runGlyph.alpha = 1
                }
            }
        }
    }

    @objc private func loadSpecimen(_ sender: UIButton) {
        guard let title = sender.accessibilityIdentifier,
              let draft = RuneBlueprint.sampleDeck.first(where: { $0.title == title }) else {
            return
        }

        currentDraft = draft
        depot.importBlueprint(draft)
        if let ledger = try? hub.inspect(blueprint: draft, spins: 100, exact: false) {
            depot.blueprint = draft
            depot.ledger = ledger
            syncFields()
            refresh(with: ledger)
        }
    }

    @objc private func openDetailEditor() {
        let editor = RuneWorkshopController(blueprint: currentDraft)
        editor.onCommit = { [weak self] blueprint in
            guard let self else { return }
            self.currentDraft = blueprint
            if let ledger = try? self.hub.inspect(blueprint: blueprint, spins: Int(self.roundsField.ink) ?? 100, exact: self.exactFlip.isOn) {
                self.depot.blueprint = blueprint
                self.depot.ledger = ledger
                self.syncFields()
                self.refresh(with: ledger)
            }
        }
        navigationController?.pushViewController(editor, animated: true)
    }

    @objc private func storeArchive() {
        let prompt = ObliqueArchiveComposer(seedTitle: depot.archiveLabel() == "Unsaved Draft" ? currentDraft.title : depot.archiveLabel(), seedMemo: "")
        prompt.onCommit = { [weak self] title, memo in
            guard let self else { return }
            let archive = self.depot.upsertArchive(title: title, memo: memo, blueprint: self.currentDraft, ledger: self.depot.ledger)
            self.archiveValue.text = "Project: \(archive.title)"
            self.present(SolsticePrompt(title: "Project saved", detail: "\(archive.title) is now stored locally and will also appear in Recent Projects.", accent: UIColor(red: 0.33, green: 0.84, blue: 0.77, alpha: 1)), animated: true)
        }
        present(prompt, animated: true)
    }

    private func heedDepot() {
        NotificationCenter.default.addObserver(self, selector: #selector(syncFromDepot), name: VaultDepot.didShift, object: nil)
    }

    @objc private func syncFromDepot() {
        currentDraft = depot.blueprint
        syncFields()
        if let ledger = depot.ledger ?? (try? hub.inspect(blueprint: currentDraft, spins: Int(roundsField.ink) ?? 100, exact: false)) {
            refresh(with: ledger)
        }
    }

    private func syncFields() {
        reelsField.ink = "\(currentDraft.reelCount)"
        rowsField.ink = "\(currentDraft.rows)"
        linesField.ink = currentDraft.usesWays ? "\(currentDraft.lines) ways" : "\(currentDraft.lines)"
        betField.ink = String(format: "%.2f", currentDraft.bet)
        archiveValue.text = "Project: \(depot.archiveLabel())"
    }

    private func refresh(with ledger: QuillLedger) {
        rtpValue.text = String(format: "%.2f%%", ledger.rtp * 100)
        hitValue.text = String(format: "%.1f%%", ledger.hitRate * 100)
        rangeValue.text = String(format: "%.1fx", ledger.topWin)
        modeValue.text = "Mode: \(ledger.exactUsed ? "Exact enumeration" : "Monte Carlo simulation") · Spins: \(ledger.spinCount)"
        deckValue.text = "Reels: \(currentDraft.reelCount) · Rows: \(currentDraft.rows) · \(currentDraft.usesWays ? "Ways" : "Lines"): \(currentDraft.lines) · Symbols: \(currentDraft.tokens.map(\.mark).joined(separator: ", "))"
        payoutGraph.bind(entries: ledger.distribution)
        shareGraph.bind(entries: ledger.contribution)
        lineGraph.bind(entries: ledger.returnTrail)
        refillInsights(ledger: ledger)
    }

    private func refillInsights(ledger: QuillLedger) {
        insightRack.arrangedSubviews.forEach {
            insightRack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        for shard in harvestInsights(ledger: ledger) {
            insightRack.addArrangedSubview(makeInsightTile(shard))
        }
    }

    private func makeInsightTile(_ shard: InsightShard) -> UIView {
        let shell = UIView()
        shell.backgroundColor = shard.tint.withAlphaComponent(0.13)
        shell.layer.cornerRadius = 18
        shell.layer.cornerCurve = .continuous

        let badge = UILabel()
        badge.text = shard.title.uppercased()
        badge.textColor = shard.tint
        badge.font = UIFont.systemFont(ofSize: 12, weight: .bold)

        let body = UILabel()
        body.text = shard.detail
        body.textColor = .white
        body.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        body.numberOfLines = 0

        let rack = UIStackView(arrangedSubviews: [badge, body])
        rack.axis = .vertical
        rack.spacing = 8
        rack.translatesAutoresizingMaskIntoConstraints = false
        shell.addSubview(rack)

        NSLayoutConstraint.activate([
            rack.topAnchor.constraint(equalTo: shell.topAnchor, constant: 14),
            rack.leadingAnchor.constraint(equalTo: shell.leadingAnchor, constant: 14),
            rack.trailingAnchor.constraint(equalTo: shell.trailingAnchor, constant: -14),
            rack.bottomAnchor.constraint(equalTo: shell.bottomAnchor, constant: -14)
        ])
        return shell
    }

    private func harvestInsights(ledger: QuillLedger) -> [InsightShard] {
        let cadence: InsightShard
        switch ledger.hitRate {
        case ..<0.18:
            cadence = InsightShard(title: "Cadence", detail: "Hit frequency is sparse, which suits a high-tension session profile. Consider boosting low-tier regular pays if you want softer onboarding.", tint: UIColor(red: 0.99, green: 0.56, blue: 0.48, alpha: 1))
        case ..<0.34:
            cadence = InsightShard(title: "Cadence", detail: "This setup lands in a balanced middle lane with enough misses to retain suspense while still feeding visible feedback loops.", tint: UIColor(red: 0.41, green: 0.84, blue: 0.83, alpha: 1))
        default:
            cadence = InsightShard(title: "Cadence", detail: "The game hits often, so players should feel busy. Watch for RTP leakage if frequent wins also pay above 2x too often.", tint: UIColor(red: 0.54, green: 0.84, blue: 0.44, alpha: 1))
        }

        let swing: InsightShard
        if ledger.topWin >= 100 {
            swing = InsightShard(title: "Volatility", detail: "Top win reach is punchy. This reel map can support high-drama marketing beats, but QA should review bankroll drain and session depth together.", tint: UIColor(red: 0.81, green: 0.50, blue: 1.0, alpha: 1))
        } else if ledger.topWin >= 30 {
            swing = InsightShard(title: "Volatility", detail: "Reward spread feels mid-weight. It should read as aspirational without looking excessively spiky in short sessions.", tint: UIColor(red: 0.34, green: 0.71, blue: 0.99, alpha: 1))
        } else {
            swing = InsightShard(title: "Volatility", detail: "Top-end potential is restrained. This favors approachable retention loops more than jackpot storytelling.", tint: UIColor(red: 0.98, green: 0.73, blue: 0.33, alpha: 1))
        }

        let topologyTitle = currentDraft.usesWays ? "Ways Matrix" : "Line Fabric"
        let topologyText = currentDraft.usesWays
            ? "Coverage currently spans \(currentDraft.lines) ways across \(currentDraft.reelCount) reels. Dense multi-row coverage tends to raise hit perception quickly, even before paytable tuning."
            : "The current lane pack holds \(currentDraft.lines) paylines. If you want sharper symbol personality, keep line count stable and tune reel frequency before expanding lane count."
        let topology = InsightShard(title: topologyTitle, detail: topologyText, tint: UIColor(red: 0.95, green: 0.42, blue: 0.64, alpha: 1))

        return [cadence, swing, topology]
    }

    private func rebuiltReels(from blueprint: RuneBlueprint, target: Int) -> [[String]] {
        guard target > 0 else { return blueprint.reels }
        if target == blueprint.reelCount { return blueprint.reels }
        if target < blueprint.reelCount { return Array(blueprint.reels.prefix(target)) }

        var reels = blueprint.reels
        let fallback = blueprint.reels.last ?? ["A", "K", "Q", "J", "W", "B"]
        while reels.count < target {
            reels.append(fallback)
        }
        return reels
    }
}
