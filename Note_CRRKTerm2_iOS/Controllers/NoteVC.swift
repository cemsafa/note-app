//
//  NoteVC.swift
//  Note_CRRKTerm2_iOS
//
//  Created by Cem Safa on 2021-09-15.
//

import UIKit
import CoreData

class NoteVC: UIViewController {

    @IBOutlet weak var noteTV: UITextView!
    @IBOutlet weak var navBar: UINavigationItem!
    
    weak var delegate: NoteTableVC?
    
    var selectedNote: Note? {
        didSet {
            editMode = true
        }
    }
    
    var editMode = false
    
    let image = NSTextAttachment()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if navBar.title != nil {
            navBar.title = selectedNote?.title
        } else {
            var textField = UITextField()
            let ac = UIAlertController(title: "New Note", message: "Please enter a title for your note", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { action in
                self.navBar.title = textField.text
            }
            ac.addTextField { $0.placeholder = "New note title"; textField = $0 }
            ac.addAction(okAction)
            present(ac, animated: true)
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if editMode {
            delegate?.deleteNote(selectedNote!)
        }
        guard navBar.title != "" else { return }
        delegate?.updateNote(with: navBar.title!)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    // MARK: - IBAction
    
    @IBAction func photoPressed(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func audioPressed(_ sender: UIBarButtonItem) {
    }
    
}
