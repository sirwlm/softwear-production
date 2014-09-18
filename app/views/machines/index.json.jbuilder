json.array!(@machines) do |machine|
  json.extract! machine, :id
  json.url machine_url(machine, format: :json)
end
