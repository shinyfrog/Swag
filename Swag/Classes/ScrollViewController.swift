//
//  ViewController.swift
//  Swag
//
//  Created by Matteo Rattotti on 09/05/2018.
//  Copyright © 2018 Matteo Rattotti. All rights reserved.
//

import UIKit

class ScrollViewController: UIViewController, UIScrollViewDelegate
{
    @IBOutlet var scrollView: UIScrollView!
    
    var personViewControllers: Array<PersonViewController>?
    var funOn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        adjustScrollView()
        scrollToPage(loadPageFromPreferences())

        personViewControllers = []
        
        for (index, person) in personsData().enumerated() {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "PersonViewController") as? PersonViewController, let view = vc.view {
                
                personViewControllers?.append(vc)
                view.frame = view.frame.offsetBy(dx: CGFloat(index) * scrollView.frame.width, dy: 0)
                self.scrollView.addSubview(view)
                
                vc.avatarImageView.image = UIImage.init(named: person["image"]!, in: nil, compatibleWith: nil)
                vc.nameLabel.text = person["name"]!.uppercased()
                vc.createQRCode(string: person["qrstring"]!, color: colorFromHEX(person["qrcolor"]!))
                
                vc.view.backgroundColor = colorFromHEX(person["bgcolor"]!)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    // MARK: - Person Data

    private func personsData() -> Array<[String:String]> {
        let data = [["name":"Matteo Rattotti",
                     "image":"matteo",
                     "qrcolor":"25734C",
                     "qrstring":"BEGIN:VCARD\nN:Rattotti;Matteo\nEMAIL:matteo.rattotti@shinyfrog.net\nEND:VCARD",
                     "bgcolor":"4AB780"],
                    ["name":"Danilo Bonardi",
                     "image":"trix180",
                     "qrcolor":"255D71",
                     "qrstring":"BEGIN:VCARD\nN:Bonardi;Danilo\nEMAIL:danilo.bonardi@shinyfrog.net\nEND:VCARD",
                     "bgcolor":"4DB0D3"],
                    ["name":"Konstantin Erokhin",
                     "image":"nerolapis",
                     "qrcolor":"A05816",
                     "qrstring":"BEGIN:VCARD\nN:Erokhin;Konstantin\nEMAIL:konstantin.erokhin@shinyfrog.net\nEND:VCARD",
                     "bgcolor":"F2B21B"],
                    ["name":"Nicola Armellini",
                     "image":"ni",
                     "qrcolor":"970E0F",
                     "qrstring":"BEGIN:VCARD\nN:Armellini;Nicola\nEMAIL:nicola.armellini@shinyfrog.net\nEND:VCARD",
                     "bgcolor":"D45455"]]
        
        return data;
    }
    
    // MARK: - Scroll paging

    private func scrollToPage(_ page: Int) {
        let pageWidth = scrollView.frame.width
        scrollView.contentOffset.x = pageWidth * CGFloat(page)
    }
    
    private func currentPage() -> Int {
        let pageWidth = scrollView.frame.width
        let page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1

        return Int(page)
    }
    
    // MARK: - Avatar rotation

    private func rotationDegreeForPage(_ page: Int) -> CGFloat {
        let pageWidth = scrollView.frame.width
        let partialOffset = scrollView.contentOffset.x - (CGFloat(page) * pageWidth)
        let percentage = partialOffset * 100 / pageWidth
        let degrees = (-percentage)
        
        return degrees
    }
    
    private func rotateAvatarView(_ view: UIImageView, degree: CGFloat) {

        view.transform = CGAffineTransform(rotationAngle: degree * (CGFloat.pi / 180))
        
        let anchorPoint = CGPoint.init(x: 0.5, y: 1.2)
        let newPoint = CGPoint.init(x:view.bounds.size.width * anchorPoint.x, y:view.bounds.size.height * anchorPoint.y);
        let oldPoint = CGPoint.init(x:view.bounds.size.width * view.layer.anchorPoint.x, y:view.bounds.size.height * view.layer.anchorPoint.y);
        newPoint.applying(view.transform)
        oldPoint.applying(view.transform)
        
        var position = view.layer.position;
        
        position.x -= oldPoint.x;
        position.x += newPoint.x;
        
        position.y -= oldPoint.y;
        position.y += newPoint.y;
        
        view.layer.position = position;
        view.layer.anchorPoint = anchorPoint;

    }
    
    // MARK: - Utils

    // Re-adjust the scroll view's content size in case the layout has changed.
    fileprivate func adjustScrollView() {
        scrollView.contentSize =
            CGSize(width: scrollView.frame.width * CGFloat(personsData().count),
                   height: scrollView.superview!.frame.height)
    }

    private func colorFromHEX(_ hex: String) -> UIColor {
        
        if let rgb = Int(hex, radix: 16) {
            let red = (rgb >> 16) & 0xFF
            let green = (rgb >> 8) & 0xFF
            let blue = rgb & 0xFF
            return UIColor.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
        }
        
        return UIColor.black
    }
    
    // MARK: - Save / Load status
    
    func savePageToPreferences(_ page: Int) {
        UserDefaults.standard.set(page, forKey: "start page")
    }

    func loadPageFromPreferences() -> Int {
        return UserDefaults.standard.integer(forKey: "start page")
    }
    
    // MARK: - UIScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let controllers = personViewControllers {
            let page = currentPage()
            let degree = rotationDegreeForPage(page)
            let slowFactor = CGFloat(0.4)

            let vc = controllers[currentPage()]
            self.view.backgroundColor = vc.view.backgroundColor
            
            rotateAvatarView(vc.avatarImageView, degree: degree * slowFactor)

            if degree < 0 && page + 1 < controllers.count {
                let nextVc = controllers[currentPage() + 1]
                let nextDegree =  CGFloat(50)
                rotateAvatarView(nextVc.avatarImageView, degree: nextDegree * slowFactor)
            }
            if degree > 0 && page > 0 {
                let nextVc = controllers[currentPage() - 1]
                let nextDegree = CGFloat(-50)
                rotateAvatarView(nextVc.avatarImageView, degree: nextDegree * slowFactor)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let feedbackGenerator = UIImpactFeedbackGenerator.init(style: UIImpactFeedbackStyle.light)
        feedbackGenerator.impactOccurred()
        savePageToPreferences(currentPage())
    }
    
    // MARK: - Fun stuff
    @IBAction func tripleTouch(sender: UIGestureRecognizer) {
        if funOn {
            for (index, vc) in personViewControllers!.enumerated() {
                vc.avatarImageView.image = UIImage.init(named: personsData()[index]["image"]!, in: nil, compatibleWith: nil)

            }
            funOn = false
        }
        else {
            var oppai = ["matteo-oppai", "trix180-oppai", "nerolapis-oppai", "ni-oppai"]
            
            for (index, vc) in personViewControllers!.enumerated() {
                vc.avatarImageView.image = UIImage.init(named: oppai[index], in: nil, compatibleWith: nil)
            }
            funOn = true
        }
    }
}


