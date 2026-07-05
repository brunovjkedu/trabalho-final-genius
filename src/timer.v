/*
 * Temporizador usado pela FSM.
 * Serve para tempo de exibicao, intervalo entre LEDs e tempo de resposta.
 */
module timer (
    input clk,
    input reset,
    input limpar,
    input habilita,
    input [1:0] modo,
    input [1:0] dificuldade,
    output terminou,
    output reg [5:0] segundos_restantes
);
    parameter CICLOS_EXIBICAO = 32'd25000000; /* 0,5 s com clock de 50 MHz. */
    parameter CICLOS_INTERVALO = 32'd10000000; /* 0,2 s. */
    parameter CICLOS_UM_SEGUNDO = 32'd50000000; /* 1 s. */
    parameter SEGUNDOS_FACIL = 6'd60;
    parameter SEGUNDOS_NORMAL = 6'd45;
    parameter SEGUNDOS_DIFICIL = 6'd30;
    parameter SEGUNDOS_MUITO_DIFICIL = 6'd15;

    reg [31:0] contador;
    reg [31:0] limite;
    reg [5:0] contador_segundos;
    reg [5:0] segundos_entrada;

    wire modo_entrada;

    assign modo_entrada = (modo == 2'd2);

    always @(*) begin
        case (modo)
            2'd0: limite = CICLOS_EXIBICAO;
            2'd1: limite = CICLOS_INTERVALO;
            default: limite = CICLOS_UM_SEGUNDO;
        endcase
    end

    always @(*) begin
        case (dificuldade)
            2'b00: segundos_entrada = SEGUNDOS_FACIL;
            2'b01: segundos_entrada = SEGUNDOS_NORMAL;
            2'b10: segundos_entrada = SEGUNDOS_DIFICIL;
            default: segundos_entrada = SEGUNDOS_MUITO_DIFICIL;
        endcase
    end

    /* No modo de entrada, a contagem e feita por segundos inteiros. */
    assign terminou = habilita && (modo_entrada ? (contador_segundos >= segundos_entrada) : (contador >= limite));

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            contador <= 32'd0;
            contador_segundos <= 6'd0;
            segundos_restantes <= SEGUNDOS_FACIL;
        end else if (limpar || !habilita) begin
            contador <= 32'd0;
            contador_segundos <= 6'd0;
            segundos_restantes <= segundos_entrada;
        end else if (modo_entrada && !terminou) begin
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
            contador <= contador + 32'd1;
            segundos_restantes <= segundos_entrada;
        end else begin
            contador <= contador;
            contador_segundos <= contador_segundos;
            segundos_restantes <= segundos_restantes;
        end
    end
endmodule
