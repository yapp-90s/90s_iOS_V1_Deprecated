//
//  SignService.swift
//  Team-90s
//
//  Created by 성다연 on 2020/08/31.
//  Copyright © 2020 com.yapp.90s. All rights reserved.
//

import Alamofire

struct SignService : APIManager {
    static var shared = SignService()
    
    let header : HTTPHeaders =  ["Content-Type" : "application/json"]
    typealias completeSignService = (AFDataResponse<Any>) -> ()
    
    func findEmail(phoneNum:String, completion: @escaping(completeSignService)){
        let url = Self.url("/user/findEmail")
        let body = [
            "phoneNum" : phoneNum
        ]
        
        AF.request(url, method: .post, parameters: body, encoding:JSONEncoding.default, headers: header).responseJSON(completionHandler: {
            response in
            switch response.result {
            case .success:
                completion(response)
            case .failure(let err):
                print("Find Email err : \(err)")
                break
            }
        })
        
    }
    
    func telephoneAuth(phone:String, completion: @escaping(completeSignService)){
        let url = Self.url("/user/checkPhoneNum")
        let body: [String:Any] = [
            "phoneNumber" : phone
        ]
        
        AF.request(url, method: .post, parameters: body, encoding:JSONEncoding.default, headers: header).responseJSON(completionHandler: {
            response in
            switch response.result {
            case .success:
                completion(response)
            case .failure(let err):
                print("SignUp - telephone err : \(err)")
                break
            }
        })
    }
    
    func login(email:String, password: String?, sosial:Bool, completion: @escaping(completeSignService)){
        let url = Self.url("/user/login")
        let body: [String:Any] = [
            "email": email,
            "password": password,
            "sosial": sosial
        ]
        
        AF.request(url, method: .post, parameters: body, encoding:JSONEncoding.default, headers: header).responseJSON(completionHandler: {
            response in
            switch response.result {
            case .success:
                completion(response)
            case .failure(let err):
                print("signUp err : \(err)")
                break
            }
        })
    }
    
    func signUp(email:String, name:String, password: String?, phone:String, sosial:Bool, completion: @escaping(completeSignService)){
        let url = Self.url("/user/join")
        let body: [String:Any] = [
            "email": email,
            "name": name,
            "password": password,
            "phone": phone,
            "sosial": sosial
        ]
        
        AF.request(url, method: .post, parameters: body, encoding:JSONEncoding.default, headers: header).responseJSON(completionHandler: {
            response in
            switch response.result {
            case .success:
                completion(response)
            case .failure(let err):
                print("signUp err : \(err)")
                break
            }
        })
    }
    
    func getDefaultUser(completion: @escaping(completeSignService)){
        let url = Self.url("/user/getDefaultUser")
        
        AF.request(url, method: .get, headers: header).responseJSON(completionHandler: {
            response in
            switch response.result {
            case .success:
                completion(response)
            case .failure(let err):
                print("Get Default User err : \(err)")
                break
            }
        })
    }
    
    func emailCheck(email: String, completion: @escaping(completeSignService)){
        let url = Self.url("/user/checkEmail")
        let body = ["email":email]
        
        AF.request(url, method: .post, parameters: body,encoding:JSONEncoding.default, headers: header)
            .responseJSON(completionHandler : {
                response in
                switch response.result {
                case .success:
                    completion(response)
                case .failure(let err):
                    print("duplication err : \(err)")
                    break
                }
            })
    }
}
