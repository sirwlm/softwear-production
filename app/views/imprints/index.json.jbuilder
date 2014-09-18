json.array!(@imprints) do |imprint|
  json.extract! imprint, :id
  json.url imprint_url(imprint, format: :json)
end
