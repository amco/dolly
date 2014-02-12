namespace :db do
  desc "Will create if missing database and add default views"
  task setup: :environment do
    Dolly::Document.database.put "", nil
    puts "Database created"
  end

  desc "Will update design document with what is on db/designs/*.coffee"
  task design: :environment do
    path = File.join Rails.root, 'db', 'designs'
    files = Dir.glob("#{path}/*.coffee")
    views = {}
    filters = {}

    files.each do |filename|
      name, key  = File.basename(filename).sub(/.coffee/i, '').split(/\./)
      key ||= 'map'
      data = File.read filename

      if key == 'filter'
        filters[name] ||= data
      else
        views[name] ||= {}
        views[name][key] = data
      end
    end

    view_doc = {
      '_id' => Dolly::Document.design_doc,
      'language' => 'coffeescript',
      'views' => views,
      'filters' => filters
    }

    begin
      hash_doc = JSON::parse Dolly::Document.database.get(view_doc["_id"]).parsed_response

      rev = hash_doc.delete('_rev')

      if hash_doc == view_doc
        puts 'everything up to date'
      else
        view_doc["_rev"] = rev
        view_doc["views"].merge!(hash_doc['views'])
        puts 'updating design document'
        will_save = true
      end

    rescue Dolly::ResourceNotFound
      puts 'creating design document'
      will_save = true
    end

    Dolly::Document.database.put Dolly::Document.design_doc, view_doc.to_json if will_save
  end

end
