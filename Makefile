PROG = mailnotify
# note $$2 for make eats the first $ !
VERSION = $(shell grep '^version:' $(PROG).cabal | awk '{print $$2}')
PROGX = $(PROG)-$(VERSION)-$(shell uname -s)-$(shell uname -m)
GHC = 9.2.4

help:
	@echo
	@echo Available targets:
	@echo
	@echo "freeze  - set ghc $(GHC) and generate cabal.project.freeze"
	@echo "build   - build $(PROGX)"
	@echo "release - create a release of version $(VERSION)"
	@echo "aur     - publish $(PROG)-bin $(VERSION) on AUR"
	@echo

git-status:
	@echo checking git status ...
	git status -s
	@[[ -z "$$(git status -s)" ]]
	#git diff -quiet

release: build
	git push
	gh release create $(VERSION) --generate-notes
	gh release upload $(VERSION) $(PROGX) $(PROGX).sha256 cabal.project.freeze
	git fetch --tags upstream

cabal.project.freeze: freeze
freeze:
	ghcup set ghc $(GHC)
	cabal freeze

build: git-status $(PROGX)
$(PROGX): cabal.project.freeze
	cabal build
	cabal install
	cp -a ~/.cabal/bin/$(PROG) $(PROGX)
	sha256sum $(PROGX) > $(PROGX).sha256

aur/PKGBUILD: $(PROG).cabal
	sed -i -e "s/^pkgver=.*$$/pkgver=$(VERSION)/" aur/PKGBUILD

.PHONY: aur
aur: git-status aur/PKGBUILD
	gh workflow run aur.yaml

clean:
	rm -f $(PROGX) $(PROGX).sha256
	rm -f *.freeze

clobber: clean
	cabal clean
