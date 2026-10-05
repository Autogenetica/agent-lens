# Writebook application corpus (lemans lens-crafting, run 4 app arm)

Source: https://github.com/basecamp/writebook at tag v1.2.1 (the version the Agents on Rails tasks target). Schema, routes, and app code concatenated with a per-file banner, unmodified.
License: see the repository.



<!-- ===== db/schema.rb ===== -->

```
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2024_09_28_005927) do
  create_table "accesses", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "book_id", null: false
    t.string "level", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_accesses_on_book_id"
    t.index ["user_id", "book_id"], name: "index_accesses_on_user_id_and_book_id", unique: true
    t.index ["user_id"], name: "index_accesses_on_user_id"
  end

  create_table "accounts", force: :cascade do |t|
    t.string "name", null: false
    t.string "join_code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "custom_styles"
  end

  create_table "action_text_markdowns", force: :cascade do |t|
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.string "name", null: false
    t.text "content", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id"], name: "index_action_text_markdowns_on_record"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "slug"
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
    t.index ["slug"], name: "index_active_storage_attachments_on_slug", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "books", force: :cascade do |t|
    t.string "title", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "subtitle"
    t.string "author"
    t.boolean "published", default: false, null: false
    t.string "slug", null: false
    t.boolean "everyone_access", default: true, null: false
    t.string "theme", default: "blue", null: false
    t.index ["published"], name: "index_books_on_published"
  end

  create_table "edits", force: :cascade do |t|
    t.integer "leaf_id", null: false
    t.string "leafable_type", null: false
    t.integer "leafable_id", null: false
    t.string "action", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["leaf_id"], name: "index_edits_on_leaf_id"
    t.index ["leafable_type", "leafable_id"], name: "index_edits_on_leafable"
  end

  create_table "leaves", force: :cascade do |t|
    t.integer "book_id", null: false
    t.string "leafable_type", null: false
    t.integer "leafable_id", null: false
    t.float "position_score", null: false
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title", null: false
    t.index ["book_id"], name: "index_leaves_on_book_id"
    t.index ["leafable_type", "leafable_id"], name: "index_leafs_on_leafable"
  end

  create_table "pages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pictures", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "caption"
  end

  create_table "sections", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "theme"
    t.text "body"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "token", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "last_active_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_sessions_on_token", unique: true
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.integer "role", null: false
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["name"], name: "index_users_on_name", unique: true
  end

  add_foreign_key "accesses", "books"
  add_foreign_key "accesses", "users"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "edits", "leaves"
  add_foreign_key "leaves", "books"
  add_foreign_key "sessions", "users"

  # Virtual tables defined in this database.
  # Note that virtual tables may not work with other database engines. Be careful if changing database.
  create_virtual_table "leaf_search_index", "fts5", ["title", "content", "tokenize='porter'"]
end

```


<!-- ===== config/routes.rb ===== -->

```
Rails.application.routes.draw do
  root "books#index"

  resource :first_run, only: %i[ show create ]

  resource :session, only: %i[ new create destroy ] do
    scope module: "sessions" do
      resources :transfers, only: %i[ show update ]
    end
  end

  get "join/:join_code", to: "users#new", as: :join
  post "join/:join_code", to: "users#create"

  resource :account do
    scope module: "accounts" do
      resource :join_code, only: :create
      resource :custom_styles, only: %i[ edit update ]
    end
  end

  resources :books, except: %i[ index show ] do
    resource :publication, controller: "books/publications", only: %i[ show edit update ]
    resource :bookmark, controller: "books/bookmarks", only: :show

    scope module: "books" do
      namespace :leaves do
        resources :moves, only: :create
      end

      resource :search
    end

    resources :sections
    resources :pictures
    resources :pages
  end

  get "/:id/:slug", to: "books#show", constraints: { id: /\d+/ }, as: :slugged_book
  get "/:book_id/:book_slug/:id/:slug", to: "leafables#show", constraints: { book_id: /\d+/, id: /\d+/ }, as: :slugged_leafable

  direct :book_slug do |book, options|
    route_for :slugged_book, book, book.slug, options
  end

  direct :leafable_slug do |leaf, options|
    route_for :slugged_leafable, leaf.book, leaf.book.slug, leaf, leaf.slug, options
  end

  resources :pages, only: [] do
    scope module: "pages" do
      resources :edits, only: :show
    end
  end

  resources :qr_code, only: :show
  resources :users do
    scope module: "users" do
      resource :profile
    end
  end

  direct :leafable do |leaf, options|
    route_for "book_#{leaf.leafable_name}", leaf.book, leaf, options
  end

  direct :edit_leafable do |leaf, options|
    route_for "edit_book_#{leaf.leafable_name}", leaf.book, leaf, options
  end

  namespace :action_text, path: nil do
    get "/u/*slug" => "markdown/uploads#show", as: :markdown_upload
    post "/uploads" => "markdown/uploads#create", as: :markdown_uploads
  end

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end

```


<!-- ===== app/channels/application_cable/channel.rb ===== -->

```
module ApplicationCable
  class Channel < ActionCable::Channel::Base
  end
end

```


<!-- ===== app/channels/application_cable/connection.rb ===== -->

```
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    include Authentication::SessionLookup

    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private
      def find_verified_user
        if verified_session = find_session_by_cookie
          verified_session.user
        else
          reject_unauthorized_connection
        end
      end
  end
end

```


<!-- ===== app/controllers/accounts/custom_styles_controller.rb ===== -->

```
class Accounts::CustomStylesController < ApplicationController
  before_action :ensure_can_administer, :set_account

  def edit
  end

  def update
    @account.update!(account_params)
    redirect_to edit_account_custom_styles_url
  end

  private
    def set_account
      @account = Current.account
    end

    def account_params
      params.require(:account).permit(:custom_styles)
    end
end

```


<!-- ===== app/controllers/accounts/join_codes_controller.rb ===== -->

```
class Accounts::JoinCodesController < ApplicationController
  before_action :ensure_can_administer

  def create
    Current.account.reset_join_code
    redirect_to users_url
  end
end

```


<!-- ===== app/controllers/action_text/markdown/uploads_controller.rb ===== -->

```
class ActionText::Markdown::UploadsController < ApplicationController
  allow_unauthenticated_access only: :show

  before_action do
    ActiveStorage::Current.url_options = { protocol: request.protocol, host: request.host, port: request.port }
  end

  def create
    @record = GlobalID::Locator.locate_signed params[:record_gid]

    @markdown = @record.safe_markdown_attribute params[:attribute_name]
    @markdown.uploads.attach [ params[:file] ]
    @markdown.save!

    @upload = @markdown.uploads.attachments.last

    render :create, status: :created, formats: :json
  end

  def show
    @attachment = ActiveStorage::Attachment.find_by! slug: "#{params[:slug]}.#{params[:format]}"
    expires_in 1.year, public: true
    redirect_to @attachment.url
  end
end

```


<!-- ===== app/controllers/application_controller.rb ===== -->

```
class ApplicationController < ActionController::Base
  include Authentication, Authorization, VersionHeaders

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
end

```


<!-- ===== app/controllers/books_controller.rb ===== -->

```
class BooksController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]

  before_action :ensure_index_is_not_empty, only: :index
  before_action :set_book, only: %i[ show edit update destroy ]
  before_action :set_users, only: %i[ new edit ]
  before_action :ensure_editable, only: %i[ edit update destroy ]

  def index
    @books = Book.accessable_or_published.ordered
  end

  def new
    @book = Book.new
  end

  def create
    book = Book.create! book_params
    update_accesses(book)

    redirect_to book_slug_url(book)
  end

  def show
    @leaves = @book.leaves.active.with_leafables.positioned

    respond_to do |format|
      format.html
      format.md
    end
  end

  def edit
  end

  def update
    @book.update(book_params)
    update_accesses(@book)
    remove_cover if params[:remove_cover] == "true"

    redirect_to book_slug_url(@book)
  end

  def destroy
    @book.destroy

    redirect_to root_url
  end

  private
    def set_book
      @book = Book.accessable_or_published.find params[:id]
    end

    def set_users
      @users = User.active.ordered
    end

    def ensure_editable
      head :forbidden unless @book.editable?
    end

    def ensure_index_is_not_empty
      if !signed_in? && Book.published.none?
        require_authentication
      end
    end

    def book_params
      params.require(:book).permit(:title, :subtitle, :author, :cover, :remove_cover, :everyone_access, :theme)
    end

    def update_accesses(book)
      editors = [ Current.user.id, *params[:editor_ids]&.map(&:to_i) ]
      readers = [ Current.user.id, *params[:reader_ids]&.map(&:to_i) ]

      book.update_access(editors: editors, readers: readers)
    end

    def remove_cover
      @book.cover.purge
    end
end

```


<!-- ===== app/controllers/books/bookmarks_controller.rb ===== -->

```
class Books::BookmarksController < ApplicationController
  allow_unauthenticated_access

  include BookScoped

  def show
    @leaf = @book.leaves.active.find_by(id: last_read_leaf_id) if last_read_leaf_id.present?
  end

  private
    def last_read_leaf_id
      cookies["reading_progress_#{@book.id}"]
    end
end

```


<!-- ===== app/controllers/books/leaves/moves_controller.rb ===== -->

```
class Books::Leaves::MovesController < ApplicationController
  include BookScoped

  before_action :ensure_editable

  def create
    leaf, *followed_by = leaves
    leaf.move_to_position(position, followed_by: followed_by)
  end

  private
    def position
      params[:position].to_i
    end

    def leaves
      @book.leaves.find(Array(params[:id]))
    end
end

```


<!-- ===== app/controllers/books/publications_controller.rb ===== -->

```
class Books::PublicationsController < ApplicationController
  include BookScoped

  before_action :ensure_editable, only: %i[ edit update ]

  def show
  end

  def edit
  end

  def update
    @book.update! book_params
    redirect_to book_slug_url(@book)
  end

  private
    def book_params
      params.require(:book).permit(:published, :slug)
    end
end

```


<!-- ===== app/controllers/books/searches_controller.rb ===== -->

```
class Books::SearchesController < ApplicationController
  allow_unauthenticated_access

  include BookScoped

  def create
    @leaves = @book.leaves.active.search(params[:search]).favoring_title.limit(50)
  end
end

```


<!-- ===== app/controllers/concerns/authentication.rb ===== -->

```
module Authentication
  extend ActiveSupport::Concern
  include SessionLookup

  included do
    before_action :require_authentication
    helper_method :signed_in?

    protect_from_forgery with: :exception, unless: -> { authenticated_by.bot_key? }
  end

  class_methods do
    def require_unauthenticated_access(**options)
      allow_unauthenticated_access **options
      before_action :redirect_signed_in_user_to_root, **options
    end

    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
      before_action :restore_authentication, **options
    end
  end

  private
    def signed_in?
      Current.user.present?
    end

    def require_authentication
      restore_authentication || request_authentication
    end

    def restore_authentication
      if session = find_session_by_cookie
        resume_session session
      end
    end

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_url
    end

    def redirect_signed_in_user_to_root
      redirect_to root_url if signed_in?
    end

    def start_new_session_for(user)
      user.sessions.start!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        authenticated_as session
      end
    end

    def resume_session(session)
      session.resume user_agent: request.user_agent, ip_address: request.remote_ip
      authenticated_as session
    end

    def terminate_current_session
      Current.session&.destroy!
      reset_session
      remove_authentication_cookie
    end

    def authenticated_as(session)
      Current.session = session
      set_authenticated_by(:session)
      set_authentication_cookie(session)
    end

    def post_authenticating_url
      session.delete(:return_to_after_authenticating) || root_url
    end

    def set_authentication_cookie(session)
      cookies.signed.permanent[:session_token] = { value: session.token, httponly: true, same_site: :lax }
    end

    def remove_authentication_cookie
      cookies.delete(:session_token)
    end

    def set_authenticated_by(method)
      @authenticated_by = method.to_s.inquiry
    end

    def authenticated_by
      @authenticated_by ||= "".inquiry
    end
end

```


<!-- ===== app/controllers/concerns/authentication/session_lookup.rb ===== -->

```
module Authentication::SessionLookup
  def find_session_by_cookie
    if token = cookies.signed[:session_token]
      Session.find_by(token: token)
    end
  end
end

```


<!-- ===== app/controllers/concerns/book_scoped.rb ===== -->

```
module BookScoped extend ActiveSupport::Concern
  included do
    before_action :set_book
  end

  private
    def set_book
      @book = Book.accessable_or_published.find(params[:book_id])
    end

    def ensure_editable
      head :forbidden unless @book.editable?
    end
end

```


<!-- ===== app/controllers/concerns/page_leaf_scoped.rb ===== -->

```
module PageLeafScoped extend ActiveSupport::Concern
  included do
    before_action :set_leaf
  end

  private
    def set_leaf
      @leaf = Current.user.leaves.find(params[:page_id])
    end
end

```


<!-- ===== app/controllers/concerns/set_book_leaf.rb ===== -->

```
module SetBookLeaf
  extend ActiveSupport::Concern

  included do
    before_action :set_book
    before_action :set_leaf, :set_leafable, only: %i[ show edit update destroy ]
  end

  private
    def set_book
      @book = Book.accessable_or_published.find(params[:book_id])
    end

    def set_leaf
      @leaf = @book.leaves.active.find(params[:id])
    end

    def set_leafable
      instance_variable_set "@#{instance_name}", @leaf.leafable
    end

    def ensure_editable
      head :forbidden unless @book.editable?
    end

    def model_class
      controller_leafable_name.constantize
    end

    def instance_name
      controller_leafable_name.underscore
    end

    def controller_leafable_name
      self.class.to_s.remove("Controller").demodulize.singularize
    end
end

```


<!-- ===== app/controllers/concerns/user_scoped.rb ===== -->

```
module UserScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_user
  end

  private
    def set_user
      @user = User.active.find(params[:user_id])
    end
end

```


<!-- ===== app/controllers/concerns/version_headers.rb ===== -->

```
module VersionHeaders
  extend ActiveSupport::Concern

  included do
    before_action :set_version_headers
  end

  private
    def set_version_headers
      response.headers["X-Version"] = Rails.application.config.app_version
      response.headers["X-Rev"] = Rails.application.config.git_revision
    end
end

```


<!-- ===== app/controllers/first_runs_controller.rb ===== -->

```
class FirstRunsController < ApplicationController
  allow_unauthenticated_access

  before_action :prevent_running_after_setup

  def show
    @user = User.new
  end

  def create
    user = FirstRun.create!(user_params)
    start_new_session_for user

    redirect_to root_url
  end

  private
    def prevent_running_after_setup
      redirect_to root_url if User.any?
    end

    def user_params
      params.require(:user).permit(:name, :email_address, :password)
    end
end

```


<!-- ===== app/controllers/leafables_controller.rb ===== -->

```
class LeafablesController < ApplicationController
  allow_unauthenticated_access only: :show

  include SetBookLeaf

  before_action :ensure_editable, except: :show
  before_action :broadcast_being_edited_indicator, only: :update

  def new
    @leafable = new_leafable
  end

  def create
    @leaf = @book.press new_leafable, leaf_params
    position_new_leaf @leaf
  end

  def show
    respond_to do |format|
      format.html
      format.md
    end
  end

  def edit
  end

  def update
    @leaf.edit leafable_params: leafable_params, leaf_params: leaf_params

    respond_to do |format|
      format.turbo_stream { render }
      format.html { head :no_content }
    end
  end

  def destroy
    @leaf.trashed!

    respond_to do |format|
      format.turbo_stream { render }
      format.html { redirect_to book_slug_url(@book) }
    end
  end

  private
    def leaf_params
      default_leaf_params.merge params.fetch(:leaf, {}).permit(:title)
    end

    def default_leaf_params
      { title: new_leafable.model_name.human }
    end

    def new_leafable
      raise NotImplementedError.new "Implement in subclass"
    end

    def leafable_params
      raise NotImplementedError.new "Implement in subclass"
    end

    def position_new_leaf(leaf)
      if position = params[:position]&.to_i
        leaf.move_to_position position
      end
    end

    def broadcast_being_edited_indicator
      Turbo::StreamsChannel.broadcast_render_later_to @leaf, :being_edited,
        partial: "leaves/being_edited_by", locals: { leaf: @leaf, user: Current.user }
    end
end

```


<!-- ===== app/controllers/pages_controller.rb ===== -->

```
class PagesController < LeafablesController
  before_action :forget_reading_progress, except: :show

  private
    def forget_reading_progress
      cookies.delete "reading_progress_#{@book.id}"
    end

    def default_leaf_params
      { title: "Untitled" }
    end

    def new_leafable
      Page.new leafable_params
    end

    def leafable_params
      params.fetch(:page, {}).permit(:body)
    end
end

```


<!-- ===== app/controllers/pages/edits_controller.rb ===== -->

```
class Pages::EditsController < ApplicationController
  include PageLeafScoped

  before_action :set_edit

  def show
  end

  private
    def set_edit
      if params[:id] == "latest"
        @edit = @leaf.edits.last
      else
        @edit = @leaf.edits.find(params[:id])
      end
    end
end

```


<!-- ===== app/controllers/pictures_controller.rb ===== -->

```
class PicturesController < LeafablesController
  private
    def new_leafable
      Picture.new leafable_params
    end

    def leafable_params
      params.fetch(:picture, {}).permit(:image, :caption)
    end
end

```


<!-- ===== app/controllers/qr_code_controller.rb ===== -->

```
class QrCodeController < ApplicationController
  allow_unauthenticated_access

  def show
    qr_code_link = QrCodeLink.from_signed(params[:id])
    svg = RQRCode::QRCode.new(qr_code_link.url).as_svg(viewbox: true, fill: :white, color: :black)

    expires_in 1.year, public: true
    render plain: svg, content_type: "image/svg+xml"
  end
end

```


<!-- ===== app/controllers/sections_controller.rb ===== -->

```
class SectionsController < LeafablesController
  private
    def new_leafable
      Section.new leafable_params
    end

    def leafable_params
      params.fetch(:section, {}).permit(:body, :theme)
        .with_defaults(body: default_body)
    end

    def default_body
      params.fetch(:leaf, {})[:title]
    end
end

```


<!-- ===== app/controllers/sessions_controller.rb ===== -->

