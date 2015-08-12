ROPDB_VERSIONS = 10 11 10_eu 11_eu
ROPDB_TARGETS = $(addsuffix _ropdb.txt, $(addprefix iron_ropdb/, $(ROPDB_VERSIONS)))
ROPDB_TARGET = iron_ropdb/$(IRON_VERSION)_ropdb.txt

DATA_TARGET = Data$(IRON_SAVESLOT)_$(IRON_VERSION)_$(FIRM_VERSION)

SCRIPTS = "scripts"

.PHONY: directories all build/constants clean

all: directories build/constants installer/data/$(DATA_TARGET).bin
directories:
	@mkdir -p build && mkdir -p build/cro
	@mkdir -p installer/data


build/constants: iron_ropdb/ropdb.txt
	@python $(SCRIPTS)/makeHeaders.py build/constants "IRON_VERSION=$(IRON_VERSION)" "FIRM_VERSION=$(FIRM_VERSION)" $^


installer/data/$(DATA_TARGET).bin: $(wildcard iron_save/*.s) build/iron_code.bin
	@cd iron_save && make
	@cp iron_save/Data $@


build/iron_code.bin: iron_code/iron_code.bin
	@cp iron_code/iron_code.bin build/
iron_code/iron_code.bin: $(wildcard iron_code/source/*)
	@cd iron_code && make


iron_ropdb: $(ROPDB_TARGETS)
iron_ropdb/ropdb.txt: $(ROPDB_TARGET)
	@cp $(ROPDB_TARGET) iron_ropdb/ropdb.txt
iron_ropdb/%_ropdb.txt: iron_ropdb/10_ropdb_proto.txt
	@echo building ropDB for iron version $*...
	@python scripts/portRopDb.py iron_code_10.bin iron_code_$*.bin 0x00100000 iron_ropdb/10_ropdb_proto.txt iron_ropdb/$*_ropdb.txt

clean:
	@rm -rf build
	@cd iron_save && make clean
	@cd iron_code && make clean
