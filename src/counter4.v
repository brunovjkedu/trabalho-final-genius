/*
 * Contador usado para percorrer a sequencia.
 * No datapath ele aparece uma vez para exibicao e outra para entrada.
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
            contador <= contador + 5'd1;
        end
    end
endmodule
