# Module providing functions for handling responses from the http layer
module ResponsesHandlers
  protected

  def handle_response(verb, response, path, root_name = nil)
    case response.code
    when 200..299 then handle_response_success(response, root_name)
    when 404 then nil
    when 422 then handle_response_unprocessable_entity(response)
    else
      summary = "'#{verb} #{path}' failed with status = #{response.code}"
      raise "Shore Payment Service: #{summary}."
    end
  end

  def handle_response_success(response, root_name = nil)
    response_json = JSON.parse(response.body)
    root_name.nil? ? response_json : response_json[root_name]
  end

  def handle_response_unprocessable_entity(response)
    error = JSON.parse(response.body)['error'] || 'request error'
    raise error
  end
end
