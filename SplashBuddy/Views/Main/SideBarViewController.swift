//
//  SideBarViewController.swift
//  SplashBuddy
//
//  Created by Tyler Morgan on 6/19/18.
//  Copyright © 2018 Amaris Technologies GmbH. All rights reserved.
//

import Cocoa

class SideBarViewController: NSViewController {

    @IBOutlet weak var continueButton: NSButton!
    
    // Predicate used by Storyboard to filter which software to display
    @objc let predicate = NSPredicate(format: "displayToUser = true && canContinue = true")
    
    override func awakeFromNib() {
        // https://developer.apple.com/library/content/qa/qa1871/_index.html
        
        if self.representedObject == nil {
            self.representedObject = SoftwareArray.sharedInstance
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SideBarViewController.errorWhileInstalling),
                                               name: SoftwareArray.StateNotification.errorWhileInstalling.notification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SideBarViewController.doneInstalling),
                                               name: SoftwareArray.StateNotification.doneInstalling.notification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SideBarViewController.allSuccess),
                                               name: SoftwareArray.StateNotification.allSuccess.notification,
                                               object: nil)
        self.continueButton.title = Preferences.sharedInstance.continueAction.localizedName
        self.continueButton.isEnabled = false
    }
}
