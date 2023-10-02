/*
 * main.s
 *
 *  Created on: Dec 10, 2022
 *      Author: zevni
 */
 	.syntax unified
	.thumb
    .section    isr_vector
    .word       0x2000A000 + 0x1 //top of stack value
    .word       _start + 0x1 //reset
    .word       _nmi_handler + 0x1 //NMI
    .word       _hard_fault + 0x1 //hard fault
    .word       _memory_fault + 0x1 //mem managment
    .word       _bus_fault + 0x1 //bus fault
    .word       _usage_fault + 0x1 //usage fault
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder -> 4 reserved
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word		_tim_two_int + 0x1 //timer two int
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _start + 0x1 //place holder
    .word       _exti_15_10_int + 0x1 //exti 15:10 int


	.text
    .global _start


_start:

setup_timer:
	//0x4002 1000 -> rcc base adress
	ldr r0, =#0x40021000 //enable HSI16 oscilator and disable clock multiplication
	ldr r1, [r0]
	orr r1, r1, 0x00000100
	and r1, r1, 0xFEFFFFFF
	str r1, [r0]

wait_HSI16:
	ldr r1, [r0] //check bit 10 for HSIRDY flag
	and r1, r1, 0x00000400
	cmp r1, 0x0400
	it ne
	bne wait_HSI16

	//continiue timer setup
	ldr r0, =#0x40021008	//setup timer devision
	ldr r1, [r0]
	ldr r3, =#0xFFFFC00E
	and r1, r1, r3 //sets zeros
	orr r1, r1, #0x00000001 //sets ones
	str r1, [r0]


	ldr r0, =#0x08000000 //load values
	ldr r1, =#0x20000000

//setup vector table -> = 0xE000 E008 -> E010
	/*ldr r0, =#0xE000E010
	ldr r1, =#0x00000000
	str r1, [r0] //make the vector table in SRAM*/

copy_isr:

	ldr r2, [r0]	//relocate values and increment
	str r2, [r1]
	add r0, r0, #0x4
	add r1, r1, #0x4

	ldr r3, =#0x080000E4
	cmp r0, r3	//check if done
	it eq
	beq init
	b copy_isr


