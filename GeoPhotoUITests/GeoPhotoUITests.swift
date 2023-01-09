//
//  GeoPhotoUITests.swift
//  GeoPhotoUITests
//
//  Created by Chi hin cheung on 8/1/2023.
//

import XCTest
import LocalAuthentication

final class GeoPhotoUITests: XCTestCase {
    let app = XCUIApplication()
    let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        app.launch()
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSettingTheme() throws {
        let collectionViewsQuery = app.collectionViews
        app.tabBars["Tab Bar"].buttons["Settings"].tap()

        let themeButton = collectionViewsQuery/*@START_MENU_TOKEN@*/.buttons["Theme"]/*[[".cells.buttons[\"Theme\"]",".buttons[\"Theme\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        
        themeButton.tap()
        let darkThemeSwitch = collectionViewsQuery.switches["Dark"]
        let lightThemeSwitch = collectionViewsQuery.switches["Light"]
        let systemThemeSwitch = collectionViewsQuery.switches["System"]
        
        // Select dark theme
        darkThemeSwitch.tap()
        
        // Check if dark theme is enabled
        themeButton.tap()
        XCTAssertTrue(darkThemeSwitch.isSelected)
        
        // Select light theme
        lightThemeSwitch.tap()
        
        // Check if light theme is enabled
        themeButton.tap()
        XCTAssertTrue(lightThemeSwitch.isSelected)
        
        // Select system theme
        systemThemeSwitch.tap()
        
        // Check if system theme is enabled
        themeButton.tap()
        XCTAssertTrue(systemThemeSwitch.isSelected)
        app.navigationBars["Theme"].buttons["Settings"].tap()
    }
    
    func testSettingAppLock() throws {
        let collectionViewsQuery = app.collectionViews
        app.tabBars["Tab Bar"].buttons["Settings"].tap()
        
        // Enable app lock and cancel authentication
        let enableAppLockSwitch = collectionViewsQuery/*@START_MENU_TOKEN@*/.switches["Enable App Lock"]/*[[".cells.switches[\"Enable App Lock\"]",".switches[\"Enable App Lock\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        enableAppLockSwitch.tap()
    }
}
