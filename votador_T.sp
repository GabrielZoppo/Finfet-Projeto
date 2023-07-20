** Votador Majoritario Com Mux

** Importação da tecnologia
.include "7nm_TT.pm"

** Visualização de curvas
.option post=2

** Tensão de alimentação
.param vdd = 0.7

** Declaração das fontes
Vvdd vdd gnd vdd
Vgnd gnd gnd 0

** Declaração das ondas de entrada
Va  A 0 pulse(0 5 4n 0 0 4n 8n)
Vb  B 0 pulse(0 5 2n 0 0 2n 4n)
Vc  C 0 pulse(0 5 1n 0 0 1n 2n)

.SUBCKT INV in out vdd gnd
M9  vdd in out vdd PMOS_RVT L=2e-08 NFIN=3
M10 gnd in out gnd NMOS_RVT L=2e-08 NFIN=3 
.ENDS INV

.SUBCKT NAND2 in1 in2 out vdd gnd
M1 vdd  in1 out vdd PMOS_RVT L=2e-08 NFIN=3
M2 vdd  in2 out vdd PMOS_RVT L=2e-08 NFIN=3
M3 out  in2 2   gnd NMOS_RVT L=2e-08 NFIN=3
M4 2    in1 gnd gnd NMOS_RVT L=2e-08 NFIN=3
.ENDS NAND2

.SUBCKT NOR2 in1 in2 out vdd gnd
M1 vdd  in2  2    vdd PMOS_RVT L=2e-08 NFIN=3
M2 2    in1  out  vdd PMOS_RVT L=2e-08 NFIN=3
M3 out  in1  gnd  gnd NMOS_RVT L=2e-08 NFIN=3
M4 out  in2  gnd  gnd NMOS_RVT L=2e-08 NFIN=3
.ENDS NOR2

.SUBCKT AND2 in1 in2 out vdd gnd
X2 in1  in2 nout vdd gnd NAND2
X1 nout out      vdd gnd INV
.ENDS AND2


** Descrição do circuito
.subckt Votador_Majoritario_Com_Mux A B C OUT VDD GND
** X = ~[(~A*~B) + (A*B)]
X1 A           Inv_A VDD GND INV
X2 B           Inv_B VDD GND INV
X3 Inv_A Inv_B A1    VDD GND AND2
X4 A     B     A2    VDD GND AND2
X5 A1    A2    X     VDD GND NOR2

** inversor Y = ~X
X6 X          Y      VDD GND INV

** Z1 =  ~[A*Y]
X7 A     Y     Z1    VDD GND NAND2

** Z2 = ~[C*X]
X8 C    X     Z2     VDD GND NAND2

** S = ~[Z1*Z2]
X9 Z1    Z2    S     VDD GND NAND2

.ENDS

** Chamada do circuito

X10 A B C OUT VDD GND Votador_Majoritario_Com_Mux

** Simulação do circuito
.tran 1p 18n
.end