/*
 * 7.4 - Contador de Exibicao.
 * 7.5 - Contador de Entrada.
 *
 * Ele e usado tanto para contar qual simbolo esta sendo exibido quanto para
 * contar qual entrada do jogador esta sendo comparada.
 * Com 5 bits, ele consegue enderecar ate 32 posicoes da sequencia.
 *
 * No datapath, a instancia show_counter atende ao item 7.4 do PDF
 * e a instancia input_counter atende ao item 7.5 do PDF.
 */
module counter4 (
    input clk,
    input rst,
    input clear,
    input increment,
    output reg [4:0] count
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 5'd0;
        end else if (clear) begin
            count <= 5'd0;
        end else if (increment) begin
            /* Incrementa uma posicao da sequencia. */
            count <= count + 5'd1;
        end
    end
endmodule
