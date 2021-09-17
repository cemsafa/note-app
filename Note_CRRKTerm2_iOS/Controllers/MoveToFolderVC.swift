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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - IBAction
    
    @IBAction func cancelBtnPressed(_ sender: UIBarButtonItem) {
    }
    
    // MARK: - Private mathods
    
    private func loadFolders() {
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
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "moveToFolder-cell")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
