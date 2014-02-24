module Epicify

  class AsanaAdapter

    def initialize(api_key, logger = nil)
      @api_key = api_key
      @logger = logger
    end

    def log(message)
      if @logger
        @logger.log(message)
      end
    end

    def get_projects
      _make_request(:get, "/projects/")
    end

    def get_tasks_for_project project_id
      _make_request(:get, "/projects/#{project_id}/tasks?opt_fields=id,name,completed,tags")
    end

    def update_task_name task_id, name
      _make_request :put, "/tasks/#{task_id}", _json_bodyify({"id" => task_id, "name" => name })
    end

    def associate_tag_with_task tag_id, task_id
      _tag_action "addTag", tag_id, task_id
    end

    def remove_tag_from_task tag_id, task_id
      _tag_action "removeTag", tag_id, task_id
    end

    private

      def _tag_action action, tag_id, task_id
        _make_request :post, "/tasks/#{task_id}/#{action}", _json_bodyify({"tag" => tag_id})
      end

      def _json_bodyify data
        {
          "data" => data
        }.to_json()
      end

      def _make_request type, url, body = nil

        log "_make_request #{type} - #{url}"

        uri = _uri_for_url(url)
        http = _http_for_uri(uri)
        req = _request_for(type, uri)

        if body
          req.body = body
        end

        res = _send_request_to_actual_service(http, req)

        body = JSON.parse(res.body)
        if body['errors'] then
          puts "Server returned an error: #{body['errors'][0]['message']}"
          return nil
        else
          return body['data']
        end

      end

      def _send_request_to_actual_service http, req
        http.start { |http| http.request(req) }
      end

      def _uri_for_url(url)
        full_path = "https://app.asana.com/api/1.0" + url
        URI.parse(full_path)
      end

      def _http_for_uri(uri)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http
      end

      def _request_for(type, uri)

        req = nil

        header = {
          "Content-Type" => "application/json"
        }

        if type == :get
          maybe_query = uri.query ? "?" + uri.query : ""
          req = Net::HTTP::Get.new(uri.path + maybe_query, header)
        elsif type == :post
          req = Net::HTTP::Post.new(uri.path, header)
        elsif type == :put
          req = Net::HTTP::Put.new(uri.path, header)
        end

        req.basic_auth(@api_key, '')

        req
      end

  end

end
