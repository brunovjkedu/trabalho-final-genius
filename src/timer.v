/*
 * 7.7 - Temporizador.
 *
 * Ele substitui atrasos de simulacao por contadores reais, que podem ser
 * sintetizados na FPGA. O modo define qual tempo sera contado.
 *
 * Ideia geral:
 * - quando enable = 1, o contador soma 1 a cada clock;
 * - quando o contador chega ao limite escolhido, done vai para 1;
 * - quando clear = 1 ou enable = 0, a contagem volta para zero.
 *
 * Assim a FSM consegue usar o mesmo modulo para tres tempos diferentes:
 * - mode = 0: tempo que o LED fica aceso durante a exibicao;
 * - mode = 1: intervalo com LEDs apagados entre simbolos;
 * - mode = 2: tempo maximo para o jogador responder.
 *
 * A dificuldade muda apenas o tempo de resposta do jogador.
 */
module timer (
    input clk,          /* Clock da FPGA. */
    input rst,          /* Reset geral do circuito. */
    input clear,        /* Zera a contagem atual. */
    input enable,       /* Permite o contador andar. */
    input [1:0] mode,   /* Escolhe qual tempo sera contado. */
    input [1:0] difficulty, /* 00=60s, 01=45s, 10=30s, 11=15s. */
    output done,        /* Fica em 1 quando o tempo terminou. */
    output reg [5:0] seconds_left
);
    /*
     * Estes parametros indicam quantos ciclos de clock cada tempo deve durar.
     *
     * Com clock de 50 MHz:
     * - 25.000.000 ciclos = 0,5 segundo;
     * - 10.000.000 ciclos = 0,2 segundo;
     * - 50.000.000 ciclos = 1 segundo.
     *
     * No testbench esses valores sao trocados por numeros pequenos para a
     * simulacao terminar rapido.
     */
    parameter SHOW_TICKS = 32'd25000000;
    parameter GAP_TICKS = 32'd10000000;
    parameter ONE_SECOND_TICKS = 32'd50000000;
    parameter EASY_SECONDS = 6'd60;
    parameter NORMAL_SECONDS = 6'd45;
    parameter HARD_SECONDS = 6'd30;
    parameter VERY_HARD_SECONDS = 6'd15;

    reg [31:0] count;   /* Quantos ciclos ja foram contados. */
    reg [31:0] limit;   /* Limite escolhido pelo mode. */
    reg [5:0] seconds_count;
    reg [5:0] input_seconds;

    wire input_mode;

    assign input_mode = (mode == 2'd2);

    /* Seleciona o limite de contagem de acordo com a etapa do jogo. */
    always @(*) begin
        case (mode)
            /* Tempo em que um LED da sequencia fica ligado. */
            2'd0: limit = SHOW_TICKS;

            /* Pequena pausa entre um LED e outro. */
            2'd1: limit = GAP_TICKS;

            /* No modo de entrada, count mede apenas um segundo por vez. */
            default: limit = ONE_SECOND_TICKS;
        endcase
    end

    /* Seleciona o tempo maximo de resposta conforme a dificuldade. */
    always @(*) begin
        case (difficulty)
            2'b00: input_seconds = EASY_SECONDS;
            2'b01: input_seconds = NORMAL_SECONDS;
            2'b10: input_seconds = HARD_SECONDS;
            default: input_seconds = VERY_HARD_SECONDS;
        endcase
    end

    /*
     * done e combinacional: assim que count chega no limite, a saida avisa
     * a FSM. A FSM entao pode trocar de estado ou mandar limpar o timer.
     */
    assign done = enable && (input_mode ? (seconds_count >= input_seconds) : (count >= limit));

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            /* Reset coloca o temporizador parado no inicio. */
            count <= 32'd0;
            seconds_count <= 6'd0;
            seconds_left <= EASY_SECONDS;
        end else if (clear || !enable) begin
            /*
             * clear zera quando a FSM inicia uma nova contagem.
             * !enable tambem zera para o timer nao continuar de onde parou
             * quando nao esta sendo usado.
             */
            count <= 32'd0;
            seconds_count <= 6'd0;
            seconds_left <= input_seconds;
        end else if (input_mode && !done) begin
            /*
             * Durante a entrada do jogador, contamos segundos inteiros.
             * Isso permite mostrar o tempo restante em HEX2/HEX1.
             */
            if (count >= (ONE_SECOND_TICKS - 32'd1)) begin
                count <= 32'd0;
                seconds_count <= seconds_count + 6'd1;
                if (seconds_left > 6'd0) begin
                    seconds_left <= seconds_left - 6'd1;
                end
            end else begin
                count <= count + 32'd1;
            end
        end else if (!done) begin
            /* Nos outros modos, basta contar ciclos ate o limite. */
            count <= count + 32'd1;
            seconds_left <= input_seconds;
        end else begin
            /*
             * Quando done ja esta em 1, count fica parado no limite.
             * Ele so volta para zero quando a FSM mandar clear ou desligar enable.
             */
            count <= count;
            seconds_count <= seconds_count;
            seconds_left <= seconds_left;
        end
    end
endmodule
