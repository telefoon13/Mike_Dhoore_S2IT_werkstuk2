//
//  ViewController.swift
//  Mike_Dhoore_S2IT_werkstuk2
//
//  Created by student on 22/04/18.
//  Copyright © 2018 Mike Dhoore. All rights reserved.
//
/*
 Gebruikte bronnen
 https://www.youtube.com/channel/UC-d1NWv5IWtIkfH47ux4dWA/videos
 https://stackoverflow.com/questions/37956720/how-to-create-managedobjectcontext-using-swift-3-in-xcode-8
 */

import UIKit
import CoreData

class ViewController: UIViewController {
    
    //make appDelegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    //Make Context for CoreData from AppDelegate
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        //SUPER
        super.viewDidLoad()
        
        getJSONtoCore()
        
    }
    
    func getJSONtoCore() {
        //First clear the prevous data
        clearData()
        
        //Get new batch of data
        let url = URL(string: "https://opendata.brussel.be/api/records/1.0/search/?dataset=opmerkelijke-bomen&rows=50")
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
                        
                        let myJson = try JSONSerialization.jsonObject(with: content, options: []) as? [String: Any]
                        //print (myJson)
                        if let records = myJson?["records"] as? [[String:Any]]
                        {
                            //print (records)
                            for record in records
                            {
                                if let fields = record["fields"] as? [String: Any]
                                {
                                    //print(fields["straat"] as? String)
                                    let boom = Boom(context: self.managedContext)
                                    
                                    boom.beplanting = (fields["beplanting"] as? String)
                                    if fields["diameter_van_de_kroon"] != nil
                                    {
                                        boom.diameter_van_de_kroon = (fields["diameter_van_de_kroon"] as! Int32)
                                    }
                                    boom.gemeente = (fields["gemeente"] as? String)
                                    boom.hoogte = (fields["hoogte"] as? String)
                                    if fields["id"] != nil
                                    {
                                        boom.id = (fields["id"] as! Int32)
                                    }
                                    if fields["omtrek"] != nil
                                    {
                                        boom.omtrek = (fields["omtrek"] as! Int32)
                                    }
                                    boom.positie = (fields["positie"] as? String)
                                    boom.soort = (fields["soort"] as? String)
                                    boom.status = (fields["status"] as? String)
                                    boom.straat = (fields["straat"] as? String)
                                    
                                
                                    self.appDelegate.saveContext()
                                    
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
            self.show()
        }
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Funtion to show everything
    func show() {
        var opgehaaldeBomen:[Boom] = []
        do {
            opgehaaldeBomen = try self.managedContext.fetch(Boom.fetchRequest())
            var aantal = 0
            for elkeBoom in opgehaaldeBomen
            {
                print(elkeBoom.straat)
                aantal += 1
            }
            //print(opgehaaldeBomen[2].straat!)
            print ("Er zijn total " + String(aantal) + " bomen in de db")
        } catch {
            fatalError("Failed to fetch : \(error)")
        }
    }

    //Function to clear the data from the database
    func clearData() {
        //Source https://cocoacasts.com/how-to-delete-every-record-of-a-core-data-entity
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Boom")
        
        // Create Batch Delete Request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try self.managedContext.execute(batchDeleteRequest)
            try self.managedContext.save()
            
        } catch {
            // Error Handling
        }
        
    }

}

