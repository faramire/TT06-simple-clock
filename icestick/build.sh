 
yosys -p "synth_ice40 -blif stopwatch.blif" tb_icestick.v

arachne-pnr -d 1k -p icestick.pcf stopwatch.blif -o stopwatch.txt

icepack stopwatch.txt stopwatch.bin

iceprog  stopwatch.bin
