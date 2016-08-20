require "http/client"
require "json"
require "kemal"

require "./nilable_hash"
require "./concourse-summary/*"

alias GroupHash = NilableHash(String, NilableHash(String, Array(String)?)?)
REFRESH_INTERVAL = (ENV["REFRESH_INTERVAL"]? || 30).to_i
GROUPS = Hash(String, GroupHash).from_json(ENV["CS_GROUPS"]? || "{}")

def setup(env)
  refresh_interval = REFRESH_INTERVAL
  username = env.store["credentials_username"]?
  password = env.store["credentials_password"]?
  ignore_groups = env.params.query.has_key?("ignore_groups")
  {refresh_interval,username,password,ignore_groups}
end

def process(data, ignore_groups)
  if (ignore_groups)
    data = MyData.remove_group_info(data)
  end
  statuses = MyData.statuses(data)
end

get "/host/:host" do |env|
  refresh_interval,username,password,ignore_groups = setup(env)
  host = env.params.url["host"]

  data = MyData.get_data(host, username, password, nil)

  statuses = process(data, ignore_groups)
  render "views/host.ecr", "views/layout.ecr"
end

get "/group/:key" do |env|
  refresh_interval,username,password,ignore_groups = setup(env)

  hosts = GROUPS[env.params.url["key"]]
  hosts = hosts.map do |host, pipelines|
    data = MyData.get_data(host, username, password, pipelines)
    data = MyData.filter_groups(data, pipelines)
    statuses = process(data, ignore_groups)
    { host, statuses }
  end

  hosts
  render "views/group.ecr", "views/layout.ecr"
end

get "/" do |env|
  hosts = (ENV["HOSTS"]? || "").split(/\s+/)
  groups = GROUPS.keys
  render "views/index.ecr", "views/layout.ecr"
end

Kemal.config.add_handler ExposeUnauthorizedHandler.new
Kemal.run
