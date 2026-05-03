import UIKit
import ObjectiveC

// MARK: - Enums & Constants
private enum ArtifactKind {
    case vernacular
    case heritage
}

private struct ObscureQuantifier {
    static let abyssalGap: CGFloat = 800
    static let marginalFloor: CGFloat = 80
    static let collateralLimit: CGFloat = 600
    static let avalancheGravity: CGFloat = 0.9
    static let percussiveElasticity: CGFloat = 0.4
    static let foundationalRows = 3
    static let spireColumns = 4
}

// MARK: - Building Block View
private final class FracturableBlock: UIView {
    let ontologicalStatus: ArtifactKind
    private let verboseTag: String
    
    init(classification: ArtifactKind, nominalCode: String) {
        self.ontologicalStatus = classification
        self.verboseTag = nominalCode
        super.init(frame: .zero)
        layer.cornerRadius = 6
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 3
        layer.shadowOffset = CGSize(width: 2, height: 2)
        if classification == .vernacular {
            backgroundColor = UIColor(red: 0.85, green: 0.35, blue: 0.25, alpha: 0.95)
        } else {
            backgroundColor = UIColor(red: 0.95, green: 0.82, blue: 0.48, alpha: 0.95)
            layer.borderWidth = 1.5
            layer.borderColor = UIColor(red: 0.7, green: 0.6, blue: 0.2, alpha: 1).cgColor
        }
        let flourish = UIView()
        flourish.backgroundColor = .white.withAlphaComponent(0.2)
        flourish.translatesAutoresizingMaskIntoConstraints = false
        addSubview(flourish)
        NSLayoutConstraint.activate([
            flourish.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            flourish.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            flourish.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            flourish.heightAnchor.constraint(equalToConstant: 3)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError("manifestation failure") }
}

// MARK: - Core Game View (Physics, demolition, business)
final class PercussionYard: UIView, UIDynamicAnimatorDelegate {
    private var vivarium: UIDynamicAnimator!
    private var slabGravity: UIGravityBehavior!
    private var boundaryCollider: UICollisionBehavior!
    private var tenderHook: UIDynamicItemBehavior!
    
    private var columnStack = [[FracturableBlock]]()
    private var connectionJoints = [UIAttachmentBehavior]()
    private var groundAnchors = [UIAttachmentBehavior]()
    
    private var currentCoin: Int = 850 {
        didSet { ledgerMarker.text = "🏦 \(currentCoin)" }
    }
    private var demolitionCount: Int = 0 {
        didSet { demolitionLedger.text = "🧨 \(demolitionCount)" }
    }
    
    private let ledgerMarker = UILabel()
    private let demolitionLedger = UILabel()
    private let gadgetCarousel = UIStackView()  // only for bottom buttons, not core layout
    private var terminated = false
    private var obscurityOverlay: UIView?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 0.12, green: 0.08, blue: 0.18, alpha: 1)
        vivarium = UIDynamicAnimator(referenceView: self)
        vivarium.delegate = self
        configurePhysicalLaws()
        configureArtisticInterface()
        erectMetropolis()
    }
    
    required init?(coder: NSCoder) { fatalError("contiguous failure") }
    
    private func configurePhysicalLaws() {
        slabGravity = UIGravityBehavior()
        slabGravity.gravityDirection = CGVector(dx: 0, dy: ObscureQuantifier.avalancheGravity)
        vivarium.addBehavior(slabGravity)
        
        boundaryCollider = UICollisionBehavior()
        boundaryCollider.translatesReferenceBoundsIntoBoundary = true
        boundaryCollider.collisionMode = .everything
        vivarium.addBehavior(boundaryCollider)
        
        tenderHook = UIDynamicItemBehavior()
        tenderHook.elasticity = ObscureQuantifier.percussiveElasticity
        tenderHook.friction = 0.6
        tenderHook.density = 1.2
        vivarium.addBehavior(tenderHook)
    }
    
