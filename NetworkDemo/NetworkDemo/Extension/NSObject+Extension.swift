//  NetworkDemo
//
//  Created by Israkul Tushaer-81 on 11/1/24.
//

import Foundation

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
}
