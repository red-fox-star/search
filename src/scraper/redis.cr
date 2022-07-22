{% if flag?(:persistent_cache) %}

require "redis"

class PersistentCache
  def self.i : Redis::PooledClient
    @@connection ||= Redis::PooledClient.new url: "redis://localhost:6379/0"
  end
end

{% end %}
