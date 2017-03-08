module Riak
  module Helpers

    def create_admin(endpoint)
      require 'net/http'
      require 'uri'
      require 'json'

      uri = URI.parse("http://localhost:8080/riak-cs/user")
      request = Net::HTTP::Post.new(uri)
      request.content_type = "application/json"
      request.body = JSON.dump({
        "email" => "admin@#{endpoint}",
        "name" => "admin"
      })

      req_options = {
        use_ssl: uri.scheme == "https"
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      result = JSON.parse(response.body) #rescue result = nil
      return result
    end
  end
end