//0x48001400 -> portF base adress
//0x48000800 -> portC base adress
//0x48001800 -> portG base adress
//0x48000400 -> portB base adress
//0x4002 1000 -> rcc base adress
init:

	ldr r0, =#0x00006066 //start gpio b, f, c, g, adc4 clock
	ldr r1, =#0x4002104C
	str r0, [r1]

	ldr r0, =#0x1 //start timer two clock
	ldr r1, =#0x40021058
	str r0, [r1]

	ldr r0, =#0x1 //start SYSCFG clock
	ldr r1, =#0x40021060
	str r0, [r1]

	/*ldr r0, =#0x0000063B
	ldr r1, =#0x40021018
	str r0, [r1]*/

	ldr r0, =#0x0 //delay of two cycles is needed
	ldr r0, =#0x1
	ldr r0, =#0x2

	//SYSCFG setup
	ldr r0, =#0x00000003 //set SRAM1 mapped to 0x0
	ldr r1, =#0x40010000
	str r0, [r1]

	//PORT F SETUP
	ldr r0, =#0x00000550 //MODE REGISTER
	ldr r1, =#0x48001400
	str r0, [r1]

	ldr r0, =#0x0 //PORT OUTPUT TYPE REGISTER
	ldr r1, =#0x48001404
	str r0, [r1]

	ldr r0, =#0x0 //PORT OUTPUT SPEED REGISTER
	ldr r1, =#0x48001408
	str r0, [r1]

	ldr r0, =#0x0 //PORT PULL UP PULL DOWN REGISTER
	ldr r1, =#0x4800140C
	str r0, [r1]

	//PORT C SETUP
	ldr r0, =#0x00000055 //MODE REGISTER
	ldr r1, =#0x48000800
	str r0, [r1]

	ldr r0, =#0x0 //PORT OUTPUT TYPE REGISTER
	ldr r1, =#0x48000804
	str r0, [r1]

	ldr r0, =#0x0 //PORT OUTPUT SPEED REGISTER
	ldr r1, =#0x48000808
	str r0, [r1]

	ldr r0, =#0x50000000 //PORT PULL UP PULL DOWN REGISTER
	ldr r1, =#0x4800080C
	str r0, [r1]

	//PORT G SETUP
	ldr r0, =#0x0 //MODE REGISTER
	ldr r1, =#0x48001800
	str r0, [r1]

	ldr r0, =#0x0 //PORT OUTPUT TYPE REGISTER
	ldr r1, =#0x48001804
	str r0, [r1]

	ldr r0, =#0x0 //PORT OUTPUT SPEED REGISTER
	ldr r1, =#0x48001808
	str r0, [r1]

	ldr r0, =#0x00011005 //PORT PULL UP PULL DOWN REGISTER
	ldr r1, =#0x4800180C
	str r0, [r1]

	//PORT B SETUP
	//0x48000400 -> portB base adress
	ldr r0, =#0x30000000 //Set as analog
	ldr r1, =#0x48000400
	str r0, [r1]

	ldr r0, =#0x0 //PORT PULL UP PULL DOWN REGISTER
	ldr r1, =#0x4800040C
	str r0, [r1]



	//TIM2 SETUP
	//TIM2 base adress 0x40000000


	ldr r0, =#0x00000000 //CONTROL REGISTER 2
	ldr r1, =#0x40000004
	str r0, [r1]

	ldr r0, =#0x00000000 //SLAVE MODE CONTROL REGISTER
	ldr r1, =#0x40000008
	str r0, [r1]

	ldr r0, =#0x00000001 //DMA/INTERRUPT ENABLE REGISTER
	ldr r1, =#0x4000000C
	str r0, [r1]

	ldr r0, =#0x00000020 //PRESCALER REGISTER
	ldr r1, =#0x40000028
	str r0, [r1]

	ldr r0, =#0x0007A120 //AUTO RELOAD REGISTER
	ldr r1, =#0x4000002C
	str r0, [r1]

	ldr r0, =#0x00000005 //CONTROL REGISTER 1 (start TIM2)
	ldr r1, =#0x40000000
	str r0, [r1]

	//SETUP ADC1 -> PB14 (adc1_in_5)
	//0x50000000

	//close analog switch
	/*ldr r0, =#0x0
	ldr r1, =#0x40010030
	str r0, [r1]*/

	/*tmp_loop:
	ldr r0, =#0x50000408
	ldr r1, [r0]
	b tmp_loop*/

	ldr r0, =#0xFFFFFFFE //disable adc
	ldr r1, =#0x50000508
	//str r0, [r1]
	ldr r2, [r1]
	and r2, r2, r0
	str r2, [r1]





	//enable analog boost
	ldr r0, =#0x00000100
	ldr r1, =#0x40010004
	ldr r2, [r1]
	orr r2, r2, r0
	str r2, [r1]

	ldr r0, =#0x00410000 //enable internal channel, selec snyc clock mode, configure adc as independent
	ldr r1, =#0x50000708
	str r0, [r1]

	/*ldr r0, =#0x0 //configure adc as independent
	ldr r1, =#0x50000308
	str r0, [r1]*/

	//enable voltage regulator
	ldr r1, =#0x50000508
	ldr r0, =#0xDFFFFFFF //turn off deep power mode
	ldr r2, [r1]
	and r2, r2, r0
	str r2, [r1]

	ldr r0, =#0x10000000 //enable voltage regulator
	ldr r1, =#0x50000508
	ldr r2, [r1]
	orr r2, r2, r0
	str r2, [r1]

	//wait for 30us -> 480 ciklou (dau sm jih mal vec)
	ldr r0, =#0x0
setup_adc1_loop:
	cmp r0, #0x3C0
	IT eq
	beq exit_setup_adc1_loop
	add r0, r0, #0x1
	b setup_adc1_loop
exit_setup_adc1_loop:

	ldr r0, =#0x80000000 //set resolution to 12 bits, set adc1 in disconitous mode
	ldr r1, =#0x5000050C
	str r0, [r1]

	ldr r0, =#0x00000100 //select one conversion, specify channel number
	ldr r1, =#0x50000530
	str r0, [r1]

	ldr r0, =#0x00000000 //configure channel as single ended
	ldr r1, =#0x500005B0
	str r0, [r1]

	ldr r0, =#0x00038000 //select sample time 640.5 ADC clock cycles
	ldr r1, =#0x50000514
	str r0, [r1]

	/*ldr r0, =#0x80000000 //set adc1 in disconitous mode
	ldr r1, =#0x5000000C
	str r0, [r1]*/

	ldr r0, =#0x00000001 //enable adc
	ldr r1, =#0x50000508
	ldr r2, [r1]
	orr r2, r2, r0
	str r2, [r1]


/*tmp:
	ldr r0, [r1]
	b tmp*/

	//wait for adc to be ready
