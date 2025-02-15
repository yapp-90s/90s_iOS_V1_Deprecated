//
//  AlbumServiceData.swift
//  90's
//
//  Created by 성다연 on 2020/04/29.
//  Copyright © 2020 홍정민. All rights reserved.
//

import Alamofire
import AlamofireImage


struct AlbumService : APIManager {
    static var shared = AlbumService()

    typealias completeAlbumService = (AFDataResponse<Any>) -> ()
    typealias completeAlbumPasswordService = (DataResponse<Optional<Data>, AFError>) -> ()
    typealias completePhotoDownloadService = (DataResponse<UIImage, AFError>) -> ()
    
    let header : HTTPHeaders =  [
        "Content-Type" : "application/json"
    ]
    
    var tokenHeader : HTTPHeaders = [
        "Content-Type" : "application/json",
        "X-AUTH-TOKEN" : isDefaultUser ?
         UserDefaults.standard.value(forKey: "defaultjwt") as! String :
         UserDefaults.standard.value(forKey: "jwt") as! String
    ]
   
    var photoHeader : HTTPHeaders =
    [
        "Content-type": "multipart/form-data",
        "X-AUTH-TOKEN" : isDefaultUser ?
            UserDefaults.standard.value(forKey: "defaultjwt") as! String :
            UserDefaults.standard.value(forKey: "jwt") as! String
    ]
    
    mutating func resetToken(){
        self.tokenHeader = [
            "Content-Type" : "application/json",
            "X-AUTH-TOKEN" : isDefaultUser ?
             UserDefaults.standard.value(forKey: "defaultjwt") as! String :
             UserDefaults.standard.value(forKey: "jwt") as! String
        ]
        self.photoHeader =
        [
            "Content-type": "multipart/form-data",
            "X-AUTH-TOKEN" : isDefaultUser ?
                UserDefaults.standard.value(forKey: "defaultjwt") as! String :
                UserDefaults.standard.value(forKey: "jwt") as! String
        ]
    }
    

    // Add User, post, 친구 추가
    func albumAddUser(albumUid : Int,  name: String, role : String, userUid : Int, completion: @escaping(completeAlbumService)){
        let url = Self.url("/album/addUser")
        let body : [String: Any] = [
            "albumUid" : albumUid,
            "name" : name,
            "role" : role,
            "userUid" : userUid
        ]
        
        AF.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: tokenHeader).responseJSON(completionHandler: {
            response in
            switch response.result {
            case .success:
                completion(response)
            case .failure(let err):
                print("==> Error in AlbumAddUser Service : \(err)")
            }
        })
    }
    
    // CreateAlbum, Post, 앨범 생성
    func albumCreate(endDate : String, layoutUid : Int, name : String, photoLimit : Int, cover : Int, completion : @escaping(completeAlbumService)){
        let url = Self.url("/album/create")
        let body : [String : Any] = [
            "endDate" : endDate,
            "layoutUid" : layoutUid,
            "name" : name,
            "photoLimit" : photoLimit,
            "coverUid" : cover
        ]
        
        AF.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: tokenHeader).responseJSON(completionHandler: {
            response in
            switch response.result {
            case .success:
                completion(response)
            case .failure(let err):
                print("==> Error in AlbumCreate Service : \(err)")
            }
        })
    }

    // getAlbum, post, 앨범 정보 가져오기
    func albumGetAlbum(uid:Int, completion : @escaping(completeAlbumService)){
        let url = Self.url("/album/getAlbum")
        let body : [String : Any] = [
            "uid" : uid
        ]

        AF.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: tokenHeader).responseJSON(completionHandler: {
            response in
            switch response.result {
            case .success:
                completion(response)
            case .failure(let err):
                print("==> Error in AlbumGetAlbum Service : \(err)")
            }
        })
    }
    
    // getAlbumOwners, post, 앨범 오너 정보
    func albumGetOwners(uid : Int, completion : @escaping(completeAlbumService)){
        let url = Self.url("/album/getAlbumOwners")
        let body : [String : Any] = [
            "uid":uid
        ]
        
        AF.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: tokenHeader).responseJSON(completionHandler: {
            response in
            switch response.result {
            case .success:
                completion(response)
            case .failure(let err):
                print("==> Error in AlbumGetOwners Service : \(err)")
            }
        })
    }
    
    // getAlbumPassword, get, 앨범 비밀번호
    func albumGetPassword(uid: Int, completion : @escaping(completeAlbumPasswordService)) {
        let url = Self.url("/album/getAlbumPassword/\(uid)")
        
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: tokenHeader).response(completionHandler: {
            response in
            switch response.result {
            case .success :
                guard let data = response.data else {return}
                if let string = String(data: data, encoding: .utf8) {
                    UIPasteboard.general.string = string
                } else {
                    print("not a valid UTF-8 sequence")
                }
                completion(response)
            case .failure(let err):
                print("==> Error in AlbumGetPassword Service : \(err)")
            }
        })
    }
    
    func albumUploadPassword(uid: Int, completion : @escaping(completeAlbumPasswordService)) {
        let url = Self.url("/album/updateAlbumPassword/\(uid)")
        
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: tokenHeader).response(completionHandler: {
            response in
            switch response.result {
            case .success:
                guard let data = response.data else {return}
                if let string = String(data: data, encoding: .utf8) {
                    UIPasteboard.general.string = string
                } else {
                    print("not a valid UTF-8 sequence")
                }
                completion(response)
                completion(response)
            case .failure(let err):
                print("==> Error in AlbumUpdatePassword Service : \(err)")
            }
        })
    }
    
    // getAlbums, get, 앨범 목록
    func albumGetAlbums( completion : @escaping(completeAlbumService)){
        let url = Self.url("/album/getAlbums")
            
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: tokenHeader).responseJSON(completionHandler: {
            response in
            switch response.result {
            case .success:
                completion(response)
            case .failure(let err):
                print("==> Error in GetAlbums Service : \(err)")
            }
        })
    }
    
    func albumJoinPassword(password : String, completion : @escaping(completeAlbumService)){
        let url = Self.url("/album/joinAlbumByPassword")
        
        AF.request(url, method: .post, encoding: JSONEncoding.default, headers: tokenHeader).responseJSON(completionHandler: {
            response in
            switch response.result {
            case .success:
                completion(response)
            case .failure(let err):
                print("==> Error in CheckPassword Service : \(err)")
            }
        })
    }
    
    // plusCount, get 앨범 낡기 카운드
    func albumPlusCount(uid: Int, completion : @escaping(completeAlbumService)){
        let url = Self.url("/album/plusCount/\(uid)")
        
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: tokenHeader).responseJSON(completionHandler: {
            response in
            switch response.result {
            case .success:
                completion(response)
            case .failure(let err):
                print("==> Error in AlbumplusCount Service : \(err)")
            }
        })
    }
    
    // removeUser, post
    func albumRemoveUser(albumUid : Int, role : String, name : String, userUid : Int, completion: @escaping(completeAlbumService)){
        let url = Self.url("/album/removeUser")
        let body : [String : Any] = [
            "albumUid" : albumUid,
            "name" : name,
            "role" : role,
            "userUid" : userUid
        ]
        
        AF.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: tokenHeader).responseJSON(completionHandler: { response in
            switch response.result {
            case .success :
                completion(response)
            case .failure(let err):
                print("==> Error in AlbumRemoveUser Service : \(err)")
            }
        })
    }
}


