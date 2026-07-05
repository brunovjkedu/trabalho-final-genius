/*
 * Guarda o nivel atual da partida.
 * O nivel tambem indica o tamanho da sequencia que o jogador precisa repetir.
 */
module level_register (
    input clk,
    input reset,
    input limpar,
    input incrementar,
    output reg [5:0] nivel
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            nivel <= 6'd0;
        end else if (limpar) begin
            nivel <= 6'd1;
        end else if (incrementar && nivel < 6'd32) begin
            nivel <= nivel + 6'd1;
        end
    end
endmodule
