---
name: rails-testing-discipline-noheader
description: "Run-5 ablation of rails-testing-discipline: the same fifteen items with the standing pre-response paragraph removed. Not for distribution."
license: "Pending review"
metadata:
  shaped-by: "agent-lens v0.1.0"
  shaped-at: "2026-10-05T12:36:28Z"
  source-corpus: "rails-testing-guide.md"
  model: "claude-sonnet-4-6"
---

# Rails Testing Discipline

1. **Behaviour-per-test coverage** — If you are adding, modifying, or reviewing any feature, controller action, model method, job, mailer, or cable channel, have you written at least one dedicated test that exercises each distinct behaviour the ticket describes, rather than relying on a single omnibus test?

2. **Sad-path and validation coverage** — If the code under change enforces constraints, validations, or authorization rules, have you written tests that verify those constraints are enforced (e.g., a record fails to save, a request is rejected, an exception is raised) and not only the happy-path success case?

3. **Edge-case enumeration** — If the feature involves branching logic, boundary values, nil inputs, empty collections, or conditional flows, have you written separate tests for each branch or boundary condition rather than assuming the happy path implicitly covers them?

4. **Correct test-layer placement** — If the behaviour under test is a data rule or business logic, have you placed the test in a model test (`test/models/`); if it is a request/response contract, in a controller or integration test; and if it is a full user workflow requiring JavaScript or multi-step interaction, in a system test — rather than testing everything at one layer?

5. **System-test restraint** — If you are considering writing system tests, have you verified the scenario is a critical user path (core business workflow, complex JavaScript interaction, or multi-component integration) rather than a feature that could be adequately covered by a faster integration or unit test?

6. **HTTP response and redirect assertions** — If a controller action is created or changed, have you asserted the response status code (`:success`, `:redirect`, specific codes), any redirect destination, and relevant flash messages, not merely that the action runs without error?

7. **Database state assertions** — If code creates, updates, or destroys records, have you used `assert_difference`, `assert_no_difference`, or explicit `reload` plus attribute assertions to confirm the database state changed (or did not change) as expected, rather than only asserting on the response?

8. **Mailer delivery and content coverage** — If the code under change triggers email delivery or enqueuing, have you asserted both that the correct number of emails was sent/enqueued (`assert_emails`, `assert_enqueued_email_with`) and that the email's recipient, subject, and body content are correct?

9. **Job enqueue and execution coverage** — If the code enqueues a background job, have you asserted that the job is enqueued with the correct arguments (`assert_enqueued_with`) and, where the ticket requires verifying side effects, also asserted the outcome after `perform_enqueued_jobs` executes it?

10. **Route and URL coverage** — If new routes are added or existing ones changed, have you asserted that the routing recognises the expected path and generates the expected URL, using `assert_recognizes`, `assert_generates`, or `assert_routing` as appropriate?

11. **Fixture sufficiency** — If tests depend on fixture data, have you ensured the relevant fixture file contains all records needed to exercise the behaviour under test (including association references), so no test silently passes due to missing data returning nil rather than a real object?

12. **Time-dependent behaviour** — If the code under test branches on dates, timestamps, expiry windows, or scheduled logic, have you used `travel_to` or equivalent helpers to pin time and explicitly assert behaviour both before and after the relevant threshold?

13. **Active Storage attachment verification** — If the feature involves file uploads or attachments, have you asserted that the attachment is actually attached (`assert attachment.attached?`) and, for integration or system tests, added teardown cleanup so uploaded files do not leak between test runs?

14. **Action Cable connection and channel coverage** — If the code adds or modifies a WebSocket connection or channel subscription, have you written connection tests asserting identifier assignment or rejection, and channel tests asserting stream subscriptions or broadcast content?

15. **Test isolation confirmation** — If a test creates database records, broadcasts, or uploaded files outside the implicit transaction wrapper (e.g., with `use_transactional_tests = false`, in system tests, or via Active Storage), have you added teardown logic to clean up that state so subsequent tests are not polluted?
