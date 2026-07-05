/*
 * Modulo principal para usar na FPGA.
 *
 * Ele conecta os sinais fisicos da placa DE1 aos dois blocos principais do
 * projeto: unidade de controle e datapath. Aqui tambem ficam os debouncers dos
 * botoes KEY, porque eles sao entradas mecanicas da placa.
 */
module genius_top (
    input CLOCK_50,
    input [3:0] KEY,
    input [9:0] SW,
    output [3:0] LEDR,
    output [7:0] LEDG,
    output [6:0] HEX0,
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3
);
    parameter TEMPO_DEBOUNCE = 250000;
    parameter CICLOS_EXIBICAO = 32'd25000000;
    parameter CICLOS_INTERVALO = 32'd20000000;
    parameter CICLOS_UM_SEGUNDO = 32'd50000000;

    wire reset;
    wire iniciar;
    wire [3:0] botoes_apertados;
    wire [3:0] pulsos_botoes;
    wire gera_simbolo;
    wire escreve_memoria;
    wire limpa_nivel;
    wire incrementa_nivel;
    wire limpa_contador_exibicao;
    wire incrementa_contador_exibicao;
    wire limpa_contador_entrada;
    wire incrementa_contador_entrada;
    wire zera_timer;
    wire conta_timer;
    wire [1:0] modo_timer;
    wire atualiza_recorde;
    wire liga_led_exibicao;
    wire usa_endereco_entrada;
    wire [3:0] estado_display;
    wire [5:0] nivel;
    wire [4:0] contador_exibicao;
    wire [4:0] contador_entrada;
    wire [1:0] simbolo_jogado;
    wire tem_botao;
    wire comparacao_ok;
    wire tempo_terminou;
    wire exibicao_finalizada;
    wire entrada_finalizada;
    wire [2:0] estado;
    wire [5:0] nivel_maximo;

    /*
     * SW1 e reset, SW0 inicia a partida.
     * SW8/SW7 escolhem a dificuldade.
     * SW9 escolhe o limite: 0 = 15 niveis, 1 = 32 niveis.
     */
    assign reset = SW[1];
    assign iniciar = SW[0];
    assign nivel_maximo = SW[9] ? 6'd32 : 6'd15;

    /* Na DE1 os botoes KEY sao ativos em zero, por isso invertemos. */
    assign botoes_apertados = ~KEY;

    /* 7.9 - Debouncer: cada botao passa por um filtro antes de chegar ao jogo. */
    debouncer #(.TEMPO_ESTAVEL(TEMPO_DEBOUNCE)) db0 (.clk(CLOCK_50), .reset(reset), .entrada_ruidosa(botoes_apertados[0]), .pulso(pulsos_botoes[0]));
    debouncer #(.TEMPO_ESTAVEL(TEMPO_DEBOUNCE)) db1 (.clk(CLOCK_50), .reset(reset), .entrada_ruidosa(botoes_apertados[1]), .pulso(pulsos_botoes[1]));
    debouncer #(.TEMPO_ESTAVEL(TEMPO_DEBOUNCE)) db2 (.clk(CLOCK_50), .reset(reset), .entrada_ruidosa(botoes_apertados[2]), .pulso(pulsos_botoes[2]));
    debouncer #(.TEMPO_ESTAVEL(TEMPO_DEBOUNCE)) db3 (.clk(CLOCK_50), .reset(reset), .entrada_ruidosa(botoes_apertados[3]), .pulso(pulsos_botoes[3]));

    /* A unidade de controle gera os sinais que comandam o datapath. */
    genius_control controle (
        .clk(CLOCK_50),
        .reset(reset),
        .iniciar(iniciar),
        .tem_botao(tem_botao),
        .comparacao_ok(comparacao_ok),
        .tempo_terminou(tempo_terminou),
        .exibicao_finalizada(exibicao_finalizada),
        .entrada_finalizada(entrada_finalizada),
        .nivel(nivel),
        .nivel_maximo(nivel_maximo),
        .gera_simbolo(gera_simbolo),
        .escreve_memoria(escreve_memoria),
        .limpa_nivel(limpa_nivel),
        .incrementa_nivel(incrementa_nivel),
        .limpa_contador_exibicao(limpa_contador_exibicao),
        .incrementa_contador_exibicao(incrementa_contador_exibicao),
        .limpa_contador_entrada(limpa_contador_entrada),
        .incrementa_contador_entrada(incrementa_contador_entrada),
        .zera_timer(zera_timer),
        .conta_timer(conta_timer),
        .modo_timer(modo_timer),
        .atualiza_recorde(atualiza_recorde),
        .liga_led_exibicao(liga_led_exibicao),
        .usa_endereco_entrada(usa_endereco_entrada),
        .estado_display(estado_display),
        .estado(estado)
    );

    /* O datapath guarda a sequencia, compara jogadas e controla saidas visuais. */
    genius_datapath #(
        .CICLOS_EXIBICAO(CICLOS_EXIBICAO),
        .CICLOS_INTERVALO(CICLOS_INTERVALO),
        .CICLOS_UM_SEGUNDO(CICLOS_UM_SEGUNDO)
    ) datapath (
        .clk(CLOCK_50),
        .reset(reset),
        .pulsos_botoes(pulsos_botoes),
        .gera_simbolo(gera_simbolo),
        .escreve_memoria(escreve_memoria),
        .limpa_nivel(limpa_nivel),
        .incrementa_nivel(incrementa_nivel),
        .limpa_contador_exibicao(limpa_contador_exibicao),
        .incrementa_contador_exibicao(incrementa_contador_exibicao),
        .limpa_contador_entrada(limpa_contador_entrada),
        .incrementa_contador_entrada(incrementa_contador_entrada),
        .zera_timer(zera_timer),
        .conta_timer(conta_timer),
        .modo_timer(modo_timer),
        .dificuldade(SW[8:7]),
        .atualiza_recorde(atualiza_recorde),
        .liga_led_exibicao(liga_led_exibicao),
        .usa_endereco_entrada(usa_endereco_entrada),
        .estado_display(estado_display),
        .nivel(nivel),
        .contador_exibicao(contador_exibicao),
        .contador_entrada(contador_entrada),
        .simbolo_jogado(simbolo_jogado),
        .tem_botao(tem_botao),
        .comparacao_ok(comparacao_ok),
        .tempo_terminou(tempo_terminou),
        .exibicao_finalizada(exibicao_finalizada),
        .entrada_finalizada(entrada_finalizada),
        .leds(LEDR),
        .leds_verdes(LEDG),
        .hex0(HEX0),
        .hex1(HEX1),
        .hex2(HEX2),
        .hex3(HEX3)
    );
endmodule
