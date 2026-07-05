/*
 * 7.1 - Gerador Pseudoaleatorio.
 *
 * Usado para escolher o proximo simbolo do Genius.
 *
 * Este modulo usa um LFSR de 4 bits. A cada pulso de clock, quando habilita = 1,
 * os bits do registrador sao deslocados para a esquerda e o novo bit de entrada
 * e calculado com XOR entre os bits 3 e 2.
 *
 * O reset coloca o LFSR em 1011 para evitar o valor 0000, pois um LFSR travaria
 * se todos os bits fossem zero.
 *
 * Enquanto gira_em_espera = 1, o LFSR tambem fica girando. No nosso jogo isso
 * acontece no ESPERANDO, antes da partida comecar. Como o jogador nunca liga o SW0
 * exatamente no mesmo ciclo de clock, a sequencia comeca de pontos diferentes.
 *
 * A saida simbolo_randomico usa apenas os 2 bits menos significativos do LFSR,
 * gerando valores de 0 a 3, que correspondem aos quatro botoes/LEDs do jogo.
 */
module lfsr_random (
    input clk,
    input reset,
    input habilita,
    input gira_em_espera,
    output [1:0] simbolo_randomico
);
    reg [3:0] lfsr;
    wire realimentacao;

    /* XOR usado para criar o novo bit do LFSR. */
    assign realimentacao = lfsr[3] ^ lfsr[2];

    /* Dois bits sao suficientes para representar quatro simbolos. */
    assign simbolo_randomico = lfsr[1:0];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            lfsr <= 4'b1011;
        end else if (habilita || gira_em_espera) begin
            /* Desloca os bits e coloca o realimentacao na posicao menos significativa. */
            lfsr <= {lfsr[2:0], realimentacao};
        end
    end
endmodule
