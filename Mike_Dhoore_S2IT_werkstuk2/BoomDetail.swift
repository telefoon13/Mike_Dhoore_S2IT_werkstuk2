//
//  BoomDetail.swift
//  Mike_Dhoore_S2IT_werkstuk2
//
//  Created by student on 30/04/18.
//  Copyright © 2018 Mike Dhoore. All rights reserved.
//

import UIKit

class BoomDetail: UIViewController {
    
    var boom:Boom?
    
    @IBOutlet weak var boomIdLbl: UILabel!
    @IBOutlet weak var boomSoortLbl: UILabel!
    @IBOutlet weak var boomAdresLbl: UILabel!
    @IBOutlet weak var boomLandschapLbl: UILabel!
    @IBOutlet weak var boomPositieLbl: UILabel!
    @IBOutlet weak var boomBeplantingLbl: UILabel!
    @IBOutlet weak var boomStatusLbl: UILabel!
    @IBOutlet weak var boomOmtrekLbl: UILabel!
    @IBOutlet weak var boomHoogteLbl: UILabel!
    @IBOutlet weak var boomDiameterLbl: UILabel!
    let isLeeg:String = "Onbekend"
    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var idLbl: UILabel!
    @IBOutlet weak var soortLbl: UILabel!
    @IBOutlet weak var adresLbl: UILabel!
    @IBOutlet weak var landschapLbl: UILabel!
    @IBOutlet weak var positieLbl: UILabel!
    @IBOutlet weak var beplantingLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var omtrekLbl: UILabel!
    @IBOutlet weak var hoogteLbl: UILabel!
    @IBOutlet weak var diameterLbl: UILabel!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Vertalingen
        navBar.title = NSLocalizedString("detailBoom", comment: "")
        idLbl.text = NSLocalizedString("id", comment: "")
        soortLbl.text = NSLocalizedString("soort", comment: "")
        adresLbl.text = NSLocalizedString("adres", comment: "")
        landschapLbl.text = NSLocalizedString("landschap", comment: "")
        positieLbl.text = NSLocalizedString("positie", comment: "")
        beplantingLbl.text = NSLocalizedString("beplanting", comment: "")
        statusLbl.text = NSLocalizedString("status", comment: "")
        omtrekLbl.text = NSLocalizedString("omtrek", comment: "")
        hoogteLbl.text = NSLocalizedString("hoogte", comment: "")
        diameterLbl.text = NSLocalizedString("diameterKroon", comment: "")
        
        
//Vul de labels met de gegevens van de boom
        if boom?.id != nil
        {
            boomIdLbl.text = boom?.id.description
        } else {
            boomIdLbl.text = isLeeg
        }
        
        if boom?.soort != nil
        {
            boomSoortLbl.text = boom?.soort
        } else {
            boomSoortLbl.text = isLeeg
        }
        
        if boom?.straat != nil && boom?.gemeente != nil
        {
            boomAdresLbl.text = (boom?.straat)! + " " + (boom?.gemeente)!
        } else {
            boomAdresLbl.text = isLeeg
        }
        
        if boom?.landschap != nil
        {
            boomLandschapLbl.text = boom?.landschap
        } else {
            boomLandschapLbl.text = isLeeg
        }
        
        if boom?.positie != nil
        {
            boomPositieLbl.text = boom?.positie
        } else {
            boomPositieLbl.text = isLeeg
        }
        
        if boom?.beplanting != nil
        {
            boomBeplantingLbl.text = boom?.beplanting
        } else {
            boomBeplantingLbl.text = isLeeg
        }
        
        if boom?.status != nil
        {
            boomStatusLbl.text = boom?.status
        } else {
            boomStatusLbl.text = isLeeg
        }
        
        if boom?.omtrek != nil
        {
            boomOmtrekLbl.text = (boom?.omtrek.description)! + " m"
        } else {
            boomOmtrekLbl.text = isLeeg
        }
        
        if boom?.hoogte != nil
        {
            boomHoogteLbl.text = (boom?.hoogte)! + " m"
        } else {
            boomHoogteLbl.text = isLeeg
        }
        
        if boom?.diameter_van_de_kroon != nil
        {
            boomDiameterLbl.text = (boom?.diameter_van_de_kroon.description)! + " m"
        } else {
            boomDiameterLbl.text = isLeeg
        }
        
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
