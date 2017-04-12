//
//  AdsViewController.swift
//  Kutumblink
//
//  Created by Ramesh on 3/7/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit


class AdsViewController: UIViewController,MPInterstitialAdControllerDelegate{

    var interstitial: MPInterstitialAdController! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        interstitial = MPInterstitialAdController(forAdUnitId: "3aba0056add211e281c11231392559e4")
        //self.interstitial?.view.backgroundColor = UIColor.red
        self.interstitial?.delegate = self
        // Pre-fetch the ad up front
        self.interstitial?.loadAd()
        //        interstitial.show(from: self)
        self.view.addSubview(self.interstitial.view)
        
    }
    

    func levelDidEnd()  {
        if (interstitial.ready) {
            interstitial.show(from: self)
        }
    }
    func interstitialDidLoadAd()  {
        
         interstitial.show(from: self)
    }
//    func interstitialDidLoadAd(interstitial: MPInterstitialAdController) {
//        // This sample automatically shows the ad as soon as it's loaded, but
//        // you can move this showFromViewController call to a time more
//        // appropriate for your app.
//        if (interstitial.ready) {
//            interstitial.show(from: self)
//        }
//    }
    func interstitialDidFailToLoadAd(interstitial: MPInterstitialAdController) {
    }
    func interstitialWillAppear(interstitial: MPInterstitialAdController) {
    }
    func interstitialDidAppear(interstitial: MPInterstitialAdController) {
    }
    func interstitialWillDisappear(interstitial: MPInterstitialAdController) {
    }
    func interstitialDidDisappear(interstitial: MPInterstitialAdController) {
    }
    func interstitialDidExpire(interstitial: MPInterstitialAdController) {
    }
    func interstitialDidReceiveTapEvent(interstitial: MPInterstitialAdController) {
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
