/*
 * Transforma os pulsos dos quatro botoes em um simbolo de 0 a 3.
 */
module button_decoder (
    input [3:0] pulsos,
    output reg tem_botao,
    output reg [1:0] simbolo
);
    always @(*) begin
        tem_botao = 1'b0;
        simbolo = 2'd0;

        /* Se dois botoes vierem juntos, o de menor numero tem prioridade. */
        if (pulsos[0]) begin
            tem_botao = 1'b1;
            simbolo = 2'd0;
        end else if (pulsos[1]) begin
            tem_botao = 1'b1;
            simbolo = 2'd1;
        end else if (pulsos[2]) begin
            tem_botao = 1'b1;
            simbolo = 2'd2;
        end else if (pulsos[3]) begin
            tem_botao = 1'b1;
            simbolo = 2'd3;
        end
    end
endmodule
