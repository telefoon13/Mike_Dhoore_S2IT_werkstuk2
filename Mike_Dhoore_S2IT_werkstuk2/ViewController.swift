//
//  ViewController.swift
//  Mike_Dhoore_S2IT_werkstuk2
//
//  Created by student on 22/04/18.
//  Copyright © 2018 Mike Dhoore. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "https://opendata.brussel.be/api/records/1.0/search/?dataset=opmerkelijke-bomen&rows=5")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil
            {
                print ("ERROR")
            }
            else
            {
                if let content = data
                {
                    do
                    {
                        let myJson = try JSONSerialization.jsonObject(with: content, options: [])  as? [String: Any]
                        //print (myJson)
                        if let records = myJson?["records"] as? [[String : Any]]
                        {
                            //print (records)
                            for record in records
                            {
                                if let fields = record["fields"] as? NSDictionary
                                {
                                    print(fields)
                                }
                            }
                        }
                    }
                    catch
                    {
                        //Catch error here
                    }
                }
            }
        }
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

