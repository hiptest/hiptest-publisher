# Support development with Docker to minimize host software requirements.

# Let's just assume Bash, shall we?
SHELL=/bin/bash

.PHONY : docker-image test

default : test

# If the Gemfile is changed, the Gemfile.lock should be updated.
Gemfile.lock : Gemfile
	docker run --rm -v "$$(pwd)":/usr/src/app -w /usr/src/app ruby:2.3 bundle install

DOCKER_IMAGE = unitive/hiptest-publisher

docker-image :
	docker build -t $(DOCKER_IMAGE) .

LOG = log

$(LOG) :
	mkdir -p $@

DOCKER_RUN_TEST=docker run --interactive --tty --user $$UID --rm \
	--workdir "/usr/src/app" --entrypoint bundle $(DOCKER_IMAGE) exec rspec

test : docker-image | $(LOG)
	$(DOCKER_RUN_TEST) > >(tee $(LOG)/test.log) 2>&1

# Create targets for running individual spec files.
SPEC_FILES=$(wildcard spec/*_spec.rb) $(wildcard spec/*/*_spec.rb)
SPECS=$(patsubst spec/%_spec.rb,%,$(SPEC_FILES))
SPEC_TESTS=$(patsubst %,test/%,$(SPECS))
.PHONY : $(SPEC_TESTS)
$(SPEC_TESTS) : test/% : spec/%_spec.rb docker-image | $(LOG)
	$(DOCKER_RUN_TEST) --format documentation $< > >(tee $(LOG)/$(*).log) 2>&1

.PHONY : test-verbose
test-verbose : $(SPEC_TESTS)
