//
//  BaseViewController.swift
//  Kutumblink
//
//  Created by Apple on 02/03/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController ,MPAdViewDelegate,MPInterstitialAdControllerDelegate{

    
    var adView:MPAdView! = nil
    var interstitial: MPInterstitialAdController! = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.adView = MPAdView(adUnitId: "4cab86c3f4224777a747e2e6fd963bb2", size: MOPUB_BANNER_SIZE)
       // self.adView.delegate = self
        self.adView.frame = CGRect (x: (self.view.frame.size.width-320)/2, y: self.view.frame.size.height-100, width: 320, height: 50)
        self.view.addSubview(adView)
        self.adView.loadAd()
        
 
    }
    
    func viewControllerForPresentingModalView() -> UIViewController {
        return self
    }
    @nonobjc func adViewDidLoadAd(view:MPAdView)  {
        
        let size:CGSize = view.adContentViewSize()
        let centeredX:CGFloat = (self.view.frame.size.width - size.width) / 2
        let bottomAlignedY:CGFloat = self.view.frame.size.height - (size.height+64);
        
        view.frame = CGRect (x: centeredX, y: bottomAlignedY, width: size.width, height: size.height)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func showFullScreenAds()  {
        
        interstitial = MPInterstitialAdController(forAdUnitId: "d264a0bae9ea431caf551dea8b803f96")
        self.interstitial?.delegate = self
        self.interstitial?.loadAd()
    }
    func interstitialDidLoadAd()  {
        
        interstitial.show(from: self)
    }
    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
