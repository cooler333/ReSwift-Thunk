//
//  Thunk.swift
//  ReSwift-Thunk
//
//  Created by Daniel Martín Prieto on 01/11/2018.
//  Copyright © 2018 ReSwift. All rights reserved.
//

import Foundation
import ReSwift

public struct Thunk<State, Action> {
    let body: (_ dispatch: @escaping DispatchFunction<Action>, _ getState: @escaping () -> State?) -> Void
    init(
        body: @escaping (
            _ dispatch: @escaping DispatchFunction<Action>,
            _ getState: @escaping () -> State?
        ) -> Void
    ) {
        self.body = body
    }
}
