/*
 * 7.7 - Temporizador.
 *
 * Ele substitui atrasos de simulacao por contadores reais, que podem ser
 * sintetizados na FPGA. O modo define qual tempo sera contado.
 *
 * Ideia geral:
 * - quando habilita = 1, o contador soma 1 a cada clock;
 * - quando o contador chega ao limite escolhido, terminou vai para 1;
 * - quando limpar = 1 ou habilita = 0, a contagem volta para zero.
 *
 * Assim a FSM consegue usar o mesmo modulo para tres tempos diferentes:
 * - modo = 0: tempo que o LED fica aceso durante a exibicao;
 * - modo = 1: intervalo com LEDs apagados entre simbolos;
 * - modo = 2: tempo maximo para o jogador responder.
 *
 * A dificuldade muda apenas o tempo de resposta do jogador.
 */
module timer (
    input clk,          /* Clock da FPGA. */
    input reset,          /* Reset geral do circuito. */
    input limpar,        /* Zera a contagem atual. */
    input habilita,       /* Permite o contador andar. */
    input [1:0] modo,   /* Escolhe qual tempo sera contado. */
    input [1:0] dificuldade, /* 00=60s, 01=45s, 10=30s, 11=15s. */
    output terminou,        /* Fica em 1 quando o tempo terminou. */
    output reg [5:0] segundos_restantes
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
    parameter CICLOS_EXIBICAO = 32'd25000000;
    parameter CICLOS_INTERVALO = 32'd10000000;
    parameter CICLOS_UM_SEGUNDO = 32'd50000000;
    parameter SEGUNDOS_FACIL = 6'd60;
    parameter SEGUNDOS_NORMAL = 6'd45;
    parameter SEGUNDOS_DIFICIL = 6'd30;
    parameter SEGUNDOS_MUITO_DIFICIL = 6'd15;

    reg [31:0] contador;   /* Quantos ciclos ja foram contados. */
    reg [31:0] limite;   /* Limite escolhido pelo modo. */
    reg [5:0] contador_segundos;
    reg [5:0] segundos_entrada;

    wire modo_entrada;

    assign modo_entrada = (modo == 2'd2);

    /* Seleciona o limite de contagem de acordo com a etapa do jogo. */
    always @(*) begin
        case (modo)
            /* Tempo em que um LED da sequencia fica ligado. */
            2'd0: limite = CICLOS_EXIBICAO;

            /* Pequena pausa entre um LED e outro. */
            2'd1: limite = CICLOS_INTERVALO;

            /* No modo de entrada, contador mede apenas um segundo por vez. */
            default: limite = CICLOS_UM_SEGUNDO;
        endcase
    end

    /* Seleciona o tempo maximo de resposta conforme a dificuldade. */
    always @(*) begin
        case (dificuldade)
            2'b00: segundos_entrada = SEGUNDOS_FACIL;
            2'b01: segundos_entrada = SEGUNDOS_NORMAL;
            2'b10: segundos_entrada = SEGUNDOS_DIFICIL;
            default: segundos_entrada = SEGUNDOS_MUITO_DIFICIL;
        endcase
    end

    /*
     * terminou e combinacional: assim que contador chega no limite, a saida avisa
     * a FSM. A FSM entao pode trocar de estado ou mandar limpar o timer.
     */
    assign terminou = habilita && (modo_entrada ? (contador_segundos >= segundos_entrada) : (contador >= limite));

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            /* Reset coloca o temporizador parado no inicio. */
            contador <= 32'd0;
            contador_segundos <= 6'd0;
            segundos_restantes <= SEGUNDOS_FACIL;
        end else if (limpar || !habilita) begin
            /*
             * limpar zera quando a FSM inicia uma nova contagem.
             * !habilita tambem zera para o timer nao continuar de onde parou
             * quando nao esta sendo usado.
             */
            contador <= 32'd0;
            contador_segundos <= 6'd0;
            segundos_restantes <= segundos_entrada;
        end else if (modo_entrada && !terminou) begin
            /*
             * Durante a entrada do jogador, contamos segundos inteiros.
             * Isso permite mostrar o tempo restante em HEX2/HEX1.
             */
            if (contador >= (CICLOS_UM_SEGUNDO - 32'd1)) begin
                contador <= 32'd0;
                contador_segundos <= contador_segundos + 6'd1;
                if (segundos_restantes > 6'd0) begin
                    segundos_restantes <= segundos_restantes - 6'd1;
                end
            end else begin
                contador <= contador + 32'd1;
            end
        end else if (!terminou) begin
            /* Nos outros modos, basta contar ciclos ate o limite. */
            contador <= contador + 32'd1;
            segundos_restantes <= segundos_entrada;
        end else begin
            /*
             * Quando terminou ja esta em 1, contador fica parado no limite.
             * Ele so volta para zero quando a FSM mandar limpar ou desligar habilita.
             */
            contador <= contador;
            contador_segundos <= contador_segundos;
            segundos_restantes <= segundos_restantes;
        end
    end
endmodule
