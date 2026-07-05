/*
 * 7.4 - Contador de Exibicao.
 * 7.5 - Contador de Entrada.
 *
 * Ele e usado tanto para contar qual simbolo esta sendo exibido quanto para
 * contar qual entrada do jogador esta sendo comparada.
 * Com 5 bits, ele consegue enderecar ate 32 posicoes da sequencia.
 *
 * No datapath, a instancia contador_exibicao_inst atende ao item 7.4 do PDF
 * e a instancia contador_entrada_inst atende ao item 7.5 do PDF.
 */
module counter4 (
    input clk,
    input reset,
    input limpar,
    input incrementar,
    output reg [4:0] contador
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            contador <= 5'd0;
        end else if (limpar) begin
            contador <= 5'd0;
        end else if (incrementar) begin
            /* Incrementa uma posicao da sequencia. */
            contador <= contador + 5'd1;
        end
    end
endmodule
