//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Vadzim on 6.02.25.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    
    // swiftlint:disable:next implicitly_unwrapped_optional
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        // это специальная настройка для тестов: если один тест не прошёл,
        // то следующие тесты запускаться не будут; и правда, зачем ждать?
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testScreenCast() throws { }
    
//    app.buttons["Да"]
//    button.tap()
//    button.tap()
//    button.tap()
//    button.tap()
//    button.tap()
//    button.tap()
//    button.tap()
//    button.tap()
//    button.tap()
//    button.tap()
//    app.alerts["Этот раунд окончен!"].scrollViews.otherElements.buttons["Сыграть еще раз"].tap()
//    func testScreenCast() throws { }
    
}