wait_for_adc_ready:
	ldr r1, =#0x50000500
	ldr r0, [r1]
	and r0, r0, #0x1
	cmp r0, #0x1
	it ne
	bne wait_for_adc_ready

	//clear ready flag
	ldr r1, =#0x50000500
	ldr r0, =#0x1
	str r0, [r1]





	//SETUP AND ENABLE SYSTICK
	//base address -> 0xE000E010
	ldr r0, =#0x00186A00 //stk_load register
	ldr r1, =#0xE000E014
	str r0, [r1]

	ldr r0, =#0x0 //clear counter value
	ldr r1, =#0xE000E018
	str r0, [r1]

	ldr r0, =#0x00000005 //select processor clock, no exception and enable counter
	ldr r1, =#0xE000E010
	str r0, [r1]

	//ENABLE EXTI IRQ
	//NVIC base address -> 0xE000E100
	ldr r0, =#0x00000100 //enable interrupt number 40 (EXTI15:9)
	ldr r1, =#0xE000E104
	str r0, [r1]

	ldr r0, =#0x10000000 //enable interrupt number 28 (TIM2)
	ldr r1, =#0xE000E100
	str r0, [r1]

	//SYSCFG SETUP
	//base address -> 0x40010000
	ldr r0, =#0x00000200 //EXTERNAL INTERRUPT CONFIGURATION REGISTER 4 -> SET PC[14]
	ldr r1, =#0x40010014
	str r0, [r1]

	//EXTI SETUP
	//base address -> 0x40010400

	ldr r0, =#0x00004000 //RISING TRIGGER SELECTION REGISTER (EXTI14)
	ldr r1, =#0x40010408
	str r0, [r1]

	ldr r0, =#0x00004000 //INTERRUPT MASK REGISTER (EXTI14)
	ldr r1, =#0x40010400
	str r0, [r1]

	ldr r0, =current_water
	ldr r1, =#0x0
	str r1, [r0]
setup_variables:
	//setup variables
	ldr r0, =led_counter
	ldr r1, =#0x0
	str r1, [r0]
	ldr r0, =current_time
	ldr r1, =#0x0
	str r1, [r0]
	ldr r0, =interval_time
	ldr r1, =#0x1
	str r1, [r0]
	ldr r0, =water_amount
	ldr r1, =#0x2
	str r1, [r0]
	ldr r0, =set_interval_time_flag
	ldr r1, =#0x1
	str r1, [r0]
	//turn on led 0
	ldr r1, =#0x48001418
	mov r2,#0x4
	str r2, [r1]

loop_ok:
	//loop until button OK is not pressed so that you dont instantly go out of the sub with flag and water
	//0x48000800 -> portC base adress
	ldr r0, =#0x48000810
	ldr r1, [r0]
	and r1, r1, #0x8000
	cmp r1, #0x0 //check if ok button was pressed
	IT eq
	beq loop_ok


setup_interval_time:

	//IF LEFT IS PRESSED
	ldr r0, =#0x48001810 //portG input register for button left/right -> 6/8
	ldr r1, [r0]
	and r1, r1, #0x00000040
	cmp r1, #0x0
	IT eq
	beq add_to_interval_time

	//IF RIGHT IS PRESSED
	ldr r0, =#0x48001810 //portG input register for button left/right -> 6/8
	ldr r1, [r0]
	and r1, r1, #0x00000100
	cmp r1, #0x0
	IT eq
	beq sub_from_interval_time

	//IF OKAY IS PRESSED
	//0x48000800 -> portC base adress
	ldr r0, =#0x48000810
	ldr r1, [r0]
	and r1, r1, #0x8000
	cmp r1, #0x0 //check if ok button was pressed
	IT ne
	bne setup_interval_time //if not pressed -> loop


	//get ready for main function and branch
	ldr r0, =#0x40000024  //clear timer two counter register
	ldr r1, =#0x0
	str r1, [r0]

	ldr r0, =current_time //reset current_time counter
	ldr r1, =#0x0
	str r1, [r0]

	ldr r0, =led_counter //reset led_counter
	ldr r1, =#0x0
	str r1, [r0]

	bl operate_led

	ldr r0, =set_interval_time_flag
	ldr r1, =#0x0
	str r1, [r0]

	b main_loop //go to main loop



	//b setup_interval_time //if nothing is pressed -> loop

