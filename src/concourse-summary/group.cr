require "json"

alias GroupHash = Hash(String,Hash(String,Array(String)))

class Group
  def self.parse(json, key)
    GroupHash.from_json(json, key)
  end

  def self.all(hash : GroupHash)
    hash.map do |host,pipelines|
      client = HTTP::Client.new(host, tls: true)
      # client.basic_auth(username, password)
      Pipeline.all(client).map do |pipeline|
        next unless pipelines.has_key?(pipeline.name)
        Job.all(client, pipeline.url).map do |job|
          {pipeline, job}
        end
      end.flatten
    end.flatten.compact
  end
end
