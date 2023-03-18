import Foundation

public protocol HTTPRequest {
    
    /// Sends a GET request to a specific URL and returns the decoded type
    /// - Parameters
    ///     - url: The URL for the request.
    ///     - header: A dictionary where you can specify request headers, like ["Authorization":"Bearer 123456"]
    /// - Returns:The decoded type by type inference
    func get<ReturnType: Decodable>(url: URL?, header: [String:String]?) async throws -> ReturnType
    
    /// Sends a POST request to a specific URL, with a body, optional header and returns the decoded type
    /// - Parameters
    ///     - url: The URL for the request.
    ///     - header: A dictionary where you can specify request headers, like ["Authorization":"Bearer 123456"].
    ///     - body: The body to send the POST request, it has to conform to Encodable.
    func post<ReturnType: Decodable, BodyType: Encodable>(url: URL?, header: [String:String]?, body: BodyType) async throws -> ReturnType
    
    /// Sends a POST request to a specific URL with option header and returns the decoded type
    /// - Parameters
    ///     - url: The URL for the request.
    ///     - header: A dictionary where you can specify request headers, like ["Authorization":"Bearer 123456"].
    /// - Returns:The decoded type by type inference
    func post<ReturnType: Decodable>(url: URL?, header: [String:String]?) async throws -> ReturnType
    
    /// Sends a POST request to a specific URL with option header and returns the decoded type
    /// - Parameters
    ///     - url: The URL for the request.
    ///     - header: A dictionary where you can specify request headers, like ["Authorization":"Bearer 123456"].
    ///     - body: The body to send the POST request, it has to conform to Encodable.
    func post<BodyType: Encodable>(url: URL?, header: [String:String]?, body: BodyType) async throws
    /// Sends a PUT request to a specific URL with option header and returns the decoded type
    /// - Parameters
    ///     - url: The URL for the request.
    ///     - header: A dictionary where you can specify request headers, like ["Authorization":"Bearer 123456"].
    ///     - body: The body to send the PUT request, it has to conform to Encodable.
    func put<ReturnType: Decodable, BodyType: Encodable>(url: URL?, header: [String:String]?, body: BodyType) async throws -> ReturnType
    /// Sends a PATCH request to a specific URL with option header and returns the decoded type
    /// - Parameters
    ///     - url: The URL for the request.
    ///     - header: A dictionary where you can specify request headers, like ["Authorization":"Bearer 123456"].
    ///     - body: The body to send the PATCH request, it has to conform to Encodable.
    func patch<ReturnType: Decodable, BodyType: Encodable>(url: URL?, header: [String:String]?, body: BodyType) async throws -> ReturnType
}

public struct HTTPRequestImpl: HTTPRequest {
    public func patch<ReturnType, BodyType>(url: URL?, header: [String : String]?, body: BodyType) async throws -> ReturnType where ReturnType : Decodable, BodyType : Encodable {
        let request = try createRequest(url: url, of: .PATCH, with: header, bodyData: try JSONEncoder().encode(body))
        let data = try await handleResponse(request: request)
        guard let decoded: ReturnType = try decode(response: data) else {
            throw HTTPRequestError.couldNotDecode
        }
        return decoded
    }
    
    public func put<ReturnType: Decodable, BodyType: Encodable>(url: URL?, header: [String:String]? = nil, body: BodyType) async throws -> ReturnType {
        let request = try createRequest(url: url, of: .PUT, with: header, bodyData: try JSONEncoder().encode(body))
        let data = try await handleResponse(request: request)
        guard let decoded: ReturnType = try decode(response: data) else {
            throw HTTPRequestError.couldNotDecode
        }
        return decoded
    }
    
    
    private let session: URLSession
    
    public init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    public func post<ReturnType: Decodable, BodyType: Encodable>(url: URL?, header: [String:String]? = nil, body: BodyType) async throws -> ReturnType {
        let request = try createRequest(url: url, of: .POST, with: header, bodyData: try JSONEncoder().encode(body))
        let data = try await handleResponse(request: request)
        guard let decoded: ReturnType = try decode(response: data) else {
            throw HTTPRequestError.couldNotDecode
        }
        return decoded
    }
    
    public func post<ReturnType: Decodable>(url: URL?, header: [String:String]? = nil) async throws -> ReturnType {
        let request = try createRequest(url: url, of: .POST, with: header, bodyData: nil)
        let data = try await handleResponse(request: request)
        guard let decoded: ReturnType = try decode(response: data) else {
            throw HTTPRequestError.couldNotDecode
        }
        return decoded
    }
    
    public func post<BodyType: Encodable>(url: URL?, header: [String:String]? = nil, body: BodyType) async throws {
        let request = try createRequest(url: url, of: .POST, with: header, bodyData: try JSONEncoder().encode(body))
        _ = try await handleResponse(request: request)
    }
    
    public func get<ReturnType: Decodable>(url: URL?, header: [String: String]? = nil) async throws -> ReturnType {
        let request = try createRequest(url: url, of: .GET, with: header)
        let data = try await handleResponse(request: request)
        guard let decoded: ReturnType = try decode(response: data) else {
            throw HTTPRequestError.couldNotDecode
        }
        return decoded
    }
    
    private func decode<ReturnType: Decodable>(response: Data) throws -> ReturnType {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(ReturnType.self, from: response)
    }
    
    private func handleResponse(request: URLRequest) async throws -> Data {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
            throw HTTPRequestError.requestFailed(response: response)
        }
        return data
    }
    
    private func createRequest(url: URL?, of type: RequestType, with header: [String: String]?, bodyData: Data? = nil) throws -> URLRequest {
        guard let url = url else {
            throw HTTPRequestError.badURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = type.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        header?.forEach {
            request.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        request.httpBody = bodyData
        return request
    }
    
    private enum RequestType: String {
        case GET
        case POST
        case PUT
        case PATCH
    }
}


public enum HTTPRequestError: Error {
    case requestFailed(response: URLResponse?)
    case badURL
    case couldNotDecode
}
