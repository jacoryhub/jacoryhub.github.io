.PHONY: build validate clean

build:
	./scripts/build-repo.sh

validate:
	./scripts/validate-repo.sh

clean:
	rm -f Packages Packages.gz Packages.bz2 Release InRelease
