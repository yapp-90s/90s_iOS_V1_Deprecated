//
//  ProfileServiceData.swift
//  Team-90s
//
//  Created by 성다연 on 2020/08/31.
//  Copyright © 2020 com.yapp.90s. All rights reserved.
//

import Foundation

struct GetOrderResult : Codable {
    let uid : Int
    let album : album
    let paperType1 : PaperType
    let postType : PaperType
    let cost : String
    let amount : Int
    let orderCode : String
    var recipient : String
    var address : String
    var addressDetail : String
    var phoneNum : String
    var message : String
    var postalCode : String
    var trackingNum : String?
}

struct PaperType : Codable {
    let uid : Int
    let type : String
}

struct ProfileResult : Codable{
    let albumTotalCount : Int
    let albumPrintingCount : Int
    let userInfo : UserInfo
}

struct UserInfo : Codable {
    let email : String
    let name : String!
    let phoneNum : String!
}
