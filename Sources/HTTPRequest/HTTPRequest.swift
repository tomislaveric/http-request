import Foundation

public protocol HTTPRequest {
    func get<ReturnType: Decodable>(request: URLRequest) async throws -> ReturnType
    func post<ReturnType: Decodable, BodyType: Encodable>(request: URLRequest, body: BodyType?) async throws -> ReturnType
    func post<BodyType: Encodable>(request: URLRequest, body: BodyType?) async throws
    func post<ReturnType: Decodable>(request: URLRequest) async throws -> ReturnType
}

public struct HTTPRequestImpl: HTTPRequest {
    
    private let session: URLSession
    
    public init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    public func post<ReturnType: Decodable, BodyType: Encodable>(request: URLRequest, body: BodyType? = nil) async throws -> ReturnType {
        var request = request
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(body)
        return try await handleRequest(request: request)
    }
    
    public func post<BodyType: Encodable>(request: URLRequest, body: BodyType) async throws {
        var request = request
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(body)
        
        try await handleRequest(request: request)
    }
    
    public func post<ReturnType: Decodable>(request: URLRequest) async throws -> ReturnType {
        var request = request
        request.httpMethod = "POST"
        return try await handleRequest(request: request)
    }
    
    public func get<ReturnType: Decodable>(request: URLRequest) async throws -> ReturnType {
        var request = request
        request.httpMethod = "GET"
        return try await handleRequest(request: request)
    }
    
    private func handleRequest(request: URLRequest) async throws {
        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
            throw HTTPRequestError.requestFailed(response: response)
        }
    }
    
    private func handleRequest<ReturnType: Decodable>(request: URLRequest) async throws -> ReturnType {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
            throw HTTPRequestError.requestFailed(response: response)
        }
        return try JSONDecoder().decode(ReturnType.self, from: data)
    }
}


public enum HTTPRequestError: Error {
    case requestFailed(response: URLResponse?)
}
