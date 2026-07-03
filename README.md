# Projeto Final - Genius em Verilog

Este projeto implementa o jogo Genius para FPGA Cyclone II / placa DE1.

## Pastas

- `src/`: modulos sintetizaveis em Verilog.
- `tb/`: testbench para ModelSim.
- `quartus/`: espaco para arquivos do Quartus, como projeto e pinagem.

## Modulo principal

Use `src/genius_top.v` como top-level entity no Quartus.

Entradas e saidas principais:

- `CLOCK_50`: clock de 50 MHz.
- `KEY[3:0]`: botoes das jogadas 0 a 3. Na placa DE1 os botoes sao ativos em zero, por isso o top inverte os sinais.
- `SW[0]`: iniciar partida.
- `SW[1]`: reset.
- `SW[8:7]`: dificuldade.
- `SW[9]`: limite de niveis (`0` para 15, `1` para 32).
- `LEDR[3:0]`: LEDs dos quatro simbolos.
- `LEDG[7:0]`: animacao de vitoria.
- `HEX0`: nivel atual.
- `HEX1` e `HEX2`: tempo restante durante a entrada; recorde em IDLE/VITORIA/DERROTA.
- `HEX3`: estado atual.

## Estados exibidos no HEX3

- `0`: IDLE
- `1`: EXIBICAO
- `2`: ENTRADA
- `3`: VITORIA
- `4`: DERROTA

## Bonificacoes implementadas

- Tempo restante no HEX2/HEX1 durante a entrada do jogador.
- Quatro dificuldades em SW8/SW7:
  - `00`: 60 segundos
  - `01`: 45 segundos
  - `10`: 30 segundos
  - `11`: 15 segundos
- Animacao de vitoria nos LEDs verdes; animacao de derrota nos LEDs vermelhos.
- Recorde em registrador, mostrado em HEX2/HEX1 no IDLE e no fim da partida.
- Sequencia aumentada para ate 32 niveis, com seletor em SW9.

## Observacao sobre os diagramas parciais

Os diagramas estao coerentes com a ideia geral do trabalho. No codigo, a FSM usa estados internos extras (`ADD_SYMBOL`, `SHOW_ON` e `SHOW_OFF`) para facilitar a implementacao. Para o relatorio, eles podem ser apresentados como partes do estado maior `EXIBICAO`.

No datapath, a implementacao usa endereco de leitura separado para exibicao e entrada. Isso deixa claro quando a memoria esta sendo lida para mostrar LEDs e quando esta sendo lida para comparar a jogada do usuario.

## Simulacao no ModelSim

Compile todos os arquivos de `src/` e depois o arquivo:

`tb/tb_genius_all_cases.v`

O arquivo `sim_files.f` lista os arquivos em ordem de compilacao.

O testbench cobre:

1. jogador completa tres rodadas consecutivas;
2. jogador vence a partida;
3. reset durante a execucao;
4. timeout da entrada do jogador.

Os tempos do testbench sao reduzidos para a simulacao terminar rapido. No top-level da FPGA, os valores padrao usam o clock de 50 MHz.

## Quartus

No Quartus, siga o fluxo do tutorial do professor:

1. Crie um novo projeto.
2. Escolha a familia `Cyclone II`.
3. Escolha o dispositivo `EP2C20F484C7`.
4. Use `genius_top` como top-level entity.
5. Adicione os arquivos Verilog da pasta `src/`.
6. Importe a pinagem oficial em `Assignments > Import Assignments...`.

`quartus/DE1_pin_assignments.csv`
