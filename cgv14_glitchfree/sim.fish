#!/bin/fish
fish_add_path /home/bgigerl/Applications/verilator/bin
fish_add_path /home/bgigerl/Applications/verilator/include


verilator -Wno-UNOPTFLAT \
  -I/home/bgigerl/Applications/verilator/include/ \
  --cc --trace --exe --build -Wall \
  tb.cpp rtl/cgv14.v rtl/SecAdd.v rtl/SecAnd.v

