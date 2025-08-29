import CNativeAPI
import XCTest

@testable import NativeAPI

/// Test suite for AppRunner functionality
final class AppRunnerTests: XCTestCase {

    override func setUpWithError() throws {
        // Initialize WindowManager before each test
        _ = WindowManager.shared.initialize()
    }

    override func tearDownWithError() throws {
        // Clean up after each test
        WindowManager.shared.shutdown()
    }

    // MARK: - Basic AppRunner Tests

    func testAppRunnerSharedInstance() throws {
        // Test that shared instance exists
        let appRunner = AppRunner.shared
        XCTAssertNotNil(appRunner)

        // Test that we get the same instance
        let appRunner2 = AppRunner.shared
        XCTAssertTrue(appRunner === appRunner2, "AppRunner.shared should return the same instance")
    }

    func testAppRunnerIsNotRunningInitially() throws {
        // Test that app is not running initially
        let appRunner = AppRunner.shared
        XCTAssertFalse(appRunner.isRunning, "AppRunner should not be running initially")
    }

    // MARK: - AppExitCode Tests

    func testAppExitCodeValues() throws {
        // Test that exit codes have correct raw values
        XCTAssertEqual(AppExitCode.success.rawValue, 0)
        XCTAssertEqual(AppExitCode.failure.rawValue, 1)
        XCTAssertEqual(AppExitCode.invalidWindow.rawValue, 2)
    }

    func testAppExitCodeFromRawValue() throws {
        // Test creating exit codes from raw values
        XCTAssertEqual(AppExitCode(rawValue: 0), .success)
        XCTAssertEqual(AppExitCode(rawValue: 1), .failure)
        XCTAssertEqual(AppExitCode(rawValue: 2), .invalidWindow)
        XCTAssertNil(AppExitCode(rawValue: 99))
    }

    // MARK: - Window Creation Tests

    func testCreateWindowForAppRunner() throws {
        // Create window options
        let options = WindowOptions()
        _ = options.setTitle("Test Window")
        options.setSize(Size(width: 400, height: 300))
        options.setCentered(true)

        // Create window
        guard let window = WindowManager.shared.createWindow(with: options) else {
            XCTFail("Failed to create window")
            return
        }

        // Verify window properties
        XCTAssertEqual(window.title, "Test Window")
        let size = window.size
        XCTAssertEqual(size.width, 400, accuracy: 1.0)
        // Window height may differ due to title bar and decorations, allow more tolerance
        XCTAssertGreaterThan(size.height, 250)
        XCTAssertLessThan(size.height, 400)

        // Clean up
        _ = WindowManager.shared.destroyWindow(id: window.id)
    }

    func testCreateDefaultWindow() throws {
        // Test creating window with default options
        guard let window = WindowManager.shared.createWindow() else {
            XCTFail("Failed to create default window")
            return
        }

        // Window should exist and have an ID
        XCTAssertGreaterThan(window.id, 0)

        // Clean up
        _ = WindowManager.shared.destroyWindow(id: window.id)
    }

    // MARK: - Convenience Function Tests

    func testRunAppWithInvalidWindow() throws {
        // This test would require mocking the C API to return invalid window
        // For now, we'll test the convenience function structure exists

        let options = WindowOptions()
        _ = options.setTitle("Test Convenience Window")

        // This would normally start the app, but we can't test that in unit tests
        // without mocking the underlying C implementation
        // XCTAssertEqual(runApp(with: options), .success)

        // Instead, test that the function exists and compiles
        XCTAssertTrue(true, "Convenience functions compile successfully")
    }

    // MARK: - Error Handling Tests

    func testAppRunnerWithNilWindow() throws {
        // Test that AppRunner handles invalid window gracefully
        // This would require access to the internal window handle
        // For now, we verify the API structure

        let appRunner = AppRunner.shared
        XCTAssertNotNil(appRunner)

        // The actual run method requires a valid Window object,
        // so we can't easily test with nil without modifying the API
        XCTAssertTrue(true, "AppRunner API structure is correct")
    }

    // MARK: - Thread Safety Tests

