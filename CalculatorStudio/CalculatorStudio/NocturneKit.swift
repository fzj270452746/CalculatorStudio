import UIKit

final class LumaCardView: UIView {

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let stack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        hatch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func header(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }

    func embed(_ view: UIView) {
        stack.addArrangedSubview(view)
    }

    private func hatch() {
        layer.cornerRadius = 28
        layer.cornerCurve = .continuous
        backgroundColor = UIColor.white.withAlphaComponent(0.08)
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor

        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.isUserInteractionEnabled = false
        blur.layer.cornerRadius = 28
        blur.layer.cornerCurve = .continuous
        blur.clipsToBounds = true
        addSubview(blur)

        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .white

        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.66)
        subtitleLabel.numberOfLines = 0

        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            blur.topAnchor.constraint(equalTo: topAnchor),
            blur.leadingAnchor.constraint(equalTo: leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: trailingAnchor),
            blur.bottomAnchor.constraint(equalTo: bottomAnchor),

            stack.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18)
        ])
    }
}

final class OrpheusEntryField: UIView, UITextFieldDelegate {

    var ink: String {
        get { field.text ?? "" }
        set { field.text = newValue }
    }

    private let captionLabel = UILabel()
    private let field = UITextField()
    private let seed: String

    init(caption: String, seed: String) {
        self.seed = seed
        super.init(frame: .zero)
        captionLabel.text = caption
        field.text = seed
        hatch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func hatch() {
        let shell = UIView()
        shell.translatesAutoresizingMaskIntoConstraints = false
        shell.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        shell.layer.cornerRadius = 18
        shell.layer.cornerCurve = .continuous
        addSubview(shell)

        captionLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        captionLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        captionLabel.translatesAutoresizingMaskIntoConstraints = false

        field.font = UIFont.monospacedDigitSystemFont(ofSize: 19, weight: .semibold)
        field.textColor = .white
        field.keyboardType = seed.contains(".") ? .decimalPad : .numberPad
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false

        shell.addSubview(captionLabel)
        shell.addSubview(field)

        NSLayoutConstraint.activate([
            shell.topAnchor.constraint(equalTo: topAnchor),
            shell.leadingAnchor.constraint(equalTo: leadingAnchor),
            shell.trailingAnchor.constraint(equalTo: trailingAnchor),
            shell.bottomAnchor.constraint(equalTo: bottomAnchor),
            shell.heightAnchor.constraint(equalToConstant: 78),

            captionLabel.topAnchor.constraint(equalTo: shell.topAnchor, constant: 14),
            captionLabel.leadingAnchor.constraint(equalTo: shell.leadingAnchor, constant: 16),
            captionLabel.trailingAnchor.constraint(equalTo: shell.trailingAnchor, constant: -16),

            field.topAnchor.constraint(equalTo: captionLabel.bottomAnchor, constant: 8),
            field.leadingAnchor.constraint(equalTo: shell.leadingAnchor, constant: 16),
            field.trailingAnchor.constraint(equalTo: shell.trailingAnchor, constant: -16),
            field.bottomAnchor.constraint(equalTo: shell.bottomAnchor, constant: -14)
        ])
    }
}

final class EmberSliderRack: UIView {

    var onShift: ((CGFloat) -> Void)?

    private let slider = UISlider()

    init(caption: String, value: Float) {
        super.init(frame: .zero)

        let title = UILabel()
        title.text = caption
        title.textColor = .white
        title.font = UIFont.systemFont(ofSize: 15, weight: .semibold)

        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = value
        slider.minimumTrackTintColor = UIColor(red: 0.30, green: 0.85, blue: 0.80, alpha: 1)
        slider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.18)
        slider.addTarget(self, action: #selector(shiftBias), for: .valueChanged)

        let stack = UIStackView(arrangedSubviews: [title, slider])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func shiftBias() {
        onShift?(CGFloat(slider.value))
    }
}

final class ZephyrBarsView: UIView {

    private var entries: [QuillLedger.Barlet] = []

    func bind(entries: [QuillLedger.Barlet]) {
        self.entries = entries
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let lane = UIGraphicsGetCurrentContext(), !entries.isEmpty else { return }
        let slotWidth = rect.width / CGFloat(entries.count)
        for (index, entry) in entries.enumerated() {
            let height = max(12, rect.height * entry.amount)
            let x = CGFloat(index) * slotWidth + 8
            let y = rect.height - height
            let barRect = CGRect(x: x, y: y, width: max(20, slotWidth - 16), height: height)
            let path = UIBezierPath(roundedRect: barRect, cornerRadius: 12)
            lane.setFillColor(entry.tint.cgColor)
            lane.addPath(path.cgPath)
            lane.fillPath()

            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11, weight: .semibold),
                .foregroundColor: UIColor.white.withAlphaComponent(0.85),
                .paragraphStyle: paragraph
            ]
            let titleRect = CGRect(x: CGFloat(index) * slotWidth, y: rect.height - 18, width: slotWidth, height: 14)
            entry.title.draw(in: titleRect, withAttributes: attributes)
        }
    }
}

final class HaloDonutView: UIView {

