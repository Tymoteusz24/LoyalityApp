import ComposableArchitecture

@Reducer
public struct CustomerHeader {
    @ObservableState
    public enum State: Equatable {
        case loading
        case content(String)
        case error(String)
    }
}
