# Test Cases: UC-HOME-001 — Home Banner / Now Showing / Coming Soon / Recommended

**Related UC**: [UC-HOME-001](../../usecases/home/uc-home-001-home-banner.md)
**Module**: Home
**Last Updated**: 2026-05-28

---

## TC-HOME-001-01: Home screen loads all sections on successful API responses

- **Type**: Positive
- **Priority**: High
- **Method**: UI
- **Precondition**:
  - App is installed and launched on a device/emulator with an active network connection
  - Mock interceptor returns `200` with fixture data for all four endpoints (banners, now-showing, coming-soon, recommended)
  - User is authenticated (valid Bearer JWT in storage)
- **Test Data**:
  - `GET /api/v1/home/banners` → 2 banner objects
  - `GET /api/v1/movies/now-showing?page=1&limit=10` → 10 movie objects, `meta.hasNext: true`
  - `GET /api/v1/movies/coming-soon?page=1&limit=10` → 5 movie objects
  - `GET /api/v1/movies/recommended?page=1&limit=10` → 8 movie objects sorted by `matchPercentage` desc
- **Steps**:
  1. Launch the app from cold start; observe the Home screen
  2. Verify a shimmer/loading state appears immediately for the banner area and movie sections
  3. Wait for all four API calls to resolve
  4. Verify the banner carousel renders with the first banner visible
  5. Verify the "Now Showing" horizontal row renders movie cards
  6. Verify the "Coming Soon" horizontal row renders movie cards with `expectedReleaseDate` locale-formatted
  7. Verify the "Recommended" row renders cards sorted by `matchPercentage` descending
  8. Verify the bottom navigation bar is visible with tabs: Home (active), Search, Cinemas, Community, Profile
- **Expected Result**:
  - Shimmer replaced by content within 500ms of last API response (NFR: < 500ms)
  - Banner carousel shows first banner with a page indicator
  - "Now Showing" row shows 10 cards; scroll-end triggers next-page load (`meta.hasNext: true`)
  - "Coming Soon" cards display `expectedReleaseDate` in device locale format
  - "Recommended" cards sorted by `matchPercentage` desc (e.g., 96%, 92%, 88%)
  - Bottom nav renders all 5 tabs; Home tab is highlighted/active
- **Actual Result**: __{fill on execution}__
- **Status**: Pending

---

## TC-HOME-001-02: Banner carousel auto-rotates every 4 seconds (BR-001)

- **Type**: Positive
- **Priority**: High
- **Method**: UI
- **Precondition**:
  - Home screen is loaded with ≥ 2 banners from the mock (banners fixture has exactly 3 items)
  - No user interaction with the carousel
- **Test Data**:
  - Banner 1 id: `bnr_01`, Banner 2 id: `bnr_02`, Banner 3 id: `bnr_03`
- **Steps**:
  1. Open the Home screen and wait for the banner carousel to render banner 1
  2. Wait 4 seconds without touching the carousel
  3. Observe the carousel
  4. Wait another 4 seconds
  5. Observe the carousel again
- **Expected Result**:
  - After 4 s: carousel auto-advances to banner 2
  - After another 4 s: carousel auto-advances to banner 3
  - Rotation is smooth (no jump/flash)
- **Actual Result**: __{fill on execution}__
- **Status**: Pending

---

## TC-HOME-001-03: Manual swipe halts auto-rotation; resumes after 4 s idle (AF-1)

- **Type**: Positive
- **Priority**: High
- **Method**: UI
- **Precondition**:
  - Home screen loaded with ≥ 2 banners; auto-rotation timer is running
- **Test Data**:
  - 3-banner fixture; device timer observable via widget test `pump` or manual stopwatch
- **Steps**:
  1. Wait until banner 1 is displayed and auto-rotation is active
  2. Swipe left on the banner carousel
  3. Observe that banner 2 is shown immediately
  4. Wait 3 seconds (auto-rotation should NOT fire yet)
  5. Wait 1 more second (total 4 s idle after swipe)
  6. Observe the carousel
- **Expected Result**:
  - After swipe: banner 2 is shown; auto-rotation timer resets (does not advance at the original t+4 s)
  - At 3 s after swipe: still on banner 2
  - At 4 s after swipe: carousel auto-advances to banner 3 (timer restarted correctly)
- **Actual Result**: __{fill on execution}__
- **Status**: Pending

---

## TC-HOME-001-04: Bottom navigation tab switch

- **Type**: Positive
- **Priority**: Medium
- **Method**: UI
- **Precondition**:
  - Home screen is fully loaded; Home tab is active
- **Test Data**: None
- **Steps**:
  1. Tap the "Search" tab in the bottom navigation bar
  2. Observe the active tab indicator and rendered screen
  3. Tap "Home" tab
  4. Observe the active tab indicator and rendered screen
