//
//  FolderTableVC.swift
//  Note_CRRKTerm2_iOS
//
//  Created by Cem Safa on 2021-09-15.
//

import UIKit
import CoreData

class FolderTableVC: UITableViewController {
    
    var folders = [Folder]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = self.editButtonItem
        loadFolders()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return folders.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "folder-cell", for: indexPath)
        cell.textLabel?.text = folders[indexPath.row].name
        cell.detailTextLabel?.text = "\(folders[indexPath.row].notes?.count ?? 0)"
        cell.imageView?.image = UIImage(systemName: "folder")
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let ac = UIAlertController(title: "Confirm delete folder", message: "You are about to delete the folder and all notes under it, are you sure?", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "Confirm", style: .destructive) { [self] alert in
                deleteFolder(folders[indexPath.row])
                saveFolder()
                folders.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            ac.addAction(confirmAction)
            ac.addAction(cancelAction)
            present(ac, animated: true)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? NoteTableVC {
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedFolder = folders[indexPath.row]
                destinationVC.title = "\(folders[indexPath.row].name ?? "") Notes"
            }
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func addFolderBtnPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let ac = UIAlertController(title: "New Folder Name", message: "Enter a name for new folder", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { action in
            let folderNames = self.folders.map { $0.name?.lowercased() }
            guard !folderNames.contains(textField.text?.lowercased()) else {
                let ac = UIAlertController(title: "Name is already exists", message: "Please enter another name", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel)
                ac.addAction(okAction)
                self.present(ac, animated: true)
                return
            }
            let newFolder = Folder(context: self.context)
            newFolder.name = textField.text
            self.folders.append(newFolder)
            self.saveFolder()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        ac.addTextField { $0.placeholder = "New Folder Name"; textField = $0 }
        ac.addAction(addAction)
        ac.addAction(cancelAction)
        present(ac, animated: true)
    }
    
    // MARK: - Private methods
    
    private func loadFolders() {
        let request: NSFetchRequest<Folder> = Folder.fetchRequest()
        do {
            folders = try context.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
        tableView.reloadData()
    }
    
    private func saveFolder() {
        do {
            try context.save()
            tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func deleteFolder(_ folder: Folder) {
        context.delete(folder)
    }

}
