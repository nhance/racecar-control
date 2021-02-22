require 'barby/barcode/code_39'
require 'barby/outputter/html_outputter'
require 'barby/outputter/png_outputter'

module BarcodeCapable
  extend ActiveSupport::Concern

  BARCODE_OFFSET = 10000_00000_00000_00000_000 # 23 digits (prepended with 'C' or 'D')
  BARCODE_FORMAT = /([A-Z]+)\d0*(\d+)/ # Update in #generate_barcode if changing here.
                                     # Does not account for length of string.
  included do
    after_create :generate_barcode
  end

  module ClassMethods
    def valid_barcode?(barcode)
      if (match = BARCODE_FORMAT.match(barcode))
        barcode, klass_caps, id = match.to_a
        if klass_caps == barcode_chars
          OpenStruct.new(klass: self, id: id)
        else
          nil
        end
      end
    end

    def barcode_for_id(id)
      klass_chars = barcode_chars
      id_string   = (barcode_offset + id).to_s

      "#{klass_chars}#{id_string}"
    end

    def barcode_offset
      BARCODE_OFFSET
    end

    def barcode_chars
      to_s.upcase[0]
    end
  end

  def barcode_path
    File.join(Rails.root, "/public/barcodes/#{self.class.name.pluralize.downcase}/")
  end

  def barcode_filename
    "#{self.barcode_path}#{self.barcode}.png"
  end

  def barcode_exists?
    File.exist?(self.barcode_filename)
  end

  def barcode_html
    Barby::Code39.new(self.barcode).to_html.html_safe
  end

  def generate_barcode(force_reload: false)
    if (self.barcode.blank? || force_reload)
      self.barcode = self.class.barcode_for_id(self.id)
      raise Exception("Generated barcode #{self.barcode} is invalid. Please change BARCODE_FORMAT") unless BARCODE_FORMAT.match(self.barcode)
    end

    self.update_column(:barcode, self.barcode) if self.barcode_changed?

    write_barcode if not barcode_exists? or force_reload
  end

  private
  def write_barcode
    # Barcode writing disabled as we aren't using it
    # bc = Barby::Code39.new(self.barcode)
    # File.open(self.barcode_filename, 'w') { |f| f.write bc.to_png(height: 25, xdim: 2) }
  end
end
