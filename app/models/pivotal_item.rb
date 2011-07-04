class PivotalItem < HyperactiveResource

  def self.token()
    self.headers['X-TrackerToken']
  end

  def self.token=(token)
     self.headers['X-TrackerToken'] = (token || "")
  end
end
