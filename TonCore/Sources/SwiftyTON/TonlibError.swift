//
//  File.swift
//  
//
//  Created by nikstar on 27.04.2023.
//

import Foundation
import GlossyTON

enum TonlibError: Swift.Error {
    
    case cancelled
    case liteserverCancelled(Swift.Error)
    case liteserverError(Swift.Error)
    case unknown(Swift.Error?)
    
    init(_ e: Swift.Error?) {

        guard let e else {
            self = .unknown(nil)
            return
        }
        
        let errorDescription = e.localizedDescription.lowercased()
        
        if (e as NSError).code == GTTONErrorCodeCancelled {
            self = .cancelled
        } else if errorDescription.contains("cancelled") {
            self = .liteserverCancelled(e)
        } else if errorDescription.hasPrefix("lite_server_") {
            self = .liteserverError(e)
        } else {
            self = .unknown(e)
        }
    }
}
