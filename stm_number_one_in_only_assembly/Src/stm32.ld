MEMORY
{
     rom (rx) : ORIGIN = 0x08000000, LENGTH = 512K
     ram (!rx) : ORIGIN = 0x20000000, LENGTH = 80K
}
SECTIONS
{
    .text : 
    {
    	_stext = .;
    	*(isr_vector)
    	*(.text)
    	_etext = .;
    } > rom
    .data :
    {
    	_sdata = .;
    	*(.data)
    	_edata = .;
    } > ram
}  