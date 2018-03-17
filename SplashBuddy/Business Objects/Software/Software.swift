//
//  Software.swift
//  SplashBuddy
//
//  Copyright © 2018 Amaris Technologies GmbH. All rights reserved.
//

import Cocoa

/**
 Object that will hold the definition of a software.
 
 The goal here is to:
 1. Create a Software object from the plist (MacAdmin supplied Software)
 2. Parse the log and either:
    - Modify the Software object (if it already exists)
    - Create a new Software object.
 
 */

@objc
class Software: NSObject {

    // MARK: - Properties

    /**
     Status of the software.
     Default is .pending, other cases will be set while parsing the log
     */
    @objc
    enum SoftwareStatus: Int {
        case installing = 0
        case success = 1
        case failed = 2
        case pending = 3
    }

    @objc dynamic var packageName: String
    @objc dynamic var packageVersion: String?
    @objc dynamic var status: SoftwareStatus
    @objc dynamic var icon: NSImage?
    @objc dynamic var iconography = [Int: NSImage]()
    @objc dynamic var displayName: String?
    @objc dynamic var desc: String?
    @objc dynamic var canContinue: Bool
    @objc dynamic var displayToUser: Bool

    // MARK: - Constants

    private enum CodingKeys: String {
        case name
        case displayName
        case description
        case iconRelativePath
        case iconography
        case canContinue
    }

    // MARK: - Initialization

    init?(from dictionary: [String: Any]) {
        guard let packageName = dictionary[CodingKeys.name.rawValue] as? String else {
            Log.write(string: "Error reading name from an application in io.fti.SplashBuddy", cat: "Preferences", level: .error)
            return nil
        }

        self.packageName = packageName
        self.status = .pending

        if let displayName = dictionary[CodingKeys.displayName.rawValue] as? String {
            self.displayName = displayName
        } else {
            Log.write(string: "Error reading displayName from application \(packageName) in io.fti.SplashBuddy", cat: "Preferences", level: .fault)
        }

        if let description = dictionary[CodingKeys.description.rawValue] as? String {
            self.desc = description
        } else {
            Log.write(string: "Error reading description from application \(packageName) in io.fti.SplashBuddy", cat: "Preferences", level: .fault)
        }

        if let iconRelativePath = dictionary[CodingKeys.iconRelativePath.rawValue] as? String, !iconRelativePath.isEmpty {
            let absolutePath = Preferences.sharedInstance.assetPath.appendingPathComponent(iconRelativePath).path
            self.icon = NSImage(contentsOfFile: absolutePath)
        } else {
            Log.write(string: "Error reading iconRelativePath from application \(packageName) in io.fti.SplashBuddy", cat: "Preferences", level: .fault)
            self.icon = NSImage(named: NSImage.Name.folder)
        }

        // Populate iconography from dictionary of icons
        if let iconography = dictionary[CodingKeys.iconography.rawValue] as? [Int: String] {
            for currentIconography in iconography {
                // Check that the current key exists as a SoftwareStatus
                if SoftwareStatus(rawValue: currentIconography.key) != nil {
                    let absolutePath = Preferences.sharedInstance.assetPath.appendingPathComponent(currentIconography.value).path
                    self.iconography[currentIconography.key] = NSImage(contentsOfFile: absolutePath)
                }
            }
        }

        if let canContinue = dictionary[CodingKeys.canContinue.rawValue] as? Bool {
            self.canContinue = canContinue
        } else {
            self.canContinue = true
            Log.write(string: "Error reading canContinue from application \(packageName) in io.fti.SplashBuddy", cat: "Preferences", level: .error)
        }

        displayToUser = false

        super.init()
    }

    /**
     Manually initializes a Software Object
     
     - note: Only packageName is required to parse, displayName, description and displayToUser will have to be set later to properly show it on the GUI.

     - parameter packageName: *packageName*-packageVersion.pkg
     - parameter version: Optional
     - parameter iconPath: Optional
     - parameter displayName: Name displayed to user
     - parameter description: Second line underneath name
     - parameter canContinue: if set to false, the Software will block the "Continue" button until installed
     - parameter displayToUser: set to True to display in GUI
     */

    init(packageName: String,
         version: String? = nil,
         status: SoftwareStatus = .pending,
         iconPath: String? = nil,
         displayName: String? = nil,
         description: String? = nil,
         canContinue: Bool = true,
         displayToUser: Bool = false) {

        self.packageName = packageName
        self.packageVersion = version
        self.status = status
        self.canContinue = canContinue
        self.displayToUser = displayToUser
        self.displayName = displayName
        self.desc = description

        if let iconPath = iconPath {
            self.icon = NSImage(contentsOfFile: iconPath)
        } else {
            self.icon = NSImage(named: NSImage.Name.folder)
        }
    }

    /**
     Initializes a Software Object from a String
     
     - note: Only packageName is required to parse, displayName, description and displayToUser will have to be set later to properly show it on the GUI.
     
     - parameter packageName: *packageName*-packageVersion.pkg
     - parameter version: Optional
     - parameter iconPath: Optional
     - parameter displayName: Name displayed to user
     - parameter description: Second line underneath name
     - parameter canContinue: if set to false, the Software will block the "Continue" button until installed
     - parameter displayToUser: set to True to display in GUI
     */
    convenience init?(from line: String) {

        var name: String?
        var version: String?
        var status: SoftwareStatus?

        for (regexStatus, regex) in initRegex() {
            status = regexStatus

            let matches = regex!.matches(in: line, options: [], range: NSRange(location: 0, length: line.count))

            if !matches.isEmpty {
                name = (line as NSString).substring(with: matches[0].range(at: 1))
                version = (line as NSString).substring(with: matches[0].range(at: 2))
                break
            }
        }

        if let packageName = name, let packageVersion = version, let packageStatus = status {
            self.init(packageName: packageName, version: packageVersion, status: packageStatus)
        } else {
            return nil
        }
    }

}

func == (lhs: Software, rhs: Software) -> Bool {
    return lhs.packageName == rhs.packageName && lhs.packageVersion == rhs.packageVersion && lhs.status == rhs.status
}
