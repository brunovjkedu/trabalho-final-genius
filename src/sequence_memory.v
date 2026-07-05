/*
 * 7.2 - Memoria da Sequencia.
 *
 * Sao 32 posicoes, e cada posicao guarda um simbolo de 2 bits.
 * A escrita acontece no clock quando habilita_escrita = 1.
 * A leitura e combinacional, usando o endereco endereco_leitura.
 */
module sequence_memory (
    input clk,
    input habilita_escrita,
    input [4:0] endereco_escrita,
    input [1:0] dado_escrita,
    input [4:0] endereco_leitura,
    output [1:0] dado_leitura
);
    reg [1:0] memoria [0:31];

    /* Le a posicao escolhida pela exibicao ou pela entrada do jogador. */
    assign dado_leitura = memoria[endereco_leitura];

    always @(posedge clk) begin
        if (habilita_escrita) begin
            /* Grava o novo simbolo gerado pelo LFSR. */
            memoria[endereco_escrita] <= dado_escrita;
        end
    end
endmodule
