//
//  FritzBoxKit+ResourceLoading.swift
//  Fritz!Box Kit
//
//  Created by Roman Gille on 28.12.17.
//
//  Copyright (c) 2018 Roman Gille, http://romangille.com
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
    
    enum HTTPStatus: Int {
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
    func load<A>(_ resource: Resource<A>, completion: @escaping (Result<A, Error>) -> Void) -> URLSessionTask? {
        var urlComponents = URLComponents(url: resource.url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = resource.params.flatMap{
            $0.compactMap{
                URLQueryItem(name: $0.key, value: $0.value as? String)
            }
        }
        
        guard let url = urlComponents?.url else {
            completion(.failure(RequestError.invalidResource))
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = resource.method.rawValue
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)

        let task = session.dataTask(with: request) { (data, response, error) in
            let httpResponse = response as? HTTPURLResponse
            let result: HTTPStatus = httpResponse.flatMap{ HTTPStatus(rawValue: $0.statusCode) } ?? .unknownError

            guard result.isSuccessfulOperation else {
                completion(.failure(RequestError.invalidHTTPStatus(result.rawValue)))
                return
            }
            
            guard let data = data, let xmlString = String(data: data, encoding: .utf8) else {
                completion(.failure(RequestError.stringDecoding))
                return
            }

            do {
                completion(.success(try resource.parse(xmlString)))
            } catch (let error) {
                completion(.failure(error))
            }
        }
        task.resume()
        return task
    }
    
}
