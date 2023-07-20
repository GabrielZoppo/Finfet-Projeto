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

subckt INV IN OUT VDD GND
MP0 VDD IN OUT VDD PMOS_RVT l=20n nfin=3
MN0 GND IN OUT GND NMOS_RVT l=20n nfin=3 
ends INV


* A XOR B, com inversor interno
subckt XOR2 IN1 IN2 OUT VDD GND

INV0 (IN1 U vdd 0) INV
INV1 (IN2 V vdd 0) INV

MP3 VDD IN2 W   VDD PMOS_RVT l=20n nfin=3
MP4 W   U   OUT VDD PMOS_RVT l=20n nfin=3
MP5 VDD V   X   VDD PMOS_RVT l=20n nfin=3
MP6 X   IN1 OUT VDD PMOS_RVT l=20n nfin=3
MN3 OUT U   Y   GND NMOS_RVT l=20n nfin=3
MN4 Y   V   GND GND NMOS_RVT l=20n nfin=3
MN5 OUT IN1 Z   GND NMOS_RVT l=20n nfin=3
MN6 Z   IN2 GND GND NMOS_RVT l=20n nfin=3
ends XOR2

* Descrição do circuito

* A XOR B
R1 (a b s vdd 0) XOR2


** Tempo de simulação
tran1 tran start=0 stop=4n method=trap

