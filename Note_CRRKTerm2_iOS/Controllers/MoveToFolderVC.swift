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
        //    loadFolders()
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
      

    }
}
