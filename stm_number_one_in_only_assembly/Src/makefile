# Define required macros here
all: add.s stm32.ld clean
	@echo "Running target all"
	arm-none-eabi-as -o add.o add.s
	arm-none-eabi-ld --print-memory-usage -flto --reduce-memory-overheads -Tstm32.ld -o add.elf add.o
	arm-none-eabi-objcopy -O binary add.elf add.bin

print_symbols: all
	@echo "Running target print_symbols"
	arm-none-eabi-nm --numeric-sort add.elf

clean:
	@echo "Running target clean"
	rm -f *.o
	rm -f *.elf
	rm -f *.bin
	
   
   
