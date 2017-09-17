import UIKit

struct StringArray: Equatable, Collection {

    let elements: [String]
    let key: String

    typealias Index = Int

    var startIndex: Int {
        return elements.startIndex
    }

    var endIndex: Int {
        return elements.endIndex
    }

    subscript(i: Int) -> String {
        return elements[i]
    }

    public func index(after i: Int) -> Int {
        return elements.index(after: i)
    }

    static func ==(fst: StringArray, snd: StringArray) -> Bool {
        return fst.key == snd.key
    }
}

class NestedTableViewController: UITableViewController {

    let items = [
        [
            StringArray(
                elements: [
                    "🌞",
                    "🐩",
                ],
                key: "First"
            ),
            StringArray(
                elements: [
                    "👋🏻",
                    "🎁",
                ],
                key: "Second"
            ),
        ],
        [
            StringArray(
                elements: [
                    "🎁",
                    "👋🏻",
                ],
                key: "Second"
            ),
            StringArray(
                elements: [
                    "🌞",
                    "🐩",
                ],
                key: "First"
            ),
            StringArray(
                elements: [
                    "😊",
                ],
                key: "Third"
            ),
        ],
    ]

    var currentConfiguration = 0 {
        didSet {
            tableView.animateRowAndSectionChanges(
                oldData: items[oldValue],
                newData: items[currentConfiguration]
            )
        }
    }

    private let reuseIdentifier = "Cell"

    override func viewDidLoad() {
        super.viewDidLoad()

        let addButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh(_:)))
        navigationItem.rightBarButtonItem = addButton
    }

    @IBAction func refresh(_ sender: Any) {
        currentConfiguration = currentConfiguration == 0 ? 1 : 0
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UILabel()
        view.text = items[currentConfiguration][section].key
        view.sizeToFit()
        return view
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return items[currentConfiguration].count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[currentConfiguration][section].elements.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = items[currentConfiguration][indexPath.section].elements[indexPath.row]
        return cell
    }
}