add_to_interval_time:

	ldr r0, =interval_time //load interval time -> add 1 to interval time -> check interval time if > 9 -> write interval time
	ldr r1, [r0]
	add r1, r1, #0x1
	cmp r1, 0x9
	IT eq
	moveq r1, 0x8
	str r1, [r0]

	//LED LIGHTING
	ldr r0, =led_counter
	ldr r1, =interval_time
	ldr r2, [r1]
	str r2, [r0]
	bl operate_led

	b interval_time_delay


sub_from_interval_time:
	ldr r0, =interval_time //load interval time -> add 1 to interval time -> check interval time if > 9 -> write interval time
	ldr r1, [r0]
	cmp r1, #0x1
	IT eq
	moveq r1, #0x2
	sub r1, r1, #0x1
	str r1, [r0]

	//LED LIGHTING
	ldr r0, =led_counter
	ldr r1, =interval_time
	ldr r2, [r1]
	str r2, [r0]
	bl operate_led

	b interval_time_delay

interval_time_delay:
	//ADD DELAY
	ldr r0, =#0x40000024  //clear timer two counter register
	ldr r1, =#0x0
	str r1, [r0]

	ldr r0, =current_time //reset current_time counter
	ldr r1, =#0x0
	str r1, [r0]

interval_time_delay_sub_function:
	ldr r1, [r0]
	cmp r1, #0x1 //check value in current_time
	IT hs
	bhs setup_interval_time //branch and exchange back to setup_interval_time
	b interval_time_delay_sub_function //loop

main_loop:

	//check if you need to set interval_time
	ldr r0, =set_interval_time_flag //load current time flag
	ldr r1, [r0]
	cmp r1, #0x1
	IT eq
	beq setup_variables

	ldr r0, =current_time //load current time
	ldr r1, [r0]

	ldr r0, =interval_time //load interval time
	ldr r2, [r0]

	cmp r1, r2 //check if we need to water
	IT hs
	blhs water //ce sta enaka zalij

	b main_loop //loop back

water: //as in water the plants

	ldr r0, =current_time //clear current time
	ldr r1, =#0x0
	str r1, [r0]

	//check moisture in soil
	ldr r0, =#0x00000004 //start conversion
	ldr r1, =#0x50000508
	ldr r2, [r1]
	orr r2, r2, r0
	str r2, [r1]
wait_for_adc_result:
	ldr r1, =#0x50000500
	ldr r0, [r1]
	ldr r2, =#0x00000004
	and r0, r0, r2
	cmp r0, r2
	it ne
	bne wait_for_adc_result
 	//read conversion
	ldr r1, =#0x50000540
	ldr r0, [r1]

	ldr r2, =#0xBB8 //check for moisture
	cmp r0, r2
	it hs
	bxhs LR

	//check if we need to change the water
	ldr r0, =current_water
	ldr r1, [r0]

	ldr r0, =water_amount
	ldr r2, [r0]

	cmp r1, r2
	IT hs
	bhs init_watering_animation

	ldr r0, =led_counter //clear leds
	ldr r1, =#0x0
	str r1, [r0]
	push {LR}
	bl operate_led
	pop {LR}
water_loop: //watering animation
	ldr r0, =led_counter //load values
	ldr r1, [r0]

	ldr r0, =current_time
	ldr r2, [r0]

	cmp r2, #0x9 //check if current time is 8
	IT hs
	bhs exit_water_loop

	ldr r0, =led_counter //store the current time into led_counter
	str r2, [r0]
	push {LR}
	bl operate_led
	pop {LR}

	b water_loop

exit_water_loop: //exiting the water loop

	ldr r0, =current_water //add 1 to current_water
	ldr r2, [r0]
	add r2, r2, #0x1
	str r2, [r0]

	ldr r0, =led_counter //clear values and branch exchange
	ldr r1, =#0x0
	str r1, [r0]

	ldr r0, =current_time
	str r1, [r0]

	push {LR}
	bl operate_led
	pop {LR}

	//bx LR

	//check if we need to change the water
	ldr r0, =current_water
	ldr r1, [r0]

	ldr r0, =water_amount
	ldr r2, [r0]

	cmp r1, r2
	IT LO
	bxlo LR
init_watering_animation: //animation for the lack of water
	//init for watering_animation
	ldr r0, =#0x40000024  //clear timer two counter register
	ldr r1, =#0x0
	str r1, [r0]

	ldr r0, =current_time //reset current_time counter
	ldr r1, =#0x0
	str r1, [r0]

	ldr r0, =current_water
	ldr r1, =#0x0
	str r1, [r0]

