IRON_VERSION := 11

ROPDB_VERSIONS = 10 11
ROPDB_TARGETS = $(addsuffix _ropdb.txt, $(addprefix iron_ropdb/, $(ROPDB_VERSIONS)))

SCRIPTS = "scripts"

.PHONY: directories all iron_ropdb build/constants

all: directories build/constants build/Data0
directories:
	@mkdir -p build && mkdir -p build/cro
	@mkdir -p p
	@mkdir -p q


build/constants: iron_ropdb/ropdb.txt
	@python $(SCRIPTS)/makeHeaders.py build/constants $^


build/Data0: $(wildcard iron_save/*.s)
	@cd iron_save && make
	@cp iron_save/Data0 $@


iron_ropdb: $(ROPDB_TARGETS)
iron_ropdb/ropdb.txt: $(ROPDB_TARGETS)
	@cp iron_ropdb/$(IRON_VERSION)_ropdb.txt iron_ropdb/ropdb.txt
iron_ropdb/%_ropdb.txt: iron_ropdb/10_ropdb_proto.txt
	@echo building ropDB for iron version $*...
	@python scripts/portRopDb.py iron_code_10.bin iron_code_$*.bin 0x00100000 iron_ropdb/10_ropdb_proto.txt iron_ropdb/$*_ropdb.txt
