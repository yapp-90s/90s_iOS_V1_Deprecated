//
//  TermViewController.swift
//  90's
//
//  Created by 홍정민 on 2020/04/09.
//  Copyright © 2020 홍정민. All rights reserved.
//

import UIKit

protocol ClickDelegate : NSObjectProtocol {
    func cellClick(isClicked : Bool)
    func indicatorClick(index : Int)
}


class TermViewController: UIViewController {
    @IBOutlet weak var termTableView: UITableView!
    @IBOutlet weak var agreeAllTermBtn: UIButton!
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    let termTitle = ["이용약관 (필수)", "개인정보 수집 및 이용동의 (필수)", "연령(만 14세 이상)확인 (필수)"]
    var isAllTermBtnClicked = false
    var agreeCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    @IBAction func goBack(_ sender: Any) {
        guard let count = navigationController?.viewControllers.count else { return }
        
        if count >= 2 {
            navigationController?.popViewController(animated: true)
        } else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.switchEnterView()
        }
    }
    
    @IBAction func agreeAllTerms(_ sender: Any) {
        for cell in termTableView.visibleCells {
            let cell = cell as! TermCell
            cell.isClicked = isAllTermBtnClicked ? true : false
        }
        
        switchButtonStatus(value: isAllTermBtnClicked)
        if isAllTermBtnClicked == false { agreeCount = 0 }
        isAllTermBtnClicked = !isAllTermBtnClicked
    }
    
    @IBAction func clickOkBtn(_ sender: Any) {
        let emailVC = storyboard?.instantiateViewController(withIdentifier: "EmailViewController") as! EmailViewController
        self.navigationController?.pushViewController(emailVC, animated: true)
    }
    
    func setUI(){
        navigationController?.isNavigationBarHidden = true
        tabBarController?.tabBar.isHidden = true
        termTableView.delegate = self
        termTableView.dataSource = self
        switchButtonStatus(value: false)
        okBtn.layer.cornerRadius = 8.0
        titleLabel.textLineSpacing(firstText: "원활한 사용을 위해", secondText: "이용 약관에 동의해 주세요")
    }
    
    func switchButtonStatus(value : Bool) {
        switch value {
        case true :
            agreeAllTermBtn.setBackgroundImage(UIImage(named: "checkboxInact"), for: .normal)
            okBtn.backgroundColor = UIColor.colorRGBHex(hex: 0xE33E28)
            okBtn.isUserInteractionEnabled = true
        case false :
            agreeAllTermBtn.setBackgroundImage(UIImage(named: "checkboxgray"), for: .normal)
            okBtn.backgroundColor =  UIColor.colorRGBHex(hex: 0xC7C9D0)
            okBtn.isUserInteractionEnabled = false
        }
    }
}


extension TermViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TermCell") as! TermCell
        cell.indexNumber = indexPath.row
        cell.clickDelegate = self
        cell.termTitle.text = termTitle[indexPath.row]
        
        return cell
    }
    
}

extension TermViewController : ClickDelegate {
    func indicatorClick(index: Int) {
        let termDetailVC = storyboard?.instantiateViewController(withIdentifier: "TermDetailViewController") as! TermDetailViewController
        termDetailVC.index = index
        self.navigationController?.pushViewController(termDetailVC, animated: true)
    }
    
    func cellClick(isClicked: Bool) {
        agreeCount = isClicked ? agreeCount + 1 : agreeCount - 1
        agreeCount == 3 ? switchButtonStatus(value: true) : switchButtonStatus(value: false)
    }
}


