namespace :screens do
  task dry: :environment do
    Screen.dry_screens
  end
end
