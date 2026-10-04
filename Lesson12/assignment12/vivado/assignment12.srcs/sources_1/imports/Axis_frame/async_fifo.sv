module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 16
) (
    input  logic                  wr_clk,
    input  logic                  rd_clk,
    input  logic                  aresetn,

    input  logic                  write_en,
    input  logic [DATA_WIDTH-1:0] data_in,

    input  logic                  read_en,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic                  data_valid,

    output logic                  full,
    output logic                  empty
);

    localparam int ADDR_WIDTH = $clog2(FIFO_DEPTH);
    localparam int PTR_WIDTH  = ADDR_WIDTH + 1;

    logic [DATA_WIDTH-1:0] fifo_mem [0:FIFO_DEPTH-1];

    logic [ADDR_WIDTH-1:0] wr_addr;
    logic [ADDR_WIDTH-1:0] rd_addr;

    logic [PTR_WIDTH-1:0] wr_ptr;
    logic [PTR_WIDTH-1:0] rd_ptr;

    logic [PTR_WIDTH-1:0] wr_ptr_gray;
    logic [PTR_WIDTH-1:0] rd_ptr_gray;

    logic [PTR_WIDTH-1:0] rd_ptr_gray_sync1;
    logic [PTR_WIDTH-1:0] rd_ptr_gray_sync2;

    logic [PTR_WIDTH-1:0] wr_ptr_gray_sync1;
    logic [PTR_WIDTH-1:0] wr_ptr_gray_sync2;

    function automatic logic [PTR_WIDTH-1:0] bin_to_gray(
        input logic [PTR_WIDTH-1:0] bin
    );
        return (bin >> 1) ^ bin;
    endfunction

    assign empty = (rd_ptr_gray == wr_ptr_gray_sync2);

    assign full =
        (wr_ptr_gray ==
        {
            ~rd_ptr_gray_sync2[PTR_WIDTH-1:PTR_WIDTH-2],
             rd_ptr_gray_sync2[PTR_WIDTH-3:0]
        });

    // Write side
    always_ff @(posedge wr_clk or negedge aresetn) begin
        if (!aresetn) begin
            wr_addr     <= '0;
            wr_ptr      <= '0;
            wr_ptr_gray <= '0;
        end
        else begin
            if (write_en && !full) begin
                fifo_mem[wr_addr] <= data_in;

                wr_addr <= wr_addr + 1'b1;
                wr_ptr  <= wr_ptr + 1'b1;

                wr_ptr_gray <= bin_to_gray(wr_ptr + 1'b1);
            end
        end
    end

    // Read side
    always_ff @(posedge rd_clk or negedge aresetn) begin
        if (!aresetn) begin
            rd_addr     <= '0;
            rd_ptr      <= '0;
            rd_ptr_gray <= '0;

            data_out    <= '0;
            data_valid  <= 1'b0;
        end
        else begin
            data_valid <= 1'b0;

            if (read_en && !empty) begin
                data_out <= fifo_mem[rd_addr];

                data_valid <= 1'b1;

                rd_addr <= rd_addr + 1'b1;
                rd_ptr  <= rd_ptr + 1'b1;

                rd_ptr_gray <= bin_to_gray(rd_ptr + 1'b1);
            end
        end
    end

    // Synchronize read pointer into write clock domain
    always_ff @(posedge wr_clk or negedge aresetn) begin
        if (!aresetn) begin
            rd_ptr_gray_sync1 <= '0;
            rd_ptr_gray_sync2 <= '0;
        end
        else begin
            rd_ptr_gray_sync1 <= rd_ptr_gray;
            rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;
        end
    end

    // Synchronize write pointer into read clock domain
    always_ff @(posedge rd_clk or negedge aresetn) begin
        if (!aresetn) begin
            wr_ptr_gray_sync1 <= '0;
            wr_ptr_gray_sync2 <= '0;
        end
        else begin
            wr_ptr_gray_sync1 <= wr_ptr_gray;
            wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;
        end
    end

endmodule
