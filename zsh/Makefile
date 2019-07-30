OUTPUT_DIR := './dist/'
JOINED_SRC := './dist/full.zsh'

dist:
	mkdir -p $(OUTPUT_DIR)
	echo > $(JOINED_SRC)
	# rm -f ~/.zcompdump

	# TODO: src に
	# TODO: 番号付けして sort
	command ls ./*.zsh | xargs cat >> $(JOINED_SRC)

	zsh -n $(JOINED_SRC)                       # syntax check
	zsh -c "zcompile $(JOINED_SRC)"            # compile
	zsh -c "autoload -Uz compinit && compinit" # compinit は毎回実行しない

	cp -f $(JOINED_SRC).zwc $(JOINED_SRC).zwc.bak
	cp -f $(JOINED_SRC).zwc ~/.zshrc.zwc
