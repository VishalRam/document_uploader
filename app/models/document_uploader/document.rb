# == Schema Information
#
# Table name: documents
#
#  id                      :integer          not null, primary key
#  category                :integer
#  attachment_file_name    :string(255)
#  attachment_content_type :string(255)
#  attachment_file_size    :integer
#  attachment_updated_at   :datetime
#  s3_status               :integer
#  reference_number        :integer
#  validity_start          :datetime
#  validity_end            :datetime
#  uploaded_by             :integer
#  documentable_id         :integer
#  documentable_type       :string(255)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class DocumentUploader::Document < ActiveRecord::Base
	
	belongs_to :documentable, :polymorphic => true
	
	self.table_name="documents"
	validates :documentable_id, :documentable_type, presence: true

	config = DocumentUploader.configuration
	if config.storage == "local" || config.storage.nil?
  		has_attached_file :attachment
	elsif config.storage == "s3"
  	has_attached_file :attachment,
                   storage: :s3,
                   s3_region: config.s3_region,
                   s3_credentials: config.s3_credentials,
                   path: config.path
	end
	validates_attachment :attachment, :presence => true, :content_type => {:content_type => ["image/jpeg", "image/jpg", "image/gif", "image/png", "application/pdf"]}, :size => {:in => 0..10.megabyte}


	Paperclip.interpolates :documentable_type do |attachment, style|
  	attachment.instance.documentable_type.underscore
	end
	Paperclip.interpolates :documentable_id do |attachment, style|
  	attachment.instance.documentable_id
	end
	Paperclip.interpolates :category do |attachment, style|
  	attachment.instance.category
	end
	Paperclip.interpolates :environment do |attachment, style|
  	Rails.env
	end

end
