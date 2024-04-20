struct CLI_Table
    getter rows : Array(CLI_Table_Row)
   
    def initialize(@rows : Array(CLI_Table_Row))
    end

    def render
        content_lenght = `stty size`.chomp().split(' ')[1].to_i
        output = ""
        row_index = 0
        rows.each do |row|
            column_size = (content_lenght / row.columns).to_i
            index = 0
            row.row_data.each do |data|
                to_write = ""
                data_command = data.command
                if data_command.is_a?(Array(String))
                    to_write += "{ "
                    data_command.each do |command|
                        unless data_command.last == command
                            to_write += "#{command} : "
                        else
                            to_write += command
                        end
                    end
                    to_write += " }"
                else
                    to_write = data_command
                end
                arguments = data.arguments
                expected_content_lenght = column_size - to_write.size - 10
                unless arguments.nil?
                    if arguments.is_a?(Array(Argument))
                        expected_content_lenght -= 4
                        arguments_to_write = "{ "
                        arguments.each do |argument|
                            if argument.default == true
                                arguments_to_write += "(#{argument.value})"
                            else
                                arguments_to_write += "#{argument.value}"
                            end
                            unless arguments.last == argument
                                arguments_to_write += " : "
                            end
                        end
                        arguments_to_write += " }"
                        output += "            #{to_write} #{arguments_to_write}#{" " * (expected_content_lenght - 1 - arguments_to_write.size + 4)} | #{data.about}\n"
                    elsif arguments.is_a?(String)
                        expected_content_lenght -= (2 + arguments.size)
                        if data_command.is_a?(Array(String))
                            output += "        #{to_write} <#{arguments}>#{" " * (expected_content_lenght)}# #{data.about}\n"
                        else
                            output += "            #{to_write} <#{arguments}>#{" " * (expected_content_lenght)}|#{data.about}\n"
                        end
                        
                    end
                else
                    if data_command.is_a?(Array(String))
                        output += "        #{to_write}#{" " * expected_content_lenght} # #{data.about}\n"
                    else
                        output += "            #{to_write}#{" " * expected_content_lenght} |#{data.about}\n"
                    end
                end
                index += 1
            end
            row_index += 1
        end
        return output
    end
end

record CLI_Table_Row, row_data : Array(CLI_Table_Row_Data_Command), columns : Int8

record Argument, value : String, default : Bool

record CLI_Table_Row_Data_Command, command : Array(String) | String, arguments : Array(Argument)? | String?, about : String

# mixed_array = [] of Int8 | Bool | String
# mixed_array << 1_i8