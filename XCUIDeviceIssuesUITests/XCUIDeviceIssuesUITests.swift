//
//  XCUIDeviceIssuesUITests.swift
//  XCUIDeviceIssuesUITests
//
//  Created by Kevin Munc on 12/13/17.
//  Copyright © 2017 Method Up. All rights reserved.
//

import Foundation
import XCTest

/**
 * **tl;dr** Why can't `XCUIDevice` be relied on to query the current orientation of an app? What is the better way? (Is there one?)
 *
 * Run this test case, and first it will fail with the orientation being reported as Portrait.
 * Run it again (and again), and it will fail with the orientation as Face Up.
 *
 * # The Problem
 *
 * When creating UI tests, it can be beneficial to know which orientation the app is in,
 * as the set of interface elements are on-screen and accessible can vary (such as with split view controllers).
 * Leveraging the `XCUIDevice` API seems like the appropriate way to manage orientation for this purpose.
 * However, while _setting_ `orientation` works, `XCUIDevice` only reports back the original orientation
 * of the appliation within the simulator window.
 *
 * __It never updates which orientation it reports as current during a test run.__
 *
 * Therefore, if a given test scenario needs to ensure it is in Portrait for the assertions to be valid,
 * that testcase is not able to query for the current orientation.
 * Further, if a test scenario needs to rotate back and forth based on other conditions for a given workflow,
 * it cannot deduce if it the device/interface are already in the required orientation.
 *
 * This original orientation will likely be Portrait if the simulator just launched
 * (even if the simulator window actually launched to a landscape orienttation itself, Springboard will be in Portrait).
 * If you manually change the orientation of the simulator, that new orientation will be reported on the next run (only).
 *
 * This produces different results for the same test code, depending on environment and (potentially) from one run to the next.
 * And this is the opposite of what you want in a test suite. Reliable repeatability is key. `XCUIDevice` does not currently provide this.
 *
 * Blindly rotating at every possible need (such as in every `setUp()` invocation for a known starting orientation) has the cost of
 * having to wait for a rotation animation to complete -- whether an animation was present or not. This is _horrible_ for test run times.
 *
 * ## Other Notes
 * - Breaking variations of this test(s) into separate methods with `launch()` instead of `activate()` has no effect.
 * - `XCUIDevice()` vs. `XCUIDevice.shared` makes no difference in the results.
 * - `UIApplication.shared.statusBarOrientation` is not accessible in a UI test (and is deprecated anyway).
 * - Registering for `NSNotification.Name.UIApplicationDidChangeStatusBarOrientation` in an XCUITest is not a viable workaround, either.
 * - It can be helpful to have simulator device bezels visible during this test.
 */
class XCUIDeviceIssuesUITests: XCTestCase {
    
    // TODO: test on actual device
    // TODO: also test iOS 10 vs 11
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = true
        XCUIApplication().activate()
        
