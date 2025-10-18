import ComposableArchitecture

@Reducer
public struct AvailablePoints {
    @ObservableState
    public enum State: Equatable {
        case loading
        case content(Int)
        case error
    }
}

extension AvailablePoints.State {
    var points: Int {
        guard case let .content(points) = self else {
            return 0
        }

        return points
    }
}
