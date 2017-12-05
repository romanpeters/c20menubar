//
//  AppDelegate.swift
//  CryptoTicker
//
//  Created by Roman Peters on 04/12/2017.
//  Copyright © 2017 Roman Peters. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var statusMenu: NSMenu!
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    let USD_rate = 0.844138304 //TODO get rate
    var NAV_price = 1.10 * 0.844138304 //TODO get rate
    let NAV_amount = //TODO get amount of NAV tokens
    
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        constructMenu()
        
        var timer = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(self.getData), userInfo: nil, repeats: true)

        
    }
    
    
    
    func getNAV() {
        let urlString = "https://www.crypto20.com/status"
        guard let url = URL(string: urlString) else { return }
        
        struct NAV: Codable {
            var nav_per_token : Double
        }
        
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            guard let jsonData = data else { return }
            
            //Implement JSON decoding and parsing
            
            do {
                //Decode retrived data with JSONDecoder and assing type of nav object
                let jsonDecoder = JSONDecoder()
                let NAVToken = try jsonDecoder.decode(NAV.self, from: jsonData)
                
                //Get back to the main queue
                DispatchQueue.main.async {
                    print(NAVToken)
                    self.NAV_price = NAVToken.nav_per_token
                }
                
            } catch let jsonError {
                print(jsonError)
            }
            }.resume()
        
        
    }
    
    @objc func getData(_ sender: Any?) {
        self.getNAV()
        
        constructMenu()
        
    }
    
    func constructMenu() {
        let menu = NSMenu()
        let NAV_EUR = NAV_price * USD_rate
        let totalString = String(format: "\u{2B21} %.0f", NAV_EUR*NAV_amount)
        
        menu.addItem(NSMenuItem(title: "NAV: €\(round(NAV_EUR*10000)/10000)", action: #selector(AppDelegate.getData(_:)), keyEquivalent: ""))
        
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(NSMenuItem(title: "Refresh", action: #selector(AppDelegate.getData(_:)), keyEquivalent: "r"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
        statusItem.title = String(format: "\u{2B21} %.0f", NAV_EUR*NAV_amount)
        

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

