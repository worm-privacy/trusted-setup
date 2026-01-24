.PHONY: contribute

CONTRIB_NUMBER := 84
PARAMS := https://github.com/worm-privacy/trusted-setup/releases/download/final/final.tar.gz
PREFIX := $(shell printf "%0*d" 4 $(CONTRIB_NUMBER))
ENTROPY := $(shell tr -dc A-Za-z0-9 </dev/urandom | head -c 128; echo)
NAME := $(shell git remote get-url origin | sed -E 's#(git@|https://)github.com[:/](.+)/.+(.git)?#\2#')
CONTRIB_NAME := $(PREFIX)_$(NAME)
WGET_ARGS := -q --show-progress
PERSONAL_NOTE := ""

# Beacon is the Ethereum block hash of block #12345678
BEACON := b2a8b39935a5eb4b7c9b0117bca06c8d2c0629e0937d20e62c44aace6f05bda3

verify:
	@echo "Downloading parameter files..."
	@mkdir -p params_old
	cd params_old && wget -O params.tar.gz.aa $(WGET_ARGS) -c $(PARAMS).aa
	cd params_old && wget -O params.tar.gz.ab $(WGET_ARGS) -c $(PARAMS).ab
	cd params_old && wget -O params.tar.gz.ac $(WGET_ARGS) -c $(PARAMS).ac
	cd params_old && wget -O params.tar.gz.ad $(WGET_ARGS) -c $(PARAMS).ad
	cd params_old && wget -O params.tar.gz.ae $(WGET_ARGS) -c $(PARAMS).ae
	@echo "Extracting parameter files..."
	@cat params_old/params.tar.gz.a* > params_old/params.tar.gz
	@cd params_old && tar xzf params.tar.gz
	@if [ "$$REMOVE_PARAMS" != "" ]; then rm -rf params_old/*.tar.gz params_old/*.tar.gz.*; fi

	@echo "Downloading R1CS files..."
	wget -O proof_of_burn.r1cs.gz $(WGET_ARGS) -c https://github.com/worm-privacy/trusted-setup/releases/download/circuit_data/proof_of_burn.r1cs.gz
	wget -O spend.r1cs.gz $(WGET_ARGS) -c https://github.com/worm-privacy/trusted-setup/releases/download/circuit_data/spend.r1cs.gz
	gunzip proof_of_burn.r1cs.gz
	gunzip spend.r1cs.gz

	wget -O powersOfTau28_hez_final_18.ptau $(WGET_ARGS) -c https://storage.googleapis.com/zkevm/ptau/powersOfTau28_hez_final_18.ptau
	snarkjs zkey verify spend.r1cs powersOfTau28_hez_final_18.ptau params_old/spend.zkey

	wget -O powersOfTau28_hez_final_24.ptau $(WGET_ARGS) -c https://storage.googleapis.com/zkevm/ptau/powersOfTau28_hez_final_24.ptau
	snarkjs zkey verify proof_of_burn.r1cs powersOfTau28_hez_final_24.ptau params_old/proof_of_burn.zkey
	

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
	@mkdir -p params_old
	cd params_old && wget -O params.tar.gz.aa $(WGET_ARGS) -c $(PARAMS).aa
	cd params_old && wget -O params.tar.gz.ab $(WGET_ARGS) -c $(PARAMS).ab
	cd params_old && wget -O params.tar.gz.ac $(WGET_ARGS) -c $(PARAMS).ac
	cd params_old && wget -O params.tar.gz.ad $(WGET_ARGS) -c $(PARAMS).ad
	cd params_old && wget -O params.tar.gz.ae $(WGET_ARGS) -c $(PARAMS).ae
	@echo "Extracting parameter files..."
	@cat params_old/params.tar.gz.a* > params_old/params.tar.gz
	@cd params_old && tar xzf params.tar.gz

	ls params_old

	@if [ "$$REMOVE_PARAMS" != "" ]; then rm -rf params_old/*.tar.gz params_old/*.tar.gz.*; fi

	@mkdir -p $(CONTRIB_NAME)

	@echo "Contributing to Proof-of-Burn parameters..."
	@snarkjs zkey contribute params_old/proof_of_burn.zkey $(CONTRIB_NAME)/proof_of_burn.zkey --name="$(NAME)" -v --entropy="$(ENTROPY)" | tee proof_of_burn_logs.txt

	@echo "Contributing to Spend parameters..."
	@snarkjs zkey contribute params_old/spend.zkey $(CONTRIB_NAME)/spend.zkey --name="$(NAME)" -v --entropy="$(ENTROPY)" | tee spend_logs.txt

	@echo "Generating Solidity verifiers..."
	@snarkjs zkey export solidityverifier $(CONTRIB_NAME)/spend.zkey $(CONTRIB_NAME)/SpendVerifier.sol
	@snarkjs zkey export solidityverifier $(CONTRIB_NAME)/proof_of_burn.zkey $(CONTRIB_NAME)/ProofOfBurnVerifier.sol

	@sed -i -e 's/\x1b\[[0-9;]*m//g' proof_of_burn_logs.txt
	@sed -i -e 's/\x1b\[[0-9;]*m//g' spend_logs.txt

	@cd $(CONTRIB_NAME) && tar czf - *.zkey | split -b1G - $(CONTRIB_NAME).tar.gz.

	@cd $(CONTRIB_NAME) && echo "Release: https://github.com/$(NAME)/trusted-setup/releases/tag/$(CONTRIB_NAME) \n" > README.md
	@cd $(CONTRIB_NAME) && echo "Note: $(PERSONAL_NOTE) \n" >> README.md
	@cd $(CONTRIB_NAME) && echo "Parent params: $(PARAMS) \n" >> README.md
	@cd $(CONTRIB_NAME) && echo "SnarkJS logs for Proof-of-Burn circuit:\n" >> README.md
	@cd $(CONTRIB_NAME) && echo "\`\`\`" >> README.md
	@cd $(CONTRIB_NAME) && cat ../proof_of_burn_logs.txt >> README.md
	@cd $(CONTRIB_NAME) && echo "\`\`\`" >> README.md
	@cd $(CONTRIB_NAME) && echo "\nSnarkJS logs for Spend circuit:\n" >> README.md
	@cd $(CONTRIB_NAME) && echo "\`\`\`" >> README.md
	@cd $(CONTRIB_NAME) && cat ../spend_logs.txt >> README.md
	@cd $(CONTRIB_NAME) && echo "\`\`\`" >> README.md
	
	@echo "Uploading your contribution on GitHub..."

	@gh repo set-default $(NAME)/trusted-setup
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

beacon:
	@echo "Logging in to your GitHub..."
	@echo "$(PERSONAL_GH_TOKEN)" | gh auth login --with-token
	
	@echo "Downloading parameter files..."
	@mkdir -p params_old
	cd params_old && wget -O params.tar.gz.aa $(WGET_ARGS) -c $(PARAMS).aa
	cd params_old && wget -O params.tar.gz.ab $(WGET_ARGS) -c $(PARAMS).ab
	cd params_old && wget -O params.tar.gz.ac $(WGET_ARGS) -c $(PARAMS).ac
	cd params_old && wget -O params.tar.gz.ad $(WGET_ARGS) -c $(PARAMS).ad
	cd params_old && wget -O params.tar.gz.ae $(WGET_ARGS) -c $(PARAMS).ae
	@echo "Extracting parameter files..."
	@cat params_old/params.tar.gz.a* > params_old/params.tar.gz
	@cd params_old && tar xzf params.tar.gz

	ls params_old

	@if [ "$$REMOVE_PARAMS" != "" ]; then rm -rf params_old/*.tar.gz params_old/*.tar.gz.*; fi

	@mkdir -p final

	@echo "Applying random beacon to Proof-of-Burn parameters..."
	@snarkjs zkey beacon params_old/proof_of_burn.zkey final/proof_of_burn.zkey $(BEACON) 10 -n="Final Beacon Proof-of-Burn" | tee proof_of_burn_logs.txt

	@echo "Applying random beacon to Spend parameters..."
	@snarkjs zkey beacon params_old/spend.zkey final/spend.zkey $(BEACON) 10 -n="Final Beacon Spend" | tee spend_logs.txt

	@echo "Generating Solidity verifiers..."
	@snarkjs zkey export solidityverifier final/spend.zkey final/SpendVerifier.sol
	@snarkjs zkey export solidityverifier final/proof_of_burn.zkey final/ProofOfBurnVerifier.sol

	@sed -i -e 's/\x1b\[[0-9;]*m//g' proof_of_burn_logs.txt
	@sed -i -e 's/\x1b\[[0-9;]*m//g' spend_logs.txt

	@cd final && tar czf - *.zkey | split -b1G - final.tar.gz.

	@cd final && echo "Release: https://github.com/$(NAME)/trusted-setup/releases/tag/final \n" > README.md
	@cd final && echo "Note: $(PERSONAL_NOTE) \n" >> README.md
	@cd final && echo "Parent params: $(PARAMS) \n" >> README.md
	@cd final && echo "SnarkJS logs for Proof-of-Burn circuit:\n" >> README.md
	@cd final && echo "\`\`\`" >> README.md
	@cd final && cat ../proof_of_burn_logs.txt >> README.md
	@cd final && echo "\`\`\`" >> README.md
	@cd final && echo "\nSnarkJS logs for Spend circuit:\n" >> README.md
	@cd final && echo "\`\`\`" >> README.md
	@cd final && cat ../spend_logs.txt >> README.md
	@cd final && echo "\`\`\`" >> README.md
	
	@echo "Uploading your contribution on GitHub..."

	@gh repo set-default $(NAME)/trusted-setup
	@cd final && gh release create final --title "Beacon contribution" --notes-file README.md final.tar.gz.* *.sol ../*_logs.txt
	
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

	@awk -v newval='PARAMS := https://github.com/$(NAME)/trusted-setup/releases/download/final/final.tar.gz' ' \
		/^PARAMS :=/ { print newval; next } \
		{ print } \
		' Makefile > Makefile.new && mv Makefile.new Makefile

	@git checkout -b contrib/final
	@git add final/README.md
	@git add Makefile
	@git config user.name $(NAME)
	@git config user.email $(NAME)@users.noreply.github.com
	@git commit -m "feat: Add $(NAME)'s contribution"
	@git remote set-url origin https://x-access-token:$(PERSONAL_GH_TOKEN)@github.com/$(NAME)/trusted-setup.git
	@GITHUB_TOKEN=$(PERSONAL_GH_TOKEN) git push origin contrib/final
	@gh repo set-default worm-privacy/trusted-setup
	@gh pr create --head $(NAME):contrib/final --base main --title "$(NAME)'s contribution" --body-file final/README.md --repo worm-privacy/trusted-setup
	@echo "Done!"
