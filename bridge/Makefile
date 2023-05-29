generate: build-abi
	mkdir -p pkg/abigen/
	mkdir -p pkg/abigen/token
	mkdir -p pkg/abigen/ownership
	abigen --abi=build/DDNSToken.abi --pkg=token --out=pkg/abigen/token/ddns_token.go
	abigen --abi=build/DomainOwnership.abi --pkg=ownership --out=pkg/abigen/ownership/domain_ownership.go

build-abi:
	mkdir -p build
	cd ../contracts; truffle build
	jq -r -M '.abi' ../contracts/build/contracts/DDNSToken.json > build/DDNSToken.abi
	jq -r -M '.abi' ../contracts/build/contracts/DomainOwnership.json > build/DomainOwnership.abi