- **Expected Result**:
  - After step 1: Search tab is highlighted; Search screen renders; Home tab returns to inactive state
  - After step 3: Home tab is highlighted; Home screen is restored; Search tab returns to inactive state
- **Actual Result**: __{fill on execution}__
- **Status**: Pending

---

## TC-HOME-001-05: Banner API returns 500 — non-blocking placeholder with retry (EF-1 / AC-HOME-001-04)

- **Type**: Negative
- **Priority**: High
- **Method**: UI
- **Precondition**:
  - Mock interceptor configured to return `500 INTERNAL_ERROR` for `GET /api/v1/home/banners`
  - Now-showing and coming-soon mocks return `200` normally
- **Test Data**:
  - Banner endpoint: `500 {"error": {"code": "INTERNAL_ERROR"}}`
- **Steps**:
  1. Launch the app to the Home screen
  2. Observe the banner area while other sections load
  3. Observe the "Now Showing" and "Coming Soon" sections
  4. Tap the retry affordance in the banner area
- **Expected Result**:
  - Banner area shows a non-blocking placeholder (e.g., grey rectangle or "Failed to load" text) with an inline retry button/icon
  - "Now Showing" and "Coming Soon" sections render normally — they are not blocked by the banner failure
  - No full-screen error overlay
  - Tapping retry re-fires `GET /api/v1/home/banners`; if mock now returns `200`, banner carousel renders
- **Actual Result**: __{fill on execution}__
- **Status**: Pending

---

## TC-HOME-001-06: Network unavailable — now-showing falls back to cached data (BR-002 / AC-HOME-002-03)

- **Type**: Negative
- **Priority**: High
- **Method**: UI
- **Precondition**:
  - App has previously loaded the Home screen with a valid now-showing response (Hive cache populated)
  - Device network is disabled (airplane mode or network emulation off)
- **Test Data**:
  - Cached payload from previous successful load: 10 now-showing movies
- **Steps**:
  1. While online, open Home screen and wait for now-showing to load
  2. Background the app or wait for cache to persist (Hive TTL = 300 s)
  3. Disable network connectivity
  4. Reopen or refresh the Home screen
  5. Observe the "Now Showing" section
- **Expected Result**:
  - "Now Showing" renders the cached 10 movies (data is not empty/error)
  - A subtle "offline" indicator is displayed (e.g., icon, banner, or toast) — not a blocking error dialog
  - Banner area may show placeholder (no cache); this is acceptable
- **Actual Result**: __{fill on execution}__
- **Status**: Pending

---

## TC-HOME-001-07: Recommended section hidden when unauthenticated / token expired (AC-HOME-004-02)

- **Type**: Negative
- **Priority**: High
- **Method**: UI
- **Precondition**:
  - User is unauthenticated OR stored JWT is expired
  - Mock interceptor returns `401 UNAUTHENTICATED` for `GET /api/v1/movies/recommended`
  - Banners, now-showing, coming-soon mocks return `200`
- **Test Data**:
  - No valid JWT in local storage
  - Recommended endpoint: `401 {"error": {"code": "UNAUTHENTICATED"}}`
- **Steps**:
  1. Launch the app without logging in (or with an expired token)
  2. Navigate to the Home screen
  3. Observe whether the "Recommended" section appears
- **Expected Result**:
  - "Recommended" section is completely hidden from the Home screen
  - No error toast or error message related to recommended
  - Other sections (banners, now-showing, coming-soon) render normally
- **Actual Result**: __{fill on execution}__
- **Status**: Pending

---

## TC-HOME-001-08: Now Showing — invalid pagination params return 400

- **Type**: Negative
- **Priority**: Medium
- **Method**: UI
- **Precondition**:
  - App is online; mock interceptor returns `400 VALIDATION_ERROR` when `page=0` or `limit=0`
- **Test Data**:
  - `GET /api/v1/movies/now-showing?page=0&limit=10` → `400 {"error": {"code": "VALIDATION_ERROR"}}`
- **Steps**:
  1. Trigger pagination with `page=0` (simulate via widget test or interceptor config)
  2. Observe the "Now Showing" section behavior
- **Expected Result**:
  - UI does not crash
  - "Now Showing" section shows an error state or retains the previous page's data
  - No unhandled exception or blank white screen
- **Actual Result**: __{fill on execution}__
- **Status**: Pending

---

## TC-HOME-001-09: Empty now-showing data shows "No movies available" placeholder (EF-2 / AC-HOME-002-02)

- **Type**: Edge
- **Priority**: Medium
- **Method**: UI
- **Precondition**:
  - Mock interceptor configured to return `200` with empty `data` array for `GET /api/v1/movies/now-showing`
