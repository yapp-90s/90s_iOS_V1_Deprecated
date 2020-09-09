//
//  ImageCropVC.swift
//  90's
//
//  Created by 성다연 on 2020/06/06.
//  Copyright © 2020 홍정민. All rights reserved.
//

import UIKit

class ImageCropVC: UIViewController {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var cropView: UIView!
    @IBAction func backBtn(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func nextBtn(_ sender: UIButton) { nextVC() }
    @IBOutlet weak var layoutView: UIView!
    @IBOutlet weak var layoutImageView: UIImageView!
    
 
    var layoutAbsoluteSize : CGSize = CGSize(width: 0, height: 0)
    var imageRatio : CGFloat = 0.0
    var imageSize : CGSize = CGSize(width: 0, height: 0)
    
    var image : UIImage!
    var selectedLayout : AlbumLayout! = .Polaroid
    var albumUid : Int = 0
    var imageName : String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaultSetting()
        layoutViewSetting()
        layoutImageViewSetting()
    }
}
 

extension ImageCropVC {
    private func defaultSetting(){
        // 이미지 비율 구하기
        imageRatio = min(image.size.width / image.size.height, image.size.height / image.size.width)
        // 이미지 크기 지정
        imageSize = image.size.width > image.size.height ?
            CGSize(width: view.frame.width, height: ceil(view.frame.width * imageRatio)) :
            CGSize(width: ceil(cropView.frame.height * imageRatio), height: cropView.frame.height)
        // 이미지 크기 조절
        photoImageView.image = image
        
        let commonLayoutSize = iPhone8Model() ?
                selectedLayout.innerFrameLowSize : selectedLayout.innerFrameHighSize
        var tempRatio : CGFloat = CGFloat()
       
        if commonLayoutSize.width >= imageSize.width || commonLayoutSize.height >= imageSize.height {
            if commonLayoutSize.width >= imageSize.width  {
                tempRatio = round((imageSize.width / commonLayoutSize.width) * 1000) / 1000
            } else if commonLayoutSize.height >= imageSize.height {
                tempRatio = round((imageSize.height / commonLayoutSize.height) * 1000) / 1000
            }
            
            layoutAbsoluteSize = CGSize(width: ceil(commonLayoutSize.width * tempRatio),
            height: ceil(commonLayoutSize.height * tempRatio))
        } else {
            layoutAbsoluteSize = commonLayoutSize
        }
    }
    
    
    // 이미지 크기 만큼의 뷰
    private func layoutViewSetting() {
        layoutView.translatesAutoresizingMaskIntoConstraints = false
        layoutView.frame.size = imageSize
        
        layoutView.heightAnchor.constraint(equalToConstant: imageSize.height).isActive = true
        layoutView.widthAnchor.constraint(equalToConstant: imageSize.width).isActive = true
        layoutView.centerXAnchor.constraint(equalTo: cropView.centerXAnchor).isActive = true
        layoutView.centerYAnchor.constraint(equalTo: cropView.centerYAnchor).isActive = true
    }
    
    private func layoutImageViewSetting(){
        layoutImageView.image = selectedLayout.cropImage
        layoutImageView.translatesAutoresizingMaskIntoConstraints = false
        layoutImageView.frame.size = layoutAbsoluteSize

        layoutImageView.heightAnchor.constraint(equalToConstant: layoutAbsoluteSize.height).isActive = true
        layoutImageView.widthAnchor.constraint(equalToConstant: layoutAbsoluteSize.width).isActive = true
        layoutImageView.centerXAnchor.constraint(equalTo: layoutView.centerXAnchor).isActive = true
        layoutImageView.centerYAnchor.constraint(equalTo: layoutView.centerYAnchor).isActive = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(panGesture:)))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(pinchGesture:)))
        layoutImageView.addGestureRecognizer(panGesture)
        layoutImageView.addGestureRecognizer(pinchGesture)
    }
    
    private func nextVC(){
        let scale: CGFloat = photoImageView.image!.size.width / photoImageView.frame.width
        let rect = CGRect(x: layoutImageView.frame.minX * scale, y: layoutImageView.frame.minY * scale, width: layoutImageView.frame.width * scale, height: layoutImageView.frame.height * scale)
        let croppedImage : UIImage = photoImageView.image!.cropToRect(rect: rect)!
        image = croppedImage
        
        if image != nil {
            let nextVC = storyboard?.instantiateViewController(withIdentifier: "imageRenderVC") as! ImageRenderVC
            
            nextVC.modalPresentationStyle = .fullScreen
            nextVC.image = image
            nextVC.selectLayout = self.selectedLayout
            nextVC.albumUid = self.albumUid
            nextVC.imageName = self.imageName
            
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
}


extension ImageCropVC {
    @objc private func handlePanGesture(panGesture: UIPanGestureRecognizer){
        guard let senderView = panGesture.view else { return }
        let translation = panGesture.translation(in: self.view)
       
        // 상하 조절
        if senderView.frame.origin.y < 0.0 {
            senderView.frame.origin = CGPoint(x: senderView.frame.origin.x, y: 0)
        }
        if senderView.frame.origin.y > layoutView.frame.height - senderView.frame.height {
            senderView.frame.origin = CGPoint(x: senderView.frame.origin.x, y: layoutView.frame.height - senderView.frame.height)
        }
        
        // 좌우 조절
        if senderView.frame.origin.x + senderView.frame.size.width >= view.frame.width {
            senderView.frame.origin = CGPoint(x: view.frame.width - senderView.frame.size.width, y: senderView.frame.origin.y)
        }
        if senderView.frame.origin.x < view.frame.origin.x {
            senderView.frame.origin = CGPoint(x: view.frame.origin.x, y: senderView.frame.origin.y)
        }
        
        // 부드럽게 만들기 = 이동 후 인식 -> 인식 후 이동
        if let centerX = panGesture.view?.center.x,
            let centerY = panGesture.view?.center.y {
            senderView.center = CGPoint.init(x: centerX + translation.x, y: centerY + translation.y)
            panGesture.setTranslation(CGPoint.zero, in: self.view)
        }
    }
    
    @objc private func handlePinchGesture(pinchGesture : UIPinchGestureRecognizer){
        guard let senderView = pinchGesture.view else {return}
        
        if senderView.frame.width >= layoutView.frame.width ||
            senderView.frame.height >= layoutView.frame.height {
            senderView.transform = senderView.transform.scaledBy(x: 1.0, y: 1.0)
        } else {
            senderView.transform = (senderView.transform.scaledBy(x: pinchGesture.scale, y: pinchGesture.scale))
        }
        pinchGesture.scale = 1.0
    }
}
