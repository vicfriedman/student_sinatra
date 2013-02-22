require './sinatrastudents'
require 'sinatra'

get '/' do
  @students = Student.all
  erb :students
end


