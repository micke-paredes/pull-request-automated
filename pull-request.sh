#!/bin/bash

_files=''
_comment_commit=''
_branch_target=''
GREEN="\033[1;33m"
PURPLE="\033[1;35m"
RED="\033[1;31m"
WHITE="\033[1;37m"
NOCOLOR="\e[0m"


function print_menu()  # selected_item, ...menu_items
{
        local function_arguments=($@)
        local selected_item="$1"
        local menu_items=(${function_arguments[@]:1})
        local menu_size="${#menu_items[@]}"

        echo -e "${WHITE}CHOOSE BRANCH TARGET${NOCOLOR}"
        for (( i = 0; i < $menu_size; ++i ))
        do
                if [ "$i" = "$selected_item" ]
                then
                        echo -e "${RED}> ${menu_items[i]}${NOCOLOR}"
                else
                        echo -e "${menu_items[i]}"
                fi
        done
}

function run_menu()  # selected_item, ...menu_items
{
        local function_arguments=($@)
        local selected_item="$1"
        local menu_items=(${function_arguments[@]:1})
        local menu_size="${#menu_items[@]}"
        local menu_limit=$((menu_size - 1))

        clear
        print_menu "$selected_item" "${menu_items[@]}"
        
        while read -rsn1 input
        do
                case "$input"
                in
                        $'\x1B')  # ESC ASCII code (https://dirask.com/posts/ASCII-Table-pJ3Y0j)
                                read -rsn1 -t 0.1 input
                                if [ "$input" = "[" ]  # occurs before arrow code
                                then
                                        read -rsn1 -t 0.1 input
                                        case "$input"
                                        in
                                                A)  # Up Arrow
                                                        if [ "$selected_item" -ge 1 ]
                                                        then
                                                                selected_item=$((selected_item - 1))
                                                                clear
                                                                print_menu "$selected_item" "${menu_items[@]}"
                                                        fi
                                                        ;;
                                                B)  # Down Arrow
                                                        if [ "$selected_item" -lt "$menu_limit" ]
                                                        then
                                                                selected_item=$((selected_item + 1))
                                                                clear
                                                                print_menu "$selected_item" "${menu_items[@]}"
                                                        fi
                                                        ;;
                                        esac
                                fi
                                read -rsn5 -t 0.1  # flushing stdin
                                ;;
                        "")  # Enter key
                                return "$selected_item"
                                ;;
                esac
        done
}


# Usage:
selected_item=0
menu_items=("Dev" "Staging-QA")
run_menu "$selected_item" "${menu_items[@]}"
menu_result="$?"
case "$menu_result"
in
        0)
                _branch_target=dev
                ;;
        1)
                _branch_target=staging
                ;;
esac
echo -e "${WHITE}GIT FILES MODIFIED${NOCOLOR}"
echo -e "`git status`${WHITE}"
until [ "$_files" -a "$_comment_comit" -a "$_pr_title" -a "$_pr_body" ]
do
	read -p "Files To Add: " _files
	read -p "Comment For Commit: " _comment_comit
	read -p "PR Title: " _pr_title
	read -p "PR Body: " _pr_body
done
git add $_files
git commit -m "${_comment_comit}"
echo -e ${PURPLE}
gh pr create -t "${_pr_title}" -b "${_pr_body}" -B $_branch_target


