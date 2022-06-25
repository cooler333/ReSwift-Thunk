//
//  ReSwift_ThunkTests.swift
//  ReSwift-ThunkTests
//
//  Created by Daniel Martín Prieto on 01/11/2018.
//  Copyright © 2018 ReSwift. All rights reserved.
//

import XCTest
@testable import ReSwiftThunk

import ReSwift

private struct FakeState {}
private enum Action: Equatable {
    case initial
    case fakeAction
    case anotherFakeAction
    
    static func == (lhs: Action, rhs: Action) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial):
            return true

        case (.fakeAction, .fakeAction):
            return true

        case (.anotherFakeAction, .anotherFakeAction):
            return true

        default:
            return false
        }
    }
}

private func fakeReducer(action: Action, state: FakeState?) -> FakeState {
    return state ?? FakeState()
}

class Tests: XCTestCase {

    func testAction() {
        let thunk = Thunk<FakeState, Action> { _, _ in }
        let middleware: Middleware<FakeState, Action> = createThunkMiddleware(
            thunk: thunk,
            action: .fakeAction
        )
        let dispatch: DispatchFunction<Action> = { _ in }
        let getState: () -> FakeState? = { nil }
        var nextNotCalled = true
        let next: DispatchFunction<Action> = { _ in nextNotCalled = false }
        let action: Action = .fakeAction
        middleware(dispatch, getState)(next)(action)
        XCTAssert(nextNotCalled)
    }

    func testNextAction() {
        let thunk = Thunk<FakeState, Action> { _, _ in }
        let middleware: Middleware<FakeState, Action> = createThunkMiddleware(
            thunk: thunk,
            action: .anotherFakeAction
        )
        let dispatch: DispatchFunction<Action> = { _ in }
        let getState: () -> FakeState? = { nil }
        var nextCalled = false
        let next: DispatchFunction<Action> = { _ in nextCalled = true }
        let action: Action = .fakeAction
        middleware(dispatch, getState)(next)(action)
        XCTAssert(nextCalled)
    }

    func testThunk() {
        var thunkBodyCalled = false
        let thunk = Thunk<FakeState, Action> { _, _ in
            thunkBodyCalled = true
        }
        let middleware: Middleware<FakeState, Action> = createThunkMiddleware(
            thunk: thunk,
            action: .fakeAction
        )
        let dispatch: DispatchFunction<Action> = { _ in }
        let getState: () -> FakeState? = { nil }
        var nextCalled = false
        let next: DispatchFunction<Action> = { _ in nextCalled = true }
        middleware(dispatch, getState)(next)(.fakeAction)
        XCTAssertFalse(nextCalled)
        XCTAssert(thunkBodyCalled)
    }

    func testMiddlewareInsertion() {
        var thunkBodyCalled = false
        let thunk = Thunk<FakeState, Action> { _, _ in
            thunkBodyCalled = true
        }
        let store = Store(
            reducer: fakeReducer,
            state: nil,
            initialAction: .initial,
            middleware: [createThunkMiddleware(thunk: thunk, action: .fakeAction)]
        )
        store.dispatch(.fakeAction)
        XCTAssertTrue(thunkBodyCalled)
    }

    func testExpectThunkRuns() {
        let thunk = Thunk<FakeState, Action> { dispatch, getState in
            dispatch(.fakeAction)
            XCTAssertNotNil(getState())
            dispatch(.fakeAction)
        }
        let expectThunk = ExpectThunk(thunk, initialAction: .initial)
            .dispatches { action in
                switch action {
                case .fakeAction:
                    break
                default:
                    XCTFail("Unexpected action: \(action)")
                }
            }
            .getsState(FakeState())
            .dispatches { action in
                switch action {
                case .fakeAction:
                    break
                default:
                    XCTFail("Unexpected action: \(action)")
                }
            }
            .run()
        XCTAssertEqual(expectThunk.dispatched.count, 2)
    }

    func testExpectThunkWaits() {
        let thunk = Thunk<FakeState, Action> { dispatch, getState in
            dispatch(.fakeAction)
            XCTAssertNotNil(getState())
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.5) {
                dispatch(.anotherFakeAction)
                XCTAssertNotNil(getState())
            }
            dispatch(.fakeAction)
        }
        let expectThunk = ExpectThunk<FakeState, Action>(thunk, initialAction: .initial)
            .dispatches { action in
                switch action {
                case .fakeAction:
                    break
                default:
                    XCTFail("Unexpected action: \(action)")
                }
            }
            .getsState(FakeState())
            .dispatches { action in
                switch action {
                case .fakeAction:
                    break
                default:
                    XCTFail("Unexpected action: \(action)")
                }
            }
            .dispatches(.anotherFakeAction)
            .getsState(FakeState())
            .wait()
        XCTAssertEqual(expectThunk.dispatched.count, 3)
    }
}
