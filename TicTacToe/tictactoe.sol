// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

contract TicTacToe {
    string public state;

    address public starting_player;

    address public guest_player;

    uint public playing_state;

    address public winner;

    bool starting_player_to_play;

    constructor() {
        starting_player = msg.sender;
        reset_game();
    }

    function reset_game() public {
        require(msg.sender == starting_player, "only starter can reset the game");
        bytes memory state_bytes = "*********";
        state = string(state_bytes);
        playing_state = 0; // enter game first
        winner = address(0);
        guest_player = address(0);
        starting_player_to_play = true;
    }

    function enter() public {
        require(msg.sender != starting_player, "game starter cannot be your own opponent");
        require(playing_state == 0, "enough players");
        guest_player = msg.sender;
        playing_state = 1;
    }

    function play(uint x, uint y) public{
        require(1 <= x && x <= 3 && y >= 1 && y <= 3, "invalid location");
        require(guest_player != address(0), "we don't have guest player");
        require((starting_player == msg.sender && starting_player_to_play == true) || (guest_player == msg.sender && starting_player_to_play == false), "invalid move");
        require(playing_state == 1, "game is not in playing state");
        uint loc = (x - 1) * 3 + (y - 1);
        bytes memory state_bytes = bytes(state);
        assert(state_bytes[loc] == '*');
        if (starting_player_to_play == true) {
            state_bytes[loc] = 'O';
            starting_player_to_play = false;
        } else {
            state_bytes[loc] = 'X';
            starting_player_to_play = true;
        }
        state = string(state_bytes);
        uint8 res = check_winning();
        if (res > 0) {
            playing_state = 2;
            if (res == 1)
                winner = starting_player;
            else 
                winner = guest_player;
        }
        if (check_endgame()) {
            playing_state = 2;
        }
    }

    function check_winning_row(uint8 row_index) view private returns (uint8) {
        bytes memory state_bytes = bytes(state);
        uint8 initIndex = row_index * 3;
        if (state_bytes[initIndex] == '*') 
            return 0;
        for (uint8 i = 1; i < 3; ++i) {
            uint8 index = row_index * 3 + i;
            if (state_bytes[index] != state_bytes[initIndex]) {
                return 0;
            }
        }
        if (state_bytes[initIndex] == 'O')
            return 1;
        return 2;
    }

    function check_winning_col(uint8 col_index) view internal returns (uint8) {
        bytes memory state_bytes = bytes(state);
        uint8 initIndex = col_index;
        if (state_bytes[initIndex] == '*') 
            return 0;
        for (uint8 i = 1; i < 3; ++i) {
            uint8 index = i * 3 + col_index;
            if (state_bytes[index] != state_bytes[initIndex]) {
                return 0;
            }
        }
        if (state_bytes[initIndex] == 'O')
            return 1;
        return 2;
    }

    function check_winning_diag() view internal returns (uint8) {
        bytes memory state_bytes = bytes(state);
        uint8 initIndex = 4;
        if (state_bytes[initIndex] == '*') 
            return 0;
        if ((state_bytes[0] == state_bytes[initIndex] && state_bytes[8] == state_bytes[initIndex]) || (state_bytes[2] == state_bytes[initIndex] && state_bytes[6] == state_bytes[initIndex])) {
            if (state_bytes[initIndex] == 'O')
                return 1;
            return 2;
        }
        return 0;
    }

    function check_winning() internal view returns(uint8) {
        uint8 res = 0;
        for (uint8 i = 0; i < 3; ++i) {
            res = check_winning_col(i);
            if (res > 0)
                return res;
            res = check_winning_row(i);
            if (res > 0)
                return res;
        }
        res = check_winning_diag();
        return res;
    }

    function check_endgame() internal view returns(bool) {
        bytes memory state_bytes = bytes(state);
        for (uint8 i = 0; i < 9; ++i) {
            if (state_bytes[i] == '*') {
                return false;
            }
        }
        return true;
    }
}