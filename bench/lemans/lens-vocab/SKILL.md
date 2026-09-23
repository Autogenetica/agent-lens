---
name: rails-idiom-discipline-vocab-control
description: "Control variant of the Rails Idiom Discipline lens for the lemans pilot: the same fifteen items, same order, same trigger conditions, with every Rails API identifier replaced by a plain-language description. Exists to separate the effect of a pre-response checklist from the effect of having Rails API names in context. Not for distribution."
license: "Pending review"
metadata:
  derived-from: "bench/lemans/lens/SKILL.md (shaped 2026-09-16T18:44:18Z, claude-sonnet-4-6)"
  edited-by: "Minerva, 2026-09-23, by hand"
  purpose: "vocabulary control arm"
---

# Rails Idiom Discipline

Before responding to the user, internally verify each applicable item
below. These are pre-response checks — if the condition applies to the
conversation, confirm you have addressed the principle before sending
your answer. Cite the item by its short bold name when an answer turns
on it (e.g., *"Per **<item name>**, I'd suggest..."*).

---

1. **SQL injection guard** — if the user is writing or reviewing database queries, have you verified that any string-built conditions use placeholder binding or hash conditions rather than raw string interpolation, and used the framework's escaping helper when building pattern-match conditions?

2. **N+1 query check** — if the user is fetching associated records and iterating over them in views or jobs, have you verified that the associations are loaded up front in a single pass to avoid one query per record, and considered the framework's mode that raises on lazy association loads to catch violations automatically?

3. **Mass-assignment safety** — if the user is writing controller actions that create or update models from request parameters, have you verified that only explicitly allowlisted attributes are passed through the framework's parameter filtering, and that blanket permission or validation-skipping saves are not used without a deliberate security rationale?

4. **Uniqueness validation + DB constraint pairing** — if the user is adding a model-level uniqueness validation, have you verified that a corresponding unique index is also added in the migration, since the model validation alone does not prevent race-condition duplicates?

5. **Validation bypass awareness** — if the user is writing code that updates, inserts, or deletes records using the bulk methods that write straight to the database, have you verified that skipping callbacks and validations is intentional and safe, and noted this clearly in the implementation?

6. **Callback side-effect caution** — if the user is adding model callbacks that write to the database (persisting the record itself or its associations from inside the callback), have you verified the callback uses direct attribute assignment in the before-hooks rather than persistence methods that trigger another save cycle, and that external side effects (email, file deletion, external API) are placed in the callback that runs after the transaction commits rather than the one that runs after save?

7. **Background job argument serialization** — if the user is defining or enqueuing background jobs with model instances as arguments, have you verified that the records are passed directly and left to the job framework's global-identifier serialization, and that the job is resilient to the record being deleted between enqueue and execution (for example by discarding jobs whose record can no longer be found)?

8. **CSRF and request authenticity** — if the user is writing non-read controller actions, JavaScript requests, or API endpoints, have you verified that request forgery protection is in place (or deliberately and safely excluded for API-only endpoints), and that the forgery-token meta tags are present in the layout?

9. **Strong parameters scope completeness** — if the user is adding a new model attribute or modifying a form, have you verified that the new attribute is included in the controller's parameter allowlist, and that nested attributes or arrays are declared with the correct structure?

10. **Fragment cache dependency tracking** — if the user is adding or modifying a cached view fragment that renders partials or calls helpers, have you verified that all template dependencies are either auto-detected by the framework or explicitly declared with dependency comments, and that the parent association is set to update its timestamp on child changes where nested cache invalidation is needed?

11. **After-commit vs. after-save for external actions** — if the user is triggering emails, file operations, third-party API calls, or job enqueuing inside a model callback, have you verified the callback is the one that fires after the database transaction is durably committed, not the one that fires on save or create, so it cannot run on data that later rolls back?

12. **Sensitive data filtering and cookie security** — if the user is logging request data, storing data in cookies, or transmitting credentials, have you verified that sensitive parameters are listed in the framework's log filter, that sensitive cookie data uses the encrypted cookie jar rather than the plain one, and that session fixation is addressed by resetting the session before login?

13. **Batch processing for large datasets** — if the user is iterating over potentially large model collections (for example to send emails, export data, or run calculations), have you verified that the records are loaded in batches instead of loading the entire collection into memory and iterating it?

14. **Redirect and file path safety** — if the user is building redirect URLs from user input or serving files based on user-supplied filenames, have you verified that redirect targets are validated against a permitted list or pattern, and that file paths are resolved to absolute form and checked to prevent directory traversal attacks?

15. **Enqueue-after-commit for transactional safety** — if the user is enqueuing background jobs from within a model callback, service, or controller action that runs inside a database transaction, have you verified that either the framework's enqueue-after-commit setting is enabled or the job is enqueued from the after-commit callback, to prevent the job from running before the associated data is visible to other database connections?