```
class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { render_rejection :too_many_requests }

  before_action :ensure_user_exists, only: :new

  def new
  end

  def create
    if user = User.active.authenticate_by(email_address: params[:email_address], password: params[:password])
      start_new_session_for user
      redirect_to post_authenticating_url
    else
      render_rejection :unauthorized
    end
  end

  def destroy
    terminate_current_session
    redirect_to root_url
  end

  private
    def ensure_user_exists
      redirect_to first_run_url if User.none?
    end

    def render_rejection(status)
      flash[:alert] = "Too many requests or unauthorized."
      render :new, status: status
    end
end

```


<!-- ===== app/controllers/sessions/transfers_controller.rb ===== -->

```
class Sessions::TransfersController < ApplicationController
  allow_unauthenticated_access

  def show
  end

  def update
    if user = User.active.find_by_transfer_id(params[:id])
      start_new_session_for user
      redirect_to post_authenticating_url
    else
      head :bad_request
    end
  end
end

```


<!-- ===== app/controllers/users_controller.rb ===== -->

```
class UsersController < ApplicationController
  require_unauthenticated_access only: %i[ new create ]

  before_action :verify_join_code, only: %i[ new create ]
  before_action :ensure_can_administer, only: %i[ update destroy ]
  before_action :set_user, only: %i[ update destroy ]


  def index
    @users = User.active
  end

  def new
    @user = User.new
  end

  def create
    @user = User.create!(user_params)
    start_new_session_for @user
    redirect_to root_url
  rescue ActiveRecord::RecordNotUnique
    redirect_to new_session_url(email_address: user_params[:email_address])
  end

  def update
    @user.update(role_params)
    redirect_to users_url
  end

  def destroy
    @user.deactivate
    redirect_to users_url
  end

  private
    def role_params
      { role: params.require(:user)[:role].presence_in(%w[ member administrator ]) || "member" }
    end

    def set_user
      @user = User.active.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email_address, :password)
    end

    def verify_join_code
      head :not_found if Current.account.join_code != params[:join_code]
    end
end

```


<!-- ===== app/controllers/users/profiles_controller.rb ===== -->

```
class Users::ProfilesController < ApplicationController
  include UserScoped

  before_action :ensure_current_user, only: %i[ edit update ]

  def show
  end

  def edit
  end

  def update
    @user.update!(user_params)
    redirect_to users_url
  end

  private
    def user_params
      params.require(:user).permit(:name, :email_address, :password)
    end
end

```


<!-- ===== app/helpers/application_helper.rb ===== -->

```
module ApplicationHelper
  def hide_from_user_style_tag
    tag.style(<<~CSS.html_safe)
      [data-hide-from-user-id="#{Current.user.id}"] {
        display: none!important;
      }
    CSS
  end

  def custom_styles_tag
    if custom_styles = Current.account&.custom_styles
      tag.style(custom_styles.to_s.html_safe, data: { turbo_track: "reload" })
    end
  end
end

```


<!-- ===== app/helpers/arrangement_helper.rb ===== -->

```
module ArrangementHelper
  def arrangement_tag(book, **, &)
    tag.div data: {
      controller: "arrangement reading-progress",
      arrangement_cursor_class: "arrangement-cursor",
      arrangement_selected_class: "arrangement-selected",
      arrangement_placeholder_class: "arrangement-placeholder",
      arrangement_adding_mode_class: "arrangement--adding",
      arrangement_move_mode_class: "arrangement-move-mode",
      arrangement_url_value: book_leaves_moves_url(book),
      reading_progress_book_id_value: book.id,
      reading_progress_last_read_class: "toc__leaf--last-read"
    }, **, &
  end

  def arrangement_actions
    actions = {
      "click": "click",
      "dragstart": "dragStart",
      "dragover": "dragOver:prevent",
      "dragend": "dragEnd",
      "drop": "drop",
      "keydown.up": "moveBefore",
      "keydown.right": "moveAfter",
      "keydown.down": "moveAfter",
      "keydown.left": "moveBefore",
      "keydown.shift+up": "moveBefore",
      "keydown.shift+right": "moveAfter",
      "keydown.shift+down": "moveAfter",
      "keydown.shift+left": "moveBefore",
      "keydown.space": "toggleMoveMode",
      "keydown.enter": "applyMoveMode",
      "keydown.esc": "cancelMoveMode"
    }

    actions.map { |action, target| "#{action}->arrangement##{target}" }.join(" ")
  end
end

```


<!-- ===== app/helpers/books_helper.rb ===== -->

```
module BooksHelper
  def book_toc_tag(book, &)
    tag.ol class: "toc", tabindex: 0,
      data: {
        controller: "arrangement",
        action: arrangement_actions,
        arrangement_cursor_class: "arrangement-cursor",
        arrangement_selected_class: "arrangement-selected",
        arrangement_placeholder_class: "arrangement-placeholder",
        arrangement_move_mode_class: "arrangement-move-mode",
        arrangement_url_value: book_leaves_moves_url(book)
      }, &
  end

  def book_part_create_button(book, kind, **, &)
    url = url_for [ book, kind.new ]

    button_to url, class: "btn btn--plain txt-medium fill-transparent disable-when-arranging disable-when-deleting", draggable: true,
      data: {
        action: "dragstart->arrangement#dragStartCreate dragend->arrangement#dragEndCreate",
        arrangement_url_param: url
      }, **, &
  end

  def link_to_first_leafable(leaves)
    if first_leaf = leaves.first
      link_to leafable_slug_path(first_leaf), data: hotkey_data_attributes("right"), class: "disable-when-arranging", hidden: true do
        tag.span(class: "btn") do
          image_tag("arrow-right.svg", aria: { hidden: true }, size: 24) + tag.span("Start reading", class: "for-screen-reader")
        end + tag.span(first_leaf.title, class: "overflow-ellipsis")
      end
    end
  end

  def link_to_previous_leafable(leaf, hotkey: true, for_edit: false)
    if previous_leaf = leaf.previous
      path = for_edit ? edit_leafable_path(previous_leaf) : leafable_slug_path(previous_leaf)
      link_to path, data: hotkey_data_attributes("left", enabled: hotkey), class: "btn" do
        image_tag("arrow-left.svg", aria: { hidden: true }, size: 24) + tag.span("Previous: #{ previous_leaf.title }", class: "for-screen-reader")
      end
    else
      link_to book_slug_path(leaf.book), data: hotkey_data_attributes("left", enabled: hotkey), class: "btn" do
        image_tag("arrow-left.svg", aria: { hidden: true }, size: 24) + tag.span("Table of contents: #{ leaf.book.title }", class: "for-screen-reader")
      end
    end
  end

  def link_to_next_leafable(leaf, hotkey: true, for_edit: false)
    if next_leaf = leaf.next
      path = for_edit ? edit_leafable_path(next_leaf) : leafable_slug_path(next_leaf)
      link_to path, data: hotkey_data_attributes("right", enabled: hotkey), class: "btn txt-medium min-width" do
        tag.span("Next: #{next_leaf.title }", class: "overflow-ellipsis") + image_tag("arrow-right.svg", aria: { hidden: true }, size: 24)
      end
    else
      link_to book_slug_path(leaf.book), data: hotkey_data_attributes("right", enabled: hotkey), class: "btn txt-medium" do
        tag.span("Table of contents: #{leaf.book.title }", class: "overflow-ellipsis") + image_tag("arrow-reverse.svg", aria: { hidden: true }, size: 24)
      end
    end
  end

  private
    def hotkey_data_attributes(key, enabled: true)
      if enabled
        { controller: "hotkey", action: "keydown.#{key}@document->hotkey#click touch:swipe-#{key}@window->hotkey#click" }
      end
    end
end

```


<!-- ===== app/helpers/books/editing_helper.rb ===== -->

```
module Books::EditingHelper
  def editing_mode_toggle_switch(leaf, checked:)
    target_url = checked ? leafable_slug_path(leaf) : edit_leafable_path(leaf)
    render "books/edit_mode", target_url: target_url, checked: checked
  end
end

```


<!-- ===== app/helpers/forms_helper.rb ===== -->

```
module FormsHelper
  def auto_submit_form_with(**attributes, &)
    data = attributes.delete(:data) || {}
    data[:controller] = "auto-submit #{data[:controller]}".strip

    form_with **attributes, data: data, &
  end
end

```


<!-- ===== app/helpers/invitations_helper.rb ===== -->

```
module InvitationsHelper
  def button_to_copy_to_clipboard(url, &)
    tag.button class: "btn", data: {
      controller: "copy-to-clipboard", action: "copy-to-clipboard#copy",
      copy_to_clipboard_success_class: "btn--success", copy_to_clipboard_content_value: url
    }, &
  end

  def web_share_button(url, title, text, &)
    tag.button class: "btn", hidden: true, data: {
      controller: "web-share", action: "web-share#share",
      web_share_url_value: url,
      web_share_text_value: text,
      web_share_title_value: title
    }, &
  end

  def qr_code_image(url)
    qr_code_link = QrCodeLink.new(url)
    image_tag qr_code_path(qr_code_link.signed), class: "qr-code center", alt: "QR Code"
  end
end

```


<!-- ===== app/helpers/leaves_helper.rb ===== -->

```
module LeavesHelper
  def leaf_item_tag(leaf, **, &)
    tag.li class: "arrangement__item toc__leaf toc__leaf--#{leaf.leafable_name}",
      id: dom_id(leaf),
      data: {
        id: leaf.id,
        arrangement_target: "item"
      }, **, &
  end

  def leaf_nav_tag(leaf, **, &)
    tag.nav data: {
      controller: "reading-tracker",
      reading_tracker_book_id_value: leaf.book_id,
      reading_tracker_leaf_id_value: leaf.id
    }, **, &
  end

  def leafable_edit_form(leafable, **, &)
    form_with model: leafable, url: leafable_path(leafable.leaf), method: :put, format: :html,
    data: {
      controller: "autosave",
      action: "autosave#submit:prevent input@document->autosave#change house-md:change->autosave#change",
      autosave_clean_class: "clean",
      autosave_dirty_class: "dirty",
      autosave_saving_class: "saving"
    }, **, &
  end
end

```


<!-- ===== app/helpers/pages_helper.rb ===== -->

```
module PagesHelper
  def word_count(content)
    return if content.blank?
    pluralize number_with_delimiter(content.split.size), "word"
  end

  def page_title(leaf, book)
    [ leaf.title, book.title, book.author ].reject(&:blank?).to_sentence(two_words_connector: " · ", words_connector: " · ", last_word_connector: " · ")
  end

  def sanitize_content(content)
    sanitize content, scrubber: HtmlScrubber.new
  end
end

```


<!-- ===== app/helpers/pictures_helper.rb ===== -->

```
module PicturesHelper
end

```


<!-- ===== app/helpers/searches_helper.rb ===== -->

```
module SearchesHelper
  # Use this method to ensure FTS5 search result output is safe to render,
  # allowing only <mark> tags through.
  #
  # FTS5 highlight() and snippet() wrap matched terms in <mark> tags, but the
  # surrounding content may contain unsanitized HTML from user input,
  # particularly if it was indexed before explicit sanitization was added to
  # the Searchable concern.
  def sanitize_search_result(html)
    sanitize(html, tags: %w[mark], attributes: [])
  end

  def highlight_searched_content(leaf, content, query)
    if query.present?
      terms = leaf.matches_for_highlight(query)
      terms = whole_word_matchers(terms)

      sanitize_content highlight(content, terms, sanitize: false)
    else
      content
    end
  end

  private
    def whole_word_matchers(terms)
      terms.map { |term| /\b#{term}\b/ }
    end
end

```


<!-- ===== app/helpers/sections_helper.rb ===== -->

```
module SectionsHelper
end

```


<!-- ===== app/helpers/translations_helper.rb ===== -->

```
module TranslationsHelper
  TRANSLATIONS = {
    book_author: { "🇺🇸": "Author", "🇪🇸": "Autor", "🇫🇷": "Auteur", "🇮🇳": "लेखक", "🇩🇪": "Autor", "🇧🇷": "Autor" },
    book_subtitle: { "🇺🇸": "Subtitle", "🇪🇸": "Subtítulo", "🇫🇷": "Sous-titre", "🇮🇳": "उपशीर्षक", "🇩🇪": "Untertitel", "🇧🇷": "Subtítulo" },
    book_title: { "🇺🇸": "Book title", "🇪🇸": "Título del libro", "🇫🇷": "Titre du livre", "🇮🇳": "पुस्तक का शीर्षक", "🇩🇪": "Buchtitel", "🇧🇷": "Título do livro" },
    custom_styles: { "🇺🇸": "Add custom CSS styles. Use Caution: you could break things.", "🇪🇸": "Agrega estilos CSS personalizados. Usa precaución: podrías romper cosas.", "🇫🇷": "Ajoutez des styles CSS personnalisés. Utilisez avec précaution : vous pourriez casser des choses.", "🇮🇳": "कस्टम CSS स्टाइल जोड़ें। सावधानी बरतें: आप चीज़ों को तोड़ सकते हैं।", "🇩🇪": "Fügen Sie benutzerdefinierte CSS-Stile hinzu. Vorsicht: Sie könnten Dinge kaputt machen.", "🇧🇷": "Adicione estilos CSS personalizados. Use com cuidado: você pode quebrar coisas." },
    email_address:  { "🇺🇸": "Enter your email address", "🇪🇸": "Introduce tu correo electrónico", "🇫🇷": "Entrez votre adresse courriel", "🇮🇳": "अपना ईमेल पता दर्ज करें", "🇩🇪": "Geben Sie Ihre E-Mail-Adresse ein", "🇧🇷": "Insira seu endereço de email" },
    password: { "🇺🇸": "Enter your password", "🇪🇸": "Introduce tu contraseña", "🇫🇷": "Saisissez votre mot de passe", "🇮🇳": "अपना पासवर्ड दर्ज करें", "🇩🇪": "Geben Sie Ihr Passwort ein", "🇧🇷": "Insira sua senha" },
    picture_caption: { "🇺🇸": "Picture caption", "🇪🇸": "Subtítulo de la imagen", "🇫🇷": "Légende de l'image", "🇮🇳": "चित्र का कैप्शन", "🇩🇪": "Bildunterschrift", "🇧🇷": "Legenda da imagem" },
    transfer_session: { "🇺🇸": "Share to get them back into their account", "🇪🇸": "Comparte para que vuelvan a acceder a su cuenta", "🇫🇷": "Partagez pour les reconnecter à leur compte", "🇮🇳": "उन्हें उनके खाते में वापस लाने के लिए साझा करें", "🇩🇪": "Teilen, um ihnen den Zugang zu ihrem Konto zu ermöglichen", "🇧🇷": "Compartilhe para que eles voltem a acessar sua conta" },
    transfer_session_self: { "🇺🇸": "Link to automatically log in on another device", "🇪🇸": "Enlace para iniciar sesión automáticamente en otro dispositivo", "🇫🇷": "Lien pour se connecter automatiquement sur un autre appareil", "🇮🇳": "किसी अन्य डिवाइस पर स्वचालित रूप से लॉग इन करने के लिए लिंक", "🇩🇪": "Link, um sich automatisch auf einem anderen Gerät anzumelden", "🇧🇷": "Link para fazer login automaticamente em outro dispositivo" },
    user_name: { "🇺🇸": "Enter your name", "🇪🇸": "Introduce tu nombre", "🇫🇷": "Entrez votre nom", "🇮🇳": "अपना नाम दर्ज करें", "🇩🇪": "Geben Sie Ihren Namen ein", "🇧🇷": "Insira seu nome" },
    update_password: { "🇺🇸": "Change password", "🇪🇸": "Cambiar contraseña", "🇫🇷": "Changer le mot de passe", "🇮🇳": "पासवर्ड बदलें", "🇩🇪": "Passwort ändern", "🇧🇷": "Alterar senha" }
  }

  def translations_for(translation_key)
    tag.dl(class: "language-list") do
      TRANSLATIONS[translation_key].map do |language, translation|
        concat tag.dt(language)
        concat tag.dd(translation, class: "margin-none")
      end
    end
  end

  def translation_button(translation_key)
    tag.div(class: "position-relative", data: { controller: "popover", action: "keydown.esc->popover#close click@document->popover#closeOnClickOutside", popover_orientation_top_class: "popover-orientation-top" }) do
      tag.button(type: "button", class: "btn", tabindex: -1, data: { action: "popover#toggle" }) do
        concat image_tag("globe.svg", size: 20, role: "presentation", class: "color-icon")
        concat tag.span("Translate", class: "for-screen-reader")
      end +
      tag.dialog(class: "lanuage-list-menu popover shadow", data: { popover_target: "menu" }) do
        translations_for(translation_key)
      end
    end
  end
end

```


<!-- ===== app/helpers/turbo_stream_actions_helper.rb ===== -->

```
module TurboStreamActionsHelper
  def scroll_into_view(id, animation: nil)
    turbo_stream_action_tag :scroll_into_view, target: id, animation: animation
  end
end

Turbo::Streams::TagBuilder.prepend TurboStreamActionsHelper

```


<!-- ===== app/helpers/version_helper.rb ===== -->

```
module VersionHelper
  def version_badge
    tag.span(Rails.application.config.app_version, class: "product__version-badge")
  end
end

```


<!-- ===== app/jobs/application_job.rb ===== -->

```
class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
end

```


<!-- ===== app/mailers/application_mailer.rb ===== -->

```
class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout "mailer"
end

```


<!-- ===== app/models/access.rb ===== -->

```
class Access < ApplicationRecord
  enum :level, %w[ reader editor ].index_by(&:itself)

  belongs_to :user
  belongs_to :book
end

```


<!-- ===== app/models/account.rb ===== -->

```
class Account < ApplicationRecord
  include Joinable
end

```


<!-- ===== app/models/account/joinable.rb ===== -->

```
module Account::Joinable
  extend ActiveSupport::Concern

  included do
    before_create { self.join_code = generate_join_code }
  end

  def reset_join_code
    update! join_code: generate_join_code
  end

  private
    def generate_join_code
      SecureRandom.alphanumeric(12).scan(/.{4}/).join("-")
    end
end

```


<!-- ===== app/models/application_record.rb ===== -->

```
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end

```


<!-- ===== app/models/book.rb ===== -->

```
class Book < ApplicationRecord
  include Accessable, Sluggable

  has_many :leaves, dependent: :destroy
  has_one_attached :cover, dependent: :purge_later

  scope :ordered, -> { order(:title) }
  scope :published, -> { where(published: true) }

  enum :theme, %w[ black blue green magenta orange violet white ].index_by(&:itself), suffix: true, default: :blue

  def press(leafable, leaf_params)
    leaves.create! leaf_params.merge(leafable: leafable)
  end

  def markable
    leaves.active.positioned.map { it.leafable.markable }.join("\n\n")
  end
end

```


