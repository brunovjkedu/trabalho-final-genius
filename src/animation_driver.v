/*
 * Cuida das animacoes de vitoria e derrota.
 * Fora desses estados, deixa passar os LEDs e displays normais do jogo.
 */
module animation_driver (
    input clk,
    input reset,
    input [3:0] estado_display,
    input [3:0] leds_jogo,
    input [6:0] hex0_normal,
    input [6:0] hex1_normal,
    input [6:0] hex2_normal,
    output reg [3:0] leds,
    output reg [7:0] leds_verdes,
    output reg [6:0] hex0,
    output reg [6:0] hex1,
    output reg [6:0] hex2
);
    parameter CICLOS_ANIMACAO = 32'd12500000; /* 0,25 s com clock de 50 MHz. */

    reg [31:0] contador;
    reg [1:0] fase;

    parameter HEX_APAGADO = 7'b1111111;
    parameter HEX_TRACO = 7'b0111111; /* Acende so o segmento do meio. */

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            contador <= 32'd0;
            fase <= 2'd0;
        end else if (estado_display == 4'd3 || estado_display == 4'd4) begin
            if (contador >= CICLOS_ANIMACAO) begin
                contador <= 32'd0;
                fase <= fase + 2'd1;
            end else begin
                contador <= contador + 32'd1;
            end
        end else begin
            contador <= 32'd0;
            fase <= 2'd0;
        end
    end

    always @(*) begin
        if (estado_display == 4'd3) begin
            leds = 4'b0000;
            leds_verdes = fase[0] ? 8'b11111111 : 8'b00000000;
            hex2 = hex2_normal;
            hex1 = hex1_normal;
            hex0 = fase[0] ? hex0_normal : HEX_APAGADO;
        end else if (estado_display == 4'd4) begin
            leds = fase[0] ? 4'b1010 : 4'b0101;
            leds_verdes = 8'b00000000;
            hex2 = hex2_normal;
            hex1 = hex1_normal;
            hex0 = fase[0] ? HEX_TRACO : HEX_APAGADO;
        end else begin
            leds = leds_jogo;
            leds_verdes = 8'b00000000;
            hex2 = hex2_normal;
            hex1 = hex1_normal;
            hex0 = hex0_normal;
        end
    end
endmodule
