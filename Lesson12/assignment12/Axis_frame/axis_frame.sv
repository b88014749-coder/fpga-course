module axis_frame #(
    parameter DATA_WIDTH_IN  = 8,
    parameter DATA_WIDTH_OUT = 32,
    parameter FIFO_DEPTH     = 16,

    parameter FRAME_WIDTH    = 320,
    parameter FRAME_HEIGHT   = 200
) (
    input  logic                       aclk,
    input  logic                       aresetn,
//clock of the input data, as far as I understand it may differ from the system clock, hence the separate port here
    input  logic                       data_clk,
//Start the data accumulation while the start port is high
    input  logic                       start,
//Input data ports
    input  logic [DATA_WIDTH_IN-1:0]   s_axis_tdata,
    input  logic                       s_axis_tvalid,
    output logic                       s_axis_tready,
//Output axi master ports
    output logic [DATA_WIDTH_OUT-1:0]  m_axis_tdata,
    output logic                       m_axis_tvalid,
    input  logic                       m_axis_tready,
    output logic                       m_axis_tlast
);

    localparam int FRAME_PIXELS = FRAME_WIDTH * FRAME_HEIGHT;
//Here I assume 8bit per pixel
    localparam int FRAME_BYTES = FRAME_PIXELS;
    localparam int INPUTS_PER_OUTPUT = DATA_WIDTH_OUT / DATA_WIDTH_IN;

    localparam int FRAME_WORDS = FRAME_BYTES / INPUTS_PER_OUTPUT;
    localparam int WORD_COUNT_WIDTH = $clog2(FRAME_WORDS);
    localparam int PACK_COUNT_WIDTH = $clog2(INPUTS_PER_OUTPUT);

    logic start_sync1;
    logic start_sync2;

    logic fifo_write_en;
    logic fifo_read_en;

    logic [DATA_WIDTH_IN-1:0] fifo_data_in;
    logic [DATA_WIDTH_IN-1:0] fifo_data_out;
    logic                     fifo_data_valid;

    logic fifo_full;
    logic fifo_empty;

    logic [DATA_WIDTH_OUT-1:0] pack_reg;
    logic [PACK_COUNT_WIDTH-1:0] pack_count;
    logic [WORD_COUNT_WIDTH-1:0] word_count;

    typedef enum logic [1:0] {
        ST_IDLE,
        ST_READ,
        ST_WAIT_DATA,
        ST_OUTPUT
    } state_t;

    state_t state;

    // Synchronize start into data_clk domain to avoid metastability
    always_ff @(posedge data_clk or negedge aresetn) begin
        if (!aresetn) begin
            start_sync1 <= 1'b0;
            start_sync2 <= 1'b0;
        end
        else begin
            start_sync1 <= start;
            start_sync2 <= start_sync1;
        end
    end

    // External input is accepted only after start
    // and while the FIFO has space.
    assign s_axis_tready = start_sync2 && !fifo_full;

    assign fifo_write_en = s_axis_tvalid && s_axis_tready;

    assign fifo_data_in = s_axis_tdata;

    // FIFO
    async_fifo #(
        .DATA_WIDTH (DATA_WIDTH_IN),
        .FIFO_DEPTH (FIFO_DEPTH)
    ) input_fifo (
        .wr_clk     (data_clk),
        .rd_clk     (aclk),
        .aresetn    (aresetn),

        .write_en   (fifo_write_en),
        .data_in    (fifo_data_in),

        .read_en    (fifo_read_en),
        .data_out   (fifo_data_out),
        .data_valid (fifo_data_valid),

        .full       (fifo_full),
        .empty      (fifo_empty)
    );

    // AXI/output side
    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            state         <= ST_IDLE;
            fifo_read_en  <= 1'b0;
            pack_reg      <= '0;
            pack_count    <= '0;
            word_count    <= '0;
            m_axis_tdata  <= '0;
            m_axis_tvalid <= 1'b0;
            m_axis_tlast  <= 1'b0;
        end
        else begin
            // Default: read request is only one clock wide.
            fifo_read_en <= 1'b0;
            case (state)
                // ------------------------------------------------
                // Waiting for MicroBlaze/GPIO start
                // ------------------------------------------------
                ST_IDLE: begin
                    m_axis_tvalid <= 1'b0;
                    m_axis_tlast  <= 1'b0;
                    pack_reg   <= '0;
                    pack_count <= '0;
                    word_count <= '0;
                    if (start) begin
                        state <= ST_READ;
                    end
                end
                // ------------------------------------------------
                // Request one byte from FIFO
                // ------------------------------------------------
                ST_READ: begin
                    if (!fifo_empty) begin
                        fifo_read_en <= 1'b1;
                        state <= ST_WAIT_DATA;
                    end
                end
                // ------------------------------------------------
                // Wait for FIFO to return requested byte
                // ------------------------------------------------
                ST_WAIT_DATA: begin
                    if (fifo_data_valid) begin
                        case (pack_count)
                            0: begin
                                pack_reg[7:0] <= fifo_data_out;
                                pack_count <= pack_count + 1'b1;
                                state <= ST_READ;
                            end
                            1: begin
                                pack_reg[15:8] <= fifo_data_out;
                                pack_count <= pack_count + 1'b1;
                                state <= ST_READ;
                            end
                            2: begin
                                pack_reg[23:16] <= fifo_data_out;
                                pack_count <= pack_count + 1'b1;
                                state <= ST_READ;
                            end
                            3: begin
                                m_axis_tdata <= {fifo_data_out, pack_reg[23:0]};
                                m_axis_tvalid <= 1'b1;
                                if (word_count == FRAME_WORDS-1)
                                    m_axis_tlast <= 1'b1;
                                else
                                    m_axis_tlast <= 1'b0;
                                pack_count <= '0;
                                state <= ST_OUTPUT;
                            end
                            default: begin
                                pack_count <= '0;
                                state <= ST_READ;
                            end
                        endcase
                    end
                end
                // ------------------------------------------------
                // Hold AXI word until DMA accepts it
                // ------------------------------------------------
                ST_OUTPUT: begin
                    if (m_axis_tvalid && m_axis_tready) begin
                        m_axis_tvalid <= 1'b0;
                        if (m_axis_tlast) begin
                            // Complete frame, as far as I understand according to the spec the TLAST signal is optional, but we implement it here anyway
                            m_axis_tlast <= 1'b0;
                            word_count <= '0;
                            pack_count <= '0;
                            pack_reg   <= '0;
                            state <= ST_IDLE;
                        end
                        else begin
                            word_count <= word_count + 1'b1;
                            state <= ST_READ;
                        end
                    end
                end
                default: begin
                    state <= ST_IDLE;
                end
            endcase
        end
    end
endmodule
