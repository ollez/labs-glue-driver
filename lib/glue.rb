require "glue/version"
require "active_support/core_ext"

class Glue
  def initialize(options = {})
    @options = options
  end

  class Flow
    attr_reader :attributes, :glue

    def initialize(glue, attributes)
      @glue = glue
      @attributes = attributes
    end

    def publish
      response = glue.post_form('/workflows',
                  rule: attributes[:rule_reference],
                  smooks_config_url: attributes[:smooks_config_url])
      if response
        attributes[:reference] = response["flow-name"]
      else
        response
      end
    end

    def start
      response = glue.put flow_url('start')
      wait_for_state('running', response && response['state'])
    end

    def stop
      response = glue.put flow_url('stop')
      wait_for_state('stopped', response && response['state'])
    end

    def send_data(data)
      glue.post flow_url("data"),
                content_type: 'application/json',
                body: data
    end

    def get_results(options = {})
      glue.get flow_url("result?nres=#{options[:limit]}")
    end

    def get_results_breakdown(options = {})
      glue.get flow_url("result_breakdown?since=60")
    end

    def get_incoming_breakdown(options = {})
      glue.get flow_url("data_breakdown?since=60")
    end

    def state
      response = glue.get flow_url
      response && response["state"]
    end

    private

    def flow_url(action = nil)
      "/workflows/#{attributes[:reference]}#{"/#{action.to_s}" if action.present?}"
    end

    def wait_for_state(desired_state, current_state = self.state)
      5.times do
        return current_state if current_state == desired_state
        sleep 1
        current_state = self.state
      end
      false
    end
  end

  def flow(attributes)
    Flow.new self, attributes
  end

  def post(path, options)
    request = Net::HTTP::Post.new path
    request.content_type = options[:content_type]
    request.body = options[:body]

    parsed_response request
  end

  def post_form(path, data)
    request = Net::HTTP::Post.new path
    request.set_form_data data

    parsed_response request
  end

  def put(path)
    parsed_response Net::HTTP::Put.new(path)
  end

  def get(path)
    parsed_response Net::HTTP::Get.new(path)
  end

  private

  def http
    uri = URI(@options[:url])
    @http ||= Net::HTTP.new(uri.host, uri.port)
  end

  def parsed_response(request)
    response = http.request(request)

    if response.is_a?(Net::HTTPOK)
      response.body.blank? or begin
        JSON.parse(response.body)
      rescue
        response.body
      end
    else
      false
    end
  end
end
