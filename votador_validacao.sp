** Votador Majoritario Com Mux - Spectre

* Configurações iniciais
simulator lang=spectre
name options save=all

* Importação da tecnologia
include "7nm_TT.pm"

* Declaração das variáveis
parameters vcc=0.7
global 0

* Declaração das fontes
V0 (vdd 0) vsource dc=vcc type=dc

* Declaração das ondas de entrada (VALIDAÇÃO)
V1 (a 0) vsource type=pulse val0=0 val1=vcc delay=0 rise=0.01n fall=0.01n width=1n period=2n
V2 (b 0) vsource type=pulse val0=0 val1=vcc delay=0 rise=0.01n fall=0.01n width=2n period=4n
V3 (c 0) vsource type=pulse val0=0 val1=vcc delay=0 rise=0.01n fall=0.01n width=4n period=8n

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
tran1 tran start=0 stop=8n method=trap
