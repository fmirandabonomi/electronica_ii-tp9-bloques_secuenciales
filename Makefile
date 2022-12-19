ifeq ($(suffix $(SHELL)),.exe)
	rm = del
else
	rm = rm
endif

all : ffd johnson contador sipo det_flanco det_tiempo
entrega : all entrega-tp9.tar.gz
corregir : descomprimir all
	ghdl synth --std=08 -gN=4 ffd 
	ghdl synth --std=08 -gN=4 johnson
	ghdl synth --std=08 -gN=4 contador
	ghdl synth --std=08 -gN=4 sipo
	ghdl synth --std=08 det_flanco 
	ghdl synth --std=08 -gN=4 det_tiempo

descomprimir :
	tar -zxf entrega-tp9.tar.gz

ffd : work-obj08.cf
	ghdl -m --std=08 ffd_tb
	ghdl -r --std=08 ffd_tb
johnson : work-obj08.cf
	ghdl -m --std=08 johnson_tb
	ghdl -r --std=08 johnson_tb
contador : work-obj08.cf
	ghdl -m --std=08 contador_tb
	ghdl -r --std=08 contador_tb
det_flanco : work-obj08.cf
	ghdl -m --std=08 det_flanco_tb
	ghdl -r --std=08 det_flanco_tb
det_tiempo : work-obj08.cf
	ghdl -m --std=08 det_tiempo_tb
	ghdl -r --std=08 det_tiempo_tb
sipo : work-obj08.cf
	ghdl -m --std=08 sipo_tb
	ghdl -r --std=08 sipo_tb

wav-ffd : ffd.ghw
	gtkwave -f ffd.ghw
wav-johnson : johnson.ghw
	gtkwave -f johnson.ghw
wav-contador : contador.ghw
	gtkwave -f contador.ghw
wav-sipo : sipo.ghw
	gtkwave -f sipo.ghw
wav-det_flanco : det_flanco.ghw
	gtkwave -f det_flanco.ghw
wav-det_tiempo : det_tiempo.ghw
	gtkwave -f det_tiempo.ghw

ffd.ghw :  work-obj08.cf
	ghdl -m --std=08 ffd_tb
	ghdl -r --std=08 ffd_tb --assert-level=none --wave=ffd.ghw
johnson.ghw : work-obj08.cf
	ghdl -m --std=08 johnson_tb
	ghdl -r --std=08 johnson_tb --assert-level=none --wave=johnson.ghw
contador.ghw : work-obj08.cf
	ghdl -m --std=08 contador_tb
	ghdl -r --std=08 contador_tb --assert-level=none --wave=contador.ghw
sipo.ghw : work-obj08.cf
	ghdl -m --std=08 sipo_tb
	ghdl -r --std=08 sipo_tb --assert-level=none --wave=sipo.ghw
det_flanco.ghw : work-obj08.cf
	ghdl -m --std=08 det_flanco_tb
	ghdl -r --std=08 det_flanco_tb --assert-level=none --wave=det_flanco.ghw
det_tiempo.ghw : work-obj08.cf
	ghdl -m --std=08 det_tiempo_tb
	ghdl -r --std=08 det_tiempo_tb --assert-level=none --wave=det_tiempo.ghw

work-obj08.cf: *.vhd
	ghdl -i --std=08 *.vhd
entrega-tp9.tar.gz : ffd.vhd johnson.vhd contador.vhd sipo.vhd det_flanco.vhd det_tiempo.vhd
	tar -czf entrega-tp9.tar.gz ffd.vhd johnson.vhd contador.vhd sipo.vhd det_flanco.vhd det_tiempo.vhd
clean:
	ghdl clean
	$(rm) work-obj08.cf entrega-tp9.tar.gz *.ghw