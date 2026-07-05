/*
 * Conversor simples de numero decimal para dois digitos.
 *
 * Usado para mostrar tempo restante e recorde nos displays HEX2/HEX1.
 */
module decimal_digits (
    input [5:0] valor,
    output reg [3:0] dezena,
    output reg [3:0] unidade
);
    always @(*) begin
        if (valor >= 6'd60) begin
            dezena = 4'd6;
            unidade = valor - 6'd60;
        end else if (valor >= 6'd50) begin
            dezena = 4'd5;
            unidade = valor - 6'd50;
        end else if (valor >= 6'd40) begin
            dezena = 4'd4;
            unidade = valor - 6'd40;
        end else if (valor >= 6'd30) begin
            dezena = 4'd3;
            unidade = valor - 6'd30;
        end else if (valor >= 6'd20) begin
            dezena = 4'd2;
            unidade = valor - 6'd20;
        end else if (valor >= 6'd10) begin
            dezena = 4'd1;
            unidade = valor - 6'd10;
        end else begin
            dezena = 4'd0;
            unidade = valor[3:0];
        end
    end
endmodule
