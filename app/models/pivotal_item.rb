class PivotalItem < HyperactiveResource

  def token()
    self.headers['X-TrackerToken']
  end

  def token=(token)
     self.headers['X-TrackerToken'] = (token || "")
  end
end
