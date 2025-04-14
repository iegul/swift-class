import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func goToNextScreen(_ sender: UIButton) {
        performSegue(withIdentifier: "goToDetail", sender: nil)
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetail" {
            if let destinationVC = segue.destination as? CheckListTableViewController {
            }
        }
    }
}
