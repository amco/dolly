# frozen_string_literal: true

namespace :db do
  desc "Will create if missing database and add default views"
  task setup: :environment do
    Dolly::Document.connection.put '', {}
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
        hash_doc = Dolly::Document.connection.request(:get, view_doc["_id"])

        rev = hash_doc.delete(:_rev)

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

      Dolly::Document.connection.request :put, design_doc_name, view_doc if will_save
    end
  end

  namespace :search do
    desc 'Creates search indexes for lucend style queries.'
    task :create, [:db, :analyzer] => :environment do |_t, args|
      analyzer = args[:analyzer].presence || 'standard'

      db = args[:db].present? ? "/#{args[:db]}/" : ''
      design_dir = Rails.root.join 'db', 'searches'
      files = Dir.glob File.join design_dir, '**', '*.js'

      puts "\n\e[44m== Updating search indexes ==\e[0m\n\n"

      docs = files.map do |filename, acc|
        name  = File.basename(filename).sub(/.js/i, '')
        source = File.read filename
        design_doc_name = "_design/#{name}"

        doc = begin
                Dolly::Document.connection.request(:get, "#{db}#{design_doc_name}")
              rescue Dolly::ResourceNotFound
                {}
              end

        data = {
          _id: design_doc_name,
          indexes: {
            name => {
              index: source,
              analyzer: analyzer
            }
          }
        }

        if data[:indexes].to_json == doc[:indexes].to_json
          puts "\e[32mSearch index #{name} is up to date.\e[0m"
          {}
        else
          puts "\e[36mSearch Index #{name} will be updated.\e[0m"
          doc.merge!(data)
        end
      end

      res = Dolly::Document.connection.request :post, "#{db}_bulk_docs", docs: docs
      failed = res.reject { |r| r[:ok] }

      if failed.present?
        puts "\n\e[31mThe following indexes failed to be persisted:\e[0m"

        failed.each do |doc|
          puts "  \e[35m* #{doc[:id]}\e[0m"
        end
        puts "\n"
      else
        puts "\n\e[5m\e[42mAll search indexes saved successfully.\e[0m\e[25m\n\n"
      end
    end
  end

  namespace :index do
    desc 'Creates indexes for mango querys located in db/indexes/*.json'
    task create: :environment do
      indexes_dir = Rails.root.join('db', 'indexes')
      files = Dir.glob File.join(indexes_dir, '**', '*.json')

      files.each do |file|
        index_data = JSON.parse(File.read(file))
        database = index_data.fetch('db', 'default').to_sym
        puts "*" * 100
        puts "Creating index: #{index_data["name"]} for database: #{database}"

        if database == Dolly::Connection::DEFAULT_DATABASE
          puts Dolly::MangoIndex.create(index_data['name'], index_data['fields'])
        else
          puts Dolly::MangoIndex.create_in_database(database, index_data['name'], index_data['fields'])
        end
      end
    end
  end
end