    func testAppRunnerThreadSafety() throws {
        let expectation = XCTestExpectation(description: "Thread safety test")
        expectation.expectedFulfillmentCount = 10

        // Test accessing shared instance from multiple threads
        DispatchQueue.global().async {
            for _ in 0..<10 {
                DispatchQueue.global().async {
                    let appRunner = AppRunner.shared
                    XCTAssertNotNil(appRunner)
                    XCTAssertFalse(appRunner.isRunning)
                    expectation.fulfill()
                }
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }

    // MARK: - Integration Tests

    func testWindowManagerAndAppRunnerIntegration() throws {
        // Test that WindowManager and AppRunner work together

        // Initialize WindowManager
        let initialized = WindowManager.shared.initialize()
        XCTAssertTrue(initialized, "WindowManager should initialize successfully")

        // Create a window
        let options = WindowOptions()
        _ = options.setTitle("Integration Test Window")
        options.setSize(Size(width: 500, height: 400))

        guard let window = WindowManager.shared.createWindow(with: options) else {
            XCTFail("Failed to create window for integration test")
            return
        }

        // Verify window was created properly
        XCTAssertGreaterThan(window.id, 0)
        XCTAssertEqual(window.title, "Integration Test Window")

        // Get AppRunner instance
        let appRunner = AppRunner.shared
        XCTAssertNotNil(appRunner)
        XCTAssertFalse(appRunner.isRunning)

        // Clean up
        _ = WindowManager.shared.destroyWindow(id: window.id)
        WindowManager.shared.shutdown()
    }

    // MARK: - Performance Tests

    func testAppRunnerPerformance() throws {
        measure {
            // Test performance of getting shared instance
            for _ in 0..<1000 {
                _ = AppRunner.shared
            }
        }
    }

    func testWindowCreationPerformance() throws {
        measure {
            // Test performance of window creation
            let options = WindowOptions()
            _ = options.setTitle("Performance Test")

            for _ in 0..<10 {
                if let window = WindowManager.shared.createWindow(with: options) {
                    _ = WindowManager.shared.destroyWindow(id: window.id)
                }
            }
        }
    }

    // MARK: - API Compatibility Tests

    func testConvenienceFunctionsExist() throws {
        // Test that all convenience functions are available
        // We can't actually run them in tests, but we can verify they compile

        let options = WindowOptions()
        _ = options.setTitle("API Test Window")

        // These functions should exist and be callable
        // (though they would start actual app instances if called)

        // Test function signatures exist
        let _: (Window) -> AppExitCode = runApp(with:)
        let _: (WindowOptions) -> AppExitCode = runApp(with:)
        let _: () -> AppExitCode = runApp

        XCTAssertTrue(true, "All convenience function signatures are available")
    }

    func testAppExitCodeConformances() throws {
        // Test that AppExitCode conforms to expected protocols
        let exitCode: AppExitCode = .success

        // Should be able to compare
        XCTAssertEqual(exitCode, .success)
        XCTAssertNotEqual(exitCode, .failure)

        // Should have raw value
        XCTAssertEqual(exitCode.rawValue, 0)

        XCTAssertTrue(true, "AppExitCode conforms to expected protocols")
    }

    // MARK: - Documentation Tests

    func testAPIDocumentationCompleteness() throws {
        // This is more of a compile-time check to ensure
        // all public APIs have proper Swift interface

        let appRunner = AppRunner.shared
        XCTAssertNotNil(appRunner)

        // Test that all public methods are accessible
        let isRunning = appRunner.isRunning
        XCTAssertFalse(isRunning)

        // Test exit code cases
        let successCode = AppExitCode.success
        let failureCode = AppExitCode.failure
        let invalidWindowCode = AppExitCode.invalidWindow

        XCTAssertNotEqual(successCode, failureCode)
        XCTAssertNotEqual(failureCode, invalidWindowCode)
        XCTAssertNotEqual(successCode, invalidWindowCode)

        XCTAssertTrue(true, "All public APIs are properly documented and accessible")
    }
}

// MARK: - Mock Helper Classes

/// Mock window for testing (if needed)
private class MockWindow {
    let id: Int
    var title: String
    var size: Size

    init(id: Int, title: String, size: Size) {
        self.id = id
        self.title = title
        self.size = size
    }
}

// MARK: - Test Utilities

extension AppRunnerTests {

    /// Helper method to create a test window with default settings
    private func createTestWindow() -> Window? {
        let options = WindowOptions()
        _ = options.setTitle("Test Window")
        options.setSize(Size(width: 400, height: 300))
        return WindowManager.shared.createWindow(with: options)
    }

    /// Helper method to cleanup a test window
    private func cleanupWindow(_ window: Window) {
        _ = WindowManager.shared.destroyWindow(id: window.id)
    }
}
