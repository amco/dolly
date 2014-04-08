require 'dolly/document'
require 'dolly/couch_view'

module Dolly
  class DesignTasksHelper

    EXTENSIONS = {coffee: 'coffeescript', js: 'javascript'}
    DESIGNS_PATH = File.join(Rails.root, 'db', 'designs')

    def load!
      design_views = {}
      designs.each{ |view_path| design_views.deep_merge! build_design( view_path ) }
      design_views.each{ |id, design| post_process design, id }
    end

    private

    def build_design view_path
      view_id   = view_path.split('/')[-2]
      file_type = file_type( view_path )

      { view_id => { type: file_type, views: process_view( view_path ) } }
    end

    def designs
      base_path = File.join(DESIGNS_PATH, '*/*')
      Dir[ base_path ]
    end

    def post_process design, view_id
      design_view = CouchView.new( view_id, design[ :type ] )
      design_view.set_view( design[ :views ] )

      remote_design = design_hash( retrieve_design design_view.id )
      ensure_design( design_view, *remote_design )
    end

    def file_type filename
      ext = File.extname( filename ).sub('.','')
      EXTENSIONS[ ext.to_sym ]
    end

    def process_view filename
      name, key = File.basename(filename).sub(/.coffee/i, '').split(/\./)
      key ||= 'map'
      data = File.read filename
      { name => { key => data } }
    end

    def retrieve_design name
      request = Document.database.get( name )
      request.parsed_response.is_a?(Hash) ? request.parsed_response : JSON::parse( request.parsed_response )
    rescue ResourceNotFound
      nil
    end

    def design_hash design
      hash = design.to_hash
      rev = hash.delete('_rev')
      [hash, rev]
    end

    def ensure_design design, remote_design, rev = nil
      if design.present?
        update_existing_design design, remote_design, rev
      else
        create_design design
      end
    end

    def update_existing_design new_design, remote_design, rev
      unless new_design.to_hash == remote_design
        new_design.rev = rev
        new_design.save
      end
    end

    def create_design design
      design.save true
    end

  end
end
