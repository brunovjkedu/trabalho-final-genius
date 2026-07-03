/*
 * 7.4 - Contador de Exibicao.
 * 7.5 - Contador de Entrada.
 *
 * Ele e usado tanto para contar qual simbolo esta sendo exibido quanto para
 * contar qual entrada do jogador esta sendo comparada.
 *
 * No datapath, a instancia show_counter atende ao item 7.4 do PDF
 * e a instancia input_counter atende ao item 7.5 do PDF.
 */
module counter4 (
    input clk,
    input rst,
    input clear,
    input increment,
    output reg [3:0] count
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 4'd0;
        end else if (clear) begin
            count <= 4'd0;
        end else if (increment) begin
            /* Incrementa uma posicao da sequencia. */
            count <= count + 4'd1;
        end
    end
endmodule
