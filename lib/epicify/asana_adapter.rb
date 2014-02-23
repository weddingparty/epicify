module Epicify

  class AsanaAdapter

    def initialize(api_key)
      @api_key = api_key
    end

    def get_projects
      _make_request(:get, "/projects/")
    end

    def get_tasks_for_project project_id
      _make_request(:get, "/projects/#{project_id}/tasks?opt_fields=id,name,completed,tags")
    end

    def update_task_name task_id, name
      body = {
        "data" => {
          "id" => task_id,
          "name" => name,
        }
      }.to_json()
      _make_request :put, "/tasks/#{task_id}", body
    end

    def associate_tag_with_task tag_id, task_id
      body = {
        "data" => {
          "tag" => tag_id
        }
      }.to_json()
      _make_request :post, "/tasks/#{task_id}/addTag", body
    end

    def remove_tag_from_task tag_id, task_id
      body = {
          "data" => {
            "tag" => tag_id
          }
        }.to_json()
        log "#{body}"
      _make_request :post, "/tasks/#{task_id}/removeTag", body
    end

    private

      def _make_request type, url, body = nil

        log "_make_request #{type} - #{url}"

        full_path = "https://app.asana.com/api/1.0" + url
        uri = URI.parse(full_path)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER

        header = {
          "Content-Type" => "application/json"
        }

        req = nil
        if type == :get
          maybe_query = uri.query ? "?" + uri.query : ""
          req = Net::HTTP::Get.new(uri.path + maybe_query, header)
        elsif type == :post
          req = Net::HTTP::Post.new(uri.path, header)
        elsif type == :put
          req = Net::HTTP::Put.new(uri.path, header)
        end
        req.basic_auth(@api_key, '')

        if body
          req.body = body
        end

        res = http.start { |http| http.request(req) }

        body = JSON.parse(res.body)
        if body['errors'] then
          puts "Server returned an error: #{body['errors'][0]['message']}"
          return nil
        else
          return body['data']
        end

      end

  end

end
