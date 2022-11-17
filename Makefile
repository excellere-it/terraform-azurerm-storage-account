default: test

testdir := ./test

docs:
	terraform-docs markdown document --output-file README.md --output-mode inject .

tffmt:
	terraform fmt -recursive

gofmt:
	cd $(testdir) && go fmt

fmt: tffmt gofmt

tidy:
	cd $(testdir) && go mod tidy

# Example: make test
test: tidy fmt docs
	cd $(testdir) && go test -v --timeout=30m

# Example: make upgrade
upgrade: fmt docs
	cd ./examples/default && terraform init -upgrade
	
# Example: make deploy
deploy: fmt docs
	cd ./examples/default && terraform apply

# Example: make destroy
destroy: fmt docs
	cd ./examples/default && terraform destroy