        // Note: Without this (and with `activate()` instead of `launch()`, and no `teatDown()),
        //       repeat runs will report `faceUp` since/when it is the final issued orientation below
        //       (based on being the last test method alphabetically (in Xcode 9.2 (9C40b))).
        //       Using `launch()` instead of `activate()` will fail with `landscapeRight` (from `setUp()`) the first run through,
        //       but then fail with `faceUp` after that (and take longer for the tests to execute).
        setOrientationToKnownValue()
    }
    
    /** Note: This causes subsequent runs to always fail as `landscapeRight`.
    override func tearDown() {
        setOrientationToKnownValue()
        
        super.tearDown()
    }*/
    
    // MARK: - Orientation Tests
    
    /**
     * Only one of these will pass -- when it matches the orientation of the simulator itself.
     *
     * Rotate the simulator window, then re-run this test to get a different result.
     * This is not reliable for automated testing.
     */
    func testReportedOrientationMatchesTheIssuedOrientation() {
        XCUIDevice.shared.orientation = UIDeviceOrientation.portrait
        XCUIDevice.shared.waitForRotationToComplete()
        var result = assertCurrentOrientationIs(givenOrientation: UIDeviceOrientation.portrait)
        XCTAssertTrue(result.matched, result.failureMessage!)
        
        XCUIDevice.shared.orientation = UIDeviceOrientation.portraitUpsideDown
        XCUIDevice.shared.waitForRotationToComplete()
        result = assertCurrentOrientationIs(givenOrientation: UIDeviceOrientation.portraitUpsideDown)
        XCTAssertTrue(result.matched, result.failureMessage!)
        
        XCUIDevice.shared.orientation = UIDeviceOrientation.landscapeLeft
        XCUIDevice.shared.waitForRotationToComplete()
        result = assertCurrentOrientationIs(givenOrientation: UIDeviceOrientation.landscapeLeft)
        XCTAssertTrue(result.matched, result.failureMessage!)
        
        XCUIDevice.shared.orientation = UIDeviceOrientation.landscapeRight
        XCUIDevice.shared.waitForRotationToComplete()
        result = assertCurrentOrientationIs(givenOrientation: UIDeviceOrientation.landscapeRight)
        XCTAssertTrue(result.matched, result.failureMessage!)
        
        XCUIDevice.shared.orientation = UIDeviceOrientation.faceUp
        XCUIDevice.shared.waitForRotationToComplete()
        result = assertCurrentOrientationIs(givenOrientation: UIDeviceOrientation.faceUp)
        XCTAssertTrue(result.matched, result.failureMessage!)
        
        XCUIDevice.shared.orientation = UIDeviceOrientation.faceDown
        XCUIDevice.shared.waitForRotationToComplete()
        result = assertCurrentOrientationIs(givenOrientation: UIDeviceOrientation.faceDown)
        XCTAssertTrue(result.matched, result.failureMessage!)
    }
    
    func testEnsurePortrait() {
        XCUIDevice.shared.ensurePortrait()
        let result = assertCurrentOrientationIs(givenOrientation: UIDeviceOrientation.portrait)
        XCTAssertTrue(result.matched, result.failureMessage!)
    }
    
    func testEnsureLandscape() {
        XCUIDevice.shared.ensureLandscape()
        let result = assertCurrentOrientationIs(givenOrientation: UIDeviceOrientation.landscapeLeft)
        XCTAssertTrue(result.matched, result.failureMessage!)
    }
    
    func testEnsureMethodsInSuccession() {
        XCUIDevice.shared.ensurePortrait()
        var result = assertCurrentOrientationIs(givenOrientation: UIDeviceOrientation.portrait)
        XCTAssertTrue(result.matched, result.failureMessage!)
    
        XCUIDevice.shared.ensureLandscape()
        result = assertCurrentOrientationIs(givenOrientation: UIDeviceOrientation.landscapeLeft)
        XCTAssertTrue(result.matched, result.failureMessage!)
    }
    
    /**
     * Run this test suite, then re-run it, and the other methods will fail saying the orientation set here is the current one.
     * _Unless_ it is set to a different orientation in `tearDown()`.
     *
     * It is the last one alphabetically by test method name.
     */
    func testXYZLastMethodToExecute_causesSubsequentRunsToFailWithFaceUp() {
        XCUIDevice().orientation = UIDeviceOrientation.faceUp
        XCUIDevice().waitForRotationToComplete()
        XCTAssert(true)
    }
    
    // MARK: - Helpers
    
    /**
     * Set to a known 'clean slate' orientatioon.
     *
     * Using `landscapeRight` here to be different from `ensureLandscape()` expectation.
     * Note: Setting it redundantly to remove other odd behavior.
     */
    func setOrientationToKnownValue() {
        XCUIDevice().orientation = UIDeviceOrientation.landscapeRight
        XCUIDevice.shared.orientation = UIDeviceOrientation.landscapeRight
        XCUIDevice.shared.waitForRotationToComplete()
    }
    
    struct OrientationMatchAssertion {
        let matched: Bool
        let failureMessage: String?
    }
    
    /** Tests for equality and reports back the given orientation in the case of failure. */
    func assertCurrentOrientationIs(givenOrientation: UIDeviceOrientation, device: XCUIDevice = XCUIDevice.shared) -> OrientationMatchAssertion {
        switch device.orientation {
        case UIDeviceOrientation.portrait:
            if givenOrientation == UIDeviceOrientation.portrait {
                return OrientationMatchAssertion(matched: true, failureMessage: nil)
            } else {
                return OrientationMatchAssertion(matched: false,
                                                 failureMessage: "Orientation was unexpectedly reported as Portrait")
            }
        case UIDeviceOrientation.portraitUpsideDown:
            if givenOrientation == UIDeviceOrientation.portraitUpsideDown {
                return OrientationMatchAssertion(matched: true, failureMessage: nil)
            } else {
                return OrientationMatchAssertion(matched: false,
                                                 failureMessage: "Orientation was unexpectedly reported as Portrait Upside Down")
            }
        case UIDeviceOrientation.landscapeLeft:
            if givenOrientation == UIDeviceOrientation.landscapeLeft {
                return OrientationMatchAssertion(matched: true, failureMessage: nil)
            } else {
                return OrientationMatchAssertion(matched: false,
                                                 failureMessage: "Orientation was unexpectedly reported as Landscape Left")
            }
        case UIDeviceOrientation.landscapeRight:
            if givenOrientation == UIDeviceOrientation.landscapeRight {
                return OrientationMatchAssertion(matched: true, failureMessage: nil)
            } else {
                return OrientationMatchAssertion(matched: false,
                                                 failureMessage: "Orientation was unexpectedly reported as Landscape Right")
            }
        case UIDeviceOrientation.faceUp:
            if givenOrientation == UIDeviceOrientation.faceUp {
                return OrientationMatchAssertion(matched: true, failureMessage: nil)
            } else {
                return OrientationMatchAssertion(matched: false,
                                                 failureMessage: "Orientation was unexpectedly reported as Face Up")
            }
        case UIDeviceOrientation.faceDown:
            if givenOrientation == UIDeviceOrientation.faceDown {
                return OrientationMatchAssertion(matched: true, failureMessage: nil)
            } else {
                return OrientationMatchAssertion(matched: false,
                                                 failureMessage: "Orientation was unexpectedly reported as Face Down")
            }
        case UIDeviceOrientation.unknown:
            if givenOrientation == UIDeviceOrientation.unknown {
                return OrientationMatchAssertion(matched: true, failureMessage: nil)
            } else {
                return OrientationMatchAssertion(matched: false,
                                                 failureMessage: "Orientation was unexpectedly reported as Unknown")
            }
        }
    }
    
}
