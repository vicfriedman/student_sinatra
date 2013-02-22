# require 'rubygems'
# require 'nokogiri'
# require 'open-uri'
require 'pry'
require 'data_mapper'
require 'dm-postgres-adapter'
require 'TYLER'

ENV['DATABASE_URL'] ||= 'postgres://Victoria:@localhost/flatiron_students'
 
DataMapper.setup(:default, ENV['DATABASE_URL'])

def db_migrate
  DataMapper.auto_migrate!
  "Database migrated! All students in table!"
end


# INDEX = "http://students.flatironschool.com/"
# # INDEX_DOC = Nokogiri::HTML(open(INDEX))

# student_urls = INDEX_DOC.css("div.one_third > a").map do |a| 

#     (INDEX + a.attr("href")).sub("/.", "" )

# end


class Student
  include DataMapper::Resource
  
  property :id, Serial            # Auto-increment integer id
  property :name, String            
  property :tagline, Text         # A short string of text
  property :intro_paragraph, Text         # A longer text block
  property :social_links, Text # Auto assigns data/time
  property :work, Text
  property :education, Text
  property :coder_cred, Text
  property :blog_link, Text
  property :fav_companies, Text
  property :fav_websites, Text
  property :quotes, Text



  # def initialize(params={}) 
  #   @id = params[:id]
  #   @name = params[:name]
  #   @tagline = params[:tagline]
  #   @intro_paragraph = params[:intro_paragraph]
  #   @social_links = params[:social_links]
  # end

  def scrape_and_insert(url)
    begin
    @doc = Nokogiri::HTML(open(url))
    self.scrape_name
    self.scrape_tagline
    self.scrape_student_intro_paragraph
    self.scrape_social_links
    self.scrape_work
    self.scrape_education
    self.scrape_coder_cred
    self.scrape_blog_link
    self.scrape_fav_companies
    self.scrape_fav_websites
    self.scrape_quotes
    self.save

  rescue => ex
    puts "except #{ex} on #{url}"
      yield ex
    end
  end


  def scrape_name
    self.name = @doc.css("h1").inner_text
  end

  def scrape_tagline
    self.tagline = @doc.css("section#about h2").text
  end

  def scrape_student_intro_paragraph
    self.intro_paragraph = @doc.css("section#about p:nth(1)").text
  end

  def scrape_social_links
    self.social_links = (@doc.css("div.social_icons a").map do |social_link|
      social_link.attr("href")
    end).join(", ")
  end

  def scrape_work
    self.work = @doc.css("section#former_life div.one_half:nth(1) li a").map do |a|
      description = a.inner_text
      link = a.attr("href")
      position = {:description => description,
                  :link => link}
    end
  end

  def scrape_education
    self.education = @doc.css("section#former_life div.one_half.last ul li a").map do |a|
      description = a.inner_text
      link = a.attr("href")
      position = {:description => description,
                  :link => link}
    end
  end

  def scrape_coder_cred
    self.coder_cred = @doc.css(".columns.coder_cred td a").map do |a|
      a.attr("href")
    end
  end

  def scrape_blog_link
    self.blog_link = @doc.css(".columns.coder_cred div p a").map do |a|
      a.attr("href")
    end
  end

  def scrape_fav_companies
    self.fav_companies = @doc.css("#favorites div.columns:nth(1) a") do |a|
      description= a.inner_text
      link = a.attr("href")
      position = {:description => description,
                  :link => link}
    end
  end

  def scrape_fav_websites
    self.fav_websites = @doc.css("#favorites div.columns:nth(2) a") do |a|
      description = a.inner_text
      link = a.attr("href")
      position = {:description => description,
                  :link => link}
    end
  end

  def scrape_quotes
    self.quotes = @doc.css(".one_fourth p").text
  end

end

#end of class

DataMapper.finalize
DataMapper.auto_upgrade!

def student_scraper
  student_urls.each do |student|
    begin
    hella_student = Student.new
    hella_student.scrape_and_insert(student)
      hella_student.save
      "Success!"
    rescue => e
      puts "Error creating #{student}: #{e}"
      next
    end
  end
end




