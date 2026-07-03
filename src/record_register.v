/*
 * Registrador de recorde.
 *
 * Guarda o maior nivel completado enquanto a placa permanece ligada.
 * O valor e perdido ao desligar ou resetar a FPGA, pois e apenas um registrador.
 */
module record_register (
    input clk,
    input rst,
    input update,
    input [5:0] level,
    output reg [5:0] record
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            record <= 6'd0;
        end else if (update && level > record) begin
            record <= level;
        end
    end
endmodule
