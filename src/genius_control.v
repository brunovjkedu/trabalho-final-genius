/*
 * Unidade de controle do jogo.
 * Esta FSM decide a etapa atual e liga os sinais que comandam o datapath.
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
    parameter ESPERANDO = 3'd0; /* HEX3 mostra 0. */
    parameter ADICIONA_SIMBOLO = 3'd1; /* Parte da exibicao. */
    parameter MOSTRA_LED = 3'd2; /* Parte da exibicao. */
    parameter APAGA_LED = 3'd3; /* Parte da exibicao. */
    parameter ESPERA_ENTRADA = 3'd4; /* HEX3 mostra 2. */
    parameter VITORIA = 3'd5; /* HEX3 mostra 3. */
    parameter DERROTA = 3'd6; /* HEX3 mostra 4. */
    parameter PAUSA_RODADA = 3'd7; /* Pausa antes da proxima rodada. */

    reg [2:0] proximo_estado;

    always @(*) begin
        proximo_estado = estado;

        case (estado)
            ESPERANDO: begin
                if (iniciar) begin
                    proximo_estado = ADICIONA_SIMBOLO;
                end
            end
            ADICIONA_SIMBOLO: begin
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
                    proximo_estado = DERROTA;
                end else if (tem_botao && !comparacao_ok) begin
                    proximo_estado = DERROTA;
                end else if (tem_botao && comparacao_ok && entrada_finalizada && nivel == nivel_maximo) begin
                    proximo_estado = VITORIA;
                end else if (tem_botao && comparacao_ok && entrada_finalizada) begin
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

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            estado <= ESPERANDO;
        end else begin
            estado <= proximo_estado;
        end
    end

    always @(*) begin
        /* Padrao: tudo desligado; cada estado liga so o que precisa. */
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
                estado_display = 4'd0;
                limpa_nivel = 1'b1;
                limpa_contador_exibicao = 1'b1;
                limpa_contador_entrada = 1'b1;
                zera_timer = 1'b1;
            end
            ADICIONA_SIMBOLO: begin
                estado_display = 4'd1;
                gera_simbolo = 1'b1;
                escreve_memoria = 1'b1;
                limpa_contador_exibicao = 1'b1;
                limpa_contador_entrada = 1'b1;
                zera_timer = 1'b1;
            end
            MOSTRA_LED: begin
                estado_display = 4'd1;
                liga_led_exibicao = 1'b1;
                conta_timer = 1'b1;
                modo_timer = 2'd0;
                if (tempo_terminou) begin
                    zera_timer = 1'b1;
                end
            end
            APAGA_LED: begin
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
                /* Pequena pausa antes de mostrar a proxima sequencia. */
                estado_display = 4'd2;
                conta_timer = 1'b1;
                modo_timer = 2'd1;
                if (tempo_terminou) begin
                    zera_timer = 1'b1;
                end
            end
            VITORIA: begin
                estado_display = 4'd3;
                liga_led_exibicao = 1'b1;
            end
            DERROTA: begin
                estado_display = 4'd4;
            end
        endcase
    end
endmodule