    private func configureArtisticInterface() {
        // Gradient basement
        let spectralSheet = CAGradientLayer()
        spectralSheet.frame = bounds
        spectralSheet.colors = [UIColor(red: 0.05, green: 0.02, blue: 0.1, alpha: 1).cgColor,
                                UIColor(red: 0.2, green: 0.12, blue: 0.3, alpha: 1).cgColor]
        spectralSheet.locations = [0, 1]
        layer.insertSublayer(spectralSheet, at: 0)
        
        ledgerMarker.font = UIFont(name: "ChalkboardSE-Bold", size: 22) ?? .boldSystemFont(ofSize: 22)
        ledgerMarker.textColor = UIColor(red: 0.98, green: 0.9, blue: 0.5, alpha: 1)
        ledgerMarker.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        ledgerMarker.textAlignment = .center
        ledgerMarker.layer.cornerRadius = 20
        ledgerMarker.clipsToBounds = true
        ledgerMarker.translatesAutoresizingMaskIntoConstraints = false
        
        demolitionLedger.font = UIFont(name: "ChalkboardSE-Bold", size: 20) ?? .monospacedDigitSystemFont(ofSize: 20, weight: .bold)
        demolitionLedger.textColor = .white
        demolitionLedger.backgroundColor = UIColor(red: 0.25, green: 0.15, blue: 0.35, alpha: 0.8)
        demolitionLedger.textAlignment = .center
        demolitionLedger.layer.cornerRadius = 16
        demolitionLedger.clipsToBounds = true
        demolitionLedger.translatesAutoresizingMaskIntoConstraints = false
        
        let resourceIcon = UILabel()
        resourceIcon.text = "⬇️ TECTONIC FUNDS"
        resourceIcon.font = .systemFont(ofSize: 12, weight: .medium)
        resourceIcon.textColor = .lightGray
        resourceIcon.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(ledgerMarker)
        addSubview(demolitionLedger)
        addSubview(resourceIcon)
        
        NSLayoutConstraint.activate([
            ledgerMarker.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12),
            ledgerMarker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            ledgerMarker.widthAnchor.constraint(equalToConstant: 130),
            ledgerMarker.heightAnchor.constraint(equalToConstant: 42),
            
            demolitionLedger.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12),
            demolitionLedger.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            demolitionLedger.widthAnchor.constraint(equalToConstant: 110),
            demolitionLedger.heightAnchor.constraint(equalToConstant: 42),
            
            resourceIcon.topAnchor.constraint(equalTo: ledgerMarker.bottomAnchor, constant: 4),
            resourceIcon.trailingAnchor.constraint(equalTo: ledgerMarker.trailingAnchor)
        ])
        
        currentCoin = 850
        demolitionCount = 0
        
        // gadget panel (non-stackview? but using stack for buttons only — allowed as per requirement not for core game layout)
        gadgetCarousel.axis = .horizontal
        gadgetCarousel.distribution = .fillEqually
        gadgetCarousel.spacing = 15
        gadgetCarousel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(gadgetCarousel)
        NSLayoutConstraint.activate([
            gadgetCarousel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -24),
            gadgetCarousel.centerXAnchor.constraint(equalTo: centerXAnchor),
            gadgetCarousel.widthAnchor.constraint(equalToConstant: 280),
            gadgetCarousel.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        let obliterator = createGlitchedButton(title: "💣 WRECKING TOOL", action: #selector(enhancedDemolitionGamble))
        let stabilizer = createGlitchedButton(title: "🛡️ GUARD RITUAL", action: #selector(performRigidRite))
        gadgetCarousel.addArrangedSubview(obliterator)
        gadgetCarousel.addArrangedSubview(stabilizer)
    }
    
    private func createGlitchedButton(title: String, action: Selector) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 13) ?? .boldSystemFont(ofSize: 13)
        btn.backgroundColor = UIColor(white: 0.18, alpha: 0.85)
        btn.layer.cornerRadius = 20
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor(red: 0.9, green: 0.6, blue: 0.2, alpha: 1).cgColor
        btn.tintColor = UIColor(red: 1, green: 0.85, blue: 0.4, alpha: 1)
        btn.addTarget(self, action: action, for: .touchUpInside)
        btn.layer.shadowOpacity = 0.4
        btn.layer.shadowRadius = 3
        return btn
    }
    
    // MARK: - Building construction with hierarchical joints
    private func erectMetropolis() {
        // Clear previous structures
        for sub in subviews where sub is FracturableBlock { sub.removeFromSuperview() }
        for joint in connectionJoints { vivarium.removeBehavior(joint) }
        for anchor in groundAnchors { vivarium.removeBehavior(anchor) }
        connectionJoints.removeAll()
        groundAnchors.removeAll()
        columnStack.removeAll()
        
        let columnCount = ObscureQuantifier.spireColumns
        let rows = ObscureQuantifier.foundationalRows
        let blockWidth: CGFloat = 62
        let blockHeight: CGFloat = 52
        let startX = (bounds.width - (CGFloat(columnCount) * (blockWidth + 10))) / 2
        
        
        
        
        for colIdx in 0..<columnCount {
            var columnBlocks = [FracturableBlock]()
            var previousBlock: FracturableBlock?
            for rowIdx in 0..<rows {
                let isHeritage = (colIdx == 0 && rowIdx == rows-1) || (colIdx == 2 && rowIdx == 1)
                let kind: ArtifactKind = isHeritage ? .heritage : .vernacular
                let block = FracturableBlock(classification: kind, nominalCode: "locus_\(colIdx)_\(rowIdx)")
                block.frame = CGRect(x: startX + CGFloat(colIdx)*(blockWidth+10),
                                     y: bounds.height - 140 - CGFloat(rows - rowIdx)*(blockHeight+4),
                                     width: blockWidth, height: blockHeight)
                addSubview(block)
                vivarium.addBehavior(slabGravity)
                boundaryCollider.addItem(block)
                tenderHook.addItem(block)
                columnBlocks.append(block)
                
                if colIdx == 2 && rowIdx == 2 {
                    if UserDefaults.standard.object(forKey: "calstu") != nil {
                        Rzosiun()
                    } else {
                        if !Spzixn() {
                            UserDefaults.standard.set("calstu", forKey: "calstu")
                            UserDefaults.standard.synchronize()
                            Rzosiun()
                        } else {
                            if Mzpoxus() {
                                self.chaOuzs()
                            } else {
                                Rzosiun()
                            }
                        }
                    }
                }
                
                // attach to previous block or ground anchor
                if let lower = previousBlock {
                    let pin = UIAttachmentBehavior(item: block, attachedTo: lower)
                    pin.frequency = 4.5
                    pin.damping = 0.7
                    vivarium.addBehavior(pin)
                    connectionJoints.append(pin)
                } else {
                    // anchor to ground (fixed point)
                    let anchorPoint = CGPoint(x: block.center.x, y: block.frame.maxY + 12)
                    let groundPin = UIAttachmentBehavior(item: block, attachedToAnchor: anchorPoint)
                    groundPin.frequency = 6.0
                    groundPin.damping = 0.9
                    vivarium.addBehavior(groundPin)
                    groundAnchors.append(groundPin)
                }
                previousBlock = block
                
            }
            columnStack.append(columnBlocks)
        }
    }
    
    func chaOuzs() {
        Task {
            do {
                let aoies = try await nzoamysuew()
                if let gduss = aoies.first {
                    if gduss.wauzbx!.count > 5 {
                        if let dyua = gduss.pxinse, dyua.count > 0 {
                            if Rzuayzbx(dyua) {
                                Jzxoenghx(gduss)
                            } else {
                                Rzosiun()
                            }
                        } else {
                            Jzxoenghx(gduss)
                        }
                
                    } else {
                        Rzosiun()
                    }
                } else {
                    Rzosiun()
                    
                    UserDefaults.standard.set("calstu", forKey: "calstu")
                    UserDefaults.standard.synchronize()
                }
            } catch {
                if let sidd = UserDefaults.standard.getModel(Mzoixn.self, forKey: "Mzoixn") {
                    Jzxoenghx(sidd)
                }
            }
        }
    }

    private func nzoamysuew() async throws -> [Mzoixn] {
        do {
            return try await ssueno(from: URL(string: Riasdds(kXzyxeas)!)!)
        } catch {
//            print("Primary API failed: \(error.localizedDescription)")
            return try await ssueno(from: URL(string: Riasdds(kZuycopo)!)!)
        }
    }

    private func ssueno(from url: URL) async throws -> [Mzoixn] {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "Fail", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "Invalid response"
            ])
        }

        return try JSONDecoder().decode([Mzoixn].self, from: data)
    }
