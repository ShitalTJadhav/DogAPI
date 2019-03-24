//
//  BreedListUITests.swift
//  DogAPIUITests
//
//  Created by Tushar  Jadhav on 2019-03-23.
//  Copyright © 2019 Shital  Jadhav. All rights reserved.
//

import XCTest

class BreedListUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTableScrolling() {
        
        let collectionView = app.collectionViews["BreedListViewIdentifier"]
        _ = collectionView.waitForExistence(timeout: 3.0)
        
        //Check list collectionView exits
        XCTAssert(collectionView.exists)
        
        //Check scroll
        collectionView.swipeUp()
        collectionView.swipeUp()
    }
    
    func testSearchRecipeFunction()  {
        
        let searchField = app.otherElements["Breed_SearchBar"].searchFields["Search breed by name"]
        searchField.tap()
        
        let searchText = "affenpinsche"
        searchField.typeText(searchText)
        
        //Check type text is visible in search bar
        let searchBarValue = searchField.value as! String
        XCTAssertEqual(searchBarValue, searchText)
        
        //Tap keyboard search button
        let searchButton = app/*@START_MENU_TOKEN@*/.keyboards.buttons["Search"]/*[[".keyboards.buttons[\"Search\"]",".buttons[\"Search\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/
        searchButton.tap()
        sleep(2)
        
//        let cell = collectionView.staticTexts[searchText]
//        XCTAssert(cell.exists)
//        cell.tap()

        searchField.tap()
        app.buttons["Cancel"].tap()
        
        //Check search bar placeholder is set
        XCTAssertEqual(searchField.placeholderValue, "Search breed by name")
        
        
    }
    
    func testNavigationTo_BreedGalleryScreen() {
        
        //Check recipe detail view is visible
        let collectionView = app.collectionViews["BreedListViewIdentifier"]
        
        let cell = collectionView.children(matching: .cell).element(boundBy: 1)
        cell.tap()

        //Get detail table view
        let detailList = app.collectionViews["BreedGalleryViewIdentifier"]
        _ = detailList.waitForExistence(timeout: 3.0)
        
        XCTAssert(detailList.exists)
        

    }
    
}
