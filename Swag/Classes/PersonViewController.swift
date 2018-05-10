//
//  PersonViewController.swift
//  Swag
//
//  Created by Matteo Rattotti on 09/05/2018.
//  Copyright © 2018 Matteo Rattotti. All rights reserved.
//

import UIKit
import SafariServices

class PersonViewController: UIViewController, UIViewControllerPreviewingDelegate {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var qrCodeImageView: UIImageView!
    @IBOutlet var avatarImageView: UIImageView!
    var url : URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.url = URL.init(string: "http://www.shinyfrog.net")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //self.registerForPreviewing(with: self, sourceView: self.qrCodeImageView)
    }
    
    func createQRCode(string:String, color:UIColor) {
        if let image =  QRCodeGenerator().generateQRCode(from: string, color: color, size: self.qrCodeImageView.frame.size) {
            self.qrCodeImageView.image = image;
        }
    }
    
    // MARK: - UIViewControllerPreviewingDelegate
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                           viewControllerForLocation location: CGPoint) -> UIViewController? {
    
        if let website = url {
            let controller = SFSafariViewController.init(url: website)
            return controller
        }
        return nil
        
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                           commit viewControllerToCommit: UIViewController) {
        if let website = url {
            UIApplication.shared.open(website, options: [:], completionHandler: nil)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
