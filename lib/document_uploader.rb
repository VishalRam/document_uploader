require_relative 'document_uploader/configuration'
require "document_uploader/version"
require 'bundler'
Bundler.setup

require_relative 'document_uploader/engine'

module DocumentUploader
	class << self
		attr_accessor :configuration
	end

	def self.configuration
    	@configuration ||= Configuration.new
  	end

	def self.reset
		@configuration = Configuration.new
	end

	def self.configure
		yield(configuration)
	end
end
