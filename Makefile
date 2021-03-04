include Makefile.include
### Flags ###
CFLAGS		:= -Wall
ASFLAGS		:= -f elf64 -i $(SRC_DIR)
ASFLAGS		+= -F dwarf -g
LINK_FLAGS	:= -no-pie

### Main ###
.PHONY:	all
all:	setup $(SERVER) $(CLIENT)

.PHONY:	setup
setup:	
		@mkdir -p $(BIN_DIR)/$(SERVER)
		@mkdir -p $(BIN_DIR)/$(CLIENT)

.PHONY:	clean clean-server clean-client
clean:			clean-server clean-client
clean-server:
ifneq ($(BIN_DIR),)
		$(if $(wildcard $(SERVER_DIR)),cd $(SERVER_DIR) && rm -rf *.o *.so *.elf,)
endif
clean-client:
ifneq ($(BIN_DIR),)
		$(if $(wildcard $(CLIENT_DIR)),cd $(CLIENT_DIR) && rm -rf *.o *.so *.elf,)
endif


.PHONY:	run-server run-client
run-server:	
			./$(SERVER_DIR)/$(SERVER).elf
run-client:	
			./$(CLIENT_DIR)/$(CLIENT).elf



### Server Target ###
SERVER_SOURCES	:= $(wildcard $(SRC_DIR)/$(SERVER)/*.asm)
SERVER_TARGETS	:= $(addprefix $(SERVER_DIR)/, $(addsuffix .o, $(subst .,_, $(notdir $(SERVER_SOURCES)))))

.PHONY:	$(SERVER)
$(SERVER):	$(SERVER_TARGETS)
			$(LINKER) $(LINK_FLAGS) $(SERVER_TARGETS) -o $(SERVER_DIR)/$@.elf

### Client Target ###
CLIENT_SOURCES	:= $(wildcard $(SRC_DIR)/$(CLIENT)/*.asm)
CLIENT_TARGETS	:= $(addprefix $(CLIENT_DIR)/, $(addsuffix .o, $(subst .,_, $(notdir $(CLIENT_SOURCES)))))

.PHONY:	$(CLIENT)
$(CLIENT):	$(CLIENT_TARGETS)
			$(LINKER) $(LINK_FLAGS) $(CLIENT_TARGETS) -o $(CLIENT_DIR)/$@.elf


### Rules ###

$(SERVER_DIR)/%_c.o:	$(SRC_DIR)/$(SERVER)/%.c
						$(CC) $(CFLAGS) -c $< -o $@
$(SERVER_DIR)/%_asm.o:	$(SRC_DIR)/$(SERVER)/%.asm
						$(AS) $(ASFLAGS) -i $(dir $<) $< -o $@

$(CLIENT_DIR)/%_c.o:	$(SRC_DIR)/$(CLIENT)/%.c
						$(CC) $(CFLAGS) -c $< -o $@
$(CLIENT_DIR)/%_asm.o:	$(SRC_DIR)/$(CLIENT)/%.asm
						$(AS) $(ASFLAGS) -i $(dir $<) $< -o $@
