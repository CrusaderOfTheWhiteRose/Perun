require "./logger.function"

record Unit_Data, main_function_content : String, imports : Array(String)
record File_Unit, name : String, addon : UNIT_TYPE, content : Unit_Data

enum UNIT_TYPE
    GUARD
    INTERSEPTOR
    PIPE
    SERVICE
    GUARD_GLOBAL
    INTERSEPTOR_GLOBAL
    PIPE_GLOBAL
    SERVICE_GLOBAL
    MIDDLEWARE
    MIDDLEWARE_GLOBAL
    GET
    POST
    PUT
    DELETE
    HEAD
    PATCH
    TRACE
    CONNECT
    OPTIONS
end

record Route, target : String, value : Array(File_Unit), childrens : Array(Route)
record Route_Wrapper, target : String, value : Array(File_Unit), parent : String

record Return_Data, addon : UNIT_TYPE?, name : String?
record Value_Route, global : Array(File_Unit), local : Array(File_Unit)
record Value_Route_Data, name : String, token : UNIT_TYPE, value : String

record Interseptor_Content, name : String, into : Bool?, content : String
def check_file_return_unit(name_part : String, directory_name : String)
    addon = nil
    name = ""

    case name_part
        when "pipe"
            addon = UNIT_TYPE::PIPE
            name = directory_name
        when "guard"
            addon = UNIT_TYPE::GUARD
            name = directory_name
        when "interseptor"
            addon = UNIT_TYPE::INTERSEPTOR
            name = directory_name
        when "service"
            addon = UNIT_TYPE::SERVICE
            name = directory_name
        when "middleware"
            addon = UNIT_TYPE::MIDDLEWARE
            name = directory_name
    else
        case name_part
            when "get"
                addon = UNIT_TYPE::GET
                name = nil
            when "post"
                addon = UNIT_TYPE::POST
                name = nil
            when "put"
                addon = UNIT_TYPE::PUT
                name = nil
            when "delete"
                addon = UNIT_TYPE::DELETE
                name = nil
            when "head"
                addon = UNIT_TYPE::HEAD
                name = nil
            when "patch"
                addon = UNIT_TYPE::PATCH
                name = nil
            when "trace"
                addon = UNIT_TYPE::TRACE
                name = nil
            when "connect"
                addon = UNIT_TYPE::CONNECT
                name = nil
            when "options"
                addon = UNIT_TYPE::OPTIONS
                name = nil
        else
            name = name_part
        end
    end

    return_data = Return_Data.new addon, name
end

def check_file(entry : String, value : Array(File_Unit))
    names = entry.split "/"

    parent = names[names.size - 3]
    if parent == "source"
        parent = "/"
    end
    dir_name = names[names.size - 2]
    if dir_name == "source"
        parent = "/"
    end
    file_name = names[names.size - 1]

    content = File.read entry
    imports = [] of String
    main_function_content_array = [] of String
    lines = content.split ";"
    lines.each do |line|
        if line.includes?("@import") || line.includes?("@embedFile")
            imports << line
        else
            main_function_content_array << line
        end
    end
    main_function_content = main_function_content_array.join ";"

    data = Unit_Data.new main_function_content, imports

    name = ""
    addon = nil
    global = false

    if file_name == "index.zig" || file_name == "(#{dir_name}).zig"
        dir_name.split(".").each do |name_part|
            case name_part
                when "get"
                    addon = UNIT_TYPE::GET
                    name = dir_name.split(".")[0]
                when "post"
                    addon = UNIT_TYPE::POST
                    name = dir_name.split(".")[0]
                when "put"
                    addon = UNIT_TYPE::PUT
                    name = dir_name.split(".")[0]
                when "delete"
                    addon = UNIT_TYPE::DELETE
                    name = dir_name.split(".")[0]
                when "head"
                    addon = UNIT_TYPE::HEAD
                    name = dir_name.split(".")[0]
                when "patch"
                    addon = UNIT_TYPE::PATCH
                    name = dir_name.split(".")[0]
                when "trace"
                    addon = UNIT_TYPE::TRACE
                    name = dir_name.split(".")[0]
                when "connect"
                    addon = UNIT_TYPE::CONNECT
                    name = dir_name.split(".")[0]
                when "options"
                    addon = UNIT_TYPE::OPTIONS
                    name = dir_name.split(".")[0]
            end
        end
    else
        file_name.split(".").each do |name_part|
            if name_part == "zig"
                next
            elsif name_part == "global"
                global = true
            else
                return_data = check_file_return_unit(name_part, dir_name.split(".")[0])
                addon = return_data.addon
                name_check = return_data.name
                if name_check.nil?
                    name = file_name.split(".")[0]
                else
                    name = name_check
                end
            end
        end
    end

    case file_name
        when "get.zig"
            addon = UNIT_TYPE::GET
            name = dir_name.split(".")[0]
        when "post.zig"
            addon = UNIT_TYPE::POST
            name = dir_name.split(".")[0]
        when "put.zig"
            addon = UNIT_TYPE::PUT
            name = dir_name.split(".")[0]
        when "delete.zig"
            addon = UNIT_TYPE::DELETE
            name = dir_name.split(".")[0]
        when "head.zig"
            addon = UNIT_TYPE::HEAD
            name = dir_name.split(".")[0]
        when "patch.zig"
            addon = UNIT_TYPE::PATCH
            name = dir_name.split(".")[0]
        when "trace.zig"
            addon = UNIT_TYPE::TRACE
            name = dir_name.split(".")[0]
        when "connect.zig"
            addon = UNIT_TYPE::CONNECT
            name = dir_name.split(".")[0]
        when "options.zig"
            addon = UNIT_TYPE::OPTIONS
            name = dir_name.split(".")[0]
    end

    unless addon.nil?
        if global
            case addon
                when UNIT_TYPE::GUARD
                    value << File_Unit.new name, UNIT_TYPE::GUARD_GLOBAL, data
                when UNIT_TYPE::PIPE
                    value << File_Unit.new name, UNIT_TYPE::PIPE_GLOBAL, data
                when UNIT_TYPE::INTERSEPTOR
                    value << File_Unit.new name, UNIT_TYPE::INTERSEPTOR_GLOBAL, data
                when UNIT_TYPE::SERVICE
                    value << File_Unit.new name, UNIT_TYPE::SERVICE_GLOBAL, data
                when UNIT_TYPE::MIDDLEWARE
                    value << File_Unit.new name, UNIT_TYPE::MIDDLEWARE_GLOBAL, data
            end
        else
            value << File_Unit.new name, addon, data
        end
    end
