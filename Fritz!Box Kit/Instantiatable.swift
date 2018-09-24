//
//  Instantiatable
//  Roman Gille
//
//  Created by Roman Gille on 02.02.17.
//  Copyright © 2017 Roman Gille. All rights reserved.
//

import UIKit

protocol Instantiatable: class {
    
    static func instantiate() -> Self
    static var storyboardName: String { get }
    
}

extension Instantiatable where Self: UIViewController {
    
    static func create() -> Self {
        return instantiate()
    }
    
    static var storyboardName: String {
        return "Main"
    }
    
    static func instantiate() -> Self {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let identifier = String(describing: self)
        return storyboard.instantiateViewController(withIdentifier: identifier) as! Self
    }
    
}
