# AGENTS.md  
  
## Project Overview  
**FareLess** is an iOS application that shows users how much money they save by riding an electric scooter instead of taking a taxi.  
The MVP records a scooter trip, determines the start and finish coordinates, requests an estimated taxi price for the same route, and adds the result to the user’s accumulated savings.  
The application should be simple, fast, privacy-conscious, and usable without registration.  
   
⸻  
   
## Product Goal  
The main product hypothesis is:  
Users will regularly return to an application that automatically shows how much money they have saved by choosing a scooter instead of a taxi.  
The MVP must validate whether users:  
* record multiple trips;  
* return to view accumulated savings;  
* understand the value of the product without explanation;  
* trust the estimated taxi price;  
* find the experience sufficiently automatic.  
   
⸻  
   
## MVP Scope  
FareLess 1.0 must include:  
* onboarding;  
* location permission handling;  
* manual trip start;  
* manual trip completion;  
* GPS route recording;  
* trip duration calculation;  
* trip distance calculation;  
* start and finish coordinates;  
* estimated taxi price request;  
* calculated savings;  
* trip history;  
* trip details;  
* monthly and lifetime savings;  
* local data storage;  
* basic error handling.  
FareLess 1.0 must not include:  
* user accounts;  
* authentication;  
* subscriptions;  
* advertisements;  
* social features;  
* friends or leaderboards;  
* financial goals;  
* Apple Watch support;  
* Apple Health integration;  
* automatic trip detection;  
* background trip detection without explicit user action;  
* cloud synchronization;  
* multiple transport types;  
* maintenance costs;  
* scooter depreciation;  
* AI features;  
* referral programs;  
* complex analytics;  
* backend infrastructure unless required for API security.  
   
⸻  
   
## Platform  
* iOS  
* Minimum supported version: iOS 17  
* Primary device: iPhone  
* Orientation: portrait  
* Interface framework: SwiftUI  
* Language: Swift  
* Data persistence: SwiftData  
* Location tracking: Core Location  
* Maps: MapKit  
* Notifications: UserNotifications  
* Widgets are optional for MVP and must not block release.  
   
⸻  
   
## Core User Flow  
1. User launches FareLess.  
2. User completes onboarding.  
3. User grants location access.  
4. User taps **Start Ride**.  
5. FareLess records the route.  
6. User taps **Finish Ride**.  
7. FareLess validates the trip.  
8. FareLess requests an estimated taxi price.  
9. FareLess saves the trip locally.  
10. FareLess displays the amount saved.  
11. The home screen updates total savings.  
The primary flow should require as few taps as possible.  
   
⸻  
   
## Main Screens  
**1. Onboarding**  
The onboarding should explain:  
* what FareLess does;  
* that taxi prices are approximate;  
* why location access is required;  
* that trip data is stored locally.  
The onboarding should contain no more than three screens.  
**2. Home**  
The home screen should display:  
* savings today;  
* savings this month;  
* savings for all time;  
* number of completed trips;  
* primary **Start Ride** button;  
* recent trips.  
The current savings amount is the most important element on the screen.  
**3. Active Ride**  
The active ride screen should display:  
* elapsed time;  
* current distance;  
* ride status;  
* optional map preview;  
* **Finish Ride** button.  
The application must make it obvious that location recording is active.  
**4. Ride Result**  
The result screen should display:  
* estimated taxi price;  
* calculated savings;  
* distance;  
* duration;  
* date;  
* confirmation that the trip was saved.  
The savings amount should be the dominant visual element.  
**5. Ride History**  
The history screen should display:  
* trip date;  
* distance;  
* duration;  
* estimated taxi price;  
* saved amount.  
Trips should be ordered from newest to oldest.  
**6. Ride Details**  
The details screen should display:  
* route map;  
* start point;  
* finish point;  
* distance;  
* duration;  
* estimated taxi price;  
* savings;  
* trip date and time.  
   
⸻  
   
