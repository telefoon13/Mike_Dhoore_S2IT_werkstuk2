//
//  BoomDetail.swift
//  Mike_Dhoore_S2IT_werkstuk2
//
//  Created by student on 30/04/18.
//  Copyright © 2018 Mike Dhoore. All rights reserved.
//

import UIKit

class BoomDetail: UIViewController {
    
    var test:String?
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("LOADED")
        print(test)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
