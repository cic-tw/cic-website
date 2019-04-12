namespace :export do
  task :users => [ :environment ] do
    users = ""
    User.all.each do |u|
      user = "#{u.name}, #{u.email}\n"
      users += user
    end
    File.write(Rails.root.join('files', 'users.csv'), users)
  end
end
