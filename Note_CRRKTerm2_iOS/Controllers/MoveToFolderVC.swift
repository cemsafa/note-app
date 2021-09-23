//
//  MoveToFolderVC.swift
//  Note_CRRKTerm2_iOS
//
//  Created by Cem Safa on 2021-09-17.
//

import UIKit
import CoreData

class MoveToFolderVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var folders = [Folder]()
    
    var selectedNotes: [Note]? {
        didSet {
            loadFolders()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - IBAction
    
    @IBAction func cancelBtnPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private mathods
    
    private func loadFolders() {
        //Fetching all folders except the one
        let request: NSFetchRequest<Folder> = Folder.fetchRequest()
        let predicate = NSPredicate(format: "NOT name MATCHES %@", selectedNotes?.first?.parentFolder?.name ?? "")
        request.predicate = predicate
        do {
            folders = try context.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension MoveToFolderVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "moveToFolder-cell")
        cell.textLabel?.text = folders[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Move notes to the folder", message: "You are about to move selected notes under \(folders[indexPath.row].name ?? "").\nDo you want to continue?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { action in
            self.selectedNotes?.forEach({ note in
                note.parentFolder = self.folders[indexPath.row]
            })
            self.performSegue(withIdentifier: "dismissMoveVC", sender: self)
        }
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true, completion: nil)

    }
}
