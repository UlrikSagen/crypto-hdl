library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sha256_pad is
    port (
        clk : in std_logic;
        rst : in std_logic;

        tdata : in unsigned(31 downto 0);
        tvalid : in std_logic;
        tready : out std_logic;
        tlast : in std_logic;
        tkeep : in unsigned(3 downto 0);

        block_out : out unsigned(511 downto 0);
        first : out std_logic;
        start : out std_logic;
        core_busy : in std_logic
    );
end entity;

architecture rtl of sha256_pad is

    type state_t is (IDLE, PADDING, EMIT, EXTRA);
    signal state : state_t := IDLE;

    type w_arr_t is array (0 to 15) of unsigned(31 downto 0);
    signal buf : w_arr_t;

    signal word_idx : natural range 0 to 15 := 0;

    signal msg_done : std_logic := '0';
    signal need_extra : std_logic := '0';

    signal is_first : std_logic := '0';

begin
    
    tready <= '1' when state = PADDING else '0';

    process(clk)
        variable byte_count : unsigned(63 downto 0);
        variable blk_v : unsigned(511 downto 0);
        variable n : natural range 0 to 4 := 0;
        variable p : natural range 0 to 64 := 0;
        variable last_word : unsigned(31 downto 0) := (others => '0');
        variable bit_len : unsigned(63 downto 0);
    begin

        if rising_edge(clk) then
            if rst = '1' then
                start <= '0';
                state <= IDLE;
            else
                start <= '0';
                case state is

                    when IDLE =>

                        if tvalid = '1' then
                            is_first <= '1';
                            word_idx <= 0;
                            byte_count := (others => '0');
                            msg_done <= '0';
                            need_extra <= '0';

                            for i in 0 to 15 loop
                                buf(i) <= (others => '0');
                            end loop;

                            state <= PADDING;
                        end if;

                    when PADDING =>

                        if tvalid = '1' then

                            case tkeep is
                                when "0000" => n := 0;
                                when "1000" => n := 1;
                                when "1100" => n := 2;
                                when "1110" => n := 3;
                                when "1111" => n := 4;
                                when others => assert false report "invalid tkeep" severity error;
                            end case;

                            buf(word_idx) <= tdata;
                            byte_count := byte_count + n;

                            if tlast = '1' then
                                p := to_integer(byte_count(5 downto 0)); -- mod 64
                                if byte_count = 0 then -- Tom melding
                                    state <= EXTRA;
                                elsif p = 0 then
                                    need_extra <= '1';
                                    state <= EMIT;
                                elsif p <= 55 then
                                    
                                    last_word := (others => '0');

                                    if n = 4 then
                                        last_word(31 downto 24) := x"80";
                                        buf(word_idx + 1) <= last_word;
                                    else
                                        last_word(31 downto 32-n*8) := tdata(31 downto 32-n*8);
                                        last_word(31-8*n downto 24-8*n) := x"80";
                                        buf(word_idx) <= last_word;
                                    end if;

                                    bit_len := SHIFT_LEFT(byte_count, 3);
                                    buf(14) <= bit_len(63 downto 32);
                                    buf(15) <= bit_len(31 downto 0);
                                    msg_done <= '1';
                                    state <= EMIT;
                                else
                                    last_word := (others => '0');

                                    if n = 4 then
                                        last_word(31 downto 24) := x"80";
                                        buf(word_idx + 1) <= last_word;
                                    else
                                        last_word(31 downto 32-n*8) := tdata(31 downto 32-n*8);
                                        last_word(31-8*n downto 24-8*n) := x"80";
                                        buf(word_idx) <= last_word;
                                    end if;

                                    need_extra <= '1';
                                    state <= EMIT;
                                end if;
                            elsif word_idx = 15 then
                                word_idx <= 0;
                                state <= EMIT;
                            else
                                word_idx <= word_idx + 1;
                            end if;
                        end if;

                    when EXTRA =>

                        for i in 0 to 15 loop
                            buf(i) <= (others => '0');
                        end loop;

                        if byte_count(5 downto 0) = 0 then   -- meldingen sluttet på blokkgrense
                            buf(0)(31 downto 24) <= x"80";
                        end if;

                        bit_len := SHIFT_LEFT(byte_count, 3);
                        buf(14) <= bit_len(63 downto 32);
                        buf(15) <= bit_len(31 downto 0);

                        msg_done <= '1';
                        state <= EMIT;

                    when EMIT =>

                        for i in 0 to 15 loop
                            blk_v(511 - i*32 downto 480 - i*32) := buf(i);
                        end loop;

                        block_out <= blk_v;
                        
                        if core_busy = '0' then
                            start <= '1';
                            first <= is_first;
                            is_first <= '0';
                            
                            if need_extra = '1' then
                                need_extra <= '0';
                                state <= EXTRA;
                            elsif msg_done = '1' then
                                msg_done <= '0';
                                state <= IDLE;
                            else
                                for i in 0 to 15 loop
                                    buf(i) <= (others => '0');
                                end loop;
                                state <= PADDING;
                            end if;
                        end if;
                end case;
            end if;
        end if;

    end process;
    

end architecture;