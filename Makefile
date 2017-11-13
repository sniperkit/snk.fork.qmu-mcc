NAME := mcc
VERSION := v0.9.5
CONFIG_SCHEMA_VERSION := v1.1.0
SRCS      := $(shell find . -name '*.go' -type f)
LDFLAGS   := -ldflags "-X github.com/qmu/mcc/controller.Version=$(VERSION) -X github.com/qmu/mcc/controller.ConfigSchemaVersion=$(CONFIG_SCHEMA_VERSION)"
GH_UPLOAD := github-release upload --user qmu --repo $(NAME) --tag $(VERSION)

version:
	go run $(LDFLAGS) *.go -v

run:
	go run $(LDFLAGS) *.go -c _example/example.yml

erd:
	go-erd -path ./widget |dot -Tsvg > ./_build/widget_erd.svg
	go-erd -path ./model |dot -Tsvg > ./_build/model_erd.svg
	go-erd -path ./model/vector |dot -Tsvg > ./_build/vector_erd.svg

fmt:
	gofmt -s -w ./

clean:
	rm -rf _build/ release/

build:
	glide install
	mkdir -p _build
	gox $(LDFLAGS) -osarch="linux/amd64 darwin/amd64 linux/386 darwin/386" -output="_build/{{.OS}}_{{.Arch}}_{{.Dir}}"

test:
	go test github.com/qmu/mcc/... -cover

bench:
	go test github.com/qmu/mcc/... -bench . -benchmem

release:
	mkdir release
	go get github.com/aktau/github-release/...
	cp _build/* release
	github-release release \
		--user qmu \
		--repo $(NAME) \
		--tag $(VERSION) \
		--name $(VERSION)

	cd release/ \
		&& $(GH_UPLOAD) --name darwin_386_mcc --file darwin_386_mcc \
		&& $(GH_UPLOAD) --name darwin_amd64_mcc --file darwin_amd64_mcc \
		&& $(GH_UPLOAD) --name linux_386_mcc --file linux_386_mcc \
		&& $(GH_UPLOAD) --name linux_amd64_mcc --file linux_amd64_mcc

	git fetch --tags

.PHONY: build