<!-- ===== app/models/book/accessable.rb ===== -->

```
module Book::Accessable
  extend ActiveSupport::Concern

  included do
    has_many :accesses, dependent: :destroy
    scope :with_everyone_access, -> { where(everyone_access: true) }
  end

  class_methods do
    def accessable_or_published(user: Current.user)
      if user.present?
        accessable_or_published_books
      else
        published
      end
    end

    def accessable_or_published_books(user: Current.user)
      user.books.or(published).distinct
    end
  end

  def accessable?(user: Current.user)
    accesses.exists?(user: user)
  end

  def editable?(user: Current.user)
    access_for(user: user)&.editor? || user&.administrator?
  end

  def access_for(user: Current.user)
    accesses.find_by(user: user)
  end

  def update_access(editors:, readers:)
    editors = Set.new(editors)
    readers = Set.new(everyone_access? ? User.active.ids : readers)

    all = editors + readers
    all_accesses = all.collect { |user_id|
      { user_id: user_id, level: editors.include?(user_id) ? :editor : :reader }
    }

    accesses.upsert_all(all_accesses, unique_by: [ :book_id, :user_id ])
    accesses.where.not(user_id: all).delete_all
  end
end

```


<!-- ===== app/models/book/sluggable.rb ===== -->

```
module Book::Sluggable
  extend ActiveSupport::Concern

  included do
    before_save :generate_slug, if: -> { slug.blank? }
  end

  def generate_slug
    self.slug = title.parameterize
  end
end

```


<!-- ===== app/models/concerns/authorization.rb ===== -->

```
module Authorization
  private
    def ensure_can_administer
      head :forbidden unless Current.user.can_administer?
    end

    def ensure_current_user
      head :forbidden unless @user.current?
    end
end

```


<!-- ===== app/models/concerns/positionable.rb ===== -->

```
module Positionable
  extend ActiveSupport::Concern

  REBALANCE_THRESHOLD = 1e-10
  ELEMENT_GAP         = 1

  included do
    scope :positioned, -> { order(:position_score, :id) }

    scope :before, ->(other) { positioned.where("position_score < ?", other.position_score) }
    scope :after,  ->(other) { positioned.where("position_score > ?", other.position_score) }

    around_create :insert_at_default_position
    after_save_commit :rebalance_positions, if: :rebalance_required?
  end

  class_methods do
    def positioned_within(parent, association:, filter:)
      define_method :positioning_parent do
        send(parent)
      end

      define_method :all_positioned_siblings do
        positioning_parent.send(association).send(filter).positioned
      end

      define_method :other_positioned_siblings do
        all_positioned_siblings.excluding(self)
      end

      private :positioning_parent, :all_positioned_siblings, :other_positioned_siblings
    end
  end

  def previous
    other_positioned_siblings.before(self).last
  end

  def next
    other_positioned_siblings.after(self).first
  end

  def move_to_position(offset, followed_by: [])
    with_positioning_lock do
      all_to_move = [ self, *followed_by ]
      before, after = before_and_after_for(offset: offset, moving: all_to_move)
      gap = (after - before) / (all_to_move.count + 1)

      all_to_move.each.with_index(1) do |item, index|
        item.update!(position_score: before + (index * gap))
      end

      remember_to_rebalance_positions if gap < REBALANCE_THRESHOLD
    end
  end

  def position_as_percentage
    100 * ordinal_position.to_f / all_positioned_siblings.count
  end

  private
    def ordinal_position
      other_positioned_siblings.before(self).count + 1
    end

    def insert_at_default_position
      with_positioning_lock do
        position_at_end
        yield
      end
    end

    def position_at_start
      self.position_score = (all_positioned_siblings.minimum(:position_score) || (2 * ELEMENT_GAP)) - ELEMENT_GAP
    end

    def position_at_end
      self.position_score = (all_positioned_siblings.maximum(:position_score) || 0) + ELEMENT_GAP
    end

    def before_and_after_for(offset:, moving:)
      other_items = all_positioned_siblings.excluding(moving)

      if offset < 1
        after = all_positioned_siblings.minimum(:position_score) || (2 * ELEMENT_GAP)
        before = after - ELEMENT_GAP
      else
        before, after = other_items.offset(offset - 1).limit(2).pluck(:position_score)
        before ||= all_positioned_siblings.maximum(:position_score)
        after ||= before + (moving.count.succ * ELEMENT_GAP)
      end

      [ before, after ]
    end

    def remember_to_rebalance_positions
      @rebalance_required = true
    end

    def rebalance_required?
      @rebalance_required
    end

    def rebalance_positions
      with_positioning_lock do
        odered = all_positioned_siblings.select("row_number() over (order by position_score, id) as new_score, id")
        sql = "update #{self.class.table_name} set position_score = new_score from (#{odered.to_sql}) as ordered where #{self.class.table_name}.id = ordered.id"

        self.class.connection.execute sql
      end
      @rebalance_required = false
    end

    def with_positioning_lock(&block)
      positioning_parent.with_lock &block
    end
end

```


<!-- ===== app/models/current.rb ===== -->

```
class Current < ActiveSupport::CurrentAttributes
  attribute :session, :user

  def session=(value)
    super(value)

    if value.present?
      self.user = session.user
    end
  end

  def account
    Account.first
  end
end

```


<!-- ===== app/models/demo_content.rb ===== -->

```
class DemoContent
  class << self
    def create_manual(user)
      book = create_book(user)
      load_markdown_pages(book)
    end

    private
      def create_book(user)
        Book.create(title: "The Writebook Manual", author: "37signals", everyone_access: true).tap do |book|
          with_attachment("writebook-manual.jpg") { |attachment| book.cover.attach(attachment) }
          book.update_access(readers: [], editors: [ user.id ])
        end
      end

      def load_markdown_pages(book)
        pages = {}

        Dir.glob(Rails.root.join("app/assets/markdown/demo/*.md")).each do |fname|
          front_matter = FrontMatterParser::Parser.parse_file(fname)

          if front_matter["class"] == "Section"
            load_section(book, front_matter)
          else
            page = load_markdown_page(book, front_matter)
            attach_images(page)
            pages[page.leaf.slug] = page
          end
        end

        book.leaves.pages.each { |leaf| localize_ref_links(leaf.page, pages) }
      end

      def load_markdown_page(book, front_matter)
        book.press(Page.new(body: front_matter.content), title: front_matter["title"]).page
      end

      def load_section(book, front_matter)
        book.press Section.new(body: front_matter.content, theme: front_matter["theme"]), title: front_matter["title"]
      end

      def attach_images(page)
        re = %r{
          \/u\/           # leading portion of path
          (\S+-\w+\.\w+)  # filename including slug and extension
        }x

        body = page.body.content.gsub(re) do |match|
          with_attachment($1) { |attachment| page.body.uploads.attach(attachment) }

          attachment = page.body.uploads.attachments.last
          attachment.analyze

          "/u/" + attachment.slug
        end

        page.update!(body: body)
      end

      def localize_ref_links(page, pages)
        re = %r{
          (\[.+\])              # link title
          \(                    # opening paren
          \/\d+\/[\w-]+\/\d+\/  # leading portion of path
          ([\w-]+)              # leaf slug
        }x

        body = page.body.content.gsub(re) do |match|
          link_title, leaf_slug, anchor = $1, $2, $3
          linked_page = pages[leaf_slug]
          raise "Invalid reference link: #{page_title}" unless linked_page.present?

          url = Rails.application.routes.url_helpers.leafable_slug_path(linked_page.leaf, anchor: anchor, only_path: true)

          "#{link_title}(#{url}"
        end

        page.update!(body: body)
      end

      def with_attachment(filename)
        File.open(Rails.root.join("app/assets/images/demo/#{filename}")) do |file|
          yield io: file, filename: filename
        end
      end
  end
end

```


<!-- ===== app/models/edit.rb ===== -->

```
class Edit < ApplicationRecord
  belongs_to :leaf
  delegated_type :leafable, types: Leafable::TYPES, dependent: :destroy

  enum :action, %w[ revision trash ].index_by(&:itself)

  scope :sorted, -> { order(created_at: :desc) }
  scope :before, ->(edit) { where("created_at < ?", edit.created_at) }
  scope :after, ->(edit) { where("created_at > ?", edit.created_at) }

  def previous
    leaf.edits.before(self).last
  end

  def next
    leaf.edits.after(self).first
  end
end

```


<!-- ===== app/models/first_run.rb ===== -->

```
class FirstRun
  ACCOUNT_NAME = "Writebook"

  def self.create!(user_params)
    account = Account.create!(name: ACCOUNT_NAME)

    User.create!(user_params.merge(role: :administrator)).tap do |user|
      DemoContent.create_manual(user)
    end
  end
end

```


<!-- ===== app/models/html_scrubber.rb ===== -->

```
class HtmlScrubber < Rails::Html::PermitScrubber
  def initialize
    super
    self.tags = Rails::Html::WhiteListSanitizer.allowed_tags + %w[
      audio details summary iframe options table tbody td th thead tr video source mark
    ]
  end
end

```


<!-- ===== app/models/leaf.rb ===== -->

```
class Leaf < ApplicationRecord
  include Editable, Positionable, Searchable

  belongs_to :book, touch: true
  delegated_type :leafable, types: Leafable::TYPES, dependent: :destroy
  positioned_within :book, association: :leaves, filter: :active

  delegate :searchable_content, to: :leafable

  enum :status, %w[ active trashed ].index_by(&:itself), default: :active

  scope :with_leafables, -> { includes(:leafable) }

  def slug
    title.parameterize.presence || "-"
  end
end

```


<!-- ===== app/models/leaf/editable.rb ===== -->

```
module Leaf::Editable
  extend ActiveSupport::Concern

  MINIMUM_TIME_BETWEEN_VERSIONS = 10.minutes

  included do
    has_many :edits, dependent: :delete_all

    after_update :record_moved_to_trash, if: :was_trashed?
  end

  def edit(leafable_params: {}, leaf_params: {})
    if record_new_edit?(leafable_params)
      update_and_record_edit leaf_params, leafable_params
    else
      update_without_recording_edit leaf_params, leafable_params
    end
  end

  private
    def record_new_edit?(leafable_params)
      will_change_leafable?(leafable_params) && last_edit_old?
    end

    def last_edit_old?
      edits.empty? || edits.last.created_at.before?(MINIMUM_TIME_BETWEEN_VERSIONS.ago)
    end

    def will_change_leafable?(leafable_params)
      leafable_params.select do |key, value|
        leafable.attributes[key.to_s] != value
      end.present?
    end

    def update_without_recording_edit(leaf_params, leafable_params)
      transaction do
        leafable.update!(leafable_params)

        edits.last&.touch
        update! leaf_params
      end
    end

    def update_and_record_edit(leaf_params, leafable_params)
      transaction do
        new_leafable = dup_leafable_with_attachments leafable
        new_leafable.update!(leafable_params)

        edits.revision.create!(leafable: leafable)
        update! leaf_params.merge(leafable: new_leafable)
      end
    end

    def dup_leafable_with_attachments(leafable)
      leafable.dup.tap do |new|
        leafable.attachment_reflections.each do |name, _|
          new.send(name).attach(leafable.send(name).blob)
        end
      end
    end

    def record_moved_to_trash
      edits.trash.create!(leafable: leafable)
    end

    def was_trashed?
      trashed? && previous_changes.include?(:status)
    end
end

```


<!-- ===== app/models/leaf/searchable.rb ===== -->

```
module Leaf::Searchable
  extend ActiveSupport::Concern

  included do
    after_create_commit  :create_in_search_index,   if: :searchable?
    after_update_commit  :update_in_search_index,   if: :searchable?
    after_destroy_commit :remove_from_search_index, if: :searchable?

    scope :favoring_title, -> { order(Arel.sql("bm25(leaf_search_index, 2.0)")) }
  end

  class_methods do
    def reindex_all
      all.map &:reindex
    end

    def sanitize_query_syntax(terms)
      terms = terms.to_s
      terms = remove_invalid_search_characters(terms)
      terms = remove_unbalanced_quotes(terms)
      terms.presence
    end

    def search(terms)
      if terms = sanitize_query_syntax(terms)
        with_search_results_for(terms)
          .select(
            "leaves.*",
            "highlight(leaf_search_index, 0, '<mark>', '</mark>') as title_match",
            "snippet(leaf_search_index, 1, '<mark>', '</mark>', '...', 20) as content_match")
      else
        none
      end
    end

    def with_search_results_for(terms)
      joins("join leaf_search_index on leaves.id = leaf_search_index.rowid")
        .where("leaf_search_index match ?", terms)
    end
  end

  def reindex
    update_in_search_index if searchable?
  end

  def matches_for_highlight(terms)
    if terms = self.class.sanitize_query_syntax(terms)
      content = Leaf.with_search_results_for(terms)
        .where(id: id)
        .pick(Arel.sql("highlight(leaf_search_index, 1, '<mark>', '</mark>')"))

      content ? unique_matching_terms(content) : []
    end
  end

  private
    def searchable?
      searchable_content
    end

    # Strip tags from content before indexing to keep the FTS table clean.
    # This is a hygiene measure, not a security boundary — display-time
    # sanitization in sanitize_search_result is the primary defense.
    # ActionText content (Pages) is already HTML-safe plain text via
    # ERB::Util.html_escape, so skip it to avoid double-encoding.
    def sanitize_for_index(text)
      if text.html_safe?
        text
      else
        Rails::Html::FullSanitizer.new.sanitize(text)
      end
    end

    def create_in_search_index
      execute_sql_with_binds "insert into leaf_search_index(rowid, title, content ) values (?, ?, ?)",
        id, sanitize_for_index(title), sanitize_for_index(searchable_content)
    end

    def update_in_search_index
      transaction do
        updated = execute_sql_with_binds "update leaf_search_index set title = ?, content = ? where rowid = ?",
          sanitize_for_index(title), sanitize_for_index(searchable_content), id

        create_in_search_index unless updated
      end
    end

    def remove_from_search_index
      execute_sql_with_binds "delete from leaf_search_index where rowid = ?", id
    end

    def execute_sql_with_binds(*statement)
      self.class.connection.execute self.class.sanitize_sql(statement)

      self.class.connection.raw_connection.changes.nonzero?
    end

    def unique_matching_terms(content)
      terms = content.scan(/<mark>(.*?)<\/mark>/).flatten.uniq
      terms.sort_by(&:length).reverse
    end

    class_methods do
      private
        def remove_invalid_search_characters(terms)
          terms.gsub(/[^\w"]/, " ")
        end

        def remove_unbalanced_quotes(terms)
          if terms.count("\"").even?
            terms
          else
            terms.gsub("\"", " ")
          end
        end
    end
end

```


<!-- ===== app/models/leafable.rb ===== -->

```
module Leafable
  extend ActiveSupport::Concern

  TYPES = %w[ Page Section Picture ]

  included do
    has_one :leaf, as: :leafable, inverse_of: :leafable, touch: true
    has_one :book, through: :leaf

    delegate :title, to: :leaf
  end

  def searchable_content
    nil
  end

  class_methods do
    def leafable_name
      @leafable_name ||= ActiveModel::Name.new(self).singular.inquiry
    end
  end

  def leafable_name
    self.class.leafable_name
  end
end

```


<!-- ===== app/models/page.rb ===== -->

```
class Page < ApplicationRecord
  include Leafable

  cattr_accessor :preview_renderer do
    renderer = Redcarpet::Render::HTML.new(ActionText::Markdown::DEFAULT_RENDERER_OPTIONS)
    Redcarpet::Markdown.new(renderer, ActionText::Markdown::DEFAULT_MARKDOWN_EXTENSIONS)
  end

  has_markdown :body

  def searchable_content
    # `to_plain_text` decodes HTML entities, so characters like `<` that were `&lt;`
    # in the original HTML become literal `<`. Re-encode them with `html_escape` so
    # they are safe in the FTS index. The `html_safe` return value signals to
    # `Leaf::Searchable#sanitize_for_index` that this content should not be
    # double-encoded.
    ERB::Util.html_escape(plain_text)
  end

  def html_preview
    rendered_html(markdown_source.first(1024))
  end

  def markable
    body.content.to_s
  end

  private
    def plain_text
      html_body = rendered_html(markdown_source)
      ActionText::Content.new(html_body).to_plain_text
    end

    def rendered_html(source)
      preview_renderer.render(source)
    end

    def markdown_source
      body.content.to_s
    end
end

```


<!-- ===== app/models/picture.rb ===== -->

```
class Picture < ApplicationRecord
  include Leafable

  has_one_attached :image do |attachable|
    attachable.variant :large, resize_to_limit: [ 1500, 1500 ]
  end

  def large_image
    image.variable? ? image.variant(:large) : image
  end

  def markable
    caption
  end
end

```


<!-- ===== app/models/qr_code_link.rb ===== -->

```
class QrCodeLink
  attr_reader :url

  def initialize(url)
    @url = url
  end

  def signed
    self.class.verifier.generate(@url, purpose: :qr_code)
  end

  def self.from_signed(signed)
    new verifier.verify(signed, purpose: :qr_code)
  end

  private
    class << self
      def verifier
        ActiveSupport::MessageVerifier.new(secret, url_safe: true)
      end

      def secret
        Rails.application.key_generator.generate_key("qr_codes")
      end
    end
end

```


<!-- ===== app/models/section.rb ===== -->

```
class Section < ApplicationRecord
  include Leafable

  def searchable_content
    body
  end

  def markable
    body
  end
end

```


<!-- ===== app/models/session.rb ===== -->

```
class Session < ApplicationRecord
  ACTIVITY_REFRESH_RATE = 1.hour

  has_secure_token

  belongs_to :user

  before_create { self.last_active_at ||= Time.now }

  def self.start!(user_agent:, ip_address:)
    create! user_agent: user_agent, ip_address: ip_address
  end

  def resume(user_agent:, ip_address:)
    if last_active_at.before?(ACTIVITY_REFRESH_RATE.ago)
      update! user_agent: user_agent, ip_address: ip_address, last_active_at: Time.now
    end
  end
end

