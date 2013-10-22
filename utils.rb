def fetch_project_export site, token
  open("#{site}/publication/#{token}/project")
end
