import XCTest
import SwiftUI
@testable import DynamicColorBackground

final class DynamicColorBackgroundTests: XCTestCase {
    func testImageColorExtraction() {
        let image = UIImage(named: "hypnopolis") // Assuming a test image is available
        let view = DynamicBackgroundView(image: image!)
        
        XCTAssertNotNil(view)
    }
}