/** Photo  **/
extension AlbumService {
    // photoDownload, post, 사진 가져오기
    func photoDownload(albumUid : Int, photoUid : Int, completion : @escaping(completePhotoDownloadService)) {
        let url = Self.url("/photo/download")
        let body : [String : Any] = [
            "albumUid" : albumUid,
            "photoUid" : photoUid
        ]
        
        AF.request(url,method: .post, parameters: body, encoding: JSONEncoding.default, headers: tokenHeader).responseImage(completionHandler: {response in
            switch response.result {
            case .success:
                completion(response)
            case .failure(let err):
                print("==> Error in PhotoDownload Service : \(err)")
            }
        })
    }
    
    // photoGetPhoto, post, 사진 목록의 사진 uid
    func photoGetPhoto(albumUid : Int, completion: @escaping(completeAlbumService)){
        let url = Self.url("/photo/getPhotos")
        let body : [String : Any] = [
            "uid" : albumUid
        ]
        
        AF.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: tokenHeader).responseJSON(completionHandler: {
            response in
            switch response.result {
            case .success:
                completion(response)
            case .failure(let err):
                print("==> Error in PhotoGetPhotos Service : \(err)")
            }
        })
    }
    
    
    // photoUpload, post, 사진 업로드
    func photoUpload(albumUid : Int, image: [UIImage], imageName: String!, completion: @escaping(completeAlbumService)){
        let url = Self.url("/photo/upload")
        let body : [String : Any] = [
            "albumUid" : albumUid
        ]
        
        guard let imageData = image[0].jpegData(compressionQuality: 1.0) else {return}
        
        AF.upload(
            multipartFormData: { multipartFormData in
                for (key, value) in body {
                    multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
                }
                multipartFormData.append(imageData, withName: "image" , fileName: imageName, mimeType: "image/jpeg") //fileName : imagename.jpeg
                
        }, to: url, method: .post , headers: photoHeader)
            .response { response in
                switch response.result {
                case .success:
                    print(response)
                case .failure(let err):
                    print("==> Error in PhotoUpload Service : \(err)")
            }
        }
    }
}
