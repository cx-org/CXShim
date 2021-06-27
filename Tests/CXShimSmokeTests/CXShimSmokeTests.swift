import Foundation
import XCTest
import CXShim

class CXShimSmokeTests: XCTest {
    
    func testBasic() {
        var cancellers: Set<AnyCancellable> = []
        CXWrappers.Timer
            .publish(every: 1, on: .main, in: .common)
            .delay(for: .milliseconds(10), scheduler: DispatchQueue.main.cx)
            .encode(encoder: JSONEncoder().cx)
            .catch { _ in Empty() }
            .sink(receiveValue: { _ in })
            .store(in: &cancellers)
        
        _ = [1, 2, 3].cx.publisher
        #if canImport(ObjectiveC)
        _ = NSObject().cx.publisher(for: \.hash)
        #endif
        
        class C: CXShim.ObservableObject {
            @CXShim.Published var x: Int = 0
        }
        _ = C().objectWillChange
    }
}