```


<!-- ===== app/models/user.rb ===== -->

```
class User < ApplicationRecord
  include Role, Transferable

  has_many :sessions, dependent: :destroy
  has_secure_password validations: false

  has_many :accesses, dependent: :destroy
  has_many :books, through: :accesses
  has_many :leaves, through: :books

  after_create :grant_access_to_everyone_books

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:name) }

  def current?
    self == Current.user
  end

  def deactivate
    transaction do
      sessions.delete_all
      update! active: false, email_address: deactived_email_address
    end
  end

  private
    def deactived_email_address
      email_address&.gsub(/@/, "-deactivated-#{SecureRandom.uuid}@")
    end

    def grant_access_to_everyone_books
      all_accesses = Book.with_everyone_access.ids.collect { |id| { book_id: id, level: :reader } }
      accesses.insert_all(all_accesses)
    end
end

```


<!-- ===== app/models/user/role.rb ===== -->

```
module User::Role
  extend ActiveSupport::Concern

  included do
    enum :role, %i[ member administrator ], default: :member
  end

  def can_administer?
    administrator?
  end
end

```


<!-- ===== app/models/user/transferable.rb ===== -->

```
module User::Transferable
  extend ActiveSupport::Concern

  TRANSFER_LINK_EXPIRY_DURATION = 4.hours

  class_methods do
    def find_by_transfer_id(id)
      find_signed(id, purpose: :transfer)
    end
  end

  def transfer_id
    signed_id(purpose: :transfer, expires_in: TRANSFER_LINK_EXPIRY_DURATION)
  end
end

```


<!-- ===== app/views/accounts/custom_styles/edit.html.erb ===== -->

```
<% content_for(:title) { "Custom styles" } %>

<% content_for :header do %>
  <nav>
    <%= link_to users_path, class: "btn" do %>
      <%= image_tag "arrow-left.svg", aria: { hidden: true }, size: 24 %>
      <span class="for-screen-reader">Go back</span>
    <% end %>

    <div class="breadcrumbs">
      <%= render "books/index_link" %>
      <span class="flex-item-no-shrink">▸</span>
      <%= image_tag "art.svg", aria: { label: "Custom styles" }, size: 19, class: "colorize--black", alt: "Custom styles" %>
    </div>
  </nav>
<% end %>

<div class="center pad txt-align-center flex flex-column">
  <%= form_with model: @account, url: account_custom_styles_url, class: "flex flex-column gap",
      data: { controller: "form", action: "keydown.ctrl+enter->form#submit keydown.meta+enter->form#submit" } do |form| %>
    <div class="pad-inline-double margin-inline">
      <div class="flex align-center gap-half center full-width justify-center">
        <span class="txt-medium"><%= translation_button(:custom_styles) %></span>
        <h1 class="margin-none">Custom CSS</h1>
      </div>
      <p class="flex flex-wrap align-center justify-center gap margin-none-block-start" style="--column-gap: 0.5ch; --row-gap: 0">
        <span>Add custom CSS styles.</span>
        <%= image_tag "alert.svg", class: "flex-inline colorize--black", size: 16, aria: { hidden: "true" } %>
        <span>Use Caution: you could break things.</span>
      </p>
    </div>

    <label class="flex align-start gap flex-item-grow">
      <%= form.text_area :custom_styles, class: "input input--code txt--small", placeholder: "Add CSS styles…",
            autocomplete: "off", spellcheck: "false", autocorrect: "off", autocapitalize: "off",
            rows: 16, required: false %>
    </label>

    <%= form.button class: "btn btn--reversed center txt-large", type: "submit" do %>
      <%= image_tag "check.svg", aria: { hidden: "true" }, size: 20 %>
      <span class="for-screen-reader">Save changes</span>
    <% end %>
  <% end %>
</div>

```


<!-- ===== app/views/books/_book.html.erb ===== -->

```
<% cache book do %>
  <figure class="library__book <%= "theme--#{book&.theme}" unless book.cover.attached? %>">
    <div class="flex flex-column gap-half">
      <div class="flex-inline position-relative center">
        <% if book.cover.attached? %>
          <%= image_tag book.cover, alt: "Book cover", class: "book__cover" %>
        <% else %>
          <span class="book__cover-wrapper">
            <%= image_tag "empty-cover.png", alt: "Book cover", class: "book__cover margin-block-none center" %>
            <span class="book__title overflow-line-clamp pad txt-align-start txt-tight-lines" style="--lines: 6" aria-hidden="true"><%= book.title %></span>
          </span>
        <% end %>
        <%= turbo_frame_tag dom_id(book, :bookmark), src: book_bookmark_path(book), target: "_top" %>
      </div>
      <h2 class="margin-none flex flex-column txt-normal txt-tight-lines txt-medium--responsive">
        <strong><%= book.title %></strong>
        <span class="overflow-line-clamp"><%= book.author %></span>
      </h2>
    </div>
  </figure>
<% end %>

```


<!-- ===== app/views/books/_create_buttons.html.erb ===== -->

```
<%= book_part_create_button book, Page do %>
  <svg viewBox="0 0 20 24" xmlns="http://www.w3.org/2000/svg" fill="var(--color-ink)">
    <path d="m15.8 21.7c0 .3-.2.4-.4.4h-13.5-.2v-16.9c0-.3.2-.4.4-.4h6.3c0-.6.1-1.2.3-1.8h-6.9c-1 0-1.8.8-1.8 1.8v17.5c0 1 .8 1.8 1.8 1.8h14c.9 0 1.6-.6 1.8-1.4v-11.6c-.5.2-1.1.4-1.8.5v10.3z"/>
    <path fill="var(--color-positive)" d="m15 0c-2.8 0-5 2.2-5 5s2.2 5 5 5 5-2.2 5-5-2.2-5-5-5zm1.9 5.6h-1.2c-.1 0-.2 0-.2.2v1.2c0 .3-.3.6-.6.6s-.6-.3-.6-.6v-1.2c0-.1 0-.2-.2-.2h-1.2c-.3 0-.6-.3-.6-.6s.3-.6.6-.6h1.2c.1 0 .2 0 .2-.2v-1.2c0-.3.3-.6.6-.6s.6.3.6.6v1.2c0 .1 0 .2.2.2h1.2c.3 0 .6.3.6.6s-.3.6-.6.6z"/>
    <path d="m4.4 16.3.4-.4c.3-.3.8-.3 1.1 0 1 .9 2.5.9 3.4 0 .3-.3.8-.3 1.1 0 1 1 2.5 1 3.4 0l.3-.3c.3-.3.3-.8 0-1.1s-.8-.3-1.1 0l-.3.3c-.3.3-.8.3-1.1 0-1-1-2.5-1-3.4 0-.3.3-.8.3-1.1 0-1-1-2.5-1-3.4 0l-.4.4c-.3.3-.3.8 0 1.1s.8.3 1.1 0z"/>
    <path d="m4.5 20.1.5-.5c.4-.4.9-.4 1.3 0 1.1 1.1 2.8 1.1 3.9 0 .3-.4.3-.9 0-1.3-.4-.3-.9-.3-1.3 0s-.9.3-1.3 0c-1.1-1.1-2.8-1.1-3.9 0l-.5.5c-.3.4-.3.9 0 1.3.4.3.9.3 1.3 0z"/>
    <path d="m12.8 11.2c-.3.3-.8.3-1.1 0-1-1-2.5-1-3.4 0-.3.3-.8.3-1.1 0-1-1-2.5-1-3.4 0s-.4.4-.4.4c-.3.3-.3.8 0 1.1s.8.3 1.1 0 .4-.4.4-.4c.3-.3.8-.3 1.1 0 1 .9 2.5.9 3.4 0 .3-.3.8-.3 1.1 0 1 1 2.5 1 3.4 0s.3-.3.3-.3c.2-.2.3-.4.2-.6-.6 0-1.1-.2-1.6-.3z"/>
    <path d="m8.3 7.6c-.3.3-.8.3-1.1 0-1-1-2.5-1-3.4 0l-.4.4c-.3.3-.3.8 0 1.1s.8.3 1.1 0 .4-.4.4-.4c.3-.3.8-.3 1.1 0 1 .9 2.5.9 3.4 0 0 0 .1-.1.2-.1-.3-.4-.5-.9-.7-1.4-.2.1-.4.3-.6.4z"/>
  </svg>
  <span class="for-screen-reader">Add a new text page</span>
<% end %>

<%= book_part_create_button book, Picture do %>
  <svg viewBox="0 0 20 24" xmlns="http://www.w3.org/2000/svg" fill="var(--color-ink)">
    <path d="m14.4 16.8s.2-.2.2-.3v-5.1c-2.8-.2-5.1-2.2-5.8-4.9h-4.2c-.8 0-1.4.6-1.4 1.4v11.1c0 .8.6 1.5 1.5 1.5h1.2s.2 0 .3-.2l4.4-6.8c.2-.3.3-.4.7-.4s.5.2.7.4l2.2 3.1c0 .2.3.2.4 0zm-7.3-1.9c-.9 0-1.7-.8-1.7-1.7s.8-1.7 1.7-1.7 1.7.8 1.7 1.7-.8 1.7-1.7 1.7z"/>
    <path d="m11.2 15.8c0-.2-.2-.2-.3 0s-2.6 4.1-2.6 4.1v.4h.2 4.3c.3 0 .7-.2.8-.3s.2-.2 0-.3l-2.4-3.8z"/>
    <path d="m15.8 21.7c0 .3-.2.4-.4.4h-13.5-.2v-16.9c0-.3.2-.4.4-.4h6.3c0-.6.1-1.2.3-1.8h-6.9c-1 0-1.8.8-1.8 1.8v17.5c0 1 .8 1.8 1.8 1.8h14c.9 0 1.6-.6 1.8-1.4v-11.6c-.5.2-1.1.4-1.8.5v10.3z"/>
    <path fill="var(--color-positive)" d="m15 0c-2.8 0-5 2.2-5 5s2.2 5 5 5 5-2.2 5-5-2.2-5-5-5zm1.9 5.6h-1.2c-.1 0-.2 0-.2.2v1.2c0 .3-.3.6-.6.6s-.6-.3-.6-.6v-1.2c0-.1 0-.2-.2-.2h-1.2c-.3 0-.6-.3-.6-.6s.3-.6.6-.6h1.2c.1 0 .2 0 .2-.2v-1.2c0-.3.3-.6.6-.6s.6.3.6.6v1.2c0 .1 0 .2.2.2h1.2c.3 0 .6.3.6.6s-.3.6-.6.6z"/>
  </svg>
  <span class="for-screen-reader">Add a new picture page</span>
<% end %>

<%= book_part_create_button book, Section do %>
  <svg viewBox="0 0 20 24" xmlns="http://www.w3.org/2000/svg" fill="var(--color-ink)">
    <path d="m15 11.5c-3.6 0-6.5-2.9-6.5-6.5s0-.2 0-.2h-6.3c-.3 0-.4.2-.4.4v16.9s0 .2.2 0h13.4c.3 0 .4-.2.4-.4v-10.3c-.2 0-.5 0-.8 0z" opacity="0"/>
    <path d="m15.8 21.7c0 .3-.2.4-.4.4h-13.5-.2v-16.9c0-.3.2-.4.4-.4h6.3c0-.6.1-1.2.3-1.8h-6.9c-1 0-1.8.8-1.8 1.8v17.5c0 1 .8 1.8 1.8 1.8h14c.9 0 1.6-.6 1.8-1.4v-11.6c-.5.2-1.1.4-1.8.5v10.3z"/>
    <path fill="var(--color-positive)" d="m15 0c-2.8 0-5 2.2-5 5s2.2 5 5 5 5-2.2 5-5-2.2-5-5-5zm1.9 5.6h-1.2c-.1 0-.2 0-.2.2v1.2c0 .3-.3.6-.6.6s-.6-.3-.6-.6v-1.2c0-.1 0-.2-.2-.2h-1.2c-.3 0-.6-.3-.6-.6s.3-.6.6-.6h1.2c.1 0 .2 0 .2-.2v-1.2c0-.3.3-.6.6-.6s.6.3.6.6v1.2c0 .1 0 .2.2.2h1.2c.3 0 .6.3.6.6s-.3.6-.6.6z"/>
    <path d="m4.4 14.5.4-.4c.3-.3.8-.3 1.1 0 1 .9 2.5.9 3.4 0 .3-.3.8-.3 1.1 0 1 1 2.5 1 3.4 0l.3-.3c.3-.3.3-.8 0-1.1s-.8-.3-1.1 0l-.3.3c-.3.3-.8.3-1.1 0-1-1-2.5-1-3.4 0-.3.3-.8.3-1.1 0-1-1-2.5-1-3.4 0l-.4.4c-.3.3-.3.8 0 1.1s.8.3 1.1 0z"/>
  </svg>
  <span class="for-screen-reader">Add a new section page</span>
<% end %>

```


<!-- ===== app/views/books/_edit_mode.html.erb ===== -->

```
<%= tag.div class: "flex align-center gap flex-item-no-shrink",
      data: {
        controller: "edit-mode",
        edit_mode_target_url_value: target_url,
        edit_mode_editing_class: "edit-mode",
        edit_mode_autosave_outlet: "[data-controller='autosave']",
      } do %>
  <%= image_tag "eye.svg", aria: { hidden: true }, size: 28, class: "colorize--black" %>
  <label class="switch txt-medium">
    <%= check_box_tag :edit_mode_enabled, checked: checked, class: "switch__input", data: { action: "edit-mode#change" } %>
    <span class="switch__btn round"></span>
    <span class="for-screen-reader">Editing mode</span>
  </label>
  <%= image_tag "write.svg", aria: { hidden: true }, size: 24, class: "colorize--black" %>
<% end %>

```


<!-- ===== app/views/books/_form.html.erb ===== -->

```
<%= form_with model: book, id: "book-editor" do |form| %>
  <%= tag.div class:"book__form flex align-center gap full-width #{"theme--#{book&.theme}" unless book.cover.attached? }", style:"--input-padding: 0.5rem 1rem; --input-border-radius: 0.5rem" do %>
    <div class="flex gap-half">
      <fieldset class="flex flex-column unpad margin-block-end borderless justify-space-between">
        <legend class="for-screen-reader">Cover color</legend>

        <% Book.themes.keys.each do | theme | %>
          <label class="btn btn--circle txt-small" style="--btn-background: var(--theme-color--<%= theme -%>)" >
            <%= form.radio_button :theme, theme %>
            <%= image_tag "check.svg", aria: { hidden: "true" }, size: 24, class: "checked" %>
            <span class="for-screen-reader"><%= theme %></span>
          </label>
        <% end %>
      </fieldset>
      <%= tag.div class: "flex flex-column", data: { controller: "upload-preview", upload_preview_default_image_value: asset_url("empty-cover.png") } do %>
        <label class="align-center center gap position-relative margin-block-end">
          <% unless book.cover.attached? %>
            <span class="btn btn--reversed txt-medium book__cover--add">
              <%= image_tag "camera.svg", aria: { hidden: "true" }, size: 24 %>
              <span class="for-screen-reader">Upload a cover</span>
            </span>
          <% end %>

          <div class="input--file">
            <%= image_tag book.cover.attached? ? book.cover : "empty-cover.png", alt: "Book cover",
                class: "book__cover margin-none", style: "--cover-height: 60vh",
                data: { upload_preview_target: "image" } %>
            <%= form.file_field :cover, class: "input", accept: "image/png, image/jpeg, image/jpg, image/webp",
                data: { upload_preview_target: "input", action: "upload-preview#previewImage" },
                title: book.cover.attached? ? "Replace book cover" : "Upload book cover" %>
          </div>
        </label>

        <% if book.cover.attached? %>
          <%= tag.label class:"btn btn--negative txt-small center book__cover--remove", data: { action: "click->upload-preview#clear", upload_preview_target: "button" } do %>
            <%= image_tag "minus.svg", aria: { hidden: "true" }, size: 24 %>
            <%= check_box_tag "remove_cover", "true" %>
            <span class="for-screen-reader">Remove cover image</span>
          <% end %>
        <% end %>
      <% end %>
    <% end %>

    <div class="flex flex-column gap full-width">
      <div class="flex align-center gap txt-medium">
        <%= translation_button(:book_title) %>
        <h1 class="txt-xx-large margin-none full-width">
          <%= form.text_field :title, required: true, autofocus: true, class: "input", placeholder: "Book title", autocomplete: "off" %>
        </h1>
      </div>
      <div class="flex align-center gap txt-medium">
        <%= translation_button(:book_subtitle) %>
        <small class="txt-normal txt-large txt-tight-lines full-width"><%= form.text_area :subtitle, class: "input", placeholder: "Subtitle", autocomplete: "off" %></small>
      </div>
      <div class="flex align-center gap txt-medium">
        <%= translation_button(:book_author) %>
        <small class="txt-normal txt-large txt-tight-lines full-width"><%= form.text_field :author, class: "input", placeholder: "Author", autocomplete: "off" %></small>
      </div>
    </div>
  </div>

  <div class="book-access border-radius center pad-double fill-shade flex flex-column gap margin-block-double">
    <div class="flex align-center gap txt-medium--responsive">
      <%= image_tag "eye.svg", aria: { hidden: true }, size: 36, class: "colorize--black" %>

      <div class="min-width">
        <div class="overflow-ellipsis fill-shade"><strong>Everyone</strong></div>
      </div>

      <hr class="flex-item-grow margin-none" aria-hidden="true" style="--border-style: dashed">

      <label for="book_everyone_access" class="switch">
        <%= form.check_box :everyone_access, class: "switch__input book-access__switch" %>
        <span class="switch__btn"></span>
        <span class="for-screen-reader">Only allow some people to read this book</span>
      </label>
    </div>

    <hr class="full-width margin-block-start margin-block-end-half">

    <%= render partial: "books/accesses/access", collection: users, as: :user, locals: { book: book, creating_user: creating_user } %>
  </div>

  <%= form.submit "Save", hidden: true %>
<% end %>

```


<!-- ===== app/views/books/_index_link.html.erb ===== -->

```
<%= link_to root_path, class: "btn borderless txt-small flex-item-no-shrink" do %>
  <%= image_tag "books.svg", aria: { label: "Books" }, size: 19, class: "colorize--black", alt: "Books" %>
  <span class="for-screen-reader">All books</span>
<% end %>

```


<!-- ===== app/views/books/_mode_buttons.html.erb ===== -->

```
<label class="btn arrange-mode__button txt-medium flex-item-justify-end disable-when-deleting disable-when-empty">
  <input type="checkbox" name="arrange-mode" id="arrange-mode" data-action="arrangement#setArrangeMode">
  <%= image_tag "rearrange.svg", aria: { hidden: true }, size: 24 %>
  <span class="for-screen-reader">Rearrange</span>
