/*
 * Conversor simples de numero decimal para dois digitos.
 *
 * Usado para mostrar tempo restante e recorde nos displays HEX2/HEX1.
 */
module decimal_digits (
    input [5:0] value,
    output reg [3:0] tens,
    output reg [3:0] ones
);
    always @(*) begin
        if (value >= 6'd60) begin
            tens = 4'd6;
            ones = value - 6'd60;
        end else if (value >= 6'd50) begin
            tens = 4'd5;
            ones = value - 6'd50;
        end else if (value >= 6'd40) begin
            tens = 4'd4;
            ones = value - 6'd40;
        end else if (value >= 6'd30) begin
            tens = 4'd3;
            ones = value - 6'd30;
        end else if (value >= 6'd20) begin
            tens = 4'd2;
            ones = value - 6'd20;
        end else if (value >= 6'd10) begin
            tens = 4'd1;
            ones = value - 6'd10;
        end else begin
            tens = 4'd0;
            ones = value[3:0];
        end
    end
endmodule
