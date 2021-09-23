//
//  NoteVC.swift
//  Note_CRRKTerm2_iOS
//
//  Created by Cem Safa on 2021-09-15.
//

import UIKit
import CoreData
import CoreLocation

class NoteVC: UIViewController {

    @IBOutlet weak var noteTV: UITextView!
    @IBOutlet weak var navBar: UINavigationItem!
    let locationManager = CLLocationManager()
    @IBOutlet weak var dateLbl: UILabel! {
        didSet {
            if selectedNote?.dateUpdated != nil {
                dateLbl.text = setDate(with: (selectedNote?.dateUpdated)!)
            }
        }
    }
    
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
            noteTV.text = selectedNote?.noteContent
        } else {
            var textField = UITextField()
            let ac = UIAlertController(title: "New Note", message: "Please enter a title for your note", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { [self] action in
                navBar.title = textField.text
                selectedNote?.dateCreated = Date()
            }
            ac.addTextField { $0.placeholder = "New note title"; textField = $0 }
            ac.addAction(okAction)
            present(ac, animated: true)
        }
        setupLocationManager()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if editMode {
            delegate?.deleteNote(selectedNote!)
        }
        guard navBar.title != "" else { return }
        delegate?.updateNote(with: navBar.title!, with: noteTV.text)
    }
    func setupLocationManager(){
        //Setting location manager
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? MapVC {
            destinationVC.note = selectedNote
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func changeTitlePressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let ac = UIAlertController(title: "Change title", message: "Please enter a new title for your note", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            if textField.text != "" {
                self.navBar.title = textField.text
            } else {
                self.navBar.title = self.navBar.title
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addTextField { $0.placeholder = "New title"; textField = $0 }
        ac.addAction(okAction)
        ac.addAction(cancelAction)
        present(ac, animated: true)
    }
    
    @IBAction func photoPressed(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func audioPressed(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func mapPressed(_ sender: UIBarButtonItem) {
    }
    
    // MARK: - Private methods
    
    private func setDate(with date: Date) -> String {
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd - h:mm a"
        let formattedDate = format.string(from: date)
        return formattedDate
    }
    
}

// MARK: - CLLocationManagerDelegate

extension NoteVC: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            selectedNote?.latitude = location.coordinate.latitude
            selectedNote?.longitude = location.coordinate.longitude
        }
    }
  
}
