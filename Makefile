.PHONY=contribute

CONTRIB_NUMBER := 1
PARAMS := https://github.com/worm-privacy/proof-of-burn/releases/download/v0.1.0/params.tar.gz
POSTFIX := $(shell printf "%0*d" 4 $(CONTRIB_NUMBER))
ENTROPY := $(shell tr -dc A-Za-z0-9 </dev/urandom | head -c 128; echo)
NAME := $(shell git remote get-url origin | sed -E 's#(git@|https://)github.com[:/](.+)/.+(.git)?#\2#')
WGET_ARGS := -q --show-progress

contribute:
	@echo "   __        _____  ____  __  __ "
	@echo "   \ \      / / _ \|  _ \|  \/  |"
	@echo "    \ \ /\ / / | | | |_) | |\/| |"
	@echo "     \ V  V /| |_| |  _ <| |  | |"
	@echo "      \_/\_/  \___/|_| \_\_|  |_|"
	@echo
	@echo "Welcome $(NAME)! 🪱"
	@echo "You will now contribute in the WORM's trusted-setup ceremony! :)"
	@echo
	@sleep 3

	@echo "Logging in to your GitHub..."
	@echo "$(PERSONAL_GH_TOKEN)" | gh auth login --with-token
	
	@echo "Downloading parameter files..."
	mkdir -p params_old
	cd params_old && wget -O params.tar.gz.aa $(WGET_ARGS) -c $(PARAMS).aa
	cd params_old && wget -O params.tar.gz.ab $(WGET_ARGS) -c $(PARAMS).ab
	cd params_old && wget -O params.tar.gz.ac $(WGET_ARGS) -c $(PARAMS).ac
	cd params_old && wget -O params.tar.gz.ad $(WGET_ARGS) -c $(PARAMS).ad
	cd params_old && wget -O params.tar.gz.ae $(WGET_ARGS) -c $(PARAMS).ae
	@echo "Extracting parameter files..."
	cat params_old/params.tar.gz.a* > params_old/params.tar.gz
	cd params_old && tar xzf params.tar.gz

	rm -rf params_old/*.tar.gz params_old/*.tar.gz.*

	mkdir -p $(POSTFIX)_$(NAME)

	#@echo "Contributing to Proof-of-Burn parameters..."
	#@snarkjs zkey contribute params_old/proof_of_burn.zkey $(POSTFIX)_$(NAME)/proof_of_burn.zkey --name="$(NAME)" -v --entropy="$(ENTROPY)" | tee proof_of_burn_logs.txt
	echo Hi > proof_of_burn_logs.txt

	@echo "Contributing to Spend parameters..."
	@snarkjs zkey contribute params_old/spend.zkey $(POSTFIX)_$(NAME)/spend.zkey --name="$(NAME)" -v --entropy="$(ENTROPY)" | tee spend_logs.txt

	sed -i -e 's/\x1b\[[0-9;]*m//g' proof_of_burn_logs.txt
	sed -i -e 's/\x1b\[[0-9;]*m//g' spend_logs.txt

	cd $(POSTFIX)_$(NAME) && tar czf $(POSTFIX)_$(NAME).tar.gz *.zkey
	cd $(POSTFIX)_$(NAME) && split -b1G $(POSTFIX)_$(NAME).tar.gz $(POSTFIX)_$(NAME).tar.gz.

	@cd $(POSTFIX)_$(NAME) && echo "SnarkJS logs for Proof-of-Burn circuit:\n" > notes.md
	@cd $(POSTFIX)_$(NAME) && echo "\`\`\`" >> notes.md
	@cd $(POSTFIX)_$(NAME) && cat ../proof_of_burn_logs.txt >> notes.md
	@cd $(POSTFIX)_$(NAME) && echo "\`\`\`" >> notes.md
	@cd $(POSTFIX)_$(NAME) && echo "\nSnarkJS logs for Spend circuit:\n" >> notes.md
	@cd $(POSTFIX)_$(NAME) && echo "\`\`\`" >> notes.md
	@cd $(POSTFIX)_$(NAME) && cat ../spend_logs.txt >> notes.md
	@cd $(POSTFIX)_$(NAME) && echo "\`\`\`" >> notes.md

	@echo "Uploading your contribution on GitHub..."

	cd $(POSTFIX)_$(NAME) && gh release create $(POSTFIX)_$(NAME) --title "$(NAME)'s contribution" --notes-file notes.md $(POSTFIX)_$(NAME).tar.gz.* ../*_logs.txt
	
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

	@awk '\
		/^PARAMS[[:space:]]*:=/ { \
			split($$0, a, ":="); \
			num = a[2]; \
			gsub(/^[ \t]+/, "", num); \
			num += 1; \
			print "CONTRIB_NUMBER := " num; \
			next; \
		} \
		{ print $$0; } \
	' Makefile > Makefile.tmp && mv Makefile.tmp Makefile

	@awk -v newval='PARAMS := https://github.com/$(NAME)/trusted-setup/releases/download/$(POSTFIX)_$(NAME)/$(POSTFIX)_$(NAME).tar.gz' ' \
		/^PARAMS :=/ { print newval; next } \
		{ print } \
		' Makefile > Makefile.new && mv Makefile.new Makefile

	@git checkout -b contrib/$(NAME)
	@git add $(POSTFIX)_$(NAME)/notes.md
	@git add Makefile
	@git config user.name "github-actions[bot]"
	@git config user.email "github-actions[bot]@users.noreply.github.com"
	git commit -m "feat: Add $(NAME)'s contribution"
	git remote set-url origin https://x-access-token:$(PERSONAL_GH_TOKEN)@github.com/$(NAME)/trusted-setup.git
	GITHUB_TOKEN=$(PERSONAL_GH_TOKEN) git push origin contrib/$(NAME)
	gh repo set-default worm-privacy/trusted-setup
	gh pr create --head $(NAME):contrib/$(NAME) --base main --title "$(NAME)'s contribution" --body-file $(POSTFIX)_$(NAME)/notes.md --repo worm-privacy/trusted-setup
	@echo "Done!"
