//
//  ProfileService.swift
//  Team-90s
//
//  Created by 성다연 on 2020/08/31.
//  Copyright © 2020 com.yapp.90s. All rights reserved.
//

import Alamofire

struct ProfileService : APIManager {
    static let shared = ProfileService()
    let header: HTTPHeaders =  [
        "Content-Type" : "application/json",
        "X-AUTH-TOKEN" :  UserDefaults.standard.string(forKey: "jwt")!]
    typealias completeProfileService = (AFDataResponse<Any>) -> ()
    typealias completeProfileService_Int = (Int) -> ()
    
    func getOrder(completion: @escaping(completeProfileService)){
        let url = Self.url("/album/order/getAlbumOrders")
        
        AF.request(url, method: .get, headers: header).responseJSON(completionHandler: {
            response in
            switch response.result {
            case .success:
                completion(response)
            case .failure(let err):
                print("get orderList err : \(err)")
                break
            }
        })
    }
    
    func cancelOrder(albumOrderUid: Int, completion: @escaping(completeProfileService_Int)){
        let url = Self.url("/album/order/deleteAlbumOrder/\(albumOrderUid)")
    
        AF.request(url, method: .delete, headers: header).response(completionHandler: {
            response in
            switch response.result {
            case .success:
                completion(response.response!.statusCode)
            case .failure(let err):
                print("get orderList err : \(err)")
                break
            }
        })
    }
    
    func leave(token:String, completion: @escaping(completeProfileService_Int)){
        let url = Self.url("/user/signout")
        let header: HTTPHeaders =  [
            "Content-Type" : "application/json",
            "X-AUTH-TOKEN": token
        ]
        
        AF.request(url, method: .get, headers: header).response(completionHandler: {
            response in
            switch response.result {
            case .success:
                print("signOut success")
                completion((response.response?.statusCode)!)
            case .failure(let err):
                print("signOut err : \(err)")
                break
            }
        })
    }
    
    func changePass(password: String, phoneNum: String, completion: @escaping(completeProfileService)){
        let url = Self.url("/user/updatePassword")
        let body: [String:Any] = [
            "password": password,
            "phoneNum": phoneNum
        ]
        
        AF.request(url, method: .post, parameters: body, encoding:JSONEncoding.default, headers: header).responseJSON(completionHandler: {
            response in
            switch response.result {
            case .success:
                completion(response)
            case .failure(let err):
                print("Update Pass err : \(err)")
                break
            }
        })
    }
    
    func getProfile(token:String, completion: @escaping(completeProfileService)){
        let url = Self.url("/user/getUserProfile")
        let header: HTTPHeaders =  [
            "Content-Type" : "application/json",
            "X-AUTH-TOKEN" :  token
        ]
        
        AF.request(url, method: .get, headers: header).responseJSON(completionHandler: {
            response in
            switch response.result {
            case .success:
                completion(response)
            case .failure(let err):
                print("Update Email err : \(err)")
                break
            }
        })
    }
    
    func changePhone(phoneNum: String, completion: @escaping(completeProfileService)){
        let url = Self.url("/user/updatePhoneNumber")
           let body: [String:Any] = [
               "phoneNum": phoneNum
           ]
           
           AF.request(url, method: .post, parameters: body, encoding:JSONEncoding.default, headers: header).responseJSON(completionHandler: {
               response in
               switch response.result {
               case .success:
                   completion(response)
               case .failure(let err):
                   print("Change Phone err : \(err)")
                   break
               }
           })
       }
    
    func changeEmail(email: String, completion: @escaping(completeProfileService)){
        let url = Self.url("/user/updateEmail")
        let body: [String:Any] = [
            "email": email
        ]
        
        AF.request(url, method: .post, parameters: body, encoding:JSONEncoding.default, headers: header).responseJSON(completionHandler: {
            response in
            switch response.result {
            case .success:
                completion(response)
            case .failure(let err):
                print("Update Email err : \(err)")
                break
            }
        })
        
    }
}
