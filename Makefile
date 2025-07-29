.PHONY=contribute

contribute:
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
	mv params_old/*.zkey params_new

	cd params_new && snarkjs zkey contribute proof_of_burn.zkey proof_of_burn2.zkey --name="1st Contributor Name" -v --entropy="SOME ENTROPY"

	cd params_new && tar czf params_new.tar.gz *.zkey
	cd params_new && split -b1G params_new.tar.gz
	echo "Done!"