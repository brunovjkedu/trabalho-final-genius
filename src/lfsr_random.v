/*
 * 7.1 - Gerador Pseudoaleatorio.
 *
 * Usado para escolher o proximo simbolo do Genius.
 *
 * Este modulo usa um LFSR de 4 bits. A cada pulso de clock, quando enable = 1,
 * os bits do registrador sao deslocados para a esquerda e o novo bit de entrada
 * e calculado com XOR entre os bits 3 e 2.
 *
 * O reset coloca o LFSR em 1011 para evitar o valor 0000, pois um LFSR travaria
 * se todos os bits fossem zero.
 *
 * A saida simbolo_randomico usa apenas os 2 bits menos significativos do LFSR,
 * gerando valores de 0 a 3, que correspondem aos quatro botoes/LEDs do jogo.
 */
module lfsr_random (
    input clk,
    input rst,
    input enable,
    output [1:0] simbolo_randomico
);
    reg [3:0] lfsr;
    wire feedback;

    /* XOR usado para criar o novo bit do LFSR. */
    assign feedback = lfsr[3] ^ lfsr[2];

    /* Dois bits sao suficientes para representar quatro simbolos. */
    assign simbolo_randomico = lfsr[1:0];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            lfsr <= 4'b1011;
        end else if (enable) begin
            /* Desloca os bits e coloca o feedback na posicao menos significativa. */
            lfsr <= {lfsr[2:0], feedback};
        end
    end
endmodule
