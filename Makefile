WORDLIST_URL  = https://www.eff.org/files/2016/07/18/eff_large_wordlist.txt
DATA_DIR      = data
WORDLIST_FILE = $(DATA_DIR)/eff_large_wordlist.txt

# Default target
all: $(WORDLIST_FILE)

# Rule to download into data/
$(WORDLIST_FILE): | $(DATA_DIR)
	curl -o $@ $(WORDLIST_URL)

# Ensure data/ exists
$(DATA_DIR):
	mkdir -p $(DATA_DIR)

# Cleanup
clean:
	rm -rf $(DATA_DIR)
