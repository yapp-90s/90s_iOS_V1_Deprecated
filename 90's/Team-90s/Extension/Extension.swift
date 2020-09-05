//
//  Extension.swift
//  AlbumExample
//
//  Created by 성다연 on 24/03/2020.
//  Copyright © 2020 홍정민. All rights reserved.
//

import UIKit
import AVFoundation

extension String {
    //이메일 정규식 검증
    public func validateEmail() -> Bool {
        let emailRegEx = "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$"
        
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: self)
    }
}


extension UIButton {
    func switchComplete(next : Bool){
        switch next {
        case true :
            self.isEnabled = true
            self.backgroundColor = UIColor.colorRGBHex(hex: 0xe33e28)
        case false :
            self.isEnabled = false
            self.backgroundColor = UIColor.colorRGBHex(hex: 0xc7c9d0)
        }
    }
}

extension Int {
    public func numberToPrice(_ price : Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        let result = numberFormatter.string(from: NSNumber(value:price))!
        return result
    }
}


extension UILabel {
    func textLineSpacing(firstText : String, secondText : String?){
        let style = NSMutableParagraphStyle()
        let attrString = NSMutableAttributedString()
        style.lineSpacing = 10.0
        let first = NSAttributedString(string: firstText+"\n", attributes: [.font: UIFont(name: "NeoDunggeunmo-Regular", size: 24.0)!])
        attrString.append(first)
        
        if secondText != nil {
            let second = NSAttributedString(string: secondText!, attributes: [.font : UIFont(name: "NeoDunggeunmo-Regular", size: 24.0)!])
            attrString.append(second)
        }
        attrString.addAttributes([.paragraphStyle : style], range: NSMakeRange(0, attrString.length))
        
        self.attributedText = attrString
    }
}


extension UICollectionViewCell {
    func subImageViewSetting(imageView : UIImageView!, top : CGFloat!, left : CGFloat!, right: CGFloat!, bottom: CGFloat!){
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor,constant: top).isActive = true
        imageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: left).isActive = true
        imageView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -right).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -bottom).isActive = true
        
        imageView.contentMode = .scaleToFill
    }
}

extension UITextField {
    //TextField 왼쪽에 패딩 뷰 추가
    func addLeftPadding() {
       let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: self.frame.height))
       self.leftView = paddingView
       self.leftViewMode = ViewMode.always
     }
}


extension UIInterfaceOrientation {
    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeRight: return .landscapeRight
        case .landscapeLeft: return .landscapeLeft
        case .portrait: return .portrait
        default: return nil
        }
    }
}


extension UIColor {
    class func colorRGBHex(hex:Int, alpha: Float = 1.0) -> UIColor {
        let r = Float((hex >> 16) & 0xFF)
        let g = Float((hex >> 8) & 0xFF)
        let b = Float((hex) & 0xFF)
        return UIColor(red: CGFloat(r/255.0), green: CGFloat(g/255.0), blue:CGFloat(b/255.0), alpha : CGFloat(alpha))
    }
}


extension UIImage {
    func mergeWith(topImage: UIImage,bottomImage: UIImage) -> UIImage {
        UIGraphicsBeginImageContext(size)
        
        let areaSize = CGRect(x: 0, y: 0, width: bottomImage.size.width, height: bottomImage.size.height)
        bottomImage.draw(in: areaSize)
        
        topImage.draw(in: areaSize, blendMode: .normal, alpha: 1.0)
        
        let mergedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return mergedImage
    }
    
    func resizeImage(image: UIImage, newSize: CGSize) -> (UIImage) {
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        let context = UIGraphicsGetCurrentContext()

        // Set the quality level to use when rescaling
        context!.interpolationQuality = CGInterpolationQuality.default
        let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height )
        context!.concatenate(flipVertical)

        // Draw into the context; this scales the image
        context?.draw(image.cgImage!, in: CGRect(x: 0.0,y: 0.0, width: newRect.width, height: newRect.height))

