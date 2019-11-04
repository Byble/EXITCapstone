//
//  BottomSheetViewController.swift
//  EXITCapstone
//
//  Created by 김민국 on 2018. 7. 20..
//  Copyright © 2018년 MGHouse. All rights reserved.
//

import UIKit

class BottomSheetViewController: UIViewController {
    
    var SortedAPIData: Place?
    let fullView: CGFloat = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        prepareBackgroundView()
        
        let nameField = UILabel(frame: CGRect(x: 0, y: view.frame.height*0.02, width: 300, height: 30))
        nameField.center.x = view.center.x
        nameField.textAlignment = .center
        nameField.textColor = UIColor.white
        let realName = SortedAPIData?.realName
        nameField.text = realName
        
        nameField.font = UIFont.boldSystemFont(ofSize: 25)
        self.view.addSubview(nameField)
        
        let addressField = UILabel(frame: CGRect(x: view.frame.width*0.05, y: view.frame.height * 0.1, width: 400, height: 30))
        addressField.textColor = UIColor.white
        addressField.textAlignment = .left
        addressField.numberOfLines = 0
        addressField.isUserInteractionEnabled = false
        let address = SortedAPIData?.address
        addressField.text = "주소: \(address ?? "불러 오지 못하였습니다.")"
        
        self.view.addSubview(addressField)
        
        let countField = UILabel(frame: CGRect(x: view.frame.width*0.05, y: view.frame.height * 0.2, width: 400, height: 30))
        countField.textColor = UIColor.white
        countField.textAlignment = .left
        countField.isUserInteractionEnabled = false
        let count = SortedAPIData?.count
        countField.text = "대피가능인원수: \(count ?? "0")"
        self.view.addSubview(countField)
        
        let latField = UILabel(frame: CGRect(x: view.frame.width*0.05, y: view.frame.height * 0.3, width: 400, height: 30))
        latField.textColor = UIColor.white
        latField.textAlignment = .left
        latField.isUserInteractionEnabled = false
        let lat = NSNumber(value: (SortedAPIData?.latitude)! as Double)
        latField.text = "위도: \(lat.stringValue)"
        self.view.addSubview(latField)
        
        let lonField = UILabel(frame: CGRect(x: view.frame.width*0.05, y: view.frame.height * 0.4, width: 400, height: 30))
        lonField.textColor = UIColor.white
        lonField.textAlignment = .left
        lonField.isUserInteractionEnabled = false
        let lon = NSNumber(value: (SortedAPIData?.longitude)! as Double)
        lonField.text = "경도: \(lon.stringValue)"
        self.view.addSubview(lonField)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        roundViews()
        
        UIView.animate(withDuration: 0.4, animations: { [weak self] in
            let frame = self?.view.frame
            //let yComponent = self?.partialView
            self?.view.frame = CGRect(x: 0, y: (self?.view.frame.height)!*0.5, width: frame!.width, height: frame!.height)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func roundViews() {
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
    }
    
    func prepareBackgroundView(){
        let blurEffect = UIBlurEffect.init(style: .dark)
        
        let visualEffect = UIVisualEffectView.init(effect: blurEffect)
        let bluredView = UIVisualEffectView.init(effect: blurEffect)
        bluredView.contentView.addSubview(visualEffect)
        
        visualEffect.frame = UIScreen.main.bounds
        bluredView.frame = UIScreen.main.bounds
        
        view.insertSubview(bluredView, at: 0)
    }
    
}
