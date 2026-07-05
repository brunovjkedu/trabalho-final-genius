/*
 * Junta os blocos que guardam e processam os dados do jogo.
 * Aqui ficam memoria, LFSR, contadores, comparador, timer, LEDs e displays.
 */
module genius_datapath (
    input clk,
    input reset,
    input [3:0] pulsos_botoes,
    input gera_simbolo,
    input escreve_memoria,
    input limpa_nivel,
    input incrementa_nivel,
    input limpa_contador_exibicao,
    input incrementa_contador_exibicao,
    input limpa_contador_entrada,
    input incrementa_contador_entrada,
    input zera_timer,
    input conta_timer,
    input [1:0] modo_timer,
    input [1:0] dificuldade,
    input atualiza_recorde,
    input liga_led_exibicao,
    input usa_endereco_entrada,
    input [3:0] estado_display,
    output [5:0] nivel,
    output [4:0] contador_exibicao,
    output [4:0] contador_entrada,
    output [1:0] simbolo_jogado,
    output tem_botao,
    output comparacao_ok,
    output tempo_terminou,
    output exibicao_finalizada,
    output entrada_finalizada,
    output [3:0] leds,
    output [7:0] leds_verdes,
    output [6:0] hex0,
    output [6:0] hex1,
    output [6:0] hex2,
    output [6:0] hex3
);
    parameter CICLOS_EXIBICAO = 32'd25000000; /* 0,5 s com clock de 50 MHz. */
    parameter CICLOS_INTERVALO = 32'd10000000; /* 0,2 s. */
    parameter CICLOS_UM_SEGUNDO = 32'd50000000; /* 1 s. */
    parameter SEGUNDOS_FACIL = 6'd60;
    parameter SEGUNDOS_NORMAL = 6'd45;
    parameter SEGUNDOS_DIFICIL = 6'd30;
    parameter SEGUNDOS_MUITO_DIFICIL = 6'd15;

    wire [1:0] simbolo_sorteado;
    wire [1:0] simbolo_esperado;
    wire [4:0] endereco_leitura;
    wire [4:0] endereco_escrita;
    wire [3:0] leds_jogo;
    wire [5:0] segundos_restantes;
    wire [5:0] recorde;
    wire [5:0] numero_display;
    wire [3:0] dezena_display;
    wire [3:0] unidade_display;
    wire [3:0] digito_nivel;
    wire mostra_recorde;
    wire mostra_segundos;
    wire [6:0] hex0_normal;
    wire [6:0] hex1_normal;
    wire [6:0] hex2_normal;
    wire gira_em_espera;

    /* A memoria pode ser lida pela exibicao ou pela entrada do jogador. */
    assign endereco_leitura = usa_endereco_entrada ? contador_entrada : contador_exibicao;

    assign endereco_escrita = (nivel == 6'd0) ? 5'd0 : (nivel[4:0] - 5'd1);

    assign exibicao_finalizada = (contador_exibicao == (nivel[4:0] - 5'd1));
    assign entrada_finalizada = (contador_entrada == (nivel[4:0] - 5'd1));

    /*
     * Durante a entrada, HEX2/HEX1 mostram o tempo restante.
     * Em ESPERANDO, VITORIA e DERROTA, mostram o recorde armazenado.
     * Durante exibicao e pausa, ficam apagados para nao confundir o jogador.
     */
    assign mostra_segundos = (estado_display == 4'd2);
    assign mostra_recorde = (estado_display == 4'd0 ||
                          estado_display == 4'd3 ||
                          estado_display == 4'd4);
    assign gira_em_espera = (estado_display == 4'd0);
    assign numero_display = mostra_segundos ? segundos_restantes :
                            mostra_recorde ? recorde :
                            6'd0;
    assign digito_nivel = (nivel >= 6'd30) ? (nivel - 6'd30) :
                         (nivel >= 6'd20) ? (nivel - 6'd20) :
                         (nivel >= 6'd10) ? (nivel - 6'd10) :
                         nivel[3:0];

    /* 7.1 - Gerador Pseudoaleatorio */
    lfsr_random lfsr_jogo (
        .clk(clk),
        .reset(reset),
        .habilita(gera_simbolo),
        .gira_em_espera(gira_em_espera),
        .simbolo_randomico(simbolo_sorteado)
    );

    /* 7.2 - Memoria da Sequencia */
    sequence_memory memoria (
        .clk(clk),
        .habilita_escrita(escreve_memoria),
        .endereco_escrita(endereco_escrita),
        .dado_escrita(simbolo_sorteado),
        .endereco_leitura(endereco_leitura),
        .dado_leitura(simbolo_esperado)
    );

    /* 7.3 - Registrador de Nivel */
    level_register registrador_nivel (
        .clk(clk),
        .reset(reset),
        .limpar(limpa_nivel),
        .incrementar(incrementa_nivel),
        .nivel(nivel)
    );

    /* 7.4 - Contador de Exibicao */
    counter4 contador_exibicao_inst (
        .clk(clk),
        .reset(reset),
        .limpar(limpa_contador_exibicao),
        .incrementar(incrementa_contador_exibicao),
        .contador(contador_exibicao)
    );

    /* 7.5 - Contador de Entrada */
    counter4 contador_entrada_inst (
        .clk(clk),
        .reset(reset),
        .limpar(limpa_contador_entrada),
        .incrementar(incrementa_contador_entrada),
        .contador(contador_entrada)
    );

    button_decoder decodificador (
        .pulsos(pulsos_botoes),
        .tem_botao(tem_botao),
        .simbolo(simbolo_jogado)
    );

    /* 7.6 - Comparador de Sequencia */
    sequence_compare comparador (
        .simbolo_esperado(simbolo_esperado),
        .simbolo_jogado(simbolo_jogado),
        .resultado_comparacao(comparacao_ok)
    );

    /* 7.7 - Temporizador */
    timer #(
        .CICLOS_EXIBICAO(CICLOS_EXIBICAO),
        .CICLOS_INTERVALO(CICLOS_INTERVALO),
        .CICLOS_UM_SEGUNDO(CICLOS_UM_SEGUNDO),
        .SEGUNDOS_FACIL(SEGUNDOS_FACIL),
        .SEGUNDOS_NORMAL(SEGUNDOS_NORMAL),
        .SEGUNDOS_DIFICIL(SEGUNDOS_DIFICIL),
        .SEGUNDOS_MUITO_DIFICIL(SEGUNDOS_MUITO_DIFICIL)
    ) timer_jogo (
        .clk(clk),
        .reset(reset),
        .limpar(zera_timer),
        .habilita(conta_timer),
        .modo(modo_timer),
        .dificuldade(dificuldade),
        .terminou(tempo_terminou),
        .segundos_restantes(segundos_restantes)
    );

    record_register registrador_recorde (
        .clk(clk),
        .reset(reset),
        .atualizar(atualiza_recorde),
        .nivel(nivel),
        .recorde(recorde)
    );

    decimal_digits conversor_decimal (
        .valor(numero_display),
        .dezena(dezena_display),
        .unidade(unidade_display)
    );

    led_driver driver_leds (
        .habilita(liga_led_exibicao),
        .simbolo(simbolo_esperado),
        .leds(leds_jogo)
    );

    /* 7.8 - Decodificador para Display de Sete Segmentos */
    seven_segment display_nivel (
        .valor(digito_nivel),
        .segmentos(hex0_normal)
    );

    seven_segment display_unidade (
        .valor(unidade_display),
        .segmentos(hex1_normal)
    );

    seven_segment display_dezena (
        .valor(dezena_display),
        .segmentos(hex2_normal)
    );

    animation_driver animacoes (
        .clk(clk),
        .reset(reset),
        .estado_display(estado_display),
        .leds_jogo(leds_jogo),
        .hex0_normal(hex0_normal),
        .hex1_normal((mostra_segundos || mostra_recorde) ? hex1_normal : 7'b1111111),
        .hex2_normal((mostra_segundos || mostra_recorde) ? hex2_normal : 7'b1111111),
        .leds(leds),
        .leds_verdes(leds_verdes),
        .hex0(hex0),
        .hex1(hex1),
        .hex2(hex2)
    );

    seven_segment display_estado (
        .valor(estado_display),
        .segmentos(hex3)
    );
endmodule
