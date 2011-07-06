class Project < PivotalItem
  require 'iconv'

  self.site = "http://www.pivotaltracker.com/services/v3"

  RFC_2822_EMAIL_PERMITTED_CHARACTERS = /[^a-zA-Z0-9!#$\%&'*+-\/=?^_`{|}~]/

  def self.compare_names(name1,name2)
    str1 = standarize_name(name1)
    str2 = standarize_name(name2)

    str1_c = Iconv.conv('UTF-8//IGNORE','UTF-8',str1)
    str2_c = Iconv.conv('UTF-8//IGNORE','UTF-8',str2)
    

    Rails.logger.info "@@@@@@ Normalized names: #{str1_c} == #{str2_c} #{str1_c==str2_c}"

    str1 == str2
  end
  
  def self.standarize_name(name)
    name = name.gsub(/[\t\s]/,'')
    #name = name.gsub(RFC_2822_EMAIL_PERMITTED_CHARACTERS,'').downcase
    name
  end
  
  def self.find_project_by_name(name,token)
    Project.token = token
    all_projects =  Project.find(:all)
    all_projects.select{|p| Project.compare_names(p.name,name) }.first
  end
  
end
