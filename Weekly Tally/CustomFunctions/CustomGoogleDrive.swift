//
//  CustomGoogleDrive.swift
//  Weekly Tally
//
//  Created by Bac Cheng Huang on 2020/4/28.
//  Copyright © 2020 THEBAC. All rights reserved.
//

import Foundation
import GoogleAPIClientForREST

enum GDriveError: Error {
    case NoDataAtPath
}

class CustomGoogleDrive {
    
    private let service: GTLRDriveService
    
    init(_ service: GTLRDriveService) {
        self.service = service
    }
    
    public func listFilesInFolder(_ folder: String, onCompleted: @escaping (GTLRDrive_FileList?, Error?) -> ()) {
        search(folder) { (folderID, error) in
            guard let ID = folderID else {
                onCompleted(nil, error)
                return
            }
            self.listFiles(ID, onCompleted: onCompleted)
        }
    }
    
    private func listFiles(_ folderID: String, onCompleted: @escaping (GTLRDrive_FileList?, Error?) -> ()) {
        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 100
        query.q = "'\(folderID)' in parents"
        
        service.executeQuery(query) { (ticket, result, error) in
            onCompleted(result as? GTLRDrive_FileList, error)
        }
    }
    
    public func uploadFile(_ folderName: String, filePath: String, MIMEType: String, onCompleted: ((String?, Error?) -> ())?) {
        
        search(folderName) { (folderID, error) in
            
            if let ID = folderID {
                self.upload(ID, path: filePath, MIMEType: MIMEType, onCompleted: onCompleted)
            } else {
                self.createFolder(folderName, onCompleted: { (folderID, error) in
                    guard let ID = folderID else {
                        onCompleted?(nil, error)
                        return
                    }
                    self.upload(ID, path: filePath, MIMEType: MIMEType, onCompleted: onCompleted)
                })
            }
        }
    }
    
    private func upload(_ parentID: String, path: String, MIMEType: String, onCompleted: ((String?, Error?) -> ())?) {
        
        guard let data = FileManager.default.contents(atPath: path) else {
            onCompleted?(nil, GDriveError.NoDataAtPath)
            return
        }
        
        let file = GTLRDrive_File()
        file.name = path.components(separatedBy: "/").last
        file.parents = [parentID]
        
        let uploadParams = GTLRUploadParameters.init(data: data, mimeType: MIMEType)
        uploadParams.shouldUploadWithSingleRequest = true
        
        let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: uploadParams)
        query.fields = "id"
        
        self.service.executeQuery(query, completionHandler: { (ticket, file, error) in
            onCompleted?((file as? GTLRDrive_File)?.identifier, error)
        })
    }
    
    public func download(_ fileID: String, onCompleted: @escaping (Data?, Error?) -> ()) {
        let query = GTLRDriveQuery_FilesGet.queryForMedia(withFileId: fileID)
        service.executeQuery(query) { (ticket, file, error) in
            onCompleted((file as? GTLRDataObject)?.data, error)
        }
    }
    
    public func search(_ fileName: String, onCompleted: @escaping (String?, Error?) -> ()) {
        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 1
        query.q = "name contains '\(fileName)'"
        
        service.executeQuery(query) { (ticket, results, error) in
            onCompleted((results as? GTLRDrive_FileList)?.files?.first?.identifier, error)
        }
    }
    
    public func createFolder(_ name: String, onCompleted: @escaping (String?, Error?) -> ()) {
        let file = GTLRDrive_File()
        file.name = name
        file.mimeType = "application/vnd.google-apps.folder"
        
        let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: nil)
        query.fields = "id"
        
        service.executeQuery(query) { (ticket, folder, error) in
            onCompleted((folder as? GTLRDrive_File)?.identifier, error)
        }
    }
    
    public func delete(_ fileID: String, onCompleted: ((Error?) -> ())?) {
        let query = GTLRDriveQuery_FilesDelete.query(withFileId: fileID)
        service.executeQuery(query) { (ticket, nilFile, error) in
            onCompleted?(error)
        }
    }
    
    
    