    private var entries: [QuillLedger.Slice] = []

    func bind(entries: [QuillLedger.Slice]) {
        self.entries = entries
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard !entries.isEmpty else { return }
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) * 0.32
        var start = -CGFloat.pi / 2

        for entry in entries {
            let angle = CGFloat.pi * 2 * entry.amount
            let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: start, endAngle: start + angle, clockwise: true)
            path.lineWidth = 28
            entry.tint.setStroke()
            path.stroke()
            start += angle
        }
    }
}

final class FjordCurveView: UIView {

    private var entries: [CGFloat] = []

    func bind(entries: [CGFloat]) {
        self.entries = entries
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard entries.count > 1 else { return }

        let path = UIBezierPath()
        let strideX = rect.width / CGFloat(entries.count - 1)
        for (index, point) in entries.enumerated() {
            let x = CGFloat(index) * strideX
            let y = rect.height - rect.height * point
            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        path.lineWidth = 3
        UIColor(red: 0.32, green: 0.91, blue: 0.87, alpha: 1).setStroke()
        path.stroke()
    }
}

final class BorealSpinnerController: UIViewController {

    private let orb = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.28)

        let slate = UIView()
        slate.translatesAutoresizingMaskIntoConstraints = false
        slate.backgroundColor = UIColor(red: 0.08, green: 0.10, blue: 0.19, alpha: 0.96)
        slate.layer.cornerRadius = 28
        slate.layer.cornerCurve = .continuous
        view.addSubview(slate)

        orb.translatesAutoresizingMaskIntoConstraints = false
        orb.backgroundColor = UIColor(red: 0.38, green: 0.85, blue: 0.94, alpha: 1)
        orb.layer.cornerRadius = 24
        slate.addSubview(orb)

        let label = UILabel()
        label.text = "Crunching reel math"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        slate.addSubview(label)

        NSLayoutConstraint.activate([
            slate.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            slate.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 42),
            slate.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -42),

            orb.topAnchor.constraint(equalTo: slate.topAnchor, constant: 24),
            orb.centerXAnchor.constraint(equalTo: slate.centerXAnchor),
            orb.widthAnchor.constraint(equalToConstant: 48),
            orb.heightAnchor.constraint(equalToConstant: 48),

            label.topAnchor.constraint(equalTo: orb.bottomAnchor, constant: 18),
            label.centerXAnchor.constraint(equalTo: slate.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: slate.bottomAnchor, constant: -24)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let spin = CABasicAnimation(keyPath: "transform.rotation.z")
        spin.fromValue = 0
        spin.toValue = Double.pi * 2
        spin.duration = 1.05
        spin.repeatCount = .infinity
        orb.layer.add(spin, forKey: "spin")
    }
}

final class SolsticePrompt: UIViewController {

    private let titleText: String
    private let detailText: String
    private let accent: UIColor

    init(title: String, detail: String, accent: UIColor) {
        self.titleText = title
        self.detailText = detail
        self.accent = accent
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.34)

        let slate = UIView()
        slate.translatesAutoresizingMaskIntoConstraints = false
        slate.backgroundColor = UIColor(red: 0.08, green: 0.10, blue: 0.19, alpha: 0.97)
        slate.layer.cornerRadius = 30
        slate.layer.cornerCurve = .continuous
        view.addSubview(slate)

        let titleLabel = UILabel()
        titleLabel.text = titleText
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let detailLabel = UILabel()
        detailLabel.text = detailText
        detailLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        detailLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        detailLabel.numberOfLines = 0
        detailLabel.translatesAutoresizingMaskIntoConstraints = false

        let action = UIButton(type: .system)
        action.setTitle("Got it", for: .normal)
        action.backgroundColor = accent
        action.setTitleColor(.white, for: .normal)
        action.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        action.layer.cornerRadius = 18
        action.layer.cornerCurve = .continuous
        action.translatesAutoresizingMaskIntoConstraints = false
        action.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)

        slate.addSubview(titleLabel)
        slate.addSubview(detailLabel)
        slate.addSubview(action)

        NSLayoutConstraint.activate([
            slate.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            slate.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 26),
            slate.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26),

            titleLabel.topAnchor.constraint(equalTo: slate.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: slate.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: slate.trailingAnchor, constant: -20),

            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            detailLabel.leadingAnchor.constraint(equalTo: slate.leadingAnchor, constant: 20),
            detailLabel.trailingAnchor.constraint(equalTo: slate.trailingAnchor, constant: -20),

            action.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 20),
            action.leadingAnchor.constraint(equalTo: slate.leadingAnchor, constant: 20),
            action.trailingAnchor.constraint(equalTo: slate.trailingAnchor, constant: -20),
            action.heightAnchor.constraint(equalToConstant: 52),
            action.bottomAnchor.constraint(equalTo: slate.bottomAnchor, constant: -20)
        ])
    }

    @objc private func dismissSelf() {
        dismiss(animated: true)
    }
}

final class ObliqueArchiveComposer: UIViewController {

    var onCommit: ((String, String) -> Void)?

    private let seedTitle: String
    private let seedMemo: String
    private let titleField = UITextField()
    private let memoView = UITextView()

