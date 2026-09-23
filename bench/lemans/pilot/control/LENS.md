---
name: rails-idiom-discipline-control
description: "Vocabulary control for the Rails Idiom Discipline lens: the same fifteen pre-response checks, rewritten so no Rails API name, method, option, or constant appears. Not a lens; a control arm."
license: "Pending review"
metadata:
  control-for: "../../lens/SKILL.md"
  written-by: "minerva, by hand, 2026-09-22"
---

# Rails Idiom Discipline

Before responding to the user, internally verify each applicable item
below. These are pre-response checks — if the condition applies to the
conversation, confirm you have addressed the principle before sending
your answer. Cite the item by its short bold name when an answer turns
on it (e.g., *"Per **<item name>**, I'd suggest..."*).

---

1. **SQL injection guard** — if the user is writing or reviewing model-layer queries, have you verified that conditions carrying user-supplied values use the framework's placeholder or hash-condition form rather than raw string interpolation, and that wildcard pattern matches escape the user's input with the framework's escaping helper first?

2. **N+1 query check** — if the user is fetching associated records and iterating over them in views or jobs, have you verified that the association is eager-loaded through the framework's option for it rather than queried once per record, and considered the strict mode that raises on lazy loads to catch violations automatically?

3. **Mass-assignment safety** — if the user is writing controller actions that create or change models from request parameters, have you verified that only explicitly permitted attributes pass through the framework's parameter allowlisting, and that the allow-everything call or persisting with validation switched off is not used without a deliberate security rationale?

4. **Uniqueness validation + DB constraint pairing** — if the user is adding a uniqueness validation on a model attribute, have you verified that a corresponding unique index is also added to the database migration, since the model validation alone does not prevent race-condition duplicates?

5. **Validation bypass awareness** — if the user is writing code that changes, inserts, or deletes records through the bulk methods that write straight to the database (every matching row at once, columns without callbacks, many rows per statement, deletes without instantiating), have you verified that skipping callbacks and validations is intentional and safe, and noted this clearly?

6. **Callback side-effect caution** — if the user is adding model callbacks that write to the database (calling persistence methods on the record itself or its associations), have you verified the callback uses direct attribute assignment in before-hooks rather than persistence methods that trigger another write cycle, and that external side effects (email, file deletion, external API) run in the callback that fires after the transaction commits?

7. **Background job argument serialization** — if the user is defining or enqueuing background jobs with model records as arguments, have you verified that records are passed directly for the framework's global-identifier serialization to reload, and that the job is resilient to the record being deleted between enqueue and execution (e.g., by discarding itself on the deserialization not-found error)?

8. **CSRF and request authenticity** — if the user is writing state-changing controller actions, browser-side JavaScript requests, or API endpoints, have you verified that forgery protection is in place (or deliberately and safely excluded for API-only endpoints), and that the authenticity token meta tags are present in the layout?

9. **Strong parameters scope completeness** — if the user is adding a new model attribute or modifying a form, have you verified that the new attribute is included in the controller's parameter allowlist, and that nested attributes or arrays are declared with the correct structure?

10. **Fragment cache dependency tracking** — if the user is adding or modifying a cached view fragment that renders partials or calls helpers, have you verified that all template dependencies are auto-detected by the framework or declared with the template-dependency comment form, and that the parent-touching option is set on the owning association where Russian-doll invalidation is needed?

11. **Commit-time callbacks for external actions** — if the user is triggering emails, file operations, third-party API calls, or job enqueuing inside a model callback, have you verified the callback is the one that fires after the database transaction is durably committed (not the variants that fire when the row is written or created) so it runs only once the data is visible to other connections?

12. **Sensitive data filtering and cookie security** — if the user is logging request data, storing data in cookies, or transmitting credentials, have you verified that sensitive parameters are named in the application's parameter-filter configuration, that sensitive cookie data uses the encrypted jar rather than the plain one, and that session fixation is addressed by resetting the session before login?

13. **Batch processing for large datasets** — if the user is iterating over potentially large model collections (e.g., to send emails, export data, or run calculations), have you verified that the framework's batched iteration is used instead of loading the entire collection into memory at once?

14. **Redirect and file path safety** — if the user is building redirect URLs from user input or serving files by user-supplied filename, have you verified that redirect targets are validated against a permitted list or regex, and that file paths are expanded to absolute form and checked against directory traversal?

15. **Enqueue-after-commit for transactional safety** — if the user is enqueuing background jobs from within a model callback, service, or controller action that runs inside a database transaction, have you verified that either the framework's enqueue-after-commit setting is on or the job is enqueued from the after-commit callback, so the job cannot run before the associated data is visible to other database connections?
