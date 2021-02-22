class ContactSerializer
  def self.serialize(items)
    new(items).as_json
  end

  def initialize(items)
    @serialized_hash = items.map { |i| hash_with_contact_details(i) }
  end

  def as_json
    @serialized_hash
  end

  private
  def hash_with_contact_details(item)
    case item
    when Driver
      { id: item.id, name: item.full_name }
    when Registration
      { id: item.id, name: item.name }
    when DriverRegistration
      { id: item.id, name: item.driver.try(:full_name) }
    end
  end
end
