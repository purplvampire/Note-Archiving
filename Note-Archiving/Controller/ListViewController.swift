//
//  ListViewController.swift
//  Note-Archiving
//
//  Created by 陳信彰 on 2023/6/25.
//

import UIKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NoteViewControllerDelegate {
    
    var notes2: [Note2] = [] {
        didSet {
            self.writeToFile()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.loadFromFile()
    }

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = self.editButtonItem
        tableView.delegate = self
        tableView.dataSource = self
        
        if let username = UserDefaults.standard.string(forKey: "username") {
            self.navigationItem.title = "Hi, \(username)"
        }
    }
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: true)
    }
    
    @IBAction func add(_ sender: Any) {
        
        let note2 = Note2()
        self.notes2.insert(note2, at: 0)
        
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Archiving
    
    func writeToFile() {
        let home = URL(filePath: NSHomeDirectory())
        let documents = home.appending(path: "Documents")
        let fileUrl = documents.appending(path: "note.archive")
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: self.notes2, requiringSecureCoding: true)
            try data.write(to: fileUrl, options: .atomicWrite)  // 完整寫入
        } catch {
            print("error while saving data into file. \(error)")
        }
    }
    
    func loadFromFile() {
        let home = URL(filePath: NSHomeDirectory())
        let documents = home.appending(path: "Documents")
        let fileUrl = documents.appending(path: "note.archive")
        do {
            let fileData = try Data(contentsOf: fileUrl)
            if let arrayData = try NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClass: Note2.self, from: fileData) {
                self.notes2 = arrayData
            }
        } catch {
            print("error while loading Note objects from file. \(error)")
        }
    }
    
    // MARK: - Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notes2.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        let note = notes2[indexPath.row]
        cell.textLabel?.text = note.text
        
        let home = URL(filePath: NSHomeDirectory())
        let documents = home.appending(path: "Documents")
        let imageUrl = documents.appending(path: "\(note.noteID).jpg")
        if FileManager.default.fileExists(atPath: imageUrl.path) {
            cell.imageView?.image = UIImage(contentsOfFile: imageUrl.path)
        }
        
        
        cell.showsReorderControl = true
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)    // 選取動畫
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let note2 = notes2.remove(at: indexPath.row)
            self.writeToFile()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            let home = URL(filePath: NSHomeDirectory())
            let documents = home.appending(path: "Documents")
            let fileName = "\(note2.noteID).jpg"
            let fileUrl = documents.appending(path: fileName)
            if FileManager.default.fileExists(atPath: fileUrl.path) {
                try? FileManager.default.removeItem(at: fileUrl)
            }
        }

    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let note = notes2.remove(at: sourceIndexPath.row)
        notes2.insert(note, at: destinationIndexPath.row)
        
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let noteVC = segue.destination as? NoteViewController,
           let indexPath = tableView.indexPathForSelectedRow {
            
            noteVC.note2 = notes2[indexPath.row]
            noteVC.delegate = self
        }
    }
    
    // MARK: - NoteViewControllerDelegate
    
    func noteViewController(_ controller: NoteViewController, didFinishedUpdate note: Note2) {
        
        self.writeToFile()
        self.tableView.reloadData()
        
        
    }
    

}
