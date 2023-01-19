AST=188.244.90.2
Alisys=154.62.228.6
Blocknitive=185.170.96.121
COUNCILBOX=52.232.74.132
DigitelTS=176.34.235.103
IN2=15.236.56.133
Izertis=54.77.43.225
SERES=141.144.251.87
Kunfud=109.234.71.8
Indra=20.107.215.166

IzertisBOT=54.72.163.31
PlanisysBOT=185.180.8.154
SeresBOT=141.144.224.216
DigitelTSBOT=54.228.169.138


set -v

# Testing VALIDATORS

nc -zvw5 $AST 21000
nc -zvw5 $Alisys 21000
nc -zvw5 $Blocknitive 21000
nc -zvw5 $COUNCILBOX 21000
nc -zvw5 $DigitelTS 21000
nc -zvw5 $IN2 21000
nc -zvw5 $Izertis 21000
nc -zvw5 $SERES 21000
nc -zvw5 $Kunfud 21000
nc -zvw5 $Indra 21000

# Testing BOOT nodes

nc -zvw5 $IzertisBOT 21000
nc -zvw5 $PlanisysBOT 21000
nc -zvw5 $SeresBOT 21000
nc -zvw5 $DigitelTSBOT 21000