end

def walk_directory_source(path : String, branch : Route)
    read_directories = [] of String
    Dir.glob("#{path}/*") do |entry|
        unless File.directory?(entry)
            check_file entry, branch.value
        else
            read_directories << entry
        end
    end
    read_directories.each do |directory|
        branch.childrens << Route.new "#{branch.target}/#{directory.split("/").last.split(".").first}", [] of File_Unit, [] of Route
        walk_directory_source directory, branch.childrens.last
    end
end

def list_targets(route : Route, list : Array(String))
    list << route.target
    route.childrens.each do |children|
        list_targets children, list
    end
end

def render_imports(route : Route, imports : Array(String))
    route.value.each do |value|
        value.content.imports.each do |import|
            import_array = import.split "\""
            formatted_import = import_array[1].gsub "~", "."
            true_import = "#{import_array[0]}\"#{formatted_import}\"#{import_array[2]}"
            imports << true_import
        end
    end
    route.childrens.each do |children|
        render_imports children, imports
    end
end

def addon_values_by_routes(route : Route, values : Hash(String, Array(File_Unit)), global : Array(File_Unit))
    route.value.each do |value|
        name = value.name
        if name == "source"
            name = ""
        end
        global.each do |gl|
            begin
                values[name] << gl
            rescue KeyError
                values[name] = [] of File_Unit
                values[name] << gl
            end
        end
        if value.addon == UNIT_TYPE::GUARD_GLOBAL || value.addon == UNIT_TYPE::GUARD
            global << value
            begin
                values[name] << value
            rescue KeyError
                values[name] = [] of File_Unit
                values[name] << value
            end
        elsif value.addon == UNIT_TYPE::PIPE_GLOBAL || value.addon == UNIT_TYPE::PIPE
            global << value
            begin
                values[name] << value
            rescue KeyError
                values[name] = [] of File_Unit
                values[name] << value
            end
        elsif value.addon == UNIT_TYPE::INTERSEPTOR_GLOBAL || value.addon == UNIT_TYPE::INTERSEPTOR
            global << value
            begin
                values[name] << value
            rescue KeyError
                values[name] = [] of File_Unit
                values[name] << value
            end
        elsif value.addon == UNIT_TYPE::MIDDLEWARE_GLOBAL || value.addon == UNIT_TYPE::MIDDLEWARE
            global << value
            begin
                values[name] << value
            rescue KeyError
                values[name] = [] of File_Unit
                values[name] << value
            end
        end
    end
    route.childrens.each do |children|
        addon_values_by_routes children, values, global
    end
end

def values_into_routes(route : Route)
    route_names = [] of String
    value_files = [] of File_Unit
    route.value.each do |value|
        case value.addon
            when UNIT_TYPE::GET
                route_names << value.name
            when UNIT_TYPE::POST
                route_names << value.name
            when UNIT_TYPE::PUT
                route_names << value.name
            when UNIT_TYPE::DELETE
                route_names << value.name
            when UNIT_TYPE::HEAD
                route_names << value.name
            when UNIT_TYPE::PATCH
                route_names << value.name
            when UNIT_TYPE::TRACE
                route_names << value.name
            when UNIT_TYPE::CONNECT
                route_names << value.name
            when UNIT_TYPE::OPTIONS
                route_names << value.name
            else
                value_files << value
        end
    end
    route_names.each do |name|
        if name == route.target.split("/").last
            next
        end
        new_route = Route.new "#{route.target}/#{name}", [] of File_Unit, [] of Route
        value_files.each do |file|
            new_route.value << file
        end
        route.childrens << new_route
    end
    route.childrens.each do |children|
        values_into_routes children
    end
end

