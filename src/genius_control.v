/*
 * Unidade de controle do jogo Genius.
 *
 * Esta FSM decide em qual parte do jogo estamos e gera os sinais de controle
 * para o datapath: escrever na memoria, incrementar contadores, ligar timer,
 * habilitar LEDs e mudar o nivel.
 */
module genius_control (
    input clk,
    input rst,
    input start,
    input has_button,
    input compare_ok,
    input timer_done,
    input show_finished,
    input input_finished,
    input [5:0] level,
    input [5:0] max_level,
    output reg lfsr_enable,
    output reg mem_write,
    output reg clear_level,
    output reg inc_level,
    output reg clear_show_count,
    output reg inc_show_count,
    output reg clear_input_count,
    output reg inc_input_count,
    output reg timer_clear,
    output reg timer_enable,
    output reg [1:0] timer_mode,
    output reg update_record,
    output reg show_led_enable,
    output reg use_input_address,
    output reg [3:0] state_display_value,
    output reg [2:0] state
);
    parameter IDLE = 3'd0;
    parameter ADD_SYMBOL = 3'd1;
    parameter SHOW_ON = 3'd2;
    parameter SHOW_OFF = 3'd3;
    parameter INPUT_WAIT = 3'd4;
    parameter WIN = 3'd5;
    parameter LOSE = 3'd6;
    parameter ROUND_PAUSE = 3'd7;

    reg [2:0] next_state;

    /* Logica combinacional da proxima transicao de estado. */
    always @(*) begin
        next_state = state;

        case (state)
            IDLE: begin
                if (start) begin
                    /* SW0 inicia uma nova partida. */
                    next_state = ADD_SYMBOL;
                end
            end
            ADD_SYMBOL: begin
                /* Grava o novo simbolo e depois passa para exibicao. */
                next_state = SHOW_ON;
            end
            SHOW_ON: begin
                if (timer_done) begin
                    next_state = SHOW_OFF;
                end
            end
            SHOW_OFF: begin
                if (timer_done && show_finished) begin
                    next_state = INPUT_WAIT;
                end else if (timer_done) begin
                    next_state = SHOW_ON;
                end
            end
            INPUT_WAIT: begin
                if (timer_done) begin
                    /* Acabou o tempo de resposta do jogador. */
                    next_state = LOSE;
                end else if (has_button && !compare_ok) begin
                    /* Jogador apertou um botao diferente do esperado. */
                    next_state = LOSE;
                end else if (has_button && compare_ok && input_finished && level == max_level) begin
                    /* Ultimo nivel completado. */
                    next_state = WIN;
                end else if (has_button && compare_ok && input_finished) begin
                    /* Rodada correta: faz uma pequena pausa antes da proxima. */
                    next_state = ROUND_PAUSE;
                end
            end
            ROUND_PAUSE: begin
                if (timer_done) begin
                    next_state = ADD_SYMBOL;
                end
            end
            WIN: begin
                if (!start) begin
                    next_state = IDLE;
                end
            end
            LOSE: begin
                if (!start) begin
                    next_state = IDLE;
                end
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    /* Registrador de estado da FSM. */
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    /* Sinais de saida da FSM para comandar o datapath. */
    always @(*) begin
        /* Valores padrao evitam sinais ficando ligados sem querer. */
        lfsr_enable = 1'b0;
        mem_write = 1'b0;
        clear_level = 1'b0;
        inc_level = 1'b0;
        clear_show_count = 1'b0;
        inc_show_count = 1'b0;
        clear_input_count = 1'b0;
        inc_input_count = 1'b0;
        timer_clear = 1'b0;
        timer_enable = 1'b0;
        timer_mode = 2'd0;
        update_record = 1'b0;
        show_led_enable = 1'b0;
        use_input_address = 1'b0;
        state_display_value = 4'd0;

        case (state)
            IDLE: begin
                /* Sistema parado, esperando iniciar. */
                state_display_value = 4'd0;
                clear_level = 1'b1;
                clear_show_count = 1'b1;
                clear_input_count = 1'b1;
                timer_clear = 1'b1;
            end
            ADD_SYMBOL: begin
                /* Gera e grava o novo simbolo no final da sequencia. */
                state_display_value = 4'd1;
                lfsr_enable = 1'b1;
                mem_write = 1'b1;
                clear_show_count = 1'b1;
                clear_input_count = 1'b1;
                timer_clear = 1'b1;
            end
            SHOW_ON: begin
                /* Mostra o LED atual por um tempo definido. */
                state_display_value = 4'd1;
                show_led_enable = 1'b1;
                timer_enable = 1'b1;
                timer_mode = 2'd0;
                if (timer_done) begin
                    timer_clear = 1'b1;
                end
            end
            SHOW_OFF: begin
                /* Intervalo com LEDs apagados entre um simbolo e outro. */
                state_display_value = 4'd1;
                timer_enable = 1'b1;
                timer_mode = 2'd1;
                if (timer_done) begin
                    timer_clear = 1'b1;
                    if (!show_finished) begin
                        inc_show_count = 1'b1;
                    end
                end
            end
            INPUT_WAIT: begin
                /* Espera o jogador repetir a sequencia. */
                state_display_value = 4'd2;
                use_input_address = 1'b1;
                timer_enable = 1'b1;
                timer_mode = 2'd2;
                if (has_button) begin
                    if (compare_ok && !input_finished) begin
                        inc_input_count = 1'b1;
                    end else if (compare_ok && input_finished && level < max_level) begin
                        timer_clear = 1'b1;
                        update_record = 1'b1;
                        inc_level = 1'b1;
                    end else if (compare_ok && input_finished) begin
                        timer_clear = 1'b1;
                        update_record = 1'b1;
                    end
                end
            end
            ROUND_PAUSE: begin
                /*
                 * Pausa curta depois que o jogador acerta a rodada.
                 * Os LEDs ficam apagados para separar o clique do jogador
                 * da exibicao da proxima sequencia.
                 */
                state_display_value = 4'd2;
                timer_enable = 1'b1;
                timer_mode = 2'd1;
                if (timer_done) begin
                    timer_clear = 1'b1;
                end
            end
            WIN: begin
                /* Vitoria: mostra estado 3 no display. */
                state_display_value = 4'd3;
                show_led_enable = 1'b1;
            end
            LOSE: begin
                /* Derrota: mostra estado 4 no display. */
                state_display_value = 4'd4;
            end
        endcase
    end
endmodule
