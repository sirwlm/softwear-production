Dir[Rails.root + 'app/models/**/*.rb'].each do |file|
  next if file.include?('/concerns/')

  /app\/models\/(?<model_name>[\w\/]+\.rb)/ =~ file
  Kernel.const_get "#{model_name.gsub('.rb', '').camelize}" rescue nil
end
