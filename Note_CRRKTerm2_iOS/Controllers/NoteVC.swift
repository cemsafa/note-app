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
            noteImage = selectedNote?.photo
            if noteImage != nil {
                selectedImage = UIImage(data: noteImage!)
            }
        }
    }
    
    var editMode = false
    
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    var dateCreated: Date?
    var noteImage: Data?
    var selectedImage: UIImage?
    
    let locationManager = CLLocationManager()
    let textAttachment = NSTextAttachment()
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if navBar.title != nil {
            navBar.title = selectedNote?.title
            noteTV.text = selectedNote?.noteContent
            if selectedImage != nil {
                setPhoto()
            }
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
        picker.allowsEditing = true
        picker.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if editMode {
            delegate?.deleteNote(selectedNote!)
        }
        guard navBar.title != "" else { return }
        if selectedImage != nil {
            noteImage = selectedImage?.jpegData(compressionQuality: 1.0)
        }
        delegate?.updateNote(title: navBar.title!, content: noteTV.text, dateCreated: dateCreated!, dateUpdated: Date(), latitude: latitude ?? 0, longitude: longitude ?? 0, photo: noteImage)
        
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
            if let destinationVC = segue.destination as? AudioVC {
                // TODO: - Pass audio file string to player
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
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if noteImage == nil {
            ac.addAction(UIAlertAction(title: "Take photo", style: .default, handler: { [self] action in
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    picker.sourceType = .camera
                    present(picker, animated: true, completion: nil)
                } else {
                    print("Camera not available")
                }
            }))
            ac.addAction(UIAlertAction(title: "Camera roll", style: .default, handler: { [self] action in
                picker.sourceType = .savedPhotosAlbum
                present(picker, animated: true, completion: nil)
            }))
            ac.addAction(UIAlertAction(title: "Photo library", style: .default, handler: { [self] action in
                picker.sourceType = .photoLibrary
                present(picker, animated: true, completion: nil)
            }))
        } else {
            ac.addAction(UIAlertAction(title: "Remove photo", style: .destructive, handler: { action in
                self.noteImage = nil
            }))
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    // MARK: - Private methods
    
    private func setDate(with date: Date) -> String {
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd - h:mm a"
        let formattedDate = format.string(from: date)
        return formattedDate
    }
    
    private func setPhoto() {
        textAttachment.image = selectedImage
        let imageWidth = (noteTV.bounds.size.width - 20 )
        let scale = imageWidth/selectedImage!.size.width
        let imageHeight = selectedImage!.size.height * scale
        textAttachment.bounds = CGRect.init(x: 0, y: 0, width: imageWidth, height: imageHeight)
        let attString = NSAttributedString(attachment: textAttachment)
        noteTV.textStorage.insert(attString, at: noteTV.selectedRange.lowerBound)
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
        guard let location = locations.first else { return }
        if editMode == false {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
        }
        
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension NoteVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            selectedImage = image
            setPhoto()
        } else if let image = info[.originalImage] as? UIImage {
            selectedImage = image
            setPhoto()
        } else {
            print("Other source")
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
