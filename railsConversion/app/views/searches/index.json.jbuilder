json.array!(@searches) do |search|
  json.extract! search, :id, :userQuery
  json.url search_url(search, format: :json)
end
