//
//  DataService.swift
//  Comic Cast
//
//  Created by Bjarne Tvedten on 22/01/2019.
//  Copyright © 2019 Digital Mood. All rights reserved.
//

import Foundation
import Firebase

// OFF SCOPE GLOBAL Database REF
// -----------------------------
let DB_BASE = Database.database().reference()
let STORAGE_BASE = Storage.storage().reference()

// DataService Singleton for Database Capabilities
// -----------------------------------------------------
class DataService {
    static let instance = DataService()
    // private let _REF: DatabaseReference = Database.database().reference(withPath: "data")
    
    // DB references
    private var _REF_BASE = DB_BASE
    
    // DB child references
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_COMICS = DB_BASE.child("comics")
    
    // Storage reference "AKA Datahiding"
    private var _REF_PROFILE_IMAGES = STORAGE_BASE.child("users")
    private var _REF_COMIC_IMAGES = STORAGE_BASE.child("comics")
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    var REF_COMICS: DatabaseReference {
        return _REF_COMICS
    }
    
    var REF_USER_CURRENT: DatabaseReference {
        let uid = Auth.auth().currentUser?.uid
        let user = REF_USERS.child(uid!)
        return user
    }
    
    // Storage Images Reference "Path on the server"
    var REF_PROFILE_IMAGES: StorageReference {
        return _REF_PROFILE_IMAGES
    }
    
    var REF_COMIC_IMAGES: StorageReference {
        return _REF_COMIC_IMAGES
    }
    
    // Database Functions
    func createFirbaseDBUser(uid: String, userData: Dictionary<String, String>) {
        // Create or Update "Users / UID / Values"
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
    func updateChildValues(userData: [String: String]) {
        let REF = REF_USER_CURRENT.child("testing")
        REF.updateChildValues(userData)
    }
    
    func postTo(comic: Comic, completion: Completion? = nil) {
        if let comicUID = comic.comicUID {
            let REF = REF_COMICS.child(comicUID).child("episode")
            if let episodeUID = comic.episodeUID {
                
                let userData: [String: Any] = [:
                    /*
                    
                    */
                ]
                REF.child(episodeUID).updateChildValues(userData)
            }
            completion?()
        }
    }
    
    func post(image: UIImage?, to comic: Comic?, completion: Completion? = nil) {
        if let comicUID = /* KeychainWrapper.standard.string(forKey: KEY_UID) */ AuthService.instance.comicUID {
            if let img = image {
                // Generic Function
                // if let imgData = UIImageJPEGRepresentation(img, 0.4) {
                if let imgData = img.jpegData(compressionQuality: 0.4) {
                    
                    // Unique image identifier
                    let imageUID = NSUUID().uuidString
                    // Set metaData for the image
                    let metadata = StorageMetadata()
                    metadata.contentType = "image/jpeg"
                    // Upload image - STORAGE_BASE.child(" --- ").child( --- ).put(image, meta)
                    let storageREF = DataService.instance.REF_COMIC_IMAGES.child(comicUID).child("items").child("\(imageUID).jpg")
                    storageREF.putData(imgData, metadata: metadata) { (metadata, error) in
                        if error != nil {
                            print("postImageToFirebase: Unable to upload image to Firebase storage")
                            print(error!)
                        } else {
                            print("postImageToFirebase: Successfully uploaded image to Firebase storage")
                            storageREF.downloadURL { (url, err) in
                                if let absoluteUrlString = url?.absoluteString {
                                    if DataService.instance.REF_COMICS.child(comicUID).child("all").childByAutoId().key != nil {
                                        if let comic = comic {
                                            let newComic = Comic(comicID: comic.comicID, comicName: comic.comicName, comicNumber: comic.comicNumber, episodeTitle: comic.episodeTitle, episodeInfo: comic.episodeInfo, imgURL: absoluteUrlString, logoURL: comic.logoURL)
                                            DataService.instance.postTo(comic: newComic)
                                        }
                                        completion?()
                                    }
                                } else {
                                    print("unable to get imageLocation")
                                }
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    
}