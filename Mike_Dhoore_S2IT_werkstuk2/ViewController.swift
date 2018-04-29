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
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    //make appDelegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    //Make Context for CoreData from AppDelegate
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //The map
    @IBOutlet weak var map: MKMapView!
    //Last refresh label
    @IBOutlet weak var label: UILabel!
    //Refresh button
    @IBAction func button(_ sender: Any) {
        refresh()
        //print("op knop geduwd")
    }
    //Location manager
    let manager = CLLocationManager()

    override func viewDidLoad() {
        //SUPER
        super.viewDidLoad()
        
        
        //Set map and location
        //Bron : https://www.youtube.com/watch?v=UyiuX8jULF4
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        //Get teh coredate from JSON
        getJSONtoCore()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Bron : https://www.youtube.com/watch?v=UyiuX8jULF4
        let location = locations[0]
        //Zoom niveau
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.1,0.1)
        //Center of map
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        //The region on scree,n
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation,span)
        //Add region to the map
        map.setRegion(region, animated: true)
        
        self.map.showsUserLocation = true
    }
    
    //Refresh function
    func refresh(){
        getJSONtoCore()
    }
    
    func setLastDate(){
        //Set last refresh date and time
        //Source : https://ios8programminginswift.wordpress.com/2014/08/16/get-current-date-and-time-quickcode/
        let todaysDate:Date = Date()
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        let DateInFormat:String = dateFormatter.string(from: todaysDate)
        label.text = DateInFormat
    }
    
    //Get the data from JSON and put in core data
    func getJSONtoCore() {
        
        //First clear the prevous data
        clearData()
        
        //Set the date and time from last refresh
        setLastDate()
        
        //Get new batch of data
        let url = URL(string: "https://opendata.brussel.be/api/records/1.0/search/?dataset=opmerkelijke-bomen&rows=20")
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
            //Show the data
            self.show()
        }
        task.resume()
    }
    
    //Funtion to show everything
    func show() {
        var opgehaaldeBomen:[Boom] = []
        do {
            opgehaaldeBomen = try self.managedContext.fetch(Boom.fetchRequest())
            var aantal = 0
            var aantalAdres = 0
            for elkeBoom in opgehaaldeBomen
            {
                /*print(elkeBoom.beplanting)
                print(elkeBoom.diameter_van_de_kroon)
                print(elkeBoom.gemeente)
                print(elkeBoom.hoogte)
                print(elkeBoom.id)
                print(elkeBoom.omtrek)
                print(elkeBoom.positie)
                print(elkeBoom.soort)
                print(elkeBoom.status)
                print(elkeBoom.straat)
                print("------------------------")*/
                aantal += 1
                
                if elkeBoom.straat != nil {
                    //Convert adress to location
                    //Source :https://stackoverflow.com/questions/42279252/convert-address-to-coordinates-swift
                    let geocoder = CLGeocoder()
                    let address = elkeBoom.straat! + elkeBoom.gemeente!
                    geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
                        if((error) != nil){
                            print("Error", error ?? "")
                        }
                        if let placemark = placemarks?.first {
                            let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                            //Annotation
                            let anno1 = MKPointAnnotation()
                            //info van de Annotation
                            anno1.coordinate = coordinates
                            anno1.title = elkeBoom.soort
                            //anno1.subtitle = "theSubtitle"
                            //Add anno on map
                            self.map.addAnnotation(anno1)
                        }
                        aantalAdres += 1
                    })
                }
                
            }
            print ("Er zijn total " + String(aantal) + " bomen in de db waarvan " + String(aantalAdres) + " met een adres endus een pin")
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
        
        //Remove all annotations
        //Source : https://stackoverflow.com/questions/32850094/how-do-i-remove-all-map-annotations-in-swift-2
        let allAnnotations = self.map.annotations
        self.map.removeAnnotations(allAnnotations)
        
    }

}

