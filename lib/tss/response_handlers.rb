# Module providing functions for handling responses from the http layer
module ResponsesHandlers
  protected

  def handle_post_put_response(response, path)
    case response.code
    when 200..299 then JSON.parse(response.body)
    else fail "TSS: 'POST/PUT #{path}' failed with status = #{response.code}."
    end
  end

  def handle_get_response(response, path, root_name)
    case response.code
    when 200 then JSON.parse(response.body)[root_name]
    when 404 then nil
    else fail "TSS: 'GET #{path}' failed with status = #{response.code}."
    end
  end

end
