
import Foundation
import SwiftyTON


private var dataURL: URL {
    let url = try! FileManager.default.url(for: .documentDirectory, in: .localDomainMask, appropriateFor: nil, create: true).appendingPathComponent("blockchain")
    try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    return url
}
