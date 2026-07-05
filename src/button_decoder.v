/*
 * Converte os pulsos dos quatro botoes em um simbolo de 2 bits.
 *
 * A saida tem_botao indica que algum botao foi pressionado.
 * A saida simbolo informa qual foi o botao: 0, 1, 2 ou 3.
 */
module button_decoder (
    input [3:0] pulsos,
    output reg tem_botao,
    output reg [1:0] simbolo
);
    always @(*) begin
        /* Valores padrao: nenhum botao pressionado. */
        tem_botao = 1'b0;
        simbolo = 2'd0;

        /* A prioridade evita ambiguidades se dois botoes vierem ao mesmo tempo. */
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
