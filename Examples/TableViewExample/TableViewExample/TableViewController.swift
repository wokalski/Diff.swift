import Differ
import UIKit

class TableViewController: UITableViewController {

    var objects = [
        [
            "🌞",
            "🐩",
            "👌🏽",
            "🦄",
            "👋🏻",
            "🙇🏽‍♀️",
            "🔥",
        ],
        [
            "🐩",
            "🌞",
            "👌🏽",
            "🙇🏽‍♀️",
            "🔥",
            "👋🏻",
        ]
    ]


    var currentObjects = 0 {
        didSet {
            tableView.animateRowChanges(
                oldData: objects[oldValue],
                newData: objects[currentObjects],
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

    @IBAction func refresh(_ sender: Any) {
        currentObjects = currentObjects == 0 ? 1 : 0;
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects[currentObjects].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = objects[currentObjects][indexPath.row]
        return cell
    }
}
