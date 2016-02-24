# Module providing functions for handling responses from the http layer
module ResponsesHandlers
  protected

  def handle_response(verb, response, path, root_name = nil)
    case response.code
    when 200..299
      response_json = JSON.parse(response.body)
      root_name.nil? ? response_json : response_json[root_name]
    when 404 then nil
    when 422 then 
      response_json = JSON.parse(response.body)
      response_json = response_json['error'] if response_json.key?('error')
      raise "TSS: '#{verb} #{path}' failed with status = #{response.code}, \
message: #{response_json}."
    else raise "TSS: '#{verb} #{path}' failed with status = #{response.code}."
    end
  end
end
