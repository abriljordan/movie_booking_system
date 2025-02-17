# README

rails new movie_booking_system --api
cd movie_booking_system

gem 'jwt' # For authentication
gem 'pundit' # For authorization
gem 'bcrypt' # For password hashing
gem 'pg' # PostgreSQL database
gem "fast_jsonapi"

rails g model User name:string email:string password_digest:string role:integer
rails g model Movie title:string description:text duration:integer rating:string
rails g model Theater name:string location:string total_seats:integer
rails g model Showtime start_time:datetime end_time:datetime movie:references theater:references
rails g model Booking user:references showtime:references seats:integer total_price:decimal

rails g controller api/v1/users
rails g controller api/v1/movies
rails g controller api/v1/theaters
rails g controller api/v1/showtimes
rails g controller api/v1/bookings

rails g serializer Movie title description duration rating
rails g serializer Theater name location total_seats
rails g serializer Showtime start_time end_time
rails g serializer Booking seats total_price

1️⃣ Expand Test Coverage

Even though all tests passed, you might want to check:
 • Edge cases (e.g., booking a full theater, invalid seat numbers, trying to update a discarded booking)
 • Authorization tests (e.g., making sure non-admin users can’t delete users or modify other users’ bookings)
 • Error handling (e.g., invalid inputs, expired JWT tokens, unauthorized access)

2️⃣ Refactor for Optimization
 • Your UsersController has some duplication in authorization logic—could be abstracted further.
 • Check if your test suite runs too many database queries (use Bullet gem to catch N+1 queries).

3️⃣ Add Logging & Monitoring
 • Since you’re using Rails.logger.debug for debugging tokens, consider adding structured logs for better traceability.

4️⃣ Automate Testing in CI/CD
 • If you’re deploying this system, set up GitHub Actions or another CI/CD pipeline to run tests on every push.
