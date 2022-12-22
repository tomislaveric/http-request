import Foundation

public protocol HTTPRequest {
    func get<Model>(url: String) async throws -> Model where Model: Decodable
    func post<Model>(url: String, body: Codable) async throws -> Model where Model: Decodable
}

public struct HTTPRequestImpl: HTTPRequest {
    
    public init(session: URLSession = URLSession.shared) {
        self.session = session
    }

    private let session: URLSession

    public func post<Model>(url: String, body: Codable) async throws -> Model where Model: Decodable {
        guard let url = URL(string: url) else {
            throw HTTPRequestError.badUrl
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
            throw HTTPRequestError.requestFailed
        }
        return try JSONDecoder().decode(Model.self, from: data)
        
    }
    
    public func get<Model>(url: String) async throws -> Model where Model: Decodable {
        guard let url = URL(string: url) else {
            throw HTTPRequestError.badUrl
        }
        
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw HTTPRequestError.requestFailed
        }
        return try JSONDecoder().decode(Model.self, from: data)
    }
}


enum HTTPRequestError: Error {
    case badUrl
    case requestFailed
}
