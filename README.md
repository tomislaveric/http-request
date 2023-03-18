# HTTPRequest

Yet another HTTPRequest wrapper. HTTP requests are fully written with async/await. 
So far GET, POST, PUT and PATCH requests are available

## Why do i need this package?

In almost every project i need to make HTTP request (GET, POST...) and then the JSON result has to be decoded to some model. I am tired of writing it everytime again and again. Here i've create a Swift Package with the most up to date way of doing this. No Closures and stuff, just simple and readble async await functions with type inference to parse the result by JSONDecoder. 

## Installation

1. Within your project, click on `File -> Add Packages` and paste this repo URL `https://github.com/tomislaveric/http-request`. 
2. Click on `Add Package`.

## Usage example

```Swift
import HTTPRequest

    //Instantiate HTTPRequest
    private let httpRequest: HTTPRequest = HTTPRequestImpl()
    
    //GET example
    func getActivity() async throws -> Activity {
        var request = URLRequest(url: try endpoint)
        // You can set custom headers here if you want
        request.setValue("Bearer someToken", forHTTPHeaderField: "Authorization")
        return try await httpRequest.get(request: request)
    }
    
    //POST example without return type
    func sendActivity(activity: Activity) async throws {
        var request = URLRequest(url: try endpoint)
        try await httpRequest.post(request: request, body: activity)
    }
    
    //POST example with return type
    func sendActivity(activity: Activity) async throws -> Activity {
        var request = URLRequest(url: try endpoint)
        return try await httpRequest.post(request: request, body: activity)
    }
    
    private var endpoint: URL {
        get throws {
            guard let url = URL(string: "https://www.boredapi.com/api/acvtivity") else {
                throw UrlError.urlStringNotParsable
            }
            return url
        }
    }
    
    struct Activity: Decodable, Encodable {
        let activity: String
    }

    enum UrlError: Error {
        case urlStringNotParsable
    }
```

## Troubleshoot

If you encounter errors like this in XCodes console, you need to go to toggle `incoming/outcoming connections` for your **App Sandbox**. You can find it in `Signing and Capabilities` at your projects target.

* `NSUnderlyingError=0x6000021db390 { Error Domain=kCFErrorDomainCFNetwork Code=-1003 "(null)"`

* `Error Domain=NSURLErrorDomain Code=-1003 "A server with the specified hostname could not be found."`

![AppSandbox](images/sandbox.jpg)

## Roadmap

[x] Add handling for custom headers
[x] Add PUT requests
[x] Add PATCH requests