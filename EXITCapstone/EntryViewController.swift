//
//  EntryViewController.swift
//  EXITCapstone
//
//  Created by 김민국 on 2018. 7. 17..
//  Copyright © 2018년 MGHouse. All rights reserved.
//

import UIKit
import SwiftyJSON

class EntryViewController: UIViewController {

    var Information: [[String:Any]] = []
    
    @IBOutlet var progressView: UIProgressView!
    
    @IBOutlet var downloadLabel: UILabel!
    
    let dispatchGroup = DispatchGroup()
    
    @IBOutlet var naviBtnView: UIButton!
    @IBOutlet var informBtnView: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressView.progress = 0
        downloadLabel.text = "다운로드가 필요합니다."
        naviBtnView.setImage(UIImage(named: "main_button_A_click.png"), for: .highlighted)
        naviBtnView.setImage(UIImage(named: "main_button_A_click.png"), for: .selected)
        informBtnView.setImage(UIImage(named: "main_button_B_click"), for: .highlighted)
        informBtnView.setImage(UIImage(named: "main_button_B_click"), for: .selected)
        RequestOpenAPI()
    }
    
    @IBAction func goMapView(_ sender: Any) {
        if progressView.progress == 1{
            performSegue(withIdentifier: "open", sender: self)
            
        }else{
            let alert = UIAlertController(title: nil, message: "다운로드가 완료되어야 합니다.", preferredStyle: .alert)
            
            let okbtn = UIAlertAction(title: "ok", style: .default)
                
            alert.addAction(okbtn)
        }
    }
    
    func RequestOpenAPI() {
        // 요청 키 밸류
        downloadLabel.text = "다운로드 중입니다."
        if let path = Bundle.main.path(forResource: "BusanJinguAPI", ofType: "json") {
            
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let jsonObj = try JSON(data: data)
                let count: Float = Float(jsonObj["Row"].count)
                let IntCount = jsonObj["Row"].count
                let progress: Float = 1.0/count

                var sum: Float = 0.0
                
                for i in 0...IntCount - 1{
                    sum += progress
                    progressView.progress = Float(sum)
                    Information.append(jsonObj["Row"][i].dictionaryObject!)
                }
                downloadLabel.text = "다운로드 완료"
            } catch let error {
                print("parse error: \(error.localizedDescription)")
                downloadLabel.text = "다운로드 실패"
            }
        } else {
            downloadLabel.text = "다운로드 실패"
            print("Invalid filename/path.")
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "open"{
            
            let SWVC = segue.destination as? SWRevealViewController
            SWVC?.loadView()
            let mapVC = SWVC?.frontViewController as! MapViewController
            
            mapVC.APIData = Information
            
        }
    }
}