watering_animation:
	//0x48000800 -> portC base adress
	ldr r0, =#0x48000810
	ldr r1, [r0]
	and r1, r1, #0x8000
	cmp r1, #0x0 //check if ok button was pressed
	IT eq
	beq exit_watering_animation

	ldr r0, =current_time
	ldr r1, [r0]

	cmp r1, #0x1 //check timing
	IT hs
	bhs toggle_leds_watering_animation //toggle leds

	b watering_animation //loop


toggle_leds_watering_animation:
	ldr r0, =current_time //clear current time
	ldr r1, =#0x0
	str r1, [r0]

	ldr r1, =#0x48001414 //compare led0 input
	ldr r2, [r1]
	and r2, r2, #0x0004
	cmp r2, #0x0
	ldr r0, =led_counter
	ldr r1, =#0x8
	IT ne
	ldrne r1, =#0x0 //write 8 or 0 to led_counter
	str r1, [r0]

	push {LR}
	bl operate_led
	pop {lr}

	b watering_animation //go back to watering animation

exit_watering_animation:
	ldr r0, =led_counter //clear values and branch exchange
	ldr r1, =#0x0
	str r1, [r0]

	ldr r0, =current_time
	str r1, [r0]

	push {LR}
	bl operate_led
	pop {LR}
	bx LR

operate_led:

	ldr r1, =#0x48001418  //clear all leds
	ldr r2, =#0x003c0000
	str r2, [r1]

	ldr r1, =#0x48000818
	ldr r2, =#0x000F0000
	str r2, [r1]

	ldr r3, =led_counter
	ldr r0, [r3]
	cmp r0, #0x1  //check which led mode is selected
	beq led1

	cmp r0, #0x2
	beq led2

	cmp r0, #0x3
	beq led3

	cmp r0, #0x4
	beq led4

	cmp r0, #0x5
	beq led5

	cmp r0, #0x6
	beq led6

	cmp r0, #0x7
	beq led7

	cmp r0, #0x8
	beq led8

	bx r14  //if invalid value exchange back

led1:  //turn on leds
	ldr r1, =#0x48001418
	mov r2,#0x4
	str r2, [r1]
	bx r14
led2:
	ldr r1, =#0x48001418
	mov r2,#0xC
	str r2, [r1]
	bx r14
led3:
	ldr r1, =#0x48001418
	mov r2,#0x1C
	str r2, [r1]
	bx r14
led4:
	ldr r1, =#0x48001418
	mov r2,#0x3C
	str r2, [r1]
	bx r14
led5:
	ldr r1, =#0x48001418
	mov r2,#0x3C
	str r2, [r1]
	ldr r1, =#0x48000818
	mov r2,#0x1
	str r2, [r1]
	bx r14
led6:
	ldr r1, =#0x48001418
	mov r2,#0x3C
	str r2, [r1]
	ldr r1, =#0x48000818
	mov r2,#0x3
	str r2, [r1]
	bx r14
led7:
	ldr r1, =#0x48001418
	mov r2,#0x3C
	str r2, [r1]
	ldr r1, =#0x48000818
	mov r2,#0x7
	str r2, [r1]
	bx r14
led8:
	ldr r1, =#0x48001418
	mov r2,#0x3C
	str r2, [r1]
	ldr r1, =#0x48000818
	mov r2,#0xF
	str r2, [r1]
	bx r14


stop:
    b stop

_dummy:
_nmi_handler:
	b _nmi_handler
_hard_fault:
	b _hard_fault
_memory_fault:
	b _memory_fault
_bus_fault:
	b _bus_fault
_usage_fault:
    add r0, #1
    add r1, #1
    b _dummy
_tim_two_int:
	//CLEAR TIM2 UPDATE INTERRUPT FLAG
	ldr r0, =#0x0
	ldr r1, =#0x40000010  //read from TIM2 status register
	str r0, [r1]

	ldr r1, =current_time
	ldr r2, [r1]
	add r2, r2, #0x1
	str r2, [r1]
	bx LR

_exti_15_10_int:
	//CLEAR EXTI PENIDNG IRQ
	ldr r0, =#0x00004000 //clear exti interrupt on line 14
	ldr r1, =#0x40010414
	str r0, [r1]

	ldr r0, =set_interval_time_flag
	ldr r1, =#0x1 //load 1 into interval_time_flag to indicate you are setting interval_time
	str r1, [r0]

	bx LR




//led_counter: .word 0x10000000
.equ led_counter, 	0x10000000
.equ interval_time, 0x10000004
.equ current_time,	0x10000008
.equ water_amount, 0x1000000C
.equ current_water, 0x10000010
.equ set_interval_time_flag, 0x10000014

