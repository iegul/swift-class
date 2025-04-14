
import UIKit
import RealmSwift
import CoreImage.CIFilterBuiltins

class Kisi: Object {
    @Persisted var name: String
    @Persisted var surname: String
    @Persisted var number: String
    @Persisted var address: String
}

class CheckListTableViewController: UITableViewController, UISearchResultsUpdating {

    let realm = try! Realm()
    var checkListItems: Results<Kisi>!
    var filteredItems: [Kisi] = []

    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        checkListItems = realm.objects(Kisi.self)
        filteredItems = Array(checkListItems)

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Arama"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckListCell", for: indexPath)
        let kisi = filteredItems[indexPath.row]
        cell.textLabel?.text = "\(kisi.name) \(kisi.surname)"
        cell.accessoryType = .none

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        cell.addGestureRecognizer(longPressGesture)

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let kisiToDelete = filteredItems[indexPath.row]
            try! realm.write {
                realm.delete(kisiToDelete)
            }
            filteredItems = Array(realm.objects(Kisi.self))
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    @IBAction func addTask() {
        let alert = UIAlertController(title: "Yeni Kişi Ekle", message: nil, preferredStyle: .alert)

        alert.addTextField { $0.placeholder = "Ad" }
        alert.addTextField { $0.placeholder = "Soyad" }
        alert.addTextField { $0.placeholder = "Telefon" }
        alert.addTextField { $0.placeholder = "Adres" }

        let addAction = UIAlertAction(title: "Ekle", style: .default) { _ in
            guard let name = alert.textFields?[0].text, !name.isEmpty,
                  let surname = alert.textFields?[1].text, !surname.isEmpty,
                  let number = alert.textFields?[2].text, !number.isEmpty,
                  let address = alert.textFields?[3].text, !address.isEmpty else {
                return
            }

            let yeniKisi = Kisi()
            yeniKisi.name = name
            yeniKisi.surname = surname
            yeniKisi.number = number
            yeniKisi.address = address

            try! self.realm.write {
                self.realm.add(yeniKisi)
            }

            self.filteredItems = Array(self.realm.objects(Kisi.self))
            self.tableView.reloadData()
        }

        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        present(alert, animated: true)
    }

    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }

        if let cell = gestureRecognizer.view as? UITableViewCell,
           let indexPath = tableView.indexPath(for: cell) {
            let kisi = filteredItems[indexPath.row]
            if let qrImage = kisiToQRCode(kisi) {
                let imageView = UIImageView(image: qrImage)
                imageView.contentMode = .scaleAspectFit

                let alert = UIAlertController(title: "\(kisi.name) \(kisi.surname)", message: nil, preferredStyle: .alert)
                alert.view.addSubview(imageView)

                imageView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    imageView.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
                    imageView.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 60),
                    imageView.widthAnchor.constraint(equalToConstant: 200),
                    imageView.heightAnchor.constraint(equalToConstant: 200),
                    alert.view.heightAnchor.constraint(equalToConstant: 300)
                ])

                alert.addAction(UIAlertAction(title: "Kapat", style: .cancel))
                present(alert, animated: true)
            }
        }
    }

    func kisiToQRCode(_ kisi: Kisi) -> UIImage? {
        let vCardString = """
        BEGIN:VCARD
        VERSION:3.0
        N:\(kisi.surname);\(kisi.name)
        FN:\(kisi.name) \(kisi.surname)
        TEL;TYPE=CELL:\(kisi.number)
        ADR;TYPE=HOME:;;\(kisi.address)
        END:VCARD
        """

        guard let data = vCardString.data(using: .utf8) else { return nil }

        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")

        if let outputImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)
            return UIImage(ciImage: scaledImage)
        }
        return nil
    }

    func updateSearchResults(for searchController: UISearchController) {
    func updateSearchResults(for searchController: UISearchController) {
    func updateSearchResults(for searchController: UISearchController) {
    func updateSearchResults(for searchController: UISearchController) {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            filteredItems = Array(checkListItems)
            tableView.reloadData()
            return
        }

        if searchText.isEmpty {
            filteredItems = Array(checkListItems)
        } else {
            filteredItems = checkListItems.filter {
                $0.name.lowercased().contains(searchText) || $0.surname.lowercased().contains(searchText)
            }
            .map { $0 }
        }
        tableView.reloadData()
    }
}
