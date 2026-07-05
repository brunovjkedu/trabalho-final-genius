/*
 * Registrador de recorde.
 *
 * Guarda o maior nivel completado enquanto a placa permanece ligada.
 * O valor e perdido ao desligar ou resetar a FPGA, pois e apenas um registrador.
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
