import Foundation
import SQLite3

func connectToDatabase() -> OpaquePointer? {
    var db: OpaquePointer?
    let fileURL = try! FileManager.default
        .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("university.db")
    let path = fileURL.path
    if sqlite3_open(path, &db) != SQLITE_OK {
        print("error opening database")
        return nil
    } else {
        //print("database opened successfully")
        //print("Database path: \(path)")
        return db
    }
}

//func replaceDatabase() {
//    let fileManager = FileManager.default
//    let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
//    let finalDatabaseURL = documentsUrl.appendingPathComponent("university.db")
//
//    // Check if old database exists
//    if fileManager.fileExists(atPath: finalDatabaseURL.path) {
//        do {
//            // Delete old database
//            try fileManager.removeItem(at: finalDatabaseURL)
//            print("Old database deleted.")
//        } catch {
//            print("Error deleting old database: \(error.localizedDescription)")
//        }
//    }
//
//    // Copy new database to documents directory
//    guard let newDatabaseURL = Bundle.main.resourceURL?.appendingPathComponent("university.db") else {
//        print("New database not found.")
//        return
//    }
//
//    do {
//        try fileManager.copyItem(atPath: newDatabaseURL.path, toPath: finalDatabaseURL.path)
//        print("New database copied.")
//    } catch {
//        print("Error copying new database: \(error.localizedDescription)")
//    }
//}

func downloadDatabase() {
    guard let url = URL(string: "https://github.com/iKrut0nardo/BRSTU_PO/raw/sn0w/university.db") else {
        print("Invalid URL")
        return
    }
    
    let task = URLSession.shared.downloadTask(with: url) { (location, response, error) in
        guard let location = location else {
            print("Download failed: \(error?.localizedDescription ?? "Unknown error")")
            return
        }
        
        let fileManager = FileManager.default
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsUrl.appendingPathComponent("university.db")
        
        do {
            // Remove old database if exists
            if fileManager.fileExists(atPath: destinationUrl.path) {
                try fileManager.removeItem(at: destinationUrl)
                print("Old data removed")
            }
            
            // Move downloaded database to documents directory
            try fileManager.moveItem(at: location, to: destinationUrl)
            print("Database downloaded.")
        } catch {
            print("Error moving downloaded database: \(error.localizedDescription)")
        }
    }
    
    task.resume()
}




