/*
 * Memoria da sequencia do Genius.
 * Cada posicao guarda um simbolo de 2 bits.
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

    assign dado_leitura = memoria[endereco_leitura];

    always @(posedge clk) begin
        if (habilita_escrita) begin
            memoria[endereco_escrita] <= dado_escrita;
        end
    end
endmodule
