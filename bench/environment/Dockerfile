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

# lemans builds an image using this Dockerfile's own directory as the sole
# build context (Config::ImageSpec#context_dir == dockerfile_path.dirname) --
# there's no COPY path back out to the rest of the repo. Rails' own reference
# benches (rails/ai-evals) don't fight this either: they fetch the target
# app from its real remote inside the build step. Same idiom here.
ARG AGENT_LENS_REF=main
RUN git init -q . \
 && git fetch -q --depth 1 https://github.com/Autogenetica/agent-lens.git "$AGENT_LENS_REF" \
 && git checkout -q FETCH_HEAD \
 && rm -rf .git
