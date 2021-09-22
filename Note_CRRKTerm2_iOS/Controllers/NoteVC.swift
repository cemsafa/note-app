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
    @IBOutlet weak var noteImg: UIImageView!
    var selectedImage : Data?
    
    weak var delegate: NoteTableVC?
    
    var selectedNote: Note?
    
    //let image = NSTextAttachment()
    
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
                let newNote = Note(context: delegate.context)
                newNote.photo = selectedImage
                newNote.title = title
                delegate.addNote(with: newNote)
            }
        }
        
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
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
    
    @IBAction func mapPressed(_ sender: UIBarButtonItem) {
    }
    
}
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