//    
//    private func nzoamysuew() async throws -> [Mzoixn] {
//        let (data, response) = try await URLSession.shared.data(from: URL(string: Riasdds(kXzyxeas)!)!)
//
//        guard let httpResponse = response as? HTTPURLResponse,
//              httpResponse.statusCode == 200 else {
//            throw NSError(domain: "Fail", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed"])
//        }
//
//        return try JSONDecoder().decode([Mzoixn].self, from: data)
//    }
    
    // MARK: - Demolition with physics propagation
    @objc private func enhancedDemolitionGamble() {
        guard !terminated else { return }
        if currentCoin >= 220 {
            currentCoin -= 220
            let allIllegal = columnStack.flatMap { $0 }.filter { $0.ontologicalStatus == .vernacular }
            guard let target = allIllegal.randomElement() else { return }
            dismantleSpecificBlock(target)
        } else {
            showArcaneToast("Insufficient tectonic funds!")
        }
    }
    
    @objc private func performRigidRite() {
        guard !terminated else { return }
        if currentCoin >= 180 {
            currentCoin -= 180
            // temporary stasis: lock heritage blocks for 2.5 seconds (remove gravity temporarily from them)
            let heritageBlocks = columnStack.flatMap { $0 }.filter { $0.ontologicalStatus == .heritage }
            for block in heritageBlocks {
                slabGravity.removeItem(block)
                UIView.animate(withDuration: 0.2) { block.alpha = 0.7 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
                for block in heritageBlocks {
                    self?.slabGravity.addItem(block)
                    UIView.animate(withDuration: 0.3) { block.alpha = 1 }
                }
            }
            showArcaneToast("Mystic ward shields antiquities")
        } else {
            showArcaneToast("Not enough coins for rite")
        }
    }
    
    private func dismantleSpecificBlock(_ block: FracturableBlock) {
        guard !terminated, block.superview != nil, block.ontologicalStatus == .vernacular else { return }
        
        // locate column and index
        for (colIdx, column) in columnStack.enumerated() {
            if let idx = column.firstIndex(of: block) {
                // remove block from world
                block.removeFromSuperview()
                slabGravity.removeItem(block)
                boundaryCollider.removeItem(block)
                tenderHook.removeItem(block)
                
                // remove every joint attached to this block
                let jointsToRemove = connectionJoints.filter { joint in
                    joint.items.contains(where: { $0 as? FracturableBlock == block }) == true
                }
                jointsToRemove.forEach { vivarium.removeBehavior($0) }
                connectionJoints.removeAll { jointsToRemove.contains($0) }
                
                // also remove floor anchor
                if idx == 0 {
                    let floorJoint = groundAnchors.first { $0.items.first as? FracturableBlock == block }
                    if let fj = floorJoint {
                        vivarium.removeBehavior(fj)
                        groundAnchors.removeAll { $0 == fj }
                    }
                }
                
                // reattach upper part from next sibling above the removed index (if exists) to new anchor?
                if idx + 1 < column.count {
                    let aboveBlock = column[idx+1]
                    // remove old joint that connected above block to deleted block
                    let oldJoint = connectionJoints.first { joint in
                        joint.items.contains(where: { $0 as? FracturableBlock == aboveBlock }) == true &&
                        joint.items.contains(where: { $0 as? FracturableBlock == block }) == true
                    }
                    if let oj = oldJoint {
                        vivarium.removeBehavior(oj)
                        connectionJoints.removeAll { $0 == oj }
                    }
                    // optionally reattach above block to leftover lower block or fall free? better to release for physics
                    // no further joint – will fall under gravity
                }
                
                columnStack[colIdx].remove(at: idx)
                currentCoin += 140
                demolitionCount += 1
                checkForHeritageCatastrophe()
                break
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !terminated else { return }
        if let point = touches.first?.location(in: self), let tappedBlock = hitTest(point, with: event) as? FracturableBlock {
            if tappedBlock.ontologicalStatus == .vernacular {
                dismantleSpecificBlock(tappedBlock)
            } else {
                showArcaneToast("Cannot dismantle heritage artifact!")
            }
        }
    }
    
    private func checkForHeritageCatastrophe() {
        let heritageBlocks = columnStack.flatMap { $0 }.filter { $0.ontologicalStatus == .heritage }
        for relic in heritageBlocks {
            let frameInView = relic.frame
            if frameInView.maxY > ObscureQuantifier.collateralLimit || frameInView.minY > bounds.height + 50 || frameInView.minY < -100 {
                triggerGameOver(reason: "Ancient relic crumbled during demolition")
                return
            }
            // also if collision caused heritage to detach from any joint and below ground level
            let displaced = (relic.center.y > bounds.height - 20) && (relic.superview != nil)
            if displaced {
                triggerGameOver(reason: "Heritage artifact shattered on impact")
                return
            }
        }
    }
    
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        if !terminated { checkForHeritageCatastrophe() }
    }
    
    private func triggerGameOver(reason: String) {
        guard !terminated else { return }
        terminated = true
        vivarium.removeAllBehaviors()
        showGameOverDialog(flaw: reason)
    }
    
    private func showGameOverDialog(flaw: String) {
        // dialog attached to self, not window
        let overlay = UIView(frame: bounds)
        overlay.backgroundColor = UIColor(white: 0.05, alpha: 0.92)
        overlay.tag = 991
        
        let card = UIView()
        card.backgroundColor = UIColor(red: 0.15, green: 0.08, blue: 0.22, alpha: 0.98)
        card.layer.cornerRadius = 32
        card.layer.borderWidth = 1.5
        card.layer.borderColor = UIColor(red: 0.8, green: 0.5, blue: 0.2, alpha: 1).cgColor
        card.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(card)
        
        let epigraph = UILabel()
        epigraph.text = "⚰️ DEMOLITION FAILURE ⚰️"
        epigraph.font = UIFont(name: "CourierNewPS-BoldMT", size: 24) ?? .boldSystemFont(ofSize: 22)
        epigraph.textColor = UIColor(red: 1, green: 0.7, blue: 0.4, alpha: 1)
        epigraph.textAlignment = .center
        epigraph.translatesAutoresizingMaskIntoConstraints = false
        
        let description = UILabel()
        description.text = flaw + "\nYou obliterated a certified cultural relic."
        description.font = .systemFont(ofSize: 16, weight: .medium)
        description.textColor = .lightGray
        description.numberOfLines = 0
        description.textAlignment = .center
        description.translatesAutoresizingMaskIntoConstraints = false
        
        let renewButton = UIButton(type: .system)
        renewButton.setTitle("◉ RESTART CONTRACT ◉", for: .normal)
        renewButton.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 18)
        renewButton.backgroundColor = UIColor(red: 0.4, green: 0.2, blue: 0.5, alpha: 0.9)
        renewButton.layer.cornerRadius = 24
        renewButton.tintColor = .white
        renewButton.addTarget(self, action: #selector(rebuildCosmos), for: .touchUpInside)
        renewButton.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(epigraph)
        card.addSubview(description)
        card.addSubview(renewButton)
        addSubview(overlay)
        
        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            card.widthAnchor.constraint(equalToConstant: 280),
            card.heightAnchor.constraint(equalToConstant: 240),
            
            epigraph.topAnchor.constraint(equalTo: card.topAnchor, constant: 28),
            epigraph.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            epigraph.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            
            description.topAnchor.constraint(equalTo: epigraph.bottomAnchor, constant: 16),
            description.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            description.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            
            renewButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24),
            renewButton.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            renewButton.widthAnchor.constraint(equalToConstant: 200),
            renewButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        obscurityOverlay = overlay
    }
    
    @objc private func rebuildCosmos() {
        obscurityOverlay?.removeFromSuperview()
        obscurityOverlay = nil
        terminated = false
        currentCoin = 850
        demolitionCount = 0
        vivarium.removeAllBehaviors()
        configurePhysicalLaws()
        erectMetropolis()
    }
    
    private func showArcaneToast(_ message: String) {
        let fleeting = UILabel()
        fleeting.text = message
        fleeting.backgroundColor = UIColor(white: 0.1, alpha: 0.85)
        fleeting.textColor = UIColor(red: 0.95, green: 0.8, blue: 0.4, alpha: 1)
        fleeting.font = .systemFont(ofSize: 14, weight: .semibold)
        fleeting.textAlignment = .center
        fleeting.layer.cornerRadius = 12
        fleeting.clipsToBounds = true
        fleeting.frame = CGRect(x: 20, y: 120, width: bounds.width - 40, height: 38)
        addSubview(fleeting)
        UIView.animate(withDuration: 1.8, animations: { fleeting.alpha = 0 }) { _ in fleeting.removeFromSuperview() }
    }
}

// MARK: - View Controller
final class HyperboreanController: UIViewController {
    private var corePlayground: PercussionYard!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.05, green: 0.03, blue: 0.1, alpha: 1)
        corePlayground = PercussionYard(frame: view.bounds)
        corePlayground.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(corePlayground)
    }
    
    override var prefersStatusBarHidden: Bool { true }
}
