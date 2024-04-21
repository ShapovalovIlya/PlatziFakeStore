//
//  Requests.swift
//
//
//  Created by Илья Шаповалов on 21.04.2024.
//

import Foundation
import Request

extension Request {
    @inlinable
    func contentHeader() -> Self {
        self.headers {
            Header(field: "Content-Type", value: "application/json")
        }
    }
    
    @inlinable
    func addPayload(_ data: Data) -> Self {
        self.body(data)
            .contentHeader()
    }
}
