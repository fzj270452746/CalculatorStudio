import Foundation

struct ArchiveCodex: Codable {
    let id: UUID
    var title: String
    var memo: String
    var blueprint: RuneBlueprint
    var updatedAt: Date
    var cachedRTP: Double?
    var cachedHitRate: Double?

    init(id: UUID = UUID(), title: String, memo: String, blueprint: RuneBlueprint, updatedAt: Date = Date(), cachedRTP: Double? = nil, cachedHitRate: Double? = nil) {
        self.id = id
        self.title = title
        self.memo = memo
        self.blueprint = blueprint
        self.updatedAt = updatedAt
        self.cachedRTP = cachedRTP
        self.cachedHitRate = cachedHitRate
    }
}

private struct VaultBundle: Codable {
    var archives: [ArchiveCodex]
    var recentIDs: [UUID]
    var currentArchiveID: UUID?
}

final class VaultDepot {

    static let shared = VaultDepot()

    static let didShift = Notification.Name("VaultDepot.didShift")

    private let scriber = JSONEncoder()
    private let decoder = JSONDecoder()
    private let shelfURL: URL

    private init() {
        scriber.outputFormatting = [.prettyPrinted, .sortedKeys]
        let libraryRoot = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        shelfURL = libraryRoot.appendingPathComponent("vault-codex").appendingPathExtension("json")
        hydrateShelf()
    }

    var blueprint: RuneBlueprint = RuneBlueprint.sampleDeck[0]
    var ledger: QuillLedger?
    var archives: [ArchiveCodex] = []
    var recentIDs: [UUID] = []
    var currentArchiveID: UUID?

    var recentArchives: [ArchiveCodex] {
        recentIDs.compactMap { seekArchive(id: $0) }
    }

    @discardableResult
    func upsertArchive(title: String, memo: String, blueprint: RuneBlueprint, ledger: QuillLedger?) -> ArchiveCodex {
        let normalizedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? blueprint.title : title.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedMemo = memo.trimmingCharacters(in: .whitespacesAndNewlines)

        let archive: ArchiveCodex
        if let currentArchiveID, let index = archives.firstIndex(where: { $0.id == currentArchiveID }) {
            archives[index].title = normalizedTitle
            archives[index].memo = normalizedMemo
            archives[index].blueprint = blueprint
            archives[index].updatedAt = Date()
            archives[index].cachedRTP = ledger?.rtp
            archives[index].cachedHitRate = ledger?.hitRate
            archive = archives[index]
        } else {
            archive = ArchiveCodex(title: normalizedTitle, memo: normalizedMemo, blueprint: blueprint, cachedRTP: ledger?.rtp, cachedHitRate: ledger?.hitRate)
            archives.insert(archive, at: 0)
        }

        currentArchiveID = archive.id
        self.blueprint = blueprint
        self.ledger = ledger
        swayRecent(with: archive.id)
        settleArchiveOrder(anchor: archive.id)
        persistShelf()
        return archive
    }

    func revealArchive(id: UUID) -> ArchiveCodex? {
        guard let archive = seekArchive(id: id) else { return nil }
        currentArchiveID = archive.id
        blueprint = archive.blueprint
        ledger = nil
        swayRecent(with: archive.id)
        persistShelf()
        return archive
    }

    func discardArchive(id: UUID) {
        archives.removeAll { $0.id == id }
        recentIDs.removeAll { $0 == id }
        if currentArchiveID == id {
            currentArchiveID = nil
        }
        persistShelf()
    }

    func importBlueprint(_ blueprint: RuneBlueprint, archiveID: UUID? = nil) {
        self.blueprint = blueprint
        self.currentArchiveID = archiveID
        self.ledger = nil
        if let archiveID {
            swayRecent(with: archiveID)
        }
        persistShelf()
    }

    func archiveLabel() -> String {
        guard let currentArchiveID, let archive = seekArchive(id: currentArchiveID) else {
            return "Unsaved Draft"
        }
        return archive.title
    }

    private func hydrateShelf() {
        guard let data = try? Data(contentsOf: shelfURL),
              let bundle = try? decoder.decode(VaultBundle.self, from: data) else {
            archives = []
            recentIDs = []
            currentArchiveID = nil
            return
        }
        archives = bundle.archives.sorted { $0.updatedAt > $1.updatedAt }
        recentIDs = bundle.recentIDs
        currentArchiveID = bundle.currentArchiveID
        if let currentArchiveID, let archive = seekArchive(id: currentArchiveID) {
            blueprint = archive.blueprint
        }
    }

    private func persistShelf() {
        let bundle = VaultBundle(archives: archives, recentIDs: Array(recentIDs.prefix(8)), currentArchiveID: currentArchiveID)
        guard let data = try? scriber.encode(bundle) else { return }
        try? data.write(to: shelfURL, options: .atomic)
        NotificationCenter.default.post(name: Self.didShift, object: nil)
    }

    private func seekArchive(id: UUID) -> ArchiveCodex? {
        archives.first { $0.id == id }
    }

    private func swayRecent(with id: UUID) {
        recentIDs.removeAll { $0 == id }
        recentIDs.insert(id, at: 0)
        recentIDs = Array(recentIDs.prefix(8))
    }

    private func settleArchiveOrder(anchor id: UUID) {
        guard let index = archives.firstIndex(where: { $0.id == id }) else { return }
        let anchor = archives.remove(at: index)
        archives.insert(anchor, at: 0)
    }
}