## Savings Calculation  
For MVP:  
```
savings = estimatedTaxiPrice - scooterTripCost

```
For users with a personal scooter:  
```
scooterTripCost = 0

```
Therefore:  
```
savings = estimatedTaxiPrice

```
The application should store the taxi estimate returned at the moment the trip is completed.  
Historical trip values must not be recalculated automatically when pricing logic changes.  
All monetary values should be stored in minor currency units.  
Example:  
```
620 RUB = 62000 kopecks

```
Avoid storing currency values as floating-point numbers.  
   
⸻  
   
## Taxi Price Provider  
Taxi pricing must be accessed through an abstraction.  
Example protocol:  
```
protocol TaxiPriceProviding {
    func estimatePrice(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D
    ) async throws -> TaxiPriceEstimate
}

```
The UI and trip logic must not depend directly on a specific provider.  
Supported implementations may include:  
* Yandex taxi price API;  
* internal estimation model;  
* mock provider for testing.  
The application should be able to switch providers without changing the UI layer.  
API keys must never be committed to the repository.  
When direct client-side API access would expose a secret, use a minimal backend proxy.  
   
⸻  
   
## Location Tracking  
Use CLLocationManager.  
The application should request only the permissions required for MVP.  
Preferred permission:  
```
When In Use

```
Do not request permanent background location access unless it is required by an implemented feature.  
During an active ride:  
* record valid location points;  
* ignore stale location points;  
* ignore points with poor accuracy;  
* prevent unrealistic distance jumps;  
* calculate total distance from accepted points;  
* keep location updates active when the application is temporarily backgrounded if permitted.  
Recommended validation rules:  
* horizontal accuracy must be acceptable;  
* timestamp must be recent;  
* movement speed must be plausible;  
* single-point jumps should be filtered;  
* trips shorter than the configured minimum should be rejected or flagged.  
Initial suggested limits:  
```
Minimum trip distance: 300 meters
Minimum trip duration: 2 minutes
Maximum plausible speed: 45 km/h

```
These values should be configurable constants.  
   
⸻  
   
## Trip State  
A trip may have the following states:  
```
enum RideState {
    case idle
    case starting
    case active
    case finishing
    case requestingTaxiPrice
    case completed
    case failed
}

```
Only one active trip may exist at a time.  
The application should persist enough active trip state to recover after:  
* app termination;  
* application crash;  
* temporary background suspension.  
A user must not lose an active trip because the UI process restarted.  
   
⸻  
   
## Data Model  
Suggested SwiftData model:  
```
@Model
final class Ride {
    var id: UUID
    var startedAt: Date
    var finishedAt: Date

    var startLatitude: Double
    var startLongitude: Double
    var endLatitude: Double
    var endLongitude: Double

    var distanceMeters: Double
    var durationSeconds: Double

    var taxiPriceMinorUnits: Int
    var scooterCostMinorUnits: Int
    var savingsMinorUnits: Int
    var currencyCode: String

    var pricingProvider: String
    var pricingWasEstimated: Bool

    var routeData: Data?
}

```
Route coordinates should be encoded efficiently.  
Do not store unnecessary high-frequency location data permanently.  
Consider simplifying the route before saving.  
   
⸻  
   
## Architecture  
Use a simple feature-based architecture.  
Suggested structure:  
```
FareLess/
├── App/
├── Core/
│   ├── Location/
│   ├── Networking/
│   ├── Persistence/
│   ├── Pricing/
│   └── Utilities/
├── Features/
│   ├── Onboarding/
│   ├── Home/
│   ├── ActiveRide/
│   ├── RideResult/
│   ├── RideHistory/
│   ├── RideDetails/
│   └── Settings/
├── Models/
├── Resources/
└── Tests/

```
Use:  
* SwiftUI views;  
* observable view models;  
* dependency injection through initializers;  
* protocols for external dependencies;  
* async/await for asynchronous operations.  
Avoid introducing complex architecture frameworks in MVP.  
Do not use third-party dependencies unless they solve a clear problem that cannot be handled reasonably with Apple frameworks.  
   
