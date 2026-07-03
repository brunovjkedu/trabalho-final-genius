/*
 * 7.9 - Debouncer.
 *
 * Modulo para filtragem de ruido mecanico das entradas KEY0-KEY3.
 * Ele espera o sinal ficar estavel por STABLE_COUNT ciclos e gera apenas
 * um pulso quando detecta uma nova pressao valida.
 *
 * Ideia geral:
 * - noisy e o sinal bruto vindo do botao;
 * - quando noisy muda, o modulo nao confia nele imediatamente;
 * - primeiro ele espera o sinal ficar igual por STABLE_COUNT ciclos;
 * - so depois disso o novo valor e aceito como estado real do botao;
 * - se o novo estado aceito for 1, pulse fica em 1 por um unico ciclo.
 *
 * Isso evita que uma unica apertada seja lida como varias apertadas.
 */
module debouncer (
    input clk,          /* Clock da FPGA. */
    input rst,          /* Reset geral. */
    input noisy,        /* Entrada bruta do botao, ainda com ruido. */
    output reg pulse    /* Pulso limpo de um ciclo quando o botao e apertado. */
);
    /*
     * Numero de ciclos que o sinal precisa ficar sem mudar para ser aceito.
     * Com 50 MHz, 250000 ciclos dao cerca de 5 ms.
     */
    parameter STABLE_COUNT = 250000;

    reg stable_state;   /* Ultimo estado confirmado do botao. */
    reg last_sample;    /* Ultimo valor bruto observado em noisy. */
    reg [18:0] count;   /* Conta ha quantos ciclos noisy esta igual. */

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            /* Reset limpa o historico do botao. */
            stable_state <= 1'b0;
            last_sample <= 1'b0;
            count <= 19'd0;
            pulse <= 1'b0;
        end else begin
            /*
             * O pulso dura somente um ciclo de clock.
             * Por isso ele volta para zero no inicio de cada ciclo.
             */
            pulse <= 1'b0;

            if (noisy != last_sample) begin
                /*
                 * O sinal bruto mudou.
                 * Pode ser uma apertada real ou apenas ruido mecanico.
                 * Guardamos o novo valor e recomecamos a contagem.
                 */
                last_sample <= noisy;
                count <= 19'd0;
            end else if (count < STABLE_COUNT) begin
                /*
                 * O sinal continua igual ao ultimo valor observado.
                 * Enquanto ainda nao chegou no limite, seguimos contando.
                 */
                count <= count + 19'd1;
            end else if (stable_state != last_sample) begin
                /*
                 * O sinal ficou estavel tempo suficiente.
                 * Agora aceitamos last_sample como novo estado real do botao.
                 */
                stable_state <= last_sample;

                if (last_sample) begin
                    /*
                     * Se o novo estado real e 1, significa uma nova pressao.
                     * Geramos um pulso de um ciclo para o restante do jogo.
                     */
                    pulse <= 1'b1;
                end
            end
        end
    end
endmodule
