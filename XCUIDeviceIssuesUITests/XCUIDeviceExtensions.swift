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
 * Extension to help tests do the right thing for differences in the application interface in different orientations.
 *
 * Using fully-qualified enum values here to explicitly avoid `UIInterfaceOrientation` values.
 */
extension XCUIDevice {
    
    /**
     * Changes device orientation to _Portrait_ if it is not already in either portrait orientation.
     */
    func ensurePortrait() {
        if orientation != UIDeviceOrientation.portrait && orientation != UIDeviceOrientation.portraitUpsideDown {
            orientation = UIDeviceOrientation.portrait
            XCUIDevice().orientation = UIDeviceOrientation.portrait
            XCUIDevice.shared.orientation = UIDeviceOrientation.portrait
            waitForRotationToComplete()
        }
    }
    
    /**
     * Changes device orientation to _Landscape_ if it is not already in either landscape orientation.
     */
    func ensureLandscape() {
        if orientation != UIDeviceOrientation.landscapeLeft && orientation != UIDeviceOrientation.landscapeRight {
            orientation = UIDeviceOrientation.landscapeLeft
            XCUIDevice().orientation = UIDeviceOrientation.landscapeLeft
            XCUIDevice.shared.orientation = UIDeviceOrientation.landscapeLeft
            waitForRotationToComplete()
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
    
    // NARK: - Private Methods
    
    /** Sleep to give time for UI (and, hopefully, the proxy) to finish rotating before checking for the new value. */
    func waitForRotationToComplete() {
        let duration = (UIApplication.shared.statusBarOrientationAnimationDuration * 2.0) + 0.5 // account for 180° rotations, with buffer
        Thread.sleep(forTimeInterval: duration)
    }
    
}
