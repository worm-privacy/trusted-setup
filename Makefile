.PHONY=contribute

CONTRIB_NUMBER := 2
PARAMS := https://github.com/d3mage/trusted-setup/releases/download/0001_d3mage/0001_d3mage.tar.gz
PREFIX := $(shell printf "%0*d" 4 $(CONTRIB_NUMBER))
ENTROPY := $(shell tr -dc A-Za-z0-9 </dev/urandom | head -c 128; echo)
NAME := $(shell git remote get-url origin | sed -E 's#(git@|https://)github.com[:/](.+)/.+(.git)?#\2#')
CONTRIB_NAME := $(PREFIX)_$(NAME)
WGET_ARGS := -q --show-progress

contribute:
	
	@echo "Uploading your contribution on GitHub..."

	@cd $(CONTRIB_NAME) && gh release create $(CONTRIB_NAME) --title "$(NAME)'s contribution" --notes-file README.md $(CONTRIB_NAME).tar.gz.* *.sol ../*_logs.txt
	
	@echo "Creating PR..."

	@awk '\
		/^CONTRIB_NUMBER[[:space:]]*:=/ { \
			split($$0, a, ":="); \
			num = a[2]; \
			gsub(/^[ \t]+/, "", num); \
			num += 1; \
			print "CONTRIB_NUMBER := " num; \
			next; \
		} \
		{ print $$0; } \
	' Makefile > Makefile.tmp && mv Makefile.tmp Makefile

	@awk -v newval='PARAMS := https://github.com/$(NAME)/trusted-setup/releases/download/$(CONTRIB_NAME)/$(CONTRIB_NAME).tar.gz' ' \
		/^PARAMS :=/ { print newval; next } \
		{ print } \
		' Makefile > Makefile.new && mv Makefile.new Makefile

	@git checkout -b contrib/$(CONTRIB_NAME)
	@git add $(CONTRIB_NAME)/README.md
	@git add Makefile
	@git config user.name $(NAME)
	@git config user.email $(NAME)@users.noreply.github.com
	@git commit -m "feat: Add $(NAME)'s contribution"
	@git remote set-url origin https://x-access-token:$(PERSONAL_GH_TOKEN)@github.com/$(NAME)/trusted-setup.git
	@GITHUB_TOKEN=$(PERSONAL_GH_TOKEN) git push origin contrib/$(CONTRIB_NAME)
	@gh repo set-default worm-privacy/trusted-setup
	@gh pr create --head $(NAME):contrib/$(CONTRIB_NAME) --base main --title "$(NAME)'s contribution" --body-file $(CONTRIB_NAME)/README.md --repo worm-privacy/trusted-setup
	@echo "Done!"
