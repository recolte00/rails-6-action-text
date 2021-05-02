class Post < ApplicationRecord
	has_rich_text :content
	
	validates :title, length: {maximum: 32}, presence: true

        private

        validate :validate_content_length
        MAX_CONTENT_LENGTH = 120

        def validate_content_length
          length = content.to_plain_text.length
          if length >  MAX_CONTENT_LENGTH 
            errors.add(
                       :content, 
                       :too_long,
                       max_content_length: MAX_CONTENT_LENGTH,
                       length: length
                      )
          end
        end 

        validate :validate_attachment_size
        ONE_KILOBYTE = 1024
        MEGA_BYTES = 4 
        MAX_ATTACH_SIZE = MEGA_BYTES * 1_000 * ONE_KILOBYTE

        def validate_attachment_size
          content.body.attachables.grep(ActiveStorage::Blob).each do |attachable|
            if attachable.byte_size > MAX_ATTACH_SIZE
             errors.add(
                        :base,
                        :content_attachment_byte_size_is_too_big,
                        mega_bytes: MEGA_BYTES,
                        size: attachable.byte_size,
                        max_attach_size: MAX_ATTACH_SIZE
                       )
           end
          end
        end
        
        validate :validate_attachment_count
        MAX_CONTENT_ATTACHMENT_COUNT = 4

        def validate_attachment_count
          if content.body.attachables.grep(ActiveStorage::Blob).count > MAX_CONTENT_ATTACHMENT_COUNT
            errors.add(
              :content,
              :attachment_count_is_too_big,
              max_content_attachments_count: MAX_CONTENT_ATTACHMENT_COUNT  
            )
          end
        end

end
