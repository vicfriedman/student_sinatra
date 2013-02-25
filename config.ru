# config.ru

require './students_app'
require 'sinatra/reloader'
run Sinatra::Application

$stdout.sync = true
