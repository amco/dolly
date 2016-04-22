namespace :db do
  desc "Will create if missing database and add default views"
  task setup: :environment do
    Dolly::Document.database.put "", nil
    puts "Database created"
  end

  desc "Will update design document with what is on db/designs/*.coffee"
  task design: :environment do
    design_dir = Rails.root.join 'db', 'designs'
    files = Dir.glob File.join design_dir, '**', '*.coffee'
    data = {}

    files.each do |filename|
      parts = filename[design_dir.to_s.length+1..-1].split '/'
      design_doc_name = parts.count == 1 ? Dolly::Document.design_doc : "_design/#{parts.first}"

      name, key  = File.basename(filename).sub(/.coffee/i, '').split(/\./)
      key ||= 'map'
      source = File.read filename

      vd = data[design_doc_name] ||= { 'views' => {}, 'filters' => {}, 'lists' => {}, 'lib' => {} }

      if key == 'filter'
        vd['filters'][name] = source
      elsif key == 'lists'
        vd['lists'][name] = source
      elsif key == 'lib'
        v = vd['views']['lib'] ||= {}
        v[name] = source
      else
        v = vd['views'][name] ||= {}
        v[key] = source
      end
    end

    data.each do |design_doc_name, view_doc|
      view_doc.merge!( '_id' => design_doc_name, 'language' => 'coffeescript')

      begin
        hash_doc = JSON::parse Dolly::Document.database.get(view_doc["_id"]).parsed_response

        rev = hash_doc.delete('_rev')

        if hash_doc == view_doc
          puts 'everything up to date'
        else
          view_doc["_rev"] = rev
          puts "Updating #{design_doc_name}"
          will_save = true
        end

      rescue Dolly::ResourceNotFound
        puts "Creating design doc: #{design_doc_name}"
        will_save = true
      end

      Dolly::Document.database.put design_doc_name, view_doc.to_json if will_save
    end
  end

end
