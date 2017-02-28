//
//  Interactor.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/27/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import Foundation
import UIKit

class Interactor: UIPercentDrivenInteractiveTransition {
    var hasStarted = false // tracks whether user interaction is in progress
    var shouldFinish = false // determines whether the transition should finish what it’s doing, or roll back to its original state
}
