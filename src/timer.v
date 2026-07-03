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
 * - mode = 2 ou 3: tempo maximo para o jogador responder.
 */
module timer (
    input clk,          /* Clock da FPGA. */
    input rst,          /* Reset geral do circuito. */
    input clear,        /* Zera a contagem atual. */
    input enable,       /* Permite o contador andar. */
    input [1:0] mode,   /* Escolhe qual tempo sera contado. */
    output done         /* Fica em 1 quando o tempo terminou. */
);
    /*
     * Estes parametros indicam quantos ciclos de clock cada tempo deve durar.
     *
     * Com clock de 50 MHz:
     * - 25.000.000 ciclos = 0,5 segundo;
     * - 10.000.000 ciclos = 0,2 segundo;
     * - 3.000.000.000 ciclos = 60 segundos.
     *
     * No testbench esses valores sao trocados por numeros pequenos para a
     * simulacao terminar rapido.
     */
    parameter SHOW_TICKS = 32'd25000000;
    parameter GAP_TICKS = 32'd10000000;
    parameter INPUT_TICKS = 32'd3000000000;

    reg [31:0] count;   /* Quantos ciclos ja foram contados. */
    reg [31:0] limit;   /* Limite escolhido pelo mode. */

    /* Seleciona o limite de contagem de acordo com a etapa do jogo. */
    always @(*) begin
        case (mode)
            /* Tempo em que um LED da sequencia fica ligado. */
            2'd0: limit = SHOW_TICKS;

            /* Pequena pausa entre um LED e outro. */
            2'd1: limit = GAP_TICKS;

            /* Tempo maximo para o jogador repetir a sequencia. */
            default: limit = INPUT_TICKS;
        endcase
    end

    /*
     * done e combinacional: assim que count chega no limite, a saida avisa
     * a FSM. A FSM entao pode trocar de estado ou mandar limpar o timer.
     */
    assign done = enable && (count >= limit);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            /* Reset coloca o temporizador parado no inicio. */
            count <= 32'd0;
        end else if (clear || !enable) begin
            /*
             * clear zera quando a FSM inicia uma nova contagem.
             * !enable tambem zera para o timer nao continuar de onde parou
             * quando nao esta sendo usado.
             */
            count <= 32'd0;
        end else if (!done) begin
            /* Enquanto nao terminou, soma um ciclo de clock. */
            count <= count + 32'd1;
        end else begin
            /*
             * Quando done ja esta em 1, count fica parado no limite.
             * Ele so volta para zero quando a FSM mandar clear ou desligar enable.
             */
            count <= count;
        end
    end
endmodule