</label>

<label class="btn delete-mode__button txt-medium disable-when-arranging disable-when-empty">
  <input type="checkbox" id="delete-mode">
  <%= image_tag "minus.svg", aria: { hidden: true }, size: 24 %>
  <span class="for-screen-reader">Delete pages</span>
</label>

```


<!-- ===== app/views/books/_new.html.erb ===== -->

```
<figure class="library__book position-relative">
  <div class="library__book--empty center">
    <%= image_tag "empty-cover.png", alt: "Book cover", class: "book__cover" %>
    <span class="btn btn--positive center">
      <%= image_tag "add.svg", aria: { hidden: true }, size: 24 %>
      <span class="for-screen-reader"></span>
    </span>
  </div>
  <%= link_to new_book_path, class: "bookmark__link" do %>
    <span class="for-screen-reader">Create a new book</span>
  <% end %>
</figure>

```


<!-- ===== app/views/books/accesses/_access.html.erb ===== -->

```
<div class="flex align-center gap txt-medium--responsive" data-controller="dependent-checkbox">
  <span class="flex align-center gap-half">
    <% if user.can_administer? %>
      <%= image_tag "crown.svg", size: 18, aria: { hidden: "true" }, class: "colorize--black" %>
    <% end %>
    <span class="overflow-ellipsis txt-medium--responsive"><%= user.name %></span>
  </span>
  <hr class="flex-item-grow margin-none" aria-hidden="true" style="--border-style: dashed">

  <fieldset class="flex align-center gap borderless unpad margin-none">
    <legend class="for-screen-reader"><%= user.name %></legend>
    <label class="btn btn--small flex-item-no-shrink">
      <%= check_box_tag "editor_ids[]", user.id, book.editable?(user: user) || user == creating_user || user.can_administer?, id: nil, disabled: user.current? || user.can_administer?, data: { action: "dependent-checkbox#input", dependent_checkbox_target: "dependant" }, aria: { label: "Role: Writer" } %>
      <%= image_tag "write.svg", size: 24, aria: { hidden: "true" } %>
      <span class="for-screen-reader"></span>
    </label>

    <label class="btn btn--small flex-item-no-shrink book-access__reader">
      <%= check_box_tag "reader_ids[]", user.id, book.accessable?(user: user) || user == creating_user || user.can_administer?, id: nil, disabled: user.current? || user.can_administer?, data: { action: "dependent-checkbox#input", dependent_checkbox_target: "dependee" }, aria: { label: "Role: Reader" } %>
      <%= image_tag "eye.svg", size: 24, aria: { hidden: "true" } %>
      <span class="for-screen-reader"></span>
    </label>
  </fieldset>
</div>

```


<!-- ===== app/views/books/accesses/_editor.html.erb ===== -->

```
<%= button_to book_user_access_path(book, user), method: :delete, class: "btn txt-small flex-item-no-shrink" do %>
  <%= image_tag "write.svg", size: 24, aria: { hidden: "true" } %>
  <span class="for-screen-reader">Role: Writer</span>
<% end %>

```


<!-- ===== app/views/books/accesses/_none.html.erb ===== -->

```
<%= button_to book_user_access_path(book, user), params: { level: :reader }, class: "btn txt-small flex-item-no-shrink" do %>
  <%= image_tag "remove.svg", size: 24, aria: { hidden: "true" } %>
  <span class="for-screen-reader">Role: None</span>
<% end %>

```


<!-- ===== app/views/books/accesses/_reader.html.erb ===== -->

```
<%= button_to book_user_access_path(book, user), params: { level: :editor }, class: "btn txt-small flex-item-no-shrink" do %>
  <%= image_tag "eye.svg", size: 24, aria: { hidden: "true" } %>
  <span class="for-screen-reader">Role: Reader</span>
<% end %>

```


<!-- ===== app/views/books/bookmarks/show.html.erb ===== -->

```
<%= turbo_frame_tag dom_id(@book, :bookmark) do %>
  <% if @leaf %>
    <%= link_to book_slug_path(@book, anchor: dom_id(@leaf)), class: "bookmark__link" do %>
      <span class="for-screen-reader">Bookmark: Resume reading <%= @book.title %></span>
    <% end %>

    <%= tag.span class: "bookmark", style: "--progress: #{ @leaf.position_as_percentage }%" do %>
      <div class="flex align-center">
        <span class="bookmark__icon">
          <svg viewBox="0 0 64 64" width="64px" height="64px" xmlns="http://www.w3.org/2000/svg">
            <path d="m17.01 54.01v-42.98.00000045c-.00000025-1.65685 1.34315-3 3-3h24-.00000013c1.65685-.00000007 3 1.34315 3 3v42.98.0001206c0 1.10457-.895431 2-2 2-.34994 0-.693756-.0918173-.997105-.266281l-11.5039-6.61564c-.308638-.17748-.688362-.17748-.997 0l-11.5046 6.6153.00000011-.00000006c-.957413.550849-2.1801.221264-2.73095-.736149-.174564-.303405-.266442-.647312-.266451-.997351z" fill-rule="evenodd" fill="var(--color-marker)" />
          </svg>
        </span>
      </div>
    <% end %>
  <% else %>
    <%= link_to book_slug_path(@book), class: "bookmark__link" do %>
      <span class="for-screen-reader">Start reading <%= @book.title %></span>
    <% end %>
  <% end %>
<% end %>

```


<!-- ===== app/views/books/edit.html.erb ===== -->

```
<% content_for(:title) { "Edit #{@book.title}" } %>

<% content_for :header do %>
  <nav>
    <%= link_to book_slug_path(@book), class: "btn flex-item-justify-start" do %>
      <%= image_tag "arrow-left.svg", aria: { hidden: true }, size: 24 %>
      <span class="for-screen-reader">Cancel and go back</span>
    <% end %>
  </nav>
<% end %>

<%= render "books/form", book: @book, users: @users, creating_user: nil %>

<% content_for :footer do %>
  <nav class="flex align-end justify-center pad">
    <%= button_to book_path(@book), method: :delete, class: "btn btn--negative",
          data: { turbo_confirm: "Are you sure you want to delete this book? It cannot be undone." } do %>
      <%= image_tag "trash.svg", aria: { hidden: true }, size: 24 %>
      <span class="for-screen-reader">Delete <%= @book.title %></span>
    <% end %>
    <button type="submit" form="book-editor", class="new-book-btn btn btn--reversed center txt-medium--responsive" aria-label="Save changes" title="Save changes">
      <%= image_tag "check.svg", aria: { hidden: true }, size: 24 %>
    </button>
  </nav>
<% end %>

```


<!-- ===== app/views/books/index.html.erb ===== -->

```
<% content_for(:title) { "Library | Writebook" } %>
<% @layout_class = "books" %>

<% content_for :header do %>
  <nav>
    <span class="btn btn--placeholder" aria-hidden="true"></span>

    <a href="https://once.com/writebook" class="product__wordmark btn btn--plain txt-large center" target="_blank">
      <%= image_tag "writebook-icon.svg", aria: { hidden: true }, size: 24 %>
      <span>Writebook</span>
    </a>

    <% if Current.user %>
      <%= link_to users_path, class: "btn" do %>
        <%= image_tag "settings.svg", aria: { hidden: true }, size: 24 %>
        <span class="for-screen-reader">Manage people and settings</span>
      <% end %>
    <% else %>
      <%= link_to new_session_path, class: "btn" do %>
        <%= image_tag "login-keys.svg", aria: { hidden: true }, size: 24 %>
        <span class="for-screen-reader">Sign in</span>
      <% end %>
    <% end %>
  </nav>
<% end %>

<% cache [ @books, signed_in? ] do %>
  <div class="library">
    <%= render @books %>
    <%= render "books/new" if signed_in? %>
  </div>
<% end %>

```


<!-- ===== app/views/books/new.html.erb ===== -->

```
<% content_for(:title) { "Create a new book" } %>

<% content_for :header do %>
  <nav>
    <%= link_to root_path, class: "btn flex-item-justify-start" do %>
      <%= image_tag "arrow-left.svg", aria: { hidden: true }, size: 24 %>
      <span class="for-screen-reader">Cancel and go back</span>
    <% end %>
  </nav>
<% end %>

<%= render "books/form", book: @book, users: @users, creating_user: Current.user %>

<% content_for :footer do %>
  <nav class="new-book-btn flex justify-center pad">
    <button type="submit" form="book-editor", class="btn btn--reversed txt-medium--responsive" aria-label="Create book" title="Create book">
      <%= image_tag "arrow-right.svg", aria: { hidden: true }, size: 24 %>
    </button>
  </nav>
<% end %>

```


<!-- ===== app/views/books/publications/_publication.html.erb ===== -->

```
<div class="flex flex-column gap margin-block-start pad <%= book.published? ? "fill-selected" : "fill-shade" %> border-radius">
  <% if book.editable? %>
    <div class="flex align-center justify-center gap-half center">
      <%= image_tag "lock.svg", aria: { hidden: true }, size: 36, class: "colorize--black" %>
        <%= form_with model: book, url: book_publication_path(book), data: { controller: "form", action: "change->form#submit" }, html: { contents: true } do |form| %>
          <label class="switch txt-medium">
            <%= form.check_box :published, checked: book.published?, class: "switch__input" %>
            <span class="switch__btn round"></span>
            <span class="for-screen-reader">Publish this book</span>
          </label>
        <% end %>
      <%= image_tag "world.svg", aria: { hidden: true }, size: 36, class: "colorize--black" %>
    </div>
  <% end %>

  <% if book.published? %>
    <div class="flex flex-column align-center gap txt-medium">
      <% public_url = book_slug_url(book) %>

      <label class="flex flex-column gap full-width txt-align-center">
        <strong id="invite_label" class="invite-label for-screen-reader">Public link to this book</strong>
        <input type="text" class="input fill-white" id="invite_url" value="<%= public_url %>" aria-labelledby="invite_label" readonly>
      </label>

      <div class="flex align-center gap">
        <div data-controller="dialog" class="flex-inline">
          <%= tag.button class: "btn", data: { action: "dialog#open" } do %>
            <%= image_tag "qr-code.svg", aria: { hidden: "true" }, size: 24, class: "colorize--black" %>
            <span class="for-screen-reader">Show public link QR code</span>
          <% end %>

          <dialog class="dialog panel shadow" data-dialog-target="dialog">
            <%= qr_code_image(public_url) %>

            <form method="dialog" class="flex justify-center">
              <button class="btn panel__close" title="Close (esc)">
                <%= image_tag "remove.svg", aria: { hidden: true }, size: 24 %>
                <span class="for-screen-reader">Close</span>
              </button>
            </form>
          </dialog>
        </div>

        <%= button_to_copy_to_clipboard(public_url) do %>
          <%= image_tag "copy-paste.svg", aria: { hidden: "true" }, size: 24, class: "colorize--black" %>
          <span class="for-screen-reader">Copy public link</span>
        <% end %>

        <%= web_share_button(public_url, "Link to join Writebook", "Hit this link to join me in Writebook and start writing.") do %>
          <%= image_tag "share.svg", aria: { hidden: "true" }, size: 24, class: "colorize--black" %>
          <span class="for-screen-reader">Share public link</span>
        <% end %>

        <% if book.editable? %>
          <%= link_to edit_book_publication_path(book), class: "btn" do %>
            <%= image_tag "pencil.svg", aria: { hidden: "true" }, size: 24, class: "colorize--black" %>
            <span class="for-screen-reader">Edit link URL</span>
          <% end %>
        <% end %>
      </div>
    </div>
  <% end %>
</div>

```


<!-- ===== app/views/books/publications/edit.html.erb ===== -->

```
<%= turbo_frame_tag @book, :publication do %>
  <div class="flex flex-column gap margin-block-start pad fill-shade border-radius <%= "shake" if @book.errors[:slug].any? %>">
    <div class="flex flex-column align-center gap txt-medium">
      <% public_url = book_url(@book) %>

      <%= form_with model: @book, url: book_publication_path(@book), class: "max-width", data: { turbo_frame: "_top" } do |form| %>
        <%= form.hidden_field :publication, value: true %>

        <label class="flex flex-column gap full-width txt-align-center">
          <div id="public_link_label" class="flex align-center gap justify-center">
            <strong>Edit publication link</strong>
          </div>
          <span class="input input--actor flex align-center fill-white">
            <%= "#{request.host}/#{@book.id}/" %>
            <%= form.text_field :slug,
                  autofocus: true,
                  class: class_names("input"),
                  required: true,
                  pattern: "^[\\-A-Za-z0-9]+$",
                  title: "Enter letters, numbers, or hyphens only" %>
          </span>
        </label>

        <div class="flex align-center gap margin-inline margin-block-start">
          <button type="submit" class="btn btn--positive flex-item-justify-end">
            <%= image_tag "check.svg", aria: { hidden: true }, size: 24 %>
            <span class="for-screen-reader">Save</span>
          </button>

          <%= link_to book_slug_path(@book), class: "btn flex-item-justify-start" do %>
            <%= image_tag "remove.svg", aria: { hidden: true }, size: 24 %>
            <span class="for-screen-reader">Cancel</span>
          <% end %>
        </div>
      <% end %>
    </div>
  </div>
<% end %>

```


<!-- ===== app/views/books/publications/show.html.erb ===== -->

```
<%= turbo_frame_tag @book, :publication do %>
  <%= render "publication", book: @book %>
<% end %>

```


<!-- ===== app/views/books/searches/_banner.html.erb ===== -->

```
<% if params[:search].present? %>
  <div class="search__banner flex-inline align-center gap-half txt-medium--responsive">
    <span>Highlighted: <strong><%= params[:search] %></strong></span>

    <%= link_to leafable_slug_path(@leaf), class: "btn txt-small borderless" do %>
      <%= image_tag "remove.svg", aria: { hidden: true }, size: 24 %>
      <span class="for-screen-reader">Clear highlights</span>
    <% end %>
  </div>
<% end %>

```


<!-- ===== app/views/books/searches/_form.html.erb ===== -->

```
<%= form_with url: book_search_url(book), id: "search_form" do %><% end %>

```


<!-- ===== app/views/books/searches/_result.html.erb ===== -->

```
<%= link_to edit_leafable_path(leaf, search: params[:search]), class: "search__result hide_from_reading_mode txt-ink", data: { turbo_frame: "_top" } do %>
  <strong><%= sanitize_search_result(leaf.title_match) %>:</strong> <%= sanitize_search_result(leaf.content_match) %>
<% end %>
<%= link_to leafable_slug_path(leaf, search: params[:search]), class: "search__result hide_from_edit_mode txt-ink", data: { turbo_frame: "_top" } do %>
  <strong><%= sanitize_search_result(leaf.title_match) %>:</strong> <%= sanitize_search_result(leaf.content_match) %>
<% end %>

```


<!-- ===== app/views/books/searches/_results.html.erb ===== -->

```
<%= turbo_frame_tag :search do %>
  <%= render "books/searches/form", book: book %>

  <div class="search__results flex flex-column margin-block-start">
    <% if @leaves.any? %>
      <% @leaves.each do |leaf| %>
        <%= render "books/searches/result", leaf: leaf %>
      <% end %>
    <% else %>
      <p class="search__no_matches txt-align-center">No matches.</p>
    <% end %>
  </div>
<% end %>

```


<!-- ===== app/views/books/searches/_search.html.erb ===== -->

```
<div data-controller="dialog" data-action="keydown.ctrl+space@document->dialog#open keydown.esc->dialog#close">
  <button data-action="click->dialog#open" class="btn" title="Search (control + space)">
    <%= image_tag "search.svg", aria: { hidden: true }, size: 24 %>
    <span class="for-screen-reader">Search</span>
  </button>

  <dialog data-dialog-target="dialog" class="search__modal dialog panel shadow">
    <form method="dialog">
      <button class="btn panel__close" title="Close (esc)">
        <%= image_tag "remove.svg", aria: { hidden: true }, size: 24 %>
        <span class="for-screen-reader">Close</span>
      </button>
    </form>

    <div class="flex align-center gap">
      <label class="flex align-center gap full-width">
        <div class="flex align-center gap input input--actor">
          <%= image_tag "search.svg", aria: { hidden: "true" }, size: 24, class: "colorize--black" %>
          <%= search_field_tag :search, nil, form: "search_form", class: "search__input input full-width txt-large", autocomplete: "off", autofocus: true, placeholder: "Find in this book…" %>
        </div>

        <button class="btn btn--reversed txt-medium" title="Submit search (enter)" form="search_form" type="submit" tabindex="-1">
          <%= image_tag "arrow-right.svg", aria: { hidden: true }, size: 24 %>
          <span class="for-screen-reader">Submit search</span>
        </button>
      </label>
    </div>

    <%= turbo_frame_tag :search do %>
      <%= render "books/searches/form", book: book %>
    <% end %>
  </dialog>
</div>

```


<!-- ===== app/views/books/searches/create.html.erb ===== -->

```
<%= render "books/searches/results", book: @book, leaves: @leaves %>

```


<!-- ===== app/views/books/show.html.erb ===== -->

```
<% content_for(:title) { @book.title } %>
<% @layout_class = "book" %>

<% content_for :head do %>
  <%= tag.link rel: "alternate", type: "text/markdown", href: book_slug_path(@book, format: :md) %>
  <%= tag.meta property: "og:title", content: @book.title %>
  <%= tag.meta property: "og:description", content: @book.subtitle %>
  <%= tag.meta property: "og:image", content: @book.cover.blank? ? asset_url("covers/cover-#{@book.theme}-og.png") : "#{root_url}#{url_for(@book.cover)}" %>
  <%= tag.meta property: "og:url", content: book_slug_url(@book) %>

  <%= tag.meta property: "twitter:title", content: @book.title %>
  <%= tag.meta property: "twitter:description", content: @book.subtitle %>
  <%= tag.meta property: "twitter:image", content: @book.cover.blank? ? asset_url("covers/cover-#{@book.theme}-og.png") : "#{root_url}#{url_for(@book.cover)}" %>
  <%= tag.meta property: "twitter:card", content: "summary_large_image" %>
<% end %>

