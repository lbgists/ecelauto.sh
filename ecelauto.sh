#!/usr/bin/env bash
# Elementary Cellular Automaton in Bash
# Copyright (c) 2018 Yu-Jie Lin
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


# default settings
((T_NCELLS = $(tput cols) / 2))
RULE_NO=110


#######
# ECA #
#######


next_gen()
{
    local N_CELLS=()  # cells of the next generation

    local i curr
    for ((i = 0; i < T_NCELLS; i++)); do
        # get the current pattern to get the next state from the transition
        # rule, i.e. using the current pattern as bit index to the rule number
        # in binary.
        ((
            curr = T_CELLS[(i + T_NCELLS - 1) % T_NCELLS] << 2
                 | T_CELLS[i]                             << 1
                 | T_CELLS[(i + 1)            % T_NCELLS],
            N_CELLS[i] = (RULE_NO >> curr) & 1
        ))
    done
    T_CELLS=("${N_CELLS[@]}")
}


#########
# utils #
#########


print_tape()
{
    local i

    for ((i = 0; i < T_NCELLS; i++)); do
        # same coloring scheme as
        # http://mathworld.wolfram.com/ElementaryCellularAutomaton.html
        if ((T_CELLS[i])); then
            echo -ne '\e[1;40m  \e[0m'  # state 1 == black
        else
            echo -ne '\e[1;47m  \e[0m'
        fi
    done
    echo
}


###############
# commandline #
###############


HELP="Usage: $(basename $0) [OPTIONS]
Elementary cellular automaton

Options:

    -r <0-255>      rule number (Default: $RULE_NO)
    -n <0->         number of cells (Default: $T_NCELLS = terminal width / 2)
    -i <0,1>...     initial states (Default: all 0 but the middle cell)

    -h              this help message
"


parse()
{
    local i

    while getopts "r:n:i:h" arg; do
        case $arg in
            r) RULE_NO="$OPTARG";;
            n) T_NCELLS="$OPTARG";;
            i)
                for ((i = 0; i < ${#OPTARG}; i++)); do
                    T_CELLS[i]=${OPTARG:i:1}
                done
                ;;
            h)
                echo "$HELP"
                exit 0
                ;;
        esac
    done

    ((${#T_CELLS[@]})) || ((T_CELLS[T_NCELLS / 2] = 1))
}


main()
{
    parse "$@"

    while print_tape; read -t 0.1 -n 1; [[ -z "$REPLY" ]]; do
        next_gen
    done
}


main "$@"
