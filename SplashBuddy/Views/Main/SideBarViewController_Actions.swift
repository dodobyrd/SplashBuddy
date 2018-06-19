//
//  SideBarViewController_Actions.swift
//  SplashBuddy
//
//  Created by Tyler Morgan on 6/19/18.
//  Copyright © 2018 Amaris Technologies GmbH. All rights reserved.
//

import Foundation

extension SideBarViewController {
    
    /// User pressed the continue (or restart, logout…) button
    @IBAction func pressedContinueButton(_ sender: AnyObject) {
        Preferences.sharedInstance.setupDone = true
        Preferences.sharedInstance.continueAction.pressed(sender)
    }
    
    /// sets the status label to display an error
    @objc func errorWhileInstalling() {
        Preferences.sharedInstance.errorWhileInstalling = true
        self.continueButton.isEnabled = true
        
        guard let error = SoftwareArray.sharedInstance.localizedErrorStatus else {
            return
        }
    }
    
    /// all critical software is installed
    @objc func canContinue() {
        Preferences.sharedInstance.criticalDone = true
    }
    
    /// all software is installed (failed or success)
    @objc func doneInstalling() {
        Preferences.sharedInstance.allInstalled = true
        if Preferences.sharedInstance.labMode {
        }
    }
    
    /// all software is sucessfully installed
    @objc func allSuccess() {
        Preferences.sharedInstance.allSuccessfullyInstalled = true
        self.continueButton.isEnabled = true
    }
}
