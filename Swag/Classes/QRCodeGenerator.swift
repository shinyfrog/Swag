//
//  QRCodeGenerator.swift
//  Swag
//
//  Created by Matteo Rattotti on 10/05/2018.
//  Copyright © 2018 Matteo Rattotti. All rights reserved.
//

import UIKit

class QRCodeGenerator: NSObject {

    func generateQRCode(from string:String, color:UIColor, size:CGSize) -> UIImage? {
        let data = string.data(using: String.Encoding.isoLatin1)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("L", forKey: "inputCorrectionLevel") // possible values: L M Q H
            
            guard let qrCodeImage = filter.outputImage else { return nil }
            
            if let tintedQRCode = tintQRCode(image: qrCodeImage, color: color) {
                
                let scaleX = ceil(size.width / qrCodeImage.extent.size.width)
                let scaleY = ceil(size.height / qrCodeImage.extent.size.height)
                
                let trasform = CGAffineTransform(scaleX: scaleX, y: scaleY)
                let scaledQRCode = tintedQRCode.transformed(by: trasform)
                
                return UIImage(ciImage: scaledQRCode)
            }
        }
        
        return nil
    }
    
    func tintQRCode(image:CIImage, color:UIColor) -> CIImage? {
        
        if let alphaFilter = CIFilter(name: "CIMaskToAlpha") {
            alphaFilter.setValue(image, forKey: "inputImage")
            
            if let alphaQRCode = alphaFilter.outputImage {
                
                let bgFilter = CIFilter(name: "CISourceAtopCompositing")
                let background = CIImage(color: CIColor(color: color)).cropped(to: CGRect(x: 0, y: 0, width: image.extent.size.width, height: image.extent.size.height))
                
                bgFilter?.setValue(alphaQRCode, forKey: "inputImage")
                bgFilter?.setValue(background, forKey: "inputBackgroundImage")
                
                if let tintedImage = bgFilter?.outputImage {
                    return tintedImage
                }
                
            }
        }
        
        return nil
    }
}