- **Test Data**:
  - `{"data": [], "meta": {"page": 1, "limit": 10, "total": 0, "hasNext": false}}`
- **Steps**:
  1. Launch the app to the Home screen
  2. Observe the "Now Showing" section after loading completes
- **Expected Result**:
  - "Now Showing" section displays a "No movies available" placeholder widget (text or illustration)
  - Section is not hidden (it remains visible with the placeholder)
  - Other sections render normally
- **Actual Result**: __{fill on execution}__
- **Status**: Pending

---

## TC-HOME-001-10: Empty coming-soon data hides section or shows placeholder (AC-HOME-003-02)

- **Type**: Edge
- **Priority**: Medium
- **Method**: UI
- **Precondition**:
  - Mock interceptor returns `200` with empty `data` array for `GET /api/v1/movies/coming-soon`
- **Test Data**:
  - `{"data": [], "meta": {"page": 1, "limit": 10, "total": 0, "hasNext": false}}`
- **Steps**:
  1. Launch the app to the Home screen
  2. Observe the "Coming Soon" section after load
- **Expected Result**:
  - "Coming Soon" section is either hidden entirely OR shows a placeholder
  - No crash or layout overflow
  - Other sections render normally
- **Actual Result**: __{fill on execution}__
- **Status**: Pending

---

## TC-HOME-001-11: Empty recommended data hides section (AC-HOME-004-03)

- **Type**: Edge
- **Priority**: Medium
- **Method**: UI
- **Precondition**:
  - User is authenticated; mock returns `200` with empty `data` for `GET /api/v1/movies/recommended`
- **Test Data**:
  - `{"data": [], "meta": {"page": 1, "limit": 10, "total": 0, "hasNext": false}}`
- **Steps**:
  1. Launch the app to the Home screen as an authenticated user
  2. Observe the "Recommended" section after load
- **Expected Result**:
  - "Recommended" section is completely hidden from the Home screen
  - No "No movies available" placeholder shown (section simply absent)
  - Other sections render normally
- **Actual Result**: __{fill on execution}__
- **Status**: Pending

---

## TC-HOME-001-12: Banner renders within 500ms of API response (AC-HOME-001-01 / NFR)

- **Type**: Edge
- **Priority**: High
- **Method**: UI
- **Precondition**:
  - App on clean cold start; mock interceptor responds immediately (< 50 ms simulated delay)
  - ≥ 1 banner in mock fixture
- **Test Data**:
  - Mock latency: 0 ms; timestamp captured via widget test `pump`
- **Steps**:
  1. Start a stopwatch at the point the `200` response is received for banners
  2. Observe when the carousel renders the first banner (shimmer disappears, image visible)
- **Expected Result**:
  - Elapsed time between response received and banner rendered is < 500 ms
- **Actual Result**: __{fill on execution}__
- **Status**: Pending

---

## TC-HOME-001-13: Recommended endpoint — another user's token cannot access another user's data

- **Type**: Security
- **Priority**: High
- **Method**: UI
- **Precondition**:
  - Two test accounts exist: User A (valid JWT) and User B
  - Mock interceptor validates the JWT sub claim and returns `401` for mismatched or forged tokens
- **Test Data**:
  - Forged JWT with User B's `sub` but signed with wrong secret
  - Interceptor: returns `401 UNAUTHENTICATED` for invalid JWT
- **Steps**:
  1. Inject a forged/expired JWT into app local storage (replace User A's token)
  2. Open the Home screen
  3. Observe the "Recommended" section
  4. Verify no User B's recommendations are leaked in the response
- **Expected Result**:
  - `GET /api/v1/movies/recommended` returns `401`
  - "Recommended" section is hidden — no movie data rendered
  - No User B data appears anywhere on screen
- **Actual Result**: __{fill on execution}__
- **Status**: Pending

---

## TC-HOME-001-14: Recommended cache is private — must not be served to a different user

- **Type**: Security
- **Priority**: High
- **Method**: UI
- **Precondition**:
  - User A has a valid cached recommended payload in Hive
  - User A logs out; User B logs in on the same device
- **Test Data**:
  - User A cached data: 8 recommended movies tied to User A's profile
  - User B has a different JWT (fresh login)
- **Steps**:
  1. User A opens Home; recommended section loads and caches (Hive, `Cache-Control: private, max-age=120`)
  2. User A logs out
  3. User B logs in on the same device
  4. User B opens Home screen
  5. Observe the "Recommended" section for User B
- **Expected Result**:
  - User B's "Recommended" section either fetches fresh data from the API or is empty/hidden
  - User A's cached recommendations are NOT displayed to User B
  - Hive cache is cleared/invalidated on logout (per-user cache isolation)
- **Actual Result**: __{fill on execution}__
- **Status**: Pending
