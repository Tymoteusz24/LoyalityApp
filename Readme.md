# Recruitment Task

This repo contains a simplistic version of a loyalty program app. User collects points through
purchases and there are several rewards, which he can activate to claim them at the counter.
Activating a reward decreases his points balance.

## Task

The user stories to implement are:

1. As a user, when I click on an inactive reward, I want to activate it.  
2. As a user, when I click on an active reward, I want to deactivate it.  
3. As a user, when I activate or deactivate a reward, I want to see how my points balance has changed.  

**We ask you to implement these user stories in a way that you would do it in a regular, 
production-ready application using your best judgement when it comes to architecture, patterns,
development practices, optimal user experience etc.**

### What will you find in this repository

To save your time, the skeleton for this function is already implemented.  
There's a view layer stub and there's a `RewardsAPI` (which simulates regular remote API).
What is left for you to fill is the connection between the view layer and `RewardsAPI` as well as 
making sure that the app looks like the provided design and behaves in a user-friendly manner.

### Other info

- the skeleton is for your convenience, if you want to implement it differently, go ahead, just 
  be prepared to talk about the solution you chose
- you can use different libraries or Swift features, e.g. if you are more familiar with async/await than Combine,
  you're encouraged to use them
- if you want to provide additional info about your solution in the Readme, feel free to do so
- don't hesitate to use AI as long as you understand the generated solution and can decide whether it fits the requirements

### Mock API

The `RewardsAPI` is a mock that simulates a regular asynchronous API interface. 
Just like the original, it might throw exceptions when something goes wrong. You should expect:

- `HttpError.badRequest` with code 400 when something is wrong with a request.
- `HttpError.resourceNotFound` with code 404 when for example incorrect URL is passed to load an image.
- `HttpError.serverUnavailable` 500 from time to time

### Key aspects we evaluate during the technical solution review
* functionality and responsiveness of the application
* code complexity and size – higher volume doesn't imply higher quality
* code quality, readability, and overall cleanliness
* handling of edge cases (including several non-obvious ones)
* appropriate and effective use of design patterns
* methods used to ensure the correctness and stability of implemented changes
---

## Implementation Details

### Architecture Decisions

**DataLayer Module**  
- Created a separate `DataLayer` module with single-responsibility repositories (`CustomerRemoteRepository`, `RewardsRemoteRepository`, `ImageLoader`)  
- Follows the **Single Responsibility Principle** (SOLID) - each repository handles only one domain concern  
- Acts as an abstraction layer over the low-level `RewardsAPI`, decoupling it from feature modules  
- Enables reusability across future features without tight coupling to specific implementations  
- Introduced domain models (`CustomerModel`, `RewardModel`) that are independent of API entities  

**Modular Architecture**  
- Clean separation of concerns with distinct modules:  
  - `DataLayer` - Data access and networking  
  - `DashboardFeature` - Business logic and state management  
  - `UI` - Reusable UI components  
  - `Resources` - Assets and localization  
- Each module has well-defined boundaries and dependencies  

**Composable Architecture (TCA)**  
- Leveraged TCA best practices throughout the application  
- Structured reducers with clear action hierarchies (`DataLoadingAction`, `RewardManagementAction`)  
- Dependency injection via TCA's `@Dependency` system for testability  
- Exhaustive testing with `TestStore`  

**Data Loading Strategy**  
- Implemented **parallel, independent data loading** for better UX and app responsiveness  
- Each section (customer, points, rewards) loads independently and updates UI as soon as data arrives  
- Handles partial failures gracefully - one section failing doesn't block others  
- **Trade-off**: More complex implementation vs simpler sequential loading  
  - ✅ Pros: Better perceived performance, resilient to partial failures, responsive UI  
  - ⚠️ Cons: More complex state management and edge cases  
  - **Decision**: This approach was chosen for optimal user experience, though business/product teams should evaluate if the added complexity is justified for future maintenance  

**Error Handling**  
- Comprehensive error handling with user-friendly error toast notifications  
- Graceful degradation - sections show error states independently  
- Pull-to-refresh retries only failed sections (intelligent retry logic)  
- Prevents duplicate requests - pull-to-refresh is disabled while data is loading  
- No optimistic UI updates - UI always reflects actual server state to prevent confusion  
- API failures trigger data reload to ensure UI consistency  

**Image Loading**  
- Custom `ImageLoader` with retry logic (3 attempts with exponential backoff)  
- Simple in-memory caching via `ImageCache` for session-level performance  
- **Note**: In a production app, this should be extended with:  
  - Persistent caching between sessions  
  - Cache eviction policies (LRU, size limits)  
  - Or use battle-tested third-party libraries like **Kingfisher** or **SDWebImage**  

### Features Implemented

✅ Reward activation/deactivation with proper state management  
✅ Real-time points balance updates  
✅ Loading states for all sections with shimmer loading effect for rewards  
✅ Error handling with user-friendly toast messages  
✅ Error recovery with pull-to-refresh  
✅ Prevents duplicate API requests while loading  
✅ Image loading with automatic retry on failure  
✅ Locked/unlocked reward states based on points  
✅ Haptic feedback for reward activation/deactivation (success/error)  
✅ UI consistency - reverts on API failures (no stale state)  
✅ Comprehensive unit tests for core reducer logic  
✅ Edge case handling (e.g., active rewards loading before/after rewards list)  

### Possible Improvements

**Error Handling**
- Add timeout handling for API calls with configurable timeouts
- Implement more granular error messages based on HTTP status codes
- Add retry strategies for transient network failures (beyond images)
- Integrate crash reporting (e.g., Crashlytics) for non-fatal error logging

**Image Loading**
- Replace custom caching with production-ready library (Kingfisher/SDWebImage)
- Add persistent disk cache with size limits and TTL

**State Management**
- Evaluate if parallel loading complexity is justified vs simpler sequential loading

**UX Enhancements**
- Display more contextual error messages
- Sort rewards to show in the same order with each session

**Testing**
- Expand test coverage for edge cases
- Add integration tests for the full data flow
- Add UI tests for critical user journeys
