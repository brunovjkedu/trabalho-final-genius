/*
 * Converte os pulsos dos quatro botoes em um simbolo de 2 bits.
 *
 * A saida has_button indica que algum botao foi pressionado.
 * A saida symbol informa qual foi o botao: 0, 1, 2 ou 3.
 */
module button_decoder (
    input [3:0] pulses,
    output reg has_button,
    output reg [1:0] symbol
);
    always @(*) begin
        /* Valores padrao: nenhum botao pressionado. */
        has_button = 1'b0;
        symbol = 2'd0;

        /* A prioridade evita ambiguidades se dois botoes vierem ao mesmo tempo. */
        if (pulses[0]) begin
            has_button = 1'b1;
            symbol = 2'd0;
        end else if (pulses[1]) begin
            has_button = 1'b1;
            symbol = 2'd1;
        end else if (pulses[2]) begin
            has_button = 1'b1;
            symbol = 2'd2;
        end else if (pulses[3]) begin
            has_button = 1'b1;
            symbol = 2'd3;
        end
    end
endmodule
