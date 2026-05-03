import UIKit

final class RuneWorkshopController: UIViewController {

    var onCommit: ((RuneBlueprint) -> Void)?

    private var blueprint: RuneBlueprint
    private let scroller = UIScrollView()
    private let column = UIStackView()
    private let modeFlip = UISegmentedControl(items: ["Lines", "Ways"])

    private let reelRack = UIStackView()
    private let payRack = UIStackView()
    private let waysCanvas = WaylineCanvasView()

    private var reelColumns: [ReelColumnPad] = []
    private var payRows: [PaytablePad] = []

    init(blueprint: RuneBlueprint) {
        self.blueprint = blueprint
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Advanced Editor"
        view.backgroundColor = UIColor(red: 0.04, green: 0.05, blue: 0.10, alpha: 1)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Apply", style: .done, target: self, action: #selector(applyDraft))
        hatch()
        seedViews()
    }

    private func hatch() {
        scroller.translatesAutoresizingMaskIntoConstraints = false
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

            column.topAnchor.constraint(equalTo: scroller.contentLayoutGuide.topAnchor, constant: 20),
            column.leadingAnchor.constraint(equalTo: scroller.frameLayoutGuide.leadingAnchor, constant: 20),
            column.trailingAnchor.constraint(equalTo: scroller.frameLayoutGuide.trailingAnchor, constant: -20),
            column.bottomAnchor.constraint(equalTo: scroller.contentLayoutGuide.bottomAnchor, constant: -100)
        ])

        scroller.contentInsetAdjustmentBehavior = .always

        let modeSlate = LumaCardView()
        modeSlate.header(title: "Play Logic", subtitle: "Switch between fixed paylines and ways. Ways mode now edits real per-column coverage.")
        modeFlip.selectedSegmentIndex = blueprint.usesWays ? 1 : 0
        modeFlip.addTarget(self, action: #selector(flipMode), for: .valueChanged)
        modeSlate.embed(modeFlip)
        column.addArrangedSubview(modeSlate)

        let reelSlate = LumaCardView()
        reelSlate.header(title: "Reel Columns", subtitle: "Delete symbols, move them up or down, and keep the strip order explicit.")
        let reelScroll = UIScrollView()
        reelScroll.showsHorizontalScrollIndicator = false
        reelRack.axis = .horizontal
        reelRack.spacing = 12
        reelRack.alignment = .top
        reelScroll.addSubview(reelRack)
        reelRack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            reelRack.topAnchor.constraint(equalTo: reelScroll.contentLayoutGuide.topAnchor),
            reelRack.leadingAnchor.constraint(equalTo: reelScroll.contentLayoutGuide.leadingAnchor),
            reelRack.trailingAnchor.constraint(equalTo: reelScroll.contentLayoutGuide.trailingAnchor),
            reelRack.bottomAnchor.constraint(equalTo: reelScroll.contentLayoutGuide.bottomAnchor),
            reelRack.heightAnchor.constraint(equalTo: reelScroll.frameLayoutGuide.heightAnchor)
        ])
        reelScroll.heightAnchor.constraint(equalToConstant: 320).isActive = true
        reelSlate.embed(reelScroll)
        reelSlate.embed(stampButton(title: "Add Reel", tone: UIColor(red: 0.28, green: 0.85, blue: 0.81, alpha: 1), action: #selector(addReel)))
        column.addArrangedSubview(reelSlate)

        let paySlate = LumaCardView()
        paySlate.header(title: "Paytable", subtitle: "Edit symbol rows, set wild/scatter flags and keep weight close to the math.")
        payRack.axis = .vertical
        payRack.spacing = 12
        paySlate.embed(payRack)
        paySlate.embed(stampButton(title: "Add Symbol", tone: UIColor(red: 0.76, green: 0.38, blue: 1.0, alpha: 1), action: #selector(addSymbol)))
        column.addArrangedSubview(paySlate)

        let waysSlate = LumaCardView()
        waysSlate.header(title: "Coverage Painter", subtitle: "Line mode edits single stops. Ways mode supports multiple active rows inside each reel column.")
        waysCanvas.heightAnchor.constraint(equalToConstant: 290).isActive = true
        waysSlate.embed(waysCanvas)

        let controls = UIStackView()
        controls.axis = .horizontal
        controls.spacing = 12
        controls.distribution = .fillEqually
        controls.addArrangedSubview(stampButton(title: "Add Line", tone: UIColor(red: 0.28, green: 0.85, blue: 0.81, alpha: 1), action: #selector(addLine)))
        controls.addArrangedSubview(stampButton(title: "Clear", tone: UIColor(red: 0.95, green: 0.47, blue: 0.55, alpha: 1), action: #selector(clearLine)))
        waysSlate.embed(controls)
        column.addArrangedSubview(waysSlate)
    }

    private func seedViews() {
        reelColumns.forEach { $0.removeFromSuperview() }
        reelColumns = blueprint.reels.enumerated().map { index, reel in
            let pad = ReelColumnPad(title: "Reel \(index + 1)", symbols: reel)
            reelRack.addArrangedSubview(pad)
            return pad
        }

        payRows.forEach { $0.removeFromSuperview() }
        payRows = blueprint.tokens.map { token in
            let row = PaytablePad(token: token)
            payRack.addArrangedSubview(row)
            return row
        }

        waysCanvas.bind(rows: blueprint.rows, reels: blueprint.reelCount, lines: blueprint.waylines, cover: blueprint.waysCover, usesWays: blueprint.usesWays)
        waysCanvas.onLineChange = { [weak self] lines, cover in
            self?.blueprint.waylines = lines
            self?.blueprint.waysCover = cover
        }
    }

    private func stampButton(title: String, tone: UIColor, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        button.backgroundColor = tone
        button.layer.cornerRadius = 16
        button.layer.cornerCurve = .continuous
        button.heightAnchor.constraint(equalToConstant: 46).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc private func flipMode() {
        blueprint.usesWays = modeFlip.selectedSegmentIndex == 1
        waysCanvas.bind(rows: blueprint.rows, reels: blueprint.reelCount, lines: blueprint.waylines, cover: blueprint.waysCover, usesWays: blueprint.usesWays)
    }

    @objc private func addReel() {
        let pad = ReelColumnPad(title: "Reel \(reelColumns.count + 1)", symbols: ["A", "K", "Q"])
        reelColumns.append(pad)
        reelRack.addArrangedSubview(pad)
        waysCanvas.bind(rows: blueprint.rows, reels: reelColumns.count, lines: blueprint.waylines, cover: blueprint.waysCover, usesWays: blueprint.usesWays)
    }

    @objc private func addSymbol() {
        let row = PaytablePad(token: SigilToken(mark: "N", weight: 10, pays: [3: 1, 4: 2, 5: 5], aura: .regular))
        payRows.append(row)
        payRack.addArrangedSubview(row)
    }

    @objc private func addLine() {
        var lines = blueprint.waylines
        lines.append(WaylineTrack(title: "L\(lines.count + 1)", lane: Array(repeating: 0, count: max(reelColumns.count, 1))))
        blueprint.waylines = lines
        waysCanvas.bind(rows: blueprint.rows, reels: max(reelColumns.count, 1), lines: lines, cover: blueprint.waysCover, usesWays: blueprint.usesWays)
    }

    @objc private func clearLine() {
        waysCanvas.scrubSelectedTrack()
    }

    @objc private func applyDraft() {
        let reels = reelColumns.compactMap { pad -> [String]? in
            let symbols = pad.snapshot()
            return symbols.isEmpty ? nil : symbols
        }
        let tokens = payRows.compactMap { $0.snapshot() }
        let payload = waysCanvas.snapshot()

        guard !reels.isEmpty, !tokens.isEmpty else {
            present(SolsticePrompt(title: "Editor issue", detail: "Reels and paytable both need valid entries.", accent: .systemPink), animated: true)
            return
        }

        blueprint.reels = reels
        blueprint.tokens = tokens
        blueprint.waylines = payload.lines
        blueprint.waysCover = payload.cover
        blueprint.usesWays = modeFlip.selectedSegmentIndex == 1
        onCommit?(blueprint)
        navigationController?.popViewController(animated: true)
    }
}

private final class ReelColumnPad: UIView {

    private let titleLabel = UILabel()
    private let stack = UIStackView()
    private let scroller = UIScrollView()
    private var rows: [ReelSymbolRow] = []

    init(title: String, symbols: [String]) {
        super.init(frame: .zero)
        titleLabel.text = title
        hatch(symbols: symbols)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func snapshot() -> [String] {
        rows.compactMap { $0.readSymbol() }
    }

    private func hatch(symbols: [String]) {
        backgroundColor = UIColor.white.withAlphaComponent(0.07)
        layer.cornerRadius = 20
        layer.cornerCurve = .continuous
        widthAnchor.constraint(equalToConstant: 146).isActive = true
        heightAnchor.constraint(equalToConstant: 292).isActive = true

        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)

        let add = UIButton(type: .system)
        add.setTitle("+", for: .normal)
        add.setTitleColor(.white, for: .normal)
        add.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        add.addTarget(self, action: #selector(addSymbol), for: .touchUpInside)

        let head = UIStackView(arrangedSubviews: [titleLabel, add])
        head.axis = .horizontal
        head.distribution = .equalSpacing

        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        scroller.showsVerticalScrollIndicator = true
        scroller.alwaysBounceVertical = true
        scroller.translatesAutoresizingMaskIntoConstraints = false
        scroller.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scroller.contentLayoutGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: scroller.contentLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scroller.contentLayoutGuide.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: scroller.contentLayoutGuide.bottomAnchor),
            stack.widthAnchor.constraint(equalTo: scroller.frameLayoutGuide.widthAnchor)
        ])

        let holder = UIStackView(arrangedSubviews: [head, scroller])
        holder.axis = .vertical
        holder.spacing = 12
        holder.translatesAutoresizingMaskIntoConstraints = false
        addSubview(holder)

        NSLayoutConstraint.activate([
            holder.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            holder.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            holder.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            holder.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -14)
        ])

        scroller.heightAnchor.constraint(equalToConstant: 236).isActive = true

        let seed = symbols.isEmpty ? ["A", "K", "Q"] : symbols
        seed.forEach { appendRow(text: $0) }
    }

    private func appendRow(text: String) {
        let row = ReelSymbolRow(text: text)
        row.onShiftUp = { [weak self, weak row] in self?.move(row: row, delta: -1) }
        row.onShiftDown = { [weak self, weak row] in self?.move(row: row, delta: 1) }
        row.onCull = { [weak self, weak row] in self?.remove(row: row) }
        rows.append(row)
        stack.addArrangedSubview(row)
    }

    private func move(row: ReelSymbolRow?, delta: Int) {
        guard let row, let index = rows.firstIndex(where: { $0 === row }) else { return }
        let target = index + delta
        guard rows.indices.contains(target) else { return }
        rows.swapAt(index, target)
        stack.removeArrangedSubview(row)
        row.removeFromSuperview()
        stack.insertArrangedSubview(row, at: target)
    }

    private func remove(row: ReelSymbolRow?) {
        guard let row, rows.count > 1, let index = rows.firstIndex(where: { $0 === row }) else { return }
        rows.remove(at: index)
        stack.removeArrangedSubview(row)
        row.removeFromSuperview()
    }

    @objc private func addSymbol() {
        appendRow(text: "A")
    }
}

private final class ReelSymbolRow: UIView {

    var onShiftUp: (() -> Void)?
    var onShiftDown: (() -> Void)?
    var onCull: (() -> Void)?

    private let field = UITextField()

    init(text: String) {
        super.init(frame: .zero)
        field.text = text
        hatch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func readSymbol() -> String? {
        let text = field.text?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() ?? ""
        return text.isEmpty ? nil : text
    }

    private func hatch() {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 34).isActive = true
        setContentCompressionResistancePriority(.required, for: .vertical)
        setContentHuggingPriority(.required, for: .vertical)

        let up = miniGlyph("↑", action: #selector(shiftUp))
        let down = miniGlyph("↓", action: #selector(shiftDown))
        let trash = miniGlyph("−", action: #selector(cull))

        field.textAlignment = .center
        field.autocapitalizationType = .allCharacters
        field.textColor = .white
        field.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .semibold)
        field.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        field.layer.cornerRadius = 12
        field.layer.cornerCurve = .continuous

        let bar = UIStackView(arrangedSubviews: [up, down, field, trash])
        bar.axis = .horizontal
        bar.spacing = 6
        bar.alignment = .fill
        bar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bar)

        up.widthAnchor.constraint(equalToConstant: 26).isActive = true
        down.widthAnchor.constraint(equalToConstant: 26).isActive = true
        trash.widthAnchor.constraint(equalToConstant: 26).isActive = true
        field.heightAnchor.constraint(equalToConstant: 34).isActive = true

        NSLayoutConstraint.activate([
            bar.topAnchor.constraint(equalTo: topAnchor),
            bar.leadingAnchor.constraint(equalTo: leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: trailingAnchor),
            bar.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func miniGlyph(_ title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        button.layer.cornerRadius = 10
        button.layer.cornerCurve = .continuous
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc private func shiftUp() { onShiftUp?() }
    @objc private func shiftDown() { onShiftDown?() }
    @objc private func cull() { onCull?() }
}

private final class PaytablePad: UIView {

    private let markField = UITextField()
    private let weightField = UITextField()
    private let pay3 = UITextField()
    private let pay4 = UITextField()
    private let pay5 = UITextField()
    private let auraFlip = UISegmentedControl(items: ["Regular", "Wild", "Scatter"])

    init(token: SigilToken) {
        super.init(frame: .zero)
        hatch(token: token)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func snapshot() -> SigilToken? {
        let mark = markField.text?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() ?? ""
        guard !mark.isEmpty else { return nil }
        let values: [Int: Double] = [3: Double(pay3.text ?? "") ?? 0, 4: Double(pay4.text ?? "") ?? 0, 5: Double(pay5.text ?? "") ?? 0]
        let weight = Int(weightField.text ?? "") ?? 10
        let aura = SigilAura.allCases[safe: auraFlip.selectedSegmentIndex] ?? .regular
        return SigilToken(mark: mark, weight: max(weight, 1), pays: values, aura: aura)
    }

    private func hatch(token: SigilToken) {
        backgroundColor = UIColor.white.withAlphaComponent(0.07)
        layer.cornerRadius = 18
        layer.cornerCurve = .continuous

        let fields = [markField, weightField, pay3, pay4, pay5]
        fields.forEach {
            $0.textAlignment = .center
            $0.textColor = .white
            $0.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .semibold)
            $0.backgroundColor = UIColor.white.withAlphaComponent(0.10)
            $0.layer.cornerRadius = 12
            $0.layer.cornerCurve = .continuous
            $0.heightAnchor.constraint(equalToConstant: 38).isActive = true
        }

        markField.autocapitalizationType = .allCharacters
        markField.text = token.mark
        weightField.keyboardType = .numberPad
        weightField.text = "\(token.weight)"
        pay3.keyboardType = .decimalPad
        pay4.keyboardType = .decimalPad
        pay5.keyboardType = .decimalPad
        pay3.text = trim(token.pays[3] ?? 0)
        pay4.text = trim(token.pays[4] ?? 0)
        pay5.text = trim(token.pays[5] ?? 0)
        auraFlip.selectedSegmentIndex = SigilAura.allCases.firstIndex(of: token.aura) ?? 0

        let head = UIStackView(arrangedSubviews: [markField, weightField, pay3, pay4, pay5])
        head.axis = .horizontal
        head.distribution = .fillEqually
        head.spacing = 8

        let labels = ["Symbol", "Weight", "3x", "4x", "5x"].map {
            let label = UILabel()
            label.text = $0
            label.textColor = UIColor.white.withAlphaComponent(0.75)
            label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            return label
        }

        let legend = UIStackView(arrangedSubviews: labels)
        legend.axis = .horizontal
        legend.distribution = .fillEqually
        legend.spacing = 8

        let stack = UIStackView(arrangedSubviews: [legend, head, auraFlip])
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }

    private func trim(_ value: Double) -> String {
        let raw = String(format: "%.2f", value)
        return raw.replacingOccurrences(of: #"\.00$"#, with: "", options: .regularExpression)
    }
}

private final class WaylineCanvasView: UIView {

    struct Payload {
        let lines: [WaylineTrack]
        let cover: WaysCover?
    }

    var onLineChange: (([WaylineTrack], WaysCover?) -> Void)?

    private var rows = 3
    private var reels = 5
    private var usesWays = false
    private var lines: [WaylineTrack] = []
    private var cover: WaysCover?
    private var selectedIndex = 0

    private let picker = UISegmentedControl(items: [])
    private let grid = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        hatch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(rows: Int, reels: Int, lines: [WaylineTrack], cover: WaysCover?, usesWays: Bool) {
        self.rows = rows
        self.reels = reels
        self.lines = lines.isEmpty ? [WaylineTrack(title: "L1", lane: Array(repeating: 0, count: reels))] : lines
        self.cover = cover ?? .allRows(reels: reels, rows: rows)
        self.usesWays = usesWays
        selectedIndex = min(selectedIndex, self.lines.count - 1)
        rebuildPicker()
        rebuildGrid()
    }

    func scrubSelectedTrack() {
        if usesWays {
            cover = .allRows(reels: reels, rows: 0)
        } else if lines.indices.contains(selectedIndex) {
            lines[selectedIndex] = WaylineTrack(title: lines[selectedIndex].title, lane: Array(repeating: 0, count: reels))
        }
        rebuildGrid()
        onLineChange?(lines, cover)
    }

    func snapshot() -> Payload {
        Payload(lines: lines, cover: cover)
    }

    private func hatch() {
        backgroundColor = UIColor.white.withAlphaComponent(0.05)
        layer.cornerRadius = 18
        layer.cornerCurve = .continuous

        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.addTarget(self, action: #selector(pickLine), for: .valueChanged)
        addSubview(picker)

        grid.axis = .vertical
        grid.spacing = 8
        grid.translatesAutoresizingMaskIntoConstraints = false
        addSubview(grid)

        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            picker.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            picker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            grid.topAnchor.constraint(equalTo: picker.bottomAnchor, constant: 16),
            grid.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            grid.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            grid.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])
    }

    private func rebuildPicker() {
        picker.removeAllSegments()
        if usesWays {
            picker.insertSegment(withTitle: "Coverage", at: 0, animated: false)
            picker.selectedSegmentIndex = 0
            return
        }
        for (index, line) in lines.enumerated() {
            picker.insertSegment(withTitle: line.title, at: index, animated: false)
        }
        picker.selectedSegmentIndex = selectedIndex
    }

    private func rebuildGrid() {
        grid.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for row in 0..<rows {
            let rack = UIStackView()
            rack.axis = .horizontal
            rack.spacing = 8
            rack.distribution = .fillEqually

            for reel in 0..<reels {
                let button = UIButton(type: .system)
                button.tag = row * 100 + reel
                button.setTitle(usesWays ? (isCovered(row: row, reel: reel) ? "✓" : "") : "", for: .normal)
                button.setTitleColor(.white, for: .normal)
                button.backgroundColor = isActive(row: row, reel: reel)
                    ? UIColor(red: 0.44, green: 0.83, blue: 0.98, alpha: 1)
                    : UIColor.white.withAlphaComponent(0.08)
                button.layer.cornerRadius = 14
                button.layer.cornerCurve = .continuous
                button.heightAnchor.constraint(equalToConstant: 44).isActive = true
                button.addTarget(self, action: #selector(toggleCell(_:)), for: .touchUpInside)
                rack.addArrangedSubview(button)
            }

            grid.addArrangedSubview(rack)
        }
    }

    private func isActive(row: Int, reel: Int) -> Bool {
        if usesWays { return isCovered(row: row, reel: reel) }
        return lines[safe: selectedIndex]?.lane[safe: reel] == row
    }

    private func isCovered(row: Int, reel: Int) -> Bool {
        cover?.columns[safe: reel]?.contains(row) == true
    }

    @objc private func pickLine() {
        guard !usesWays else { return }
        selectedIndex = max(0, picker.selectedSegmentIndex)
        rebuildGrid()
    }

    @objc private func toggleCell(_ sender: UIButton) {
        let row = sender.tag / 100
        let reel = sender.tag % 100

        if usesWays {
            var matrix = cover?.columns ?? Array(repeating: [], count: reels)
            if matrix.indices.contains(reel) {
                if let index = matrix[reel].firstIndex(of: row) {
                    matrix[reel].remove(at: index)
                } else {
                    matrix[reel].append(row)
                    matrix[reel].sort()
                }
            }
            cover = WaysCover(title: "Custom Ways", columns: matrix)
        } else if lines.indices.contains(selectedIndex), lines[selectedIndex].lane.indices.contains(reel) {
            var lane = lines[selectedIndex].lane
            lane[reel] = row
            lines[selectedIndex] = WaylineTrack(title: lines[selectedIndex].title, lane: lane)
        }

        rebuildGrid()
        onLineChange?(lines, cover)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
