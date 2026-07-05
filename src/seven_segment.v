/*
 * 7.8 - Decodificador para Display de Sete Segmentos.
 *
 * Converte um valor hexadecimal de 0 a F para o padrao dos segmentos.
 * A placa DE1 usa segmentos ativos em zero.
 */
module seven_segment (
    input [3:0] valor,
    output reg [6:0] segmentos
);
    always @(*) begin
        /* Cada bit controla um segmento do display. */
        case (valor)
            4'h0: segmentos = 7'b1000000;
            4'h1: segmentos = 7'b1111001;
            4'h2: segmentos = 7'b0100100;
            4'h3: segmentos = 7'b0110000;
            4'h4: segmentos = 7'b0011001;
            4'h5: segmentos = 7'b0010010;
            4'h6: segmentos = 7'b0000010;
            4'h7: segmentos = 7'b1111000;
            4'h8: segmentos = 7'b0000000;
            4'h9: segmentos = 7'b0010000;
            4'hA: segmentos = 7'b0001000;
            4'hB: segmentos = 7'b0000011;
            4'hC: segmentos = 7'b1000110;
            4'hD: segmentos = 7'b0100001;
            4'hE: segmentos = 7'b0000110;
            default: segmentos = 7'b0001110;
        endcase
    end
endmodule
