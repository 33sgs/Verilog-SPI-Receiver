module SPIReceiver (i_Clock, o_Data, i_CS, i_MOSI, i_SCLK, o_MISO, o_Ready);
	parameter	DATA_SIZE = 16; // Must be a power of 2
	
	input wire i_Clock; // Main input clock, serial clock will be half the frequency of this clock
	input wire i_CS; // Active low chip select
	input wire i_MOSI; // Master data out
	input wire i_SCLK; // Idle low clock
	
	output reg o_MISO;
	output reg o_Ready; // Serializer uses this to signal that it is ready for more data
	output reg [DATA_SIZE-1:0] o_Data; // Parallel data input lines
	
	reg [DATA_SIZE-1:0] r_Data;
	reg [$clog2(DATA_SIZE)-1:0] r_Data_Index;
	reg r_Prev_CS;
	reg r_Prev_SCLK;
	reg r_Enabled;

	initial
	begin
		o_Data <= 1'b0;
		o_Ready <= 1'b0;
		o_MISO <= 1'b0;
		
		r_Prev_CS <= 1'b1;
		r_Prev_SCLK <= 1'b1;
		r_Data <= 1'b0;
		r_Data_Index <= 1'b0;
	end
	
	always @(posedge i_Clock)
	begin
		r_Prev_CS <= i_CS;
		
		// Start Condition
		if(r_Prev_CS && !i_CS)
		begin
			r_Data <= 1'b0;
			r_Data_Index <= 1'b0;
			o_Data <= 1'b0;
			o_Ready <= 1'b0;
			o_MISO <= 1'b0;
			o_Ready <= 1'b0;
			
			r_Prev_CS <= 1'b1;
			r_Enabled <= 1'b1;
		end
		
		// Stop Condition
		if(!r_Prev_CS && i_CS)
		begin
			r_Enabled <= 1'b0;
			o_Ready <= 1'b1;
		end
		
		if(r_Enabled)
		begin
			r_Prev_SCLK <= i_SCLK;
			
			// Sample Data
			if(!r_Prev_SCLK && i_SCLK)
			begin
				if(r_Data_Index < DATA_SIZE)
				begin
					o_Data[r_Data_Index] <= i_MOSI;
					r_Data_Index <= r_Data_Index + 1;
				end
			end
		end
		
		
	end
endmodule
