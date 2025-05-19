module ApplicationHelper

  include Pagy::Frontend

  # this method is based on the Luhn algorithm (aka Mod 10)
  # wikipedia provides a clear explanation of it:
  # http://en.wikipedia.org/wiki/Luhn_algorithm#Implementation_of_standard_Mod_10
  def ApplicationHelper.valid_barcode?(barcode)
    if barcode.is_a? Fixnum
      barcode = barcode.to_s
    end

    # Code taken from POD, updated to reflect that we only care about MDPI barcodes here (beginning with a 4)
    #
    # The following is ONLY true of the Physical Object Database (POD) where this code comes from. It also
    # varies in that MDPI barcodes begin with the number 4, whereas IU barcodes begin with the number 3
    mode = '4'

    if barcode.nil? or barcode.length != 14 or barcode[0] != mode
      puts "failed check"
      return false
    end

    check_digit = barcode.chars.pop.to_i
    sum = 0
    barcode.reverse.chars.each_slice(2).map do |even, odd|
      o = (odd.to_i * 2).divmod(10)
      sum += o[0] == 0 ? o[1] : o[0] + o[1]
      sum += even.to_i
    end
    # need to remove the check_digit from the sum since it was added in the iteration and
    # should not be part of the total sum
    ((sum - check_digit) * 9) % 10 == check_digit
  end

  def ApplicationHelper.mdpi_barcode_assigned?(barcode)
    b = false
    if (po = Recording.where(mdpi_barcode: barcode).limit(1)).size == 1
      b = po[0]
    end
    return b
  end

  def ApplicationHelper.valid_mdpi_barcode(seed = 0, prefix = 0)
    generate_barcode(true, seed, 4)
  end

  def boolean_to_yes_no(bool)
    if bool.nil?
      ""
    else
      bool == false ? 'No' : 'Yes'
    end
  end

  def self.fulltext_search(text)
    AvalonItem.search do
      fulltext text do
        fields(:avalon_id, :recordings, :performances, :tracks, :title => 2.0)
      end
    end
  end

  def self.hide_sql
    ActiveRecord::Base.logger.level = 1
  end
  def self.show_sql
    ActiveRecord::Base.logger.level = 0
  end

  private
  def ApplicationHelper.generate_barcode(valid = true, seed = 0, prefix = 0)
    if prefix.zero?
      barcode = 4 * (10**13)
    else
      prefix = 4.to_s + prefix.to_s
      barcode = prefix.to_i * (10**(14 - prefix.length))
    end
    if seed.zero?
      barcode += SecureRandom.random_number(10**11)*10
    else
      barcode += seed * 10
    end
    check_digit = 0
    (0..9).each do |x|
      check_digit = x
      break if valid == ApplicationHelper::valid_barcode?(barcode + check_digit)
    end
    return barcode + check_digit
  end

end
