//
//  AlbumInfoVC.swift
//  90's
//
//  Created by 성다연 on 2020/04/11.
//  Copyright © 2020 홍정민. All rights reserved.
//

import UIKit
import KakaoLink

protocol albumInfoDeleteProtocol {
    func switchQuitHideView(value : Bool)
}

class AlbumInfoVC: UIViewController {
    @IBOutlet weak var hideView: UIView!
    @IBOutlet weak var hideLabel: UILabel!
    @IBOutlet weak var hideCancleBtn: UIButton!
    @IBOutlet weak var hideCompleteBtn: UIButton!
    @IBOutlet weak var hideWhiteViewBottom: NSLayoutConstraint!
    @IBOutlet weak var hideWhiteView: UIView!
    
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var albumDateLabel: UILabel!
    @IBOutlet weak var albumCountLabel: UILabel!
    @IBOutlet weak var albumLayoutLabel: UILabel!
    @IBOutlet weak var albumCoverImageView: UIImageView!
    @IBOutlet weak var memberTableView: UITableView!
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var memberTableConst: NSLayoutConstraint!
    
    @IBOutlet weak var copyPasswdBtn: UIButton!
    @IBOutlet weak var newPasswdBtn: UIButton!
    @IBOutlet weak var inviteBtn: UIButton!
    @IBOutlet weak var quitBtn: UIButton!
    
    @IBAction func backBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func touchInviteBtn(_ sender: UIButton) {
        inviteSetting()
    }
    @IBAction func quitMemberBtn(_ sender: UIButton) {
        hideLabel.text = "이 앨범에서 나가시겠습니까?"
        switchQuitHideView(value: false)
    }
    
    @IBOutlet weak var albumPasswordCopyBtn: UIButton!
    @IBOutlet weak var albumPasswordUploadBtn: UIButton!
    
    var albumUid: Int = 0
    var infoAlbum : album?
    var mainProtocol : AlbumMainVCProtocol?
    var me : AlbumUserData!
    var other : AlbumUserData!
    var otherTag : Int = 0
    
