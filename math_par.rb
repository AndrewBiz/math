#!/usr/bin/env ruby -U
# encoding: UTF-8
# (с) ANB Andrew Bizyaev Андрей Бизяев 

require 'pony'
require 'date'

Vars = ["a", "b", "c", "d", "e", "f", "g", "h"]
Signs = ["+", "-", "-"]
$text = ""

def par1_in_good_position(pos, expr)
  check_item = expr[pos]
  Vars.member?(check_item)||(check_item == "(")
end

def par2_in_good_position(pos, expr)
  check_item = expr[pos-1]
  Vars.member?(check_item)||(check_item == ")")
end

def expr_to_s( expr )
  expr_str = ""
  expr.each {|v| expr_str += v}
  expr_str
end

def generate_expr( max_var, num_var, num_par)
  # Step 1 - generating var sequence
  expr = []
  vars_used = []
  num_var.times do |i|
    cur_var = Vars[rand(max_var)]
    vars_used << cur_var
    expr << Signs[rand(Signs.size)]
    expr << cur_var
  end
  #p expr_to_s expr

  # Step 2 - adding parentesies
  num_par.times do |i|
    par2 = 1 + rand(expr.size)
    #p "par2 beg #{par2}"   
    # searching for proper place for ")"
    par2 += 1 until par2_in_good_position(par2, expr)
    #p "par2 end #{par2}"   
    expr[par2, 0] = ")"
    par1 = 1 + rand(par2-1)
    #p "par1 beg #{par1}"   
    # searching for proper place for "("
    par1 -= 1 until par1_in_good_position(par1, expr)
    #p "par1 end #{par1}"   
    expr[par1, 0] = "("
    #p expr_to_s expr 
  end

  # Step 3 - generating values
  expr_vars = ""
  vars_used.uniq!.sort!
  vars_used.each { |v| expr_vars += "#{v} = #{rand(21)}\n" }
  
  # Step 4 - generating expression for teacher
  [expr_to_s(expr), expr_vars]
end

def puts_anb msg, output=true
  $text << msg+"\n"
  puts msg if output
end

begin #*** GLOBAL BLOCK
  # expr = ["-", "(", "a", "-", "b", ")", "+", "c"]
  t_start = DateTime.now
  print "Ваше имя: "
  name_student = STDIN.gets
  name_student.strip!.chomp!

  max_tasks = 5
  param_tasks = ARGV[0].to_i
  if param_tasks == 0 or param_tasks > max_tasks
    num_tasks = max_tasks
  else
    num_tasks = param_tasks
  end

  difficulty = [[3,4,2], [3,6,3], [4,8,4], [4,10,5], [5,12,6], [5,14,8]]
  num_ok = 0
  num_tasks.times do |t|
    s1, s2, s3 = difficulty[t]
    puts_anb "*****************************************************"
    puts_anb "Задача №#{t+1} из #{num_tasks}. Сложность #{s1*s2*s3}"

    expr_teacher, expr_vars = generate_expr(s1, s2, s3)
    puts_anb "Раскрыть скобки в выражении: #{expr_teacher}"
    print "Введите ответ: "
    expr_student = STDIN.gets
    expr_student.strip!.chomp!
    puts "Ответ принят"
    begin
       result_student = eval(expr_vars+expr_student)
    rescue Exception => e
       puts_anb "Введено некоректное математическое выражение", false
       result_student = nil
    end
    puts_anb "Проверка ответа:", false
    puts_anb expr_vars, false
    result_teacher = eval(expr_vars+expr_teacher)
    puts_anb "Исходное выражение : #{expr_teacher} = #{result_teacher}", false
    puts_anb "Полученный ответ   : #{expr_student} = #{result_student}", false
    if result_student == result_teacher
      num_ok += 1
      puts_anb "ПРАВИЛЬНО!", false
    else
      puts_anb "НЕПРАВИЛЬНО!", false
    end
    puts_anb "*****************************************************"
  end
  puts_anb "ВСЕГО правильно решено #{num_ok} из #{num_tasks}", false
  t_finish = DateTime.now
  puts_anb "Затрачено времени: #{((t_finish-t_start)*86400.0).to_f.round(1)} сек.", false

  puts "*** Суммарные результаты ***"
  puts $text

  # отправить по почте
  #p ENV['SEND_ROBOT_PASSWORD']
  email_from = 'robot.anblab@gmail.com'
  address_to = ['andrew.bizyaev@gmail.com']
  Pony.options = { from: email_from, charset: 'utf-8', via: :smtp,
    via_options: { address: 'smtp.gmail.com', port: '587', enable_starttls_auto: true, 
      user_name: email_from, password: ENV['SEND_ROBOT_PASSWORD'], authentication: :plain, 
        domain: "localhost.localdomain"} }

  address_to.each do |a|
  begin
    puts "sending to #{a}..."
    Pony.mail( to: a,
               subject: "#{name_student} - результаты теста по математике (решено #{num_ok} из #{num_tasks})",
               body: $text )
    puts "Ok"
  rescue Exception => e
    $stderr.puts "ERROR #{e.message}"
  end

end


rescue SignalException => e
  $stderr.puts "Exit on user interrupt Ctrl-C"
  exit(-1)

rescue Exception => e
  $stderr.puts e.message
  exit(-1)
end # *** GLOBAL BLOCK