def target_functions_render(functions_list : Array(String), route : Route)
    if functions_list.size == 0
        route.value.each do |value|
            name = value.name
            if name == "source"
                name = ""
            end
            function_name = "target#{route.target.split("/").join("_")}_#{name}_#{value.addon}"
            if route.target.split("/").last == name
                function_name = "target#{route.target.split("/").join("_")}_#{value.addon}"
            end
            case value.addon
                when UNIT_TYPE::GET
                    functions_list << value.content.main_function_content.sub "main", function_name
                when UNIT_TYPE::POST
                    functions_list << value.content.main_function_content.sub "main", function_name
                when UNIT_TYPE::PUT
                    functions_list << value.content.main_function_content.sub "main", function_name
                when UNIT_TYPE::DELETE
                    functions_list << value.content.main_function_content.sub "main", function_name
                when UNIT_TYPE::HEAD
                    functions_list << value.content.main_function_content.sub "main", function_name
                when UNIT_TYPE::PATCH
                    functions_list << value.content.main_function_content.sub "main", function_name
                when UNIT_TYPE::TRACE
                    functions_list << value.content.main_function_content.sub "main", function_name
                when UNIT_TYPE::CONNECT
                    functions_list << value.content.main_function_content.sub "main", function_name
                when UNIT_TYPE::OPTIONS
                    functions_list << value.content.main_function_content.sub "main", function_name
            end
        end
    end
    route.childrens.each do |children|
        children.value.each do |value|
            name = value.name
            if name == "source"
                name = ""
            end
            function_name = "target#{children.target.split("/").join("_")}_#{name}_#{value.addon}"
            if children.target.split("/").last == name
                function_name = "target#{children.target.split("/").join("_")}_#{value.addon}"
            end
            case value.addon
                when UNIT_TYPE::GET
                    functions_list << value.content.main_function_content.sub "main", function_name
                when UNIT_TYPE::POST
                    functions_list << value.content.main_function_content.sub "main", function_name
                when UNIT_TYPE::PUT
                    functions_list << value.content.main_function_content.sub "main", function_name
                when UNIT_TYPE::DELETE
                    functions_list << value.content.main_function_content.sub "main", function_name
                when UNIT_TYPE::HEAD
                    functions_list << value.content.main_function_content.sub "main", function_name
                when UNIT_TYPE::PATCH
                    functions_list << value.content.main_function_content.sub "main", function_name
                when UNIT_TYPE::TRACE
                    functions_list << value.content.main_function_content.sub "main", function_name
                when UNIT_TYPE::CONNECT
                    functions_list << value.content.main_function_content.sub "main", function_name
                when UNIT_TYPE::OPTIONS
                    functions_list << value.content.main_function_content.sub "main", function_name
            end
        end
        target_functions_render functions_list, children
    end
end

record Plugin, number : Int32 | Nil, name : String, content : String

def scan_plugins(imports_out : Array(String), values : Array(Plugin))
    Dir.glob("./plugins/*") do |entry|
        unless File.directory?(entry)
            names = entry.split "/"

            parent = names[names.size - 3]
            if parent == "source"
                parent = "/"
            end
            dir_name = names[names.size - 2]
            if dir_name == "source"
                parent = "/"
            end
            file_name = names[names.size - 1]

            parts = file_name.split "."
            name = ""

            number = nil
            
            if parts.size == 2
                name = parts[0]
            else
                name = parts[1]
                if parts[0][0..0].matches?(/^\d+$/)
                    if parts[0][0..0] == "0"
                        number = parts[0][0..1].to_i
                    end
                end
            end

            content = File.read entry
            imports = [] of String
            main_function_content_array = [] of String
            lines = content.split ";"
            lines.each do |line|
                if line.includes?("@import") || line.includes?("@embedFile")
                    line = line.gsub "\n", ""
                    imports << line
                else
                    main_function_content_array << line
                end
            end
            main_function_content = main_function_content_array.join ";"

            imports_out += imports

            values << Plugin.new number, name, main_function_content
        end
    end
end

record Name_Value, name : String, value : String

