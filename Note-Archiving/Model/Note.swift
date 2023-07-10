//
//  Note.swift
//  Note-Archiving
//
//  Created by 陳信彰 on 2023/6/25.
//

import Foundation
import UIKit

class Note2: NSObject, NSCoding, NSSecureCoding {
    
    static var supportsSecureCoding: Bool = true
    
    var text = "New Note"
    var noteID: String
    
    override init() {
        noteID = UUID().uuidString
    }
    
    required init?(coder: NSCoder) {
        self.text = coder.decodeObject(forKey: "text") as! String
        self.noteID = coder.decodeObject(forKey: "noteID") as! String
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.text, forKey: "text")
        coder.encode(self.noteID, forKey: "noteID")
    }
    
    func image() -> UIImage? {
        let home = URL(filePath: NSHomeDirectory())
        let documents = home.appending(path: "Documents")
        let fileName = "\(self.noteID).jpg"
        let fileUrl = documents.appending(path: fileName)
        
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            return UIImage(contentsOfFile: fileUrl.path)
        }
        return nil
    }
    
    func thumbnail() -> UIImage? {
        
        if let image = self.image() {
            
            let thumbnailSize = CGSize(width: 50, height: 50)   // 縮圖大小
            let scale = UIScreen.main.scale                     // 螢幕大小
            
            UIGraphicsBeginImageContextWithOptions(thumbnailSize, false, scale) // 產生畫布
            
            //計算長寬的縮圖比例，取最大值MAX會變成UIViewContentModeScaleAspectFill(大頭貼)
            let widthRatio = thumbnailSize.width / image.size.width     // width比例
            let heightRadio = thumbnailSize.height / image.size.height  // height比例
            let ratio = max(widthRatio, heightRadio)                    // 大頭貼
            let imageSize = CGSize(width: image.size.width*ratio, height: image.size.height*ratio)
            
            //如果要切圓形(縮圖大小)
            let circlePath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: thumbnailSize.width, height: thumbnailSize.height))
            circlePath.addClip()
            
            image.draw(in: CGRect(x: -(imageSize.width - thumbnailSize.width)/2.0, y: -(imageSize.height - thumbnailSize.height)/2.0, width: imageSize.width, height: imageSize.height))
            
            let smallImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return smallImage
            
        } else {
            return nil
        }
    }
}

struct Note: Codable {
    var text = "New Note"
    var imageName: String?
    
    static let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    static func saveNote(notes: [Note]) {
        
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(notes) else { return }
        let url = documentDirectory.appendingPathComponent("notes")
        try? data.write(to: url)
    }
    
    static func loadNote() -> [Note]? {
        
        let url = documentDirectory.appendingPathComponent("notes")
        guard let data = try? Data(contentsOf: url) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode([Note].self, from: data)
    }
}
