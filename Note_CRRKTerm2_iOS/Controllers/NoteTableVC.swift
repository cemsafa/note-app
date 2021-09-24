//
//  NoteTableVC.swift
//  Note_CRRKTerm2_iOS
//
//  Created by Cem Safa on 2021-09-15.
//

import UIKit
import CoreData

enum Sorting:String {
    case title = "title"
    case titleReverse = "titleReverse"

}
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
    
    @IBAction func sortBtnPressed(_ sender: UIBarButtonItem) {
        //Showing Sorting options in actionsheet
        let ac = UIAlertController(title: "Change sort type", message: "", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Sort by title (ascending)", style: .default) { [self] action in
            sortNotes(for: .title)
        })
        ac.addAction(UIAlertAction(title: "Sort by title (descending)", style: .default) { [self] action in
            sortNotes(for: .titleReverse)
        })
        ac.addAction(UIAlertAction(title: "Sort by created date (ascending)", style: .default) { [self] action in
            loadNotes(sortBy: "dateCreated", isAsc: true)
        })
        ac.addAction(UIAlertAction(title: "Sort by created date (descending)", style: .default) { [self] action in
            loadNotes(sortBy: "dateCreated", isAsc: false)
        })
        ac.addAction(UIAlertAction(title: "Sort by updated date (ascending)", style: .default) { [self] action in
            loadNotes(sortBy: "dateUpdated", isAsc: true)
        })
        ac.addAction(UIAlertAction(title: "Sort by updated date (descending)", style: .default) { [self] action in
            loadNotes(sortBy: "dateUpdated", isAsc: false)
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated: true)
    }
    
    // MARK: - Private methods
    
    // This function can sort notes in acc or desc order of its title
    private func sortNotes(for type : Sorting){
        switch type {
        case .title:
            notes.sort {$0.title! < $1.title!}
        case .titleReverse:
            notes.sort {$0.title! > $1.title!}
        }
        tableView.reloadData()
    }
    
    private func loadNotes(with predicate: NSPredicate? = nil, sortBy: String? = nil, isAsc: Bool? = nil) {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        let folderPredicate = NSPredicate(format: "parentFolder.name=%@", selectedFolder!.name!)
        
        if sortBy != nil && isAsc != nil {
            request.sortDescriptors = [NSSortDescriptor(key: sortBy, ascending: isAsc!)]
        } else {
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        }
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
        //Setting a searchbar
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search notes"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    // MARK: - Public methods
    
    func updateNote(with title: String, with content: String) {
        notes = []
        let newNote = Note(context: context)
        newNote.title = title
        newNote.dateUpdated = Date()
        newNote.noteContent = content
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
//Searchbar delegate methods
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        loadNotes()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //If there is no text in searchbar,We reload all the notes
        if searchBar.text?.count == 0 {
            loadNotes()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        else{
            //Searching note by keyword which user has entered
            //Predicate which will match search keyword with title of notes
            let titlePredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
            
            //Predicate which will match search keyword with description of notes
            let contentPredicate = NSPredicate(format: "noteContent CONTAINS[cd] %@", searchBar.text!)
            
            // Calling function to filter the notes according to predicates
            let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, contentPredicate])
            loadNotes(with: predicate)
        }
       
    }
}
