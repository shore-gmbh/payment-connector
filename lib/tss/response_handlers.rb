# Module providing functions for handling responses from the http layer
module ResponsesHandlers
  protected

  def handle_response(verb, response, path, root_name = nil)
    case response.code
    when 200..299
      response_json = JSON.parse(response.body)
      root_name.nil? ? response_json : response_json[root_name]
    when 404 then nil
    else fail "TSS: '#{verb} #{path}' failed with status = #{response.code}."
    end
  end
end