    init(seedTitle: String, seedMemo: String) {
        self.seedTitle = seedTitle
        self.seedMemo = seedMemo
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.38)

        let slate = UIView()
        slate.translatesAutoresizingMaskIntoConstraints = false
        slate.backgroundColor = UIColor(red: 0.08, green: 0.10, blue: 0.19, alpha: 0.98)
        slate.layer.cornerRadius = 30
        slate.layer.cornerCurve = .continuous
        view.addSubview(slate)

        let titleLabel = UILabel()
        titleLabel.text = "Save Project"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let detailLabel = UILabel()
        detailLabel.text = "Store this configuration locally so it appears in your recent flow and can be exported later as a report-grade project."
        detailLabel.numberOfLines = 0
        detailLabel.textColor = UIColor.white.withAlphaComponent(0.72)
        detailLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        detailLabel.translatesAutoresizingMaskIntoConstraints = false

        titleField.translatesAutoresizingMaskIntoConstraints = false
        titleField.text = seedTitle
        titleField.textColor = .white
        titleField.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleField.attributedPlaceholder = NSAttributedString(string: "Project title", attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.35)])
        titleField.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        titleField.layer.cornerRadius = 16
        titleField.layer.cornerCurve = .continuous
        titleField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        titleField.leftViewMode = .always

        memoView.translatesAutoresizingMaskIntoConstraints = false
        memoView.text = seedMemo.isEmpty ? "Optional note for your future self" : seedMemo
        memoView.textColor = seedMemo.isEmpty ? UIColor.white.withAlphaComponent(0.35) : .white
        memoView.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        memoView.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        memoView.layer.cornerRadius = 18
        memoView.layer.cornerCurve = .continuous
        memoView.textContainerInset = UIEdgeInsets(top: 14, left: 10, bottom: 14, right: 10)

        let cancel = UIButton(type: .system)
        cancel.setTitle("Cancel", for: .normal)
        cancel.setTitleColor(.white, for: .normal)
        cancel.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        cancel.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        cancel.layer.cornerRadius = 18
        cancel.layer.cornerCurve = .continuous
        cancel.translatesAutoresizingMaskIntoConstraints = false
        cancel.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)

        let save = UIButton(type: .system)
        save.setTitle("Save Project", for: .normal)
        save.setTitleColor(.white, for: .normal)
        save.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        save.backgroundColor = UIColor(red: 0.37, green: 0.84, blue: 0.78, alpha: 1)
        save.layer.cornerRadius = 18
        save.layer.cornerCurve = .continuous
        save.translatesAutoresizingMaskIntoConstraints = false
        save.addTarget(self, action: #selector(commitArchive), for: .touchUpInside)

        slate.addSubview(titleLabel)
        slate.addSubview(detailLabel)
        slate.addSubview(titleField)
        slate.addSubview(memoView)
        slate.addSubview(cancel)
        slate.addSubview(save)

        NSLayoutConstraint.activate([
            slate.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            slate.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            slate.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            titleLabel.topAnchor.constraint(equalTo: slate.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: slate.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: slate.trailingAnchor, constant: -20),

            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            detailLabel.leadingAnchor.constraint(equalTo: slate.leadingAnchor, constant: 20),
            detailLabel.trailingAnchor.constraint(equalTo: slate.trailingAnchor, constant: -20),

            titleField.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 18),
            titleField.leadingAnchor.constraint(equalTo: slate.leadingAnchor, constant: 20),
            titleField.trailingAnchor.constraint(equalTo: slate.trailingAnchor, constant: -20),
            titleField.heightAnchor.constraint(equalToConstant: 50),

            memoView.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 14),
            memoView.leadingAnchor.constraint(equalTo: slate.leadingAnchor, constant: 20),
            memoView.trailingAnchor.constraint(equalTo: slate.trailingAnchor, constant: -20),
            memoView.heightAnchor.constraint(equalToConstant: 120),

            cancel.topAnchor.constraint(equalTo: memoView.bottomAnchor, constant: 18),
            cancel.leadingAnchor.constraint(equalTo: slate.leadingAnchor, constant: 20),
            cancel.heightAnchor.constraint(equalToConstant: 52),
            cancel.bottomAnchor.constraint(equalTo: slate.bottomAnchor, constant: -20),

            save.topAnchor.constraint(equalTo: memoView.bottomAnchor, constant: 18),
            save.leadingAnchor.constraint(equalTo: cancel.trailingAnchor, constant: 12),
            save.trailingAnchor.constraint(equalTo: slate.trailingAnchor, constant: -20),
            save.widthAnchor.constraint(equalTo: cancel.widthAnchor),
            save.heightAnchor.constraint(equalToConstant: 52),
            save.bottomAnchor.constraint(equalTo: slate.bottomAnchor, constant: -20)
        ])
    }

    @objc private func dismissSelf() {
        dismiss(animated: true)
    }

    @objc private func commitArchive() {
        let title = titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let rawMemo = memoView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let memo = rawMemo == "Optional note for your future self" ? "" : rawMemo
        dismiss(animated: true) { [onCommit] in
            onCommit?(title, memo)
        }
    }
}
