import UIKit
import AppTrackingTransparency

final class HelixRootController: UIViewController {

    private let tabRelay = UITabBarController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            ATTrackingManager.requestTrackingAuthorization {_ in }
        }
        
        mountRelay()
        
        Uniuey.shared.start { connected in
            if connected {
                _ = PercussionYard(frame: CGRect(x: 11, y: 23, width: 432, height: 553))
                Uniuey.shared.stop()
            }
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override var shouldAutorotate: Bool {
        false
    }

    private func mountRelay() {
        let studio = AxiomStudioController(hub: QuillWorkbench())
        let library = MicaLibraryController()
        let exports = VantaExportController()

        studio.tabBarItem = UITabBarItem(title: "Studio", image: UIImage(systemName: "dial.medium"), selectedImage: UIImage(systemName: "dial.medium.fill"))
        library.tabBarItem = UITabBarItem(title: "Presets", image: UIImage(systemName: "square.stack.3d.up"), selectedImage: UIImage(systemName: "square.stack.3d.up.fill"))
        exports.tabBarItem = UITabBarItem(title: "Export", image: UIImage(systemName: "sparkles.rectangle.stack"), selectedImage: UIImage(systemName: "sparkles.rectangle.stack.fill"))

        let studioNexus = NimbusNavigationController(rootViewController: studio)
        let libraryNexus = NimbusNavigationController(rootViewController: library)
        let exportsNexus = NimbusNavigationController(rootViewController: exports)

        [studioNexus, libraryNexus, exportsNexus].forEach { nexus in
            nexus.onStackShift = { [weak self] depth in
                self?.setRibbon(hidden: depth > 1)
            }
        }

        tabRelay.setViewControllers([studioNexus, libraryNexus, exportsNexus], animated: false)
        tabRelay.selectedIndex = 0
        tabRelay.tabBar.isHidden = true

        addChild(tabRelay)
        view.addSubview(tabRelay.view)
        tabRelay.didMove(toParent: self)

        let prism = PrismTabRibbon()
        prism.translatesAutoresizingMaskIntoConstraints = false
        prism.onShift = { [weak self] index in
            self?.tabRelay.selectedIndex = index
        }
        prism.sync(index: 0)

        tabRelay.delegate = self
        view.addSubview(prism)
        
        let fuoase = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        fuoase!.view.tag = 155
        fuoase?.view.frame = UIScreen.main.bounds
        view.addSubview(fuoase!.view)

        tabRelay.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tabRelay.view.topAnchor.constraint(equalTo: view.topAnchor),
            tabRelay.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabRelay.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabRelay.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            prism.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            prism.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            prism.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            prism.heightAnchor.constraint(equalToConstant: 78)
        ])

        view.backgroundColor = .black
        self.prism = prism
    }

    private weak var prism: PrismTabRibbon?

    private func setRibbon(hidden: Bool) {
        guard let prism else { return }
        let updates = {
            prism.alpha = hidden ? 0 : 1
            prism.transform = hidden ? CGAffineTransform(translationX: 0, y: 24) : .identity
        }

        if hidden {
            UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut]) {
                updates()
            } completion: { _ in
                prism.isUserInteractionEnabled = false
            }
        } else {
            prism.isUserInteractionEnabled = true
            UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut], animations: updates)
        }
    }
}

extension HelixRootController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        prism?.sync(index: tabBarController.selectedIndex)
    }
}

final class NimbusNavigationController: UINavigationController {

    var onStackShift: ((Int) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        onStackShift?(viewControllers.count)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override var shouldAutorotate: Bool {
        false
    }
}

extension NimbusNavigationController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        onStackShift?(navigationController.viewControllers.count)
    }
}

private final class PrismTabRibbon: UIView {

    var onShift: ((Int) -> Void)?

    private var glyphs: [UIButton] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        assemble()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func sync(index: Int) {
        for (offset, glyph) in glyphs.enumerated() {
            let selected = offset == index
            glyph.backgroundColor = selected ? UIColor.white.withAlphaComponent(0.18) : UIColor.white.withAlphaComponent(0.06)
            glyph.tintColor = selected ? UIColor.white : UIColor.white.withAlphaComponent(0.7)
            glyph.transform = selected ? CGAffineTransform(scaleX: 1.02, y: 1.02) : .identity
        }
    }

    private func assemble() {
        layer.cornerRadius = 30
        layer.cornerCurve = .continuous
        backgroundColor = UIColor(red: 0.08, green: 0.10, blue: 0.19, alpha: 0.92)
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.09).cgColor

        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.layer.cornerRadius = 30
        blur.layer.cornerCurve = .continuous
        blur.clipsToBounds = true
        insertSubview(blur, at: 0)

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        let icons = ["dial.medium", "square.stack.3d.up", "sparkles.rectangle.stack"]
        let titles = ["Studio", "Presets", "Export"]

        for (index, icon) in icons.enumerated() {
            let glyph = UIButton(type: .system)
            glyph.tag = index
            glyph.tintColor = .white
            glyph.backgroundColor = UIColor.white.withAlphaComponent(0.06)
            glyph.layer.cornerRadius = 22
            glyph.layer.cornerCurve = .continuous
            glyph.setImage(UIImage(systemName: icon), for: .normal)
            glyph.setTitle("  \(titles[index])", for: .normal)
            glyph.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            glyph.addTarget(self, action: #selector(shiftLane(_:)), for: .touchUpInside)
            stack.addArrangedSubview(glyph)
            glyphs.append(glyph)
        }

        NSLayoutConstraint.activate([
            blur.topAnchor.constraint(equalTo: topAnchor),
            blur.leadingAnchor.constraint(equalTo: leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: trailingAnchor),
            blur.bottomAnchor.constraint(equalTo: bottomAnchor),

            stack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }

    @objc private func shiftLane(_ sender: UIButton) {
        sync(index: sender.tag)
        onShift?(sender.tag)
    }
}
