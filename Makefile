GO:=go

get:
	$(GO) get -d -t -v ./...
.PHONY: get

clean:
	$(GO) mod verify
	$(GO) mod tidy
	$(GO) vet ./...
	$(GO) fmt ./...
	$(GO) run github.com/golangci/golangci-lint/cmd/golangci-lint run
.PHONY: clean

test:
	$(GO) test -coverprofile=coverage.out ./...
	$(GO) tool cover -func=coverage.out
.PHONY: test

test-coverpkg-all:
	$(GO) test -coverpkg=./... -coverprofile=coverage.out ./...
	$(GO) tool cover -func=coverage.out
.PHONY: test-coverpkg-all

test-coverpkg-explicit-all:
	$(GO) test -coverpkg="`go list ./... | tr '\n' ','`" -coverprofile=coverage.out ./...
	$(GO) tool cover -func=coverage.out
.PHONY: test-coverpkg-explicit-all

test-ci:
	$(GO) test -failfast -timeout=1m -short -coverprofile=coverage.out ./...
.PHONY: test-ci
