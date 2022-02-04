# go-test-cov-testing
![tests](https://github.com/wafer-bw/go-test-cov-testing/workflows/tests/badge.svg)
![lint](https://github.com/wafer-bw/go-test-cov-testing/workflows/lint/badge.svg)
[![Go Report Card](https://goreportcard.com/badge/github.com/wafer-bw/go-test-cov-testing)](https://goreportcard.com/report/github.com/wafer-bw/go-test-cov-testing)
![CodeQL](https://github.com/wafer-bw/go-test-cov-testing/workflows/CodeQL/badge.svg)
[![Coverage Status](https://coveralls.io/repos/github/wafer-bw/go-test-cov-testing/badge.svg)](https://coveralls.io/github/wafer-bw/go-test-cov-testing)
[![Go Reference](https://pkg.go.dev/badge/github.com/wafer-bw/go-test-cov-testing.svg)](https://pkg.go.dev/github.com/wafer-bw/go-test-cov-testing)

## Golang issue
There is currently an issue tracked in the golang project [here](https://github.com/golang/go/issues/24570) that, if fixed, would resolve this issue.
The main flaw is that packages/files with no test file are not counted as 0% coverage. There is also a stack overflow question [here](https://stackoverflow.com/questions/59903169/go-wrong-coverage-when-there-is-no-tests-for-a-package). The currently available solutions are empty test files or `coverpkg=./...`.

## About this repo
The goal is to find a coverage method that meets the following
- calculates coverage for files with no `*_test.go` file as 0%
- does not perform any cross-package/cross-module coverage counting
- does not artificially raise statement/package/total coverage
- does not artificially lower statement/package/total coverage

The actual coverage of the packages in this repo should be reported as
```sh
# github.com/wafer-bw/go-test-cov-testing/one/one.go:3:          One             100.0%
# github.com/wafer-bw/go-test-cov-testing/three/three.go:3:      Three           0.0%
# github.com/wafer-bw/go-test-cov-testing/two/two.go:3:          Two             0.0%
# total:                                                  (statements)    33.3%
```
## Options
The various methods of calculating coverage

### (Option 1) `go test -coverprofile=coverage.out ./...` with no empty `_test.go` files
```sh
go test -coverprofile=coverage.out ./...
# ok      github.com/wafer-bw/go-test-cov-testing/one    0.123s  coverage: 100.0% of statements
# ?       github.com/wafer-bw/go-test-cov-testing/three  [no test files]
# ?       github.com/wafer-bw/go-test-cov-testing/two    [no test files]
go tool cover -func=coverage.out
# github.com/wafer-bw/go-test-cov-testing/one/one.go:3:  One             100.0%
# total:                                          (statements)    100.0%
```

- :x: does not calculate coverage for files with no `*_test.go` file
    - `two.go`, `three.go`
- :white_check_mark: does not perform any cross-package coverage
    - `one_test.go` tests `three.go` but does not cover it
- :x: artificially raises total coverage
    - total should be ~33.3%

### (Option 2) `go test -coverpkg=./... -coverprofile=coverage.out ./...`
```sh
go test -coverpkg=./... -coverprofile=coverage.out ./...
# ok      github.com/wafer-bw/go-test-cov-testing/one    0.281s  coverage: 66.7% of statements in ./...
# ?       github.com/wafer-bw/go-test-cov-testing/three  [no test files]
# ?       github.com/wafer-bw/go-test-cov-testing/two    [no test files]
go tool cover -func=coverage.out
# github.com/wafer-bw/go-test-cov-testing/one/one.go:3:          One             100.0%
# github.com/wafer-bw/go-test-cov-testing/three/three.go:3:      Three           100.0%
# github.com/wafer-bw/go-test-cov-testing/two/two.go:3:          Two             0.0%
# total:                                                  (statements)    66.7%
```

- :white_check_mark: accurately covers files with no `*_test.go`
    - `package two`
- :x: introduces cross-package coverage
    - `one_test.go` covers `three.go`
- :x: artificially lowers statement coverage
    - `package one` @ 66.7% should be 100%
- :x: artificially raises total coverage
    - total should be ~33.3%

### (Option 3) `go test -coverprofile=coverage.out ./...` with empty `_test.go` files
If we add empty test files to packages two and three the results will be accurate. A commit for this repo demonstrating this can be reviewed [here](https://github.com/wafer-bw/go-test-cov-testing/tree/a60ccfe77b03554ca4f13047434ae8973d8995e8). Every package we want to include in the coverage total must have at least one `_test.go` file to be considered in the total.
```sh
go test -coverprofile=coverage.out ./...
# ok      github.com/wafer-bw/go-test-cov-testing/one     0.150s  coverage: 100.0% of statements
# ok      github.com/wafer-bw/go-test-cov-testing/three   0.197s  coverage: 0.0% of statements [no tests to run]
# ok      github.com/wafer-bw/go-test-cov-testing/two     0.105s  coverage: 0.0% of statements [no tests to run]
go tool cover -func=coverage.out
# github.com/wafer-bw/go-test-cov-testing/one/one.go:4:           One             100.0%
# github.com/wafer-bw/go-test-cov-testing/three/three.go:4:       Three           0.0%
# github.com/wafer-bw/go-test-cov-testing/two/two.go:4:           Two             0.0%
# total:                                                          (statements)    33.3%
```

- :white_check_mark: accurately covers files with no `*_test.go`
- :white_check_mark: does not introduce cross-package coverage
- :white_check_mark: does not artificially raise statement/package/total coverage
- :white_check_mark: does not artificially lower statement/package/total coverage
