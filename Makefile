.PHONY=contribute

contribute:
	echo "Welcome $(NAME)!"

	mkdir -p params_old
	mkdir -p params_new
	echo "Downloading parameter files..."
	cd params_old && wget $(WGET_ARGS) -c https://github.com/worm-privacy/proof-of-burn/releases/download/v0.1.0/params.tar.gz.aa
	cd params_old && wget $(WGET_ARGS) -c https://github.com/worm-privacy/proof-of-burn/releases/download/v0.1.0/params.tar.gz.ab
	cd params_old && wget $(WGET_ARGS) -c https://github.com/worm-privacy/proof-of-burn/releases/download/v0.1.0/params.tar.gz.ac
	cd params_old && wget $(WGET_ARGS) -c https://github.com/worm-privacy/proof-of-burn/releases/download/v0.1.0/params.tar.gz.ad
	cd params_old && wget $(WGET_ARGS) -c https://github.com/worm-privacy/proof-of-burn/releases/download/v0.1.0/params.tar.gz.ae
	echo "Extracting parameter files..."
	cat params_old/params.tar.gz.a* > params_old/params.tar.gz
	cd params_old && tar xzf params.tar.gz

	#echo "Contributing to Proof-of-Burn parameters..."
	#snarkjs zkey contribute params_old/proof_of_burn.zkey params_new/proof_of_burn.zkey --name="$(NAME)" -v --entropy="$(ENTROPY)"

	echo "Contributing to Spend parameters..."
	snarkjs zkey contribute params_old/spend.zkey params_new/spend.zkey --name="$(NAME)" -v --entropy="$(ENTROPY)"

	cd params_new && tar czf params_new.tar.gz *.zkey
	cd params_new && split -b1G params_new.tar.gz

	#GH_TOKEN=$(GH_TOKEN) gh auth login
	cd params_new && gh release create $(NAME) params_new.tar.gz.*
	echo "Done!"