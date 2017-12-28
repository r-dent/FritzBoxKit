//
//  FritzBoxKit+ResourceLoading.swift
//  Fritz!Box Kit
//
//  Created by Roman Gille on 28.12.17.
//  Copyright © 2017 Roman Gille. All rights reserved.
//

import Foundation

extension FritzBox {
    
    /// HTTP method definitions.
    ///
    /// See https://tools.ietf.org/html/rfc7231#section-4.3
    public enum HTTPMethod: String {
        case options = "OPTIONS"
        case get     = "GET"
        case head    = "HEAD"
        case post    = "POST"
        case put     = "PUT"
        case patch   = "PATCH"
        case delete  = "DELETE"
        case trace   = "TRACE"
        case connect = "CONNECT"
    }
    
    /// A dictionary of parameters to apply to a `URLRequest`.
    public typealias Parameters = [String: Any]
    
    enum Result: Int {
        case
        noConnection    = 0,
        succeeded       = 200,
        created         = 201,
        notModified     = 304,
        badRequest      = 400,
        unauthorized    = 401,
        notFound        = 404,
        unknownError    = 500
        
        /**
         * Status code is in 200 range.
         * See: https://en.wikipedia.org/wiki/List_of_HTTP_status_codes#2xx_Success
         */
        var isSuccessfulOperation: Bool {
            return rawValue >= 200 && rawValue <= 299
        }
    }
    
    struct Resource<T> {
        typealias ParseBlock = (_ xmlString: String) throws -> T
        
        let url: URL
        let method: HTTPMethod
        let params: Parameters?
        let parse: ParseBlock
        
        init(url: URL, method: HTTPMethod, params: Parameters? = nil, parse: @escaping ParseBlock) {
            self.url    = url
            self.method = method
            self.params = params
            self.parse  = parse
        }
        
        enum ParseError: Error {
            case mappingFailed, itemNotFound
        }
    }
    
    @discardableResult
    func load<A>(_ resource: Resource<A>, completion: @escaping (A?, Result) -> Void) -> URLSessionTask? {
        var urlComponents = URLComponents(url: resource.url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = resource.params.flatMap{
            $0.flatMap{
                URLQueryItem(name: $0.key, value: $0.value as? String)
            }
        }
        
        guard let url = urlComponents?.url else {
            completion(nil, .badRequest)
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = resource.method.rawValue
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            let httpResponse = response as? HTTPURLResponse
            let result: Result = httpResponse.flatMap{ Result(rawValue: $0.statusCode) } ?? .unknownError
            
            guard let data = data, let xmlString = String(data: data, encoding: .utf8) else {
                completion(nil, result)
                return
            }
            
            completion(try? resource.parse(xmlString), result)
        }
        task.resume()
        return task
    }
    
}
