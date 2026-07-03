/*
 * Animacoes simples para vitoria e derrota.
 *
 * Fora dos estados finais, os LEDs normais do jogo passam direto.
 * Em vitoria, todos os LEDs piscam.
 * Em derrota, os LEDs alternam em pares.
 * Mantem HEX2/HEX1 com o recorde nos estados finais.
 * O HEX0 pode piscar como detalhe visual.
 * O HEX3 fica fora daqui para continuar mostrando 3 ou 4 como estado.
 */
module animation_driver (
    input clk,
    input rst,
    input [3:0] state_display_value,
    input [3:0] game_leds,
    input [6:0] normal_hex0,
    input [6:0] normal_hex1,
    input [6:0] normal_hex2,
    output reg [3:0] leds,
    output reg [6:0] hex0,
    output reg [6:0] hex1,
    output reg [6:0] hex2
);
    parameter ANIMATION_TICKS = 32'd12500000;

    reg [31:0] count;
    reg [1:0] phase;

    parameter HEX_BLANK = 7'b1111111;
    parameter HEX_DASH = 7'b0111111;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 32'd0;
            phase <= 2'd0;
        end else if (state_display_value == 4'd3 || state_display_value == 4'd4) begin
            if (count >= ANIMATION_TICKS) begin
                count <= 32'd0;
                phase <= phase + 2'd1;
            end else begin
                count <= count + 32'd1;
            end
        end else begin
            count <= 32'd0;
            phase <= 2'd0;
        end
    end

    always @(*) begin
        if (state_display_value == 4'd3) begin
            leds = phase[0] ? 4'b1111 : 4'b0000;
            hex2 = normal_hex2;
            hex1 = normal_hex1;
            hex0 = phase[0] ? normal_hex0 : HEX_BLANK;
        end else if (state_display_value == 4'd4) begin
            leds = phase[0] ? 4'b1010 : 4'b0101;
            hex2 = normal_hex2;
            hex1 = normal_hex1;
            hex0 = phase[0] ? HEX_DASH : HEX_BLANK;
        end else begin
            leds = game_leds;
            hex2 = normal_hex2;
            hex1 = normal_hex1;
            hex0 = normal_hex0;
        end
    end
endmodule