def start_execute(debugger_state : Bool, verbose_level : String, no_guard : Bool, env_file_path : String | Nil)
    start_time = Time.monotonic
    content = File.read "main.zig"
    imports = [] of String
    main_struct_content_array = [] of String
    lines = content.split ";"
    lines.each do |line|
        if line.includes?("@import") || line.includes?("@embedFile")
            line = line.gsub "\n", ""
            imports << line
        else
            main_struct_content_array << line
        end
    end
    new_imports = [] of String
    imports.each do |import|
        import_array = import.split "\""
        formatted_import = import_array[1].gsub "~", "."
        true_import = "#{import_array[0]}\"#{formatted_import}\"#{import_array[2]}"
        new_imports << true_import
    end
    imports = new_imports
    main_struct_content = main_struct_content_array.join ";"

    main_struct_env = ""
    main_struct_port = ""
    main_struct_kernel_backlog = ""
    main_struct_max_http_headers_size = ""
    main_struct_max_request_body_size = ""

    main_parts = main_struct_content.split ","
    main_parts.each do |part|
        name_value = part.split "="
        if name_value.size == 3
            name_value = [name_value[1],name_value[2]]
        end
        if name_value.size == 1
            next
        end
        name = name_value[0]
        value = name_value[1]
        if name.includes? ".env"
            unless value.includes? "null"
                while value[0..0] == " "
                    value = value[1..]
                end
                value = value[1..(value.size - 2)]
                main_struct_env = value
            end
        elsif name.includes? ".port"
            unless value.includes? "null"
                while value[0..0] == " "
                    value = value[1..]
                end
                main_struct_port = value
            end
        elsif name.includes? ".kernel_backlog"
            unless value.includes? "null"
                while value[0..0] == " "
                    value = value[1..]
                end
                main_struct_kernel_backlog = value
            end
        elsif name.includes? ".max_http_headers_size"
            unless value.includes? "null"
                while value[0..0] == " "
                    value = value[1..]
                end
                main_struct_max_http_headers_size = value
            end
        elsif name.includes? ".max_request_body_size"
            unless value.includes? "null"
                while value[0..0] == " "
                    value = value[1..]
                end
                main_struct_max_request_body_size = value
            end
        end
    end

    env = nil
    if env_file_path.nil?
        unless main_struct_env == ""
            env = File.read main_struct_env
            env_array = env.split "\n"
            env = [] of Name_Value
            env_array.each do |env_line|
                name_value = env_line.split "="

                if name_value.size < 2 || name_value.size > 2
                    next
                end
                
                name = name_value[0]
                value = name_value[1]
                
                while name[-1..-1] == " "
                    name = name[0..-2]
                end
                while value[0..0] == " "
                    value = value[1..]
                end

                env << Name_Value.new name, value
            end
        end
    else
        env = File.read env_file_path
        env_array = env.split "\n"
        env = [] of Name_Value
        env_array.each do |env_line|
            name_value = env_line.split "="
            
            name = name_value[0]
            value = name_value[1]
            
            while name[-1..-1] == " "
                name = name[0..-2]
            end
            while value[0..0] == " "
                value = value[1..]
            end

            env << Name_Value.new name, value
        end
    end

    main_branch = Route.new "", [] of File_Unit, [] of Route
    walk_directory_source "./source", main_branch
    time = (Time.monotonic - start_time).nanoseconds
    if (Time.monotonic - start_time).milliseconds > 0
        time += (Time.monotonic - start_time).milliseconds * 1000
    end
    logger("CLI", "Render", "route", "Scanned Source Directory", "STEP { 1/8 }", time, "info")
    took_time = Time.monotonic
    values_by_routes = Hash(String, Array(File_Unit)).new

    addon_values_by_routes main_branch, values_by_routes, [] of File_Unit

    values_into_routes main_branch
    time = (Time.monotonic - took_time).nanoseconds
    if (Time.monotonic - took_time).milliseconds > 0
        time += (Time.monotonic - took_time).milliseconds * 1000
    end
    logger("CLI", "Render", "route", "Tokenized Files", "STEP { 2/8 }", time, "info")
    took_time = Time.monotonic

    addon_pointers = ""

    plugin_values = [] of Plugin

    # modify build.zig for modules
    scan_plugins imports, plugin_values
    # add dashboard
    # add debbuger

    targets_list = [] of String
    list_targets main_branch, targets_list
    targets_list_buffer = [] of String
    targets_list.each do |target|
        if target == "/source"
            targets_list_buffer.unshift "/"
        elsif target != ""
            targets_list_buffer << target
        end
    end
    targets_list = targets_list_buffer

    lines = [] of String
    time = (Time.monotonic - took_time).nanoseconds
    if (Time.monotonic - took_time).milliseconds > 0
        time += (Time.monotonic - took_time).milliseconds * 1000
    end
    logger("CLI", "Render", "route", "Started Rendering", "STEP { 3/8 }", time, "info")
    took_time = Time.monotonic

    render_imports main_branch, imports
    imports << "const logger = @import(\"./@perun/functions/logger.build.zig\").logger"
    plugin_lines = [] of String

    sorted_plugins = [] of Int32
    plugin_values.each do |value|
        the_number = value.number
        unless the_number.nil?
            sorted_plugins << the_number
        end
    end
    sorted_plugins.sort
    sorted_plugins.each do |plugin_number|
        plugin_values.each do |value|
            the_number = value.number
            unless the_number.nil?
                if the_number == plugin_number
                    number_string = the_number
                    if number_string < 10
                        number_string = "0#{number_string}"
                    end
                    imports_include = false
                    imports.each do |imp|
                        if imp.includes? "./plugins/#{number_string}.#{value.name}.zig"
                            imports_include = true
                        end
                    end
                    unless imports_include
                        imports << "\nconst #{value.name}_struct = @import(\"./plugins/#{number_string}.#{value.name}.zig\")"
                    end
                    plugin_lines << "    try #{value.name}_struct.main.init(std.heap.page_allocator);"
                end
            end
        end
        plugin_values.each do |value|
            the_number = value.number
            if the_number.nil?
                imports_include = false
                imports.each do |imp|
                    if imp.includes? "./plugins/#{value.name}.zig"
                        imports_include = true
                    end
                end
                unless imports_include
                    imports << "\nconst #{value.name}_struct = @import(\"./plugins/#{value.name}.zig\")"
                end
                plugin_lines << "    try #{value.name}_struct.main.init(std.heap.page_allocator);"
            end
        end
    end
    imports.uniq!
    imports.each do |import|
        lines << "#{import};"
    end

    to_write = ""
    lines.each do |line|
        to_write += line
    end
    to_write += "\n"

    lines = [] of String

    lines << ""

    if main_struct_port == ""
        main_struct_port = "8000"
    end
    if main_struct_kernel_backlog == ""
        main_struct_kernel_backlog = "2_147_483_647"
    end

    lines += [
        "pub fn main() !void {",
        "    var netServer = std.net.Address.listen(try std.net.Address.parseIp(\"127.0.0.1\", #{main_struct_port}), .{ .reuse_address = true, .kernel_backlog = #{main_struct_kernel_backlog} }) catch |err| {",
        "        try logger.format.e(\"Initialisation\", \"Main\", \"index\", \"Error, Server is Offline         \", \"{any}\", \"NO_TIME\", .{err});",
        "        return;",
        "    };",
        "    try logger.format.l(\"Initialisation\", \"Main\", \"index\", \"Server is Listening On Port      \", \"#{main_struct_port}\", \"NO_TIME\", .{});",
        "    var routeHashMap = std.StringHashMap(*const fn (*handlerStruct, []const u8) anyerror!void).init(std.heap.page_allocator);",
    ]

    lines << ""

    lines += plugin_lines

    lines.each do |line|
        to_write += "#{line}\n"
    end

    functions_list = [] of String
    target_functions_render functions_list, main_branch

    lines = [] of String
    targets_list.each do |target|
        if target == "/"
            lines << "    try routeHashMap.put(\"#{target}\", &target_);"
        else
            lines << "    try routeHashMap.put(\"#{target}\", &target#{target.split("/").join("_")});"
        end
    end
    time = (Time.monotonic - took_time).nanoseconds
    if (Time.monotonic - took_time).milliseconds > 0
        time += (Time.monotonic - took_time).milliseconds * 1000
    end
    logger("CLI", "Render", "route", "Routes were written", "STEP { 4/8 }", time, "info")
    took_time = Time.monotonic
    
    unless env.nil?
        lines << ""
        env.each do |name_value|
            lines << "    try environmentStruct.map.put(\"#{name_value.name}\", \"#{name_value.value}\");"
        end
    end

    to_write += "\n"
    lines.each do |line|
        to_write += "#{line}\n"
    end

    lines = [
        "    while (true) {",
        "        (try std.Thread.spawn(.{}, performWorkOnThread, .{&(try netServer.accept()), &routeHashMap})).detach();",
        "    }",
        "}",
        ""
    ]

    lines += [
        "fn performWorkOnThread(connection: *const std.net.Server.Connection, routeHashMap: *std.StringHashMap(*const fn (*handlerStruct, []const u8) anyerror!void)) !void {",
    ]

    unless main_struct_max_http_headers_size == ""
        lines << "    var buffer: [#{main_struct_max_http_headers_size}]u8 = undefined;"
    else
        lines << "    var buffer: [1024]u8 = undefined;"
    end

    lines += [
        "    const content = buffer[0..try connection.stream.read(buffer[0..])];",
        "    var headerParse = std.mem.split(u8, content, \"#{"\\"+"r"+"\\"+"n"}\");",
        "    var firstParse = std.mem.split(u8, headerParse.next().?, \" \");",
        "",
        "    const method = firstParse.next().?;",
        "    const target = firstParse.next().?;",
        "",
        "    var headers = std.StringHashMap([]const u8).init(std.heap.page_allocator);",
        "",
    ]

    unless main_struct_max_http_headers_size == ""
        lines += [
            "    while (headerParse.next()) |value| {",
            "        var parseLine = std.mem.split(u8, value, \":\");",
            "        if (parseLine.next()) |thingName| {",
            "            if (thingName.len == 0) break;",
            "            if (parseLine.next()) |thingValue| {",
            "                if (thingValue[0] == 32) {",
            "                    try headers.put(thingName, thingValue[1..]);",
            "                } else try headers.put(thingName, thingValue);",
            "            } else {",
            "               try connection.stream.writeAll(\"HTTP/1.1 431 Request Header Fields Too Large#{"\\"+"r"+"\\"+"n"}Content-Type: text/plain#{"\\"+"r"+"\\"+"n"}Content-Length: 0#{"\\"+"r"+"\\"+"n"}#{"\\"+"r"+"\\"+"n"}\");",
            "                return;",
            "            }",
            "        } else {",
            "            try connection.stream.writeAll(\"HTTP/1.1 431 Request Header Fields Too Large#{"\\"+"r"+"\\"+"n"}Content-Type: text/plain#{"\\"+"r"+"\\"+"n"}Content-Length: 0#{"\\"+"r"+"\\"+"n"}#{"\\"+"r"+"\\"+"n"}\");",
            "            return;",
            "        }",
            "    }",
        ]
    else
        lines += [
            "    while (headerParse.next()) |value| {",
            "        var parseLine = std.mem.split(u8, value, \":\");",
            "        const thingName = parseLine.next().?;",
            "        if (thingName.len == 0) break;",
            "        var thingValue = parseLine.next().?;",
            "        if (thingValue[0] == 32) {",
            "            thingValue = thingValue[1..];",
            "        }",
            "        try headers.put(thingName, thingValue);",
            "    }",
        ]
    end

    lines += [
        "",
        "    var body: []u8 = \"\";",
        "",
        "    while (headerParse.next()) |value| {",
        "        body = try std.mem.join(std.heap.page_allocator, \"#{"\\"+"r"+"\\"+"n"}\", &[_][]const u8{ body, value });",
        "    }",
        "",
    ]

    unless main_struct_max_request_body_size == ""
        lines += [
            "    if (headers.get(\"content-length\")) |content_length| {",
            "        if ((try std.fmt.parseInt(u64, content_length, 10)) > (buffer.len - content.len)) {",
            "            while (true) {",
            "                var streamBuffer: [2048]u8 = undefined;",
            "                const readBytes = try connection.stream.read(streamBuffer[0..]);",
            "                body = try std.mem.join(std.heap.page_allocator, \"\", &[_][]const u8{ body, streamBuffer[0..] });",
            "                if (#{main_struct_max_request_body_size} < body.len) {",
            "                    try connection.stream.writeAll(\"HTTP/1.1 413 Payload Too Large#{"\\"+"r"+"\\"+"n"}Content-Type: text/plain#{"\\"+"r"+"\\"+"n"}Content-Length: 0#{"\\"+"r"+"\\"+"n"}#{"\\"+"r"+"\\"+"n"}\");",
            "                    return;",
            "                }",
            "                if (readBytes < streamBuffer.len) break;",
            "            }",
            "        }",
            "    }",
            "",
        ]
    else
        lines += [
            "    if (headers.get(\"content-length\")) |content_length| {",
            "        if ((try std.fmt.parseInt(u64, content_length, 10)) > (buffer.len - content.len)) {",
            "            while (true) {",
            "                var streamBuffer: [2048]u8 = undefined;",
            "                const readBytes = try connection.stream.read(streamBuffer[0..]);",
            "                body = try std.mem.join(std.heap.page_allocator, \"\", &[_][]const u8{ body, streamBuffer[0..] });",
            "                if (readBytes < streamBuffer.len) break;",
            "            }",
            "        }",
            "    }",
            "",
        ]
    end

    lines += [
        "    var handler: handlerStruct = .{",
        "        .body = body,",
        "        .connection = connection,",
        "        .headers = &headers,",
        "    };",
        "",
        "    if (routeHashMap.get(target)) |routeOperation| {",
        "        try routeOperation(&handler, method);",
        "    } else try connection.stream.writeAll(\"HTTP/1.1 404 Not Found#{"\\"+"r"+"\\"+"n"}Content-Type: text/plain#{"\\"+"r"+"\\"+"n"}Content-Length: 0#{"\\"+"r"+"\\"+"n"}#{"\\"+"r"+"\\"+"n"}\");",
        "}",
        ""
    ]
    time = (Time.monotonic - took_time).nanoseconds
    if (Time.monotonic - took_time).milliseconds > 0
        time += (Time.monotonic - took_time).milliseconds * 1000
    end
    logger("CLI", "Render", "route", "Boilerplate Was Written", "STEP { 5/8 }", time, "info")
    took_time = Time.monotonic

    functions_list.each do |function|
        function_split = function.split "\n\n"
        function = function_split.join ""
        lines << function
    end

    to_write += "\n"
    lines.each do |line|
        to_write += "#{line}\n"
    end
    File.write "index.zig", to_write

    target_functions = Hash(String, Array(String)).new

    functions_list.each do |function|
        things = function.split("fn ")[1].split("(")[0].split("_")
        things.pop
        if things.size == 1
            things << ""
        end
        begin
            target_functions[things.join "_"] << function.split("fn ")[1].split("(")[0].split("_").last
        rescue KeyError
            target_functions[things.join "_"] = [] of String
            target_functions[things.join "_"] << function.split("fn ")[1].split("(")[0].split("_").last
        end
    end

    guard_number = 0

    to_write = ""
    lines = [] of String

    route_value_map = Hash(String, Value_Route).new

    in_thing = [] of Value_Route_Data

    just_after_function = [] of String
    time = (Time.monotonic - took_time).nanoseconds
    if (Time.monotonic - took_time).milliseconds > 0
        time += (Time.monotonic - took_time).milliseconds * 1000
    end
    logger("CLI", "Render", "route", "Started Writing Files' Content", "STEP { 6/8 }", time, "info")
    took_time = Time.monotonic

    targets_list.each do |target|
        target_time = Time.monotonic
        beginning = [] of String
        content = [] of String
        ending = [] of String
        out_content_write = ""

        function_name_rendered = "target#{target.split("/").join("_")}"

        methods = target_functions[function_name_rendered]

        index_method = 0
        lines << "fn #{function_name_rendered}(handler: *handlerStruct, method: []const u8) !void {"

        if function_name_rendered.ends_with? "_"
            function_name_rendered = function_name_rendered.rchop
        end

        begin
            route = function_name_rendered.split("_").last
            if route == "target"
                route = ""
            end

            values_by_routes[route].uniq!

            values_by_routes[route].each do |value|
                if value.addon == UNIT_TYPE::GUARD_GLOBAL
                    if no_guard
                        next
                    end
                    in_thing << Value_Route_Data.new value.name, value.addon, value.content.main_function_content
                    beginning << "if (try guard_global_#{value.name}(handler)) {"
                    ending << "} else try handler.response(406, \"Content-Type: text/plain\", null);"
                elsif value.addon == UNIT_TYPE::GUARD
                    if no_guard
                        next
                    end
                    in_thing << Value_Route_Data.new value.name, value.addon, value.content.main_function_content
                    beginning << "if (try guard_#{value.name}(handler)) {"
                    ending << "} else try handler.response(406, \"Content-Type: text/plain\", null);"
                elsif value.addon == UNIT_TYPE::INTERSEPTOR
                    value_content = value.content.main_function_content.split "\n"
                    value_content_buffer = [] of String
                    value_content.each do |content|
                        content.split(" ").each do |cnt|
                            unless cnt == ""
                                value_content_buffer << cnt
                            end
                        end
                    end
                    reader = [] of Interseptor_Content
                    count = 0
                    read_header_variables = [] of String

                    in_variables = [] of String
                    record_in = false
                    out_variables = [] of String
                    record_out = false

                    value_content_buffer.each do |vcb|
                        if vcb == "{"
                            count += 1
                        elsif vcb == "}" || vcb == "};"
                            count -= 1
                        end
                        if count != 0
                            if vcb.includes? "@\"_\"("
                                reader << Interseptor_Content.new "_", nil, vcb
                            elsif vcb.includes? "@\">\"("
                                in_variables += vcb.split("(")[1].split ":"
                                reader << Interseptor_Content.new ">", nil, vcb
                                record_in = true
                            elsif vcb.includes? "@\"<\"("
                                out_variables += vcb.split("(")[1].split ":"
                                reader << Interseptor_Content.new "<", nil, vcb
                                record_out = true
                            elsif reader.size > 0
                                if record_out
                                    if vcb[-1..-1] == ")"
                                        record_out = false
                                    else
                                        while vcb[-1..-1] == " "
                                            vcb = vcb[0..-2]
                                        end
                                        if vcb[-1..-1] == ","
                                        elsif vcb[-1..-1] == ":"
                                            out_variables << vcb[0..-2]
                                        end
                                    end
                                end
                                if record_in
                                    if vcb[-1..-1] == ")"
                                        record_in = false
                                    else
                                        in_variables << vcb
                                    end
                                end
                                name = reader.last.name
                                into = reader.last.into
                                reader_content = reader.last.content
                                reader_content += " #{vcb}"
                                reader.pop
                                reader << Interseptor_Content.new name, into, reader_content
                            end
                        end
                    end
                    reader_index = 0
                    reader.each do |rd|
                        name = reader[reader_index].name
                        into = reader[reader_index].into
                        cont = reader[reader_index].content
                        check_for_fn_token = reader[reader_index].content[-2..-1]
                        
                        if check_for_fn_token == "fn"
                            cont = cont[0...-2]
                        end
                        reader[reader_index] = Interseptor_Content.new name, into, cont
                        reader_index += 1
                    end
                    init_variables = [] of String
                    in_content = "fn"
                    out_content = "fn"
                    reader.each do |rd|
                        reader_index = 0
                        skip_iteration = 0
                        if rd.name == "_"
                            reader_content = rd.content.split " "
                            reader_content.each do |rdcnt|
                                if skip_iteration > 0
                                    skip_iteration -= 1
                                elsif rdcnt == "_" && reader_content[reader_index + 1] == "="
                                    skip_iteration += 2
                                else
                                    init_variables << rdcnt
                                end
                                reader_index += 1
                            end
                        elsif rd.name == ">"
                            reader_content = rd.content.split " "
                            reader_content.each do |rdcnt|
                                in_content += " #{rdcnt}"
                            end
                        elsif rd.name == "<"
                            reader_content = rd.content.split " "
                            reader_content.each do |rdcnt|
                                out_content += " #{rdcnt}"
                            end
                        end
                    end
                    count = 0
                    read_began = false
                    init_content = ""
                    init_variables.each do |iv|
                        if iv == "{"
                            count += 1
                            read_began = true
                        elsif iv == "}"
                            count -= 1
                        elsif read_began
                            init_content += " #{iv}"
                        end
                        if count == 0 && read_began
                            break
                        end
                    end
                    beginning << init_content
                    in_content = in_content.gsub "@\">\"", "@\">#{value.name}\""
                    in_name = "try @\">#{value.name}\"("

                    in_variables_buffer = [] of String
                    in_variables.each do |inv|
                        if inv != "" && inv != " "
                            in_variables_buffer << inv
                        end
                    end
                    in_variables = in_variables_buffer
                    if in_variables.size > 1
                        in_name += in_variables.join ", "
                    else
                        if in_variables.size > 0
                            in_name += in_variables[0]
                        end
                    end

                    if in_variables.size > 0
                        in_name += ");"
                        beginning << in_name
                        just_after_function << in_content
                    end

                    out_content = out_content.gsub "@\"<\"", "@\"<#{value.name}\""
                    out_name = "try @\"<#{value.name}\"("

                    out_variables_buffer = [] of String
                    out_variables.each do |otv|
                        if otv != "" && otv != " "
                            out_variables_buffer << otv
                        end
                    end
                    out_variables = out_variables_buffer
                    if out_variables.size > 1
                        out_name += out_variables.join ", "
                    else
                        if out_variables.size > 0
                            out_name += out_variables[0]
                        end
                    end

                    out_name += ");"
                    just_after_function << out_content
                    out_content_write = out_name
                end
            end
        rescue KeyError
        end
        
        method_array = [] of Int32
        methods.each do |method|
            case method
                when "GET"
                    method_array << 71
                when "DELETE"
                    method_array << 68
                when "HEAD"
                    method_array << 72
                when "OPTIONS"
                    method_array << 79
                when "PUT"
                    method_array.unshift 85
                when "POST"
                    method_array.unshift 79
                when "PATCH"
                    method_array.unshift 65
                when "PROPFIND"
                    method_array.unshift 82
            end
        end
        method_array_index = 0
        method_array.each do |number|
            method = ""
            case number
                when 71
                    method = "GET"
                when 68
                    method = "DELETE"
                when 72
                    method = "HEAD"
                when 79
                    if method_array_index == 0
                        method = "POST"
                    else
                        method = "OPTIONS"
                    end
                when 85
                    method = "PUT"
                when 65
                    method = "PATCH"
                when 82
                    method = "PROPFIND"
            end
            if method_array_index == 0
                if number == 85 || number == 79 || number == 65 || number == 82
                    content << "    if (method[0] == 80) {"
                    p_index = 0
                    method_array.each do |p_number|
                        if p_number != 85 && p_number != 79 && p_number != 65 && p_number != 82
                            break
                        end
                        if p_index == 0
                            content << "        if (method[1] == #{p_number}) {"
                            content << "            try #{function_name_rendered}_#{method}(handler);"
                            
                        else
                            content << "        else if (method[1] == #{p_number}) {"
                            content << "            try #{function_name_rendered}_#{method}(handler);"
                        end
                        content << "        } else try handler.response(405, \"Content-Type: text/plain\", null);"
                        p_index += 1
                    end
                    content << "    }"
                else
                    content << "    if (method[0] == #{number}) {"
                    content << "        try #{function_name_rendered}_#{method}(handler);"
                    content << "    }"
                end
            else
                if number == 85 || number == 79 || number == 65 || number == 82
                    next
                else
                    content << "    else if (method[0] == #{number}) {"
                    content << "        try #{function_name_rendered}_#{method}(handler);"
                    content << "    }"
                end
            end
            method_array_index += 1
        end
        content << "    else try handler.response(405, \"Content-Type: text/plain\", null);"

        thing = 4
        beginning.each do |bg|
            lines << "#{" " * thing}#{bg}"
            thing += 4
        end
        thing -= 4
        content.each do |ct|
            lines << "#{" " * thing}#{ct}"
        end
        unless out_content_write == ""
            lines << out_content_write
        end
        ending.each do |en|
            lines << "#{" " * thing}#{en}"
            thing -= 4
        end
        lines << "}"

        if verbose_level == "v"
            time = (Time.monotonic - target_time).nanoseconds
            if (Time.monotonic - target_time).milliseconds > 0
                time += (Time.monotonic - target_time).milliseconds * 1000
            end
            logger("CLI", "Render", "route", "This Target Was Rendered", "#{target}", time, "verbose")
        end
    end
    lines.each do |line|
        to_write += "#{line}\n"
    end
    in_thing.uniq!
    in_thing.each do |thing|
        if thing.token == UNIT_TYPE::GUARD_GLOBAL
            to_write += thing.value.gsub "fn main(", "fn guard_global_#{thing.name}("
        elsif thing.token == UNIT_TYPE::GUARD
            to_write += thing.value.gsub "fn main(", "fn guard_#{thing.name}("
        end
    end
    just_after_function.uniq!
    just_after_function.each do |jaf|
        if jaf == "fn"
            next
        end
        to_write += "#{jaf}\n"
    end
    time = (Time.monotonic - took_time).nanoseconds
    if (Time.monotonic - took_time).milliseconds > 0
        time += (Time.monotonic - took_time).milliseconds * 1000
    end
    logger("CLI", "Render", "route", "Render Was Completed", "STEP { 7/8 }", time, "info")
    file_content = "#{File.read "index.zig"}#{to_write}"
    File.write "index.zig", file_content
    time = (Time.monotonic - start_time).nanoseconds
    if (Time.monotonic - start_time).milliseconds > 0
        time += (Time.monotonic - start_time).milliseconds * 1000
    end
    logger("CLI", "Render", "route", "Asking Zig To Build Project", "FINISHED", time, "info")
    section
    if system "zig build run"
        edit_count = 0
        file_modification_times = {} of String => Time
        loop do
            sleep 1
            Dir.glob("./**/*.zig").each do |file|
                modified_at = File.info(file).modification_time
                if file_modification_times[file]? != modified_at
                    edit_count += 1
                    file_modification_times[file] = modified_at
                    start_execute(debugger_state, verbose_level, no_guard, env_file_path)
                end
            end
        end
    else
        logger("CLI", "Render", "route", "There Is An Error, Check \"index.zig\"", "FAILED", 0, "error")
    end
end