<% content_for :header do %>
  <nav class="book__navbar">
    <%= link_to root_path, class: "btn" do %>
      <%= image_tag "arrow-left.svg", aria: { hidden: true }, size: 24 %>
      <span class="for-screen-reader">Go back</span>
    <% end %>

    <span class="btn btn--placeholder placeholder-start" aria-hidden="true"></span>

    <div class="breadcrumbs">
      <%= render "books/index_link" %>
      <span class="flex-item-no-shrink">▸</span>
      <strong><%= @book.title %></strong>
    </div>

    <%= link_to_first_leafable(@leaves) %>

    <span class="btn btn--placeholder placeholder-end" aria-hidden="true"></span>

    <button class="btn fullscreen" data-action="fullscreen#toggle" data-fullscreen-target="button">
      <%= image_tag "expand.svg", aria: { hidden: true }, size: 24 %>
      <span class="for-screen-reader">Enter fullscreen</span>
    </button>

    <%= render "books/searches/search", book: @book %>

    <% if @book.editable? %>
      <%= link_to edit_book_path(@book), class: "btn settings" do %>
        <%= image_tag "settings.svg", aria: { hidden: true }, size: 24 %>
        <span class="for-screen-reader">Edit book settings</span>
      <% end %>
    <% end %>
  </nav>
<% end %>

<% cache [ @book, @book.editable? ] do %>
  <aside class="txt-align-center margin-block">
    <div class="book__sidebar <%= "theme--#{@book&.theme}" unless @book.cover.attached? %>">
      <% if @book.cover.attached? %>
        <%= link_to rails_blob_path(@book.cover, disposition: "attachment", only_path: true), data: { action: "lightbox#open:prevent", lightbox_target: "image", lightbox_url_value: rails_blob_path(@book.cover, disposition: "attachment", only_path: true) } do %>
          <%= image_tag @book.cover, alt: "Cover for #{ @book.title }", class: "book__cover margin-block-none center" %>
        <% end %>
      <% else %>
        <span class="book__cover-wrapper">
          <%= image_tag "empty-cover.png", alt: "Book cover", class: "book__cover margin-block-none center" %>
          <span class="book__title overflow-line-clamp pad txt-align-start txt-tight-lines"" style="--lines: 6" aria-hidden="true"><%= @book.title %></span>
        </span>
      <% end %>

      <% if @book.editable? %>
        <%= turbo_frame_tag @book, :publication do %>
          <%= render "books/publications/publication", book: @book %>
        <% end %>
      <% end %>

      <span data-controller="edit-mode" data-edit-mode-editing-class="edit-mode" />
    </div>
  </aside>

  <%= arrangement_tag @book, class: "arrangement__container toc__container full-width txt-align-center" do %>
    <h1 class="flex flex-column txt-tight-lines txt-align-start margin-block-end">
      <strong class="book__title txt-x-large--responsive"><%= @book.title %></strong>
      <span class="txt-large--responsive txt-normal"><%= @book.subtitle %></span>
      <span class="txt-large--responsive txt-normal"><%= @book.author %></span>
    </h1>

    <div class="book__toolbar fill-white flex gap-half pad-block margin-block-end-half justify-center <%= "position-sticky" if @book.editable? %>" data-controller="toc-view" data-toc-view-id-value="<%= dom_id(@book) %>">
      <label class="btn txt-medium disable-when-empty">
        <input type="radio" name="view" id="toc-list" value="list" data-toc-view-target="switch" data-toc-view-type-value="list" data-action="toc-view#saveViewPref">
        <%= image_tag "view-list.svg", aria: { hidden: true }, size: 24 %>
        <span class="for-screen-reader">List view</span>
      </label>

      <label class="btn txt-medium flex-item-justify-start disable-when-empty">
        <input type="radio" name="view" id="toc-grid" value="grid" checked="checked" data-toc-view-target="switch" data-toc-view-type-value="grid" data-action="toc-view#saveViewPref">
        <%= image_tag "view-grid.svg", aria: { hidden: true }, size: 24 %>
        <span class="for-screen-reader">Page view</span>
      </label>

      <% if @book.editable? %>
        <%= render "books/create_buttons", book: @book %>
        <%= render "books/mode_buttons", book: @book %>
      <% end %>
    </div>

    <div class="position-relative">
      <% if @book.editable? %>
        <div class="toc__blank-slate align-center justify-start">
          <%= image_tag "blank-slate-arrows.svg", aria: { hidden: true }, size: 60, class: "colorize--black" %>
          <span class="flex align-center gap-half"><span>🇺🇸</span> <span>Pick a page type to get started</span></span>
          <span class="flex align-center gap-half"><span>🇪🇸</span> <span>Elige un tipo de página para comenzar</span></span>
          <span class="flex align-center gap-half"><span>🇫🇷</span> <span>Choisissez un type de page pour commencer</span></span>
          <span class="flex align-center gap-half"><span>🇮🇳</span> <span>शुरू करने के लिए एक पृष्ठ प्रकार चुनें</span></span>
          <span class="flex align-center gap-half"><span>🇩🇪</span> <span>Wählen Sie einen Seitentyp, um zu beginnen</span></span>
          <span class="flex align-center gap-half"><span>🇧🇷</span> <span>Escolha um tipo de página para começar</span></span>
        </div>
      <% end %>

      <menu class="toc margin-none" tabindex="0" data-arrangement-target="container" data-action="<%= arrangement_actions %>">
        <%= turbo_frame_tag :leaves, data: { arrangement_target: "list" } do -%>
          <%= render partial: "leaves/leaf", collection: @leaves, as: :leaf -%>
        <% end -%>
      </menu>

      <div data-arrangement-target="layer" class="toc"></div>
      <div data-arrangement-target="dragImage" class="arrangement-drag-image"></div>
    </div>
  <% end %>
<% end %>

<% content_for :footer do %>
  <nav class="book__nav flex align-center justify-center">
    <a href="https://once.com/writebook" class="product__wordmark btn btn--plain txt-medium" target="_blank">
      <%= image_tag "writebook-icon.svg", aria: { hidden: true }, size: 24 %>
      <span>Made with Writebook</span>
    </a>
  </nav>
<% end %>

```


<!-- ===== app/views/books/show.md.erb ===== -->

```
---
title: "<%= @book.title %>"
author: "<%= @book.author %>"
url: "<%= book_slug_url(@book) %>"
---

<%= raw @book.markable %>
```


<!-- ===== app/views/books/users/accesses/create.html.erb ===== -->

```
<%= render "books/accesses/access", user: @user, book: @book %>

```


<!-- ===== app/views/books/users/accesses/destroy.html.erb ===== -->

```
<%= render "books/accesses/access", user: @user, book: @book %>

```


<!-- ===== app/views/first_runs/show.html.erb ===== -->

```
<% content_for(:title) { "Set up Writebook" } %>

<div class="panel shadow center margin-block-double <%="shake" if flash[:alert] %>">
  <%= image_tag "writebook-icon.svg", class: "product__logo center colorize--black", size: 130 %>
  <h1 class="margin-none-block-start margin-block-end-double">Writebook</h1>

  <%= form_with model: @user, url: first_run_path, class: "flex flex-column gap" do |form| %>
    <div class="flex align-center gap">
      <%= translation_button(:user_name) %>
      <label class="flex align-center gap input input--actor txt-large">
        <%= form.text_field :name, class: "input", autocomplete: "name", placeholder: "Name", autofocus: true, required: true, data: { "1p-ignore": true } %>
        <%= image_tag "person.svg", aria: { hidden: "true" }, size: 30, class: "colorize--black" %>
      </label>
    </div>

    <div class="flex align-center gap">
      <%= translation_button(:email_address) %>
      <label class="flex align-center gap input input--actor txt-large">
        <%= form.email_field :email_address, class: "input", autocomplete: "username", placeholder: "Email address", required: true %>
        <%= image_tag "email.svg", aria: { hidden: "true" }, size: 30, class: "colorize--black" %>
      </label>
    </div>

    <div class="flex align-center gap">
      <%= translation_button(:password) %>
      <label class="flex align-center gap input input--actor txt-large">
        <%= form.password_field :password, class: "input", autocomplete: "new-password", placeholder: "Password", required: true, maxlength: 72 %>
        <%= image_tag "password.svg", aria: { hidden: "true" }, size: 30, class: "colorize--black" %>
      </label>
    </div>
    <button type="submit" id="log_in" class="btn btn--reversed center">
      <%= image_tag "arrow-right.svg", aria: { hidden: true }, size: 24 %>
      <span class="for-screen-reader">Create your account</span>
    </button>
  <% end %>
</div>

```


<!-- ===== app/views/layouts/_lightbox.html.erb ===== -->

```
<dialog class="lightbox" aria-label="Image Viewer (Press escape to close)" data-lightbox-target="dialog" data-action="close->lightbox#reset">
  <img src="" class="lightbox__image" data-lightbox-target="zoomedImage" />

  <form method="dialog" class="lightbox__btn">
    <button class="btn fill-white" title="Close (esc)">
      <%= image_tag "remove.svg", aria: { hidden: "true" } %>
      <span class="for-screen-reader">Close image viewer (esc)</span>
    </button>
  </form>
</dialog>

```


<!-- ===== app/views/layouts/application.html.erb ===== -->

```
<!DOCTYPE html>
<html>
  <head>
    <title><%= content_for(:title) || "Writebook" %></title>

    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta charset="UTF-8">
    <meta name="color-scheme" content="light dark">
    <meta name="theme-color" content="#ffffff" media="(prefers-color-scheme: light)">
    <meta name="theme-color" content="#000000" media="(prefers-color-scheme: dark)">
    <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no, interactive-widget=resizes-content">
    <meta name="view-transition" content="same-origin">
    <meta name="turbo-cache-control" content="no-cache">

    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    <% if signed_in? %>
      <%= hide_from_user_style_tag %>
    <% end %>

    <%= yield :head %>

    <link rel="manifest" href="/manifest.json">
    <link rel="icon" href="/favicon.svg" type="image/svg+xml">
    <link rel="icon" href="/favicon.png" type="image/png">
    <link rel="apple-touch-icon" href="/app-icon.png">

    <%= stylesheet_link_tag :all, "data-turbo-track": "reload" %>
    <%= custom_styles_tag %>

    <%= javascript_importmap_tags %>
  </head>

  <body data-controller="fullscreen lightbox touch">
    <header id="header">
      <%= yield :header %>
    </header>

    <div id="toolbar">
      <%= yield :toolbar %>
    </div>

    <main id="main" class="<%= @layout_class %>">
      <%= yield %>
    </main>

    <aside id="sidebar" aria-label="Table of Contents">
      <%= yield :sidebar %>
    </aside>

    <footer id="footer">
      <%= yield :footer %>
    </footer>

    <%= render "layouts/lightbox" %>
  </body>
</html>

```


<!-- ===== app/views/layouts/mailer.html.erb ===== -->

```
<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <style>
      /* Email styles need to be inline */
    </style>
  </head>

  <body>
    <%= yield %>
  </body>
</html>

```


<!-- ===== app/views/layouts/mailer.text.erb ===== -->

```
<%= yield %>

```


<!-- ===== app/views/leafables/_edit_header.html.erb ===== -->

```
<nav>
  <%= render "leaves/sidebar_toggle" %>

  <%= link_to_previous_leafable(leaf, hotkey: false, for_edit: true) %>

  <div class="breadcrumbs">
    <%= render "books/index_link" %>
    <span class="flex-item-no-shrink">▸</span>
    <%= link_to book.title, book_slug_path(book) %>
    <span class="flex-item-no-shrink">▸</span>
    <%= form_with model: [ book, leaf ], url: leafable_path(leaf), class: "flex align-center gap-half", format: :html do |form| %>
      <strong class="min-width"><%= form.text_field :title, form: "leafable-editor", class: "input full-width", autocomplete: "off" %></strong>
    <% end %>
  </div>

  <button class="btn" data-action="fullscreen#toggle" data-fullscreen-target="button">
    <%= image_tag "expand.svg", aria: { hidden: true }, size: 24 %>
    <span class="for-screen-reader">Enter fullscreen</span>
  </button>

  <%= render "books/searches/search", book: @book %>
</nav>

```


<!-- ===== app/views/leafables/create.turbo_stream.erb ===== -->

```
<% if params[:position].present? %>
  <%= turbo_stream.replace :dragged_item, partial: "leaves/edit", locals: { leaf: @leaf } %>
<% else %>
  <%= turbo_stream.append :leaves, partial: "leaves/edit", locals: { leaf: @leaf } %>
<% end %>

<%= turbo_stream.scroll_into_view @leaf, animation: :wiggle %>

```


<!-- ===== app/views/leafables/destroy.turbo_stream.erb ===== -->

```
<%= turbo_stream.remove @leaf %>

```


<!-- ===== app/views/leafables/show.html.erb ===== -->

```
<% content_for(:title) { page_title(@leaf, @book) } %>

<% content_for :head do %>
  <%= tag.link rel: "alternate", type: "text/markdown", href: leafable_slug_path(@leaf, format: :md) %>
<% end %>

<% content_for :header do %>
  <%= render "leaves/header", book: @book, leaf: @leaf %>
<% end %>

<% content_for :sidebar do %>
  <%= render "leaves/sidebar", book: @book %>
<% end %>

<% if @leaf.section? %>
  <div class="page--section <%= "theme--dark" if @leaf.leafable.theme == "dark" %>">
    <h1><%= highlight_searched_content @leaf, simple_format(@leaf.section.body), params[:search] %></h1>
  </div>
<% elsif @leaf.page? %>
  <div class="page--page" data-controller="scroll-to-highlight">
    <%= highlight_searched_content @leaf, sanitize_content(@leaf.page.body.to_html), params[:search] %>
  </div>
<% elsif @leaf.picture? %>
  <figure class="page--picture flex flex-column align-center gap margin-none">
    <% if @leaf.picture.image.attached? %>
      <%= link_to rails_blob_path(@leaf.picture.image), data: {
            action: "lightbox#open:prevent",
            lightbox_target: "image",
            lightbox_url_value: rails_blob_path(@leaf.picture.image, disposition: "attachment", only_path: true) } do %>
        <%= image_tag @leaf.picture.large_image, loading: "lazy" %>
      <% end %>
    <% else %>
      <%= image_tag "default-picture.webp", alt: "No image uploaded", loading: "lazy" %>
    <% end %>

    <figcaption>
      <%= simple_format @leaf.picture.caption %>
    </figcaption>
  </figure>
<% end %>

<% content_for :footer do %>
  <%= render "leaves/navigation", leaf: @leaf %>
<% end %>

```


<!-- ===== app/views/leafables/show.md.erb ===== -->

```
---
title: "<%= @leaf.title %>"
url: "<%= leafable_slug_url(@leaf) %>"
---

<%= raw @leaf.leafable.markable %>

```


<!-- ===== app/views/leaves/_being_edited_by.turbo_stream.erb ===== -->

```
<%= turbo_stream.append dom_id(leaf, :being_edited) do %>
  <%= tag.div id: dom_id(user, :being_edited_by),
        class: "flex-inline align-center justify-center margin-block-end-double txt-medium gap being-edited-by",
        data: { controller: "autoremove", action: "animationend->autoremove#remove", hide_from_user_id: user.id } do %>
    <strong class="margin-inline-end-half"><%= user.name %></strong>
    <span class="spinner txt-small flex-inline"></span>
    <%= image_tag "write.svg", aria: { hidden: true }, size: 18, class: "colorize--white margin-inline-start" %>
  <% end %>
<% end %>

```


<!-- ===== app/views/leaves/_being_edited_indicator.html.erb ===== -->

```
<%= turbo_stream_from leaf, :being_edited %>
<%= tag.div id: dom_id(leaf, :being_edited), class: "being-edited-indicator" %>

```


<!-- ===== app/views/leaves/_delete.html.erb ===== -->

```
<%= button_to leafable_path(leaf), method: :delete, data: { turbo_confirm: "Are you sure you want to delete this page?" }, class: "btn btn--negative txt-small min-width", form_class: "leaf__delete" do %>
  <%= image_tag "minus.svg", aria: { hidden: true }, size: 24 %>
  <span class="for-screen-reader">Delete <%= leaf.title %></span>
<% end %>

```


<!-- ===== app/views/leaves/_edit_footer.html.erb ===== -->

```
<% content_for :footer do %>
  <nav class="book__nav flex align-center gap">
    <span class="btn btn--placeholder flex-item-justify-start"></span>

    <%= link_to_next_leafable(leaf, hotkey: false, for_edit: true) %>

    <span class="flex-item-justify-end">
      <%= form_with url: leafable_path(leaf, format: :html), class: "flex align-center gap-half", method: :delete do |form| %>
        <%= form.button class: "btn btn--negative txt-small min-width", data: { turbo_confirm: "Are you sure you want to delete this page?" } do %>
          <%= image_tag "minus.svg", aria: { hidden: true }, size: 24 %>
          <span class="for-screen-reader">Delete <%= @leaf.title %></span>
        <% end %>
      <% end %>
    </span>
  </nav>
<% end %>

```


<!-- ===== app/views/leaves/_edit.html.erb ===== -->

```
<%= leaf_item_tag(leaf) do %>
  <span class="btn btn--link arrangement__handle txt-small">
    <%= image_tag "handle.svg", aria: { hidden: true }, size: 24 %>
    <span class="for-screen-reader">Move <%= leaf.title %></span>
  </span>

  <%= link_to leafable_path(leaf), class: "toc__thumbnail", data: { turbo_frame: "_top" } do %>
    <%= leaf.section.body if leaf.section? %>
    <%= sanitize_content(leaf.leafable.body.to_html) if leaf.page? %>
    <%= image_tag leaf.leafable.large_image if leaf.picture&.image&.attached? %>
  <% end %>

  <div class="toc__title flex align-center min-width">
    <%= form_with model: [ leaf.book, leaf ], url: leafable_path(leaf), class: "flex align-center max-width min-width", id: dom_id(leaf, "form") do |form| %>
      <%= form.text_field :title, class: "input full-width", autofocus: true, autocomplete: "off", data: { controller: "autoselect" } %>
    <% end %>

    <span class="flex align-center gap-half">
      <button type="submit" class="btn txt-small btn--positive" form="<%= dom_id(leaf, "form") %>">
        <%= image_tag "check.svg", aria: { hidden: true }, size: 24 %>
        <span class="for-screen-reader">Save</span>
      </button>

      <%= button_to leafable_path(leaf), method: :delete, class: "btn btn--negative txt-small" do %>
        <%= image_tag "trash.svg", aria: { hidden: true }, size: 24 %>
        <span class="for-screen-reader">Delete this page</span>
      <% end %>
    </span>
  </div>

  <small class="toc__wordcount">
    <% if leaf.page? %>
      <%= word_count(leaf.leafable.body.content) %>
    <% end %>
  </small>

  <%= yield if block_given? %>