⸻  
   
## Source of Truth  
Business logic should not live inside SwiftUI views.  
Views should render state and send user actions.  
Recommended separation:  
* Views: presentation;  
* View models: screen state and user actions;  
* Services: location, pricing, notifications;  
* Repositories: persistence;  
* Models: business data.  
Avoid duplicated calculations across screens.  
Monthly and lifetime totals should be calculated through one shared service or repository.  
   
⸻  
   
## Error Handling  
The application must handle:  
* location permission denied;  
* location services unavailable;  
* insufficient GPS accuracy;  
* trip too short;  
* no internet connection;  
* taxi pricing API timeout;  
* taxi pricing API rejection;  
* invalid pricing response;  
* active trip interrupted;  
* data persistence failure.  
Error messages must be understandable to non-technical users.  
Example:  
```
Не удалось получить стоимость такси. Поездка сохранена, а цену можно рассчитать позже.

```
A failed price request should not delete the recorded trip.  
The ride may be saved with a pending pricing state and retried later.  
   
⸻  
   
## Offline Behavior  
Trip recording must work without internet access.  
When internet access is unavailable:  
1. save the trip;  
2. mark taxi pricing as pending;  
3. retry when connectivity returns or when the user opens the app;  
4. update savings after receiving a valid price.  
Do not block ride completion because of a network failure.  
   
⸻  
   
## Privacy  
The application handles sensitive location data.  
Requirements:  
* explain clearly why location is needed;  
* store trip history locally by default;  
* do not collect location data outside an active trip;  
* do not transmit full routes unless required;  
* send only necessary origin and destination data to the pricing provider;  
* do not include analytics SDKs in MVP unless explicitly approved;  
* provide a way to delete trip history;  
* avoid logging coordinates in production logs.  
The App Store privacy declaration must accurately describe all collected data.  
   
⸻  
   
## Security  
* Never commit API keys.  
* Never hardcode production secrets.  
* Use .xcconfig or environment-based configuration for non-secret values.  
* Use a backend proxy when the API requires a confidential credential.  
* Validate all external API responses.  
* Use HTTPS only.  
* Avoid logging tokens, coordinates, or pricing responses containing identifiers.  
* Keep dependency count minimal.  
   
⸻  
   
## UI Principles  
The visual priority is:  
1. saved amount;  
2. primary ride action;  
3. monthly progress;  
4. recent trips.  
The design should feel:  
* simple;  
* optimistic;  
* financially motivating;  
* modern;  
* uncluttered.  
Avoid:  
* dense dashboards;  
* unnecessary charts;  
* excessive settings;  
* technical transport terminology;  
* gamification that distracts from savings.  
Use native Apple components where possible.  
Support:  
* Dynamic Type;  
* VoiceOver;  
* light mode;  
* dark mode;  
* safe area insets;  
* localization-ready strings.  
   
⸻  
   
## Localization  
The initial interface language may be Russian.  
All user-facing strings must be stored in localization resources.  
Do not hardcode user-facing text inside views.  
Initial currency:  
```
RUB

```
Currency formatting must use FormatStyle and the user’s locale.  
The architecture should support additional currencies later.  
   
⸻  
   
## Analytics  
MVP analytics should remain minimal.  
Recommended events:  
```
onboarding_completed
location_permission_granted
location_permission_denied
ride_started
ride_completed
ride_discarded
taxi_estimate_requested
taxi_estimate_succeeded
taxi_estimate_failed
ride_result_viewed
history_viewed

```
Do not send exact coordinates to analytics.  
Useful product metrics:  
* number of completed rides;  
* rides per active user;  
* percentage of started rides completed;  
* taxi estimate success rate;  
* day-1 and day-7 retention;  
* average savings per ride;  
* percentage of users with three or more rides.  
Analytics must be removable or replaceable.  
   
