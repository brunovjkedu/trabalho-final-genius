/*
 * Compara o simbolo esperado com o simbolo jogado pelo usuario.
 */
module sequence_compare (
    input [1:0] simbolo_esperado,
    input [1:0] simbolo_jogado,
    output resultado_comparacao
);
    assign resultado_comparacao = (simbolo_esperado == simbolo_jogado);
endmodule
