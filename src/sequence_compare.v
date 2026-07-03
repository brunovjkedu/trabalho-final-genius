/*
 * 7.6 - Comparador de Sequencia.
 *
 * Retorna 1 quando o simbolo esperado pela memoria e igual ao simbolo jogado.
 */
module sequence_compare (
    input [1:0] simbolo_esperado,
    input [1:0] simbolo_jogado,
    output resultado_comparacao
);
    /* Comparacao combinacional simples. */
    assign resultado_comparacao = (simbolo_esperado == simbolo_jogado);
endmodule
