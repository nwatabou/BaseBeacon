//
//  ViewController.swift
//  BaseBeacon
//
//  Created by 仲西 渉 on 2016/01/13.
//  Copyright © 2016年 nwatabou. All rights reserved.
//


import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var uuid: UILabel!
    @IBOutlet weak var major: UILabel!
    @IBOutlet weak var minor: UILabel!
    @IBOutlet weak var proximity: UILabel!
    @IBOutlet weak var accuracy: UILabel!
    @IBOutlet weak var rssi: UILabel!
    
    
    //beaconの値取得関係の変数
    var trackLocationManager : CLLocationManager!
    var beaconRegion : CLBeaconRegion!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ロケーションマネージャを作成する
        self.trackLocationManager = CLLocationManager();
        
        // デリゲートを自身に設定
        self.trackLocationManager.delegate = self;
        
        // BeaconのUUIDを設定
        let uuid:UUID? = UUID(uuidString: "00000000-7DE6-1001-B000-001C4DF13E76")
        
        //Beacon領域を作成
        self.beaconRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: "net.noumenon-th")
        
        // セキュリティ認証のステータスを取得
        let status = CLLocationManager.authorizationStatus()
        
        // まだ認証が得られていない場合は、認証ダイアログを表示
        if(status == CLAuthorizationStatus.notDetermined) {
            
            self.trackLocationManager.requestAlwaysAuthorization();
        }
        
    }
    
    
    //位置認証のステータスが変更された時に呼ばれる
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        // 認証のステータス
        let statusStr = "";
        print("CLAuthorizationStatus: \(statusStr)")
        
        
        print(" CLAuthorizationStatus: \(statusStr)")
        
        //観測を開始させる
        trackLocationManager.startMonitoring(for: self.beaconRegion)
        
    }
    
    
    
    
    //観測の開始に成功すると呼ばれる
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        
        print("didStartMonitoringForRegion");
        
        //観測開始に成功したら、領域内にいるかどうかの判定をおこなう。→（didDetermineState）へ
        trackLocationManager.requestState(for: self.beaconRegion);
    }
    
    
    
    
    //領域内にいるかどうかを判定する
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for inRegion: CLRegion) {
        
        switch (state) {
            
        case .inside: // すでに領域内にいる場合は（didEnterRegion）は呼ばれない
            
            trackLocationManager.startRangingBeacons(in: beaconRegion);
            // →(didRangeBeacons)で測定をはじめる
            break
            
        case .outside:
            
            // 領域外→領域に入った場合はdidEnterRegionが呼ばれる
            reset()
            break
            
        case .unknown:
            
            // 不明→領域に入った場合はdidEnterRegionが呼ばれる
            reset()
            break
            
        }
    }
    
    
    
    
    //領域に入った時
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        // →(didRangeBeacons)で測定をはじめる
        self.trackLocationManager.startRangingBeacons(in: self.beaconRegion)
    }
    
    
    
    
    //領域から出た時
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        //測定を停止する
        self.trackLocationManager.stopRangingBeacons(in: self.beaconRegion)
    }
    
    
    //領域内にいるので測定をする
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion){
        let beacon = beacons[0]
        
        /*
        beaconから取得できるデータ
        proximityUUID   :   regionの識別子
        major           :   識別子１
        minor           :   識別子２
        proximity       :   相対距離
        accuracy        :   精度
        rssi            :   電波強度
        */
        if(beacons.count > 0){
            if(beacon.proximity == CLProximity.immediate) {
                self.proximity.text = "Immediate"
            } else if (beacon.proximity == CLProximity.near) {
                self.proximity.text = "Near"
            } else if (beacon.proximity == CLProximity.far) {
                self.proximity.text = "Far"
            }
            self.uuid.text     = beacon.proximityUUID.uuidString
            self.major.text    = "\(beacon.major)"
            self.minor.text    = "\(beacon.minor)"
            self.accuracy.text = "\(beacon.accuracy)"
            self.rssi.text     = "\(beacon.rssi)"
        
        }else{
            reset()
        }
    }
    
    
    func reset(){
        self.uuid.text     = "none"
        self.major.text    = "none"
        self.minor.text    = "none"
        self.accuracy.text = "none"
        self.rssi.text     = "none"
        self.proximity.text = "none"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}



