require 'base64'

module Dolly
  module Attachment
    def attach_file! file_name, mime_type, body, opts={}
      attach_file file_name, mime_type, body, opts
      save
    end

    def attach_file file_name, mime_type, body, opts={}
      if opts[:inline]
        attach_inline_file file_name, mime_type, body
      else
        attach_standalone_file file_name, mime_type, body
      end
    end

    def attach_inline_file file_name, mime_type, body
      attachment_data = { file_name.to_s => { 'content_type' => mime_type,
                                              'data'         => Base64.encode64(body)} }
      doc['_attachments'] ||= {}
      doc['_attachments'].merge! attachment_data
    end

    def attach_standalone_file file_name, mime_type, body
      self.class.connection.attach id_as_resource, CGI.escape(file_name), body, { 'Content-Type' => mime_type }
    end
  end
end
