module Layer
  class ResourceCollection < Enumerator

    def initialize(resource, client)
      @resource = resource
      @client = client
      @params = { page_size: 100 }
      @counter = 0

      super() do |yielder|
        while response = next_page
          response.map do |attributes|
            yielder << resource.from_response(attributes, client)
          end
        end
      end
    end

  private

    attr_reader :resource, :client, :params

    def next_page
      response = client.get(resource.url, {}, { params: params })
      return nil if response.empty? || @counter > max_pages
      @counter += 1
      params[:from_id] = Layer::Client.normalize_id(response.last['id'])
      response
    end

    def max_pages
      ENV['max_conversation_pages'].to_i || 3
    end

  end
end
