** Votador Majoritario Com Mux - Spectre

* Configurações iniciais
simulator lang=spectre
name options save=all

* Importação da tecnologia
include "7nm_TT.pm"

* Declaração das variáveis
parameters vcc=0.7
global 0

* Variação da Temperatura
change alter param=temp value=75

* Declaração das fontes
V0 (vdd 0) vsource dc=vcc type=dc

* Declaração das ondas de entrada (VALIDAÇÃO)
V1 (a 0) vsource type=pwl wave=[0 0 4n 0 4.01n vcc 5n vcc 5.01n 0 10n 0 10.01n vcc 11n vcc 11.01n 0 12n 0 12.01n vcc]
V2 (b 0) vsource type=pwl wave=[0 0 1n 0 1.01n vcc 2n vcc 2.01n 0 6n 0 6.01n vcc 12n vcc 12.01n 0 16n 0 16.01n vcc 17n vcc 17.01n 0]
V3 (c 0) vsource type=pwl wave=[0 vcc 6n vcc 6.01n 0 7n 0 7.01n vcc 8n vcc 8.01n 0 13n 0 13.01n vcc 14n vcc 14.01n 0]

subckt INV IN OUT VDD GND
MP0 VDD IN OUT VDD PMOS_RVT l=20n nfin=3
MN0 GND IN OUT GND NMOS_RVT l=20n nfin=3 
ends INV

subckt NAND2 IN1 IN2 OUT VDD GND
MP1 VDD  IN1 OUT VDD PMOS_RVT l=20n nfin=3
MP2 VDD  IN2 OUT VDD PMOS_RVT l=20n nfin=3
MN1 OUT  IN2 X   GND NMOS_RVT l=20n nfin=3
MN2 X    IN1 GND GND NMOS_RVT l=20n nfin=3
ends NAND2

* A XOR B, 4 entradas prevendo ~A e ~B
subckt XOR2 IN1 IN2 IN3 IN4 OUT VDD GND

MP3 VDD IN1 W   VDD PMOS_RVT l=20n nfin=3
MP4 W   IN4 OUT VDD PMOS_RVT l=20n nfin=3
MP5 VDD IN3 X   VDD PMOS_RVT l=20n nfin=3
MP6 X   IN2 OUT VDD PMOS_RVT l=20n nfin=3
MN3 OUT IN1 Y   GND NMOS_RVT l=20n nfin=3
MN4 Y   IN2 GND GND NMOS_RVT l=20n nfin=3
MN5 OUT IN3 Z   GND NMOS_RVT l=20n nfin=3
MN6 Z   IN4 GND GND NMOS_RVT l=20n nfin=3
ends XOR2

* Circuito
subckt VOTADOR IN1 IN2 IN3 OUT VDD GND
* I = ~A, J = ~B

R0 (IN1 I VDD GND) INV

R1 (IN2 J VDD GND) INV

* A XOR B
R2 (IN1 IN2 I J K VDD GND) XOR2

* inversor L = ~K
R3 (K L VDD GND) INV

* M =  ~[A*L]
R4 (IN1 L M VDD GND) NAND2

* N = ~[C*K]
R5 (IN3 K N VDD GND) NAND2

* OUT = ~[M*N]
R6 (M N OUT VDD GND) NAND2

ends VOTADOR

* Chamada do Circuito
R7 (a b c s vdd 0) VOTADOR

* Tempo de simulação
tran1 tran start=0 stop=18n method=trap

* Medidação do atraso
simulator lang=spice
.measure TRAN pd_lh_b1 TRIG v(b) VAL=0.35 RISE=1 TARG v(s) VAL=0.35 RISE=1
.measure TRAN pd_hl_b1 TRIG v(b) VAL=0.35 FALL=1 TARG v(s) VAL=0.35 FALL=1

.measure TRAN pd_lh_a1 TRIG v(a) VAL=0.35 RISE=1 TARG v(s) VAL=0.35 RISE=2
.measure TRAN pd_hl_a1 TRIG v(a) VAL=0.35 FALL=1 TARG v(s) VAL=0.35 FALL=2

.measure TRAN pd_lh_c1 TRIG v(c) VAL=0.35 RISE=1 TARG v(s) VAL=0.35 RISE=3
.measure TRAN pd_hl_c1 TRIG v(c) VAL=0.35 FALL=2 TARG v(s) VAL=0.35 FALL=3

.measure TRAN pd_hl_a2 TRIG v(a) VAL=0.35 RISE=2 TARG v(s) VAL=0.35 RISE=4
.measure TRAN pd_lh_a2 TRIG v(a) VAL=0.35 FALL=2 TARG v(s) VAL=0.35 FALL=4

.measure TRAN pd_hl_c2 TRIG v(c) VAL=0.35 RISE=2 TARG v(s) VAL=0.35 RISE=5
.measure TRAN pd_lh_c2 TRIG v(c) VAL=0.35 FALL=3 TARG v(s) VAL=0.35 FALL=5

.measure TRAN pd_hl_b2 TRIG v(b) VAL=0.35 RISE=3 TARG v(s) VAL=0.35 RISE=6
.measure TRAN pd_lh_b2 TRIG v(b) VAL=0.35 FALL=3 TARG v(s) VAL=0.35 FALL=6

* Medição de consumo
.measure tran potencia_VOTADOR avg P(V0) from=0.01n to=18n
