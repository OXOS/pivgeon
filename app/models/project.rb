class Project < PivotalItem
  self.site = "http://www.pivotaltracker.com/services/v3"
  
  RFC_2822_EMAIL_PERMITTED_CHARACTERS = %W{! # $ % & ' * + - / = ? ^ _ ` { | } ~]}

  def self.compare_names(name1,name2)
    str1 = standarize_name(name1)
    str2 = standarize_name(name2)
    str1 == str2
  end
  
  def self.standarize_name(name)
    name.gsub(/[\t\s]/,'').gsub(/^[a-zA-Z0-9#{RFC_2822_EMAIL_PERMITTED_CHARACTERS.join}]/,'').downcase
  end
  
  def self.find_project_by_name(name,token)
    Project.token = token
    
    Project.find(:all).select{|p| Project.compare_names(p.name,name) }.first
  end
  
end
