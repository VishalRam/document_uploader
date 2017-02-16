module DocumentUploader
  class Configuration
    attr_accessor :storage, :s3_region, :s3_credentials, :path

    def initialize
      @storage = nil
      @s3_region = nil
      @s3_credentials = nil
      @path = nil
    end
  end
end
