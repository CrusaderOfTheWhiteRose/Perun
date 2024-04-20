require "./logger.function"

record Directory_FS_Unit, directory : String, file_system : Array(Directory_FS_Unit) | Array(File_FS_Unit) | Array(Directory_FS_Unit | File_FS_Unit)
record File_FS_Unit, file : String, value : String

def file_unit_hashmap
    { 
        "default" => Directory_FS_Unit.new(".", [
            Directory_FS_Unit.new("@perun", [
                Directory_FS_Unit.new("core", [
                    File_FS_Unit.new("handler.struct.zig", {{ read_file "embed/@perun/core/handler.struct.zig" }}),
                    File_FS_Unit.new("parse.struct.zig", {{ read_file "embed/@perun/core/parse.struct.zig" }}),
                    File_FS_Unit.new("server.struct.zig", {{ read_file "embed/@perun/core/server.struct.zig" }}),
                ]),
                Directory_FS_Unit.new("functions", [
                    File_FS_Unit.new("logger.build.zig", {{ read_file "embed/@perun/functions/logger.build.zig" }}),
                ]),
                Directory_FS_Unit.new("modules", [
                    File_FS_Unit.new("environment.build.zig", {{ read_file "embed/@perun/modules/environment.build.zig" }}),
                ]),
            ]),
            File_FS_Unit.new(".env", {{ read_file "embed/.env" }}),
            File_FS_Unit.new(".gitignore", {{ read_file "embed/.gitignore" }}),
            File_FS_Unit.new("build.zig", {{ read_file "embed/build.zig" }}),
            File_FS_Unit.new("main.zig", {{ read_file "embed/main.zig" }}),
        ]),
        "minimal" => Directory_FS_Unit.new(".", [
            Directory_FS_Unit.new("source", [
                File_FS_Unit.new("get.zig", {{ read_file "embed/minimal/source/get.zig" }}),
            ]),
        ]),
        "standart" => Directory_FS_Unit.new(".", [
            Directory_FS_Unit.new("source", [
                Directory_FS_Unit.new("hello.get", [
                    File_FS_Unit.new("(hello.get).zig", {{ read_file "embed/standart/source/hello.get/(hello.get).zig" }}),
                    File_FS_Unit.new("guard.zig", {{ read_file "embed/standart/source/hello.get/guard.zig" }}),
                    File_FS_Unit.new("interseptor.zig", {{ read_file "embed/standart/source/hello.get/interseptor.zig" }}),
                ]),
            ]),
        ]),
        "complex" => Directory_FS_Unit.new(".", [
            Directory_FS_Unit.new("assets", [] of File_FS_Unit),
            Directory_FS_Unit.new("modules", [
                Directory_FS_Unit.new("c_printf_wrapper", [
                    File_FS_Unit.new("c_printf_wrapper.c", {{ read_file "embed/complex/modules/c_printf_wrapper/c_printf_wrapper.c" }}),
                    File_FS_Unit.new("c_printf_wrapper.h", {{ read_file "embed/complex/modules/c_printf_wrapper/c_printf_wrapper.h" }}),
                ]),
            ]),
            Directory_FS_Unit.new("plugins", [
                File_FS_Unit.new("01.first.zig", {{ read_file "embed/complex/plugins/01.first.zig" }}),
            ]),
            Directory_FS_Unit.new("source", [
                Directory_FS_Unit.new("hello.get", [
                    Directory_FS_Unit.new("send.post", [
                        File_FS_Unit.new("index.zig", {{ read_file "embed/complex/source/hello.get/send.post/index.zig" }}),
                        File_FS_Unit.new("guard.zig", {{ read_file "embed/complex/source/hello.get/send.post/guard.zig" }}),
                    ]),
                    File_FS_Unit.new("(hello.get).zig", {{ read_file "embed/complex/source/hello.get/(hello.get).zig" }}),
                    File_FS_Unit.new("interseptor.zig", {{ read_file "embed/complex/source/hello.get/interseptor.zig" }}),
                    File_FS_Unit.new("more_stuff.zig", {{ read_file "embed/complex/source/hello.get/more_stuff.zig" }}),
                ]),
                File_FS_Unit.new("guard.global.zig", {{ read_file "embed/complex/source/guard.global.zig" }}),
                File_FS_Unit.new("remove.delete.zig", {{ read_file "embed/complex/source/remove.delete.zig" }}),
            ]),
            Directory_FS_Unit.new("utilities", [
                File_FS_Unit.new("odd.zig", {{ read_file "embed/complex/utilities/odd.zig" }}),
            ]),
        ]),
    }
