#!/bin/zsh

ghdl -a --std=08 mux_line_selector.vhd mux_nx2.vhd jk_flip_flop.vhd shift_register.vhd binary_up_counter.vhd ps2_fsm.vhd ps2.vhd ps2_tb.vhd
ghdl -e --std=08 ps2_tb
ghdl -r --std=08 ps2_tb --stop-time=25ms --fst=sim.fst
