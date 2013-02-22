# config.ru

require './students_app'
run Sinatra::Application

$stdout.sync = true
