module Opcodes

    @@opcodes = {
            "0x00" => 'STOP',
            "0x01" => 'ADD',
            "0x02" => 'MUL',
            "0x03" => 'SUB',
            "0x04" => 'DIV',
            "0x05" => 'SDIV',
            "0x06" => 'MOD',
            "0x07" => 'SMOD',
            "0x08" => 'ADDMOD',
            "0x09" => 'MULMOD',
            "0x0a" => 'EXP',
            "0x0b" => 'SIGNEXTEND',
            "0x10" => 'LT',
            "0x11" => 'GT',
            "0x12" => 'SLT',
            "0x13" => 'SGT',
            "0x14" => 'EQ',
            "0x15" => 'ISZERO',
            "0x16" => 'AND',
            "0x17" => 'OR',
            "0x18" => 'XOR',
            "0x19" => 'NOT',
            "0x1a" => 'BYTE',
            "0x20" => 'SHA3',
            "0x30" => 'ADDRESS',
            "0x31" => 'BALANCE',
            "0x32" => 'ORIGIN',
            "0x33" => 'CALLER',
            "0x34" => 'CALLVALUE',
            "0x35" => 'CALLDATALOAD',
            "0x36" => 'CALLDATASIZE',
            "0x37" => 'CALLDATACOPY',
            "0x38" => 'CODESIZE',
            "0x39" => 'CODECOPY',
            "0x3a" => 'GASPRICE',
            "0x3b" => 'EXTCODESIZE',
            "0x3c" => 'EXTCODECOPY',
            "0x3d" => 'RETURNDATASIZE',
            "0x3e" => 'RETURNDATACOPY',
            "0x40" => 'BLOCKHASH',
            "0x41" => 'COINBASE',
            "0x42" => 'TIMESTAMP',
            "0x43" => 'NUMBER',
            "0x44" => 'DIFFICULTY',
            "0x45" => 'GASLIMIT',
            "0x50" => 'POP',
            "0x51" => 'MLOAD',
            "0x52" => 'MSTORE',
            "0x53" => 'MSTORE8',
            "0x54" => 'SLOAD',
            "0x55" => 'SSTORE',
            "0x56" => 'JUMP',
            "0x57" => 'JUMPI',
            "0x58" => 'PC',
            "0x59" => 'MSIZE',
            "0x5a" => 'GAS',
            "0x5b" => 'JUMPDEST',
            "0xa0" => 'LOG0',
            "0xa1" => 'LOG1',
            "0xa2" => 'LOG2',
            "0xa3" => 'LOG3',
            "0xa4" => 'LOG4',
            "0xf0" => 'CREATE',
            "0xf1" => 'CALL',
            "0xf2" => 'CALLCODE',
            "0xf3" => 'RETURN',
            "0xf4" => 'DELEGATECALL',
            "0xf5" => 'CALLBLACKBOX',
            "0xfa" => 'STATICCALL',
            "0xfd" => 'REVERT',
            "0xff" => 'SUICIDE',
        }

    def gen_list
        hex = 0x5f #59
        (1..32).each do |i|
            hex += 1
            hex_rep = "0x"+hex.to_s(16)
            @@opcodes.store(hex_rep, "PUSH#{i}")
        end
        hex = 0x7F
        (1..32).each do |i|
            hex +=1
            hex_rep = "0x"+hex.to_s(16)
            @@opcodes.store(hex_rep, "DUP#{i}")
        end
        hex = 0x8F
        (1..16).each do |i|
            hex +=1
            hex_rep = "0x"+hex.to_s(16)
            @@opcodes.store(hex_rep, "DUP#{i}")
        end
        return @@opcodes
    end
end