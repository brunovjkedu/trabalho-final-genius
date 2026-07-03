/*
 * 7.2 - Memoria da Sequencia.
 *
 * Sao 32 posicoes, e cada posicao guarda um simbolo de 2 bits.
 * A escrita acontece no clock quando write_enable = 1.
 * A leitura e combinacional, usando o endereco read_address.
 */
module sequence_memory (
    input clk,
    input write_enable,
    input [4:0] write_address,
    input [1:0] write_data,
    input [4:0] read_address,
    output [1:0] read_data
);
    reg [1:0] memory [0:31];

    /* Le a posicao escolhida pela exibicao ou pela entrada do jogador. */
    assign read_data = memory[read_address];

    always @(posedge clk) begin
        if (write_enable) begin
            /* Grava o novo simbolo gerado pelo LFSR. */
            memory[write_address] <= write_data;
        end
    end
endmodule
