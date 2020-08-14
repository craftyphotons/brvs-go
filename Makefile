export GOOS=$(shell go env GOOS)
export GO_BUILD=env GO111MODULE=on go build -ldflags="-s -w"
export GO_INSTALL=env GO111MODULE=on go install
export GO_TEST=env GOTRACEBACK=all GO111MODULE=on go test -race -coverprofile=coverage.out
export GO_VET=env GO111MODULE=on go vet
export GO_RUN=env GO111MODULE=on go run
export PATH := $(PWD)/bin/$(GOOS):$(PATH)

VERSION := $(shell cat ./VERSION)

SOURCES := $(shell find . -name '*.go' -not -name '*_test.go') go.mod go.sum
SOURCES_NO_VENDOR := $(shell find . -path ./vendor -prune -o -name "*.go" -not -name '*_test.go' -print)

all: install

install: clean vet test build

bench:
	$(GO_TEST) -bench=. -run=^$$ ./...

build: $(SOURCES)
	$(GO_BUILD) -o bin/brvs cmd/brvs/main.go

clean:
	$(RM) -r bin
	$(RM) -r dist

coverage:
	GO111MODULE=off go get github.com/mattn/goveralls
	$(shell go env GOPATH)/bin/goveralls -coverprofile=coverage.out -service=github

fmt: $(SOURCES_NO_VENDOR)
	gofmt -w -s $^

lint:
	golangci-lint run ./...

test:
	$(GO_TEST) ./...

tidy:
	go mod tidy

vet:
	$(GO_VET) -v ./...

man:
	rm -fr share/man
	mkdir -p share/man/man1
	cp man/man1/*.1 share/man/man1
	# man/*.5 share/man/man5
	# man/*.7 share/man/man7
	find share/man -type f -name "*.1" -exec sed -i.bak "s/{{DATE}}/$(shell date +%Y-%m-%d)/g" {} \;
	find share/man -type f -name "*.1" -exec sed -i.bak "s/{{VERSION}}/$(shell cat VERSION)/g" {} \;
	rm -fr share/man/**/*.bak

.PHONY: all docs man install bench clean coverage fmt lint test tidy vet
