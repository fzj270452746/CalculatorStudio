import UIKit

final class VantaExportController: UIViewController {

    private let depot = VaultDepot.shared
    private let hub = QuillWorkbench()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Export Center"
        view.backgroundColor = UIColor(red: 0.04, green: 0.05, blue: 0.10, alpha: 1)

        let slate = LumaCardView()
        slate.translatesAutoresizingMaskIntoConstraints = false
        slate.header(title: "Export Ready", subtitle: "Export the current studio state as PDF, JSON or CSV.")

        let label = UILabel()
        label.text = "Files are written into Documents and then passed into the standard share sheet, which keeps the flow lightweight and App Store-safe."
        label.numberOfLines = 0
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        slate.embed(label)

        let rack = UIStackView()
        rack.axis = .vertical
        rack.spacing = 12
        rack.addArrangedSubview(exportButton(title: "Export PDF", tone: UIColor(red: 0.76, green: 0.38, blue: 1.0, alpha: 1), action: #selector(exportPDF)))
        rack.addArrangedSubview(exportButton(title: "Export JSON", tone: UIColor(red: 0.28, green: 0.85, blue: 0.81, alpha: 1), action: #selector(exportJSON)))
        rack.addArrangedSubview(exportButton(title: "Export CSV", tone: UIColor(red: 0.98, green: 0.60, blue: 0.31, alpha: 1), action: #selector(exportCSV)))
        slate.embed(rack)

        view.addSubview(slate)
        NSLayoutConstraint.activate([
            slate.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            slate.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            slate.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func exportButton(title: String, tone: UIColor, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = tone
        button.layer.cornerRadius = 18
        button.layer.cornerCurve = .continuous
        button.heightAnchor.constraint(equalToConstant: 52).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc private func exportPDF() {
        guard let ledger = depot.ledger else {
            present(SolsticePrompt(title: "Nothing to export", detail: "Run a simulation in Studio first so the report has real numbers.", accent: .systemPink), animated: true)
            return
        }

        do {
            let url = try CodexExporter().savePDF(blueprint: depot.blueprint, ledger: ledger)
            presentShare(for: url)
        } catch {
            present(SolsticePrompt(title: "PDF export failed", detail: error.localizedDescription, accent: .systemPink), animated: true)
        }
    }

    @objc private func exportJSON() {
        do {
            let url = try CodexExporter().saveJSON(data: hub.serializeDeck(depot.blueprint), title: depot.blueprint.title)
            presentShare(for: url)
        } catch {
            present(SolsticePrompt(title: "JSON export failed", detail: error.localizedDescription, accent: .systemPink), animated: true)
        }
    }

    @objc private func exportCSV() {
        guard let ledger = depot.ledger else {
            present(SolsticePrompt(title: "Nothing to export", detail: "Run a simulation in Studio first so the spreadsheet has real rows.", accent: .systemPink), animated: true)
            return
        }

        do {
            let csv = hub.csvSheet(for: depot.blueprint, ledger: ledger)
            let url = try CodexExporter().saveCSV(text: csv, title: depot.blueprint.title)
            presentShare(for: url)
        } catch {
            present(SolsticePrompt(title: "CSV export failed", detail: error.localizedDescription, accent: .systemPink), animated: true)
        }
    }

    private func presentShare(for url: URL) {
        let relay = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let sheet = relay.popoverPresentationController {
            sheet.sourceView = view
            sheet.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 1, height: 1)
        }
        present(relay, animated: true)
    }
}
