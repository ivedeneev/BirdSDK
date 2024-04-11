//
//  File.swift
//  
//
//  Created by Igor Vedeneev on 11/04/2024.
//

import Foundation

protocol RequestBuilder {
    func urlRequest(for request: Request) throws -> URLRequest
}
