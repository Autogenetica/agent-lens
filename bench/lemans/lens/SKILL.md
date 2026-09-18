---
name: rails-idiom-discipline
description: "Rails Idiom Discipline skill — a pre-response verification checklist applied when the user's conversation falls within the trigger conditions of any listed item. Use this skill whenever the agent is acting as a Rails engineer solving small, well-scoped tickets against an existing production app, even when the user doesn't name the underlying patterns explicitly. (Auto-generated description; override with --description for publication.)"
license: "Pending review"
metadata:
  shaped-by: "agent-lens v0.1.0"
  shaped-at: "2026-09-16T18:44:18Z"
  source-corpus: "rails-guides.md"
  model: "claude-sonnet-4-6"
---

# Rails Idiom Discipline

Before responding to the user, internally verify each applicable item
below. These are pre-response checks — if the condition applies to the
conversation, confirm you have addressed the principle before sending
your answer. Cite the item by its short bold name when an answer turns
on it (e.g., *"Per **<item name>**, I'd suggest..."*).

---

1. **SQL injection guard** — if the user is writing or reviewing Active Record queries, have you verified that any string-interpolated conditions use parameterized placeholders (`where("col = ?", value)` or hash conditions) rather than raw string interpolation, and used `sanitize_sql_like` when building `LIKE` conditions?

2. **N+1 query check** — if the user is fetching associated records and iterating over them in views or jobs, have you verified that eager loading (`includes`, `preload`, or `eager_load`) is used to avoid one query per record, and considered `strict_loading` to catch violations automatically?

3. **Mass-assignment safety** — if the user is writing controller actions that create or update models from request params, have you verified that only explicitly permitted attributes are passed via `expect`/`permit`/`require` on `params`, and that `permit!` or `save(validate: false)` is not used without a deliberate security rationale?

4. **Uniqueness validation + DB constraint pairing** — if the user is adding a `validates :attribute, uniqueness: true` validation, have you verified that a corresponding unique index is also added to the database migration, since the model validation alone does not prevent race-condition duplicates?

5. **Validation bypass awareness** — if the user is writing code that updates or deletes records using bulk methods (`update_all`, `update_columns`, `insert_all`, `upsert`, `delete_all`, etc.), have you verified that skipping callbacks and validations is intentional and safe, and noted this clearly in the implementation?

6. **Callback side-effect caution** — if the user is adding model callbacks that write to the database (calling `update`, `save`, or similar methods on `self` or associations), have you verified the callback uses direct attribute assignment (`self.attr = val`) in `before_*` hooks rather than persistence methods that trigger another save cycle, and that external side effects (email, file deletion, external API) are placed in `after_commit` rather than `after_save`?

7. **Background job argument serialization** — if the user is defining or enqueuing Active Job jobs with Active Record objects as arguments, have you verified that GlobalID-supported objects are passed directly (letting Active Job serialize/deserialize them), and that the job is resilient to the record being deleted between enqueue and execution (e.g., via `discard_on ActiveJob::DeserializationError::RecordNotFound`)?

8. **CSRF and request authenticity** — if the user is writing non-`GET` controller actions, JavaScript `fetch` calls, or API endpoints, have you verified that `protect_from_forgery` is in place (or deliberately and safely excluded for API-only endpoints), and that the CSRF token meta tags are present in the layout?

9. **Strong parameters scope completeness** — if the user is adding a new model attribute or modifying a form, have you verified that the new attribute is included in the controller's `params.expect`/`permit` allowlist, and that nested attributes or arrays are declared with the correct structure?

10. **Fragment cache dependency tracking** — if the user is adding or modifying a cached view fragment (`cache` block) that renders partials or calls helpers, have you verified that all template dependencies are either auto-detected by Rails or explicitly declared with `# Template Dependency:` comments, and that `touch: true` is set on `belongs_to` associations where Russian-doll cache invalidation is needed?

11. **`after_commit` vs. `after_save` for external actions** — if the user is triggering emails, file operations, third-party API calls, or job enqueuing inside a model callback, have you verified the callback is placed in `after_commit` (not `after_save` or `after_create`) so it only fires after the database transaction is durably committed?

12. **Sensitive data filtering and cookie security** — if the user is logging request data, storing data in cookies, or transmitting credentials, have you verified that sensitive parameters are listed in `config.filter_parameters`, that sensitive cookie data uses `cookies.encrypted` rather than plain `cookies`, and that session fixation is addressed with `reset_session` before login?

13. **Batch processing for large datasets** — if the user is iterating over potentially large model collections (e.g., to send emails, export data, or run calculations), have you verified that `find_each` or `find_in_batches` is used instead of loading the entire collection into memory with `.all.each`?

14. **Redirect and file path safety** — if the user is building redirect URLs from user input or serving files based on user-supplied filenames, have you verified that redirect targets are validated against a permitted list or regex, and that file paths are checked with `File.expand_path` to prevent directory traversal attacks?

15. **Enqueue-after-commit for transactional safety** — if the user is enqueuing background jobs from within a model callback, service, or controller action that runs inside a database transaction, have you verified that either `enqueue_after_transaction_commit: true` is configured or the job is enqueued from an `after_commit` callback, to prevent the job from running before the associated data is visible to other database connections?
