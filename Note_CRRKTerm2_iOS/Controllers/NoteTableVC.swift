//
//  NoteTableVC.swift
//  Note_CRRKTerm2_iOS
//
//  Created by Cem Safa on 2021-09-15.
//

import UIKit
import CoreData

class NoteTableVC: UITableViewController {

    @IBOutlet weak var deleteBtn: UIBarButtonItem!
    @IBOutlet weak var moveBtn: UIBarButtonItem!
    
    var notes = [Note]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedFolder: Folder? {
        didSet {
            loadNotes()
        }
    }
    
    private var editOption = false
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        showSearchBar()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "note-cell", for: indexPath)
        cell.textLabel?.text = notes[indexPath.row].title
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? NoteVC {
            destinationVC.delegate = self
            if let cell = sender as? UITableViewCell {
                if let index = tableView.indexPath(for: cell)?.row {
                    destinationVC.selectedNote = notes[index]
                    destinationVC.navBar.title = notes[index].title
                }
            }
        }
        if let destinationVC = segue.destination as? MoveToFolderVC {
            if let indexPath = tableView.indexPathsForSelectedRows {
                let rows = indexPath.map { $0.row }
                destinationVC.selectedNotes = rows.map { notes[$0] }
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard identifier != "moveNotesSegue" else { return true }
        return !editOption
    }
    
    @IBAction func unwindToNoteTableVC(_ unwindSegue: UIStoryboardSegue) {
        saveNotes()
        loadNotes()
        changeEditOptionState()
    }

    // MARK: - IBAction
    
    @IBAction func deleteBtnPressed(_ sender: UIBarButtonItem) {
        if let indexPaths = tableView.indexPathsForSelectedRows {
            let rows = (indexPaths.map { $0.row }).sorted(by: >)
            rows.forEach { deleteNote(notes[$0]) }
            rows.forEach { notes.remove(at: $0) }
            tableView.reloadData()
            saveNotes()
            changeEditOptionState()
        }
    }
    
    @IBAction func editBtnPressed(_ sender: UIBarButtonItem) {
        tableView.allowsMultipleSelectionDuringEditing = true
        changeEditOptionState()
    }
    
    // MARK: - Private methods
    
    private func loadNotes(with predicate: NSPredicate? = nil) {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        let folderPredicate = NSPredicate(format: "parentFolder.name=%@", selectedFolder!.name!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [folderPredicate, additionalPredicate])
        } else {
            request.predicate = folderPredicate
        }
        
        do {
            notes = try context.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
        tableView.reloadData()
    }
    
    private func saveNotes() {
        do {
            try context.save()
            tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func changeEditOptionState() {
        editOption = !editOption
        deleteBtn.isEnabled = !deleteBtn.isEnabled
        moveBtn.isEnabled = !moveBtn.isEnabled
        tableView.setEditing(editOption, animated: true)
    }
    
    private func showSearchBar() {
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search notes"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.searchTextField.textColor = .lightGray
    }
    
    // MARK: - Public methods
    
    func updateNote(with title: String) {
        notes = []
        let newNote = Note(context: context)
        newNote.title = title
        newNote.parentFolder = selectedFolder
        saveNotes()
        loadNotes()
    }
    
    func deleteNote(_ note: Note) {
        context.delete(note)
    }
}

// MARK: - UISearchBarDelegate

extension NoteTableVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        loadNotes(with: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadNotes()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