    var userArray : [AlbumUserData] = []
    var roleArray : [String] = []
    var userUidArray : [Int] = []
    var userNameArray : [String] = []
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        
        if hideView.isHidden == false {
            if touch.view != self.hideWhiteView {
                switchQuitHideView(value: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        networkSetting()
        defaultUserSetting()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaultSetting()
        hideViewSetting()
    }
}


extension AlbumInfoVC : albumInfoDeleteProtocol {
    private func defaultSetting(){
        guard let data = infoAlbum else {return}
        albumCoverImageView.image = getCoverByUid(value: data.cover.uid)
        albumNameLabel.text = data.name
        albumDateLabel.text = "\(data.created_at.split(separator: "T").first!)  ~ \(data.endDate)"
        albumCountLabel.text = "\(data.photoLimit)"
        albumLayoutLabel.text = getLayoutByUid(value: data.layout).layoutName
      
        
        memberTableView.delegate = self
        memberTableView.dataSource = self
        
        albumPasswordCopyBtn.layer.borderWidth = 1.0
        albumPasswordCopyBtn.layer.borderColor = UIColor.lightGray.cgColor
        albumPasswordUploadBtn.layer.borderWidth = 1.0
        albumPasswordUploadBtn.layer.borderColor = UIColor.lightGray.cgColor
        albumPasswordCopyBtn.addTarget(self, action: #selector(touchPasswordCopyBtn), for: .touchUpInside)
        albumPasswordUploadBtn.addTarget(self, action: #selector(touchPasswordUploadBtn), for: .touchUpInside)
    }
    
    private func defaultUserSetting(){
        switch isDefaultUser {
        case true:
            inviteBtn.isHidden = true
            copyPasswdBtn.isHidden = true
            newPasswdBtn.isHidden = true
            quitBtn.isHidden = true
        case false:
            inviteBtn.isHidden = false
            copyPasswdBtn.isHidden = false
            newPasswdBtn.isHidden = false
            quitBtn.isHidden = false
        }
        
    }
    
    private func hideViewSetting(){
        hideLabel.text = "앨범에서 해당 멤버를\n삭제하시겠습니까?"
        hideCancleBtn.addTarget(self, action: #selector(touchHideCancleBtn), for: .touchUpInside)
        hideCompleteBtn.addTarget(self, action: #selector(touchHideCompleteBtn), for: .touchUpInside)
    }
    
    func switchQuitHideView(value : Bool){
        switch value {
        case true :
            hideWhiteViewBottom.constant = -hideWhiteView.frame.height
            hideView.isHidden = true
        case false :
            hideWhiteViewBottom.constant = 0
            hideView.isHidden = false
        }
        UIView.animate(withDuration: 0.5, delay: 0.25, animations: {
            self.view.layoutIfNeeded()
        })
    }
}


extension AlbumInfoVC {
    // 멤버 목록 가져오기
    private func networkSetting(){
        AlbumService.shared.albumGetOwners(uid:albumUid, completion: { response in
            if let status = response.response?.statusCode {
                switch status {
                case 200:
                    guard let data = response.data else {return}
                    guard let value = try? JSONDecoder().decode([AlbumUserData].self, from: data) else {return}
                    let identify = value.compactMap { $0.userUid }.first
                    self.me = value.filter {$0.userUid == identify }.first
                    self.other = self.me
                    self.userArray = value.map { $0 }
                    self.roleArray = self.userArray.map { $0.role }
                    self.userUidArray = self.userArray.map { $0.userUid }
                    self.userNameArray = self.userArray.map { $0.name }
                    self.memberTableView.reloadData()
                case 401:
                    print("\(status) : bad request, no warning in Server")
                case 404:
                    print("\(status) : Not found, no address")
                case 500 :
                    print("\(status) : Server error in AlbumInfo - getOwners")
                default:
                    return
                }
            }
        })
    }
    
    // 멤버 추가
    private func networkAddUser(username: String, userrole : String, useruid: Int){
        AlbumService.shared.albumAddUser(albumUid: albumUid, name: username, role: userrole, userUid: useruid, completion: { response in
            
            if let status = response.response?.statusCode {
                switch status {
                case 200 :
                    self.memberTableView.reloadData()
                    print("albumInfo - add User complete")
                case 401:
                    print("\(status) : bad request, no warning in Server")
                case 404:
                    print("\(status) : Not found, no address")
                case 500 :
                    print("\(status) : Server error in AlbumInfo - addUser")
                default:
                    return
                }
            }
        })
    }
    
    // 멤버 삭제
    private func networkRemoveUser(userName : String, userRole : String, userUid: Int){
        AlbumService.shared.albumRemoveUser(albumUid: albumUid, role: userRole, name: userName, userUid: userUid, completion: { response in
            if let status = response.response?.statusCode {
                switch status {
                case 200 :
                    self.memberTableView.reloadData()
                case 401 :
                    print("\(status) : bad request, no warning in Server")
                case 404 :
                    print("\(status) : Not found, no address")
                case 500 :
                    print("\(status) : Server error in AlbumInfo - removeUser")
                default:
                    return
                }
            }
        })
    }
    
    private func networkGetPassword(){
        AlbumService.shared.albumGetPassword(uid: albumUid, completion: {
            response in
            if let status = response.response?.statusCode {
                switch status {
                    case 200 :
                        print("get password success")
                    case 401 :
                        print("\(status) : bad request, no warning in Server")
                    case 404 :
                        print("\(status) : Not found, no address")
                    case 500 :
                        print("\(status) : Server error in AlbumInfo - getPassword")
                    default:
                        return
                }
            }
        })
    }
    
    private func networkUpdatePassword(){
        AlbumService.shared.albumUploadPassword(uid: albumUid, completion: {
            response in
            if let status = response.response?.statusCode {
                switch status {
                    case 200 :
                        print("upload password success")
                    case 401 :
                        print("\(status) : bad request, no warning in Server")
                    case 404 :
                        print("\(status) : Not found, no address")
                    case 500 :
                        print("\(status) : Server error in AlbumInfo - uploadPassword")
                    default:
                        return
                }
            }
        })
    }
}


extension AlbumInfoVC {
    @objc private func touchHideCancleBtn(){
        switchQuitHideView(value: true)
    }
    
    @objc private func touchHideCompleteBtn(){
        networkRemoveUser(userName: other.name, userRole: other.role, userUid: other.userUid)
        userArray.remove(at: otherTag)
        
        if otherTag == 0 {
            mainProtocol?.AlbumMainreloadView()
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            memberTableView.reloadData()
        }
        switchQuitHideView(value: true)
    }
    
    @objc private func touchMemberDeleteBtn(_ sender : UIButton){
        other = userArray[sender.tag]
        otherTag = sender.tag
        hideLabel.text = "앨범에서 해당 멤버를\n삭제하시겠습니까?"
        switchQuitHideView(value: false)
    }
    
    @objc private func touchPasswordCopyBtn(){
        networkGetPassword()
        copyPasswordAlert()
    }
    
    @objc private func touchPasswordUploadBtn(){
        networkUpdatePassword()
        requestNewPasswordAlert()
    }
}


extension AlbumInfoVC {
    private func inviteSetting() {
        let templeteId = "24532"
        KLKTalkLinkCenter.shared().sendCustom(withTemplateId: templeteId, templateArgs: nil, success: {(warningMsg, argumentMsg) in
            print("warning message : \(String(describing: warningMsg))")
            print("argument message : \(String(describing: argumentMsg))")
        }, failure: {(error) in
            print("error \(error)")
        })
    }
    
    private func copyPasswordAlert(){
        let alert = UIAlertController(title: "비밀번호 복사", message: "비밀번호가 클립보드에 복사 되었습니다!", preferredStyle: UIAlertController.Style.alert)
        let accept = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(accept)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func requestNewPasswordAlert(){
        let alert = UIAlertController(title: "비밀번호 재발급", message: "재발급된 비밀번호가 클립보드에 복사 되었습니다!", preferredStyle: UIAlertController.Style.alert)
        let accept = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(accept)
        self.present(alert, animated: true, completion: nil)
    }
}

// 오너의 경우 헤더뷰로 하나 넣기
extension AlbumInfoVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "membertablecell", for: indexPath) as! MemberTableViewCell
        
        if roleArray[indexPath.row] == "ROLE_CREATOR" {
            cell.memberImageView.image = UIImage(named: "iconOwner")
            cell.memberNameLabel.text = userNameArray[indexPath.row]
            cell.memberSubLabel.text = "Owner"
            cell.memberDeleteBtn.isEnabled = false
            cell.memberDeleteBtn.isHidden = true
        } else {
            cell.memberImageView.image = UIImage(named: "iconMembers")
            cell.memberNameLabel.text = userNameArray[indexPath.row]
            cell.memberSubLabel.text = "Member"
            cell.memberDeleteBtn.isEnabled = true
            cell.memberDeleteBtn.isHidden = false
        }
        
        cell.memberDeleteBtn.tag = indexPath.row
        cell.memberDeleteBtn.addTarget(self, action: #selector(touchMemberDeleteBtn(_:)), for: .touchUpInside)
        
        self.memberTableConst.constant = self.memberTableView.contentSize.height + 35 
        self.memberTableView.layoutIfNeeded()
        
        return cell
    }
}



class MemberTableViewCell: UITableViewCell {
    @IBOutlet weak var memberImageView: UIImageView!
    @IBOutlet weak var memberNameLabel: UILabel!
    @IBOutlet weak var memberSubLabel: UILabel!
    @IBOutlet weak var memberDeleteBtn: UIButton!
    @IBAction func memberDeleteBtn(_ sender: UIButton) {
        infoProtocol?.switchQuitHideView(value: false)
    }
    
    var infoProtocol : albumInfoDeleteProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
