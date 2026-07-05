/*
 * Unidade de controle do jogo Genius.
 *
 * Esta FSM decide em qual parte do jogo estamos e gera os sinais de controle
 * para o datapath: escrever na memoria, incrementar contadores, ligar timer,
 * habilitar LEDs e mudar o nivel.
 */
module genius_control (
    input clk,
    input reset,
    input iniciar,
    input tem_botao,
    input comparacao_ok,
    input tempo_terminou,
    input exibicao_finalizada,
    input entrada_finalizada,
    input [5:0] nivel,
    input [5:0] nivel_maximo,
    output reg gera_simbolo,
    output reg escreve_memoria,
    output reg limpa_nivel,
    output reg incrementa_nivel,
    output reg limpa_contador_exibicao,
    output reg incrementa_contador_exibicao,
    output reg limpa_contador_entrada,
    output reg incrementa_contador_entrada,
    output reg zera_timer,
    output reg conta_timer,
    output reg [1:0] modo_timer,
    output reg atualiza_recorde,
    output reg liga_led_exibicao,
    output reg usa_endereco_entrada,
    output reg [3:0] estado_display,
    output reg [2:0] estado
);
    parameter ESPERANDO = 3'd0;
    parameter ADICIONA_SIMBOLO = 3'd1;
    parameter MOSTRA_LED = 3'd2;
    parameter APAGA_LED = 3'd3;
    parameter ESPERA_ENTRADA = 3'd4;
    parameter VITORIA = 3'd5;
    parameter DERROTA = 3'd6;
    parameter PAUSA_RODADA = 3'd7;

    reg [2:0] proximo_estado;

    /* Logica combinacional da proxima transicao de estado. */
    always @(*) begin
        proximo_estado = estado;

        case (estado)
            ESPERANDO: begin
                if (iniciar) begin
                    /* SW0 inicia uma nova partida. */
                    proximo_estado = ADICIONA_SIMBOLO;
                end
            end
            ADICIONA_SIMBOLO: begin
                /* Grava o novo simbolo e depois passa para exibicao. */
                proximo_estado = MOSTRA_LED;
            end
            MOSTRA_LED: begin
                if (tempo_terminou) begin
                    proximo_estado = APAGA_LED;
                end
            end
            APAGA_LED: begin
                if (tempo_terminou && exibicao_finalizada) begin
                    proximo_estado = ESPERA_ENTRADA;
                end else if (tempo_terminou) begin
                    proximo_estado = MOSTRA_LED;
                end
            end
            ESPERA_ENTRADA: begin
                if (tempo_terminou) begin
                    /* Acabou o tempo de resposta do jogador. */
                    proximo_estado = DERROTA;
                end else if (tem_botao && !comparacao_ok) begin
                    /* Jogador apertou um botao diferente do esperado. */
                    proximo_estado = DERROTA;
                end else if (tem_botao && comparacao_ok && entrada_finalizada && nivel == nivel_maximo) begin
                    /* Ultimo nivel completado. */
                    proximo_estado = VITORIA;
                end else if (tem_botao && comparacao_ok && entrada_finalizada) begin
                    /* Rodada correta: faz uma pequena pausa antes da proxima. */
                    proximo_estado = PAUSA_RODADA;
                end
            end
            PAUSA_RODADA: begin
                if (tempo_terminou) begin
                    proximo_estado = ADICIONA_SIMBOLO;
                end
            end
            VITORIA: begin
                if (!iniciar) begin
                    proximo_estado = ESPERANDO;
                end
            end
            DERROTA: begin
                if (!iniciar) begin
                    proximo_estado = ESPERANDO;
                end
            end
            default: begin
                proximo_estado = ESPERANDO;
            end
        endcase
    end

    /* Registrador de estado da FSM. */
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            estado <= ESPERANDO;
        end else begin
            estado <= proximo_estado;
        end
    end

    /* Sinais de saida da FSM para comandar o datapath. */
    always @(*) begin
        /* Valores padrao evitam sinais ficando ligados sem querer. */
        gera_simbolo = 1'b0;
        escreve_memoria = 1'b0;
        limpa_nivel = 1'b0;
        incrementa_nivel = 1'b0;
        limpa_contador_exibicao = 1'b0;
        incrementa_contador_exibicao = 1'b0;
        limpa_contador_entrada = 1'b0;
        incrementa_contador_entrada = 1'b0;
        zera_timer = 1'b0;
        conta_timer = 1'b0;
        modo_timer = 2'd0;
        atualiza_recorde = 1'b0;
        liga_led_exibicao = 1'b0;
        usa_endereco_entrada = 1'b0;
        estado_display = 4'd0;

        case (estado)
            ESPERANDO: begin
                /* Sistema parado, esperando iniciar. */
                estado_display = 4'd0;
                limpa_nivel = 1'b1;
                limpa_contador_exibicao = 1'b1;
                limpa_contador_entrada = 1'b1;
                zera_timer = 1'b1;
            end
            ADICIONA_SIMBOLO: begin
                /* Gera e grava o novo simbolo no final da sequencia. */
                estado_display = 4'd1;
                gera_simbolo = 1'b1;
                escreve_memoria = 1'b1;
                limpa_contador_exibicao = 1'b1;
                limpa_contador_entrada = 1'b1;
                zera_timer = 1'b1;
            end
            MOSTRA_LED: begin
                /* Mostra o LED atual por um tempo definido. */
                estado_display = 4'd1;
                liga_led_exibicao = 1'b1;
                conta_timer = 1'b1;
                modo_timer = 2'd0;
                if (tempo_terminou) begin
                    zera_timer = 1'b1;
                end
            end
            APAGA_LED: begin
                /* Intervalo com LEDs apagados entre um simbolo e outro. */
                estado_display = 4'd1;
                conta_timer = 1'b1;
                modo_timer = 2'd1;
                if (tempo_terminou) begin
                    zera_timer = 1'b1;
                    if (!exibicao_finalizada) begin
                        incrementa_contador_exibicao = 1'b1;
                    end
                end
            end
            ESPERA_ENTRADA: begin
                /* Espera o jogador repetir a sequencia. */
                estado_display = 4'd2;
                usa_endereco_entrada = 1'b1;
                conta_timer = 1'b1;
                modo_timer = 2'd2;
                if (tem_botao) begin
                    if (comparacao_ok && !entrada_finalizada) begin
                        incrementa_contador_entrada = 1'b1;
                    end else if (comparacao_ok && entrada_finalizada && nivel < nivel_maximo) begin
                        zera_timer = 1'b1;
                        atualiza_recorde = 1'b1;
                        incrementa_nivel = 1'b1;
                    end else if (comparacao_ok && entrada_finalizada) begin
                        zera_timer = 1'b1;
                        atualiza_recorde = 1'b1;
                    end
                end
            end
            PAUSA_RODADA: begin
                /*
                 * Pausa curta depois que o jogador acerta a rodada.
                 * Os LEDs ficam apagados para separar o clique do jogador
                 * da exibicao da proxima sequencia.
                 */
                estado_display = 4'd2;
                conta_timer = 1'b1;
                modo_timer = 2'd1;
                if (tempo_terminou) begin
                    zera_timer = 1'b1;
                end
            end
            VITORIA: begin
                /* Vitoria: mostra estado 3 no display. */
                estado_display = 4'd3;
                liga_led_exibicao = 1'b1;
            end
            DERROTA: begin
                /* Derrota: mostra estado 4 no display. */
                estado_display = 4'd4;
            end
        endcase
    end
endmodule
