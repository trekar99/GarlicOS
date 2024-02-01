#---------------------------------------------------------------------------------
.SUFFIXES:
#---------------------------------------------------------------------------------
ifeq ($(strip $(DEVKITARM)),)
$(error "Please set DEVKITARM in your environment. export DEVKITARM=<path to>devkitARM")
endif

include $(DEVKITARM)/ds_rules

export TARGET		:=	$(shell basename $(CURDIR))
export TOPDIR		:=	$(CURDIR)

# NITRODATA contains the "virtual" file system accessed through filesystem lib
NITRODATA	:=	nitrofiles
export _ADDFILES	:=	-d $(CURDIR)/arm9/$(NITRODATA)

export GAME_TITLE :=  GARLIC_OS_v2
export GAME_SUBTITLE1 :=  Practica de Estructura de Sistemas Operativos
export GAME_SUBTITLE2 :=  Departamento de Ingenieria Informatica y Matematicas (URV)
export GAME_ICON  :=  $(DEVKITPRO)/libnds/icon.bmp

.PHONY: arm7/$(TARGET).elf arm9/$(TARGET).elf

#---------------------------------------------------------------------------------
# main targets
#---------------------------------------------------------------------------------

all: $(TARGET).nds

#---------------------------------------------------------------------------------
$(TARGET).nds	:	arm7/$(TARGET).elf arm9/$(TARGET).elf
	ndstool	-c $(TARGET).nds -7 arm7/$(TARGET).elf -9 arm9/$(TARGET).elf -b $(GAME_ICON) "$(GAME_TITLE);$(GAME_SUBTITLE1);$(GAME_SUBTITLE2)" $(_ADDFILES) 

	@echo built ... $(notdir $@)

#---------------------------------------------------------------------------------
arm7/$(TARGET).elf:
	$(MAKE) -C arm7
	
#---------------------------------------------------------------------------------
arm9/$(TARGET).elf:
	$(MAKE) -C arm9

#---------------------------------------------------------------------------------
clean:
	$(MAKE) -C arm9 clean
	$(MAKE) -C arm7 clean
	rm -f $(TARGET).nds $(TARGET).arm7 $(TARGET).arm9

#---------------------------------------------------------------------------------
run : $(TARGET).nds
	@echo "runing $(TARGET).nds with DesmuME"
	@$(DESMUME)/DeSmuME.exe $(TARGET).nds &

#---------------------------------------------------------------------------------
debug : $(TARGET).nds arm9/$(TARGET).elf
	@echo "testing $(TARGET).nds/.elf with DeSmuME_dev/Insight (gdb) through TCP port=1000"
	$(DESMUME)/DeSmuME_dev.exe --arm9gdb=1000 $(TARGET).nds &
	$(DEVKITPRO)/insight/bin/arm-eabi-insight arm9/$(TARGET).elf &
