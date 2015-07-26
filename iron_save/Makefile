all: Data0

clean:
	@rm -f Data0

Data0: iron_save.s iron_constants.s iron_macros.s iron_rop.s ../build/iron_code.bin
	armips iron_save.s
