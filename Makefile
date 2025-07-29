.PHONY=contribute

CONTRIB_NUMBER := 0001
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

	
	@echo "Downloading parameter files..."
	mkdir -p params_old
	cd params_old && wget $(WGET_ARGS) -c https://github.com/worm-privacy/proof-of-burn/releases/download/v0.1.0/params.tar.gz.aa
	cd params_old && wget $(WGET_ARGS) -c https://github.com/worm-privacy/proof-of-burn/releases/download/v0.1.0/params.tar.gz.ab
	cd params_old && wget $(WGET_ARGS) -c https://github.com/worm-privacy/proof-of-burn/releases/download/v0.1.0/params.tar.gz.ac
	cd params_old && wget $(WGET_ARGS) -c https://github.com/worm-privacy/proof-of-burn/releases/download/v0.1.0/params.tar.gz.ad
	cd params_old && wget $(WGET_ARGS) -c https://github.com/worm-privacy/proof-of-burn/releases/download/v0.1.0/params.tar.gz.ae
	@echo "Extracting parameter files..."
	cat params_old/params.tar.gz.a* > params_old/params.tar.gz
	cd params_old && tar xzf params.tar.gz

	rm -rf params_old/*.tar.gz params_old/*.tar.gz.*

	mkdir -p params_$(CONTRIB_NUMBER)

	@echo "Contributing to Proof-of-Burn parameters..."
	@snarkjs zkey contribute params_old/proof_of_burn.zkey params_$(CONTRIB_NUMBER)/proof_of_burn.zkey --name="$(NAME)" -v --entropy="$(ENTROPY)" | tee proof_of_burn_logs.txt

	@echo "Contributing to Spend parameters..."
	@snarkjs zkey contribute params_old/spend.zkey params_$(CONTRIB_NUMBER)/spend.zkey --name="$(NAME)" -v --entropy="$(ENTROPY)" | tee spend_logs.txt

	cd params_$(CONTRIB_NUMBER) && tar czf params_$(CONTRIB_NUMBER).tar.gz *.zkey
	cd params_$(CONTRIB_NUMBER) && split -b1G params_$(CONTRIB_NUMBER).tar.gz params_$(CONTRIB_NUMBER).tar.gz.

	@cd params_$(CONTRIB_NUMBER) && echo "SnarkJS logs for Proof-of-Burn circuit:\n" > notes.md
	@cd params_$(CONTRIB_NUMBER) && echo "\`\`\`" >> notes.md
	@cd params_$(CONTRIB_NUMBER) && cat ../proof_of_burn_logs.txt >> notes.md
	@cd params_$(CONTRIB_NUMBER) && echo "\`\`\`" >> notes.md
	@cd params_$(CONTRIB_NUMBER) && echo "\nSnarkJS logs for Spend circuit:\n" >> notes.md
	@cd params_$(CONTRIB_NUMBER) && echo "\`\`\`" >> notes.md
	@cd params_$(CONTRIB_NUMBER) && cat ../spend_logs.txt >> notes.md
	@cd params_$(CONTRIB_NUMBER) && echo "\`\`\`" >> notes.md

	@echo "Uploading your contribution on GitHub..."

	@echo "$(PERSONAL_GH_TOKEN)" | gh auth login --with-token
	cd params_$(CONTRIB_NUMBER) && gh release create $(NAME) --title "$(NAME)'s contribution" --notes-file notes.md params_$(CONTRIB_NUMBER).tar.gz.* ../*_logs.txt
	@echo "Done!"