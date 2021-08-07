# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'

require 'base64'
require 'rest-client'
require 'json'

##
# Registry Client for interacting with the RESTful API
# of any Docker registry.
class Registry
    def initialize(url, username, password)
        @url = url
        @headers = { 'Authorization' => "Basic #{Base64.encode64("#{username}:#{password}").chomp}",
                     'Accept' => 'application/vnd.docker.distribution.manifest.v2+json' }
        # puts @headers.inspect
    end

    def repositories
        route('/v2/_catalog', @headers)
    end

    def tags(repository)
        route("/v2/#{repository}/tags/list", @headers)
    end

    def manifest(repository, tag)
        route("/v2/#{repository}/manifests/#{tag}", @headers, full_request: true)
    end

    def delete_manifest(repository, shasum)
        RestClient.delete "#{@url}/v2/#{repository}/manifests/#{shasum}"
    end

    def self.parse_digest(request)
        request.headers[:docker_content_digest]
    end

    def route(path, headers, full_request: false)
        request = RestClient.get "#{@url}#{path}", headers
        return JSON.parse(request.body) if request.code == 200 && !full_request

        request
    end
end
