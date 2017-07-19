-----------------------------------------------------------------------------------
--!     @file    loop_server.vhd
--!     @brief   Sample Module 
--!     @version 0.1.0
--!     @date    2017/7/14
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2016-2017 Ichiro Kawazome
--      All rights reserved.
--
--      Redistribution and use in source and binary forms, with or without
--      modification, are permitted provided that the following conditions
--      are met:
--
--        1. Redistributions of source code must retain the above copyright
--           notice, this list of conditions and the following disclaimer.
--
--        2. Redistributions in binary form must reproduce the above copyright
--           notice, this list of conditions and the following disclaimer in
--           the documentation and/or other materials provided with the
--           distribution.
--
--      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
--      "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
--      LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
--      A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
--      OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
--      SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
--      LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
--      DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
--      THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
--      (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
--      OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
entity  Loop_Server is
    port (
    -------------------------------------------------------------------------------
    -- Clock and Reset Signals
    -------------------------------------------------------------------------------
        CLK             : in  std_logic; 
        ARESETn         : in  std_logic;
    -------------------------------------------------------------------------------
    -- MessagePack-RPC Byte Data Input Interface
    -------------------------------------------------------------------------------
        I_TDATA         : in  std_logic_vector(31 downto 0);
        I_TKEEP         : in  std_logic_vector( 3 downto 0);
        I_TLAST         : in  std_logic := '0';
        I_TVALID        : in  std_logic;
        I_TREADY        : out std_logic;
    -------------------------------------------------------------------------------
    -- MessagePack-RPC Byte Data Output Interface
    -------------------------------------------------------------------------------
        O_TDATA         : out std_logic_vector(31 downto 0);
        O_TKEEP         : out std_logic_vector( 3 downto 0);
        O_TLAST         : out std_logic;
        O_TVALID        : out std_logic;
        O_TREADY        : in  std_logic
    );
end  Loop_Server;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
architecture RTL of Loop_Server is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  VEC_LO        : integer := 0;
    constant  VEC_DATA_LO   : integer := VEC_LO;
    constant  VEC_DATA_HI   : integer := VEC_DATA_LO + 31;
    constant  VEC_KEEP_LO   : integer := VEC_DATA_HI +  1;
    constant  VEC_KEEP_HI   : integer := VEC_KEEP_LO +  3;
    constant  VEC_LAST_POS  : integer := VEC_KEEP_HI +  1;
    constant  VEC_HI        : integer := VEC_LAST_POS;
    constant  QUEUE_SIZE    : integer := 2;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    s_data        : std_logic_vector(VEC_HI downto VEC_LO);
    signal    s_valid       : std_logic;
    signal    s_ready       : std_logic;
    signal    i_data        : std_logic_vector(VEC_HI downto VEC_LO);
    signal    o_data        : std_logic_vector(VEC_HI downto VEC_LO);
    signal    o_valid       : std_logic_vector(QUEUE_SIZE downto 0);
    signal    reset         : std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    component QUEUE_RECEIVER
        generic (
            QUEUE_SIZE  : integer range 2 to 256 := 2;
            DATA_BITS   : integer :=  32
        );
        port (
            CLK         : in  std_logic; 
            RST         : in  std_logic;
            CLR         : in  std_logic;
            I_ENABLE    : in  std_logic;
            I_DATA      : in  std_logic_vector(DATA_BITS-1 downto 0);
            I_VAL       : in  std_logic;
            I_RDY       : out std_logic;
            O_DATA      : out std_logic_vector(DATA_BITS-1 downto 0);
            O_VAL       : out std_logic;
            O_RDY       : in  std_logic
        );
    end component;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    component QUEUE_REGISTER
        generic (
            QUEUE_SIZE  : integer := 1;
            DATA_BITS   : integer :=  32;
            LOWPOWER    : integer range 0 to 1 := 1
        );
        port (
            CLK         : in  std_logic; 
            RST         : in  std_logic;
            CLR         : in  std_logic;
            I_DATA      : in  std_logic_vector(DATA_BITS-1 downto 0);
            I_VAL       : in  std_logic;
            I_RDY       : out std_logic;
            O_DATA      : out std_logic_vector(DATA_BITS-1 downto 0);
            O_VAL       : out std_logic_vector(QUEUE_SIZE  downto 0);
            Q_DATA      : out std_logic_vector(DATA_BITS-1 downto 0);
            Q_VAL       : out std_logic_vector(QUEUE_SIZE  downto 0);
            Q_RDY       : in  std_logic
        );
    end component;
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    reset <= '1' when (ARESETn = '0') else '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    I: QUEUE_RECEIVER
        generic map (
            QUEUE_SIZE  => 2,
            DATA_BITS   => i_data'length
        )
        port map(
            CLK         => CLK         , -- In  :
            RST         => reset       , -- In  :
            CLR         => '0'         , -- In  :
            I_ENABLE    => '1'         , -- In  :
            I_DATA      => i_data      , -- In  :
            I_VAL       => I_TVALID    , -- In  :
            I_RDY       => I_TREADY    , -- Out :
            O_DATA      => s_data      , -- Out :
            O_VAL       => s_valid     , -- Out :
            O_RDY       => s_ready       -- In  :
        );
    i_data(VEC_DATA_HI downto VEC_DATA_LO) <= I_TDATA;
    i_data(VEC_KEEP_HI downto VEC_KEEP_LO) <= I_TKEEP;
    i_data(VEC_LAST_POS                  ) <= I_TLAST;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O: QUEUE_REGISTER
        generic map (
            QUEUE_SIZE  => QUEUE_SIZE,
            DATA_BITS   => o_data'length,
            LOWPOWER    => 1
        )
        port map (
            CLK         => CLK         , -- In  :
            RST         => reset       , -- In  :
            CLR         => '0'         , -- In  :
            I_DATA      => s_data      , -- In  :
            I_VAL       => s_valid     , -- In  :
            I_RDY       => s_ready     , -- Out :
            O_DATA      => open        , -- Out :
            O_VAL       => open        , -- Out :
            Q_DATA      => o_data      , -- Out :
            Q_VAL       => o_valid     , -- Out :
            Q_RDY       => O_TREADY      -- In  :
        );
    O_TDATA  <= o_data(VEC_DATA_HI downto VEC_DATA_LO);
    O_TKEEP  <= o_data(VEC_KEEP_HI downto VEC_KEEP_LO);
    O_TLAST  <= o_data(VEC_LAST_POS);
    O_TVALID <= o_valid(0);
end RTL;
