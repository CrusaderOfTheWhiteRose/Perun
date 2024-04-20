def logger(process : String, sub_process : String, file : String, content : String, value : String, time : Int32, type : String)
    content_lenght = 40
    show_time =  " # [TOOK_NO_TIME]"
    if time >= 1_000_000_000
        show_time = " # [#{(time / 1_000_000_000).to_i}] Seconds"
    elsif time >= 1_000_000
        show_time = " # [#{(time / 1_000_000).to_i}] MilliSeconds"
    elsif time > 0
        show_time = " # [#{time}] NanoSeconds"
    end
    content_left_lenght = content_lenght - content.size
    if content_left_lenght < 0
        content_left_lenght = 0    
    end
    value_left_lenght = 20 - value.size
    if value_left_lenght < 0
        value_left_lenght = 0
    end
    if type == "info"
        puts "    #{process} :: #{sub_process} @ [#{file}] > #{content} #{" " * content_left_lenght}| [#{value}]#{" " * value_left_lenght}#{show_time}".colorize(:light_green)
    elsif type == "verbose"
        puts "    #{process} :: #{sub_process} @ [#{file}] > #{content} #{" " * content_left_lenght}| [#{value}]#{" " * value_left_lenght}#{show_time}".colorize(:light_blue)
    elsif type == "warning"
        puts "    #{process} :: #{sub_process} @ [#{file}] > #{content} #{" " * content_left_lenght}| [#{value}]#{" " * value_left_lenght}#{show_time}".colorize(:light_yellow)
    elsif type == "error"
        puts "    #{process} :: #{sub_process} @ [#{file}] > #{content} #{" " * content_left_lenght}| [#{value}]#{" " * value_left_lenght}#{show_time}".colorize(:light_red)
    elsif type == "fatal"
        puts "    #{process} :: #{sub_process} @ [#{file}] > #{content} #{" " * content_left_lenght}| [#{value}]#{" " * value_left_lenght}#{show_time}".colorize(:white)
    else
        puts "    #{process} :: #{sub_process} @ [#{file}] > #{content} #{" " * content_left_lenght}| [#{value}]#{" " * value_left_lenght}#{show_time}".colorize(:light_magenta)
    end
end

def section
    content_lenght = `stty size`.chomp().split(' ')[1].to_i
    puts "#{"-" * content_lenght}".colorize(:light_blue)
end