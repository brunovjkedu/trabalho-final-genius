/*
 * Guarda o maior nivel alcancado enquanto a placa esta ligada.
 */
module record_register (
    input clk,
    input reset,
    input atualizar,
    input [5:0] nivel,
    output reg [5:0] recorde
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            recorde <= 6'd0;
        end else if (atualizar && nivel > recorde) begin
            recorde <= nivel;
        end
    end
endmodule
