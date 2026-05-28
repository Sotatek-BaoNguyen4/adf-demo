# Test Summary

**Last Updated**: 2026-05-28
**Total Test Cases**: 22

## Coverage by Module

| Module | Use Cases | Test Cases | Coverage |
|--------|-----------|------------|----------|
| Home   | 1         | 22         | 100%     |
| **Total** | **1** | **22**  | **100%** |

## Priority Distribution

| Priority | Count | %    |
|----------|-------|------|
| Critical | 0     | 0%   |
| High     | 13    | 59%  |
| Medium   | 9     | 41%  |
| Low      | 0     | 0%   |

## Type Distribution

| Type     | Count | %    |
|----------|-------|------|
| Positive | 4     | 18%  |
| Negative | 8     | 36%  |
| Edge     | 8     | 36%  |
| Security | 2     | 9%   |

## UC to TC Mapping

| Use Case ID  | Use Case Title                                          | Test Cases |
|--------------|---------------------------------------------------------|------------|
| UC-HOME-001  | Home Banner / Now Showing / Coming Soon / Recommended   | TC-HOME-001-01 .. TC-HOME-001-22 |

## TC Detail Index

| TC ID            | Title                                                                 | Type     | Priority |
|------------------|-----------------------------------------------------------------------|----------|----------|
| TC-HOME-001-01   | Home screen loads all sections on successful API responses            | Positive | High     |
| TC-HOME-001-02   | Banner carousel auto-rotates every 4 seconds (BR-001)                 | Positive | High     |
| TC-HOME-001-03   | Manual swipe halts auto-rotation; resumes after 4 s idle              | Positive | High     |
| TC-HOME-001-04   | Bottom navigation tab switch                                          | Positive | Medium   |
| TC-HOME-001-05   | Banner API 500 — non-blocking placeholder with retry                  | Negative | High     |
| TC-HOME-001-06   | Network unavailable — now-showing falls back to cached data           | Negative | High     |
| TC-HOME-001-07   | Recommended section hidden when unauthenticated / token expired       | Negative | High     |
| TC-HOME-001-08   | Now Showing — invalid pagination params return 400                    | Negative | Medium   |
| TC-HOME-001-09   | Empty now-showing data shows "No movies available" placeholder        | Edge     | Medium   |
| TC-HOME-001-10   | Empty coming-soon data hides section or shows placeholder             | Edge     | Medium   |
| TC-HOME-001-11   | Empty recommended data hides section                                  | Edge     | Medium   |
| TC-HOME-001-12   | Banner renders within 500ms of API response (NFR)                     | Edge     | High     |
| TC-HOME-001-13   | Recommended endpoint — forged token cannot access data                | Security | High     |
| TC-HOME-001-14   | Recommended cache is private — not served to a different user         | Security | High     |
| TC-HOME-001-15   | Network timeout maps to NetworkFailure with offline message           | Negative | High     |
| TC-HOME-001-16   | Malformed JSON body (non-list) surfaces as ParseFailure               | Negative | High     |
| TC-HOME-001-17   | DTO schema drift (missing required field) caught as ParseFailure      | Negative | High     |
| TC-HOME-001-18   | HTTP 404 on any home endpoint surfaces as NetworkFailure              | Negative | Medium   |
| TC-HOME-001-19   | Single-banner carousel does not rotate and shows 1 progress bar       | Edge     | Medium   |
| TC-HOME-001-20   | App backgrounded mid-rotation pauses; resumes correctly on resume     | Edge     | Medium   |
| TC-HOME-001-21   | Last page reached — pagination stops, no error on further scroll      | Edge     | Medium   |
| TC-HOME-001-22   | Broken banner image URL falls back gracefully                         | Edge     | Medium   |
