class Project < HyperactiveResource
  self.site = "http://www.pivotaltracker.com/services/v3"
  
  include Pivgeon::Token
  tokenize()
  
  def self.find_project_by_name(name,token)
    Project.token = token  
    Project.find(:all).select{|p| p.name.match(/^#{name}$/i) }.first
  end
  
end