⸻  
   
## Testing Requirements  
**Unit Tests**  
Cover:  
* savings calculation;  
* distance validation;  
* trip duration calculation;  
* monthly totals;  
* lifetime totals;  
* taxi response parsing;  
* location point filtering;  
* trip state transitions;  
* pending pricing retry logic.  
**UI Tests**  
Cover the primary flow:  
1. complete onboarding;  
2. start a ride;  
3. simulate location points;  
4. finish the ride;  
5. receive mocked taxi pricing;  
6. see result;  
7. verify trip appears in history.  
**Mocking**  
Provide mocks for:  
* location service;  
* taxi pricing provider;  
* ride repository;  
* notification service;  
* network status service.  
Tests must not make live API calls.  
   
⸻  
   
## Code Style  
Follow standard Swift conventions.  
Requirements:  
* meaningful type and variable names;  
* small focused methods;  
* explicit access control;  
* no force unwraps in production code;  
* no force casts;  
* no ignored errors;  
* no business logic in views;  
* no singletons unless required by Apple APIs;  
* no unnecessary abstractions;  
* no commented-out code;  
* no dead code;  
* no placeholder TODOs in release branches.  
Prefer:  
```
guard

```
for early exits.  
Prefer structured concurrency with:  
```
async/await

```
Avoid callback-based APIs in new code unless wrapping Apple frameworks.  
   
⸻  
   
## Git Conventions  
Branches:  
```
feature/<feature-name>
fix/<bug-name>
chore/<task-name>

```
Commit examples:  
```
feat: add active ride tracking
feat: add taxi price provider abstraction
fix: prevent duplicate active rides
fix: handle denied location permission
test: add savings calculation tests
chore: configure localization resources

```
Commits should be small and focused.  
Do not commit:  
* API secrets;  
* build artifacts;  
* personal Xcode settings;  
* temporary files;  
* production credentials.  
   
⸻  
   
## Definition of Done  
A feature is complete when:  
* it satisfies the product requirement;  
* it handles loading, empty, success, and error states;  
* it is accessible;  
* it has appropriate unit tests;  
* it does not expose secrets;  
* it does not introduce warnings;  
* it works on the minimum supported iOS version;  
* user-facing strings are localized;  
* analytics events are added when applicable;  
* the primary flow remains functional.  
   
⸻  
   
## Release Criteria for MVP 1.0  
FareLess 1.0 is ready for release when:  
* onboarding works;  
* location permission flow works;  
* users can start and finish a ride;  
* route distance and duration are reliable;  
* taxi estimates are received or safely deferred;  
* savings are calculated correctly;  
* rides persist after restarting the app;  
* history and details screens work;  
* users can delete ride data;  
* offline ride completion works;  
* critical unit and UI tests pass;  
* no API secrets are present in the application bundle unless explicitly safe;  
* App Store privacy information is prepared;  
* the app contains no known crash in the main flow.  
   
⸻  
   
## Agent Instructions  
When modifying this repository:  
1. Read this file before making changes.  
2. Preserve the narrow MVP scope.  
3. Do not add features that are not required.  
4. Prefer Apple-native frameworks.  
5. Keep external services behind protocols.  
6. Protect user location data.  
7. Never expose API secrets.  
8. Add tests for business logic changes.  
9. Do not break offline trip recording.  
10. Keep the primary flow fast and obvious.  
11. Explain material architectural changes in the pull request.  
12. Flag any uncertainty involving taxi API terms, App Store rules, or background location behavior.  
When multiple implementations are possible, choose the simplest solution that:  
* is reliable;  
* is testable;  
* protects user privacy;  
* can evolve after product validation.  
The priority order is:  
```
Product clarity
→ Reliability
→ Privacy
→ Simplicity
→ Extensibility
→ Visual polish

```
Этот вариант можно положить в корень репозитория как AGENTS.md.  
