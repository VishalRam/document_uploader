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

	if Rails.env.development?
  	has_attached_file :attachment
	else
  	has_attached_file :attachment,
                    storage: :s3,
                    s3_region: "s3-ap-south-1.amazonaws.com",
                    s3_credentials: Settings.s3_settings.to_h,
                    path: ":environment/:class/:attachment/:documentable_type/:documentable_id/:category/:style/:filename"
	end
	validates_attachment :attachment, :presence => true, :content_type => {:content_type => ["image/jpeg", "image/jpg", "image/gif", "image/png", "application/pdf"]}, :size => {:in => 0..10.megabyte}
	before_post_process :rename_doc


	# enum category: {registration: 0, road_tax: 1, pollution: 2, insurance: 3,
  #                all_india_permit: 4, authorization: 5, endorsement_form: 6, rent_a_cab_license: 7, amc: 8,
  #                estimate: 10, approve_estimate: 11, invoice: 12, approve_invoice: 13, survey: 14, approve_survey: 15, approve_final_survey: 16, fir: 17, driver_DL: 18, car_image: 19, other: 20}
	# enum s3_status: {sync_pending: 0, successful: 1}
	# enum file_type: {jpeg: 0, pdf: 1}


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
  	Settings.s3_environment || Rails.env
	end


	def rename_doc
		self.attachment.instance_write :name, "#{Time.now.to_i}_#{self.attachment_file_name.gsub(/\s/, '_')}"
	end
end