<% end %>

```


<!-- ===== app/views/leaves/_header.html.erb ===== -->

```
<% content_for :header do %>
  <%= leaf_nav_tag(leaf) do %>
    <%= render "leaves/sidebar_toggle" %>

    <%= link_to_previous_leafable(leaf) %>

    <div class="breadcrumbs">
      <%= render "books/index_link" %>
      <span class="flex-item-no-shrink">▸</span>
      <%= link_to book.title, book_slug_path(book) %>
      <span class="flex-item-no-shrink">▸</span>
      <strong><%= leaf.leafable.title %></strong>
    </div>

    <button class="btn" data-action="fullscreen#toggle" data-fullscreen-target="button">
      <%= image_tag "expand.svg", aria: { hidden: true }, size: 24 %>
      <span class="for-screen-reader">Enter fullscreen</span>
    </button>

    <%= render "books/searches/search", book: @book %>
  <% end %>
<% end %>

<% content_for :toolbar do %>
  <div class="flex flex-column">
    <% if book.editable? %>
      <div class="page-toolbar fill-shade">
        <%= editing_mode_toggle_switch(@leaf, checked: false) %>
      </div>
    <% end %>

    <%= render "books/searches/banner" %>
  </div>
<% end %>

```


<!-- ===== app/views/leaves/_history.html.erb ===== -->

```
<% if leaf.edits.any? %>
  <%= link_to page_edit_path(leaf, "latest"), class: "btn flex-item-no-shrink txt-small" do %>
    <%= image_tag "history.svg", aria: { hidden: "true" }, size: "24" %>
    <span class="for-screen-reader">Editing history</span>
  <% end %>
<% end %>

```


<!-- ===== app/views/leaves/_leaf.html.erb ===== -->

```
<% cache [ leaf, leaf.book, leaf.book.editable? ] do %>
  <%= leaf_item_tag(leaf) do %>
    <span class="btn btn--link arrangement__handle txt-small">
      <%= image_tag "handle.svg", aria: { hidden: true }, size: 24 %>
      <span class="for-screen-reader">Move <%= leaf.title %></span>
    </span>

    <%= render "leaves/delete", leaf: leaf %>

    <div class="toc__thumbnail <%= "toc__thumbnail--dark" if leaf.section&.theme == "dark" %>">
      <% if leaf.book.editable? %>
        <%= link_to edit_leafable_path(leaf), class: "toc__link hide_from_reading_mode", data: { turbo_frame: "_top" } do %>
          <span class="for-screen-reader">Edit <%= leaf.title %></span>
        <% end %>

        <%= link_to leafable_slug_path(leaf), class: "toc__link hide_from_edit_mode", data: { turbo_frame: "_top" } do %>
          <span class="for-screen-reader">Open <%= leaf.title %></span>
        <% end %>
      <% else %>
        <%= link_to leafable_slug_path(leaf), class: "toc__link", data: { turbo_frame: "_top" } do %>
          <span class="for-screen-reader">Open <%= leaf.title %></span>
        <% end %>
      <% end %>

      <%= tag.span(simple_format(leaf.section.body), class: "txt-align-center") if leaf.section? %>

      <%= sanitize_content leaf.page.html_preview if leaf.page? %>

      <% if leaf.picture? %>
        <%= image_tag leaf.leafable.image.attached? ? leaf.leafable.large_image : "default-picture.webp" %>
      <% end %>
    </div>

    <% if leaf.book.editable? %>
      <%= link_to edit_leafable_path(leaf), class: "toc__title min-width hide_from_reading_mode", data: { turbo_frame: "_top" } do %>
        <span class="overflow-ellipsis"><%= leaf.title %></span>
      <% end %>

      <%= link_to leafable_slug_path(leaf), class: "toc__title min-width hide_from_edit_mode", data: { turbo_frame: "_top" } do %>
        <span class="overflow-ellipsis"><%= leaf.title %></span>
      <% end %>
    <% else %>
      <%= link_to leafable_slug_path(leaf), class: "toc__title min-width", data: { turbo_frame: "_top" } do %>
        <span class="overflow-ellipsis"><%= leaf.title %></span>
      <% end %>
    <% end %>

    <span class="toc__bookmark">
      <svg viewBox="0 0 64 64" width="64px" height="64px" xmlns="http://www.w3.org/2000/svg">
        <path d="m17.01 54.01v-42.98.00000045c-.00000025-1.65685 1.34315-3 3-3h24-.00000013c1.65685-.00000007 3 1.34315 3 3v42.98.0001206c0 1.10457-.895431 2-2 2-.34994 0-.693756-.0918173-.997105-.266281l-11.5039-6.61564c-.308638-.17748-.688362-.17748-.997 0l-11.5046 6.6153.00000011-.00000006c-.957413.550849-2.1801.221264-2.73095-.736149-.174564-.303405-.266442-.647312-.266451-.997351z" fill-rule="evenodd" fill="var(--color-marker)" />
      </svg>
    </span>

    <small class="toc__wordcount txt-small--responsive">
      <% if leaf.page? %>
        <%= word_count(leaf.leafable.body.content) %>
      <% end %>
    </small>
  <% end %>
<% end %>

```


<!-- ===== app/views/leaves/_navigation.html.erb ===== -->

```
<nav class="book__nav flex align-center gap justify-center">
  <%= link_to_next_leafable(leaf) %>
</nav>

```


<!-- ===== app/views/leaves/_sidebar_toggle.html.erb ===== -->

```
<label class="btn sidebar__toggle" data-controller="sidebar">
  <input type="checkbox" id="sidebar-toggle" data-sidebar-target="toggle" data-action="sidebar#toggle">
  <%= image_tag "sidebar.svg", aria: { hidden: true }, size: 24 %>
  <span class="for-screen-reader">Toggle sidebar</span>
</label>

```


<!-- ===== app/views/leaves/_sidebar.html.erb ===== -->

```
<menu class="sidebar__content toc flex flex-column">
  <header>
    <h1 class="txt-large--responsive margin-none">
      <%= book.title %>
    </h1>
  </header>

  <% book.leaves.active.with_leafables.positioned.each do |leaf| %>
    <li class="flex min-width <%= "leaf--section" if leaf.section? -%>">
      <% if leaf.book.editable? %>
        <%= link_to edit_leafable_path(leaf), class: "toc__title hide_from_reading_mode min-width", data: { turbo_frame: "_top" } do %>
          <span class="overflow-ellipsis"><%= leaf.title %></span>
        <% end %>

        <%= link_to leafable_slug_path(leaf), class: "toc__title hide_from_edit_mode min-width", data: { turbo_frame: "_top" } do %>
          <span class="overflow-ellipsis"><%= leaf.title %></span>
        <% end %>
      <% else %>
        <%= link_to leafable_slug_path(leaf), class: "toc__title min-width", data: { turbo_frame: "_top" } do %>
          <span class="overflow-ellipsis"><%= leaf.title %></span>
        <% end %>
      <% end %>
    </li>
  <% end %>
</menu>

```


<!-- ===== app/views/pages/_form.html.erb ===== -->

```
<%= leafable_edit_form(page, id: "leafable-editor") do |form| %>
  <%= form.markdown_area :body, toolbar: "house_toolbar", required: true, autofocus: true, class: "page__editor" %>
<% end %>

```


<!-- ===== app/views/pages/_house_toolbar.html.erb ===== -->

```
<%= house_toolbar id: "house_toolbar" do %>
  <%= house_toolbar_button "bold" do %>
    <%= image_tag "text-bold.svg", aria: { hidden: "true" }, size: "16", class: "colorize--black" %>
    <span class="for-screen-reader">Text style: bold</span>
  <% end %>

  <%= house_toolbar_button "italic" do %>
    <%= image_tag "text-italic.svg", aria: { hidden: "true" }, size: "16", class: "colorize--black" %>
    <span class="for-screen-reader">Text style: italic</span>
  <% end %>

  <%= house_toolbar_button "quote" do %>
    <%= image_tag "text-quote.svg", aria: { hidden: "true" }, size: "18", class: "colorize--black" %>
    <span class="for-screen-reader">Text style: quote</span>
  <% end %>

  <%= house_toolbar_button "code" do %>
    <%= image_tag "text-code.svg", aria: { hidden: "true" }, size: "18", class: "colorize--black" %>
    <span class="for-screen-reader">Text style: code</span>
  <% end %>

  <%= house_toolbar_button "link" do %>
    <%= image_tag "text-link.svg", aria: { hidden: "true" }, size: "18", class: "colorize--black" %>
    <span class="for-screen-reader">Text style: link</span>
  <% end %>

  <%= house_toolbar_button "bulletList" do %>
    <%= image_tag "text-bullets.svg", aria: { hidden: "true" }, size: "18", class: "colorize--black" %>
    <span class="for-screen-reader">Text style: bulleted list</span>
  <% end %>

  <%= house_toolbar_button "numberList" do %>
    <%= image_tag "text-numbers.svg", aria: { hidden: "true" }, size: "18", class: "colorize--black" %>
    <span class="for-screen-reader">Text style: numbered list</span>
  <% end %>

  <%= house_toolbar_file_upload_button do %>
    <%= image_tag "text-image.svg", aria: { hidden: "true" }, size: "18", class: "colorize--black" %>
    <span class="for-screen-reader">Add image</span>
  <% end %>
<% end %>

```


<!-- ===== app/views/pages/edit.html.erb ===== -->

```
<% content_for(:title) { "Edit #{ @page.title }" } %>

<% content_for :header do %>
  <%= render "leafables/edit_header", leaf: @leaf, book: @book %>
<% end %>

<% content_for :toolbar do %>
  <div class="page-toolbar fill-selected align-center gap-half margin-block-end-double">
    <%= editing_mode_toggle_switch(@leaf, checked: true) %>

    <span class="separator margin-inline-half" aria-hidden="true"></span>

    <span class="overflow-y overflow-hide-scrollbar">
      <%= render "house_toolbar" %>
    </span>

    <span class="separator margin-inline-half" aria-hidden="true"></span>

    <%= render "leaves/history", leaf: @leaf %>

    <button type="submit" form="leafable-editor" class="btn flex page-toolbar__save flex-item-justify-end flex-item-no-shrink txt-small">
      <%= image_tag "check.svg", aria: { hidden: true }, size: 24 %>
      <span class="for-screen-reader">Save</span>
    </button>
  </div>
<% end %>

<% content_for :sidebar do %>
  <%= render "leaves/sidebar", book: @book %>
<% end %>

<article class="layout--reading">
  <%= render "leaves/being_edited_indicator", leaf: @leaf %>

  <%= render "pages/form", book: @book, page: @page %>
</article>

<%= render "leaves/edit_footer", leaf: @leaf %>

```


<!-- ===== app/views/pages/edits/show.html.erb ===== -->

```
<% content_for(:title) { "Changes to #{ @leaf.title }" } %>
<% @layout_class = "books" %>

<% content_for :header do %>
  <nav>
    <%= link_to edit_leafable_path(@leaf), class: "btn" do %>
      <%= image_tag "arrow-left.svg", aria: { hidden: true }, size: 24 %>
      <span class="for-screen-reader">Go back</span>
    <% end %>

    <div class="breadcrumbs">
      <%= render "books/index_link" %>
      <span class="flex-item-no-shrink">▸</span>
      <%= link_to @leaf.book.title, @leaf.book %>
      <span class="flex-item-no-shrink">▸</span>
      <strong><%= @leaf.title %></strong>
    </div>
  </nav>
<% end %>

<div class="library">
  <section class="txt-align-start">
    <%= turbo_frame_tag :previous_version do %>
      <header class="flex align-center justify-center gap">
        <% if @edit.previous %>
          <%= link_to page_edit_path(@leaf, @edit.previous), data: { turbo_action: :advance }, class: "btn btn--reversed txt-small" do %>
            <%= image_tag "arrow-left.svg", aria: { hidden: true }, size: 24 %>
            <span class="for-screen-reader">Previous version</span>
          <% end %>
        <% else %>
          <span class="btn btn-reversed txt-small" disabled>
            <%= image_tag "arrow-left.svg", aria: { hidden: true }, size: 24 %>
            <span class="for-screen-reader">Previous version</span>
          </span>
        <% end %>

        <h2 class="btn btn--reversed txt-medium margin-none overflow-ellipsis">
          <%= time_ago_in_words(@edit.updated_at) %> ago
        </h2>

        <% if @edit.next %>
          <%= link_to page_edit_path(@leaf, @edit.next), data: { turbo_action: :advance }, class: "btn btn--reversed txt-small" do %>
            <%= image_tag "arrow-right.svg", aria: { hidden: true }, size: 24 %>
            <span class="for-screen-reader">Next version</span>
          <% end %>
        <% else %>
          <span class="btn btn-reversed txt-small" disabled>
            <%= image_tag "arrow-right.svg", aria: { hidden: true }, size: 24 %>
            <span class="for-screen-reader">Next version</span>
          </span>
        <% end %>
      </header>

      <%= sanitize_content(@edit.page.body.to_html) %>
    <% end %>
  </section>

  <section class="page-edit__current txt-align-start">
    <header class="flex align-center gap justify-center">
      <%= link_to edit_leafable_path(@leaf), class: "btn btn--positive txt-medium center margin-none" do %>
        Current
      <% end %>
    </header>

    <%= sanitize_content(@leaf.page.body.to_html) %>
  </section>
</div>

```


<!-- ===== app/views/pages/new.html.erb ===== -->

```
<% content_for(:title) { "New page" } %>

<% content_for :header do %>
  <nav>
    <%= link_to @book, class: "btn flex-item-justify-start" do %>
      <%= image_tag "remove.svg", aria: { hidden: true }, size: 24 %>
      <span class="for-screen-reader">Cancel</span>
    <% end %>

    <button type="submit" form="leafable-editor", class="btn flex-item-justify-end">
      <%= image_tag "check.svg", aria: { hidden: true }, size: 24 %>
      <span class="for-screen-reader">Save</span>
    </button>
  </nav>
<% end %>

<article class="layout--reading">
  <%= render "pages/form", book: @book, page: @page %>
</article>

```


<!-- ===== app/views/pages/update.turbo_stream.erb ===== -->

```
<%= turbo_stream.replace dom_id(@leaf) do %>
  <%= render "leaves/leaf", leaf: @leaf %>
<% end %>

```


<!-- ===== app/views/pictures/_form.html.erb ===== -->

```
<%= leafable_edit_form(picture, id: "leafable-editor") do |form| %>
  <label class="input input--file input--picture unpad" data-controller="upload-preview">
    <%= image_tag picture.image.attached? ? picture.large_image : "default-picture.webp", alt: "Picture",
        data: { upload_preview_target: "image" } %>
    <%= form.file_field :image, class: "input", accept: "image/png, image/jpeg, image/jpg, image/webp", autofocus: true,
        data: { upload_preview_target: "input", action: "upload-preview#previewImage" } %>
  </label>
  <div class="flex align-center gap margin-block">
    <%= translation_button(:picture_caption) %>
    <%= form.text_field :caption, class: "input", placeholder: "Picture caption" %>
  </div>
  <%= form.submit "Save", hidden: true, data: { upload_preview_target: "button" } %>
<% end %>

```


<!-- ===== app/views/pictures/edit.html.erb ===== -->

```
<% content_for(:title) { "Edit #{ @picture.title }" } %>

<% content_for :header do %>
  <%= render "leafables/edit_header", leaf: @leaf, book: @book %>
<% end %>

<% content_for :toolbar do %>
  <div class="page-toolbar fill-selected align-center gap-half margin-block-end-double">
    <%= editing_mode_toggle_switch(@leaf, checked: true) %>

    <span class="separator margin-inline-half" aria-hidden="true"></span>

    <button type="submit" form="leafable-editor" class="btn flex page-toolbar__save flex-item-justify-end flex-item-no-shrink txt-small">
      <%= image_tag "check.svg", aria: { hidden: true }, size: 24 %>
      <span class="for-screen-reader">Save</span>
    </button>
  </div>
<% end %>

<% content_for :sidebar do %>
  <%= render "leaves/sidebar", book: @book %>
<% end %>

<div class="page--picture picture-form margin-none">
  <%= render "pictures/form", book: @book, picture: @picture %>
</div>

<%= render "leaves/edit_footer", leaf: @leaf %>

```


<!-- ===== app/views/pictures/new.html.erb ===== -->

```
<% content_for(:title) { "New image page" } %>

<% content_for :header do %>
  <nav>
    <%= link_to @book, class: "btn flex-item-justify-start" do %>
      <%= image_tag "remove.svg", aria: { hidden: true }, size: 24 %>
      <span class="for-screen-reader">Cancel</span>
    <% end %>

    <button type="submit" form="leafable-editor", class="btn flex-item-justify-end">
      <%= image_tag "check.svg", aria: { hidden: true }, size: 24 %>
      <span class="for-screen-reader">Save</span>
    </button>
  </nav>
<% end %>

<div class="page--picture">
  <%= render "pictures/form", book: @book, picture: @picture %>
</div>

```


<!-- ===== app/views/pictures/update.turbo_stream.erb ===== -->

```
<%= turbo_stream.replace dom_id(@leaf) do %>
  <%= render "leaves/leaf", leaf: @leaf %>
<% end %>

```


<!-- ===== app/views/pwa/manifest.json.erb ===== -->

```
{
  "name": "Writebook",
  "icons": [
    {
      "src": "/app-icon-192.png",
      "type": "image/png",
      "sizes": "192x192"
    },
    {
      "src": "/app-icon.png",
      "type": "image/png",
      "sizes": "512x512"
    },
    {
      "src": "/app-icon.png",
      "type": "image/png",
      "sizes": "512x512",
      "purpose": "maskable"
    }
  ],
  "start_url": "/",
  "display": "standalone",
  "scope": "/",
  "description": "Writebook is remarkably simple software that allows you to publish text and pictures in a simple, browsable online book format.",
  "categories": ["books", "business", "productivity"],
  "shortcuts": [
    {
      "name": "Create a new book",
      "description": "Open Writebook and start writing",
      "url": "/books/new",
      "icons": [{ "src": "<%= image_url("add.svg") %>", "sizes": "any" }]
    },
    {
      "name": "Open library",
      "description": "Open Writebook and see all your books",
      "url": "/books",
      "icons": [{ "src": "<%= image_url("books.svg") %>", "sizes": "any" }]
    }
  ],
  "theme_color": "#ffffff",
  "background_color": "#ffffff"
}

