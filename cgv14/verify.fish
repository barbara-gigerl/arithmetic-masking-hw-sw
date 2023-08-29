#!/bin/fish

set VERILATOR_DIR /home/bgigerl/Applications/verilator/include
set VERILATOR_BIN /home/bgigerl/Applications/verilator/bin/verilator
set YOSYS_DIR /home/bgigerl/Applications/yosys/
set ALMA_HOME /home/bgigerl/rebecca-light-for-risc-v-software-masking/alma

set SRC_DIR rtl
set BUILD_DIR build



function labelBit
  # Arguments:
  # 1 = signal name
  # 2 = bit pos
  # 3 = label
  set signal_name $argv[1]
  set bit_pos $argv[2]
  set label_val $argv[3]

  sed -i "/^"$signal_name"\:"$bit_pos":/ s/unimportant/"$label_val"/g" $BUILD_DIR/labels_new.txt

  if [ $status != 0 ]
      echo "Error"
      exit -1
  end
end 


if [ $argv[1] = "parse" ]

  if not test -d $BUILD_DIR
    rm -rf $BUILD_DIR
  end
  mkdir $BUILD_DIR

  verilator -Wno-UNOPTFLAT --lint-only $SRC_DIR/cgv14.v $SRC_DIR/SecAdd.v $SRC_DIR/SecAnd.v --top cgv14
  if [ $status != 0 ]
      echo "ERROR verilator sytax check."
      exit -1
  else
      echo "SUCCESSFUL verilation"
  end

  echo "Running Yosys synth..."

  $YOSYS_DIR/yosys -l $BUILD_DIR/yosys_synth_log.txt synth.ys > /dev/null
  if [ $status != 0 ]
      echo "ERROR yosys synthesis."
      exit -1
  end

  echo "Creating graphs..."
  python3 $ALMA_HOME/createGraphs.py --top-module cgv14 --working-dir $BUILD_DIR

  if [ $status != 0 ]
      echo "ERROR creating graphs."
      exit -1
  end

else if [ $argv[1] = "trace" ]
  echo "Running trace using Verilator..."
  $VERILATOR_BIN -Wall -Mdir $BUILD_DIR/obj_dir --unroll-count 100000 --unroll-stmts 100000  --top-module cgv14 --trace-max-width 4096  --trace-max-array 4096 --trace --trace-underscore -Wno-UNOPTFLAT -Wno-EOFNEWLINE -Wno-DECLFILENAME -Wno-UNUSED --timescale 1ns -cc -I$SRC_DIR $BUILD_DIR/circuit.v
  
  if [ $status != 0 ]
      echo "Error verilating"
      exit -1
  end

  cd build/obj_dir;make -f Vcgv14.mk;cd ..; cd ..;
  if [ $status != 0 ]
      echo "Error"
      exit -1
  end

  g++ -I$BUILD_DIR/obj_dir -I$VERILATOR_DIR -I$VERILATOR_DIR/vltstd tb_verification.cpp $BUILD_DIR/obj_dir/Vcgv14__ALL.a $VERILATOR_DIR/verilated.cpp $VERILATOR_DIR/verilated_vcd_c.cpp $VERILATOR_DIR/verilated_threads.cpp -o $BUILD_DIR/cgv14

  echo "Successfully built testbench."
  
  $BUILD_DIR/cgv14

else if [ $argv[1] = "verify" ]

  echo "Labeling"                         
  cp $BUILD_DIR/labels.txt $BUILD_DIR/labels_new.txt
  sed -i "s/$timescale 1ps/$timescale 1ns/g" $BUILD_DIR/circuit.vcd

  for bitnum in (seq 0 15)
      labelBit "A0_i" $bitnum "share "$bitnum
      labelBit "A1_i" $bitnum "share "$bitnum
      labelBit "R0_i" $bitnum  "mask"
      labelBit "R1_i" $bitnum "mask"
      labelBit "Rxy_i" $bitnum "mask"
      labelBit "Rxc_i" $bitnum "mask"
      labelBit "Ryc_i" $bitnum "mask"
  end 
  
  set order 1
  
  
  python3 -u $ALMA_HOME/verify.py --safe-graph $BUILD_DIR/safe_graph --circuit-graph $BUILD_DIR/circuit_graph --label $BUILD_DIR/labels_new.txt --vcd $BUILD_DIR/circuit.vcd --cycles 5 --order $order --mode transient --masking-type boolean  --dbg-output-dir $BUILD_DIR --rst-name rst_i --rst-cycles 6 --rst-phase 1  --debug-config default.conf > $BUILD_DIR/log.txt


  if [ $status -eq 255 ]
      zenity --info --text "ERROR"
      python3 /home/bgigerl/coco-cores/parse_dbg_label_trace.py --dbg-labels-initial $BUILD_DIR/dbg-labels-initial --dbg-cycle-labels $BUILD_DIR/dbg-labels --pdf-path $BUILD_DIR/dbg --dbg-leaks $BUILD_DIR/dbg-leaks
      evince $BUILD_DIR/dbg.pdf &
  else
      zenity --info --text "SUCCESS"
  end
end