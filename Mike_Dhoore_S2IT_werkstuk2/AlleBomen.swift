//
//  ViewController.swift
//  Mike_Dhoore_S2IT_werkstuk2
//
//  Created by student on 22/04/18.
//  Copyright © 2018 Mike Dhoore. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import CoreLocation

class AlleBomen: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    //make appDelegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    //Make Context for CoreData from AppDelegate
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //The map
    @IBOutlet weak var map: MKMapView!
    //Last refresh label
    @IBOutlet weak var label: UILabel!
    //Navigatie Bar
    @IBOutlet weak var navBar: UINavigationItem!
    //Tekst label "laats bijgewerkt"
    @IBOutlet weak var txtLastLbl: UILabel!
    //Last time refreshed
    var lastRefresh:Date?
    //Refresh button
    @IBOutlet weak var reloadButton: UIButton!
    //Refresh button action
    @IBAction func button(_ sender: Any) {
        //Bron : https://stackoverflow.com/questions/39018335/swift-3-comparing-date-objects
        let nuMin = Date().addingTimeInterval(-60)
        if (lastRefresh! < nuMin){
            refresh()
        } else {
            //popup tonen
            //Bron : https://stackoverflow.com/questions/24022479/how-would-i-create-a-uialertview-in-swift
            // create the alert
            let alert = UIAlertController(title: NSLocalizedString("herlaadGegevens", comment: ""), message: NSLocalizedString("alert", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
    //Location manager
    let manager = CLLocationManager()
    //Selected tree
    var geselecteerdeBoom:BoomPin?

    
    //Functie die aangeroepen word wanneer de view geladen is
    override func viewDidLoad() {
        //SUPER
        super.viewDidLoad()
        
        self.map.delegate = self
        
        //Navigatiebar invullen
        navBar.title = NSLocalizedString("alleBomen", comment: "")
        //bron : https://stackoverflow.com/questions/28471164/how-to-set-back-button-text-in-swift
        let backItem = UIBarButtonItem()
        backItem.title = NSLocalizedString("terug", comment: "")
        navBar.backBarButtonItem = backItem
        //Laatsbijgewerkt lbl
        txtLastLbl.text = NSLocalizedString("laatstBijgewerkt", comment: "")
        //Knop vertaling
        reloadButton.setTitle(NSLocalizedString("herlaadGegevens", comment: ""), for: .normal)
        
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
    
    
    //Functie om min locatie te tonen en te centreren
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
    
    
    
    //Functie om de refresh datum te generenen en te tonen
    func setLastDate(){
        //Set last refresh date and time
        //Source : https://ios8programminginswift.wordpress.com/2014/08/16/get-current-date-and-time-quickcode/
        lastRefresh = Date()
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        let DateInFormat:String = dateFormatter.string(from: lastRefresh!)
        label.text = DateInFormat
    }
    
    
    
    
    //Functie om de JSON op te halen en deze in de Core Date te steken
    func getJSONtoCore() {
        
        //Disable refresh button
        self.reloadButton.isEnabled = false
        
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
                                    boom.landschap = (fields["landschap"] as? String)
                                    
                                    if boom.straat != nil && boom.gemeente != nil{
                                        self.appDelegate.saveContext()
                                    }
                                    
                                }
                                
                            }
                        }
                    }
                    catch
                    {
                        print ("Catch error here")
                    }
                }
            }
            DispatchQueue.main.async {
                //Show the data
                self.show()
            }
        }
        task.resume()
    }
    
    
    
    //Functie om alles op UI te tonen (Adres omzetten naar cordinaat en pinnen toevoegen)
    func show() {
        var opgehaaldeBomen:[Boom] = []
        do {
            opgehaaldeBomen = try self.managedContext.fetch(Boom.fetchRequest())
            for elkeBoom in opgehaaldeBomen
            {
                if elkeBoom.straat != nil && elkeBoom.gemeente != nil {
                    //Convert adress to location
                    //Source :https://stackoverflow.com/questions/42279252/convert-address-to-coordinates-swift
                    let geocoder = CLGeocoder()
                    let address = elkeBoom.straat! + elkeBoom.gemeente!
                    geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
                        if((error) != nil){
                            print("Error(Locatie kan niet bepaald worden)", error ?? "")
                        }
                        if let placemark = placemarks?.first {
                            let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                            //Annotation
                            let anno1 = BoomPin()
                            //info van de Annotation
                            anno1.coordinate = coordinates
                            var splitSoort = elkeBoom.soort?.components(separatedBy: "\n")
                            anno1.title = splitSoort?[0]
                            if ((splitSoort?.count)! > 1){
                                anno1.subtitle = splitSoort?[1]
                            }
                            
                            anno1.boom = elkeBoom
                            //Bron :https://marketplace.visualstudio.com/items?itemName=Gruntfuggly.todo-tree
                            anno1.image = "BoomPin"
                            
                            DispatchQueue.main.async {
                                //Add anno on map
                                self.map.addAnnotation(anno1)
                            }
                        }
                    })
                }
                self.reloadButton.isEnabled = true
            }
        } catch {
            fatalError("Failed to fetch : \(error)")
        }
    }
    
    
    
    //Functie om "I" knop aan anotatie toe tevoegen om op te klikken + custom image te gebruiken ipv standaard pin
    //Bron : https://stackoverflow.com/questions/40478120/mkannotationview-swift-adding-info-button
    //Bron : https://stackoverflow.com/questions/41800302/how-to-set-custom-pin-image-in-mapview-swift-ios
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        let annotationIdentifier = "Identifier"
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        if let annotationView = annotationView {
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "smallTree")
        }
        return annotationView
    }
    
    
    
    //Functie die de segue aanroept wanneer er op een "I" knop word geduwd van een annotatie
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            
            //print(view.annotation?.title)
            performSegue(withIdentifier: "toDetail", sender: view)
        }
    }
    
    
    
    
    //Functie om de segue uit te voeren
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toDetail"){
            if let nextVC = segue.destination as? BoomDetail{
                //let test = "OK?"
                nextVC.boom = geselecteerdeBoom?.boom
            }
        }
        
    }
    
    
    
    
    //Functie om de gegevens te krijgen van de geslecteerde annotatie
    //Bron : https://stackoverflow.com/questions/39206418/how-can-i-detect-which-annotation-was-selected-in-mapview
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.geselecteerdeBoom = view.annotation as? BoomPin
    }

    
    
    //Functie om de coredata leeg te maken en alle annotaties te verwijderen
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