end

def iterate_directories(unit : Directory_FS_Unit, path : String, verbose_level : Int32)
    unit.file_system.each do |sub_unit|
        if sub_unit.is_a?(Directory_FS_Unit)
            start_time = Time.monotonic
            Dir.mkdir_p("#{path}/#{sub_unit.directory}")
            if verbose_level == 0
                time = (Time.monotonic - start_time).nanoseconds
                if (Time.monotonic - start_time).milliseconds > 0
                    time += (Time.monotonic - start_time).milliseconds * 1000
                end
                logger("Index", "Init", "route", "Directory Was Written", "#{sub_unit.directory}", time, "verbose")
            end
            iterate_directories(sub_unit, "#{path}/#{sub_unit.directory}", verbose_level)
        elsif sub_unit.is_a?(File_FS_Unit)
            start_time = Time.monotonic
            File.write "#{path}/#{sub_unit.file}", sub_unit.value
            if verbose_level == 0
                time = (Time.monotonic - start_time).nanoseconds
                if (Time.monotonic - start_time).milliseconds > 0
                    time += (Time.monotonic - start_time).milliseconds * 1000
                end
                logger("Index", "Init", "route", "File Was Written", "#{sub_unit.file}", time, "verbose")
            end
        end
    end
end

def initialisate_execute(project_name : String, complexity_level : String, verbose_level : String, this_directory : Bool)
    start_time = Time.monotonic

    logger("Index", "Init", "route", "Project Initialistion Just Began [#{complexity_level.upcase}]:[#{verbose_level.upcase}]", "#{project_name}", 0, "info")

    verbose_level_int = 0
    case verbose_level
        when "v"
            verbose_level_int = 0
        when "i"
            verbose_level_int = 1
        when "w"
            verbose_level_int = 2
        when "e"
            verbose_level_int = 3
    end

    write_package_name = "default"

    if this_directory
        iterate_directories file_unit_hashmap[write_package_name], "./", verbose_level_int
    else
        iterate_directories file_unit_hashmap[write_package_name], "#{project_name}/", verbose_level_int
    end

    time = (Time.monotonic - start_time).nanoseconds
    if (Time.monotonic - start_time).milliseconds > 0
        time += (Time.monotonic - start_time).milliseconds * 1000
    end
    logger("Index", "Init", "route", "Main Package Was Written", "STEP { 1/3 }", time, "info")

    case complexity_level
        when "m"
            write_package_name = "minimal"
        when "s"
            write_package_name = "standart"
        when "c"
            write_package_name = "complex"
    end

    if this_directory
        iterate_directories file_unit_hashmap[write_package_name], "./", verbose_level_int
    else
        iterate_directories file_unit_hashmap[write_package_name], "#{project_name}/", verbose_level_int
    end
    
    time = (Time.monotonic - start_time).nanoseconds
    if (Time.monotonic - start_time).milliseconds > 0
        time += (Time.monotonic - start_time).milliseconds * 1000
    end
    logger("Index", "Init", "route", "Sub Package Was Written", "STEP { 2/3 }", time, "info")

    if this_directory
        File.write(File.join("./", "build.zig"), File.read(File.join("./", "build.zig")).gsub("[project-name]", File.basename(Dir.current)))
    else
        File.write(File.join(project_name, "build.zig"), File.read(File.join(project_name, "build.zig")).gsub("[project-name]", project_name))
    end
    
    time = (Time.monotonic - start_time).nanoseconds
    if (Time.monotonic - start_time).milliseconds > 0
        time += (Time.monotonic - start_time).milliseconds * 1000
    end
    logger("Index", "Init", "route", "Final Preparations Finished", "STEP { 3/3 }", time, "info")
end
