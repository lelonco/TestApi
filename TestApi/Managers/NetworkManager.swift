//
//  NetworkManager.swift
//  TestApi
//
//  Created by Yaroslav on 14.12.2020.
//

import Foundation

class NetworkManager: NSObject {
    static let shared = NetworkManager()
    let session: URLSession
    let baseUrl: URL
    
    private override init() {
        self.session = URLSession.shared
        self.baseUrl = URL(string: "https://testapi.doitserver.in.ua/api/")!
    }
    func makeRequest(_ request: TestApiRequest, success:@escaping (URLResponse?, Any?) -> (), failure:@escaping (Error) -> ()) {
        guard let urlRequest = self.prepareUrlRequest(with: request, failure: failure) else {
            return
        }
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data, let response = response else {
                if let error = error {
                    failure(error)
                } else {
                    let nsError = NSError(domain: "Something went wrong", code: -99, userInfo: nil)
                    failure(nsError)
                }
                return
            }
            
            success(response, data)
        }
        task.resume()
    }
    
    private func prepareUrlRequest(with request: TestApiRequest, failure:@escaping (Error) -> ()) -> URLRequest? {
        
        guard let endPoint = request.endPoint else {
            let error = NSError(domain: "Cant get endpoint", code: -999, userInfo: nil)
            failure(error)
            return nil
        }
        guard let url = URL(string:endPoint, relativeTo: baseUrl) else {
            let error = NSError(domain: "Cant create url!", code: -999, userInfo: nil)
            failure(error)
            return nil
        }
        var urlComp = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        if let queryParams = request.queryParam {
            urlComp?.queryItems = queryParams.compactMap({ (key: String, value: Any) -> URLQueryItem? in
                return URLQueryItem(name: key, value: value as? String)
            })
        }
        var urlRequest = URLRequest(url: (urlComp?.url)!)
        if let params = request.headerParameters {
            params.forEach { (key: String, value: Any) in
                urlRequest.setValue(value as? String, forHTTPHeaderField: key)
            }
        }

        urlRequest.httpBody = request.httpBody
        urlRequest.httpMethod = request.httpMethod.rawValue

        return urlRequest
    }
}
