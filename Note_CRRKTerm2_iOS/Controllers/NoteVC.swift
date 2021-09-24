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

    @IBOutlet weak var noteImg: UIImageView!
    var selectedImage : Data?

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
            dateCreated = selectedNote?.dateCreated
            latitude = selectedNote?.latitude
            longitude = selectedNote?.longitude
        }
    }
    
    var editMode = false
    
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    var dateCreated: Date?
    
    let locationManager = CLLocationManager()
    
    
    //let image = NSTextAttachment()
    
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
                dateCreated = Date()
            }
            ac.addTextField { $0.placeholder = "New note title"; textField = $0 }
            ac.addAction(okAction)
            present(ac, animated: true)
        }

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        }
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let _ = selectedNote{
            selectedNote?.photo = selectedImage
            try! delegate?.context.save()
        }
        else{
            guard navBar.title != "" else { return }
            if let delegate = delegate{
//                let newNote = Note(context: delegate.context)
//                newNote.photo = selectedImage
//                newNote.title = title
                delegate.updateNote(with: navBar.title!, with: noteTV.text)
            }
        }
        
    }
    func setupLocationManager(){
        //Setting location manager
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        guard navBar.title != "" else { return }
        delegate?.updateNote(title: navBar.title!, content: noteTV.text, dateCreated: dateCreated!, dateUpdated: Date(), latitude: latitude ?? 0, longitude: longitude ?? 0)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if editMode == false {
            let ac = UIAlertController(title: "Warning", message: "Note must be saved first to see where it was taken", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                self.dismiss(animated: true, completion: nil)
            }))
            present(ac, animated: true)
        } else {
            if let destinationVC = segue.destination as? MapVC {
                destinationVC.note = selectedNote
            }
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
        // create an actionSheet
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        // Check for weither to show add image option or remove
        if noteImg.isHidden == true{
            // Add image options
            let cameraAction: UIAlertAction = UIAlertAction(title: "Image From Camera", style: .default) { action -> Void in
                self.handleCamera()
            }
            let mediaAction: UIAlertAction = UIAlertAction(title: "Image From Gallary", style: .default) { action -> Void in

                self.handlePhotoLibrary()
            }
            actionSheetController.addAction(cameraAction)
            actionSheetController.addAction(mediaAction)
        }
        else{
            //Remove options
            let removeAction = UIAlertAction(title: "Remove Image", style: .destructive, handler: { (action) in
                self.noteImg.isHidden = true
                self.noteImg.image = nil
                self.selectedImage = nil
            })
            actionSheetController.addAction(removeAction)
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
        actionSheetController.addAction(cancelAction)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    func handleCamera()
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true)
        }
        else{
            print("Camera not available")
        }
    }
    func setupUI() {
        if let image = selectedNote?.photo{
            noteImg.isHidden = false
            noteImg.image = UIImage(data: image)
        }
    }
    func handlePhotoLibrary()
    {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true)
    }
    
    @IBAction func audioPressed(_ sender: UIBarButtonItem) {
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
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined, .denied, .restricted:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        if editMode == false {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
        }
}

  // MARK: -UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension NoteVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        noteImg.isHidden = false

        if let image = info[.editedImage] as? UIImage {
            noteImg.image = image
        }
        else if let image = info[.originalImage] as? UIImage {
            noteImg.image = image
        } else {
            print("Other source")
        }
        //converted image into data so, we can store in coredata
        selectedImage = noteImg.image!.jpegData(compressionQuality: 0.75)

        picker.dismiss(animated: true, completion: nil)
    }
  
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

}