        let newImageRef = context!.makeImage()! as CGImage
        let newImage = UIImage(cgImage: newImageRef)

        // Get the resized image from the context and a UIImage
        UIGraphicsEndImageContext()

        return newImage
    }
    
    func imageResize (sizeChange:CGSize)-> UIImage{
        let hasAlpha = true
        let scale: CGFloat = 0.0 // Use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage!
    }
    
    func cropToRect(rect: CGRect!) -> UIImage? {
        let scaledRect = CGRect(x: rect.origin.x * self.scale,
                                y: rect.origin.y * self.scale,
                                width: rect.size.width * self.scale,
                                height: rect.size.height * self.scale)
        guard let imageRef: CGImage = self.cgImage?.cropping(to:scaledRect) else { return nil }

        let croppedImage: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        return croppedImage
    }
}

extension UIView {
    public func createImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: self.frame.width, height: self.frame.height), true, 1)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}


extension UIAlertController {
    static func showMessage(_ message: String) {
        showAlert(title: "", message: message, actions: [UIAlertAction(title: "OK", style: .cancel, handler: nil)])
    }
    
    static func showAlert(title: String?, message: String?, actions: [UIAlertAction]) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            for action in actions {
                alert.addAction(action)
            }
            if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController, let presenting = navigationController.topViewController {
                presenting.present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension Date {
    func dayMonthYearFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
}



extension UIViewController{
    // imageCropVC - layoutView setting
    func setSubViewFrameSetting(view : UIView, subView : UIView, top : CGFloat, left: CGFloat, right: CGFloat, bottom : CGFloat){
        subView.translatesAutoresizingMaskIntoConstraints = false
        subView.topAnchor.constraint(equalTo: view.topAnchor, constant: top).isActive = true
        subView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: left).isActive = true
        subView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -right).isActive = true
        subView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -bottom).isActive = true
    }
    
    // imageRenderVC - imageView setting
    func setRenderImageViewFrameSetting(view: UIView, imageView : UIImageView, selectlayout : AlbumLayout){
        let top = getImageViewConstraintY(selecetedLayout: selectlayout).width
        let bottom = getImageViewConstraintY(selecetedLayout: selectlayout).height
        let distance = (selectlayout.deviceHighSize.width - imageView.frame.width) / 2
    
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: top).isActive = true
        imageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: distance).isActive = true
        imageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -distance).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -bottom).isActive = true
    }
    
    // imageRenderVC - saveView setting
    func setRenderSaveViewFrameSetting(view:UIView, selectLayout : AlbumLayout, size : CGSize){
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame.size = size
        
        let distance = (self.view.frame.width - view.frame.width) / 2
        view.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: distance).isActive = true
        view.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -distance).isActive = true
        view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: (self.view.frame.height - view.frame.height)/3).isActive = true
    }
    
    ///Identifier 찾기
    func getDeviceIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    func iPhone8Model() -> Bool {
        let identifier = self.getDeviceIdentifier()
        
        switch identifier {
        case "iPhone1,1", "iPhone1,2","iPhone2,1","iPhone3,1", "iPhone3,2", "iPhone3,3", "iPhone4,1" , "iPhone5,1", "iPhone5,2","iPhone5,3", "iPhone5,4","iPhone6,1", "iPhone6,2" , "iPhone7,2" ,"iPhone7,1","iPhone8,1","iPhone8,2","iPhone8,4","iPhone9,1", "iPhone9,3", "iPhone9,2", "iPhone9,4","x86_64"  :
            return true
        case "iPhone10,1", "iPhone10,4" ,"iPhone10,2", "iPhone10,5", "iPhone10,3", "iPhone10,6" :
            return false
        default:
            return false
        }
    }

    func getBytesFromImage(image: UIImage?) -> [UInt8]? {
        var pixelValues: [UInt8]?
        if let imageRef = image?.cgImage {
            let width = Int(imageRef.width)
            let height = Int(imageRef.height)
            let bitsPerComponent = 8
            let bytesPerRow = width * 4
            let totalBytes = height * bytesPerRow
            
            let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            var intensities = [UInt8](repeating: 0, count: totalBytes)
            
            let contextRef = CGContext(data: &intensities, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
            contextRef?.draw(imageRef, in: CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height)))
            
            pixelValues = intensities
        }
        return pixelValues!
    }
   
    
    // stickerVC, previewVC - layoutview
    func applyBackImageViewLayout(selectedLayout : AlbumLayout, smallBig: CGSize, imageView : UIImageView ) -> UIImageView {
        imageView.frame = CGRect(x: 0, y: 0, width: smallBig.width, height: smallBig.height)
        imageView.image = selectedLayout.image
        return imageView
    }
    
    // albumCreate - previewVC
    func applyImageViewLayout(selectedLayout : AlbumLayout, smallBig: CGSize, imageView : UIImageView, image : UIImage) -> UIImageView {
        var size : CGSize = CGSize(width: 0, height: 0)
        
        switch selectedLayout {
        case .Polaroid:
            size = CGSize(width: smallBig.width - 20, height: smallBig.height - 50)
            imageView.frame = CGRect(x: 10, y: 10, width: size.width, height: size.height)
        case .Mini:
            size =  CGSize(width: smallBig.width - 24, height: smallBig.height - 48)
            imageView.frame = CGRect(x: 12, y: 9, width: size.width, height: size.height)
        case .Memory:
            size = CGSize(width: smallBig.width - 48, height: smallBig.height - 52)
            imageView.frame = CGRect(x: 24, y: 26, width: size.width, height: size.height)
        case .Portrab:
            size = CGSize(width: smallBig.width - 20, height: smallBig.height - 24)
            imageView.frame = CGRect(x: 10, y: 12, width: size.width, height: size.height)
        case .Tape:
            size = CGSize(width: smallBig.width - 44, height: smallBig.height - 80)
            imageView.frame = CGRect(x: 23, y: 43, width: size.width, height: size.height)
        case .Portraw:
            size = CGSize(width: smallBig.width - 18, height: smallBig.height - 30)
            imageView.frame = CGRect(x: 9, y: 15, width: size.width, height: size.height)
        case .Filmroll:
            size = CGSize(width: smallBig.width - 68, height: smallBig.height - 6)
            imageView.frame = CGRect(x: 34, y: 3, width:size.width, height: size.height)
        }
        imageView.image = image.imageResize(sizeChange: size)
        return imageView
    }
    
    // album - Sticker - addPhoto
    func applyStickerLowDeviceImageViewLayout(selectedLayout : AlbumLayout, smallBig: CGSize, imageView : UIImageView, image : UIImage) -> UIImageView {
        var size : CGSize = CGSize(width: 0, height: 0)
        
        switch selectedLayout {
        case .Polaroid :
            size = CGSize(width: smallBig.width - 26, height: smallBig.height - 75)
            imageView.frame = CGRect(x: 13, y: 14, width: size.width, height: size.height)
        case .Mini :
            size = CGSize(width: smallBig.width - 30, height: smallBig.height - 67)
            imageView.frame = CGRect(x: 15, y: 13, width: size.width, height: size.height)
        case .Memory :
            size = CGSize(width: smallBig.width - 46, height: smallBig.height - 52)
        imageView.frame = CGRect(x: 23, y: 26, width: size.width, height: size.height)
        case .Portrab :
            size = CGSize(width: smallBig.width - 16, height: smallBig.height - 14)
            imageView.frame = CGRect(x: 8, y: 7, width: size.width, height: size.height)
        case .Tape :
            size = CGSize(width: smallBig.width - 28, height: smallBig.height - 88)
            imageView.frame = CGRect(x: 14, y: 35, width: size.width, height: size.height)
        case .Portraw :
            size = CGSize(width: smallBig.width - 6, height: smallBig.height - 18)
            imageView.frame = CGRect(x: 3, y: 9, width: size.width, height: size.height)
        case .Filmroll :
            size = CGSize(width: smallBig.width - 60, height: smallBig.height - 2)
            imageView.frame = CGRect(x: 30, y: 1, width: size.width, height: size.height)
        }
        imageView.image = image.imageResize(sizeChange: size)
        return imageView
    }
    
    // album - Sticker - addPhoto
    func applyStickerHighDeviceImageViewLayout(selectedLayout : AlbumLayout, smallBig: CGSize, imageView : UIImageView, image : UIImage) -> UIImageView {
        var size : CGSize = CGSize(width: 0, height: 0)
        
        switch selectedLayout {
        case .Polaroid:
            size = CGSize(width: smallBig.width - 40, height: smallBig.height - 87)
            imageView.frame = CGRect(x: 18, y: 26, width: size.width, height: size.height)
        case .Mini:
            size =  CGSize(width: smallBig.width - 48, height: smallBig.height - 82)
            imageView.frame = CGRect(x: 24, y: 20, width: size.width, height: size.height)
        case .Memory:
            size = CGSize(width: smallBig.width - 60, height: smallBig.height - 60)
            imageView.frame = CGRect(x: 30, y: 35, width: size.width, height: size.height)
        case .Portrab:
            size = CGSize(width: smallBig.width - 26, height: smallBig.height - 21)
            imageView.frame = CGRect(x: 13, y: 10, width: size.width, height: size.height)
        case .Tape:
            size = CGSize(width: smallBig.width - 36, height: smallBig.height - 116)
            imageView.frame = CGRect(x: 18, y: 44, width: size.width, height: size.height)
        case .Portraw:
            size = CGSize(width: smallBig.width - 14, height: smallBig.height - 28)
            imageView.frame = CGRect(x: 7, y: 14, width: size.width, height: size.height)
        case .Filmroll:
            size = CGSize(width: smallBig.width - 72, height: smallBig.height - 6)
            imageView.frame = CGRect(x: 36, y: 3, width:size.width, height: size.height)
        }
        imageView.image = image.imageResize(sizeChange: size)
        return imageView
    }
    
    // top, bottom
    func getImageViewConstraintY(selecetedLayout : AlbumLayout) -> CGSize {
        switch selecetedLayout {
        case .Polaroid: return CGSize(width: 26, height: 88)
        case .Mini: return CGSize(width: 20, height: 70) 
        case .Memory: return CGSize(width: 36, height: 38)
        case .Portrab: return CGSize(width: 16, height: 14)
        case .Tape: return CGSize(width: 44, height: 72)
        case .Portraw: return CGSize(width: 14, height: 14)
        case .Filmroll: return CGSize(width: 3, height: 3)
        }
    }
        
    func getLayoutByUid(value : Int) -> AlbumLayout{
        switch value {
        case 0 : return AlbumLayout.Polaroid
        case 1 : return AlbumLayout.Mini
        case 2 : return AlbumLayout.Memory
        case 3 : return AlbumLayout.Portrab
        case 4 : return AlbumLayout.Tape
        case 5 : return AlbumLayout.Portraw
        case 6 : return AlbumLayout.Filmroll
        default: return AlbumLayout.Polaroid
        }
    }
    
    func getCoverByUid (value : Int) -> UIImage {
        switch value {
        case 1 : return AlbumCover.Copy.image
        case 2 : return AlbumCover.Paradiso.image
        case 3 : return AlbumCover.HappilyEverAfter.image
        case 4 : return AlbumCover.FavoriteThings.image
        case 5 : return AlbumCover.AwesomeMix.image
        case 6 : return AlbumCover.LessButBetter.image
        case 7 : return AlbumCover.SretroClub.image
        case 8 : return AlbumCover.OneAndOnlyCopy.image
        default: return AlbumCover.Copy.image
        }
    }
    
    func goToRootVC(value : Int){
        let vc : [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController?.popToViewController(vc[vc.count - value], animated: true)
    }
}