//        public func search(_ name: String, onCompleted: @escaping (GTLRDrive_File?, Error?) -> ()) {
//            let query = GTLRDriveQuery_FilesList.query()
//            query.pageSize = 1
//            query.q = "name contains '\(name)'"
//            googleDriveService.executeQuery(query) { (ticket, results, error) in
//                onCompleted((results as? GTLRDrive_FileList)?.files?.first, error)
//            }
//        }
//
//         public func listFiles(_ folderID: String, onCompleted: @escaping (GTLRDrive_FileList?, Error?) -> ()) {
//            let query = GTLRDriveQuery_FilesList.query()
//            query.pageSize = 100
//            query.q = "'\(folderID)' in parents and mimeType != 'application/vnd.google-apps.folder'"
//            googleDriveService.executeQuery(query) { (ticket, result, error) in
//                onCompleted(result as? GTLRDrive_FileList, error)
//            }
//        }
//
//        private func upload(_ folderID: String, fileName: String, data: Data, MIMEType: String, onCompleted: ((String?, Error?) -> ())?) {
//            let file = GTLRDrive_File()
//            file.name = fileName
//    //        file.parents = [folderID]
//
//            let params = GTLRUploadParameters(data: data, mimeType: MIMEType)
//            params.shouldUploadWithSingleRequest = true
//
//            let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: params)
//            query.fields = "id"
//
//           googleDriveService.executeQuery(query, completionHandler: { (ticket, file, error) in
//                onCompleted?((file as? GTLRDrive_File)?.identifier, error)
//                print("completed")
//            })
//        }
//
//        public func download(_ fileItem: GTLRDrive_File, onCompleted: @escaping (Data?, Error?) -> ()) {
//            guard let fileID = fileItem.identifier else {
//                return onCompleted(nil, nil)
//            }
//
//            googleDriveService.executeQuery(GTLRDriveQuery_FilesGet.queryForMedia(withFileId: fileID)) { (ticket, file, error) in
//                guard let data = (file as? GTLRDataObject)?.data else {
//                    return onCompleted(nil, nil)
//                }
//
//                onCompleted(data, nil)
//            }
//        }
//
//        public func delete(_ fileItem: GTLRDrive_File, onCompleted: @escaping ((Error?) -> ())) {
//            guard let fileID = fileItem.identifier else {
//                return onCompleted(nil)
//            }
//
//            googleDriveService.executeQuery(GTLRDriveQuery_FilesDelete.query(withFileId: fileID)) { (ticket, nilFile, error) in
//                onCompleted(error)
//            }
//        }
//
//        public func setupGoogleSignIn() {
//
//            /***** Configure Google Sign In *****/
//            GIDSignIn.sharedInstance()?.delegate = self
//            GIDSignIn.sharedInstance()?.presentingViewController = self
//            GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeDrive]
//            // Automatically sign in the user.
//            GIDSignIn.sharedInstance()?.restorePreviousSignIn()
//        }
//
//
//        func getFolderID(
//            name: String,
//            service: GTLRDriveService,
//            user: GIDGoogleUser,
//            completion: @escaping (String?) -> Void) {
//
//            let query = GTLRDriveQuery_FilesList.query()
//
//            // Comma-separated list of areas the search applies to. E.g., appDataFolder, photos, drive.
//            query.spaces = "drive"
//
//            // Comma-separated list of access levels to search in. Some possible values are "user,allTeamDrives" or "user"
//            query.corpora = "user"
//
//            let withName = "name = '\(name)'" // Case insensitive!
//            let foldersOnly = "mimeType = 'application/vnd.google-apps.folder'"
//            let ownedByUser = "'\(user.profile!.email!)' in owners" // only user. omitting will broaden search to shared folders as well
//            query.q = "\(withName) and \(foldersOnly) and \(ownedByUser)"
//
//            service.executeQuery(query) { (_, result, error) in
//                guard error == nil else {
//                    fatalError(error!.localizedDescription)
//                }
//
//                let folderList = result as! GTLRDrive_FileList
//
//                // For brevity, assumes only one folder is returned.
//                completion(folderList.files?.first?.identifier)
//            }
//        }
//
//        func createFolder(
//            name: String,
//            service: GTLRDriveService,
//            completion: @escaping (String) -> Void) {
//
//            let folder = GTLRDrive_File()
//            folder.mimeType = "application/vnd.google-apps.folder"
//            folder.name = name
//
//            // Google Drive folders are files with a special MIME-type.
//            let query = GTLRDriveQuery_FilesCreate.query(withObject: folder, uploadParameters: nil)
//
//            googleDriveService.executeQuery(query) { (_, file, error) in
//                guard error == nil else {
//                    fatalError(error!.localizedDescription)
//                }
//
//                let folder = file as! GTLRDrive_File
//                completion(folder.identifier!)
//            }
//        }
//
//        func populateFolderID() {
//            let myFolderName = "my-folder"
//            getFolderID(
//                name: myFolderName,
//                service: googleDriveService,
//                user: googleUser!) { folderID in
//                if folderID == nil {
//                    self.createFolder(
//                        name: myFolderName,
//                        service: googleDriveService) {
//                        uploadFolderID = $0
//                    }
//                } else {
//                    // Folder already exists
//                    uploadFolderID = folderID
//                }
//            }
//        }
}
