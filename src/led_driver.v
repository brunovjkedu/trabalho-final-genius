/*
 * Acende o LED vermelho correspondente ao simbolo que deve ser mostrado.
 */
module led_driver (
    input habilita,
    input [1:0] simbolo,
    output reg [3:0] leds
);
    always @(*) begin
        if (!habilita) begin
            leds = 4'b0000;
        end else begin
            case (simbolo)
                2'd0: leds = 4'b0001;
                2'd1: leds = 4'b0010;
                2'd2: leds = 4'b0100;
                default: leds = 4'b1000;
            endcase
        end
    end
endmodule
