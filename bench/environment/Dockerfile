FROM ruby:4-slim

# The harness seals, snapshots, and grades through git.
RUN apt-get update \
 && apt-get install -y --no-install-recommends git ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# lib/lens.rb requires every lens/* file, so the full gemspec runtime
# dependency set has to load even though this task only touches validator.rb.
RUN gem install ruby_llm --version "~> 1.14" --no-document \
 && gem install dotenv --version "~> 3.0" --no-document \
 && gem install thor --version "~> 1.3" --no-document \
 && gem install minitest --no-document

WORKDIR /app
