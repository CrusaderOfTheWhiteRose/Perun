require "colorize"

require "./class/cli_table.class"
require "./function/cli_route_start.function"
require "./function/cli_route_initialisate.function"

row_init = CLI_Table_Row.new([
    CLI_Table_Row_Data_Command.new(["i", "initialisate"], "project-name", "Initialisate Perun Project"),
    CLI_Table_Row_Data_Command.new("-t", [
            Argument.new("false", true),
            Argument.new("true", false),
        ],
    "    Write In This Directory"),
    CLI_Table_Row_Data_Command.new("-c", [
            Argument.new("m", false),
            Argument.new("s", true),
            Argument.new("c", false)
        ],
    "    How Many Framework's Features Will Be Shown In The Project"),
    CLI_Table_Row_Data_Command.new("-v", [
            Argument.new("v", false),
            Argument.new("i", true),
            Argument.new("w", false),
            Argument.new("e", false)
        ],
    "    Verbose Output Level"),
], 2)
row_start = CLI_Table_Row.new([
    CLI_Table_Row_Data_Command.new(["s", "start"], nil, "Build And Run The Server"),
    CLI_Table_Row_Data_Command.new("-d", [
        Argument.new("false", false),
        Argument.new("true", true),
    ], "    Turn On/Off Debugger"),
    CLI_Table_Row_Data_Command.new("-g", [
        Argument.new("false", false),
        Argument.new("true", true),
    ], "    Turn On/Off Guards"),
    CLI_Table_Row_Data_Command.new("-e", "path-to-env", "     Force Environment File"),
    CLI_Table_Row_Data_Command.new("-v", [
        Argument.new("v", false),
        Argument.new("i", true),
        Argument.new("w", false),
        Argument.new("e", false)
    ], "    Verbose Output Level")
], 2)
row_build = CLI_Table_Row.new([
    CLI_Table_Row_Data_Command.new(["b", "build"], nil, "Build Server For Production Use"),
    CLI_Table_Row_Data_Command.new("-v", [
        Argument.new("v", false),
        Argument.new("i", true),
        Argument.new("w", false),
        Argument.new("e", false)
    ], "    Verbose Output Level")
], 2)
help_table = CLI_Table.new([
    row_init,
    row_start,
    row_build,
    CLI_Table_Row.new([
            CLI_Table_Row_Data_Command.new(["-v", "-%", "--version"], nil, "Outputs Version Information"),
            CLI_Table_Row_Data_Command.new(["-h", "-?", "--help"], nil, "Outputs Help Information")
        ],
    2)
]).render

if ARGV.size > 0
    case ARGV[0]
        when "-v" || "-%" || "--version"
            puts "VERSION - 0.0.0 | BUILD - 0.0.0-ЇТА"
        when "-h" || "-?" || "--help"
            puts help_table
        when "i" || "initialisate"
            if ARGV.last == "-h" || ARGV.last == "-?" || ARGV.last == "--help"
                puts CLI_Table.new([row_init]).render
            else
                initialisate ARGV
            end
        when "s" || "start"
            if ARGV.last == "-h" || ARGV.last == "-?" || ARGV.last == "--help"
                puts CLI_Table.new([row_start]).render
            else
                start ARGV
            end
        when "b" || "build"
            if ARGV.last == "-h" || ARGV.last == "-?" || ARGV.last == "--help"
                puts CLI_Table.new([row_build]).render
            else
                build ARGV
            end
        else
            puts help_table
    end
else
    puts help_table
end

def initialisate(arguments : Array(String))
    project_name, complexity_level, verbose_level, this_directory, index = "perun-project", "s", "i", false, 0
    start_after = false
    if arguments.size > 1
        arguments.each do
            case arguments[index - 1]
                when "-c"
                    complexity_level = "c"
                    if arguments[index] == "m"
                        complexity_level = "m"
                    end
                when "-v"
                    verbose_level = "v"
                    if arguments[index] == "w"
                        verbose_level = "w"
                    elsif arguments[index] == "e"
                        verbose_level = "e"
                    end
                when "-t"
                    this_directory = true
                    if arguments[index] == "false"
                        this_directory = false
                    end
                when "-s"
                    start_after = true
                    if arguments[index] == "false"
                        start_after = false
                    end
                else
                    if arguments[index] != "-v" && arguments[index] != "-c" && index != 0
                        project_name = arguments[index]
                    end
                end
            index += 1
        end
    end
    initialisate_execute(project_name, complexity_level, verbose_level, this_directory)
    if start_after
        start [] of String
    end
end
def start(arguments : Array(String))
    debugger_state, verbose_level, no_guard, env_file_path, index = true, "i", false, nil, 0
    if arguments.size > 1
        arguments.each do
            case arguments[index - 1]
                when "-e"
                    env_file_path = arguments[index]
                when "-d"
                    debugger_state = false
                    if arguments[index] == "true"
                        debugger_state = true
                    end
                when "-g"
                    no_guard = true
                    if arguments[index] == "true"
                        no_guard = true
                    end
                when "-v"
                    verbose_level = "v"
                    if arguments[index] == "w"
                        verbose_level = "w"
                    elsif arguments[index] == "e"
                        verbose_level = "e"
                    end
                end
            index += 1
        end
    end
    start_execute(debugger_state, verbose_level, no_guard, env_file_path)
end
def build(arguments : Array(String))
    run, doptimize, index = false, nil, 0
    if arguments.size > 1
        arguments.each do
            case arguments[index - 1]
                when "-r"
                    run = true
                    if arguments[index] == "true"
                        run = true
                    end
                when "-d"
                    if arguments[index] == "d"
                        doptimize = "-Doptimize=Debug"
                    elsif arguments[index] == "rs"
                        doptimize = "-Doptimize=ReleaseSafe"
                    elsif arguments[index] == "rf"
                        doptimize = "-Doptimize=ReleaseFast"
                    elsif arguments[index] == "rsl"
                        doptimize = "-Doptimize=ReleaseSmall"
                    end
                end
            index += 1
        end
    end
    if (doptimize.nil? && run == false)
        system "zig build"
    elsif (doptimize.nil? && run == true)
        system "zig build run"
    elsif (!doptimize.nil? && run == false)
        system "zig build #{doptimize}"
    elsif (!doptimize.nil? && run == true)
        system "zig build run #{doptimize}"
    else
        system "zig build"
    end
end
