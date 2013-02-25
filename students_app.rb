require './sinatrastudents'
require 'sinatra'

get '/' do
  @students = Student.all
  erb :students
end


get '/:slug' do 
  @student = Student.first(:slug => params[:slug])
  erb :profile
end

