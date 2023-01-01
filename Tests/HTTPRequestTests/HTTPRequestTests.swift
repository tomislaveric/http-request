import XCTest
@testable import HTTPRequest

final class HTTPRequestTests: XCTestCase {
    override class func setUp() {
        URLProtocol.registerClass(MockURLProtocol.self)
    }
    
    func test_getShouldThrow_onFailedRequest() async throws {
        let config = URLSessionConfiguration.default
        config.protocolClasses?.insert(MockURLProtocol.self, at: 0)
        let httpRequest: HTTPRequest = HTTPRequestImpl(session: URLSession(configuration: config))
        MockURLProtocol.mockData["/test"] = try JSONEncoder().encode(MockResponse(id: 26, name: "Tomi"))
        let request = URLRequest(url: try XCTUnwrap(URL(string: "/test")))
        
        let expectation = expectation(description: "Fetching")
        let result: MockResponse = try await httpRequest.get(request: request)
        XCTAssertEqual(result.name, "Tomi")
        expectation.fulfill()
        wait(for: [expectation], timeout: 5)
    }
}

struct MockResponse: Codable, Equatable {
    let id: Int
    let name: String
}

public class MockURLProtocol: URLProtocol {

    // A dictionary of mock data, where keys are URL path eg. "/weather?country=SG"
    static var mockData = [String: Data]()

    public override class func canInit(with task: URLSessionTask) -> Bool {
        return true
    }

    public override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    public override func startLoading() {
        if let url = request.url {
            let path: String
            if let queryString = url.query {
                path = url.relativePath + "?" + queryString
            } else {
                path = url.relativePath
            }
            let data = MockURLProtocol.mockData[path]!
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocol(self, didReceive: HTTPURLResponse(), cacheStoragePolicy: .allowed)
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    public override func stopLoading() {}

}
