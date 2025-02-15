//
//  NewPassViewController.swift
//  90's
//
//  Created by 홍정민 on 2020/05/06.
//  Copyright © 2020 홍정민. All rights reserved.
//

import UIKit

class NewPassViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var tfNewPass: UITextField!
    @IBOutlet weak var tfConfirmPass: UITextField!
    @IBOutlet weak var selectorImageView1: UIImageView!
    @IBOutlet weak var selectorImageView2: UIImageView!
    @IBOutlet weak var validationLabel: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var buttonConst: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topConst: NSLayoutConstraint!
    
    var authenType:String?
    var pass:String!
    var phoneNum:String!
    var keyboardFlag = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setObserver()
    }
    
    @IBAction func goBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    //확인 버튼 클릭 시 액션
    @IBAction func clickNextBtn(_ sender: Any) {
        let newPass = tfNewPass.text!
        let confirmPass = tfConfirmPass.text!
        
        if(newPass == confirmPass){
            pass = newPass
            changePassword()
        }else {
            validationLabel.isHidden = false
            selectorImageView2.image = UIImage(named: "path378Red")
        }
    }
    
    func setUI(){
        tfNewPass.delegate = self
        tfConfirmPass.delegate = self
        nextBtn.isEnabled = false
        tfConfirmPass.isEnabled = false
        validationLabel.isHidden = true
        nextBtn.layer.cornerRadius = 8.0
        subTitleLabel.textLineSpacing(firstText: "새로운 비밀번호를", secondText: "입력해 주세요")
        
        if let type = authenType {
            if(type == "MainFindPass"){
                self.titleLabel.isHidden = true
            }
        }
        
    }
    
    func setObserver(){
        //새로운 패스워드 TF에 대한 옵저버
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: tfNewPass, queue: .main, using : {
            _ in
            let str = self.tfNewPass.text!.trimmingCharacters(in: .whitespaces)
            
            if(str != ""){
                self.selectorImageView1.image = UIImage(named: "path378Black")
                self.tfConfirmPass.isEnabled = true
            }else {
                self.selectorImageView1.image = UIImage(named: "path378Grey1")
                self.tfConfirmPass.isEnabled = false
            }
            
        })
        
        //패스워드 확인 TF에 대한 옵저버
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: tfConfirmPass, queue: .main, using : {
            _ in
            let str = self.tfConfirmPass.text!.trimmingCharacters(in: .whitespaces)
            
            if(str != ""){
                self.selectorImageView2.image = UIImage(named: "path378Black")
                self.nextBtn.backgroundColor = UIColor(red: 227/255, green: 62/255, blue: 40/255, alpha: 1.0)
                self.nextBtn.isEnabled = true
            }else {
                self.selectorImageView2.image = UIImage(named: "path378Grey1")
                self.nextBtn.backgroundColor = UIColor(red: 199/255,green: 201/255, blue: 208/255, alpha: 1.0)
                self.nextBtn.isEnabled = false
            }
            
        })
        
        //키보드에 대한 Observer
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardHeight = keyboardSize.cgRectValue.height
        
        let frameHeight = self.view.frame.height
        if(frameHeight >= 736.0){
            //iphone6+, iphoneX ... (화면이 큰 휴대폰)
            buttonConst.constant = keyboardHeight - 18
        }else if(!keyboardFlag){
            //~iphone8, iphone7 (화면이 작은 휴대폰)
            keyboardFlag = true
            topConst.constant += 70
            self.view.frame.origin.y -= keyboardHeight
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardHeight = keyboardSize.cgRectValue.height
        let frameHeight = self.view.frame.height
        
        if(frameHeight >= 736.0){
            //iphoneX~
            buttonConst.constant = 18
        }else if(keyboardFlag){
            //~iphone8
            keyboardFlag = false
            topConst.constant -= 70
            self.view.frame.origin.y = 0
            self.view.layoutIfNeeded()
        }
    }
    
    
    //화면 터치시 키보드 내림
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        tfNewPass.endEditing(true)
        tfConfirmPass.endEditing(true)
    }
    
    //키보드 리턴 버튼 클릭 시 키보드 내림
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if(textField == tfNewPass){
            tfConfirmPass.becomeFirstResponder()
        }
        return true
    }
    
}


extension NewPassViewController {
    //비밀번호 변경 서버통신 메소드
    func changePassword(){
        ProfileService.shared.changePass(password: self.pass, phoneNum: self.phoneNum, completion: { response in
            if let status = response.response?.statusCode {
                switch status {
                case 200:
                    //기존의 정보 다 삭제(자체로그인 시 저장하는 정보 : email, password, social, jwt)
                    UserDefaults.standard.removeObject(forKey: "email")
                    UserDefaults.standard.removeObject(forKey: "password")
                    UserDefaults.standard.removeObject(forKey: "social")
                    UserDefaults.standard.removeObject(forKey: "jwt")
                    
                    self.goCompleteVC()
                    break
                case 401...404:
                    self.showErrAlert()
                    break
                case 500:
                    self.showErrAlert()
                    break
                default:
                    return
                }
            }
            
        })
    }
    
    func showErrAlert(){
        let alert = UIAlertController(title: "오류", message: "비밀번호 변경 불가", preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    func goCompleteVC() {
        let completeManageVC = storyboard?.instantiateViewController(withIdentifier: "CompleteManageViewController") as! CompleteManageViewController
        completeManageVC.pass = self.pass
        completeManageVC.authenType = "비밀번호 변경"
        navigationController?.pushViewController(completeManageVC, animated: true)
        
    }
}

