/*
 * Testbench dos principais casos pedidos no enunciado.
 *
 * Os tempos do timer sao reduzidos para a simulacao rodar rapido.
 * Aqui os pulsos dos botoes sao aplicados diretamente, sem passar pelo
 * debouncer, porque o objetivo e testar a logica do jogo.
 */
module tb_genius_all_cases;
    reg clk;
    reg reset;
    reg iniciar;
    reg [3:0] pulsos_botoes;

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
    wire [3:0] leds;
    wire [7:0] leds_verdes;
    wire [6:0] hex0;
    wire [6:0] hex1;
    wire [6:0] hex2;
    wire [6:0] hex3;
    wire [2:0] estado;

    integer erros;
    integer indice;
    integer numero_rodada;

    parameter ESPERANDO = 3'd0;
    parameter ADICIONA_SIMBOLO = 3'd1;
    parameter MOSTRA_LED = 3'd2;
    parameter APAGA_LED = 3'd3;
    parameter ESPERA_ENTRADA = 3'd4;
    parameter VITORIA = 3'd5;
    parameter DERROTA = 3'd6;

    genius_control controle (
        .clk(clk),
        .reset(reset),
        .iniciar(iniciar),
        .tem_botao(tem_botao),
        .comparacao_ok(comparacao_ok),
        .tempo_terminou(tempo_terminou),
        .exibicao_finalizada(exibicao_finalizada),
        .entrada_finalizada(entrada_finalizada),
        .nivel(nivel),
        .nivel_maximo(6'd32),
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

    genius_datapath #(
        .CICLOS_EXIBICAO(3),
        .CICLOS_INTERVALO(2),
        .CICLOS_UM_SEGUNDO(3),
        .SEGUNDOS_FACIL(6'd60),
        .SEGUNDOS_NORMAL(6'd45),
        .SEGUNDOS_DIFICIL(6'd30),
        .SEGUNDOS_MUITO_DIFICIL(6'd15)
    ) datapath (
        .clk(clk),
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
        .dificuldade(2'b00),
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
        .leds(leds),
        .leds_verdes(leds_verdes),
        .hex0(hex0),
        .hex1(hex1),
        .hex2(hex2),
        .hex3(hex3)
    );

    initial begin
        clk = 1'b0;
        /* Clock apenas para simulacao. Este delay nao vai para a FPGA. */
        forever #5 clk = ~clk;
    end

    task resetar_jogo;
        begin
            /* Coloca o circuito em um estado conhecido antes de cada caso. */
            reset = 1'b1;
            iniciar = 1'b0;
            pulsos_botoes = 4'b0000;
            repeat (3) @(posedge clk);
            reset = 1'b0;
            repeat (2) @(posedge clk);
        end
    endtask

    task apertar_simbolo;
        input [1:0] simbolo;
        begin
            /* Gera um pulso de um ciclo no botao correspondente ao simbolo. */
            @(negedge clk);
            pulsos_botoes = 4'b0001 << simbolo;
            @(negedge clk);
            pulsos_botoes = 4'b0000;
            repeat (2) @(posedge clk);
        end
    endtask

    task esperar_estado_entrada;
        begin
            /* Espera a FSM terminar a exibicao e liberar a entrada. */
            while (estado != ESPERA_ENTRADA) begin
                @(posedge clk);
            end
            @(posedge clk);
        end
    endtask

    task jogar_rodada_atual;
        begin
            esperar_estado_entrada;
            /* Reproduz a sequencia correta lendo a memoria interna do datapath. */
            for (indice = 0; indice < nivel; indice = indice + 1) begin
                apertar_simbolo(datapath.memoria.memoria[indice]);
            end
        end
    endtask

    task verificar_estado;
        input [2:0] esperado;
        input [120:0] mensagem;
        begin
            if (estado != esperado) begin
                erros = erros + 1;
                $display("ERRO: %s", mensagem);
            end else begin
                $display("OK: %s", mensagem);
            end
        end
    endtask

    initial begin
        erros = 0;

        /* Caso 1 do enunciado. */
        $display("Caso 1: jogador completa tres rodadas consecutivas");
        resetar_jogo;
        iniciar = 1'b1;
        jogar_rodada_atual;
        jogar_rodada_atual;
        jogar_rodada_atual;
        repeat (3) @(posedge clk);
        if (estado == DERROTA) begin
            erros = erros + 1;
            $display("ERRO: jogador perdeu durante as tres rodadas corretas");
        end else if (nivel < 6'd4) begin
            erros = erros + 1;
            $display("ERRO: nivel nao avancou apos tres rodadas");
        end else begin
            $display("OK: tres rodadas corretas foram aceitas");
        end

        /* Caso 2 do enunciado. */
        $display("Caso 2: jogador vence a partida");
        resetar_jogo;
        iniciar = 1'b1;
        for (numero_rodada = 1; numero_rodada <= 32; numero_rodada = numero_rodada + 1) begin
            jogar_rodada_atual;
        end
        repeat (3) @(posedge clk);
        verificar_estado(VITORIA, "estado final deve ser VITORIA");

        /* Caso 3 do enunciado. */
        $display("Caso 3: reset durante a execucao");
        resetar_jogo;
        iniciar = 1'b1;
        while (estado != MOSTRA_LED) begin
            @(posedge clk);
        end
        reset = 1'b1;
        iniciar = 1'b0;
        repeat (2) @(posedge clk);
        reset = 1'b0;
        repeat (2) @(posedge clk);
        verificar_estado(ESPERANDO, "reset deve retornar para ESPERANDO");

        /* Caso 4 do enunciado. */
        $display("Caso 4: timeout da entrada do jogador");
        resetar_jogo;
        iniciar = 1'b1;
        esperar_estado_entrada;
        while (estado != DERROTA) begin
            @(posedge clk);
        end
        verificar_estado(DERROTA, "timeout deve levar para DERROTA");

        if (erros == 0) begin
            $display("Todos os casos passaram.");
        end else begin
            $display("Total de erros: %0d", erros);
        end

        $finish;
    end
endmodule
