
set board_part   [get_board_parts -quiet -latest_file_version "*pynq*"]
set device_part  "xc7z020clg400-1"

set pblock_list [list]

lappend pblock_list {rpc_server_0}
set pblock_info(rpc_server_0.cell)    {base_i/RPC_SERVER_0}
set pblock_info(rpc_server_0.slice)   {SLICE_X50Y0:SLICE_X113Y97}
set pblock_info(rpc_server_0.dsp48)   {DSP48_X3Y0:DSP48_X4Y37}
set pblock_info(rpc_server_0.ramb18)  {RAMB18_X3Y0:RAMB18_X5Y37}
set pblock_info(rpc_server_0.ramb36)  {RAMB36_X3Y0:RAMB36_X5Y18}
set pblock_info(rpc_server_0.dcp)     {rpc_server_0_dummy.dcp}
set pblock_info(rpc_server_0.bit)     {rpc_server_0_dummy.bit}


