//
//  createThunkMiddleware.swift
//  ReSwift-Thunk
//
//  Created by Daniel Martín Prieto on 02/11/2018.
//  Copyright © 2018 ReSwift. All rights reserved.
//

import Foundation
import ReSwift

public func createThunkMiddleware<State, Action: Equatable>(
    thunk: Thunk<State, Action>,
    actions: [Action]
) -> Middleware<State, Action> {
    return { dispatch, getState in
        return { next in
            return { action in
                if actions.contains(action) {
                    thunk.body(dispatch, getState)
                } else {
                    next(action)
                }
            }
        }
    }
}

public func createThunkMiddleware<State, Action: Equatable>(
    thunk: Thunk<State, Action>,
    action: Action
) -> Middleware<State, Action> {
    createThunkMiddleware(thunk: thunk, actions: [action])
}
