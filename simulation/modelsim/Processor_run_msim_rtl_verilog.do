transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/Knight/Desktop/Processor {C:/Users/Knight/Desktop/Processor/ALU.v}
vlog -vlog01compat -work work +incdir+C:/Users/Knight/Desktop/Processor {C:/Users/Knight/Desktop/Processor/BRIDGE.v}
vlog -vlog01compat -work work +incdir+C:/Users/Knight/Desktop/Processor {C:/Users/Knight/Desktop/Processor/CONTROL_UNIT.v}
vlog -vlog01compat -work work +incdir+C:/Users/Knight/Desktop/Processor {C:/Users/Knight/Desktop/Processor/CPU.v}
vlog -vlog01compat -work work +incdir+C:/Users/Knight/Desktop/Processor {C:/Users/Knight/Desktop/Processor/MUX_FOR_BUS_B.v}
vlog -vlog01compat -work work +incdir+C:/Users/Knight/Desktop/Processor {C:/Users/Knight/Desktop/Processor/PROCESSOR.v}
vlog -vlog01compat -work work +incdir+C:/Users/Knight/Desktop/Processor {C:/Users/Knight/Desktop/Processor/REGISTER.v}
vlog -vlog01compat -work work +incdir+C:/Users/Knight/Desktop/Processor {C:/Users/Knight/Desktop/Processor/UART_MODULE.v}
vlog -vlog01compat -work work +incdir+C:/Users/Knight/Desktop/Processor {C:/Users/Knight/Desktop/Processor/WHERE_SHOULD_DATA_GO.v}
vlog -vlog01compat -work work +incdir+C:/Users/Knight/Desktop/Processor {C:/Users/Knight/Desktop/Processor/INSTRUCTION_ROM.v}
vlog -vlog01compat -work work +incdir+C:/Users/Knight/Desktop/Processor {C:/Users/Knight/Desktop/Processor/RAM.v}
