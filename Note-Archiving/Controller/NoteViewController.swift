//
//  NoteViewController.swift
//  Note-Archiving
//
//  Created by 陳信彰 on 2023/6/25.
//

import UIKit

protocol NoteViewControllerDelegate: AnyObject {
    func noteViewController(_ controller: NoteViewController, didFinishedUpdate note: Note2)
}

class NoteViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    weak var delegate: NoteViewControllerDelegate?
    
    var note: Note!
    var note2: Note2!

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var noteTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
    }
    
    func updateUI() {
        noteTextView.text = note2.text
        photoImageView.image = note2.image()
    }
    
    @IBAction func save(_ sender: Any) {
        
        note2.text = noteTextView.text ?? ""
        
        if let image = photoImageView.image,
           let imageData = image.jpegData(compressionQuality: 1) {
            
            let home = URL(filePath: NSHomeDirectory())
            let documents = home.appending(path: "Documents")
            let fileUrl = documents.appending(path: "\(note2.noteID).jpg")
            try? imageData.write(to: fileUrl, options: [.atomicWrite])
        }
        self.delegate?.noteViewController(self, didFinishedUpdate: note2)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func getPhoto(_ sender: Any) {
        
        let controller = UIImagePickerController()
        controller.delegate = self
        present(controller, animated: true)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            photoImageView.image = image
        }
        dismiss(animated: true)
    }

}
