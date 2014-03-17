require 'dolly/document'
require 'dolly/couch_view_doc'

module Dolly
  class DesignTasksHelper

    EXTENSIONS = {coffee: 'coffeescript', erl: 'erlang', js: 'javascript'}
    DESIGNS_PATH = File.join(Rails.root, 'db', 'designs')

    def load!
      documents = {}

      design_docs.each do |view_path|
        doc_id = view_path.split('/')[-2]
        file_type = file_type( view_path )
        view_name, view_functions = process_view( view_path )
        documents[ doc_id ] ||= CouchViewDoc.new(doc_id, file_type)
        documents[ doc_id ][:views][view_name] = view_functions
      end

      documents.each{ |id, doc| post_process_design doc }

      Dolly::Document.bulk_save
    end

    def design_docs
      base_path = File.join(DESIGNS_PATH, '*/*')
      Dir[ base_path ]
    end

    def file_type filename
      ext = File.extname filename
      ext_key = ext.gsub('.','').to_sym
      EXTENSIONS[ ext_key ]
    end

    def post_process_design doc
      if remote_doc = retrieve_doc( doc.id )
        update_existing_design_document doc, *doc_to_hash( remote_doc )
      else
        create_design_document doc
      end
    end

    def process_view filename
      name, key  = File.basename(filename).sub(/.coffee/i, '').split(/\./)
      key ||= 'map'
      data = File.read filename
      [name, { key => data }]
    end

    def retrieve_doc doc_id
      request = Dolly::Document.database.get( doc_id )
      request.parsed_response.is_a?(Hash) ? request.parsed_response : JSON::parse( request.parsed_response )
    rescue Dolly::ResourceNotFound
      nil
    end

    def doc_to_hash doc
      hash_doc = doc.to_hash
      rev = hash_doc.delete('_rev')
      [hash_doc, rev]
    end

    def update_existing_design_document new_doc, remote_doc, rev = nil
      if new_doc.to_hash == remote_doc
        puts "#{new_doc.id} is up to date"
      else
        new_doc.rev = rev
        puts "updating #{new_doc.id}"
        new_doc.save
      end
    end

    def create_design_document doc
      puts "creating #{doc.id}"
      doc.save true
    end

    def is_main_path? path
      path == "#{DESIGNS_PATH}/"
    end

  end
end
