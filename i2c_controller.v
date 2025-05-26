`timescale 1ns / 1ps

module i2c_controller (
    input wire clk,
    input wire rst,
    input wire [6:0] addr,
    input wire [7:0] wdata,
    input wire enable,
    input wire rw, // 1 for read, 0 for write

    output reg [7:0] data_out,
    output wire ready,

    inout wire i2c_sda,
    inout wire i2c_scl
);

// FSM states
localparam IDLE        = 4'd0;
localparam START       = 4'd1;
localparam ADDRESS     = 4'd2;
localparam READ_ACK    = 4'd3;
localparam WRITE_DATA  = 4'd4;
localparam WRITE_ACK   = 4'd5;
localparam READ_DATA   = 4'd6;
localparam READ_ACK2   = 4'd7;
localparam STOP        = 4'd8;

reg [3:0] state;
reg [2:0] counter;

reg [7:0] saved_data;
reg [7:0] saved_addr;

reg sda_out;
reg write_enable;
reg i2c_scl_enable;
reg i2c_clk;

// Generate slower I2C clock using clock divider
reg [7:0] clk_divider;
always @(posedge clk or posedge rst) begin
    if (rst) begin
        clk_divider <= 0;
        i2c_clk <= 0;
    end else begin
        clk_divider <= clk_divider + 1;
        if (clk_divider == 100) begin
            i2c_clk <= ~i2c_clk;
            clk_divider <= 0;
        end
    end
end

// Ready signal
assign ready = (~rst) && (state == IDLE);

// i2c_scl control
assign i2c_scl = i2c_scl_enable ? i2c_clk : 1'bz;

// i2c_sda control
assign i2c_sda = write_enable ? sda_out : 1'bz;

// SCL enable logic
always @(negedge i2c_clk or posedge rst) begin
    if (rst) begin
        i2c_scl_enable <= 0;
    end else begin
        if ((state == IDLE) || (state == START) || (state == STOP))
            i2c_scl_enable <= 0;
        else
            i2c_scl_enable <= 1;
    end
end

// FSM
always @(posedge i2c_clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        data_out <= 8'b0;
        counter <= 3'd7;
    end else begin
        case (state)
            IDLE: begin
                if (enable) begin
                    saved_addr <= {addr, rw};
                    saved_data <= wdata;
                    state <= START;
                end
            end

            START: begin
                counter <= 3'd7;
                state <= ADDRESS;
            end

            ADDRESS: begin
                if (counter == 0) state <= READ_ACK;
                else counter <= counter - 1;
            end

            READ_ACK: begin
                if (i2c_sda == 0) begin
                    counter <= 3'd7;
                    if (saved_addr[0] == 0) state <= WRITE_DATA;
                    else state <= READ_DATA;
                end else state <= STOP;
            end

            WRITE_DATA: begin
                if (counter == 0) state <= READ_ACK2;
                else counter <= counter - 1;
            end

            READ_DATA: begin
                data_out[counter] <= i2c_sda;
                if (counter == 0) state <= WRITE_ACK;
                else counter <= counter - 1;
            end

            WRITE_ACK: begin
                state <= STOP;
            end

            READ_ACK2: begin
                state <= STOP;
            end

            STOP: begin
                state <= IDLE;
            end

            default: state <= IDLE;
        endcase
    end
end

// SDA driver logic
always @(negedge i2c_clk or posedge rst) begin
    if (rst) begin
        write_enable <= 1;
        sda_out <= 1;
    end else begin
        case (state)
            START: begin
                write_enable <= 1;
                sda_out <= 0;
            end
            ADDRESS: begin
                sda_out <= saved_addr[counter];
            end
            READ_ACK: begin
                write_enable <= 0;
            end
            WRITE_DATA: begin
                write_enable <= 1;
                sda_out <= saved_data[counter];
            end
            READ_DATA: begin
                write_enable <= 0;
            end
            WRITE_ACK: begin
                write_enable <= 1;
                sda_out <= 0;
            end
            STOP: begin
                write_enable <= 1;
                sda_out <= 1;
            end
        endcase
    end
end

endmodule