```


<!-- ===== app/views/sections/_form.html.erb ===== -->

```
<%= leafable_edit_form(section, id: "leafable-editor") do |form| %>
  <h1><%= form.text_area :body, class: "input input--textara full-width txt-align-center", required: true, autocomplete: "off", autofocus: true %></h1>
  <%= form.submit "Save", hidden: true %>
<% end %>

```


<!-- ===== app/views/sections/edit.html.erb ===== -->

```
<% content_for(:title) { "Edit #{ @section.title }" } %>

<% content_for :header do %>
  <%= render "leafables/edit_header", leaf: @leaf, book: @book %>
<% end %>

<% content_for :toolbar do %>
  <div class="page-toolbar fill-selected align-center gap-half margin-block-end-double">
    <%= editing_mode_toggle_switch(@leaf, checked: true) %>

    <span class="separator margin-inline-half" aria-hidden="true"></span>

    <label class="btn txt-small">
      <%= hidden_field_tag "section[theme]", nil, id: nil, form: "leafable-editor" %>
      <%= check_box_tag "section[theme]", "dark", @section.theme.present?, class: "switch__input", form: "leafable-editor" %>
      <%= image_tag "theme-switch.svg", aria: { hidden: true }, size: 24 %>
      <span class="for-screen-reader">Change theme</span>
    </label>

    <span class="separator margin-inline-half" aria-hidden="true"></span>

    <button type="submit" form="leafable-editor" class="btn flex page-toolbar__save flex-item-justify-end flex-item-no-shrink txt-small">
      <%= image_tag "check.svg", aria: { hidden: true }, size: 24 %>
      <span class="for-screen-reader">Save</span>
    </button>
  </div>
<% end %>

<% content_for :sidebar do %>
  <%= render "leaves/sidebar", book: @book %>
<% end %>

<div class="page--section <%= "theme--dark" if @section.theme == "dark" %>">
  <%= render "sections/form", book: @book, section: @section %>
</div>

<%= render "leaves/edit_footer", leaf: @leaf %>

```


<!-- ===== app/views/sections/new.html.erb ===== -->

```
<% content_for(:title) { "New section page" } %>

<% content_for :header do %>
  <nav>
    <%= link_to @book, class: "btn flex-item-justify-start" do %>
      <%= image_tag "remove.svg", aria: { hidden: true }, size: 24 %>
      <span class="for-screen-reader">Cancel</span>
    <% end %>

    <button type="submit" form="leafable-editor", class="btn flex-item-justify-end">
      <%= image_tag "check.svg", aria: { hidden: true }, size: 24 %>
      <span class="for-screen-reader">Save</span>
    </button>
  </nav>
<% end %>

<div class="page--section">
  <%= render "sections/form", book: @book, section: @section %>
</div>

```


<!-- ===== app/views/sections/update.turbo_stream.erb ===== -->

```
<%= turbo_stream.replace dom_id(@leaf) do %>
  <%= render "leaves/leaf", leaf: @leaf %>
<% end %>

```


<!-- ===== app/views/sessions/new.html.erb ===== -->

```
<% content_for(:title) { "Sign in" } %>
<% turbo_page_requires_reload %>

<div class="panel shadow center margin-block-double <%= "shake" if flash[:alert] %>">
  <%= image_tag "writebook-icon.svg", class: "product__logo center colorize--black", size: 130 %>
  <h1 class="margin-none-block-start margin-block-end-double">Writebook</h1>

  <%= form_with url: session_url, class: "flex flex-column gap" do |form| %>
    <div class="flex align-center gap">
      <%= translation_button(:email_address) %>
      <label class="flex align-center gap input input--actor txt-large">
        <%= form.email_field :email_address, required: true, class: "input full-width", autofocus: true, autocomplete: "username", placeholder: "Enter your email address", value: params[:email_address] %>
        <%= image_tag "email.svg", aria: { hidden: "true" }, size: 30, class: "colorize--black" %>
      </label>
    </div>

    <div class="flex align-center gap">
      <%= translation_button(:password) %>
      <label class="flex align-center gap input input--actor txt-large">
        <%= form.password_field :password, required: true, class: "input full-width", autocomplete: "current-password", placeholder: "Enter your password", maxlength: 72 %>
        <%= image_tag "password.svg", aria: { hidden: "true" }, size: 30, class: "colorize--black" %>
      </label>
    </div>
    <button type="submit" id="log_in" class="btn btn--reversed center">
      <%= image_tag "arrow-right.svg", aria: { hidden: true }, size: 24 %>
      <span class="for-screen-reader">Sign in</span>
    </button>
  <% end %>
</div>

<% content_for(:footer) do %>
  <div class="txt-align-center center margin-block-double txt-subtle">Writebook&trade; version <%= version_badge %></div>
<% end %>

```


<!-- ===== app/views/sessions/transfers/show.html.erb ===== -->

```
<%= auto_submit_form_with method: :put %>

```


<!-- ===== app/views/users/_invite.html.erb ===== -->

```
<div class="flex flex-column align-center gap txt-medium--responsive">
  <% url = join_url(Current.account.join_code) %>

  <label class="flex flex-column gap full-width txt-align-center">
    <strong id="invite_label" class="invite-label">Share to invite more people</strong>
    <span class="flex align-center gap margin-inline">
      <input type="text" class="input fill-white" id="invite_url" value="<%= url %>" aria-labelledby="invite_label" readonly>
    </span>
  </label>

  <div class="flex align-center gap">
    <div data-controller="dialog" class="flex-inline">
      <%= tag.button class: "btn", data: { action: "dialog#open" } do %>
        <%= image_tag "qr-code.svg", aria: { hidden: "true" }, size: 24, class: "colorize--black" %>
        <span class="for-screen-reader">Show join link QR code</span>
      <% end %>

      <dialog class="dialog panel shadow" data-dialog-target="dialog">
        <%= qr_code_image(url) %>

        <form method="dialog" class="flex justify-center">
          <button class="btn panel__close" title="Close (esc)">
            <%= image_tag "remove.svg", aria: { hidden: true }, size: 24 %>
            <span class="for-screen-reader">Close (esc)</span>
          </button>
        </form>
      </dialog>
    </div>

    <%= button_to_copy_to_clipboard(url) do %>
      <%= image_tag "copy-paste.svg", aria: { hidden: "true" }, size: 24, class: "colorize--black" %>
      <span class="for-screen-reader">Copy join link</span>
    <% end %>

    <%= web_share_button(url, "Link to join Writebook", "Hit this link to join me in Writebook and start writing.") do %>
      <%= image_tag "share.svg", aria: { hidden: "true" }, size: 24, class: "colorize--black" %>
      <span class="for-screen-reader">Share join link</span>
    <% end %>

    <% if Current.user.can_administer? %>
      <%= button_to account_join_code_path, class: "btn btn--regenerate" do %>
        <%= image_tag "refresh.svg", aria: { hidden: "true" }, size: 24, class: "colorize--black" %>
        <span class="for-screen-reader">Regenerate join link</span>
      <% end %>
    <% end %>
  </div>
</div>

```


<!-- ===== app/views/users/_transfer.html.erb ===== -->

```
<div class="flex flex-column align-center gap txt-medium--responsive">
  <% url = session_transfer_url(user.transfer_id) %>

  <label class="flex flex-column gap full-width">
    <div class="flex align-center gap">
      <% if Current.user != user %>
        <%= translation_button(:transfer_session) %>
        <strong id="session_transfer_label" class="txt-align-start">Share to get them back into their account</strong>
      <% else %>
        <%= translation_button(:transfer_session_self) %>
        <strong id="session_transfer_label" class="txt-align-start">Link to automatically log in on another device</strong>
      <% end %>
    </div>
    <span class="flex align-center gap margin-inline">
      <input type="text" class="input fill-white" id="session_transfer_url" value="<%= url %>" aria-labelledby="session_transfer_label" readonly>
    </span>
  </label>

  <div class="flex align-center gap">
    <div data-controller="dialog" class="flex-inline">
      <%= tag.button class: "btn", data: { action: "dialog#open" } do %>
        <%= image_tag "qr-code.svg", aria: { hidden: "true" }, size: 24, class: "colorize--black" %>
        <span class="for-screen-reader">Show auto-login QR code</span>
      <% end %>

      <dialog class="dialog panel shadow" data-dialog-target="dialog">
        <%= qr_code_image(url) %>

        <form method="dialog" class="flex justify-center">
          <button class="btn panel__close" title="Close (esc)">
            <%= image_tag "remove.svg", aria: { hidden: true }, size: 24 %>
            <span class="for-screen-reader">Close (esc)</span>
          </button>
        </form>
      </dialog>
    </div>

    <%= button_to_copy_to_clipboard(url) do %>
      <%= image_tag "copy-paste.svg", aria: { hidden: "true" }, size: 24, class: "colorize--black" %>
      <span class="for-screen-reader">Copy auto-login link</span>
    <% end %>

    <%= web_share_button(url, "Your sign-in link", "This is your own private sign-in URL, DO NOT SHARE IT. Use it to sign-in on another device or if you get locked out.") do %>
      <%= image_tag "share.svg", aria: { hidden: "true" }, size: 24, class: "colorize--black" %>
      <span class="for-screen-reader">Share auto-login link</span>
    <% end %>
  </div>
</div>

```


<!-- ===== app/views/users/_user.html.erb ===== -->

```
<div class="flex align-center gap-half pad-inline txt-medium--responsive">
  <strong class="overflow-ellipsis txt-medium--responsive"><%= link_to user.name, user.current? ? edit_user_profile_path(user) : user_profile_path(user) %></strong>
  <hr class="flex-item-grow margin-none" aria-hidden="true">

  <%= form_with model: user, url: user_path(user), data: { controller: "form" }, method: :patch do | form | %>
    <label class="btn btn--small flex-item-no-shrink" for="<%= dom_id(user, :role) %>">
      <span class="for-screen-reader"><%= user.name %>'s role: <%= user.administrator? ? "Administrator" : "Member" %></span>
      <%= image_tag "crown.svg", size: 24, aria: { hidden: "true" } %>
      <%= form.check_box :role, { data: { action: "form#submit" }, hidden: true, id: dom_id(user, :role), disabled: ("disabled" if user.current? || !Current.user.can_administer?) }, "administrator", "member" %>
    </label>
  <% end %>

  <%= button_to user_path(user), method: :delete, class: "btn btn--small btn--negative flex-item-no-shrink", disabled: ("disabled" if user.current? || !Current.user.can_administer?), data: {
        turbo_confirm: "Are you sure you want to permanently remove this person from the account? This can’t be undone."} do %>
    <%= image_tag "minus.svg", aria: { hidden: true }, size: 24 %>
    <span class="for-screen-reader">Remove <%= user.name %> from the account</span>
  <% end %>
</div>

```


<!-- ===== app/views/users/index.html.erb ===== -->

```
<% content_for(:title) { "People on the account" } %>

<% content_for :header do %>
  <nav>
    <%= link_to root_path, class: "btn" do %>
      <%= image_tag "arrow-left.svg", aria: { hidden: true }, size: 24 %>
      <span class="for-screen-reader">Go back</span>
    <% end %>

    <div class="breadcrumbs">
      <%= render "books/index_link" %>
      <span class="flex-item-no-shrink">▸</span>
      <%= image_tag "settings.svg", aria: { label: "Settings" }, size: 19, class: "colorize--black", alt: "Settings" %>
    </div>

    <% if Current.user.can_administer? %>
      <%= link_to edit_account_custom_styles_url, class: "btn" do %>
        <%= image_tag "art.svg", aria: { hidden: true }, size: 24 %>
        <span class="for-screen-reader">Custom styles</span>
      <% end %>
    <% end %>
  </nav>
<% end %>

<div class="panel borderless center pad fill-shade flex flex-column margin-block">
  <%= render "invite" %>
</div>

<div class="panel borderless center pad fill-none flex flex-column gap">
  <%= render @users %>
</div>

<% content_for(:footer) do %>
  <div class="txt-align-center center margin-block-double txt-subtle">Writebook&trade; version <%= version_badge %></div>
<% end %>

```


<!-- ===== app/views/users/new.html.erb ===== -->

```
<% content_for(:title) { "Create your account" } %>
<% turbo_page_requires_reload %>

<% content_for :header do %>
  <nav>
    <%= link_to new_session_path, class: "btn flex-item-justify-end" do %>
      <%= image_tag "login-keys.svg", aria: { hidden: true }, size: 24 %>
      <span class="for-screen-reader">Sign in instead</span>
    <% end %>
  </nav>
<% end %>

<div class="panel shadow center <%= "shake" if flash[:alert] %>">
  <%= image_tag "writebook-icon.svg", class: "product__logo center colorize--black", size: 130 %>
  <h1 class="margin-none-block-start margin-block-end-double">Writebook</h1>

  <%= form_with model: @user, url: join_path(params[:join_code]), class: "flex flex-column gap" do |form| %>
    <div class="flex align-center gap">
      <%= translation_button(:user_name) %>
      <label class="flex align-center gap input input--actor">
        <%= form.text_field :name, class: "input full-width", autocomplete: "name", placeholder: "Name", autofocus: true, required: true, data: { "1p-ignore": true } %>
        <%= image_tag "person.svg", aria: { hidden: "true" }, size: 30, class: "colorize--black" %>
      </label>
    </div>
    <div class="flex align-center gap">
      <%= translation_button(:email_address) %>
      <label class="flex align-center gap input input--actor">
        <%= form.email_field :email_address, class: "input full-width", autocomplete: "username", placeholder: "Email address", required: true %>
        <%= image_tag "email.svg", aria: { hidden: "true" }, size: 30, class: "colorize--black" %>
      </label>
    </div>
    <div class="flex align-center gap">
      <%= translation_button(:password) %>
      <label class="flex align-center gap input input--actor">
        <%= form.password_field :password, class: "input full-width", autocomplete: "new-password", placeholder: "Password", required: true, maxlength: 72 %>
        <%= image_tag "password.svg", aria: { hidden: "true" }, size: 30, class: "colorize--black" %>
      </label>
    </div>
    <button type="submit" id="log_in" class="btn btn--reversed center">
      <%= image_tag "arrow-right.svg", aria: { hidden: true }, size: 24 %>
      <span class="for-screen-reader">Sign in</span>
    </button>
  <% end %>
</div>

```


<!-- ===== app/views/users/profiles/edit.html.erb ===== -->

```
<% content_for(:title) { "Your settings" } %>

<% content_for :header do %>
  <nav>
    <%= link_to users_path, class: "btn" do %>
      <%= image_tag "arrow-left.svg", aria: { hidden: true }, size: 24 %>
      <span class="for-screen-reader">Go back</span>
    <% end %>

    <div class="breadcrumbs">
      <%= render "books/index_link" %>
      <span class="flex-item-no-shrink">▸</span>
      <%= link_to users_path, class: "btn borderless txt-small flex-item-no-shrink" do %>
        <%= image_tag "people.svg", aria: { label: "People" }, size: 19, class: "colorize--black", alt: "People" %>
        <span class="for-screen-reader">Manage people</span>
      <% end %>
      <span class="flex-item-no-shrink">▸</span>
      <%= @user.name %>
    </div>
  </nav>
<% end %>

<div class="panel margin-block-double shadow center">
  <%= form_with model: @user, url: user_profile_path(@user), class: "flex flex-column gap" do |form| %>
    <%= form.hidden_field :role %>
    <div class="flex align-center gap margin-block-start">
      <%= translation_button(:user_name) %>
      <label class="flex align-center gap input input--actor">
        <%= form.text_field :name, class: "input full-width", autocomplete: "name", placeholder: "Name", autofocus: true, required: true, data: { "1p-ignore": true } %>
        <%= image_tag "person.svg", aria: { hidden: "true" }, size: 30, class: "colorize--black" %>
      </label>
    </div>
    <div class="flex align-center gap">
      <%= translation_button(:email_address) %>
      <label class="flex align-center gap input input--actor">
        <%= form.email_field :email_address, class: "input full-width", autocomplete: "username", placeholder: "Email address", required: true %>
        <%= image_tag "email.svg", aria: { hidden: "true" }, size: 30, class: "colorize--black" %>
      </label>
    </div>
    <div class="flex align-center gap">
      <%= translation_button(:update_password) %>
      <label class="flex align-center gap input input--actor">
        <%= form.password_field :password, class: "input full-width", autocomplete: "new-password", placeholder: "Change password", maxlength: 72 %>
        <%= image_tag "password.svg", aria: { hidden: "true" }, size: 30, class: "colorize--black" %>
      </label>
    </div>
    <button type="submit" class="btn btn--reversed center">
      <%= image_tag "check.svg", aria: { hidden: true }, size: 24 %>
      <span class="for-screen-reader">Save changes</span>
    </button>
  <% end %>
</div>

<div class="panel margin-block-double shadow center">
  <%= render "users/transfer", user: @user %>
</div>

<div class="panel margin-block-double shadow center">
  <%= button_to session_path, method: :delete, class: "btn center" do %>
    <%= image_tag "logout.svg", aria: { hidden: true }, size: 24 %>
    <span class="for-screen-reader">Sign out</span>
  <% end %>
</div>

```


<!-- ===== app/views/users/profiles/show.html.erb ===== -->

```
<% content_for(:title) { @user.name } %>

<% content_for :header do %>
  <nav>
    <%= link_to users_path, class: "btn" do %>
      <%= image_tag "arrow-left.svg", aria: { hidden: true }, size: 24 %>
      <span class="for-screen-reader">Go back</span>
    <% end %>

    <div class="breadcrumbs">
      <%= render "books/index_link" %>
      <span class="flex-item-no-shrink">▸</span>
      <%= link_to users_path, class: "btn borderless txt-small flex-item-no-shrink" do %>
        <%= image_tag "people.svg", aria: { label: "People" }, size: 19, class: "colorize--black", alt: "People" %>
        <span class="for-screen-reader">Manage people</span>
      <% end %>
      <span class="flex-item-no-shrink">▸</span>
      <%= @user.name %>
    </div>
  </nav>
<% end %>

<div class="panel margin-block-double shadow center">
  <h2 class="margin-none-block-end"><%= @user.name %></h2>
  <p class="margin-none-block-start"><%= mail_to @user.email_address %></p>

  <% if Current.user.can_administer? %>
    <hr class="full-width margin-block-double" aria-hidden="true">
    <%= render "users/transfer", user: @user %>
  <% end %>
</div>

```
