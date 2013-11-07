namespace :db do
  desc "Will create if missing database and add default views"
  task setup: :environment do
    VIEW_DOC = {
      language: "coffeescript",
      views: {
        find: {
          map: "(d)->\n  if d._id\n    [str, t, id] = d._id.match /([^/]+)[/](.+)/\n    emit [t, id], 1 if t and id"
        }
      }
    }.freeze

    Dolly::Document.database.put "", nil

    remote_doc = begin
      JSON.parse Dolly::Document.database.get(Dolly::Document.design_doc).parsed_response
    rescue Dolly::ResourceNotFound
      {}
    end

    doc = VIEW_DOC.merge remote_doc

    Dolly::Document.database.put Dolly::Document.design_doc, doc.to_json
    puts "design document #{Dolly::Document.design_doc} was created/updated."
  end
end
