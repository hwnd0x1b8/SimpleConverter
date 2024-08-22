#!/usr/bin/bash

definition_regex='^[a-zA-Z]+\_to\_[a-zA-Z]+$'
constant_regex='^\-?[0-9]+(\.[0-9]+)?$'
value_to_convert_regex='^[0-9]+(\.[0-9]+)?$'

print_file_definitions() {
    index=1
    while IFS= read -r line
    do
        echo "${index}. ${line}"
        index=$((index + 1))
    done < definitions.txt
}

add_definition() {
    echo "Enter a definition:"
    read -a user_input
    user_input_length=${#user_input[@]}
    definition=${user_input[0]}
    constant=${user_input[1]}
    if [[ $user_input_length -eq 2 && $definition =~ $definition_regex && $constant =~ $constant_regex ]]; then
        echo "${definition} ${constant}" >> "definitions.txt"
    else
        echo "The definition is incorrect!"
        add_definition
    fi
}

delete_definition() {
    file_contents=$(cat definitions.txt)
    if [[ ! -z $file_contents ]]; then
        echo "Type the line number to delete or '0' to return"
        print_file_definitions
        delete_definition_line
    else
        echo "Please add a definition first!"
    fi
}

delete_definition_line() {
    read -a line_number_to_delete
    if [[ -z "$line_number_to_delete" || $(wc -l < definitions.txt) -lt $line_number_to_delete ]]; then
        echo "Enter a valid line number!"
        delete_definition_line
    else
        if [[ $line_number_to_delete -gt 0 ]]; then
            sed -i "${line_number_to_delete}d" definitions.txt
        fi
    fi
}

convert_units() {
    file_contents=$(cat definitions.txt)
    if [[ ! -z $file_contents ]]; then
        echo "Type the line number to convert units or '0' to return"
        print_file_definitions
        get_line_to_convert
    else
        echo "Please add a definition first!"
    fi
}

get_line_to_convert() {
    read -a line_number_to_convert
    if [[ -z $line_number_to_convert || $(wc -l < definitions.txt) -lt $line_number_to_convert ]]; then
        echo "Enter a valid line number!"
        get_line_to_convert
    elif [[ $line_number_to_convert -gt 0 ]]; then
        echo "Enter a value to convert:"
        get_value_to_convert
    else
        :
    fi
}

get_value_to_convert() {
    read -a value_to_convert
    if [[ $value_to_convert =~ $value_to_convert_regex ]]; then
        file_name="definitions.txt"
        line=$(sed "${line_number_to_convert}!d" definitions.txt)
        read -a text <<< "$line"
        do_conversion $line $value_to_convert
    else
        echo "Enter a float or integer value!"
        get_value_to_convert
    fi
}

do_conversion() {
    line="${1} ${2}"
    constant=$2
    value_to_convert=$3
    if [[ $value_to_convert =~ $value_to_convert_regex ]]; then
        result=$(echo "scale=2; $constant * $value_to_convert" | bc -l)
        printf "Result: %s\n" "$result"
    else
        echo "Enter a float or integer value!"
        get_value_to_convert
    fi
}

echo "Welcome to the Simple converter!"
while :
do
    echo "Select an option"
    echo "0. Type '0' or 'quit' to end program"
    echo "1. Convert units"
    echo "2. Add a definition"
    echo "3. Delete a definition"
    read -a option

    case "${option}" in
        0 | "quit" )
            echo "Goodbye!"
            break
            ;;
        1 )
            convert_units
            ;;
        2 )
            add_definition
            ;;
        3 )
            delete_definition
            ;;
        * )
            echo "Invalid option!"
    esac
done

