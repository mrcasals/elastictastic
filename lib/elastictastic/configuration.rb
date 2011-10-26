module Elastictastic
  class Configuration
    attr_writer :hosts, :adapter, :default_index, :auto_refresh, :default_batch_size
    attr_accessor :logger

    def host=(host)
      @hosts = [host]
    end

    def hosts
      @hosts ||= ['http://localhost:9200']
    end

    def adapter
      @adapter ||= :net_http
    end

    def default_index
      @default_index ||= 'default'
    end

    def auto_refresh
      !!@auto_refresh
    end

    def default_batch_size
      @default_batch_size ||= 100
    end
  end
end
