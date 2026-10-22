---
name: writebook-conventions
description: "Writebook Conventions skill — a pre-response verification checklist applied when the user's conversation falls within the trigger conditions of any listed item. Use this skill whenever the agent is acting as a Rails engineer solving small, well-scoped tickets against this application, keeping to the conventions its own code establishes, even when the user doesn't name the underlying patterns explicitly. (Auto-generated description; override with --description for publication.)"
license: "Pending review"
metadata:
  shaped-by: "agent-lens v0.1.0"
  shaped-at: "2026-10-05T12:37:00Z"
  source-corpus: "writebook-app.md"
  model: "claude-sonnet-4-6"
---

# Writebook Conventions

Before responding to the user, internally verify each applicable item
below. These are pre-response checks — if the condition applies to the
conversation, confirm you have addressed the principle before sending
your answer. Cite the item by its short bold name when an answer turns
on it (e.g., *"Per **<item name>**, I'd suggest..."*).

---

1. **Leaf-book scoping guard** — If adding or modifying a controller action that touches leaves, sections, pages, or pictures, have you verified that the lookup goes through `@book.leaves` (or `Book.accessable_or_published`) rather than a global `Leaf.find`, so the book-scoping security boundary is preserved?

2. **Access-level authorization check** — If writing any action that creates, edits, moves, or destroys content (leaves, books, accesses), have you confirmed that `ensure_editable` (or `ensure_can_administer`) is called as a `before_action` and not skipped inadvertently?

3. **Delegated-type consistency** — If adding a new leafable type or a method that branches on leaf type, have you ensured the type is listed in `Leafable::TYPES`, follows the `include Leafable` contract (implementing `searchable_content` and `markable`), and has a corresponding controller that inherits from `LeafablesController`?

4. **Search index hygiene** — If changing content stored on a `Page`, `Section`, or any model indexed in `leaf_search_index`, have you verified that `sanitize_for_index` is applied before writing to the FTS table, and that display-time output goes through `sanitize_search_result` or `sanitize_content`?

5. **Slug and URL routing alignment** — If working on book or leaf URLs, have you confirmed that the custom `direct` route helpers (`book_slug`, `leafable_slug`, `leafable`, `edit_leafable`) are used instead of standard path helpers, to keep slugged URLs consistent with the `/:id/:slug` routing convention?

6. **Unauthenticated-access declaration** — If making an action publicly accessible (readable without login), have you explicitly added `allow_unauthenticated_access` for only those specific actions, rather than removing the global `require_authentication` that `ApplicationController` enforces?

7. **Positionable sibling scope** — If adding a new positioned model or modifying move/ordering logic, have you verified that `positioned_within` is called with the correct parent, association, and filter arguments so that `previous`, `next`, and `move_to_position` operate within the right sibling set?

8. **Turbo Stream response parity** — If an action already has a `.turbo_stream.erb` response (create, update, destroy on leafables), have you ensured your change maintains both the `format.turbo_stream` and `format.html` branches in the controller, and that the stream template replaces/removes the correct `dom_id`?

9. **Book cache invalidation** — If changing data that is fragment-cached under `[ book, book.editable? ]` or `[ @books, signed_in? ]`, have you confirmed the relevant model has a `touch: true` association or that `updated_at` will change so Rails cache keys expire correctly?

10. **Everyone-access propagation** — If modifying book creation, access updates, or user creation logic, have you verified that `everyone_access` books automatically grant reader access to new users (via `grant_access_to_everyone_books`) and that `update_access` correctly fans out to all active users when `everyone_access?` is true?

11. **Role-gated admin actions** — If adding functionality restricted to administrators (account settings, user management, join-code reset), have you placed `ensure_can_administer` as a `before_action` and confirmed that `User#can_administer?` is the sole check rather than inline role comparisons?

12. **Markdown upload slug integrity** — If working with file attachments inside markdown content (`Page#body`), have you ensured attachments receive a `slug` on the `active_storage_attachments` record and that upload URLs go through the `/u/*slug` route backed by `ActionText::Markdown::UploadsController#show`, not direct blob URLs?

13. **Deactivation instead of deletion** — If removing a user or implementing any user-removal flow, have you confirmed the code calls `user.deactivate` (which nullifies sessions and mangles the email address) rather than `user.destroy`, preserving referential integrity with books and accesses?

14. **Edit history versioning threshold** — If modifying how page or leafable content is saved, have you verified that changes go through `leaf.edit(leafable_params:, leaf_params:)` so the 10-minute version-gate (`MINIMUM_TIME_BETWEEN_VERSIONS`) and edit duplication logic are respected, rather than calling `leafable.update!` directly?

15. **FTS virtual table raw SQL safety** — If querying or updating `leaf_search_index`, have you used `sanitize_sql` / `execute_sql_with_binds` with positional `?` binds (as the existing `Leaf::Searchable` methods do) rather than string interpolation, given that the virtual table bypasses Active Record's normal query interface?
