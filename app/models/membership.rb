class Membership < HyperactiveResource
  self.site = "http://www.pivotaltracker.com/services/v3/projects/:project_id"
  
  def self.token=(token)
    self.headers['X-TrackerToken'] = (token ? token : "")
  end
  
end
