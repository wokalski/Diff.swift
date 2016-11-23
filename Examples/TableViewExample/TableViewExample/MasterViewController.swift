
import UIKit
import Diff

class MasterViewController: UITableViewController {

    var objects = [
        "🌞",
        "🐩",
        "👌🏽",
        "🦄",
        "👋🏻",
        "🙇🏽‍♀️",
        "🔥",
    ] {
        didSet {
            tableView.animateRowChanges(
                oldData: oldValue,
                newData: objects,
                deletionAnimation: .right,
                insertionAnimation: .right)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let addButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh(_:)))
        self.navigationItem.rightBarButtonItem = addButton
    }

    func refresh(_ sender: Any) {
        let moveIndices = (0 ... 0).map { _ in (randomIndex(), randomIndex()) }
        let insertionIndices = (0 ... 0).map { _ in randomIndex() }
        let deleteIndices = (0 ... 0).map { _ in randomIndex() }

        var mutableObjects = objects

        moveIndices.forEach { from, to in
            let element = mutableObjects.remove(at: from)
            mutableObjects.insert(element, at: to)
        }

        insertionIndices.forEach { index in
            mutableObjects.insert(randomEmoji(), at: index)
        }

        deleteIndices.forEach { index in
            mutableObjects.remove(at: index)
        }

        objects = mutableObjects
    }

    func randomIndex() -> Int {
        return Int(arc4random_uniform(UInt32(objects.count)))
    }

    func randomEmoji() -> String {
        let emojis = (UInt32(0x1F601) ... UInt32(0x1F64F)).map { String(UnicodeScalar($0)!) }
        return emojis[Int(arc4random_uniform(UInt32(emojis.count)))]
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = objects[indexPath.row]
        return cell
    }
}
