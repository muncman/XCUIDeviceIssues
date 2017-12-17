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
 * It can be helpful to have simulator device bezels visible during this test.
 *
 * Sleeping 2 seconds after invoking orientation changes to give time for UI (and, hopefully, the proxy) to update.
 */
class XCUIDeviceIssuesUITests: XCTestCase {
    
    var originalOrientation = XCUIDevice.shared.orientation
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = true
        XCUIApplication().activate()
        // Set initial orientation
        // TODO: clean up, see if this even helps...
        XCUIDevice().orientation = UIDeviceOrientation.landscapeLeft // TEST: is this working?
        XCUIDevice.shared.orientation = UIDeviceOrientation.landscapeLeft // Just to be thorough.
        sleep(2) // Wait for any rotation to complete.
    }
    
    override func tearDown() {
        XCUIDevice().orientation = originalOrientation
        XCUIDevice.shared.orientation = originalOrientation
        sleep(2)
        
        super.tearDown()
    }
    
    // MARK: - The Primary Issue
    
    /**
     * Only one of these will pass -- when it matches the orientation of the simulator itself.
     *
     * Rotate the simulator window, then re-run this test to get a different result.
     * This is not reliable for automated testing.
     *
     * Note that _setting_ `orientation` works, rotating the UI within the simulator.
     * But then `XCUIDevice` reports the orientation of the simulator window itself, which does not match the simulated device.
     *
     * Also note that portrait is still reported if the sim window chrome is in landscape but the Springboard is in Portrait
     * (such as when the sim was just launched into landscape (from prior run) and not manually rotated).
     *
     * Breaking these into separate test methods with `launch()` instead of `activate()` has no effect.
     * `XCUIDevice()` vs. `XCUIDevice.shared` makes no difference in the results.
     */
    func testReportedOrientationMatchesTheIssuedOrientation() {
        // FIXME: test on actual device
        // TODO: also test iOS 10 vs 11
        // TODO: XCUIApplication().statusBars.firstMatch.orientation
        // FIXME: or is it the test-launch-time interface orientation?!!?
        // Note: Only using `shared` hook here.
        XCUIDevice.shared.orientation = UIDeviceOrientation.portrait
        sleep(2)
        var result = assertCurrentOrientationIs(givenOrientation: UIDeviceOrientation.portrait)
        XCTAssertTrue(result.matched, result.failureMessage!)
        
        XCUIDevice.shared.orientation = UIDeviceOrientation.portraitUpsideDown
        sleep(2)
        result = assertCurrentOrientationIs(givenOrientation: UIDeviceOrientation.portraitUpsideDown)
        XCTAssertTrue(result.matched, result.failureMessage!)
        
        XCUIDevice.shared.orientation = UIDeviceOrientation.landscapeLeft
        sleep(2)
        result = assertCurrentOrientationIs(givenOrientation: UIDeviceOrientation.landscapeLeft)
        XCTAssertTrue(result.matched, result.failureMessage!)
        
        XCUIDevice.shared.orientation = UIDeviceOrientation.landscapeRight
        sleep(2)
        result = assertCurrentOrientationIs(givenOrientation: UIDeviceOrientation.landscapeRight)
        XCTAssertTrue(result.matched, result.failureMessage!)
        
        XCUIDevice.shared.orientation = UIDeviceOrientation.faceUp
        sleep(2)
        result = assertCurrentOrientationIs(givenOrientation: UIDeviceOrientation.faceUp)
        XCTAssertTrue(result.matched, result.failureMessage!)
        
        XCUIDevice.shared.orientation = UIDeviceOrientation.faceDown
        sleep(2)
        result = assertCurrentOrientationIs(givenOrientation: UIDeviceOrientation.faceDown)
        XCTAssertTrue(result.matched, result.failureMessage!)
    }
    
    func testReportedOrientationMatchesTheIssuedOrientation_withNewProxy() {
        XCUIDevice.shared.orientation = UIDeviceOrientation.portrait
        sleep(3)
        var result = assertCurrentOrientationIs(givenOrientation: UIDeviceOrientation.portrait, device: XCUIDevice())
        XCTAssertTrue(result.matched, result.failureMessage!)
        
        XCUIDevice.shared.orientation = UIDeviceOrientation.portraitUpsideDown
        sleep(3)
        result = assertCurrentOrientationIs(givenOrientation: UIDeviceOrientation.portraitUpsideDown, device: XCUIDevice())
        XCTAssertTrue(result.matched, result.failureMessage!)
        
        XCUIDevice.shared.orientation = UIDeviceOrientation.landscapeLeft
        sleep(3)
        result = assertCurrentOrientationIs(givenOrientation: UIDeviceOrientation.landscapeLeft, device: XCUIDevice())
        XCTAssertTrue(result.matched, result.failureMessage!)
        
        XCUIDevice.shared.orientation = UIDeviceOrientation.landscapeRight
        sleep(3)
        result = assertCurrentOrientationIs(givenOrientation: UIDeviceOrientation.landscapeRight, device: XCUIDevice())
        XCTAssertTrue(result.matched, result.failureMessage!)
        
        XCUIDevice.shared.orientation = UIDeviceOrientation.faceUp
        sleep(3)
        result = assertCurrentOrientationIs(givenOrientation: UIDeviceOrientation.faceUp, device: XCUIDevice())
        XCTAssertTrue(result.matched, result.failureMessage!)
        
        XCUIDevice.shared.orientation = UIDeviceOrientation.faceDown
        sleep(3)
        result = assertCurrentOrientationIs(givenOrientation: UIDeviceOrientation.faceDown, device: XCUIDevice())
        XCTAssertTrue(result.matched, result.failureMessage!)
    }
    
    func testTwoStepWithLaunchBetween_stepOne() {
        XCUIApplication().launch()
        XCUIDevice.shared.orientation = UIDeviceOrientation.landscapeRight
        sleep(2)
        let result = assertCurrentOrientationIs(givenOrientation: UIDeviceOrientation.landscapeRight, device: XCUIDevice())
        XCTAssertTrue(result.matched, result.failureMessage!)
    }
    
    func testTwoStepWithLaunchBetween_stepTwo() {
        XCUIApplication().launch()
        XCUIDevice.shared.orientation = UIDeviceOrientation.portraitUpsideDown
        sleep(2)
        let result = assertCurrentOrientationIs(givenOrientation: UIDeviceOrientation.portraitUpsideDown, device: XCUIDevice())
        XCTAssertTrue(result.matched, result.failureMessage!)
    }
    
    // MARK: - Orientation Tests
    
    func testCurrentOrientationDetection_viaNew() {
        let first = XCUIDevice().orientation
        let second = XCUIDevice().orientation
        
        XCTAssertEqual(first, second)
    }
    
    func testCurrentOrientationDetection_viaShared() {
        let first = XCUIDevice.shared.orientation
        let second = XCUIDevice.shared.orientation
        
        XCTAssertEqual(first, second)
    }
    
    func testCurrentOrientationDetection_sharedVsNew() {
        let fromNew = XCUIDevice().orientation
        let fromShared = XCUIDevice.shared.orientation
        
        XCTAssertEqual(fromNew, fromShared)
    }
    
    func testSameOrientationReported_afterUpdating_viaNew() {
        XCUIDevice().orientation = UIDeviceOrientation.faceDown
        sleep(2)
        let fromNew = XCUIDevice().orientation
        let fromShared = XCUIDevice.shared.orientation
        
        XCTAssertEqual(fromNew, fromShared)
    }
    
    func testSameOrientationReported_afterUpdating_viaShared() {
        XCUIDevice.shared.orientation = UIDeviceOrientation.faceDown
        sleep(2)
        let fromNew = XCUIDevice().orientation
        let fromShared = XCUIDevice.shared.orientation
        
        XCTAssertEqual(fromNew, fromShared)
    }
    
    func testSameOrientationReported_afterUpdatingBoth_toDifferentValues() {
        XCUIDevice().orientation = UIDeviceOrientation.faceDown
        sleep(2)
        XCUIDevice.shared.orientation = UIDeviceOrientation.portraitUpsideDown
        sleep(2)
        let fromNew = XCUIDevice().orientation
        let fromShared = XCUIDevice.shared.orientation
        
        XCTAssertEqual(fromNew, fromShared)
    }
    
    func testSameOrientationReported_afterUpdating_viaSavedReference() {
        // Only using non-shared reference here.
        let expectedOrientation = UIDeviceOrientation.landscapeRight
        let deviceProxy = XCUIDevice()
        deviceProxy.orientation = expectedOrientation
        sleep(2)
        
        let result = assertCurrentOrientationIs(givenOrientation: expectedOrientation, device: deviceProxy)
        XCTAssertTrue(result.matched, result.failureMessage!)
    }
    
    // TODO: are these good once it all passes?
    
    func testSameOrientationReported_isNotPortraitWhenItShouldNotBe_viaNew() {
        XCUIDevice().orientation = UIDeviceOrientation.faceDown
        sleep(2)
        
        XCTAssertNotEqual(XCUIDevice().orientation, UIDeviceOrientation.portrait,
                          "The simulator window itself must not be in portrait orientation (regardless of app interface orientation)")
    }
    
    func testSameOrientationReported_isNotPortraitWhenItShouldNotBe_viaShared() {
        XCUIDevice.shared.orientation = UIDeviceOrientation.faceDown
        sleep(2)
        
        XCTAssertNotEqual(XCUIDevice.shared.orientation, UIDeviceOrientation.portrait,
                          "The simulator window itself must not be in portrait orientation (regardless of app interface orientation)")
    }
    
    func testUpdatingOrientation_viaNew() {
        let expectedOrientation = UIDeviceOrientation.faceDown
        XCUIDevice().orientation = expectedOrientation
        sleep(2)
        
        let result = assertCurrentOrientationIs(givenOrientation: expectedOrientation, device: XCUIDevice())
        XCTAssertTrue(result.matched, result.failureMessage!)
    }
    
    func testUpdatingOrientation_viaShared() {
        let expectedOrientation = UIDeviceOrientation.faceDown
        XCUIDevice.shared.orientation = expectedOrientation
        sleep(2)
        
        let result = assertCurrentOrientationIs(givenOrientation: expectedOrientation, device: XCUIDevice.shared)
        XCTAssertTrue(result.matched, result.failureMessage!)
    }
    
    func testStraightEqualityCheckSucceeds() {
        XCTAssertEqual(UIDeviceOrientation.landscapeLeft, UIDeviceOrientation.landscapeLeft)
        XCTAssertTrue(UIDeviceOrientation.landscapeLeft == UIDeviceOrientation.landscapeLeft)
        XCTAssertEqual(UIDeviceOrientation.unknown, .unknown,
                       "Should be save to use either fully-qualified or non-fully-qualified enum references")
    }
    
    func testUpdatingAndComparingOrientation_viaNew() {
        let expectedOrientation = UIDeviceOrientation.portraitUpsideDown
        XCUIDevice().orientation = expectedOrientation
        sleep(2)
        let result = assertCurrentOrientationIs(givenOrientation: expectedOrientation)
        XCTAssertTrue(result.matched, result.failureMessage!)
        
        // Change again
        let changedOrientation = UIDeviceOrientation.landscapeRight
        XCUIDevice().orientation = changedOrientation
        sleep(2)
        let changedResult = assertCurrentOrientationIs(givenOrientation: changedOrientation)
        XCTAssertTrue(changedResult.matched, changedResult.failureMessage!)
    }
    
    func testUpdatingAndComparingOrientation_viaShared() {
        let expectedOrientation = UIDeviceOrientation.portraitUpsideDown
        XCUIDevice.shared.orientation = expectedOrientation
        sleep(2)
        let result = assertCurrentOrientationIs(givenOrientation: expectedOrientation)
        XCTAssertTrue(result.matched, result.failureMessage!)
        
        // Change again
        let changedOrientation = UIDeviceOrientation.landscapeRight
        XCUIDevice.shared.orientation = changedOrientation
        sleep(2)
        let changedResult = assertCurrentOrientationIs(givenOrientation: changedOrientation)
        XCTAssertTrue(changedResult.matched, changedResult.failureMessage!)
    }
    
    func testUpdatingAndComparingOrientation_viaReusedReference_viaNew() {
        let deviceProxy = XCUIDevice()
        let expectedOrientation = UIDeviceOrientation.portraitUpsideDown
        deviceProxy.orientation = expectedOrientation
        sleep(2)
        let result = assertCurrentOrientationIs(givenOrientation: expectedOrientation)
        XCTAssertTrue(result.matched, result.failureMessage!)
        
        // Change again
        let changedOrientation = UIDeviceOrientation.landscapeRight
        deviceProxy.orientation = changedOrientation
        sleep(2)
        let changedResult = assertCurrentOrientationIs(givenOrientation: changedOrientation, device: deviceProxy)
        XCTAssertTrue(changedResult.matched, changedResult.failureMessage!)
    }
    
    func testUpdatingAndComparingOrientation_viaReusedReference_viaShared_andDifferentOrientation() {
        let deviceProxy = XCUIDevice.shared
        let expectedOrientation = UIDeviceOrientation.landscapeLeft
        deviceProxy.orientation = expectedOrientation
        sleep(2)
        let result = assertCurrentOrientationIs(givenOrientation: expectedOrientation)
        XCTAssertTrue(result.matched, result.failureMessage!)
        
        // Change again
        let changedOrientation = UIDeviceOrientation.landscapeRight
        deviceProxy.orientation = changedOrientation
        sleep(2)
        let changedResult = assertCurrentOrientationIs(givenOrientation: changedOrientation, device: deviceProxy)
        XCTAssertTrue(changedResult.matched, changedResult.failureMessage!)
    }
    
    
    // FIXME: add tests using extension methods
    
    
    // MARK: - Instance Reference Tests
    
    /*
     (lldb) po self
     <XCUIDevice: 0x608000012b80> // from inside extension
     (lldb) po XCUIDevice()
     <XCUIDevice: 0x604000015060> // different with each invocation (unsurprising)
     (lldb) po XCUIDevice.shared
     <XCUIDevice: 0x60c0000146a0> // reference remains consistent on subsequent invocations (expected)
     */
    
    func testReferenceRemainsSame_viaShared() {
        let first = XCUIDevice.shared
        let _ = XCUIDevice.shared
        let third = XCUIDevice.shared
        
        XCTAssertEqual(first, third, "The shared reference should remain consistent")
    }
    
    func testReferenceRemainsSame_viaNew() {
        let first = XCUIDevice()
        let second = XCUIDevice()
        
        XCTAssertNotEqual(first, second, "The proxy references are never the same") // Does this matter?
    }
    
    // MARK: - Helpers
    
    struct OrientationMatchAssertion {
        let matched: Bool
        let failureMessage: String?
    }
    
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
