//
//  SignServiceData.swift
//  Team-90s
//
//  Created by 성다연 on 2020/08/31.
//  Copyright © 2020 com.yapp.90s. All rights reserved.
//

import Foundation

struct LoginResult {
    var email: String?
    var password: String?
    var social: Bool?
    var kakaoToken: String?
}

struct FindEmailResult : Codable {
    let email:String
    let name:String
}

struct FindEmailErrResult: Codable{
    let status: Int
    let error: String
    let message :String
}

struct CheckEmailResult : Codable {
    var result:Bool?
}

struct SignUpResult : Codable {
    var jwt:String? //jwt token
}

struct TelephoneAuthResult : Codable {
    var num:String? //Authentication number
}
