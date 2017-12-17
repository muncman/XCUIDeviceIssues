//
//  XCUIDeviceExtensions.swift
//  XCUIDeviceIssuesUITests
//
//  Created by Kevin Munc on 12/13/17.
//  Copyright © 2017 Method Up. All rights reserved.
//

import XCTest

var WRAPPER_LAST_ORIENTATION_SET_VIA_XCUIDEVICE_PROXY = XCUIDevice.shared.orientation

/**
 * Extensino to help tests do the right thing for differences in the application interface in different orientations.
 * 
 * Using fully-qualified enum values here to explicitly avoid `UIInterfaceOrientation` values.
 */
extension XCUIDevice {
    
    open override func didChangeValue(forKey key: String, withSetMutation mutationKind: NSKeyValueSetMutationKind, using objects: Set<AnyHashable>) {
        print("changing key: \(key)") // TODO:
    }
    
    /**
     * Changes device orientation to _Portrait_ if it is not already in either portrait orientation.
     */
    func ensurePortrait() {
        if orientation != UIDeviceOrientation.portrait && orientation != UIDeviceOrientation.portraitUpsideDown {
            orientation = UIDeviceOrientation.portrait
            sleep(2) // Let rotation finish.
        }
    }
    
    /**
     * Changes device orientation to _Landscape_ if it is not already in either landscape orientation.
     */
    func ensureLandscape() {
        if orientation != UIDeviceOrientation.landscapeLeft && orientation != UIDeviceOrientation.landscapeRight {
            orientation = UIDeviceOrientation.landscapeLeft
            sleep(2) // Let rotation finish.
        }
    }
    
    /**
     * Reports if the current device orientation is in either portrait orientation.
     */
    func isPortraity() -> Bool {
        if orientation != UIDeviceOrientation.portrait && orientation != UIDeviceOrientation.portraitUpsideDown {
            return true
        }
        return false
    }
    
    /**
     * Reports if the current device orientation is in either landscape orientation.
     */
    func isLandscapey() -> Bool {
        if orientation != UIDeviceOrientation.landscapeLeft && orientation != UIDeviceOrientation.landscapeRight {
            return true
        }
        return false
    }
    
    /**
     * Reports if the current device orientation matches the given orientation.
     */
    func isOrientationSame(as otherOrientation: UIDeviceOrientation) -> Bool {
        return orientation == otherOrientation
    }
    
}
