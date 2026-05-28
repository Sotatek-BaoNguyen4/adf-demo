# UC-HOME-001: Home Banner - Now Showing - Coming Soon - Recommended

**Module**: Home
**Actor**: User
**Priority**: High
**Last Updated**: 2026-05-28

## Precondition

- The application is launched and the user is on the Home screen.
- The device has an active internet connection.

## Main Flow

1. The User opens the mobile application and navigates to the Home screen.
2. The System displays a persistent bottom navigation bar with tabs: Home (active), Search, Cinemas, Community, and Profile.
3. The System displays a loading state (shimmer effects) for the main content area.
4. The System concurrently fetches data for:
   - Advertisement Banners (Mocked from IMDB)
   - Now Showing Movies (Mocked from IMDB)
   - Coming Soon Movies (Mocked from IMDB)
   - Recommended Movies (Mocked from IMDB)
5. The System replaces the loading state with the fetched content.
6. The System starts the auto-rotation of the banner carousel (e.g., every 5 seconds).
7. The User scrolls horizontally to view "Now Showing", "Coming Soon", and "Recommended" movies.
8. The User can tap any tab in the bottom navigation to switch contexts.

## Alternative Flows

### AF-1: Manual Carousel Navigation
- At step 6, if the User swipes left or right on the banner carousel:
  1. The System halts the auto-rotation timer.
  2. The System moves the carousel to the next or previous banner based on the swipe direction.
  3. The System restarts the auto-rotation timer after 5 seconds of inactivity.

## Exception Flows

### EF-1: Network Failure
- At step 4, if the internet connection is lost or the API fails:
  1. The System displays a network error message or "Failed to load content".
  2. The System displays a "Pull to Refresh" or "Retry" button.

### EF-2: Empty Data
- At step 5, if the API returns an empty list for "Now Showing", "Coming Soon", or "Recommended":
  1. The System hides the respective section or displays a "No movies available" placeholder.

## Postcondition

- The Home screen displays the latest banners, currently showing, upcoming, and recommended movies to the user.

## Business Rules

- BR-001: Banners must auto-rotate every 5 seconds
- BR-002: "Now Showing", "Coming Soon", and "Recommended" should be cached locally

## Acceptance Criteria

Detailed Given/When/Then scenarios are defined in [FSD §2 Acceptance Criteria](../../project-fsd.md#2-acceptance-criteria). Summary:

- AC-HOME-001-01 — Banners render within 500ms on `200` response (FR-HOME-001)
- AC-HOME-001-02 — Carousel auto-advances every 5s (FR-HOME-001, BR-001)
- AC-HOME-001-03 — Manual swipe halts auto-rotation; resumes after 5s idle (FR-HOME-001)
- AC-HOME-001-04 — Banner API `500` shows non-blocking placeholder with retry (FR-HOME-001)
- AC-HOME-002-01 — Now-showing renders paginated list with `meta.hasNext` (FR-HOME-002)
- AC-HOME-002-02 — Empty now-showing data shows "No movies available" (FR-HOME-002)
- AC-HOME-002-03 — Offline falls back to cached now-showing payload (FR-HOME-002, BR-002)
- AC-HOME-003-01 — Coming-soon renders cards with locale-formatted `expectedReleaseDate` (FR-HOME-003)
- AC-HOME-003-02 — Empty coming-soon data hides section or shows placeholder (FR-HOME-003)
- AC-HOME-004-01 — Authenticated `200` renders recommended sorted by `matchPercentage` desc (FR-HOME-004)
- AC-HOME-004-02 — `401` from recommended endpoint hides the section (FR-HOME-004)
- AC-HOME-004-03 — Empty recommended data hides the section (FR-HOME-004)
- AC-HOME-005-01 — Tab tap switches active state and renders target screen (FR-HOME-005)
- AC-HOME-005-02 — Deep link preserves target tab as active on cold start (FR-HOME-005)
